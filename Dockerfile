# Usa Node 18
FROM node:18

# Instalar pnpm
RUN npm install -g pnpm

# Crear carpeta de la app
WORKDIR /app

# Copiar archivos
COPY . .

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Construir proyecto
RUN pnpm build

# Exponer puerto (Botpress usa 3000 por defecto)
EXPOSE 3000

# Arrancar Botpress
CMD ["pnpm", "start"]
