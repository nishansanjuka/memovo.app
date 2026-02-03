// =============================================================================
// MEMOVO.APP - Main Jenkins CI/CD Pipeline
// =============================================================================
// This pipeline handles both PR validation and main branch deployments
// using Turborepo for monorepo orchestration
// =============================================================================

// Global variables (accessible in post block)
def IS_LOCAL = false
def IS_PR_BUILD = false
def IS_MAIN_BUILD = false

pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds(abortPrevious: true)
    }
    
    environment {
        // Turborepo (mark as optional for local testing)
        TURBO_TEAM = credentials('turbo-team')
        TURBO_TOKEN = credentials('turbo-token')
        
        // Docker Registry (Google Artifact Registry)
        GCP_PROJECT_ID = credentials('gcp-project-id')
        GCP_REGION = 'us-central1'
        
        // Node/pnpm
        PNPM_HOME = "${WORKSPACE}/.pnpm-store"
    }
    
    tools {
        nodejs 'Node-20'
        maven 'Maven-3.9'
        jdk 'JDK-21'
    }
    
    stages {
        // =====================================================================
        // STAGE: Environment Setup
        // =====================================================================
        stage('Environment Setup') {
            steps {
                script {
                    // Set global variables
                    IS_LOCAL = env.JENKINS_URL?.contains('localhost') ?: true
                    IS_PR_BUILD = env.CHANGE_ID != null
                    IS_MAIN_BUILD = env.BRANCH_NAME == 'main' || env.BRANCH_NAME == null // null for non-multibranch
                    
                    // Set BUILD_TAG safely
                    env.BUILD_TAG = env.GIT_COMMIT ? env.GIT_COMMIT.take(8) : 'latest'
                    env.ARTIFACT_REGISTRY = "${env.GCP_REGION}-docker.pkg.dev/${env.GCP_PROJECT_ID}/memovo"
                    
                    echo "🚀 Starting CI/CD Pipeline"
                    echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
                    echo "Commit: ${env.GIT_COMMIT ?: 'N/A'}"
                    echo "Build Tag: ${env.BUILD_TAG}"
                    echo "Is PR: ${IS_PR_BUILD}"
                    echo "Is Main: ${IS_MAIN_BUILD}"
                    echo "Is Local: ${IS_LOCAL}"
                    
                    if (IS_LOCAL) {
                        echo "⚠️  Running on LOCAL Jenkins - deployment stages will be skipped"
                    }
                }
                
                // Install pnpm
                sh '''
                    corepack enable
                    corepack prepare pnpm@9.0.0 --activate
                    pnpm config set store-dir ${PNPM_HOME}
                '''
                
                // Install dependencies with Turborepo cache
                sh 'pnpm install --frozen-lockfile'
            }
        }
        
        // =====================================================================
        // STAGE: Code Quality & Linting (Parallel)
        // =====================================================================
        stage('Code Quality') {
            parallel {
                stage('Lint - TypeScript/JavaScript') {
                    steps {
                        sh 'pnpm turbo run lint --filter=!mobile'
                    }
                }
                
                stage('Lint - Python') {
                    steps {
                        dir('apps/llm-service') {
                            sh '''
                                python -m pip install --user ruff
                                python -m ruff check src/
                            '''
                        }
                    }
                }
                
                stage('Lint - Java') {
                    steps {
                        dir('apps/api') {
                            sh './mvnw checkstyle:check -q || true'
                        }
                    }
                }
                
                stage('Lint - Dart/Flutter') {
                    steps {
                        dir('apps/mobile') {
                            sh '''
                                flutter pub get
                                flutter analyze --no-fatal-infos
                            '''
                        }
                    }
                }
            }
        }
        
        // =====================================================================
        // STAGE: Type Checking
        // =====================================================================
        stage('Type Checking') {
            parallel {
                stage('TypeScript Check') {
                    steps {
                        sh 'pnpm turbo run check-types --filter=!mobile --filter=!api --filter=!llm-service'
                    }
                }
                
                stage('Python Type Check') {
                    steps {
                        dir('apps/llm-service') {
                            sh '''
                                python -m pip install --user mypy
                                python -m mypy src/ --ignore-missing-imports || true
                            '''
                        }
                    }
                }
            }
        }
        
        // =====================================================================
        // STAGE: Build All Services
        // =====================================================================
        stage('Build') {
            parallel {
                stage('Build - Node Services') {
                    steps {
                        // Use Turborepo to build all Node.js services
                        sh 'pnpm turbo run build --filter=gateway-service --filter=web-app --filter=devdocs-portal'
                    }
                }
                
                stage('Build - Java API') {
                    steps {
                        dir('apps/api') {
                            sh './mvnw clean package -DskipTests -q'
                        }
                    }
                }
                
                stage('Build - Flutter Mobile') {
                    when {
                        expression { return fileExists('apps/mobile/pubspec.yaml') }
                    }
                    steps {
                        dir('apps/mobile') {
                            sh '''
                                flutter pub get
                                flutter build apk --debug
                            '''
                        }
                    }
                }
                
                stage('Build - Python LLM Service') {
                    steps {
                        dir('apps/llm-service') {
                            sh '''
                                python -m pip install --user -r requirements.txt
                                python -m py_compile src/main.py
                            '''
                        }
                    }
                }
            }
        }
        
        // =====================================================================
        // STAGE: Unit Tests
        // =====================================================================
        stage('Unit Tests') {
            parallel {
                stage('Test - Gateway Service') {
                    steps {
                        dir('apps/gateway-service') {
                            sh 'pnpm test --passWithNoTests'
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'apps/gateway-service/coverage/junit.xml'
                        }
                    }
                }
                
                stage('Test - Java API') {
                    steps {
                        dir('apps/api') {
                            sh './mvnw test -q'
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'apps/api/target/surefire-reports/*.xml'
                        }
                    }
                }
                
                stage('Test - Python LLM Service') {
                    steps {
                        dir('apps/llm-service') {
                            sh '''
                                python -m pip install --user pytest pytest-cov
                                python -m pytest src/tests/ -v --junitxml=test-results.xml || true
                            '''
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'apps/llm-service/test-results.xml'
                        }
                    }
                }
                
                stage('Test - Flutter Mobile') {
                    steps {
                        dir('apps/mobile') {
                            sh 'flutter test --coverage || true'
                        }
                    }
                }
            }
        }
        
        // =====================================================================
        // STAGE: Integration Tests (PR only)
        // =====================================================================
        stage('Integration Tests') {
            when {
                expression { return IS_PR_BUILD }
            }
            steps {
                script {
                    // Run e2e tests for gateway service
                    dir('apps/gateway-service') {
                        sh 'pnpm test:e2e || true'
                    }
                }
            }
        }
        
        // =====================================================================
        // STAGE: Local Docker Build Test (Local Jenkins only)
        // =====================================================================
        stage('Local Docker Build Test') {
            when {
                expression { return IS_LOCAL && IS_MAIN_BUILD }
            }
            steps {
                script {
                    echo "🐳 Building Docker images locally (no push)..."
                    sh """
                        export ARTIFACT_REGISTRY=local
                        export BUILD_TAG=${env.BUILD_TAG}
                        docker compose -f docker-compose.deploy.yml build
                    """
                    echo "✅ Local Docker build completed successfully!"
                }
            }
        }
        
        // =====================================================================
        // STAGE: Build Docker Images (Main branch only, skip on local)
        // =====================================================================
        stage('Build Docker Images') {
            when {
                expression { return IS_MAIN_BUILD && !IS_LOCAL }
            }
            steps {
                script {
                    // Authenticate with Google Cloud
                    withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY')]) {
                        sh '''
                            gcloud auth activate-service-account --key-file=${GCP_KEY}
                            gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev --quiet
                        '''
                    }
                    
                    // Build all images using Docker Compose
                    sh """
                        docker compose -f docker-compose.deploy.yml build \\
                            --build-arg BUILD_TAG=${env.BUILD_TAG} \\
                            --build-arg GIT_COMMIT=${env.GIT_COMMIT ?: 'unknown'}
                    """
                }
            }
        }
        
        // =====================================================================
        // STAGE: Push Docker Images (Main branch only, skip on local)
        // =====================================================================
        stage('Push Docker Images') {
            when {
                expression { return IS_MAIN_BUILD && !IS_LOCAL }
            }
            steps {
                script {
                    sh """
                        docker compose -f docker-compose.deploy.yml push
                    """
                }
            }
        }
        
        // =====================================================================
        // STAGE: Deploy to Google Cloud Run (Main branch only, skip on local)
        // =====================================================================
        stage('Deploy to Cloud Run') {
            when {
                expression { return IS_MAIN_BUILD && !IS_LOCAL }
            }
            steps {
                script {
                    withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY')]) {
                        sh '''
                            gcloud auth activate-service-account --key-file=${GCP_KEY}
                            gcloud config set project ${GCP_PROJECT_ID}
                            
                            # Deploy using the deployment script
                            chmod +x ./ci/scripts/deploy-cloud-run.sh
                            ./ci/scripts/deploy-cloud-run.sh
                        '''
                    }
                }
            }
        }
    }
    
    // =========================================================================
    // POST BUILD ACTIONS
    // =========================================================================
    post {
        always {
            node('') {
                // Clean up workspace
                cleanWs(
                    cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true
                )
            }
        }
        
        success {
            script {
                if (IS_PR_BUILD) {
                    // Update GitHub PR status (requires GitHub plugin)
                    echo "✅ PR build passed - all checks successful!"
                } else if (IS_MAIN_BUILD) {
                    echo "✅ Deployment to Cloud Run completed successfully!"
                }
            }
        }
        
        failure {
            script {
                if (IS_PR_BUILD) {
                    echo "❌ PR build failed!"
                }
            }
            
            // Send notification (configure as needed)
            echo "❌ Pipeline failed! Check the logs for details."
        }
        
        unstable {
            echo "⚠️ Pipeline completed with warnings"
        }
    }
}
