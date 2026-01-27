# Stage 1: build Angular app
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy sources and build
COPY . .
RUN npm run build -- --configuration=production

# Stage 2: serve with nginx
FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html

# Custom nginx config (expects file alongside Dockerfile)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app
COPY --from=builder /app/dist/order-app-frontend ./

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]