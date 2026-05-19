# Container internals

## Arranque de un contenedor paso a paso

1. **Creación del proceso**: El comando [`docker run`]() (o `podman run`) crea un nuevo proceso en el host que actuará como proceso init del contenedor.

2. **Configuración de namespaces**: El proceso se ejecuta con nuevos **namespaces** (PID, NET, IPC, UTS y mount) mediante la llamada al sistema `clone()` con las flags adecuadas. Esto aísla la vista de procesos, red, sistemas de archivos y nombres de host del contenedor.

Algunos identificadores como el PID de los procesos son globales en el host; pero desde dentro del container sólo se ve lo que está en el namespace del container.

3. **Asignación de cgroups**: Se crea un nuevo **cgroup** (o se asigna a uno existente) para limitar y monitorizar recursos como CPU, memoria y E/S del contenedor.

4. **Montaje del sistema de archivos raíz**: Se monta la capa de lectura‑solo de la imagen del contenedor y, si corresponde, una capa writable (overlayFS) que forma el **rootfs** del contenedor.

5. **Cambiar la raíz (pivot_root / chroot)**: El proceso cambia su raíz al nuevo `rootfs` mediante `pivot_root` (o `chroot`), de modo que todo el árbol de directorios que ve corresponde al contenedor.

6. **Configuración de la red**: Se crea una interfaz de red virtual y se la conecta a un bridge o a otro tipo de red configurada por Docker. Se asigna una dirección IP al contenedor.

7. **Montaje de /proc y /sys**: Se montan los sistemas de archivos virtuales `/proc` y `/sys` dentro del contenedor para que las herramientas del sistema funcionen correctamente (por ejemplo [ps(1)](https://manpages.ubuntu.com/manpages/focal/man1/ps.1.html))

8. **Ejecutar el proceso especificado**: Finalmente, el proceso init del contenedor (por defecto `/bin/sh` o el `ENTRYPOINT` de la imagen) se ejecuta con [`execve`](https://manpages.ubuntu.com/manpages/focal/man2/execve.2.html), heredando el entorno configurado.

9. **Gestión del ciclo de vida**: Docker monitoriza el proceso principal; cuando termina, Docker limpia los namespaces, desmonta el `rootfs`, libera los cgroups y elimina la red virtual.

Este flujo permite que el contenedor se inicie de forma aislada, con sus propios recursos y vista del sistema, pero compartiendo el kernel del host.
