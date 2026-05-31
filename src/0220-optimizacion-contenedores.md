# Optimización de contenedores

## ¿Por qué optimizar?

Cada vez que utilizamos o construimos un contenedor la imagen resultante viaja por la red, se almacena en disco y tarda un tiempo en construirse. Una imagen inflada innecesariamente ralentiza todo el flujo (tarda más en descargarse y subirse, y ocupa más espacio en disco)

## Cómo optimizar un contenedor

## Imagen base ligera

La elección de la imagen base es el factor que más impacto tiene en el tamaño final.
Si usamos una imagen pequeña, como Alpine, la imagen resultante será más ligera y más rápida.

Ejemplo: Linux

Alpine es una distribución minimalista basada en musl libc y busybox. Sus imágenes pesan ~5 MB, frente a los ~200 MB de las imágenes basadas en Debian:

```dockerfile
FROM alpine:latest
```

Muchas imágenes oficiales ofrecen variantes `-alpine`:

|Nombre | Tamaño |
|-------|--------|
|node:20-alpine       | ~ 50 MB |
|node:20              | ~ 200 MB |
|python:3.12-alpine   | ~ 55 MB |
|python:3.12           | 300 MB|


### Variantes slim

Si Alpine nos resulta demasiado restrictivo (por ejemplo, porque necesitamos glibc), podemos usar las variantes `-slim` de las imágenes oficiales, que eliminan paquetes innecesarios:

```dockerfile
FROM node:20-slim
```

### Distroless

Las imágenes _distroless_ de Google contienen solo la aplicación y sus dependencias de sistema, sin gestor de paquetes, shell ni utilidades:

```dockerfile
FROM gcr.io/distroless/base-debian12
```

Son las más seguras y pequeñas para producción, pero dificultan el debugging porque no hay shell ni ningún software que permita inspeccionar el contenedor.


## Multi-stage builds

Los _multi-stage builds_ permiten usar varias imágenes `FROM` en un mismo `Dockerfile`. La primera etapa compila o descarga dependencias, y la segunda copia solo los artefactos necesarios.

Este es el ejemplo clásico con una aplicación Go:

```dockerfile
# Etapa 1: compilación
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o mi-app .

# Etapa 2: imagen final mínima
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/mi-app /usr/local/bin/
CMD ["mi-app"]
```

La imagen final solo contiene Alpine, los certificados y el binario compilado. El SDK de Go y las dependencias de compilación se quedan en la primera etapa y no ocupan espacio en la imagen final.

## Orden de las instrucciones y caché

Docker crea una capa (_layer_) por cada instrucción del `Dockerfile` y las cachea. Si una instrucción no ha cambiado entre builds, Docker reutiliza la capa cacheada y salta su ejecución.

Para aprovechar bien la caché, debemos ordenar las instrucciones de **menos a más cambiantes**:

```dockerfile
# 1. Lo que casi nunca cambia
FROM node:20-alpine

# 2. Dependencias (cambian con poca frecuencia)
COPY package.json package-lock.json ./
RUN npm ci --production

# 3. Código fuente (cambia en cada commit)
COPY . .

CMD ["node", "index.js"]
```

Si colocamos `COPY . .` antes de instalar dependencias, cada cambio en el código fuente invalidaría la caché de `npm ci` y reinstalaríamos todo cada vez.

### Combinar instrucciones

Cada `RUN` crea una capa adicional. Aunque el número de capas no es crítico, podemos agrupar comandos relacionados en un solo `RUN` para mantener el orden y reducir el número de capas:

```dockerfile
# Menos eficiente: tres capas
RUN apt-get update
RUN apt-get install -y python3
RUN rm -rf /var/lib/apt/lists/*

# Más eficiente: una capa
RUN apt-get update && \
    apt-get install -y python3 && \
    rm -rf /var/lib/apt/lists/*
```

## .dockerignore

Por defecto, `docker build` envía todo el contenido del contexto (el directorio donde ejecutamos `docker build`) al demonio de Docker. Esto incluye `node_modules`, `.git`, entornos virtuales y otros ficheros que no necesitamos.

Creamos un fichero `.dockerignore` para excluirlos:

```text
.git
node_modules
__pycache__
*.log
.env
.vscode
.idea
```

El contexto de construcción será más pequeño, la transferencia al demonio será más rápida y la caché del `COPY . .` se invalidará solo cuando cambie código relevante.

## Capa única para binarios compilados

Si compilamos código, podemos enlazar de forma estática y copiar un solo binario:

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o app .

FROM scratch
COPY --from=builder /app/app /
CMD ["/app"]
```

- `CGO_ENABLED=0`: compilación estática, sin dependencias de C.
- `-ldflags="-s -w"`: elimina símbolos de depuración y tabla de cadenas (reduce el binario).
- `FROM scratch`: imagen vacía, solo contiene nuestro binario.

El resultado puede ser una imagen de menos de 10 MB.
