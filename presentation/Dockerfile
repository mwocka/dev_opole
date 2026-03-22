FROM node:20-alpine

WORKDIR /app
COPY package*.json ./

RUN npm ci --production=false

COPY . .

EXPOSE 5173
CMD ["npx", "vite", "--host", "0.0.0.0"]
