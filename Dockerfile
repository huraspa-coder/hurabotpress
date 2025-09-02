# Dockerfile - Botpress OSS + CLI (última versión)
FROM node:18

# Configura directorio de la app
WORKDIR /app

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Instala Botpress CLI global
RUN pnpm install -g @botpress/cli@latest

# Copiar archivos de package y lock para instalar deps primero
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Instalar dependencias de workspace
RUN pnpm install --no-frozen-lockfile

# Copiar el resto del repo (integraciones, src, etc)
COPY . .

# Construir todas las integraciones y paquetes
RUN pnpm build

# Exponer puerto Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
