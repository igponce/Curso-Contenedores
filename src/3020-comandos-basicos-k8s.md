# Comandos básicos

** ANTES DE EMPEZA ** Necesitamos crear un cluster.

Vamos a crear un [cluster local con kind](ejercicios_resueltos\cluster_k8s_kind\README.md).

# kubectl

Esta es la herramienta principal para interactuar con Kubernetes.

Se usa PARA TODO.

Está incluida en Docker Desktop :-)

Si no tienes Docker Desktop, puedes instalar `kubectl` separadamente siguiendo las instrucciones en [la documentación oficial](https://kubernetes.io/docs/tasks/tools/).

# Información del cluster

```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:54387
CoreDNS is running at https://127.0.0.1:54387/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
Esto nos da información sobre el estado del cluster. El plano de control está funcionando y tenemos el CoreDNS activo.

## Información de nodos (get nodes)

```bash
# Ver nodos
$ kubectl get nodes
```

Esto nos da una lista de los nodos en el cluster.
Nos dice si el nodo está listo (Ready) o no para aceptar cargas de trabajo.

Podemos verlo con más detalles usando `-o wide`:
```bash
$ kubectl get nodes -o wide
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                      CONTAINER-RUNTIME
kind-control-plane   Ready    control-plane   41m   v1.35.0   172.19.0.3    <none>        Debian GNU/Linux 12 (bookworm)   6.6.114.1-microsoft-standard-WSL2   containerd://2.2.0
kind-worker          Ready    <none>          41m   v1.35.0   172.19.0.2    <none>        Debian GNU/Linux 12 (bookworm)   6.6.114.1-microsoft-standard-WSL2   containerd://2.2.0
```

## Vamos a lanzar una carga en el cluster

```bash
kubectl run nginx --image=nginx
              ^            ^
              |            \- imagen a usar
              \- nombre del Pod
```

Esto crea un Pod llamado `nginx` que corre la imagen `nginx`.

Podemos ver el estado del Pod con `kubectl get pods`.

Esto nos da información; pero a lo mejor no es suficiente.

¿Qué ocurre si ejecutarmos `kubectl describe pods nginx`?

```bash
kubectl describe pod nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             kind-worker/172.19.0.2
Start Time:       Mon, 01 Jun 2026 21:53:02 +0200
Labels:           run=nginx
Annotations:      <none>
Status:           Running
IP:               10.244.1.3
IPs:
  IP:  10.244.1.3
Containers:
  nginx:
    Container ID:   containerd://13a2ce7b18ee7ba4868ed69c1f1277258be0eaf8e2c319068ab361b4f5d1035e
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:5aca99593157f4ae539a5dec1092a0ad8762f8e2eb1789085a13a0f5622369f6
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 01 Jun 2026 21:53:09 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8bhjr (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-8bhjr:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  41m   default-scheduler  Successfully assigned default/nginx to kind-worker
  Normal  Pulling    41m   kubelet            Pulling image "nginx"
  Normal  Pulled     41m   kubelet            Successfully pulled image "nginx" in 6.776s (6.776s including waiting). Image size: 63120520 bytes.
  Normal  Created    41m   kubelet            Container created
  Normal  Started    41m   kubelet            Container started
  ```

## Información de Pods (get pods)
```bash
# Ver todos los Pods del cluster
kubectl get pods --all-namespaces
```
¿Porqué ponemos `--all-namespaces`?

##  Namespaces

Un _namespace_ es una agrupación lógica de recursos. Como "carpetas" dentro del cluster.

En el cluster podemos usar 'namespaces' para organizar los recursos en distintos grupos. 
De estas manera podemos manipular los recursos de forma más sencilla.

Imagina que tienes unos webservices de autenticación. Si quieres separar estos servicios de los demás puedes crear un namespace para ellos y colocar ahí los recurseos que necesiten.

Estos son los namespaces preconfigurades en k8s:
- `default`: Namespace por defecto
- `kube-system`: Namespace para los componentes del sistema. ¡Aquí no se instala nada!
- `kube-public`: El contenido de este namespace es público y accesible para todos los usuarios, aunque no estén autenticados.
- `kube-node-lease`: Namespace para objetos Lease (se usan para enviar heartbeats, elección de nodos maestros, etc.)


Listar los namespaces en el cluster:
```bash
kubectl get namespaces
```
Crear un namespace:
```bash
kubectl create namespace mbit
``` 

## 1.6 Contextos y kubeconfig (10 min) 🆕

| Sub-tema | Detalle | Tiempo |
|---|---|---|
| ¿Qué es un contexto? | Cluster + usuario + namespace. Todo en uno | 3 min |
| El archivo `~/.kube/config` | Estructura: clusters, users, contexts | 3 min |
| `kubectx` | Cambiar entre local (minikube) y AWS (EKS) | 2 min |
| Caso práctico | Alternar entre cluster de desarrollo local y cluster de producción en AWS | 2 min |


---
# Referencias
- [Kubernetes Components — Documentación oficial](https://kubernetes.io/docs/concepts/overview/components/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
