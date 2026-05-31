# Docker Compose

## El problema de orquestar múltiples contenedores

Hasta ahora hemos lanzado contenedores con `docker run`. Cuando solo tenemos uno o dos, es manejable. Pero en cuanto nuestro entorno involucra varios servicios —una base de datos, un backend, un frontend, una caché—, gestionarlos a mano se vuelve pesado.

```bash
docker network create mi-red
docker run -d --network mi-red --name db -v pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secreto postgres
docker run -d --network mi-red --name backend -p 3000:3000 mi-backend
docker run -d --network mi-red --name frontend -p 8080:80 mi-frontend
```

Para cada servicio repetimos: red, volúmenes, puertos, variables de entorno, orden de arranque...

*Docker Compose* resuelve esto permitiéndonos describir todo el entorno en un único fichero YAML y levantarlo con un solo comando.

## docker-compose.yml

El fichero `compose.yml` (o `docker-compose.yml`) define los servicios, redes y volúmenes que forman parte de la aplicación.

Veamos un ejemplo:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secreto

volumes:
  pgdata:
```

Este fichero define tres servicios que se comunican a través de la red que Compose crea automáticamente.

La app tiene un apartado "build" que define cómo construir la imagen Docker para el servicio.

## Comandos básicos

### Levantar el entorno

```bash
docker compose up
```

Con `-d` (detached) para que se ejecute en segundo plano:

```bash
docker compose up -d
```

### Ver el estado

```bash
docker compose ps
```

### Ver los logs

```bash
docker compose logs -f
```

En los logs veremos los mensajes de los contenedores. Cada mensaje de log tiene el nombre del contenedor al que pertenece.

### Detener y eliminar

```bash
docker compose down
```

`down` detiene los contenedores y elimina la red creada por Compose, pero **no elimina los volúmenes**. Para eliminarlos también:

```bash
docker compose down -v
```

### Reconstruir imágenes

Si hemos modificado el código y el servicio tiene `build: .`, podemos reconstruir la imagen:

```bash
docker compose build
```

O directamente levantar forzando la reconstrucción:

```bash
docker compose up --build
```

## Comunicación entre servicios

Compose crea automáticamente una red para todos los servicios definidos en el fichero. Cada servicio es accesible por su nombre (el que aparece bajo `services:`). Así, desde el servicio `app` podemos conectar a la base de datos usando el hostname `db`, tal como hemos puesto en `DB_HOST=db`.

```yaml
services:
  app:
    environment:
      - DB_HOST=db      # ← nombre del servicio en Compose
      - DB_PORT=5432
```

*¡OJO!* No hace falta exponer puertos de la base de datos al host; solo los servicios que necesiten acceso externo (web, API) usan `ports`.

## Dependencias y orden de arranque

Con `depends_on` indicamos que un servicio debe arrancar antes que otro:

```yaml
services:
  app:
    depends_on:
      - db
```

Esto solo garantiza un orden de arranque.
