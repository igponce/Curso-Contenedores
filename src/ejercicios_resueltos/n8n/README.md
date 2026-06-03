# Ejercicio resuelto: n8n

n8n es un sistema de automatización de flujos de trabajo (ver [n8n.io](https://n8n.io/)).

## Qué tenemos que hacer

### Paso 1: Levantar una BBDD PostgreSQL.

```yaml
services:
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=mbit01
    volumes:
      - postgres:/var/lib/postgresql/data
  volumes:
  n8n_volume:
    driver: local
  postgres:
    driver: local
```

Aquí hay dos cosas importantes:
- Configurar la password de Postgres. Lo hacemos definiendo variables de entorno`POSTGRES_PASSWORD=mbit01
- Como usamos una base de datos, seguramente querremos no perder los datos. Para ello creamos un volumen `postgres` y lo montamos en `/var/lib/postgresql/data` (que es donde Postgres almacena por defecto los datos)


### Paso 2: Levantar un n8n

Para levantar el n8n tenemos que crear un servicio `n8n` que arranque la imágen `docker.n8n.io/n8nio/n8n:latest`.

También necesitamos que n8n arranque después que Postgres porque consume información de la BBDD. Esto lo conseguimos con la opción `depends_on`.

```yaml
depends_on:
  - postgres
```

Observa que `depends_on` es un array. Puede que alguna vez necesites que un servicio arranque después de varios otros servicios (que podrían ser independientes unos de otros - por ejemplo una base de datos y un servidor de correo).

### Paso 3: Utilizar la BBDD de Postgres como backend de n8n

El servicio n8n utiliza por defecto una base de datos SQLite; sin embargo, no se recomienda utilizar SQLite en producción.

En la configuración que tenemos cada vez que reiniciamos el contendor la base de datos desaparece y hay que volver a configurar n8n a mano.

¿Cómo podemos usar el Postgres en lugar de SQLite?

La solución está en la documentación de n8n en docker hub: [Configuring n8n with PostgreSQL](https://hub.docker.com/r/n8nio/n8n#use-with-postgresql).

Tenemos que asignar varias variables de entorno para configurar la conexión a la BBDD de Postgres. Concetamente:

- DBTYPE (tiene que tomar el valor `postgres`)
- DB_HOST: ponemos el valor `postgres` 
- DB_PORT: ponemos el valor `5432` que es el puerto por defecto de Postgres.
- DB_USER: 'postgres'
- DB_PASSWORD: (la misma que el valor de `POSTGRES_PASSWORD` en el container de postgres)
- DB_DATABASE: 'postgres' (valor por defecto) 

Con esto el contenedor de n8n se conectará a la BBDD de Postgres y la utilizará como almacén de datos.

### Paso 4: Utilizar la BBDD de Postgres como memoria de chat

Por último, necesitamos configurar la BBDD de Postgres en n8n para que se utilice como memoria de chat.

Aquí no podemos usar variables de entorno.

Tenemos que crear una conexión de BBDD en n8n y utilizar unas credenciales específicas para conectarse a la BBDD de Postgres.

Estos son objetos que están dentro de la base de datos de n8n y no pueden hacer referencia a variables de entorno.

¿Cómo lo podemos hacer?

Creando a mano las credenciales en n8n y usando la dirección IP del contenedor de Postgres... pero ¿cómo obtenemos la dirección IP del contenedor de Postgres?

Podemos obtener la dirección IP del contenedor de Postgres usando el comando `docker inspect` y buscando una cadena `IPAddress` en la salida:

```bash
docker inspect postgres | grep IPAddress
```
Ahora podemos poner a mano esta IP en la credencial de n8n.

# Docker-Compose completo

```
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=mbit01
      - DB_POSTGRESDB_DATABASE=postgres
    depends_on:
      - postgres
    volumes:
      - n8n_volume:/posgres_ip.txt
      - n8n_volume:/data
    ports:
      - "5678:5678"

  postgres:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=mbit01
    volumes:
      - postgres:/var/lib/postgresql/data

volumes:
  n8n_volume:
    driver: local
  postgres:
    driver: local
```
