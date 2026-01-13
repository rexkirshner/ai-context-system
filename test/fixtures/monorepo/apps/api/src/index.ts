import express from "express";
import { formatDate } from "@monorepo/utils";

const app = express();
const port = process.env.PORT || 3001;

app.get("/", (req, res) => {
  res.json({ message: "Hello from API", timestamp: formatDate(new Date()) });
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
