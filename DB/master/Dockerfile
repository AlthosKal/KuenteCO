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

# Variables de entorno por defecto
ENV POSTGRES_USER=master
ENV POSTGRES_PASSWORD=root
ENV POSTGRES_DB=KuenteCO

# Exponer puerto de PostgreSQL
EXPOSE 5432

# Arranque usando el config modificado
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
