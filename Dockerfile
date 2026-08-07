FROM tzahi12345/youtubedl-material:latest

USER root

# Install Node.js 20 (required for yt-dlp JS runtime)
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates python3-pip \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && pip3 install --no-cache-dir yt-dlp==2025.01.15 \
 && rm -rf /var/lib/apt/lists/*

# Ensure yt-dlp path exists where app expects it
RUN mkdir -p /app/appdata/bin \
 && ln -sf /usr/local/bin/yt-dlp /app/appdata/bin/yt-dlp

# Replace youtube-dl with wrapper
RUN cat > /app/yt-dlp-wrapper.js <<'EOF'
const { execFile } = require('child_process');

const binary = '/app/appdata/bin/yt-dlp';

function exec(url, args, options, callback) {
    execFile(
        binary,
        ['--js-runtimes', 'node', ...args, url],
        options,
        (err, stdout, stderr) => {
            if (err) return callback(err, stdout);
            callback(null, stdout);
        }
    );
}

function getInfo(url, args, callback) {
    exec(url, ['-j', ...args], { maxBuffer: 1024 * 1024 * 50 }, callback);
}

module.exports = { exec, getInfo };
EOF

# Patch original app to use wrapper
RUN sed -i "s/require('youtube-dl')/require('.\\/yt-dlp-wrapper')/g" \
    /app/downloader.js \
    /app/subscriptions.js


# Verify runtime
RUN node -v && yt-dlp --version
