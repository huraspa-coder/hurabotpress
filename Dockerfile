# Dockerfile - Botpress OSS + CLI (adaptado a tu setup local)
FROM node:18

# Directorio de la app
WORKDIR /app

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Configura PNPM_HOME para binarios globales
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Copiar archivos de lock y workspace
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copiar patches si existen
COPY patches ./patches

# Copiar todo el repo
COPY . .

# Instalar todas las dependencias del workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Construir todas las integraciones y paquetes
RUN pnpm run build

# Exponer puerto Botpress
EXPOSE 3000

# Comando para iniciar Botpress
CMD ["pnpm", "start"]
