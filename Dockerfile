FROM mcr.microsoft.com/playwright:v1.39.0-jammy

# Install build dependencies required for compiling native node modules (like sharp)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Now run your global npm installs
RUN npm install -g sharp netlify-cli@20.1.1 node-jq serve