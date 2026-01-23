export type DocPage = {
  id: string;
  title: string;
  type: "markdown" | "api";
  content?: string; // For Markdown
  specUrl?: string; // For Scalar
  group: "General" | "Microservices" | "Gateway";
};
