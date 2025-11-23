# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
# Install production dependencies only
RUN npm ci --omit=dev

# Copy source code
COPY . .

# Buat folder uploads dan database
RUN mkdir -p uploads && touch academic_dashboard.db

# Expose port backend
EXPOSE 5000

# Jalankan server
CMD ["npm", "start"]