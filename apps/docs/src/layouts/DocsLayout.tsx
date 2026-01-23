import React from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "@/components/Sidebar";

const DocsLayout: React.FC = () => {
  return (
    <div className="flex h-screen w-full bg-[#0F0F0F] text-zinc-100 overflow-hidden">
      <Sidebar />
      <Outlet />
    </div>
  );
};

export default DocsLayout;
