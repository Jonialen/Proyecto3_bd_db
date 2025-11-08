# Proyecto3_bd_db

Esta parte del proyecto contiene la configuración y los scripts de inicialización para la base de datos PostgreSQL.

## Tabla de Contenidos
- [Proyecto3_bd_db](#proyecto3_bd_db)
  - [Tabla de Contenidos](#tabla-de-contenidos)
  - [Descripción](#descripción)
  - [Tecnologías](#tecnologías)
  - [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
  - [Uso](#uso)

## Descripción

Este directorio utiliza Docker y Docker Compose para crear un contenedor con una base de datos PostgreSQL. La base de datos se inicializa con un esquema, triggers y datos de prueba.

La base de datos modela un sistema de reservas para canchas deportivas. Es utilizada por un backend en FastAPI y un frontend en React para generar diferentes reportes y estadísticas.

Incluye:

- Tablas relacionadas a usuarios, canchas, horarios, reservas y promociones.
- Datos iniciales de ejemplo para pruebas y desarrollo.
- Compatibilidad total con Docker para facilitar el despliegue.

## Tecnologías

- PostgreSQL 17
- Docker

## Estructura de la Base de Datos

La inicialización de la base de datos se realiza a través de los siguientes scripts SQL, que se ejecutan en orden alfabético:

- **`01_init.sql`**: Crea todas las tablas, relaciones y vistas necesarias para la aplicación.
- **`02_triggers.sql`**: Define los triggers y funciones para automatizar ciertas lógicas en la base de datos (por ejemplo, actualizar timestamps).
- **`03_data.sql`**: Inserta datos iniciales para el desarrollo y las pruebas, como tipos de cancha, roles de usuario, etc.

## Uso

Para levantar el servicio de la base de datos, sigue estos pasos:

1.  **Asegúrate de tener Docker instalado.**

2.  **Navega a este directorio y ejecuta Docker Compose:**
    ```bash
    docker-compose up -d
    ```

Esto creará y correrá un contenedor llamado `postgres-mvp`.

-   **Host**: `localhost`
-   **Puerto**: `5430` (mapeado al puerto `5432` del contenedor)
-   **Usuario**: `mvpuser`
-   **Contraseña**: `mvppass`
-   **Nombre de la base de datos**: `mvpdb`

Para detener el servicio, ejecuta:
```bash
docker-compose down
```
