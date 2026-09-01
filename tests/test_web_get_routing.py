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
    root = Path(__file__).parents[1]
    spec = importlib.util.spec_from_file_location("appmaker_server_routing", root / "web/server.py")
    server = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(server)
    httpd = server.ThreadingHTTPServer(("127.0.0.1", server.PORT), server.Handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()

    def get(path):
        try:
            with urllib.request.urlopen(
                f"http://127.0.0.1:{server.PORT}{path}", timeout=3
            ) as response:
                return response.status, response.read()
        except urllib.error.HTTPError as error:
            return error.code, error.read()

    status, body = get("/")
    assert status == 200
    assert "次はCodexです！".encode() in body

    status, body = get("/?completed=1")
    assert status == 200
    assert "次はCodexです！".encode() in body

    assert get("/health")[0] == 200
    assert get("/api/status")[0] == 200

    apk = Path(home) / "android-ai-appmaker/out/latest/app.apk"
    apk.parent.mkdir(parents=True)
    apk.write_bytes(b"apk")
    assert get("/apk")[0] == 200

    httpd.shutdown()
    thread.join(timeout=3)

print("GET routing regression checks passed")
