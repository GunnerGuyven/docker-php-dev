import { Application, Router } from "@oak/oak";

const app = new Application();
const router = new Router();

// Simple health check
router.get("/health", (ctx) => {
  ctx.response.body = {
    status: "ok",
    service: "deno-oak",
    timestamp: new Date().toISOString(),
  };
  ctx.response.type = "application/json";
});

// Main hello
router.get("/", (ctx) => {
  ctx.response.body = {
    message: "Hello from Deno + Oak!",
    runtime: "Deno " + Deno.version.deno,
    endpoints: ["/", "/health", "/echo", "/test-php"],
    note: "Try /test-php to exercise the internal PHP service call.",
  };
});

// Echo endpoint for testing
router.get("/echo", (ctx) => {
  const params = Object.fromEntries(ctx.request.url.searchParams);
  ctx.response.body = {
    method: ctx.request.method,
    url: ctx.request.url.toString(),
    headers: Object.fromEntries(ctx.request.headers.entries()),
    query: params,
  };
  ctx.response.type = "application/json";
});

// Test endpoint: calls the internal PHP service (on 127.0.0.1:9001)
// This is the implemented integration test: Deno calls a simple PHP service
// that responds with a static JSON payload. (Works with both FrankenPHP and nginx.Dockerfile variants.)

router.get("/test-php", async (ctx) => {
  try {
    const phpRes = await fetch("http://127.0.0.1:9001/test.php");
    if (!phpRes.ok) {
      throw new Error(`PHP service returned HTTP ${phpRes.status}`);
    }
    const phpData = await phpRes.json();

    ctx.response.body = {
      status: "ok",
      called_from: "deno-oak",
      php_service: phpData,
      note: "This route proves the Deno application successfully called the internal PHP service.",
    };
    ctx.response.type = "application/json";
  } catch (err) {
    ctx.response.status = 502;
    ctx.response.body = {
      status: "error",
      message: "Failed to reach internal PHP service",
      error: String(err),
      hint: "Ensure the internal PHP service is running on 127.0.0.1:9001 (managed by Supervisor). (Works with both variants.)",
    };
    ctx.response.type = "application/json";
  }
});

// Fallback
app.use(async (ctx, next) => {
  await next();
  if (ctx.response.status === 404) {
    ctx.response.body = { error: "Not found", path: ctx.request.url.pathname };
    ctx.response.status = 404;
    ctx.response.type = "application/json";
  }
});

app.use(router.routes());
app.use(router.allowedMethods());

const port = parseInt(Deno.env.get("PORT") || "8000");
console.log(`Deno Oak server listening on http://0.0.0.0:${port}`);
await app.listen({ port, hostname: "0.0.0.0" });
