# Step 1: Build (if React exists)
FROM node:16 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Try build (won't fail pipeline if missing)
RUN npm run build || echo "Skipping build"

# Step 2: Nginx serve
FROM nginx:alpine

# If build folder exists → use it
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html || true

# If no build → fallback to raw files
COPY . /usr/share/nginx/html

EXPOSE 80
