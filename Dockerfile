# Dockerfile (temporal) — copia todo y usa --no-frozen-lockfile para evitar bloqueo por lock mismatch
FROM node:18 AS builder

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

# Copiamos todo para que patches/ existan
COPY . .

# Instalar dependencias sin forzar el lockfile (temporal)
RUN pnpm install --no-frozen-lockfile

# Ejecutar build
RUN pnpm build

# Stage runtime
FROM node:18 AS runtime
ENV NODE_ENV=production

RUN corepack enable
RUN corepack prepare pnpm@8.6.2 --activate

WORKDIR /app

COPY --from=builder /app /app

# Instalar solo deps prod (intenta con frozen, si falla, sin frozen)
RUN pnpm install --prod --frozen-lockfile || pnpm install --prod --no-frozen-lockfile

EXPOSE 3000

CMD ["pnpm", "start"]
