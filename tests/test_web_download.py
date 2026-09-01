#!/usr/bin/env python3
import importlib.util
import os
import subprocess
import tempfile
import threading
import urllib.request
from pathlib import Path

root = Path(__file__).parents[1]
html = (root / "web/index.html").read_text()
script = html.split("<script>\n", 1)[1].split("\n</script>", 1)[0]

node_test = r'''
const vm = require('vm');
const elements = {
  '#onboarding': {style: {}},
  '#completion': {style: {}},
  '#download': {},
  '#download-help': {hidden: true},
  '#installed': {},
  '#step2': {hidden: true, scrollIntoView() {}},
  '#launched': {},
};
const context = {
  URLSearchParams,
  location: {search: ''},
  document: {querySelector(selector) { return elements[selector]; }},
};
vm.runInNewContext(process.argv[1], context);
const result = elements['#download'].onclick();
if (result !== undefined) throw new Error('download handler returned a value');
if (elements['#download-help'].hidden !== false) throw new Error('download help stayed hidden');
'''
subprocess.run(["node", "-e", node_test, script], check=True)

with tempfile.TemporaryDirectory() as home:
    os.environ["HOME"] = home
    apk = Path(home) / "android-ai-appmaker/out/latest/app.apk"
    apk.parent.mkdir(parents=True)
    apk.write_bytes(b"download-regression-apk")

    spec = importlib.util.spec_from_file_location("appmaker_server_download", root / "web/server.py")
    server = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(server)
    httpd = server.ThreadingHTTPServer(("127.0.0.1", server.PORT), server.Handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{server.PORT}/apk", timeout=3) as response:
            assert response.status == 200
            assert response.read() == b"download-regression-apk"
    finally:
        httpd.shutdown()
        thread.join(timeout=3)

print("download regression checks passed: click keeps /apk navigation and shows help")
