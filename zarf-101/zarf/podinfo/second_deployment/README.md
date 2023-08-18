# Introduction
The purpose of this folder is to capture the work in order to update a zarf package to deploy the [podinfo](https://github.com/stefanprodan/podinfo) application with a new version and additional replicas.

# Getting Started
The first update of the version change is straight forward, just changing the version on the chart and the image:

```yaml
kind: ZarfPackageConfig
metadata:
  name: podinfo
  description: "Deploy helm chart for the podinfo application in K8s via zarf"

components:
  - name: podinfo
    required: true
    charts:
      - name: podinfo
        version: 6.4.1
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
    images:
      - ghcr.io/stefanprodan/podinfo:6.4.1
```

The replicas part will take a little more digging.  In the values.yaml for the podinfo chart, [line three](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/values.yaml#L3) is a "replicaCount" and that looks like exactly what is needed here.  Based on the [zarf package schema](https://docs.zarf.dev/docs/create-a-zarf-package/zarf-schema), the `charts` key also supports a `valuesFile`.  Copying line 3 from the values file and updating it to three replicas will update the zarf package to the new version and up the replicaCount of the podinfo container to 3.  Zarf expects to reference any values files off of the local file system relative to the zarf.yaml file.

```yaml
kind: ZarfPackageConfig
metadata:
  name: podinfo
  description: "Deploy helm chart for the podinfo application in K8s via zarf"

components:
  - name: podinfo
    required: true
    charts:
      - name: podinfo
        version: 6.4.1
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
        valuesFiles:
          - podinfo-values.yaml
    images:
      - ghcr.io/stefanprodan/podinfo:6.4.1

```

The podinfo-values.yaml file contains an update to the replicaCount:

```yaml
# Custom values for podinfo.

replicaCount: 3
```

Since the namespace and releaseName are the same, the package previously deployed will be updated in place.

Sweet, the release now has three pods but how can it be confirmed that the rest of the values file bundled with the chart was honored?  The `helm get values` command looks perfect for this:

```
[rmengert@Robs-MacBook-Pro:~/projects/sparkle-academy/zarf-101/zarf]
$ helm get values -n podinfo-helm-namespace zarf-podinfo
USER-SUPPLIED VALUES:
replicaCount: 3
[rmengert@Robs-MacBook-Pro:~/projects/sparkle-academy/zarf-101/zarf]
$
```

Hmm, nothing else displayed.  The `-a` flag to this command will show all values used by the release and not just the user supplied ones:

```
[rmengert@Robs-MacBook-Pro:~/projects/sparkle-academy/zarf-101/zarf]
$ helm get values -a -n podinfo-helm-namespace zarf-podinfo
COMPUTED VALUES:
affinity: {}
backend: null
backends: []
cache: ""
certificate:
  create: false
  dnsNames:
  - podinfo
  issuerRef:
    kind: ClusterIssuer
    name: self-signed
faults:
  delay: false
  error: false
  testFail: false
  testTimeout: false
  unhealthy: false
  unready: false
h2c:
  enabled: false
host: null
hpa:
  cpu: null
  enabled: false
  maxReplicas: 10
  memory: null
  requests: null
image:
  pullPolicy: IfNotPresent
  repository: ghcr.io/stefanprodan/podinfo
  tag: 6.4.1
ingress:
  annotations: {}
  className: ""
  enabled: false
  hosts:
  - host: podinfo.local
    paths:
    - path: /
      pathType: ImplementationSpecific
  tls: []
linkerd:
  profile:
    enabled: false
logLevel: info
nodeSelector: {}
podAnnotations: {}
probes:
  liveness:
    failureThreshold: 3
    initialDelaySeconds: 1
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  readiness:
    failureThreshold: 3
    initialDelaySeconds: 1
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
redis:
  enabled: false
  repository: redis
  tag: 6.0.8
replicaCount: 3
resources:
  limits: null
  requests:
    cpu: 1m
    memory: 16Mi
securityContext: {}
service:
  annotations: {}
  enabled: true
  externalPort: 9898
  grpcPort: 9999
  grpcService: podinfo
  hostPort: null
  httpPort: 9898
  metricsPort: 9797
  nodePort: 31198
  type: ClusterIP
serviceAccount:
  enabled: false
  imagePullSecrets: []
  name: null
serviceMonitor:
  additionalLabels: {}
  enabled: false
  interval: 15s
tls:
  certPath: /data/cert
  enabled: false
  hostPort: null
  port: 9899
  secretName: null
tolerations: []
ui:
  color: '#34577c'
  logo: ""
  message: ""
[rmengert@Robs-MacBook-Pro:~/projects/sparkle-academy/zarf-101/zarf]
$ 
```

Huzzah!  That matches up with the [values.yaml file in the podinfo repo](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/values.yaml).
