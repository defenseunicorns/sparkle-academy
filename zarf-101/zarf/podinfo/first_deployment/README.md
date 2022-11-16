# Introduction
The purpose of this folder is to capture the work in order to create a zarf.yaml file to deploy the [podinfo](https://github.com/stefanprodan/podinfo) application.

# Getting Started
A large chunk of the [games zarf.yaml](https://github.com/defenseunicorns/zarf/blob/master/examples/game/zarf.yaml) can be copied:

```yaml
kind: ZarfPackageConfig
metadata:
  name: dos-games
  description: "Simple example to load classic DOS games into K8s in the airgap"

```

Becomes:

```yaml
kind: ZarfPackageConfig
metadata:
  name: podinfo
  description: "Deploy helm chart for the podinfo application in K8s via zarf"
```

The components section requires a little more thought.  With the contraint of using a helm chart, there are some options to how the chart can be referenced.  Note that the [podinfo repo](https://github.com/stefanprodan/podinfo) also has a "[charts](https://github.com/stefanprodan/podinfo/tree/master/charts)" folder so it is hosting a helm chart for podinfo.  This impacts how the chart is referenced in the zarf.yaml component section.  The latest version of the helm chartas of the time of this writing is 6.2.2 (as denoted by the "version" [here](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/Chart.yaml)) and that also matches the latest release of the [podinfo container image](https://hub.docker.com/layers/stefanprodan/podinfo/6.2.2/images/sha256-857e5d7a3d571c09d1cdba06c90e2ec1dd024f0d357b87781d6d1d86dc922e94?context=explore).

# Components

This zarf.yaml will only have one component comprised of the actual helm chart.  All components require a name and optionally if they are required (meaning that they will be installed without prompting the operator if required is set to true).  That means the zarf.yaml now looks like this:

```yaml
kind: ZarfPackageConfig
metadata:
  name: podinfo
  description: "Deploy helm chart for the podinfo application in K8s via zarf"

components:
  - name: podinfo
    required: true
```

According to the [package schema](https://docs.zarf.dev/docs/user-guide/zarf-schema), the next field required is "charts" in order to specify a Helm chart.  

> **_NOTE:_** On the package schema documentaiton link, expand "components" and then "charts" to see Helm chart related documentation.

Under charts, the required fields are denoted by the asterisks and they are:
 - name
 - version
 - namespace

The name field refers to the name of the Helm chart as defined in the Chart.yaml.  For the [podinfo chart](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/Chart.yaml), this is simply "podinfo".  The version refers to the version of the chart which is also in the Chart.yaml (at the time of this writing, that version was 6.2.2).  The namespace is for the operator to define and this determines the Kubernetes namespace where the chart will be deployed.  Just to make things easy, let's call it "podinfo" as well.  That leaves us with this updated zarf.yaml:

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
        version: 6.2.2
        namespace: podinfo
```

The other fields that will be used here are:
  - url
  - releaseName

While not required, the "url" field will tell zarf where the chart is (localPath is an option to tell Zarf where the chart is as well).  This can be an actual chart repository, like artifacthub or bitnami, or a git URL.  In this case, a chart repository will be used.  A Helm repo is defined in the Github repo [here](https://github.com/stefanprodan/podinfo#helm).  The releaseName refers to the name of the Helm release (see [here](https://helm.sh/docs/intro/using_helm/) for more details on Helm releases).  For this deployment, let's again just call the release podinfo.  Now the zarf.yaml looks like this.

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
        version: 6.2.2
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
```

The last step is telling zarf about the container images that need to be part of the package.  According to the [values file for the podinfo chart](https://github.com/stefanprodan/podinfo/blob/master/charts/podinfo/values.yaml), the container image in question is located at: ghcr.io/stefanprodan/podinfo:6.2.2

The updated zarf.yaml now looks like this:

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
        version: 6.2.2
        namespace: podinfo-helm-namespace
        releaseName: podinfo
        url: https://stefanprodan.github.io/podinfo
    images:
      - ghcr.io/stefanprodan/podinfo:6.2.2
```

> **_NOTE:_** note the indentation of the "images" field.  This indentation corresponds to the [Zarf package schema](https://docs.zarf.dev/docs/user-guide/zarf-schema).
