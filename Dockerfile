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
        args.concat(url),
        options,
        (err, stdout, stderr) => {
            if (err) {
                callback(err, stdout);
                return;
            }

            try {
                const json = JSON.parse(stdout);

                // youtube-dl npm module compatibility
                if (json.format_id === undefined && json.formats) {
                    json.format_id = json.format_id || json.formats
                        .map(f => f.format_id)
                        .filter(Boolean)
                        .join('+');
                }

                callback(null, JSON.stringify(json));
            } catch {
                callback(null, stdout);
            }
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

# Replace old youtube-dl npm module usage
RUN sed -i "s/require('youtube-dl')/require('.\\/yt-dlp-wrapper')/g" \
    /app/downloader.js \
    /app/subscriptions.js

# Verify yt-dlp exists
RUN yt-dlp --version

