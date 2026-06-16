// Quick test for grammar/check endpoint
const body = JSON.stringify({ text: "我不想吃饭" });
fetch("http://localhost:3001/grammar/check", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: body,
})
  .then((r) => r.json())
  .then((data) => console.log("RESULT:", JSON.stringify(data, null, 2)))
  .catch((e) => console.error("ERROR:", e));
