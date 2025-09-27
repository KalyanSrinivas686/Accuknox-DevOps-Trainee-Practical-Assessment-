# Dockerfile (multi-stage, Node.js example)
#############################################################################
# Build stage
#############################################################################
FROM node:18-alpine AS builder
WORKDIR /app
# install build deps
COPY package*.json ./
RUN npm ci --production=false
COPY . .
# build if applicable
RUN if [ -f package.json ] && grep -q "\"build\"" package.json; then npm run build || true; fi

#############################################################################
# Production stage
#############################################################################
FROM node:18-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --chown=appuser:appgroup --from=builder /app /app
USER appuser

# Expose port (adjust if app listens on different port)
EXPOSE 3000

# Default start command (adjust if package.json uses another script)
CMD ["node", "server.js"]
