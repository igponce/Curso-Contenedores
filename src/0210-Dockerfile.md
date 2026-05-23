# Creación de imagenes (Dockerfile)

El fichero Dockerfile tiene este aspecto (a grandes rasgos):

```dockerfile
FROM imagen_base
RUN <<comando>>
COPY <<fichero_origen>> <<fichero_destino>>
```
Veamos un ejemplo real: [Python:3.13](https://github.com/docker-library/python/blob/078b07840dfee55993c57dada1e5cf99ebd16dce/3.13/trixie/Dockerfile)

Para crear la imágen de docker ejecutamos `docker build`:

```bash
docker build -t <<nombre_imagen>> .
              |                   |
              |                   └───> Directorio actual donde buscar el Dockerfile
              └────────────> Nombre de la imagen (etiqueta)    
```

Podemos utilizar el flag `-f` para especificar un Dockerfile diferente:

```bash
docker build -t <<nombre_imagen>> -f Dockerfile_debug .
```

# Referencia de Dockerfile

A continuación se listan todos los comandos (instrucciones) que puede contener un `Dockerfile`, ordenados alfabéticamente:

| Comando | Descripción |
|---|---|
| `ADD` | Copia ficheros, directorios o URLs remotas al contenedor. Similar a `COPY`, pero soporta orígenes URL y descompresión automática de tarballs. |
| `ARG` | Define una variable que se pasa en tiempo de construcción (`docker build --build-arg`). No persiste en la imagen final. |
| `CMD` | Proporciona el comando por defecto al ejecutar el contenedor. Se sobreescribe al pasar argumentos a `docker run`. Solo el último `CMD` tiene efecto. |
| `COPY` | Copia ficheros o directorios del contexto de construcción al sistema de ficheros del contenedor. |
| `ENTRYPOINT` | Configura el contenedor como un ejecutable. A diferencia de `CMD`, no se sobreescribe al pasar argumentos; los argumentos se concatenan. |
| `ENV` | Establece variables de entorno que persisten en el contenedor en ejecución. |
| `EXPOSE` | Documenta que el contenedor escucha en un puerto. No lo publica automáticamente: es  informativo. |
| `FROM` | Inicializa una nueva etapa de construcción y establece la imagen base. Es la primera instrucción de un `Dockerfile` (salvo `ARG`). |
| `HEALTHCHECK` | Define un comando que Docker ejecuta periódicamente para verificar si el contenedor sigue funcionando correctamente. |
| `LABEL` | Añade metadatos a la imagen en forma de pares clave=valor (versión, mantenedor, descripción...). |
| `RUN` | Ejecuta un comando en una nueva capa sobre la imagen actual y confirma el resultado. Es la instrucción principal para instalar paquetes y configurar el sistema. |
| `SHELL` | Cambia el shell por defecto usado por `RUN`, `CMD` y `ENTRYPOINT`. Por defecto es `/bin/sh -c` en Linux. |
| `USER` | Cambia el usuario (UID/GID) que ejecutará las siguientes instrucciones `RUN`, `CMD` y `ENTRYPOINT`. |
| `VOLUME` | Declara un punto de montaje para datos persistentes. Crea un volumen anónimo en tiempo de ejecución. |
| `WORKDIR` | Establece el directorio de trabajo para las siguientes instrucciones `RUN`, `CMD`, `ENTRYPOINT`, `COPY` y `ADD`. Crea el directorio si no existe. |
