#!/usr/bin/env python3
import json, os, secrets, shutil, subprocess, threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HTML = (ROOT / 'web' / 'index.html').read_bytes()
PORT = int(os.environ.get('APPMAKER_PORT', '8765'))
CSRF_TOKEN = secrets.token_urlsafe(32)
BUILD_LOCK = threading.Lock()

def codex_state():
    if os.environ.get('APPMAKER_AI', 'auto') == 'none' or not shutil.which('codex'):
        return 'unavailable'
    try:
        result = subprocess.run(['codex', 'login', 'status'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=10)
        return 'available' if result.returncode == 0 else 'login_required'
    except (OSError, subprocess.TimeoutExpired):
        return 'unavailable'

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_): pass
    def allowed_host(self): return self.headers.get('Host', '') in {f'127.0.0.1:{PORT}', f'localhost:{PORT}'}
    def allowed_origin(self): return self.headers.get('Origin', '') in {f'http://127.0.0.1:{PORT}', f'http://localhost:{PORT}'}
    def do_GET(self):
        if not self.allowed_host(): self.send_error(400, 'invalid host'); return
        if self.path == '/': self.send(200, 'text/html; charset=utf-8', HTML)
        elif self.path == '/api/status': self.send_json(200, {'ai': codex_state(), 'csrf': CSRF_TOKEN})
        elif self.path == '/install' and (Path.home() / 'android-ai-appmaker/out/latest/app.apk').is_file():
            try: subprocess.Popen(['termux-open', str(Path.home() / 'android-ai-appmaker/out/latest/app.apk')]); self.send(200, 'text/plain; charset=utf-8', 'APKを開きました。'.encode())
            except OSError: self.send(500, 'text/plain; charset=utf-8', 'APKをタップしてください。'.encode())
        else: self.send(404, 'text/plain', b'Not found')
    def do_POST(self):
        if not self.allowed_host() or not self.allowed_origin(): self.send_json(403, {'message':'HostまたはOriginを拒否しました'}); return
        if self.path != '/build': self.send_error(404); return
        if self.headers.get('Content-Type', '').split(';', 1)[0].strip() != 'application/json': self.send_json(415, {'message':'application/jsonのみ受け付けます'}); return
        if self.headers.get('X-CSRF-Token') != CSRF_TOKEN: self.send_json(403, {'message':'CSRF tokenが不正です'}); return
        if not BUILD_LOCK.acquire(blocking=False): self.send_json(409, {'message':'別のビルドが実行中です'}); return
        try:
            n = int(self.headers.get('Content-Length', '0'))
            if n <= 0 or n > 64 * 1024: raise ValueError('リクエストサイズが不正です')
            body = json.loads(self.rfile.read(n)); prompt = str(body.get('prompt', '')).strip()
            if not prompt: raise ValueError('仕様が空です')
            subprocess.run([str(ROOT / 'bin/appmaker'), prompt], check=True, timeout=1800)
            self.send_json(200, {'message':'APKの生成と署名が完了しました。', 'apk':True})
        except Exception as e: self.send_json(500, {'message':'ビルドに失敗しました: ' + str(e), 'apk':False})
        finally: BUILD_LOCK.release()
    def send(self, code, kind, data):
        self.send_response(code); self.send_header('Content-Type', kind); self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
    def send_json(self, code, obj): self.send(code, 'application/json; charset=utf-8', json.dumps(obj, ensure_ascii=False).encode())

if __name__ == '__main__': ThreadingHTTPServer(('127.0.0.1', PORT), Handler).serve_forever()
