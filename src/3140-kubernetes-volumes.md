# Volúmenes y almacenamiento

Vamos a volver un segundo al pod que tenía wordpress y mysql.
Si recordáis bien ninguno de los dos contenedores tenían ningún volúmen asignado.
Esto quiere decir que los datos ser perderían si el pod muere, o si el contenedor se reinicia (por ejemplo en el caso de que consuma demasiada memora).

Sin embargo en docker y docker-compose podíamos asignar volúmenes a los contenedores para persistir los datos.


En Kubernetes también podemos asignar volúmenes efímeros (`emptyDir`) que se eliminan cuando el pod muere y persistentes (`PersistentVolume`/`PersistentVolumeClaim`) que se mantienen aunque el pod se reinicie.

## ¿ Cómo se define un volumen?

Los volúmenes se definen en un manifest de Kubernetes.
Podemos tenerlos en el *spec* de un pod o en un *PersistentVolume*.

Una vez definido un volumen, se los podemos asignar a un contenedor.

**OJO**os volúmenes no se asignan a *PODs* : se asignan a *containers*. Igual que en docker y docker-compose.

## Creación de un volumen efímero (`emptyDir`)

Los volúmenes efímeros (`emptyDir`) se eliminan cuando el pod muere.

El caso de uso de un `emptyDir` es cuando necesitamos un volumen temporal para almacenar datos que no necesitamos persistir entre reinicios de pods como, por ejemplo, logs o archivos temporales.

PERO si guardamos datos en el filesystem del contendor... también ser eliminarán ¿verdad?
Sí, esos datos se eliminarán cuando el pod se elimine; pero es mejor user un volúmen efímero porque se eliminará automáticamente cuando el pod se elimine, no cuando el contenedor se reicicie.

Un contenedor se puede reiniciar por varios motivos, como una actualización de la imágen, un error en la aplicación, o usa más memoria de la que tiene asignada. En esos casos el volumen efímero seguirá existiendo y los datos no se perderán.

## Volúmenes persistentes (`PersistentVolume`/`PersistentVolumeClaim`)

Los volúmenes persistentes se mantienen aunque el pod se elimine.
Los datos almacenados en el volumen persistente se mantienen incluso si el pod se elimina y se vuelve a crear.

Los PersistentVolumeClaims (PVC) son objetos de kubernetes que asocan un volumen persistente con un pod.

Cuando se crea un PVC, Kubernetes busca un PersistentVolume que coincida con las especificaciones del VolumeClaim y lo asocia.

## Cómo crear un persistentVolume y un persistentVolumeClaim en el clúster

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: 
spec:
  accessModes:
    - ReadWriteOnce <--- Cómo accedr
  capacity:
    storage: 1Gi
  storageClassName: standard  <---- Esto es importante
  ...
```

¿Qué es el storageClassName y porqué es importante?

Esto depende de la configuración del cluster y plugins de almacenamiento instalados.
Por ejemplo, si tenemos un cluster en AWS el storageClassName `standard` se refiere a un volumen EBS estándar; pero tenemos otros tipos de volúmenes disponibles como `gp2` (volumen EBS generalizado) o `gp3` (volumen EBS de alto rendimiento).

Para usar gp3, simplemente cambiamos el storageClassName

Hay que tener cuidado con el tipo de storageClass que usamos. Los precios del gp3, gp3, io1, etc varían: Consulta la [página de precios de AWS EBS](https://aws.amazon.com/es/ebs/pricing/) antes de configurar un storageClass.

Si tenemos un filer NAS (NetAPP/EMC/o similar), también podemos usar un `PersistentVolume` de tipo `NFS` para montar el almacenamiento persistente en el clúster.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 1Gi
  storageClassName: standard
  nfs:
    path: /exports
    server: filer.nas.local
```

## Cómo montar el volumen en un Pod

Para montar el volumen en un Pod, necesitamos asociar el volumen con el contenedor usando la sección `volumeMounts` en la especificación del contenedor.

Pero primero tenemos que crear un PVC para solicitar el almacenamiento:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pgsql-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: default
```

Y después ya podemos crear el Pod que usa el PVC:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres
spec:
  containers:
    - name: pg
      image: postgres:latest
      volumeMounts:
        - name: pgsql-data
          mountPath: /var/lib/postgresql/data
  volumes:
    - name: pgsql-data
      persistentVolumeClaim:
        claimName: pgsql-data-pvc
  storageClassName: de
```

Si creamos el Pod antes de que el PVC esté disponible, el Pod se quedará en estado `Pending` hasta que el PVC se asocie con un PV.
