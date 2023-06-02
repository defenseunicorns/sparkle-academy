# Ingress Mini Project Solutions

This section offers one of many possible solution to the mini projects in the ingress section.  There are several mini projects in this section, this doc will step through each of them.

# Different Ingress Controller in K3d/Kind

The cluster type this section will be working with is K3d.

The ingress controller chosen for this is HAProxy (among [many](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) that would work).  First step, is to work out how to deploy a K3d cluster without the default Traefik ingress controller.  K3d can take arguments on the CLI in order to influence how a cluster is deployed.  Those arguments can also be captures in a configuration file and passed to the `k3d cluster create` command as an argument.  The cluster for this solution will be spun up using the config file called `k3d_no_traefik_cluster.yaml` in this directory:

```bash
$  k3d cluster create --config k3d_no_traefik_cluster.yaml 
```

## Ingress Controller Installation

Again, HAProxy was the ingress controller selected for this mini project.  The easiest way to install the ingress controller is via Helm.  An ingress controller requires multiple objects in a cluster in order to function properly.  Helm can install/remove all of them at once ([docs for the HAProxy Helm Repo](https://haproxy-ingress.github.io/docs/getting-started/)).

1. Add the HAProxy Helm repo and update

```bash 
$ helm repo add haproxytech https://haproxytech.github.io/helm-charts
$ helm repo update
```

Running `helm search repo <STRING>` will search Helm charts and may help get the exact name of a chart:

```bash
$ helm search repo haproxy
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
haproxytech/haproxy             1.19.0          2.7.5           A Helm chart for HAProxy on Kubernetes            
haproxytech/kubernetes-ingress  1.30.5          1.10.2          A Helm chart for HAProxy Kubernetes Ingress Con...
```

Let's now install the chart:

```bash
$ helm upgrade -i haproxy haproxytech/kubernetes-ingress
```

Note, the `helm install` command would have worked just as well here.  This syntax using `upgrade -i` is more common in automation workflows as it will either install the chart if it does not exist or upgrade it if it does.  It's also possible to view all of the objects that this chart will deploy by either pulling the chart down or templating it locally via the `haproxy haproxytech/kubernetes-ingress` command.

Running `kubectl get pod` now will show that an Nginx ingress controller pod is running.

```bash
$ kubectl get pod | grep haproxy
haproxy-kubernetes-ingress-6ff9b75bf9-d5cr2    1/1     Running   0          51m
haproxy-kubernetes-ingress-6ff9b75bf9-p9hqh    1/1     Running   0          51m
```

One of the objects that was deployed as part of the chart was a service:

```bash
$ kubectl get svc | grep haproxy
haproxy-kubernetes-ingress    NodePort       10.43.196.178   <none>        80:30645/TCP,443:31655/TCP,1024:32363/TCP   52m
```

Traffic needs to be directed to `haproxy-kubernetes-ingress` service in order for this ingress controller to make any forwarding decisions (keep this in mind for later).

The next step is to deploy some type of application that can be used by the ingress controller.  