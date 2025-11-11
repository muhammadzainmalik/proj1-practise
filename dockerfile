# syntax=docker/dockerfile:1

FROM node:20-alpine AS deps
ENV NODE_ENV=production
WORKDIR /app
RUN apk add --no-cache libc6-compat
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev

FROM node:20-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app
# Use the existing 'node' user that comes with the image
# Copy modules and app files; ensure permissions belong to 'node'
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node . .
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ || exit 1
CMD ["node", "server.js"]