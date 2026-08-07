FROM tzahi12345/youtubedl-material:latest

USER root

# Install yt-dlp + Deno
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-pip curl ca-certificates \
 && pip3 install --no-cache-dir yt-dlp \
 && curl -fsSL https://deno.land/install.sh | sh \
 && ln -s /root/.deno/bin/deno /usr/local/bin/deno \
 && mkdir -p /app/appdata/bin \
 && ln -sf /usr/local/bin/yt-dlp /app/appdata/bin/yt-dlp \
 && rm -rf /var/lib/apt/lists/*

# Wrapper WITHOUT js-runtimes flag
RUN cat > /app/yt-dlp-wrapper.js <<'EOF'
const { execFile } = require('child_process');

const binary = '/app/appdata/bin/yt-dlp';

function exec(url, args, options, callback) {
    execFile(
        binary,
        [...args, url],
        options,
        (err, stdout, stderr) => {
            if (err) {
                callback(err, stdout);
                return;
            }

            callback(null, stdout);
        }
    );
}

function getInfo(url, args, callback) {
    exec(url, ['-j', ...args], { maxBuffer: Infinity }, callback);
}

module.exports = {
    exec,
    getInfo
};
EOF

# Replace youtube-dl usage
RUN sed -i "s/require('youtube-dl')/require('.\\/yt-dlp-wrapper')/g" \
    /app/downloader.js \
    /app/subscriptions.js

# Verify
RUN yt-dlp --version && deno --version
