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

## Frontend

El frontend se sirve en `http://localhost:8080`:

```bash
docker compose up -d --build frontend
```

Desde la página puedes iniciar y detener la cámara del equipo y capturar un
frame local. El navegador solicitará permiso para usar la cámara; por ahora la
captura no se envía al backend ni se guarda en PostgreSQL.

El build incluye el peso oficial `yolo26n.onnx` dentro de la imagen para que
el navegador lo cargue desde el mismo origen y pueda ejecutar la inferencia sin
problemas de CORS.

## Backend de detecciones

El backend FastAPI se sirve directamente en `http://localhost:8001` y también
está disponible desde el frontend bajo `/api`.

- `GET /api/health`: comprueba que el backend puede conectarse a PostgreSQL.
- `POST /api/detections`: guarda una detección con `class_name`, `confidence` y `bbox`.
- `GET /api/detections?limit=100&offset=0`: consulta las detecciones guardadas.

Ejemplo para guardar una detección:

```bash
curl -X POST http://localhost:8001/api/detections \
	-H 'Content-Type: application/json' \
	-d '{
		"source_name": "camara-1",
		"class_id": 0,
		"class_name": "person",
		"confidence": 0.91,
		"bbox": {"x1": 120.5, "y1": 80.2, "x2": 340.7, "y2": 420.1}
	}'
```

Cuando las detecciones están activas en el frontend, se envían automáticamente
a este endpoint como máximo una vez por segundo y se guardan en PostgreSQL.

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