# Stage 1: Build
FROM node:18 as builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
COPY tsconfig.json .
RUN npm run build

# Stage 2: Runtime
FROM node:18-slim
WORKDIR /usr/app
COPY --from=builder /usr/src/app/dist ./dist
COPY package*.json ./
RUN npm install --only=production
EXPOSE 3000
CMD ["node", "dist/main"]
