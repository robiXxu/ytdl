FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir yt-dlp \
    && mkdir -p /app/appdata/bin \
    && ln -s /usr/local/bin/yt-dlp /app/appdata/bin/yt-dlp \
    && rm -rf /var/lib/apt/lists/*

RUN yt-dlp --version
