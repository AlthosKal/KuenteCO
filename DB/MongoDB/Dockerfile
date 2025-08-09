FROM mongo:8.0

# Copiar archivo de variables de entorno
COPY .env.docker /.env.docker

# Crear script de entrada personalizado que carga .env.docker
RUN echo '#!/bin/bash' > /docker-entrypoint-custom.sh && \
    echo 'set -a' >> /docker-entrypoint-custom.sh && \
    echo 'source /.env.docker' >> /docker-entrypoint-custom.sh && \
    echo 'set +a' >> /docker-entrypoint-custom.sh && \
    echo 'exec /usr/local/bin/docker-entrypoint.sh "$@"' >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh
  
# Usar nuestro script personalizado como entrypoint
ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["mongod"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "mongosh", "--eval", "db.adminCommand({ ping: 1 })" ]
EXPOSE 27017
