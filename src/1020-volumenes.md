# Persistencia de datos

## El problema de la efimeridad

Los contenedores son efímeros por naturaleza: cuando eliminamos o reiniciamos un contenedor, todos los datos que se hayan generado dentro de él se pierden. Los datos adjuntos en tiempo de construcción (`COPY` o `ADD` en el `Dockerfile`) también desaparecen al borrar el contenedor, a menos que se haya creado una nueva imagen.

Vamos a verlo con un ejemplo:

```bash
docker run -d --name temporal alpine sh -c "echo 'Hola people' > /data/mensaje.txt && cat /data/mensaje.txt"
```

Si eliminamos el contenedor y lanzamos uno nuevo, el fichero `mensaje.txt` ya no existirá:

```bash
docker rm temporal
docker run alpine cat /data/mensaje.txt
# cat: can't open '/data/mensaje.txt': No such file or directory
```

Para conservar datos entre ejecuciones, necesitamos **volúmenes**.

## Tipos de volúmenes

Docker ofrece tres mecanismos de persistencia de datos:

- Montar una carpeta del host en el contenedor (bind mount)
- Almacenamiento gestionado por docker (volume)
- Almacenamiento efímero (tmpfs)


## Bind mounts

Un _bind mount_ monta un directorio del sistema anfitrión (host) dentro del contenedor. Lo que escribamos en ese directorio desde el contenedor se reflejará en el host, y viceversa.

Puede ser útil cuando tenemos un compilador en un contenedor y quemos , o queremos "subir" datos "por detrás" al contenedor o "bajarlos".

La sintaxis del volume mount es *muy* parecida a la de exposición de puertos

```bash
docker run -v /ruta/en/host:/ruta/en/contenedor <<nombre_contenedor>>
```

Un caso práctico habitual es montar el directorio de trabajo actual:

```bash
docker run -v "$(pwd):/app" -w /app node npm init
```

Esto monta la carpeta actual en `/app` dentro del contenedor y establece `/app` como directorio de trabajo con la opción `-w`. Es decir, 'node npm init' se ejecutará en el directorio /app.

## Volúmenes gestionados por Docker

Los _volumes_ son la forma recomendada de persistir datos en Docker. Docker los gestiona y los almacena en una ubicación del sistema (`/var/lib/docker/volumes/` en Linux).


### Crear un volumen

```bash
docker volume create mis-datos
```

Podemos listar los volúmenes existentes:

```bash
docker volume ls
```

Y ver sus detalles:

```bash
docker volume inspect mis-datos
```

### Usar un volumen en un contenedor

```text
docker run -v mis-datos:/datos alpine
                  |        |
                  |        \----> Punto de montaje en el contenedor
                  \-------------> Nombre del volumen
```

Si eliminamos el contenedor y creamos otro que monte el mismo volumen, los datos seguirán ahí:

```bash
docker run -v mis-datos:/datos alpine cat /datos/ejemplo.txt
# Contenido persistente
```

### Volúmenes anónimos

Si no especificamos un nombre, Docker crea un volumen anónimo con un identificador único:

```bash
docker run -v /datos alpine
```

Son útiles cuando no necesitamos reutilizar el volumen explícitamente, pero queremos que los datos sobrevivan al menos hasta que eliminemos el volumen. Por ejemplo, para no perder datos generados por una base de datos incluso si el contenedor se elimina accidentalmente.

### Volúmenes anónimos

Si no especificamos un nombre, Docker crea un volumen anónimo con un identificador único:

```bash
docker run -v /datos alpine
```

Son útiles cuando no necesitamos reutilizar el volumen explícitamente, pero queremos que los datos sobrevivan al menos hasta que eliminemos el volumen. Por ejemplo, para no perder datos generados por una base de datos incluso si el contenedor se elimina accidentalmente.

## Tmpfs mounts

Los _tmpfs mounts_ funcionan como un "ramdisk": montan un sistema de archivos temporal en la memoria RAM del host. Los datos escritos en un tmpfs mount son efímeros: desaparecen al detener el contenedor y nunca se escriben en el disco.

Son ideales para almacenar información sensible (como contraseñas o tokens) o datos temporales no necesitan persistencia pero sí un acceso muy rápido de lectura o escritura.

```bash
docker run --tmpfs /tmp alpine:latest sh -c "echo 'Datos en RAM' > /tmp/ejemplo.txt && cat /tmp/ejemplo.txt"
```

Al detener y eliminar el contenedor, los datos del tmpfs se pierden por completo.

También podemos especificar opciones adicionales como el tamaño máximo:

```bash
docker run --tmpfs /tmp:size=64M alpine df -h /tmp
```

### Eliminar volúmenes

```bash
docker volume rm mis-datos
```

Para eliminar todos los volúmenes no utilizados:

```bash
docker volume prune
```

## Persistencia en bases de datos

Las bases de datos son el caso de uso más común para los volúmenes. Sin un volumen, al eliminar el contenedor de la base de datos perderíamos toda la información.

```bash
docker run -d \
  --name mi-postgres \
  -e POSTGRES_PASSWORD=secreto \
  -v pg-data:/var/lib/postgresql/data \
  postgres
```

El contenedor arrancará y PostgreSQL guardará todos sus datos en el volumen `pg-data`. Podemos reiniciar o reemplazar el contenedor cuantas veces queramos; los datos persistirán.

```bash
docker rm -f mi-postgres
docker run -d \
  --name nuevo-postgres \
  -e POSTGRES_PASSWORD=secreto \
  -v pg-data:/var/lib/postgresql/data \
  postgres
```

La base de datos seguirá conteniendo los mismos datos que antes.

## Compartir datos entre contenedores

Varios contenedores pueden montar el mismo volumen simultáneamente. Esto permite que compartan información sin necesidad de red.

```bash
# Creamos el volumen compartido
docker volume create compartido

# Contenedor escritor
docker run -d --name escritor -v compartido:/data alpine sh -c "while true; do date >> /data/log.txt; sleep 5; done"

# Contenedor lector
docker run -it --name lector -v compartido:/data alpine cat /data/log.txt
```

## CUIDADO: Permisos y propietarios

Al usar _bind mounts_, los ficheros mantienen los permisos y el propietario del sistema anfitrión. Esto puede provocar problemas si el usuario dentro del contenedor (por ejemplo, `node` o `postgres`) no tiene los mismos UID/GID que el usuario del host.

Una solución común es especificar cómo mapear el usuario dentro del contenedor con la opción `--user`:

```bash
docker run --user "$(id -u):$(id -g)" -v "$(pwd):/app" alpine touch /app/fichero.txt
```

## Copia de seguridad de volúmenes

Podemos hacer una copia de seguridad de un volumen montándolo en un contenedor temporal y comprimiendo su contenido:

```bash
docker run --rm -v mis-datos:/datos -v "$(pwd):/backup" alpine tar czf /backup/mis-datos.tar.gz -C /datos .
```

Para restaurar:

```bash
docker run --rm -v mis-datos:/datos -v "$(pwd):/backup" alpine tar xzf /backup/mis-datos.tar.gz -C /datos
```

## Resumen

```text
Bind mount       ---> docker run -v /host/ruta:/container/ruta
Volume (nombrado) ---> docker run -v nombre-volumen:/container/ruta
Volume (anónimo) ---> docker run -v /container/ruta
```

Los **volúmenes gestionados** son la opción recomendada para producción porque:

- Docker los gestiona y aisla del resto del sistema.
- Son portables entre equipos.
- Se pueden gestionar con `docker volume` (crear, inspeccionar, eliminar, hacer copias de seguridad).
- Funcionan correctamente en entornos con múltiples hosts (Docker Swarm, Kubernetes).
