FROM tzahi12345/youtubedl-material:latest

USER root

# Install yt-dlp and create a stable binary path
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && pip3 install --no-cache-dir yt-dlp \
    && mkdir -p /app/appdata/bin \
    && ln -sf /usr/local/bin/yt-dlp /app/appdata/bin/yt-dlp \
    && rm -rf /var/lib/apt/lists/*

# Add yt-dlp compatibility wrapper for the old youtube-dl npm API
RUN cat > /app/yt-dlp-wrapper.js <<'EOF'
const { execFile } = require('child_process');

const binary = '/app/appdata/bin/yt-dlp';

function exec(url, args, options, callback) {
    execFile(
        binary,
        [...args, url],
        options,
        callback
    );
}

function getInfo(url, args, callback) {
    execFile(
        binary,
        ['--dump-json', ...args, url],
        { maxBuffer: Infinity },
        callback
    );
}

module.exports = {
    exec,
    getInfo
};
EOF

# Replace old youtube-dl npm module usage
RUN sed -i "s/require('youtube-dl')/require('.\\/yt-dlp-wrapper')/g" \
    /app/downloader.js \
    /app/subscriptions.js

# Verify yt-dlp exists
RUN yt-dlp --version

USER node
