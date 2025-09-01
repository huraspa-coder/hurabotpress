# Dockerfile (builder simple que asegura que patches existan antes de instalar)
FROM node:18 AS builder

# activar corepack/pnpm
RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos TODO el repo primero (asegura que patches/ existan)
COPY . .

# Instalar dependencias (usa el lockfile si está presente)
RUN pnpm install --frozen-lockfile

# Ejecutar la build del monorepo
RUN pnpm build

# Stage runtime
FROM node:18 AS runtime
ENV NODE_ENV=production

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos artefactos desde el builder
COPY --from=builder /app /app

# Instalar solo deps de producción para aligerar la imagen
RUN pnpm install --prod --frozen-lockfile || pnpm install --prod

EXPOSE 3000

CMD ["pnpm", "start"]
