# Dockerfile - Botpress OSS + CLI (última versión)
FROM node:18

# Configura directorio de la app
WORKDIR /app

# Instala pnpm
RUN npm install -g pnpm@10.15.1

# Configura PNPM_HOME para global bin
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Instala Botpress CLI global
RUN pnpm install -g @botpress/cli@latest

# Copiar archivos esenciales para workspace
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY patches ./patches

# Copiar todos los paquetes y las integraciones
COPY packages ./packages
COPY integrations ./integrations

# Instalar dependencias de workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Construir todas las integraciones y paquetes
RUN pnpm build

# Copiar cualquier otro archivo restante (scripts, configs, etc.)
COPY . .

# Exponer puerto Botpress
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
