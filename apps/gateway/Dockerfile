FROM node:22-alpine

WORKDIR /workspace

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=development
ENV NX_DAEMON=false

EXPOSE 3000

CMD ["npx", "nx", "run", "gateway:dev"]
