import ScalarDocs from "./components/ScalarDocs";

function App() {
  return (
    <>
      <ScalarDocs openApiUrl="http://localhost:3000/api-docs-json" />
    </>
  );
}

export default App;
