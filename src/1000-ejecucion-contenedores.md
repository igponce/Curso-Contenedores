# Ejecución de contenedores

Para ejecutar un contenedor usamos 'docker run':

```text
docker run rancher/cowsay:latest "Hola people"
              ^      ^       ^      ^
              |      |       |      \----- Argumentos
              |      |       \------------ Etiqueta (version)
              |      \-------------------- nombre del contenedor
              \--------------------------- proveedor (en docker hub)
```

Al ejecutar el contenedor así, la salida del contenedor se muestra en *stdout* y cuando termina de ejecutarse el contenedor volvemos.

La salida del container será esta:

```text
_____________ 
< Hola people >
 -------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

No todos los containers terminan y nos devuelven el control.
Si ejecutamos una base de datos, o un servicio web el contenedor se quedará en ejecución y no nos devolverá el control.

Por ejemplo:
```
docker run jupyter/jupyter-minimal-notebook
```

En este caso debemos ejecutar el contenedor usando '-d' (dettach o daemon):

```
docker run  -d jupyter/minimal-notebook
1bafab238aac6f0398be149b0be03166a1afd167bf0c93efb8290192b76ff392
```
Ahora este contenedor se está ejecutando 

Podemos ver qué contenedores se están ejecutando con la orden `docker ps`:
```bash
docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                   PORTS      NAMES 
1bafab238aac   jupyter/minimal-notebook   "tini -g -- start-no…"   8 seconds ago   Up 7 seconds (healthy)   8888/tcp   nostalgic_khorana 
```

Si queremos eliminar (matar) el contenedor que hemos creado antes usamos `docker kill`:
```bash
docker kill 1bafab238aac
```
