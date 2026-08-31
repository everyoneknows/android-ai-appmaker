#!/usr/bin/env python3
import json, logging, os, secrets, shutil, subprocess, threading, traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent; PORT=8765; TOKEN=secrets.token_urlsafe(32); LOCK=threading.Lock(); MAX_BODY=64*1024; MAX_PROMPT=4000
APK_PATH=Path.home()/'android-ai-appmaker/out/latest/app.apk'
LOG_PATH=Path.home()/'.android-ai-appmaker'/'web.log'
LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
logging.basicConfig(filename=LOG_PATH, level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger=logging.getLogger(__name__)
def ai_status():
 if os.environ.get('APPMAKER_AI')=='none': return 'unavailable', 'disabled'
 if not shutil.which('codex'): return 'unavailable', 'not_installed'
 try:
  return ('available', '') if subprocess.run(['codex','login','status'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=10).returncode==0 else ('login_required', '')
 except (OSError, subprocess.TimeoutExpired): return 'unavailable', 'not_detected'
class Handler(BaseHTTPRequestHandler):
 def log_message(self,*args): pass
 def host_ok(self): return self.headers.get('Host','') in {f'127.0.0.1:{PORT}',f'localhost:{PORT}'}
 def origin_ok(self): return self.headers.get('Origin','') in {f'http://127.0.0.1:{PORT}',f'http://localhost:{PORT}'}
 def send_data(self,c,t,d): self.send_response(c); self.send_header('Content-Type',t); self.send_header('Content-Length',str(len(d))); self.end_headers(); self.wfile.write(d)
 def send_json(self,c,o): self.send_data(c,'application/json; charset=utf-8',json.dumps(o,ensure_ascii=False).encode())
 def do_GET(self):
  if not self.host_ok(): self.send_error(400,'invalid host'); return
  if self.path=='/health': self.send_data(200,'text/plain; charset=utf-8',b'ok\n')
  elif self.path=='/': self.send_data(200,'text/html; charset=utf-8',(ROOT/'web/index.html').read_bytes())
  elif self.path=='/api/status':
   ai, reason=ai_status(); self.send_json(200,{'ai':ai,'reason':reason,'csrf':TOKEN,'apk':str(APK_PATH) if APK_PATH.is_file() else ''})
  elif self.path=='/apk':
   if not APK_PATH.is_file(): self.send_error(404,'APKがまだありません'); return
   data=APK_PATH.read_bytes(); self.send_response(200)
   self.send_header('Content-Type','application/vnd.android.package-archive')
   self.send_header('Content-Disposition','attachment; filename="calculator.apk"')
   self.send_header('Content-Length',str(len(data))); self.end_headers(); self.wfile.write(data)
  else: self.send_error(404)
 def do_POST(self):
  if not self.host_ok() or not self.origin_ok(): self.send_json(403,{'message':'HostまたはOriginを拒否しました'}); return
  if self.path != '/build': self.send_error(404); return
  if self.headers.get('Content-Type','').split(';',1)[0].strip()!='application/json': self.send_json(415,{'message':'application/jsonのみ受け付けます'}); return
  if self.headers.get('X-CSRF-Token')!=TOKEN: self.send_json(403,{'message':'CSRF tokenが不正です'}); return
  try: n=int(self.headers.get('Content-Length','-1'))
  except ValueError: n=-1
  if n<0 or n>MAX_BODY: self.send_json(413,{'message':'リクエストが大きすぎます'}); return
  if not LOCK.acquire(False): self.send_json(409,{'message':'別のビルドが実行中です'}); return
  try:
   body=json.loads(self.rfile.read(n)); prompt=str(body.get('prompt','')).strip()
   if not prompt or len(prompt)>MAX_PROMPT: raise ValueError('仕様は1〜4000文字で入力してください')
   subprocess.run([str(ROOT/'bin/appmaker'),prompt],check=True,timeout=1800,cwd=ROOT)
   if not APK_PATH.is_file(): raise RuntimeError('APKが生成されませんでした')
   self.send_json(200,{'message':'APKの生成と署名が完了しました。','apk':True})
  except subprocess.TimeoutExpired: self.send_json(504,{'message':'ビルドが時間内に完了しませんでした','apk':False})
  except Exception:
   logger.exception('build failed')
   self.send_json(500,{'message':'ビルドに失敗しました。詳細はTermux内のローカルログを確認してください。','apk':False})
  finally: LOCK.release()
if __name__=='__main__': ThreadingHTTPServer(('127.0.0.1',PORT),Handler).serve_forever()
