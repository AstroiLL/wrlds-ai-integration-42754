# WRLDS / AstroiLL — фронтенд (Vite + React + TS)

Ниже — краткая инструкция: как скачать проект, собрать и запустить локально, как запустить в Docker с live-reload (dev-профиль) и как поднять продакшен. В конце — как сохранить готовый продакшен-образ для запуска на другом компьютере без пересборки.

## Скачивание из GitHub

```bash
# Клонирование репозитория
git clone <YOUR_GITHUB_URL>
cd <PROJECT_DIR>
```

Замените `<YOUR_GITHUB_URL>` и `<PROJECT_DIR>` на реальные значения.

## Локальная сборка без Docker

Требуется Node.js 20+ и npm.

```bash
# Установка зависимостей
npm ci

# Запуск dev-сервера (Vite, HMR)
npm run dev
# По умолчанию откроется http://localhost:5173

# Продакшен-сборка
npm run build

# Локальный предпросмотр собранного билда
npm run preview
# По умолчанию http://localhost:4173
```

## Запуск в Docker (dev, live-reload)

Для разработки добавлен отдельный профиль `dev`, запускающий Vite с HMR внутри контейнера и монтирующий исходники:

```bash
# Запуск профиля разработки
docker compose --profile dev up web-dev
# Откройте http://localhost:5173
```

Особенности dev-профиля:
- Монтирует исходники в контейнер (`.:/app`), изменения видны сразу
- Использует Vite dev server с `--host 0.0.0.0 --port 5173`
- Переменные окружения настроены для корректного HMR в Docker

## Запуск в Docker (production)

Продакшен-режим собирает проект и раздаёт статику через Nginx:

```bash
# Сборка образа и запуск в фоне
docker compose up --build -d

# Откройте http://localhost:8080
```

Под капотом используется многостадийный образ: Node (сборка `dist`) → Nginx (раздача `dist`), с fallback на `index.html` для SPA.

## Сохранение готового продакшен-образа локально (перенос без сборки)

Хотите перенести готовый образ на другой компьютер без повторной сборки? Сделайте так:

```bash
# 1) Соберите продакшен-образ локально
docker compose build web

# 2) (Опционально) Явно задайте читаемый тег
# По умолчанию Compose именует образ как <folder>-web:latest
# Зададим удобный тег:
docker tag $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '-web:latest$' | head -n1) astroill-site:prod

# 3) Сохраните образ в tar-файл
docker save -o astroill-site-prod.tar astroill-site:prod

# --- На другом компьютере ---
# 4) Загрузите образ из файла
docker load -i astroill-site-prod.tar

# 5) Запустите контейнер напрямую (без compose)
docker run -d -p 8080:80 --name astroill-site astroill-site:prod
# Откройте http://localhost:8080
```

Альтернатива без переназначения тега (если знаете точное имя образа Compose):

```bash
# Имя обычно выглядит как <имя_папки>-web:latest, например:
# wrlds-ai-integration-42754-web:latest

# Сохранение
docker save -o astroill-site-prod.tar wrlds-ai-integration-42754-web:latest

# Загрузка и запуск на целевой машине
docker load -i astroill-site-prod.tar
docker run -d -p 8080:80 --name astroill-site wrlds-ai-integration-42754-web:latest
```

## Технологии
- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS
- Docker / Docker Compose

## Полезные команды
- Dev (Docker): `docker compose --profile dev up web-dev`
- Prod (Docker): `docker compose up --build -d`
- Остановка: `docker compose down`
- Просмотр логов: `docker compose logs -f`

Если нужно добавить дополнительные proxy-настройки для API в dev-режиме или изменить порты — напишите, расширю конфигурацию.
