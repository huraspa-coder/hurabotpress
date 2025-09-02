# ====== Dockerfile definitivo para Botpress ======

# Base image
FROM node:20-bullseye-slim

# ====== Variables de entorno ======
ENV BOTPRESS_VERSION=13.18.1
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# ====== Instalar herramientas necesarias ======
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ====== Instalar PNPM (última versión) ======
RUN npm install -g pnpm@latest

# ====== Crear directorio de la app ======
WORKDIR /app

# ====== Copiar package.json y pnpm-lock.yaml primero ======
# Esto permite instalar dependencias sin copiar todo el código (cache layer)
COPY package.json pnpm-lock.yaml ./

# ====== Configurar PNPM y evitar errores con patches/scripts ======
RUN pnpm config set ignore-patches true \
 && pnpm config set fetch-retries 5 \
 && pnpm install --shamefully-hoist --no-frozen-lockfile --ignore-scripts

# ====== Copiar el resto del proyecto ======
COPY . .

# ====== Construir Botpress ======
RUN pnpm run build

# ====== Instalar Botpress CLI global (última versión) ======
RUN pnpm add -g @botpress/cli@latest

# ====== Exponer puerto Botpress ======
EXPOSE 3000

# ====== Comando para iniciar Botpress ======
CMD ["botpress", "start", "--production"]
