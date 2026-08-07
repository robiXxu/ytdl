FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir -U yt-dlp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Patch the hardcoded downloader command
RUN sed -i "s/node_modules\\\\youtube-dl\\\\bin\\\\youtube-dl/node_modules\\\\youtube-dl\\\\bin\\\\yt-dlp/g" /app/app.js \
    && sed -i "s/command: 'youtube-dl'/command: 'yt-dlp'/g" /app/app.js

RUN rm -rf /app/node_modules/youtube-dl \
 && mkdir -p /app/node_modules/youtube-dl/bin \
 && printf '#!/bin/sh\nexec /usr/local/bin/yt-dlp "$@"\n' > /app/node_modules/youtube-dl/bin/youtube-dl \
 && chmod +x /app/node_modules/youtube-dl/bin/youtube-dl

RUN yt-dlp --version
