# Troubleshooting

Problemas comunes con docker

- No tenemos permisos para el "named pipe" de docker em 
  - Ejecutamos docker como un usuario sin permisos.
  - Windows: tenemos varias versiones de docker corriendo.
- Docker daemon caido
  - systemctl start docker.service
- No podemos descargar (pull) imágenes de contenedor
  - Problema de conectividad
  - No disponemos de credenciales para el container registry (docker hub también es un container registry).
- Disco lleno
  - Hay que eliminar imágenes del disco (docker images ls)

Problemas con containers:
- Reinicio del contenedor
- Reinicio del host antes de tener diagnósticos
