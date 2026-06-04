# Pods - puertos y servicios

# Exponer puertos

Para exponer un puerto de un contenedor en un pod, podemos usar la clave `ports` en la especificación del contenedor.

**OJO** Los puertos que ese exponen son puertos accesibles desde fuera del pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wordpress-standalone
spec:
  containers:
    - name: wp
      image: wordpress:latest
      ports:
        - containerPort: 80
    - name: mysql
      image: mysql:latest
      ports:
        - containerPort: 3306
```

Vamos a ver un ejemplo con dos pods:

```yaml
apiVersion: v1
kind: Pod
metadata:
  app: blog
  name: wp-pod
spec:
  containers:
    - name: wp
      image: wordpress:latest
      ports:
        - containerPort: 80
      env:
        - name: WORDPRESS_DB_HOST
          value: mysql-pod
        - name: WORDPRESS_DB_PASSWORD
          value: secret
        - name: WORDPRESS_DB_USER
          value: wp
        - name: WORDPRESS_DB_NAME
          value: wp
--
apiVersion: v1
kind: Pod
metadata:
  app: blog
  name: mysql-pod
spec:
  containers:
    - name: mysql
      image: mysql:latest
      ports:
        - containerPort: 3306
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: secret
        - name: MYSQL_DATABASE
          value: wp
        - name: MYSQL_USER
          value: wp
        - name: MYSQL_PASSWORD
          value: secret
```

Al exponer los puertos podemos acceder a los servicios desde fuera del...
- [ X ] POD
- [ ] Cluster

# TODO: Servicios
# TODO: Ingress
