# Memovo Documentation App

This app provides interactive documentation and API references for the Memovo platform, including microservices, architecture, and live API specs.

## Features

- Vite-powered React app
- Dynamic API reference loading (dev/prod)
- Markdown-based docs
- Scalar API viewer integration

## Prerequisites

- Node.js (v18+ recommended)

## Setup & Run

1. Install dependencies:
   ```bash
   npm install
   # or
   pnpm install
   ```
2. Create a `.env` file in this directory with the following variables:
   ```env
   VITE_MEMOVO_API_URL=http://localhost:8080/api-docs
   VITE_GATEWAY_API_URL=http://localhost:4000/api-json
   ```

   - For production, set these to your deployed API endpoints.
3. Start the app:
   ```bash
   npm run dev
   # or
   pnpm dev
   ```

## API Reference

- The app loads OpenAPI specs from the URLs set in `.env`.
- Supports both development and production environments.

## Customization

- Edit `constants.tsx` to add or update documentation pages.
- API reference URLs are controlled via `.env` variables.

---

For more details, see the source code and comments in each file.
