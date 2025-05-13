# Proyecto3 BD - Database de Reportes de Reservas de Canchas Deportivas

Este repositorio contiene la definición y despliegue de la base de datos utilizada en el Proyecto 3.

## Descripción

La base de datos modela un sistema de reservas para canchas deportivas. Es utilizada por un backend en FastAPI y un frontend en React para generar diferentes reportes y estadísticas.

Incluye:

- Tablas relacionadas a usuarios, canchas, horarios, reservas y promociones.
- Datos iniciales de ejemplo para pruebas y desarrollo.
- Compatibilidad total con Docker para facilitar el despliegue.

## Cómo correr el proyecto

1. Clona el repositorio:
    ```bash
    git clone https://github.com/Jonialen/Proyecto3_bd_db.git
    cd Proyecto3_bd_db

2. Levanta los servicios con Docker:
    ```bash
    docker-compose up --build