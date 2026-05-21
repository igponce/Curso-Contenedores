# Conexión a la red

## Mapeo de puertos

Hasta ahora no hemos accedido al container desde el exterior.
Volvemos a lanzar el contender para ver qué ocurre:

```bash
docker run jupyter/minimal-notebook
```

Si intentamos entrar en el puerto de Jupyter lab (8888), obtendremos un error porque no podemos conectarnos. Ese puerto no está abierto en el host; pero sí en el contenedor.

Lo que tenemos que hacer es exponer el puerto de _dentro_ del contenedor hacia el exterior:

```text
docker run -p 8888:8888 jupyter/minimal-notebook
                |    |
                |    \---------- Puerto del contenedor
                \--------------- Puerto del host
```

También podemos asignar rangos de puertos:
 ```bash
 docker run -p 8000-9000:8000-9000 jupyter/minimal-notebook
```

No siempre es necesario usar el mismo puerto que usa el contenedor

 ```bash
 docker run -p 8001:8000 container1
 docker run -p 8002:8000 container2
```

Estos dos contenedores usan internamente el puerto 8000. Para evitar que choquen entre sí, mapeamos el puerto 8001 para el primer contenedor y el 8002 para el segundo.

## Redes

También podemos conectar un contenedor a la red.

Hay una red por defecto (bridge) con la que podemos conectar varios contenedores entre sí, siempre que conozcamos las IPs, o los nombres de los contenedores:

```
docker run -d --name web1 nginx
docker run -d --name web2 nginx
```

Podemos ver los atributos con `docker inspect <<nombre_contenedor>>`. Nos interesa la dirección ip:
```bash
$ docker inspect web2 | grep IP
"IPAddress": "172.17.0.44"
```

Desde el contenedor web1 podemos hacer un curl a la ip del contenedor2

Podemos crear redes personalizadas con `docker network create` y conectar contenedores a la red con la opción `--network` del comando `docker run`.

Esto puede ser muy útil si no queremos exponer servicios fuera del contenedor; pero necesitamos que los contenedores se hablen entre sí.

### Conexión a la red del host

Si queremos ejecutar un contenedor y exponer _todos_ sus servicios a la red podemos exponerlo a la red del host usando la red `network`:

```bash
$ docker run --network host <<container>>
```
Esto expone todos los servicios hacia la red del host. El conenedor queda expuesto hacia el exterior (más tarde veremos porqué no es *tan* buena idea).
