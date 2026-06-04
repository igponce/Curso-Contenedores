# Kubernetes: Secrets y configmaps

¿Cómo configuramos los contenedores que ejecutan nuestras aplicacioens en Kubernetes?

Además de usando variables de entorno, tenemos otras dos opciones que nos permiten configurar con precisión las aplicaciones, y ocultar datos sensibles como contraseñas o tokens que nunca deben ser expuestos.

## Cómo configurar nuestros contenedores

Caso real: configuración de nginx en un contenedor de Kubernetes.

Supongamos que tenemos un contenedor de nginx que queremos configurar con un archivo `nginx.conf` a medida (o varios)

¿¿Cómo podemos inyectar la configuración de nginx en el contenedor de Kubernetes??

Tenemos varias opciones:
1, Crear un contenedor a medida con la configuración que queremos.
2. Utilizar un volumen 
3. Utilizar un ConfigMap

Crear un contenedor a medida es sencillo. Nos permite replicar todo en desarrollo independientemente de cómo ejecutemos el contenedor (docker, docker-compose, kubernetes...)

Utilizar un volumen es más flexible, ya que nos permite compartir configuraciones entre contenedores y pods; sin embargo si le pasa algo a ese volumen, o si falla el fichero, el contenedor no se ejecutará correctamente.
Esta es una buena opción en desarrollo para arrancar y parar rápidamente el contenedor; sin embargo en producción tiene un problema: *FALTA TRAZABILIDAD*.

Si queremos que nuestros sistemas estén certificados con normativa NIS2 o ENS, necesitamos una forma de mantener la configuración separada del código y de los contenedores.

La opción que nos permite esto es utilizar un ConfigMap.

# ¿Qué es un ConfigMap?

Un ConfigMap es un objeto de Kubernetes (como un Pod, un Secret, un Volumen...).

Lo podemos definir con un manifest que contenga la información  de configuración que necesita el contenedor que vamos a usar (en el mundo Java sería un fichero .properties, ficheros .ini en windows/net, .toml / .yaml etc...)

El contenido de un ConfigMap son tuplas clave/valor.

Por ejemplo este sería un ConfigMap con la configuración de un servidor Nginx:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    << contenido del fichero nginx.conf >>
```

(Algunas cosas como el servidor nginx necesitan muchos ficheros de configuración como `default`, `sites-available/<<sitename>>`, `sites-enabled/<<sitename>>`. Podemos definir el contenido de estos ficheros en el ConfigMap=

Una vez creado el ConfigMap, podemos usarlo en un contenedor.
Podemos montarlo como un volumen, o para poblar una variable de entorno.

**Demo** Crear un configmap, y montarlo como un archivo

Fichero: [`configmap-volume.yaml`](/ejercicios_resueltos/k8s_manifests/volumes-configmaps.yaml)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: log-config
data:
  log_level.conf: |
    # Podemos montar un configmap como volumen
    log_level=INFO
---
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume
spec:
  containers:
    - name: test
      image: busybox
      command:
        [
          "sh",
          "-c",
          'echo "Contenido de del volumen:" && ls -al /etc/config && tail -f /dev/null',
        ]
      volumeMounts:
        - name: config-vol
          mountPath: /etc/config/log_level
  volumes:
    - name: config-vol
      configMap:
        name: log-config
        items:
          - key: log_level.conf
            path: log_level.conf
```

## Creación de ConfigMaps desde `kubectl`

Podemos crear de forma imperativa el ConfigMap usando kubectl:

El origen puede ser un archivo local, o desde líneas de comandos.

```bash
kubectl create configmap nombre --from-literal=clave=valor 
```

```bash
kubectl create configmap nombre --from-file=archivo
```

O desde un fichero de entorno:

```bash
kubectl create configmap configmap-from-env --from-env-file=configmap-sample.env
```

**DEMO**: Creamos el ConfigMap desde un fichero de entorno y vemos el contenido con `kubectl inspect`

## Secrets

¿Qué es un Secret en Kubernetes?

Un Secret es un objeto que contiene datos sensibles, como contraseñas, tokens o certificados.

La ventaa de usar secrets es que los valores están codificados (no cifrados) y se decodifican dentro de los contenedores - a los que los usuarios no tienen acceso directo

Se puede crear mediante un manifest o por línea de comandos.

Para crearlo de forma imperativa usamos `kubectl create secret`.

```
kubectl create secret generic mbit-secret-key --from-literal=mbit-secret-password=nolodigas
```

## Uso de Secrets

En los pods que hemos desplegado hasta ahora hemos usado variables de entorno
para almacenar información sensible, como contraseñas en los contenedores.

¿ Cómo podemos hacerlo usando secrets?

*DEMO* Configurar clave root de postgres con un secret

En primer lugar necesitamos crear un secret con la clave root de postgres:
```
kubectl create secret generic postgres-root-password --from-literal=clave-root=laclave
```

Una vez creada el secret, podemos inyectarlo en un pod usando `secretKeyRef`:

```
apiVersion: v1
kind: Secret
metadata:
  name: postgres-root-password
type: Opaque
data:
  clave-root: esaclave
---
apiVersion: v1
kind: Pod
metadata:
  name: postgres
spec:
  containers:
    - name: postgres
      image: postgres:latest
      env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-root-password <---- Nombre del secret               key: key: clave-root <--- Clave dentro del secret (como en un configMap clave:valor)
```

## Otras formas de gestionar secrets

### SOPS

SOPS (Secret Operations) es una herramienta que permite cifrar y desencriptar valores confidenciales en Kubernetes.

El objetivo de SOPS es permitir almacenar de forma segura el contenido de los manifest de kubernetes en un control de versiones, sin que ello comprometa la seguridad de un cluster.

### Secrets managers de Cloud

Hay productos en la nube que ofrecen gestores de secretos, como AWS Secrets Manager, Azure Key Vault, GCP Secrets Manager...

Para acceder a los secretos tenemos que estar autenticados en la nube, y tener permiso para leerlos.

La idea es que hay un usuario (no asociado a una persona; sino una service account) que tiene permiso para leer esta información.

Kubernetes usa ese usuario (junto con un plugin del Cloud Provider) para acceder a los secretos en la nube.
