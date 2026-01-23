import React from "react";
import { Outlet } from "react-router-dom";

const ApiRefLayout: React.FC = () => {
  return (
    <div className="h-screen w-full bg-[#0F0F0F] text-zinc-100">
      <Outlet />
    </div>
  );
};

export default ApiRefLayout;