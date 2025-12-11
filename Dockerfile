FROM node:18-alpine

WORKDIR /app

# Copy package metadata and install dependencies
COPY package.json ./
RUN npm install --production

# Copy app source
COPY . .

EXPOSE 80

CMD ["node", "index.js"]
