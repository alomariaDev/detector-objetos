# detector-objetos

Base del proyecto para deteccion de objetos, con PostgreSQL listo para desarrollo local mediante Docker Compose.

## Requisitos

- Docker con Compose v2

## PostgreSQL

Inicia la base de datos:

```bash
docker compose up -d
```

Comprueba el estado del servicio:

```bash
docker compose ps
```

Valores locales por defecto:

- Base de datos: `detector_objetos`
- Usuario: `detector`
- Contrasena: `detector_dev_password`
- Puerto local: `55432` (puerto interno de PostgreSQL: `5432`)

Puedes sobrescribirlos creando un archivo `.env` a partir de `.env.example`.

Para detener los contenedores:

```bash
docker compose down
```

Para eliminar tambien los datos persistidos:

```bash
docker compose down -v
```