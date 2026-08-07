FROM tzahi12345/youtubedl-material:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir -U yt-dlp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Remove old npm youtube-dl package
RUN npm uninstall youtube-dl

# Install yt-dlp node wrapper
RUN npm install yt-dlp

RUN yt-dlp --version
