FROM node:22-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY ../package*.json ./
COPY ../yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY ./ ./tests
COPY ../jest.config.js ./

# Command to run the application
CMD ["yarn", "test:watch"]