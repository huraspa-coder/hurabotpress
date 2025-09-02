# Dockerfile para ejecutar Botpress v12 usando la imagen oficial
FROM ghcr.io/botpress/botpress/server:v12_31_10

# Si tienes archivos de datos/configs locales que quieras incluir:
# COPY data/ /botpress/data/

# Exponer puerto (Botpress v12 por defecto 3000)
EXPOSE 3000

# La imagen ya trae entrypoint que arranca el servidor.
