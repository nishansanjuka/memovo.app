import React, { useState, useEffect } from "react";
import Sidebar from "./components/Sidebar.tsx";
import MarkdownRenderer from "./components/MarkdownRenderer.tsx";
import ScalarDocs from "./components/ScalarDocs.tsx";
import { DOCS } from "./constants.tsx";
import { Search, Github, BookOpen } from "lucide-react";

const App: React.FC = () => {
  const [activePath, setActivePath] = useState<string>(() => {
    const hash = window.location.hash.replace("#", "");
    return DOCS.find((d) => d.id === hash) ? hash : DOCS[0].id;
  });

  useEffect(() => {
    window.location.hash = activePath;
  }, [activePath]);

  const activeDoc = DOCS.find((doc) => doc.id === activePath) || DOCS[0];

  return (
    <div className="flex h-screen w-full bg-[#0F0F0F] text-zinc-100 overflow-hidden">
      {/* Sidebar */}
      <Sidebar currentPath={activePath} onNavigate={setActivePath} />

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Header */}
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
            {/* <div className="relative group hidden md:block">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500 group-focus-within:text-purple-400 transition-colors" size={16} />
              <input
                type="text"
                placeholder="Search documentation..."
                className="bg-zinc-900 border border-zinc-800 rounded-full py-1.5 pl-10 pr-4 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-purple-600/20 focus:border-purple-600 transition-all"
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-bold text-zinc-600 border border-zinc-800 px-1 rounded">
                ⌘K
              </div>
            </div> */}
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

        {/* Content Area */}
        <main className="flex-1 overflow-y-auto relative">
          {activeDoc.type === "markdown" ? (
            <div className="max-w-4xl mx-auto px-8 py-12 animate-in fade-in slide-in-from-bottom-2 duration-500">
              <div className="mb-8">
                <span className="text-xs font-bold text-purple-500 uppercase tracking-widest px-2 py-1 bg-purple-500/10 rounded mb-4 inline-block">
                  Guide
                </span>
                <h1 className="text-4xl font-extrabold tracking-tight text-white mb-4">
                  {activeDoc.title}
                </h1>
                <p className="text-zinc-400 text-lg">
                  Learn about the core architecture and development workflow for
                  the {activeDoc.title}.
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
          ) : (
            <div className="h-full w-full animate-in fade-in duration-300">
              <ScalarDocs
                key={activeDoc.id}
                specUrl={activeDoc.specUrl || ""}
              />
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

export default App;
