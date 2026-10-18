FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm install -g npm@12.2.0
RUN npm install -g netlify-cli@20.1.1 node-jq
RUN npm install -g serve