FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir -U yt-dlp \
    && rm -rf /var/lib/apt/lists/*

RUN cat > /app/node_modules/youtube-dl/bin/youtube-dl <<'EOF'
#!/bin/sh
exec /usr/local/bin/yt-dlp "$@"
EOF

RUN chmod +x /app/node_modules/youtube-dl/bin/youtube-dl
