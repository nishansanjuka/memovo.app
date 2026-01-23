import React, { useEffect } from "react";
import { createApiReference } from "@scalar/api-reference";

interface ScalarDocsProps {
  specUrl: string;
}

const ScalarDocs: React.FC<ScalarDocsProps> = ({ specUrl }) => {
  useEffect(() => {
    const el = document.getElementById("scalar-root");
    if (!el) return;

    el.innerHTML = "";

    createApiReference(el, {
      url: specUrl,
      layout: "modern",
      theme: "deepSpace",
      withDefaultFonts: true,
      hideDarkModeToggle: true,
      darkMode: true,
      hideClientButton: true,
      hideSearch: true,
      hideDownloadButton: false,
    });
  }, [specUrl]);

  return (
    <div
      id="scalar-root"
      className="w-full h-screen overflow-auto bg-zinc-950"
    />
  );
};

export default ScalarDocs;
