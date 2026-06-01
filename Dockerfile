FROM node:20-slim

# Install Typst
RUN apt-get update && apt-get install -y wget xz-utils && \
    wget -q https://github.com/typst/typst/releases/download/v0.14.0/typst-x86_64-unknown-linux-musl.txz && \
    tar -xf typst-x86_64-unknown-linux-musl.txz && \
    mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/ && \
    rm -rf typst-x86_64-unknown-linux-musl*

WORKDIR /app

# Copy assets
COPY fonts/ ./fonts/
COPY template.typ ./template.typ
COPY server.js ./server.js
COPY package.json ./package.json

RUN npm install

EXPOSE 3002

CMD ["node", "server.js"]
