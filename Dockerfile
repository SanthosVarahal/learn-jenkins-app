FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN apt update && apt install -y jq
RUN npm install -g  netlify-cli serve
