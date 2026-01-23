
import React from "react";
import {
  Layout,
  Server,
  Network,
  FileText,
  ChevronRight,
} from "lucide-react";
import { Link, useLocation } from "react-router-dom";
import { DOCS } from "../constants.tsx";

const Sidebar: React.FC = () => {
  const location = useLocation();
  const activeId = location.pathname.split("/").pop();

  const groups = Array.from(new Set(DOCS.map((doc) => doc.group)));

  const getIcon = (group: string) => {
    switch (group) {
      case "General":
        return <FileText size={18} />;
      case "Microservices":
        return <Server size={18} />;
      case "Gateway":
        return <Network size={18} />;
      default:
        return <Layout size={18} />;
    }
  };

  return (
    <div className="w-64 h-full border-r border-zinc-800 bg-[#0F0F0F] flex flex-col shrink-0 overflow-y-auto">
      <div className="p-6 border-b border-zinc-800">
        <div className="flex items-center gap-2 mb-1">
          <div className="w-8 h-8 bg-purple-600 rounded-lg flex items-center justify-center font-bold text-white">
            DP
          </div>
          <span className="font-bold text-xl tracking-tight">DevDocs</span>
        </div>
        <p className="text-xs text-zinc-500 font-medium">v1.2.0 Stable</p>
      </div>

      <nav className="flex-1 p-4 space-y-8">
        {groups.map((group) => (
          <div key={group} className="space-y-2">
            <h3 className="text-xs font-semibold text-zinc-500 uppercase tracking-widest px-2 flex items-center gap-2">
              {getIcon(group)}
              {group}
            </h3>
            <div className="space-y-1">
              {DOCS.filter((doc) => doc.group === group).map((doc) => (
                <Link
                  key={doc.id}
                  to={
                    doc.type === "api"
                      ? `/reference/${doc.id}`
                      : `/docs/${doc.id}`
                  }
                  className={`w-full flex items-center justify-between px-3 py-2 text-sm font-medium rounded-md transition-all duration-200 group ${
                    activeId === doc.id
                      ? "bg-purple-600/10 text-purple-400 border border-purple-600/20"
                      : "text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900 border border-transparent"
                  }`}
                >
                  <span className="flex items-center gap-2">
                    {doc.type === "api" ? (
                      <span className="text-[10px] bg-zinc-800 px-1.5 py-0.5 rounded text-zinc-500 font-mono">
                        API
                      </span>
                    ) : (
                      <span className="text-[10px] bg-zinc-800 px-1.5 py-0.5 rounded text-zinc-500 font-mono">
                        DOC
                      </span>
                    )}
                    {doc.title}
                  </span>
                  <ChevronRight
                    size={14}
                    className={`transition-transform duration-200 ${
                      activeId === doc.id
                        ? "translate-x-0 opacity-100"
                        : "-translate-x-2 opacity-0 group-hover:translate-x-0 group-hover:opacity-100"
                    }`}
                  />
                </Link>
              ))}
            </div>
          </div>
        ))}
      </nav>

      <div className="p-4 border-t border-zinc-800">
        <div className="bg-zinc-900/50 p-3 rounded-lg border border-zinc-800">
          <p className="text-[10px] text-zinc-500 mb-1 font-mono uppercase">
            System Status
          </p>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></div>
            <span className="text-xs font-medium text-zinc-300">
              All Systems Operational
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;

