# Dockerfile (multi-stage) — builder + runtime
# Stage 1: builder
FROM node:18 AS builder

# Activar corepack y pnpm (versión definida en packageManager)
RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos archivos críticos para cachear instalación
# Si no existe alguno, el COPY fallará; en ese caso remueve los nombres que no tengas.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Instalar dependencias (incluye dev deps para build)
RUN pnpm install --frozen-lockfile

# Copiar el resto del repo
COPY . .

# Ejecutar la build usando tu "build" en package.json (turbo run ...)
RUN pnpm build

# Stage 2: runtime (ligero)
FROM node:18 AS runtime

ENV NODE_ENV=production

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos la app ya construida
COPY --from=builder /app /app

# Instalar sólo deps de producción
RUN pnpm install --prod --frozen-lockfile

# Puerto por defecto de Botpress
EXPOSE 3000

# Arrancar con tu script start (botpress start)
CMD ["pnpm", "start"]
