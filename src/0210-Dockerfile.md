# Creación de imagenes (Dockerfile)

El fichero Dockerfile tiene este aspecto (a grandes rasgos):

```dockerfile
FROM imagen_base
RUN <<comando>>
COPY <<fichero_origen>> <<fichero_destino>>
```
Veamos un ejemplo real: [Python:3.13](https://github.com/docker-library/python/blob/078b07840dfee55993c57dada1e5cf99ebd16dce/3.13/trixie/Dockerfile)
