FROM node:22-bookworm-slim

WORKDIR /app

ENV HUSKY=0
ENV CI=true
ENV WRANGLER_SEND_METRICS=false
ENV RUNNING_IN_DOCKER=true

RUN corepack enable && \
    corepack prepare pnpm@9.15.9 --activate

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl && \
    rm -rf /var/lib/apt/lists/*

COPY package.json pnpm-lock.yaml* ./

RUN pnpm fetch

COPY . .

RUN npm pkg delete scripts.prepare && \
    pnpm install --frozen-lockfile --prod=false

RUN NODE_OPTIONS=--max-old-space-size=4096 pnpm run build

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=5173

RUN mkdir -p /root/.config/.wrangler && \
    echo '{"enabled":false}' > /root/.config/.wrangler/metrics.json

EXPOSE 5173

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5 \
  CMD curl -fsS http://localhost:5173/ || exit 1

CMD ["pnpm","run","dockerstart"]
