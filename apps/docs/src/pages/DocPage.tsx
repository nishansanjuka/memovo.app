import React from "react";
import { useParams } from "react-router-dom";
import { DOCS } from "@/constants";
import MarkdownRenderer from "@/components/MarkdownRenderer";
import { BookOpen } from "lucide-react";
import { Github } from "lucide-react";

const DocPage: React.FC = () => {
  const { docId } = useParams<{ docId: string }>();
  const activeDoc = DOCS.find((doc) => doc.id === docId) || DOCS[0];

  return (
    <div className="flex-1 flex flex-col min-w-0">
      <header className="h-16 border-b border-zinc-800 bg-zinc-950/50 backdrop-blur-sm flex items-center justify-between px-8 shrink-0 z-10">
        <div className="flex items-center gap-4">
          <div className="text-sm font-medium text-zinc-500 flex items-center gap-2">
            <BookOpen size={16} />
            <span>Documentation</span>
            <span className="text-zinc-700">/</span>
            <span className="text-zinc-300 font-semibold uppercase tracking-tight">
              {activeDoc.title}
            </span>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <a
            href="https://github.com/nishansanjuka/memovo.app"
            target="_blank"
            rel="noopener noreferrer"
            className="p-2 hover:bg-zinc-900 rounded-full transition-colors"
          >
            <Github size={20} className="text-zinc-400" />
          </a>
        </div>
      </header>

      <main className="flex-1 overflow-y-auto relative">
        <div className="max-w-4xl mx-auto px-8 py-12 animate-in fade-in slide-in-from-bottom-2 duration-500">
          <div className="mb-8">
            <span className="text-xs font-bold text-purple-500 uppercase tracking-widest px-2 py-1 bg-purple-500/10 rounded mb-4 inline-block">
              Guide
            </span>
            <h1 className="text-4xl font-extrabold tracking-tight text-white mb-4">
              {activeDoc.title}
            </h1>
            <p className="text-zinc-400 text-lg">
              Learn about the core architecture and development workflow for the{" "}
              {activeDoc.title}.
            </p>
          </div>
          <MarkdownRenderer content={activeDoc.content || ""} />
          <div className="mt-20 pt-8 border-t border-zinc-900 flex justify-between">
            <div className="text-xs text-zinc-600 italic">
              Last updated: February 2024
            </div>
            <div className="flex gap-4">
              <button className="text-xs text-zinc-500 hover:text-white transition-colors">
                Edit this page
              </button>
              <button className="text-xs text-zinc-500 hover:text-white transition-colors">
                Submit feedback
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default DocPage;
