# Configuración

¿Cómo podemos configurar un contenedor?
Tenemos que tener alguna manera de gestionar cómo se comporta el software que tenemos dentro del contenedor para que interactúe correctamente con otros sistemas.

Para configurar el contenedor tenemos estas posibilidades:

- Configuración con variables de entorno
- Configuración mediante volúmenes
- Configuración mediante *secrets*
- Creación de un container nuevo con la configuración

Dependiendo de lo que necesitemos utilizaremos un método u otro:

| Método | Cometido |
|--------|----------|
| Variables de entorno | Configuración de elementos puntuales. |
| Volúmenes | Montaje de ficheros de configuración o directorios con configuración (mysql: my.cfg, nginx: /etc/nginx/sites-available) |
| Secrets | Valores o ficheros que contienen datos sensibles como credenciales, o claves de API |
| Container nuevo | Configuraciones muy complejas que no tienen información sensible (por ejemplo, estructuras de directorios)|

## Variables de entorno

La forma más sencilla de configurar software.
Basta con hacer que tu software espere que varias variables de entorno estén definidas.

Por ejemplo este código se puede configurar con variables de entorno:

```python
from os import environ

config_defaults = [
    ('DB_HOST', '127.0.0.1'),
    ('JWT_SHARED_SECRET', 'test123'),
    ('ENDPOINT', 'http://localhost:1234')
]

app_config = {k: environ.get(k,v) for (k,v) in config_defaults }

# resto de la aplicación

```

Si esta aplicación está paquetizada en un contenedor podemos ejecutarla cambiando su configuración de esta manera:

```bash
$ docker run -e ENDPOINT="https://google.com" \
             -e DB_HOST="server.database.com" \
             <<app>>:latest
```

Ejemplo: [Postgres en dockerhub](https://hub.docker.com/_/postgres/)

## Volúmenes

Para configurar mediante volúmenes exponemos los ficheros o directorios en los puntos de montaje que espera la aplicación.

```bash
$ docker run --name my-custom-nginx-container -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx
```

Ejemplo: Servidor web [nginx](https://hub.docker.com/_/nginx)

## Secrets

Los secrets son datos gestionados por Docker y que se montan como ficheros durante la ejecución del contenedor.

Es mejor usar secrets que variables de entorno porque los secrets no aparecen en los logs; sin embargo una variable de entorno sí puede aparecer.
Las variables de entorno se pueden consultar fácilmente desde cualquier proceso.

Para crear el secret utilizamos el comando `docker secret create` 
```
echo "sk-AAS....." | docker secret create OPENAI_API_KEY -
```

Para usar los secrets necesitamos [docker-compose](0230-docker-compose.md)
