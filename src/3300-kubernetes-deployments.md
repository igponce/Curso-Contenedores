# Desplegar una aplicación en Kubernetes

Hasta ahora hemos levantados los pods uno a uno.
Esto es muy tedioso, puede lleva a errores y no es escalable.
Tiene que haber una forma más fácil de deplegar aplicaciones.

# Cómo escalar una aplicación

Si llegan más peticiones las que podemos atender tenemos que ser capaces
de lanzar varias réplicas de nuestra aplicación.
Como mínimo, lanzaremos réplicas de los pods "frontales" que son los
que reciben estas cargas.

## ReplicaSets

Un ReplicaSet es un recurso de Kubernetes que asegura que N réplicas
de un Pod estén corriendo siempre.
Si un que pertenece a un ReplicaSet Pod muere, lo recrea automáticamente.

Veamos un ejemplo de cómo crear un ReplicaSet (usando un container de BusyBox para que no consuma recursos):

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: sleeper-rs
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sleeper-APP
  template:
    metadata:
      labels:
        app: sleeper-APP
    spec:
      containers:
        - name: busybox
          image: busybox
          command:
            [
              "sh",
              "-c",
              "while true; do echo '$(hostname) - $(date)'; sleep 13; done",
            ]

```

**DEMO** 
 - Cuántos pods se crean automáticamente.
 - ¿Qué ocurre si eliminamos un pod?
 - ¿Qué ocurre si MODIFICAMOS el ReplicaSet?
    - Aumentamos a 4 las réplicas
    - Modificamos el Pod template
  - ¿Qué pasa si eliminamos un nodo?

  # Deployments

  Un Deployment es un recurso de Kubernetes que gestiona el despliegue de una aplicación.
  Añade funcionalidades al ReplicaSet.

  Imagína este escenario:

  Tenemos una aplicación que se despliega en varios pods.
  Necesitamos actualizar la aplicación (cambiar la imagen, añadir configuración, etc.).
  ¿Qué ocurriría con un ReplicaSet?

  Con un *_deployment_* podemos actualizar la aplicación sin que deje de dar servicio.
  El deployment se encarga de gestionar las réplicas, y cómo se actualizan los pods.

  Veamos un ejemplo de cómo crear un Deployment (también con BusyBox):

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: sleeper-deployment
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: sleeper2-APP
    template:
      metadata:
        labels:
          app: sleeper-APP
      spec:
        containers:
          - name: busybox
            image: busybox:1.35
            command:
              [
                "sh",
                "-c",
                "while true; do echo '$(hostname) - $(date)'; sleep $(SLEEP_DURATION; done",
              ]
        env:
          - name: SLEEP_DURATION
            value: "13"
  ```

¿Qué ha cambiado respecto al ReplicaSet?

Aparentemente nada, excepto que el sleep_duration ahora es configurable con una variable de entorno.

*PRUEBAS*:
 - ¿Qué ocurre si actualizamos la configuración de la aplicación en el Deployment?
 - ¿Qué ocurre si actualizamos la imagen de la aplicación en el Deployment?


##Rolling updates

Para cambiar poco a poco los pods, Kubernetes actualiza los pods uno a uno, manteniendo siempre al menos una réplica disponible.

Para configurar el tiempo de espera entre actualizaciones, podemos usar el campo `spec.strategy.rollingUpdate.maxSurge` y `spec.strategy.rollingUpdate.maxUnavailable`.

`maxSurge` nos permite definir cuántos pods pueden ser creados por encima del número deseado antes de que se actualicen.

`maxUnavailable` nos permite definir cuántos pods pueden ser eliminados antes de que se actualicen.

Los dos parámetros `maxSurge` y `maxUnavailable` nos permiten usar un número, o un % que se calcula en función del número de pods que tiene el deployment en el momento de la actualización.

# ¿Cómo dar marcha atrás? -> kubectl rollout

kubectl rollout undo deployment/sleeper-deployment --to-revision=
