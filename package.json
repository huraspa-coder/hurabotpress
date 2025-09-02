# Dockerfile - Botpress OSS + CLI (última versión)
FROM node:18

# Configura directorio de la app
WORKDIR /app

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Configura PNPM_HOME para global bin
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Inicializa directorio de binarios globales
RUN pnpm setup

# Instala Botpress CLI global (última versión)
RUN pnpm install -g @botpress/cli@latest

# Copiar archivos de dependencias y parches antes de instalar
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./ 
COPY patches ./patches

# Instalar todas las dependencias del workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Copiar el resto del proyecto (src, integraciones, etc)
COPY . .

# Construir todas las integraciones y paquetes
RUN pnpm build

# Exponer puerto Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
