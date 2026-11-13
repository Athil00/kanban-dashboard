# Stage 1: Build the React application

FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Serve the production build using unprivileged Nginx

FROM nginxinc/nginx-unprivileged:alpine

COPY --chown=101:101 --from=build /app/dist/ /usr/share/nginx/html/

USER 101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
