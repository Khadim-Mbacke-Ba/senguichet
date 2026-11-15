
# Etape 1 : Construction du frontend
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Etape 2 : Serveur Nginx
FROM nginx:alpine

# Configuration personnalisée de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Fichiers compilés du frontend
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
