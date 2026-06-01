FROM node:20-slim

# Install Typst (architecture-aware)
RUN apt-get update && apt-get install -y wget xz-utils && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
      URL="https://github.com/typst/typst/releases/download/v0.14.2/typst-x86_64-unknown-linux-musl.tar.xz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      URL="https://github.com/typst/typst/releases/download/v0.14.2/typst-aarch64-unknown-linux-musl.tar.xz"; \
    else \
      echo "Unsupported arch: $ARCH" && exit 1; \
    fi && \
    wget -q "$URL" && \
    tar -xf "$(basename $URL)" && \
    mv typst-*/typst /usr/local/bin/ && \
    rm -rf typst-*

WORKDIR /app

# Copy assets
COPY fonts/ ./fonts/
COPY template.typ ./template.typ
COPY server.js ./server.js
COPY package.json ./package.json

RUN npm install

EXPOSE 3002

CMD ["node", "server.js"]
