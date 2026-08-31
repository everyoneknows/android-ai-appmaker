#!/usr/bin/env python3
import importlib.util
import os
import tempfile
import threading
import urllib.error
import urllib.request
from pathlib import Path

with tempfile.TemporaryDirectory() as home:
    os.environ["HOME"] = home
    spec = importlib.util.spec_from_file_location("appmaker_server", Path(__file__).parents[1] / "web/server.py")
    server = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(server)
    httpd = server.ThreadingHTTPServer(("127.0.0.1", server.PORT), server.Handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()

    def request(method, path, headers=None, data=b""):
        req = urllib.request.Request(
            f"http://127.0.0.1:{server.PORT}{path}", method=method,
            headers=headers or {}, data=data)
        try:
            with urllib.request.urlopen(req, timeout=3) as response:
                return response.status, response.read()
        except urllib.error.HTTPError as error:
            return error.code, error.read()

    status, body = request("GET", "/api/status", {"Origin": "http://127.0.0.1:8765"})
    assert status == 200
    csrf = __import__("json").loads(body)["csrf"]
    common = {"Origin": "http://127.0.0.1:8765", "Content-Type": "application/json", "X-CSRF-Token": csrf}
    assert request("GET", "/install")[0] == 404
    assert request("POST", "/install", common)[0] == 404
    apk = Path(home) / "android-ai-appmaker/out/latest/app.apk"
    apk.parent.mkdir(parents=True)
    apk.write_bytes(b"apk")
    status, body = request("GET", "/apk")
    assert status == 200
    assert body == b"apk"
    # APK distribution is a fixed file response, never a user-controlled path.
    assert request("GET", "/apk?path=../../etc/passwd")[0] == 404
    httpd.shutdown()
    thread.join(timeout=3)
print("web security integration checks passed")
