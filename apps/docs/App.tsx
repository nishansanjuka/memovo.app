import React from "react";
import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom";
import Redirector from "./src/pages/Redirector";
import DocsLayout from "./src/layouts/DocsLayout";
import DocPage from "./src/pages/DocPage";
import ApiRefLayout from "./src/layouts/ApiRefLayout";
import ApiRefPage from "./src/pages/ApiRefPage";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Redirector />,
  },
  {
    path: "/docs",
    element: <DocsLayout />,
    children: [
      {
        path: ":docId",
        element: <DocPage />,
      },
    ],
  },
  {
    path: "/reference",
    element: <ApiRefLayout />,
    children: [
      {
        path: ":apiId",
        element: <ApiRefPage />,
      },
    ],
  },
]);

const App: React.FC = () => {
  return <RouterProvider router={router} />;
};

export default App;