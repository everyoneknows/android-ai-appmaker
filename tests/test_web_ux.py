#!/usr/bin/env python3
import importlib.util
import json
import os
import stat
import tempfile
import threading
import urllib.request
from pathlib import Path

root = Path(__file__).parents[1]
with tempfile.TemporaryDirectory() as home, tempfile.TemporaryDirectory() as tools:
    os.environ['HOME'] = home
    codex = Path(tools) / 'codex'
    codex.write_text("#!/bin/sh\nexit 0\n")
    codex.chmod(codex.stat().st_mode | stat.S_IXUSR)
    os.environ['PATH'] = tools + os.pathsep + os.environ.get('PATH', '')
    spec = importlib.util.spec_from_file_location('appmaker_server_ux', root / 'web/server.py')
    server = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(server)
    httpd = server.ThreadingHTTPServer(('127.0.0.1', server.PORT), server.Handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()

    def get(path):
        with urllib.request.urlopen(f'http://127.0.0.1:{server.PORT}{path}', timeout=3) as response:
            return response.status, response.headers, response.read()

    apk = Path(home) / 'android-ai-appmaker/out/latest/app.apk'
    apk.parent.mkdir(parents=True)
    apk.write_bytes(b'latest-apk')
    status, headers, body = get('/apk')
    assert status == 200 and body == b'latest-apk'
    assert headers['Content-Type'].startswith('application/vnd.android.package-archive')
    assert headers['Content-Disposition'] == 'attachment; filename="calculator.apk"'

    status, _, body = get('/api/status')
    data = json.loads(body)
    assert status == 200 and data['ai'] == 'available'
    assert data['reason'] == ''

    original_run = server.subprocess.run
    server.subprocess.run = lambda *args, **kwargs: type('Result', (), {'returncode': 1})()
    assert server.ai_status() == ('login_required', '')
    server.subprocess.run = original_run

    os.environ['APPMAKER_AI'] = 'none'
    assert server.ai_status() == ('unavailable', 'disabled')
    del os.environ['APPMAKER_AI']
    os.environ['PATH'] = '/nonexistent'
    assert server.ai_status() == ('unavailable', 'not_installed')
    httpd.shutdown()
print('web UX regression checks passed: APK headers and AI states')
