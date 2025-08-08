FROM mongo:8.0

# Copiar archivo de variables de entorno
COPY .env.docker /.env.docker

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "mongosh", "--eval", "db.adminCommand({ ping: 1 })" ]

EXPOSE 27017
