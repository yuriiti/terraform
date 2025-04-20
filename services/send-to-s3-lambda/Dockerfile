FROM node:22-alpine

# Set the working directory
WORKDIR /var/task

# Copy package.json and package-lock.json
COPY ../../package*.json ./
COPY ../../yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY ../../ ./

RUN yarn build

# Command to run the application
CMD ["node", "dist/services/send-to-s3-lambda/index.js"]