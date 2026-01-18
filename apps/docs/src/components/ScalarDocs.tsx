import { useEffect } from "react";
import "@scalar/api-reference/style.css";
import { createApiReference } from "@scalar/api-reference";

interface ScalarDocsProps {
  openApiUrl: string;
}

export default function ScalarDocs({ openApiUrl }: ScalarDocsProps) {
  useEffect(() => {
    const el = document.getElementById("scalar-root");

    if (!el) return;

    el.innerHTML = "";

    createApiReference(el, {
      url: openApiUrl,
    });
  }, [openApiUrl]);

  return (
    <div
      id="scalar-root"
      style={{
        height: "100vh",
        width: "100%",
      }}
    />
  );
}
