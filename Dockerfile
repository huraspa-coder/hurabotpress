# Dockerfile - Botpress OSS + CLI (última versión)
FROM node:18-bullseye

# Configura directorio de la app
WORKDIR /app

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Copiar archivos principales primero (para aprovechar caché de Docker)
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Instalar dependencias de workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Copiar el resto del proyecto (integraciones, src, etc)
COPY . .

# Construir todos los paquetes e integraciones
RUN pnpm run build

# Instalar la última versión del CLI de Botpress de manera global
RUN pnpm add -g @botpress/cli@latest

# Exponer puerto de Botpress
EXPOSE 3000

# Arrancar Botpress (desde el CLI global)
CMD ["botpress", "start"]
