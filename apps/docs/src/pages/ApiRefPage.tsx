import React from "react";
import { useParams } from "react-router-dom";
import { DOCS } from "@/constants";
import ScalarDocs from "@/components/ScalarDocs";

const ApiRefPage: React.FC = () => {
  const { apiId } = useParams<{ apiId: string }>();
  const activeDoc = DOCS.find((doc) => doc.id === apiId);

  if (!activeDoc) {
    return (
      <div className="flex h-screen w-full items-center justify-center text-zinc-400">
        API Reference not found.
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col min-w-0">
      <main className="flex-1 overflow-y-auto rounded-md">
        <ScalarDocs
          key={activeDoc.id}
          specUrl={activeDoc.specUrl || ""}
        />
      </main>
    </div>
  );
};

export default ApiRefPage;
