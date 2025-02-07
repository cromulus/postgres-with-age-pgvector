# Use PostgreSQL 16 – the maximum version supported by Apache AGE
FROM postgres:16-bookworm


# Add Debian Bookworm backports repository to install golang-1.22-go
RUN echo "deb http://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        git \
        golang-1.22-go \
        flex \
        bison \
        postgresql-server-dev-16 && \
    rm -rf /var/lib/apt/lists/*

# Build and install the pg_vector extension
RUN git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make && \
    make install && \
    rm -rf /tmp/pgvector

# Build and install the Apache AGE extension
RUN git clone https://github.com/apache/age.git /tmp/age && \
    cd /tmp/age && \
    make PG_CONFIG=/usr/bin/pg_config && \
    make install PG_CONFIG=/usr/bin/pg_config && \
    rm -rf /tmp/age


COPY init-pgvector.sql /docker-entrypoint-initdb.d/init-pgvector.sql

# Add an init script to set 'age' as a shared preload library.
# This script will run when a new database is initialized.

COPY init-age.sh /docker-entrypoint-initdb.d/init-age.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-age.sh
