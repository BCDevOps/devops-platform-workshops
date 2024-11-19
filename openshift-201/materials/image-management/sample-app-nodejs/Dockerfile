# Use the official Node.js image from the Docker Hub
FROM node:16-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install the app dependencies
RUN npm install

# Copy the rest of the app's source code
COPY . .

# Expose the port the app will run on
EXPOSE 8080

# Start the Node.js app
CMD ["node", "index.js"]
