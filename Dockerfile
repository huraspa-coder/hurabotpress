# Dockerfile (multi-stage) — builder + runtime
# Stage 1: builder
FROM node:18 AS builder

# Activar corepack y pin de pnpm (según packageManager)
RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos archivos críticos para cache de dependencias
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Instalar dependencias (incluye dev deps para poder build)
RUN pnpm install --frozen-lockfile

# Copiar el resto del código
COPY . .

# Ejecutar la build (usar script "build" en root)
RUN pnpm build

# Stage 2: runtime
FROM node:18 AS runtime

ENV NODE_ENV=production

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos la app construida
COPY --from=builder /app /app

# Instalar solo dependencias de producción para reducir tamaño
RUN pnpm install --prod --frozen-lockfile

# Exponer puerto por defecto de Botpress
EXPOSE 3000

# Command final
CMD ["pnpm", "start"]
