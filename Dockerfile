# Dockerfile (multi-stage) — builder + runtime
FROM node:18 AS builder

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos archivos críticos para cachear instalación
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Instalar dependencias (incluye dev deps para build)
RUN pnpm install --frozen-lockfile

# Copiar el resto del repo
COPY . .

# Ejecutar la build usando tu "build" en package.json (turbo run ...)
RUN pnpm build

# Stage runtime
FROM node:18 AS runtime
ENV NODE_ENV=production

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app
COPY --from=builder /app /app

# Instalar solo deps de producción
RUN pnpm install --prod --frozen-lockfile

EXPOSE 3000

CMD ["pnpm", "start"]
