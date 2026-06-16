// Test key with generativelanguage endpoint instead of aiplatform
const apiKey = "AQ.Ab8RN6JzNEqFiHbFgJxLaLu4SMjcBtgD1UUG2eQBiTv70L2UzQ";
const model = "gemini-2.5-flash";

// Try generativelanguage.googleapis.com with the AQ key
const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

console.log("Testing generativelanguage endpoint with AQ key...");

fetch(url, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    contents: [{ role: "user", parts: [{ text: "说你好" }] }],
    generationConfig: { maxOutputTokens: 100 },
  }),
  signal: AbortSignal.timeout(15000),
})
  .then(async (r) => {
    const body = await r.text();
    console.log("Status:", r.status);
    console.log("Body:", body.slice(0, 800));
  })
  .catch((e) => console.error("ERROR:", e));
