FROM postgres:17-alpine

# Instalar dependencias para pg_http y pg_cron
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
    && cd pgsql-http \
    && make \
    && make install

# Compilar e instalar pg_cron
RUN git clone https://github.com/citusdata/pg_cron.git \
    && cd pg_cron \
    && make \
    && make install

# Copiar script de inicialización
COPY init-slave.sh /docker-entrypoint-initdb.d/

# Dar permisos de ejecución al script
RUN chmod +x /docker-entrypoint-initdb.d/init-slave.sh

# Copiar archivo de variables de entorno
COPY .env.docker /.env.docker

# Exponer puerto de PostgreSQL
EXPOSE 5432