# Dockerfile final funcional - Botpress OSS + CLI
FROM node:18

# Directorio de la app
WORKDIR /app

# Instala dependencias del sistema para compilación de paquetes nativos
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Configura PNPM_HOME para global bin
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Instala prebuild-install global para dependencias nativas
RUN npm install -g prebuild-install

# Instala Botpress CLI global (última versión)
RUN pnpm install -g @botpress/cli@latest

# Copiar archivos de lock y package antes de instalar
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copiar el resto del proyecto
COPY . .

# Ignorar patches locales problemáticos
RUN pnpm config set ignore-patches true

# Instalar todas las dependencias del workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Construir todas las integraciones y paquetes
RUN pnpm build

# Exponer puerto de Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
