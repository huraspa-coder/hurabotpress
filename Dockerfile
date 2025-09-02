# ====== Dockerfile Botpress OSS completo ======
FROM node:18-bullseye

WORKDIR /app

# Instalar herramientas de compilación para dependencias nativas
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    git \
    curl \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Instalar PNPM y dependencias globales necesarias
RUN npm install -g pnpm@10.15.1 node-gyp prebuild-install @botpress/cli@latest

# Configurar PATH de PNPM
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Copiar archivos de lockfiles primero para cache
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copiar todo el proyecto (integraciones, src, patches)
COPY . .

# Ignorar patches locales para evitar errores
RUN pnpm config set ignore-patches true

# Instalar todas las dependencias del workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Construir todos los paquetes
RUN pnpm build

# Exponer puerto estándar de Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
