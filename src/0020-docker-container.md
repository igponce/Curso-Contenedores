# Docker containers

Docker (2013) originalmente necesitaba un kernel de Linux específico. Por defecto los kernels estándar no disponían de todas las caracteristicas que necesitaba docker, como overlayFS.

Por este motivo, fabricantes como RedHat o Canonical (Ubuntu) comenzaron a lanzar versiones específicas del kernel para contenedores asegurando que el sistema soportaría la ejecución de contenedores de forma estable.

Actualmente el kernel de Linux de cualquier  distribución soporta contenedores; sin embargo es necesario instalar un paquete con la interfaz para ejecutar de contenedores como *docker*, *podman*, o *runc*.

# Ejecución de contenedores

```bash
$ docker run helloworld
```
Esto ejecuta el contenedor "helloworld".
