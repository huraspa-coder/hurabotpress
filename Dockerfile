# ====== Dockerfile Botpress OSS + CLI ======
FROM node:18-bullseye

WORKDIR /app

# Instala herramientas de compilación necesarias para dependencias nativas
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    git \
    curl \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Instala PNPM y CLI globales
RUN npm install -g pnpm@10.15.1 prebuild-install @botpress/cli@latest

# Configura PNPM global
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Copiar lockfiles primero para aprovechar cache
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copiar todo el repo (integraciones, src, patches)
COPY . .

# Ignorar patches locales problemáticos si existen
RUN pnpm config set ignore-patches true

# Instalar todas las dependencias del workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Construir todos los paquetes e integraciones
RUN pnpm build

# Exponer puerto estándar de Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
