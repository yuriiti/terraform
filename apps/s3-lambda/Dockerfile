FROM node:22-alpine

WORKDIR /workspace

RUN npm install -g nx nodemon

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

# RUN nx run s3-lambda:package-local

#  "cd dist/apps/s3-lambda && zip -r s3-lambda.zip ."

# RUN chmod +x ./apps/s3-lambda/docker-entrypoint.sh
# ENTRYPOINT ["./apps/s3-lambda/docker-entrypoint.sh"]

CMD ["npx", "nx", "serve", "s3-lambda"]

# ENTRYPOINT ['tail', '-f', '/dev/null']