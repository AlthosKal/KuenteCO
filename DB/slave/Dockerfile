FROM postgres:17

# Instalar dependencias para pg_http y pg_cron
RUN apt-get update && apt-get install -y \
    postgresql-server-dev-17 \
    libcurl4-openssl-dev \
    make \
    gcc \
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

# Variables de entorno por defecto
ENV POSTGRES_USER=slave
ENV POSTGRES_PASSWORD=root
ENV POSTGRES_DB=KuenteCO
ENV MASTER_HOST=postgres-master-database
ENV MASTER_PORT=5432
ENV REPLICATOR_USER=replicator
ENV REPLICATOR_PASSWORD=root

# Exponer puerto de PostgreSQL
EXPOSE 5432