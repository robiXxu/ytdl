FROM tzahi12345/youtubedl-material:latest

USER root

# Install Python pip if missing, then install yt-dlp
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir --upgrade yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify installation
RUN yt-dlp --version

USER node
