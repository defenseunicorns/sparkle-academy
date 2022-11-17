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
        version: 6.2.3
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
    images:
      - ghcr.io/stefanprodan/podinfo:6.2.3
```

The replicas part will take a little more digging.  In the values.yaml for the podinfo chart, [line three](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/values.yaml#L3) is a "replicaCount" and that looks like exactly what is needed here.  Based on the [zarf package schema](https://docs.zarf.dev/docs/user-guide/zarf-schema), the `charts` key also supports a `valuesFile`.  Copying line 3 from the values file and updating it to three replicas will update the zarf package to the new version and up the replicaCount of the podinfo container to 3.  Zarf expects to reference any values files off of the local file system relative to the zarf.yaml file.

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
        version: 6.2.3
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
        valuesFiles:
          - podinfo-values.yaml
    images:
      - ghcr.io/stefanprodan/podinfo:6.2.3

```

The podinfo-values.yaml file contains an update to the replicaCount:

```yaml
# Custom values for podinfo.

replicaCount: 3
```

Since the namespace and releaseName are the same, the package previously deployed will be updated in place.