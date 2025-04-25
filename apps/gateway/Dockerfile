FROM node:22-alpine AS base

FROM base AS deps
WORKDIR /workspace

COPY *.json yarn.lock *.mjs ./
COPY ./apps/gateway ./apps/gateway

RUN yarn install --frozen-lockfile

FROM deps AS builder
RUN npx nx build gateway --configuration=production
RUN rm -rf node_modules
RUN yarn install --production --frozen-lockfile

FROM deps AS dev
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=development
ENV NX_DAEMON=false

EXPOSE 3000

CMD ["npx", "nx", "run", "gateway:dev"]

FROM base AS start
WORKDIR /app

COPY --from=builder /workspace/dist/apps/gateway ./dist/apps/gateway
COPY --from=builder /workspace/node_modules ./node_modules

CMD ["node", "dist/apps/gateway/main.js"]