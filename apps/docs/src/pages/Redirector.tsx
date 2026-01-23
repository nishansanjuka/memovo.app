import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { DOCS } from "@/constants";

const Redirector = () => {
  const navigate = useNavigate();
  useEffect(() => {
    const firstDoc = DOCS.find(d => d.type === 'markdown');
    if (firstDoc) {
      navigate(`/docs/${firstDoc.id}`, { replace: true });
    }
  }, [navigate]);

  return null;
};

export default Redirector;
