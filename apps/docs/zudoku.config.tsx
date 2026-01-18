import type { ZudokuConfig } from "zudoku";

const config: ZudokuConfig = {
  site: {
    logo: {
      src: { light: "/logo-light.svg", dark: "/logo-dark.svg" },
      alt: "Zudoku",
      width: "130px",
    },
  },
  navigation: [
    {
      type: "category",
      label: "Documentation",
      items: [
        {
          type: "category",
          label: "Getting Started",
          icon: "sparkles",
          items: [
            "introduction",
            {
              type: "link",
              icon: "folder-cog",
              badge: {
                label: "New",
                color: "purple",
              },
              label: "API Reference",
              to: "/api",
            },
          ],
        },
        {
          type: "category",
          label: "Useful Links",
          collapsible: false,
          icon: "link",
          items: [
            {
              type: "link",
              icon: "book",
              label: "Zudoku Docs",
              to: "https://zudoku.dev/docs/",
            },
          ],
        },
      ],
    },
    {
      type: "link",
      to: "/api",
      label: "API Reference",
    },
  ],
  redirects: [{ from: "/", to: "/introduction" }],
  // apis.type can be "url" (for live endpoints) or "file" (for local OpenAPI files)
  // apis.input should be a valid URL or a relative file path
  apis: [
    {
      type: "url",
      input: "http://localhost:8080/api-docs", // Make sure this endpoint is reachable during build
      path: "/api",
    },
  ],
  plugins: [
    {
      getIdentities: async () => {
        return [
          {
            id: "bearer-token",
            label: "Bearer Token",
            authorizationFields: {
              headers: ["Authorization"],
            },
            authorizeRequest: async (request) => request,
          },
          {
            id: "api-key",
            label: "API Key",
            authorizationFields: {
              headers: ["x-api-key"],
            },
            authorizeRequest: async (request) => request,
          },
        ];
      },
    },
  ],
};

export default config;
