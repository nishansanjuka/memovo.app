package app.memovo.api.domain;

public class HealthStatus {
    private final String status;

    public HealthStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}
