# syntax=docker/dockerfile:1

# 1) Build stage: собираем Vite-приложение
FROM node:20-alpine AS build
WORKDIR /app

# Копируем только манифесты для кеширования зависимостей
COPY package*.json ./

# Устанавливаем зависимости включая dev для сборки
RUN npm ci

# Копируем исходники и собираем
COPY . .
RUN npm run build

# 2) Runtime stage: отдаем статику через Nginx
FROM nginx:1.27-alpine

# Конфиг для SPA с fallback на index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Копируем билд
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

# Простой healthcheck
HEALTHCHECK CMD wget -qO- http://localhost/ >/dev/null || exit 1

