const { createReadStream, existsSync, statSync } = require('node:fs');
const { createServer, request } = require('node:http');
const { extname, join, normalize, resolve } = require('node:path');

const root = resolve(__dirname, '..', 'apps', 'admin');
const mobileAssetsRoot = resolve(__dirname, '..', 'apps', 'mobile', 'assets');
const port = Number(process.env.ADMIN_PORT || process.argv[2] || 8080);
const apiPort = Number(process.env.API_PORT || 3001);

const types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

function send(res, status, body, type = 'text/plain; charset=utf-8') {
  res.writeHead(status, {
    'Content-Type': type,
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

function proxyApi(req, res, url) {
  const apiPath = url.pathname.startsWith('/api')
    ? url.pathname.replace(/^\/api/, '') || '/'
    : url.pathname;
  const proxyReq = request(
    {
      hostname: '127.0.0.1',
      port: apiPort,
      path: `${apiPath}${url.search}`,
      method: req.method,
      headers: {
        ...req.headers,
        host: `127.0.0.1:${apiPort}`,
      },
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, {
        ...proxyRes.headers,
        'Cache-Control': 'no-store',
      });
      proxyRes.pipe(res);
    },
  );

  proxyReq.on('error', (error) => {
    send(
      res,
      503,
      JSON.stringify({
        statusCode: 503,
        message: `VNChinese API is not reachable on port ${apiPort}. ${error.message}`,
      }),
      'application/json; charset=utf-8',
    );
  });

  req.pipe(proxyReq);
}

createServer((req, res) => {
  const url = new URL(req.url || '/', 'http://localhost');
  const pathname = decodeURIComponent(url.pathname);
  if (pathname === '/api' || pathname.startsWith('/api/') || pathname.startsWith('/uploads/')) {
    proxyApi(req, res, url);
    return;
  }

  if (pathname.startsWith('/mobile/assets/')) {
    const relativeAsset = pathname.replace(/^\/mobile\/assets\//, '');
    const file = normalize(resolve(join(mobileAssetsRoot, relativeAsset)));
    if (!file.startsWith(mobileAssetsRoot) || !existsSync(file) || !statSync(file).isFile()) {
      send(res, 404, 'Asset not found');
      return;
    }
    res.writeHead(200, {
      'Content-Type': types[extname(file)] || 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    createReadStream(file).pipe(res);
    return;
  }

  const target = pathname === '/' ? '/index.html' : pathname;
  const file = normalize(resolve(join(root, target)));

  if (!file.startsWith(root) || !existsSync(file) || !statSync(file).isFile()) {
    send(res, 404, 'Not found');
    return;
  }

  res.writeHead(200, {
    'Content-Type': types[extname(file)] || 'application/octet-stream',
    'Cache-Control': 'no-store',
  });
  createReadStream(file).pipe(res);
}).listen(port, '0.0.0.0', () => {
  console.log(`VNChinese Admin ready: http://127.0.0.1:${port}`);
});
