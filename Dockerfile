# Dockerfile (multi-stage) — build + runtime
# Stage 1: builder (instala todo y construye)
FROM node:18 AS builder

# Activar corepack y pnpm (versión que define packageManager)
RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos archivos de lock y package para cachear la instalación
# Incluye pnpm-lock.yaml y pnpm-workspace.yaml si los tienes
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
# Si no tienes alguno, COPY solo los que existan en tu repo.
# Instalar dependencias (incluye dev deps para poder build)
RUN pnpm install --frozen-lockfile

# Copiar el resto del código
COPY . .

# Ejecutar la build (usa tu script "build" en root)
RUN pnpm build

# Stage 2: runtime (ligero)
FROM node:18 AS runtime

ENV NODE_ENV=production
# Activar pnpm en runtime también
RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos la app ya construida desde builder
COPY --from=builder /app /app

# Instalar solo dependencias de producción (reduce tamaño)
# Esto también regenerará node_modules para producción
RUN pnpm install --prod --frozen-lockfile

# Exponer puerto (ajusta si usas otro)
EXPOSE 3000

# Comando final — usa tu start script
CMD ["pnpm", "start"]
