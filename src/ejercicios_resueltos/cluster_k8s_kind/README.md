# Creacion de un cluster Kubernetes con Kind

```bash
kind create cluster --config .\kind_config.yaml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.35.0) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂```
{!kind_config.yaml!}

Una vez creado el cluster, necesitamos el fichero de configuración para que kubectl pueda interactuar con el cluster.

```bash
kind get kubeconfig --name kind > kubeconfig.yaml
```
