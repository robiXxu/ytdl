FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir -U yt-dlp \
    && rm -rf /var/lib/apt/lists/*

# Replace youtube-dl binary with yt-dlp wrapper
RUN rm -f /app/node_modules/youtube-dl/bin/youtube-dl \
    && ln -s /usr/local/bin/yt-dlp /app/node_modules/youtube-dl/bin/youtube-dl

# Verify installation
RUN yt-dlp --version

