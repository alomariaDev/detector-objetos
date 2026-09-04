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

La tabla `detections` guarda los resultados de `yolo26n`: clase, etiqueta,
confianza, coordenadas de la caja, modelo, origen, frame, fecha y metadatos.

Ejemplo de inserción:

```sql
INSERT INTO detections (
	source_name, class_id, label, confidence, x1, y1, x2, y2
) VALUES (
	'imagen.jpg', 0, 'person', 0.91, 120.5, 80.2, 340.7, 420.1
);
```

La migración está en `db/init/001_create_detections.sql`. Docker la ejecuta
automáticamente al crear un volumen PostgreSQL nuevo.

Para detener los contenedores:

```bash
docker compose down
```

Para eliminar tambien los datos persistidos:

```bash
docker compose down -v
```