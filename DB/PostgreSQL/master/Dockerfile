FROM postgres:17-alpine

# Instalar dependencias
RUN apk add --no-cache \
    postgresql-dev \
    curl-dev \
    make \
    gcc \
    clang19 \
    llvm19 \
    llvm19-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Compilar e instalar pg_http
RUN git clone https://github.com/pramsey/pgsql-http.git \
    && cd pgsql-http && make && make install

# Compilar e instalar pg_cron
RUN git clone https://github.com/citusdata/pg_cron.git \
    && cd pg_cron && make && make install

# Copiar archivos de inicialización
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf
COPY init-master.sh /docker-entrypoint-initdb.d/init-master.sh

# Asegurar permisos de ejecución
RUN chmod +x /docker-entrypoint-initdb.d/init-master.sh

# Copiar archivo de variables de entorno
COPY .env.docker /.env.docker

# Crear script de entrada personalizado que carga .env.docker
RUN echo '#!/bin/bash' > /docker-entrypoint-custom.sh && \
    echo 'set -a' >> /docker-entrypoint-custom.sh && \
    echo 'source /.env.docker' >> /docker-entrypoint-custom.sh && \
    echo 'set +a' >> /docker-entrypoint-custom.sh && \
    echo 'exec /usr/local/bin/docker-entrypoint.sh "$@"' >> /docker-entrypoint-custom.sh && \
    chmod +x /docker-entrypoint-custom.sh

HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=250s \
  CMD pg_isready -U master -d KuenteCO

# Exponer puerto de PostgreSQL
EXPOSE 5432

# Usar nuestro script personalizado como entrypoint
ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
