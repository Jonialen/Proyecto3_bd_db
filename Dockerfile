FROM postgres:17

COPY sql/*.sql /docker-entrypoint-initdb.d/
