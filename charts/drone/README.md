# Drone

[Drone](https://drone.io) is an open source Continuous Delivery platform that automates your testing and release workflows.

## Introduction

This chart bootstraps a single node Drone server and agent deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.9+ with RBAC Authentication enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

Prior to running helm commands, create a `secrets/` directory inside `charts/`, and set secrets with this naming scheme:
```secret-name.toml```
with each file containing the associated secret. The Drone token, a required secret, can be generated using the `openssl` tool: ```openssl rand -base64 8 | md5 | head -c8; echo```. Copy the generated string into a file `drone-secret.toml` containing the string. Helm will base64 encode the secret for you on installation.

To install the chart with the release name `drone-ci`:

```bash
$ helm --tiller-namespace tiller-server --tls install --name drone-ci cncd/drone --namespace drone
```

The command deploys Drone on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `drone-ci` deployment:

```bash
$ helm --tiller-namespace tiller-server --tls delete drone-ci
```

The command removes all the Kubernetes components associated with the chart and deletes the release. In order to remove *all* associated manifests (i.e. `ConfigMap`s and `Secret`s), modified the command with the `--purge` flag:

```bash
$ helm --tiller-namespace tiller-server --tls delete --purge drone-ci
```

## Configuration

The following table lists the configurable parameters of the Drone chart and their default values.

| Parameter                             | Description                               | Default                         |
| ------------------------------------  | ----------------------------------------- | --------------------------------|
| `namespace`                           | Namespace to deploy drone to              | drone                           |
| `server.image`                        | Image to use for Drone's server           | `drone`                         |
| `server.imageTag`                     | Drone-server image version                | `0.8`                           |
| `server.imageRegistry`                | Docker registry to pull from              | `drone`                         |
| `server.admin`                        | Registered github administrators          | appleboy                        |
| `server.debug`                        | Debug mode                                | `false`                         |
| `server.open`                         | Set drone open to registration or not     | `true`                          |
| `server.host`                         | Drone server hostname                     | drone.cncd.io                   |
| `server.service.name`                 | Service name for the Drone server         | drone-service                   |
| `server.service.type`                 | Service type for the Drone server         | `LoadBalancer`                  |
| `server.service.httpPort`             | Exposed port for Web UI                   | 8000                            |
| `server.service.grpcPort`             | Exposed port for gRPC calls to clients    | 9000                            |
| `agent.name`                          | Kubernetes name selector for agent        | `drone-agent`                   |
| `agent.image`                         | Image to use for Drone's agent            | `drone-agent`                   |
| `agent.imageTag`                      | Drone-agent image tag                     | `0.8`                           |
| `agent.imageRegistry`                 | Docker registry to pull from              | `drone`                         |
| `agent.replicas`                      | How many agent replicas show run          | 1                               |
| `agent.procs.max`                     | Max processes the agent will run at once  | 3                               |
| `agent.keepalive.time`                | Create a volume to store data             | 1s                              |
| `agent.keepalive.timeout`             | Size of persistent volume claim           | 5s                              |
| `agent.healthCheck`                   | Enabled gRPC healthchecking               | `true`                          |
| `agent.debug.enabled`                 | Debug mode                                | `false`                         |
| `agent.debug.pretty`                  | Pretty logs                               | `true`                          |
| `github.enabled`                      | Enable remote Github integration          | `true`                          |
| `rbac.enabled`                        | Enabled `rbac` permissions                | `true`                          |
| `rbac.serviceAccountName`             | Drone service account name                | `LoadBalancer`                  |
| `db.enabled`                          | Create an external database service       | sqlite3                         |
| `db.driver`                           | Delay before liveness probe is initiated  | sqlite3                         |
| `db.source`                           | How often to perform the probe            | `nil`                           |
| `db.conf.name`                        | When the probe times out                  | drone-server-sqlite-db          |
| `db.conf.mountPath`                   | Path to mount database config to          | /var/lib/drone                  |
| `docker.apiVersion`                   | API Docker daemon to use for execution    | 1.24        |
| `dind.mountPath`                      | Path to docker daemon to expose           | `/var/run/docker.sock`          |
| `gitea.enabled`                       | List of mysql configuration files         | `true`                          |
| `gitea.url`                           | Subdirectory of the volume to mount       | https://try.gitea.io            |
| `gitea.skip.verify`                   | CPU/Memory resource requests/limits       | `true`                          |
| `persistence.enabled`                 | Whether to enable persistence via a `pvc` | `true`                          |
| `persistence.accessMode`              | Subdirectory of the volume to mount       | `ReadWriteOnce`                 |
| `persistence.size`                    | Size of persistent storage                | `8Gi`                           |
| `livenessProbe.httpGet.path`          | List of mysql configuration files         | `nil`                           |
| `livenessProbe.httpGet.port`          | List of mysql configuration files         | `nil`                           |
| `livenessProbe.initialDelaySeconds`   | List of mysql configuration files         | `nil`                           |
| `livenessProbe.periodSeconds`         | List of mysql configuration files         | `nil`                           |
| `resources`                           | CPU/Memory resource requests/limits       | Memory: `256Mi`, CPU: `100m`    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm --tiller-namespace tiller-server --tls install --name drone-ci --set agent.replicas=3 cncd/drone
```

The above command creates a policy creating three replicas of the `drone-agent` deployment.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm --tiller-namespace tiller-server --tls install --name drone-ci -f values.yaml stable/drone
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The [Drone](https://hub.docker.com/drone/drone/) image stores data and configurations at the `/var/lib/drone` path of the container.

By default a PersistentVolumeClaim is created and mounted into that directory. In order to disable this functionality
you can change the values.yaml to disable persistence and use an emptyDir instead.

You must create a persistent disk to pair with the `pvc.yaml` - for example, create a Google Cloud Platform Compute Engine disk:

```bash
$ gcloud compute disks create --size 10GB drone-data
```

> *"An emptyDir volume is first created when a Pod is assigned to a Node, and exists as long as that Pod is running on that node. When a Pod is removed from a node for any reason, the data in the emptyDir is deleted forever."*
