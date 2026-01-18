export type DocPage = {
  id: string;
  title: string;
  type: "markdown" | "api";
  content?: string; // For Markdown
  specUrl?: string; // For Scalar
  group: "General" | "Api references" | "Gateway";
};

export interface NavigationProps {
  currentPath: string;
  onNavigate: (path: string) => void;
}
