# frontend/Dockerfile

# Tahap 1: Build React App
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Tahap 2: Serve pakai Nginx
FROM nginx:alpine
# Copy hasil build React ke folder Nginx
COPY --from=builder /app/build /usr/share/nginx/html
# Copy konfigurasi Nginx (agar React Router jalan lancar)
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]