FROM node:22-alpine AS base

FROM base AS deps
WORKDIR /workspace

COPY *.json yarn.lock *.mjs ./
COPY ./apps/s3-lambda ./apps/s3-lambda

RUN yarn install --frozen-lockfile

FROM deps AS dev
ENV NODE_ENV=development
ENV NX_DAEMON=false

CMD ["npx", "nx", "run", "s3-lambda:dev"]
