# Repositorio de código Gitea

Objetivo: desplegar nuestro "github" particular.

*[Gitea](https://gitea.io/)* es un 'forge' para alojar repositorios Git.
Tiene una interfaz web y soporta también el protocolo GIT a traves de HTTPS.

Pasos a seguir:

Tenemos que fijarnos pequeños objetivos e ir avanzando poco a poco:

1. Desplegar gitea en un contenedor.
2. Configurar gitea sin perder datos al reiniciar el contenedor.
3. Crear un repositorio en gitea.
4. Comunicarnos con gitea usando la línea de comandos (git remote add **direccion_del_remote (localhost)** )
5. Ejecutar gitea detrás de un proxy por seguridad (podéis usar https://caddyserver.com/ )
