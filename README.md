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

## Tabla de detecciones

La tabla `detections` guarda los resultados de `yolo26n`: clase (`class_name`),
confianza (`confidence`) y caja (`bbox`), además del modelo, origen, frame,
fecha y metadatos.

Ejemplo de inserción:

```sql
INSERT INTO detections (
	source_name, class_id, class_name, confidence, bbox
) VALUES (
	'imagen.jpg', 0, 'person', 0.91,
	'{"x1": 120.5, "y1": 80.2, "x2": 340.7, "y2": 420.1}'::jsonb
);
```

Las migraciones están en `db/init/`. Docker las ejecuta automáticamente al
crear un volumen PostgreSQL nuevo.

Para detener los contenedores:

```bash
docker compose down
```

Para eliminar tambien los datos persistidos:

```bash
docker compose down -v
```