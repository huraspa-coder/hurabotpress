# ====== Imagen base ======
FROM node:20-bullseye

# ====== Variables de entorno ======
ENV NODE_ENV=production
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# ====== Crear directorio de trabajo ======
WORKDIR /app

# ====== Instalar PNPM ======
RUN corepack enable && corepack prepare pnpm@latest --activate

# ====== Copiar archivos de dependencia y patches primero ======
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches

# ====== Instalar dependencias ======
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# ====== Copiar el resto del proyecto ======
COPY . .

# ====== Construir Botpress ======
RUN pnpm run build

# ====== Exponer puerto Botpress ======
EXPOSE 3000

# ====== Comando por defecto ======
CMD ["pnpm", "start"]
