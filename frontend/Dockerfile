# Stage 1: Build Angular app
FROM node:20-alpine AS builder

WORKDIR /app

# Copie package.json et installe les dépendances
COPY package*.json ./
RUN npm ci

# Copie le code source
COPY . .

# Build l'application
RUN npm run build

# Stage 2: Serve avec nginx
FROM nginx:alpine

# Copie les fichiers de configuration nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copie l'application buildée
COPY --from=builder /app/dist/order-app-frontend/browser /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
