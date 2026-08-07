FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir yt-dlp \
    && mkdir -p /app/appdata/bin \
    && ln -sf /usr/local/bin/yt-dlp /app/appdata/bin/yt-dlp \
    && rm -rf /var/lib/apt/lists/*

RUN python3 - <<'PY'
from pathlib import Path

p = Path("/app/app.js")
s = p.read_text()

old = "const youtubedl = require('youtube-dl');"

new = """const { execFile } = require('child_process');

const youtubedl = {
    exec: function(url, args, options, callback) {
        execFile(
            '/app/appdata/bin/yt-dlp',
            [...args, url],
            options,
            callback
        );
    }
};"""

if old not in s:
    raise Exception("old youtube-dl import not found")

p.write_text(s.replace(old, new))
PY

RUN yt-dlp --version
