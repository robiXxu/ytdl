FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir -U yt-dlp \
    && rm -rf /var/lib/apt/lists/*

RUN python3 - <<'PY'
from pathlib import Path

p = Path("/app/app.js")
s = p.read_text()

old = "const youtubedl = require('youtube-dl');"

new = r"""
const { execFile } = require('child_process');

const youtubedl = {
    exec: function(url, args, callback) {
        execFile('yt-dlp', [...args, url], callback);
    }
};
"""

if old not in s:
    raise Exception("youtube-dl import not found")

p.write_text(s.replace(old, new))
PY

RUN yt-dlp --version
