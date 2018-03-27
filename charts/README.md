# Drone

[Drone](https://drone.io) is an open source Continuous Delivery platform that automates your testing and release workflows.

## Introduction

This chart bootstraps a single node Drone server and agent deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.9+ with RBAC Authentication enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

Prior to running helm commands, create a `secrets/` directory inside `charts/`, and set secrets as follows:
```secret-name.toml```
You can then reference them in manifests via `secretKeyRef`'s set to the secrets file name.

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/mysql
```

The command deploys MySQL on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

By default a random password will be generated for the root user. If you'd like to set your own password change the mysqlRootPassword
in the values.yaml.

You can retrieve your root password by running the following command. Make sure to replace [YOUR_RELEASE_NAME]:

    printf $(printf '\%o' `kubectl get secret [YOUR_RELEASE_NAME]-mysql -o jsonpath="{.data.mysql-root-password[*]}"`)

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the MySQL chart and their default values.

| Parameter                            | Description                               | Default                                              |
| ------------------------------------ | ----------------------------------------- | ---------------------------------------------------- |
| `namespace`                           | Namespace to deploy drone to                  | Drone                                 |
| `server.image`                       | Image to use for Drone's server              | `drone`                                       |
| `server.imageTag`                  | Drone-server image version            | `nil`                                                |
| `server.imageRegistry`                          | Docker registry to pull from          | `nil`                                                |
| `server.admin`                      | Registered github administrators              | `nil`            |
| `server.debug`                      | Debug mode          | `nil`              |
| `server.resources`                          | CPU/Memory resource requests/limits       | Memory: `256Mi`, CPU: `100m`  |
| `db.driver`  | Delay before liveness probe is initiated  | 30             |
| `db.source`        | How often to perform the probe            | 10                                                   |
| `db.conf.name`       | When the probe times out                  | 5                                                    |
| `db.conf.mountPath`     | Minimum consecutive successes for the probe to be considered successful after having failed. | 1 |
| `agent.image`     | Image to use for Drone's agent    | 3 |
| `agent.imageTag` | Drone-agent image tag | 5     |
| `agent.imageRegistry`       | Docker registry to pull from             | 10     |
| `agent.replicas`      | How many agent replicas show run                | 1             |
| `agent.procs.max`    | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | 3 |
| `agent.keepalive.time`                | Create a volume to store data             | true |
| `agent.keepalive.timeout`                   | Size of persistent volume claim           | 8Gi RW  |
| `agent.healthCheck`           | Enabled gRPC healthchecking         | nil  (uses alpha storage class annotation)  |
| `agent.debug.enabled`             | Debug mode               | ReadWriteOnce   |
| `agent.debug.pretty`          | Pretty logs      | `nil`   |
| `agent.resources`                          | CPU/Memory resource requests/limits       | Memory: `256Mi`, CPU: `100m`  |
| `dind.mountPath`                | Path to docker daemon to expose      | `nil`  |
| `gitea.enabled`                 | List of mysql configuration files         | `nil`      |
| `gitea.url`                | Subdirectory of the volume to mount       | `nil`  |
| `gitea.skip.verify`                          | CPU/Memory resource requests/limits       | Memory: `256Mi`, CPU: `100m`  |
| `persistence.enabled`                 | Whether to enable persistence via a `pvc`        | `nil`      |
| `persistence.accessMode`                | Subdirectory of the volume to mount       | `nil`  |
| `persistence.size`                          | Size of persistent storage       | Memory: `256Mi`, CPU: `100m`  |
| `configurationFiles`                 | List of mysql configuration files         | `nil`      |
Some of the parameters above map to the env variables defined in the [MySQL DockerHub image](https://hub.docker.com/_/mysql/).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set mysqlRootPassword=secretpassword,mysqlUser=my-user,mysqlPassword=my-password,mysqlDatabase=my-database \
    stable/mysql
```

The above command sets the MySQL `root` account password to `secretpassword`. Additionally it creates a standard database user named `my-user`, with the password `my-password`, who has access to a database named `my-database`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/drone
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The [Drone](https://hub.docker.com/_/mysql/) image stores data and configurations at the `/var/lib/drone` path of the container.

By default a PersistentVolumeClaim is created and mounted into that directory. In order to disable this functionality
you can change the values.yaml to disable persistence and use an emptyDir instead.

> *"An emptyDir volume is first created when a Pod is assigned to a Node, and exists as long as that Pod is running on that node. When a Pod is removed from a node for any reason, the data in the emptyDir is deleted forever."*
