# Prueba de instalación

Para verificar que Docker se ha instalado correctamente, ejecuta los siguientes comandos:

```bash
docker run hello-world
```

Este comando descarga y ejecuta una imagen de prueba. 
Debes ver un mensaje de bienvenida que confirma que la instalación está operativa.

```bash
docker ps -a
```

Muestra la lista de todos los contenedores que hay en el sistema. 
Después de ejecutar el contenedor hello-world tienes que ver que el contenedor está ahí parado.

```bash
docker images
```

Lista las imágenes Docker que tienes almacenadas localmente. 
Deberías ver la imagen `hello-world` en la lista, lo que confirma que la descarga e instalación de imágenes funciona correctamente.
