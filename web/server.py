#!/usr/bin/env python3
import json, os, subprocess, urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HTML = (ROOT / 'web' / 'index.html').read_bytes()
APK = Path.home() / 'android-ai-appmaker' / 'out' / 'app.apk'

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_): pass
    def do_GET(self):
        if self.path == '/':
            self.send(200, 'text/html; charset=utf-8', HTML)
        elif self.path == '/install' and APK.is_file():
            try:
                subprocess.Popen(['termux-open', str(APK)])
                self.send(200, 'text/plain; charset=utf-8', 'APKを開きました。画面の指示に従ってインストールしてください。'.encode())
            except OSError:
                self.send(500, 'text/plain; charset=utf-8', 'termux-openを実行できません。APKをタップしてください。'.encode())
        else: self.send(404, 'text/plain', b'Not found')
    def do_POST(self):
        if self.path != '/build': self.send(404, 'text/plain', b'Not found'); return
        try:
            n = int(self.headers.get('Content-Length', '0'))
            prompt = json.loads(self.rfile.read(n)).get('prompt', '').strip()
            if not prompt: raise ValueError('仕様が空です')
            subprocess.run([str(ROOT / 'bin/appmaker'), prompt], check=True, timeout=1800)
            self.send_json(200, {'message':'APKの生成と署名が完了しました。', 'apk':True})
        except Exception as e:
            self.send_json(500, {'message':'ビルドに失敗しました: ' + str(e), 'apk':False})
    def send(self, code, kind, data):
        self.send_response(code); self.send_header('Content-Type', kind); self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
    def send_json(self, code, obj): self.send(code, 'application/json; charset=utf-8', json.dumps(obj, ensure_ascii=False).encode())

if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', int(os.environ.get('APPMAKER_PORT', '8765'))), Handler).serve_forever()
