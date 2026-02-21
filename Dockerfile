# -----------------------------------------------------------------------------
# Stage 1: Build React frontend
# -----------------------------------------------------------------------------
FROM node:20-alpine AS frontend-builder

WORKDIR /app

# Install dependencies (use same lockfile as repo; ignore-scripts avoids prepare/npm start)
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Copy frontend source and build
COPY public/ public/
COPY src/ src/
COPY config-overrides.js index.html ./
COPY tailwind.config.js postcss.config.js ./

ENV CI=true
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 2: Production runtime
# -----------------------------------------------------------------------------
FROM node:20-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Install production deps only (server needs them; ignore-scripts avoids prepare/npm start)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

# Copy server code
COPY server/ ./server/

# Copy built frontend to path Express expects (frontend/build)
COPY --from=frontend-builder /app/build ./frontend/build

# Own files
RUN chown -R appuser:appgroup /app

USER appuser

ENV NODE_ENV=production
ENV PORT=3099
EXPOSE 3099

CMD ["node", "server/server.js"]
