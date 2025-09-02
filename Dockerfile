# Etapa de build
FROM node:20-slim AS build

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
  python3 make g++ git curl \
  && rm -rf /var/lib/apt/lists/*

# Instalar pnpm globalmente
RUN npm install -g pnpm

WORKDIR /app

# Copiar solo los archivos necesarios para instalar dependencias
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches

# Instalar dependencias de workspace
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Copiar el resto del proyecto
COPY . .

# Build de Botpress
RUN pnpm run build

# Etapa final
FROM node:20-slim AS runtime
WORKDIR /app

RUN npm install -g pnpm

# Copiar desde la etapa de build
COPY --from=build /app ./

EXPOSE 3000

CMD ["pnpm", "start"]
