FROM node:22-alpine AS base

ENV HOST=0.0.0.0
ENV PORT=3000

WORKDIR /workspace

FROM base AS dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


FROM dependencies AS watch
COPY . .

EXPOSE 3000
CMD ["npx", "nx", "serve", "gateway"]
