# Arquitectura k8s

![](img/Kubernetes-cluster.excalidraw.png)

## Container Registry
Donde se almacenan las imágenes de contenedor que vamos a desplegar.
Se puede desplegar un contenedor que está en un registry público (basta con tener conectividad);
pero es recomendable publicar en nuestro container registry los contendores que usamos.

¿Qué puede ir mal?

¿Y si no podemos acceeder al registry público?
¿Y si el acceso es muy lento (hay thottling)?
¿Y si el proveedor del contailer lo elimina?

Todo esto nos lo podemos evitar copiando el contenedor a nuestro propio registry:

```bash
# Obtenemos el contenedor que tomamos como base
docker pull <<contenedor_base>>
# Le cambiamos el nombre
docker tag miversion:1.0
docker push miversion:1.0 <<mi-docker-registry.com>>
```

Después podemos construir nuestros containers sin preocuparnos por la disponibilidad del container base.
```dockerfile
FROM mi-docker-reginstry.com/miversion:1.2
...
<<resto>>
...
```
