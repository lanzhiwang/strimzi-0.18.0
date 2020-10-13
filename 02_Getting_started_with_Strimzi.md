## [2. Getting started with Strimzi](https://strimzi.io/docs/operators/0.18.0/using.html#getting-started-str)

Strimzi is designed to work on all types of Kubernetes cluster regardless of distribution, from public and private clouds to local deployments intended for development.  Strimzi设计为可在所有类型的Kubernetes集群上工作，无论其分布如何，从公共云和私有云到旨在进行开发的本地部署。

This section describes the procedures to deploy Strimzi on Kubernetes 1.11 and later.  本节介绍了在Kubernetes 1.11和更高版本上部署Strimzi的过程。

> NOTE To run the commands in this guide, your cluster user must have the rights to manage role-based access control (RBAC) and CRDs.

### [2.1. Preparing for your Strimzi deployment](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-tasks-prereqs_str)

This section shows how you prepare for a Strimzi deployment, describing:

- [The prerequisites you need before you can deploy Strimzi](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-prereqs-str)  部署Strimzi所需的先决条件
- [How to download the Strimzi release artifacts to use in your deployment](https://strimzi.io/docs/operators/0.18.0/using.html#downloads-str)  如何下载Strimzi发行工件以在您的部署中使用
- [How to push the Strimzi container images into you own registry (if required)](https://strimzi.io/docs/operators/0.18.0/using.html#container-images-str)  如何将Strimzi容器映像推送到您自己的注册表中（如果需要）
- [How to set up *admin* roles for configuration of custom resources used in deployment](https://strimzi.io/docs/operators/0.18.0/using.html#adding-users-the-strimzi-admin-role-str)  如何设置admin角色以配置部署中使用的自定义资源
- [Alternative deployment options to Kubernetes using *Minikube* or *Minishift*](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-alternatives_str)  使用Minikube或Minishift替代Kubernetes的部署选项

> NOTE To run the commands in this guide, your cluster user must have the rights to manage role-based access control (RBAC) and CRDs.

#### [2.1.1. Deployment prerequisites](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-prereqs-str)

To deploy Strimzi, make sure:

- A Kubernetes 1.11 and later cluster is available
- The `kubectl` command-line tool is installed and configured to connect to the running cluster.

> NOTE Strimzi supports some features that are specific to OpenShift, where such integration benefits OpenShift users and there is no equivalent implementation using standard Kubernetes.  Strimzi支持一些特定于OpenShift的功能，其中这些集成使OpenShift用户受益，并且没有使用标准Kubernetes的等效实现。

##### Alternatives if a Kubernetes cluster is not available

If you do not have access to a Kubernetes cluster, as an alternative you can try installing Strimzi with:

- [*Minikube*](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-kubernetes-str)
- [*Minishift*](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-openshift-str)

#### [2.1.2. Downloading Strimzi release artifacts](https://strimzi.io/docs/operators/0.18.0/using.html#downloads-str)

To install Strimzi, download the release artifacts from [GitHub](https://github.com/strimzi/strimzi-kafka-operator/releases).

Strimzi release artifacts include sample YAML files to help you deploy the components of Strimzi to Kubernetes, perform common operations, and configure your Kafka cluster.

You deploy Strimzi to a Kubernetes cluster using the `kubectl` command-line tool.

> NOTE Additionally, Strimzi container images are available through the [Docker Hub](https://hub.docker.com/u/strimzi). However, we recommend that you use the YAML files provided to deploy Strimzi.

#### [2.1.3. Pushing container images to your own registry](https://strimzi.io/docs/operators/0.18.0/using.html#container-images-str)

Container images for Strimzi are available in the [Docker Hub](https://hub.docker.com/u/strimzi). The installation YAML files provided by Strimzi will pull the images directly from the [Docker Hub](https://hub.docker.com/u/strimzi).

If you do not have access to the [Docker Hub](https://hub.docker.com/u/strimzi) or want to use your own container repository:

1. Pull **all** container images listed here
2. Push them into your own registry
3. Update the image names in the YAML files used in deployment

> NOTE Each Kafka version supported for the release has a separate image.

##### 1、Kafka

###### Namespace/Repository

* docker.io/strimzi/kafka:0.18.0-kafka-2.4.0
* docker.io/strimzi/kafka:0.18.0-kafka-2.4.1
* docker.io/strimzi/kafka:0.18.0-kafka-2.5.0

###### Description

Strimzi image for running Kafka, including:

* Kafka Broker
* Kafka Connect / S2I
* Kafka MirrorMaker
* ZooKeeper
* TLS Sidecars

##### 2、Operator

###### Namespace/Repository

* docker.io/strimzi/operator:0.18.0

###### Description

Strimzi image for running the operators:

* Cluster Operator
* Topic Operator
* User Operator
* Kafka Initializer


##### 3、Kafka Bridge

###### Namespace/Repository

* docker.io/strimzi/kafka-bridge:0.16.0

###### Description

Strimzi image for running the Strimzi kafka Bridge


##### 4、JmxTrans

###### Namespace/Repository

* docker.io/strimzi/jmxtrans:0.18.0

###### Description

Strimzi image for running the Strimzi JmxTrans


#### [2.1.4. Designating Strimzi administrators](https://strimzi.io/docs/operators/0.18.0/using.html#adding-users-the-strimzi-admin-role-str)

Strimzi provides custom resources for configuration of your deployment. By default, permission to view, create, edit, and delete these resources is limited to Kubernetes cluster administrators. Strimzi provides two cluster roles that you can use to assign these rights to other users:  Strimzi提供用于配置部署的自定义资源。 默认情况下，查看，创建，编辑和删除这些资源的权限仅限于Kubernetes集群管理员。 Strimzi提供了两个群集角色，可用于将这些权限分配给其他用户：

- `strimzi-view` allows users to view and list Strimzi resources.
- `strimzi-admin` allows users to also create, edit or delete Strimzi resources.

When you install these roles, they will automatically aggregate (add) these rights to the default Kubernetes cluster roles. `strimzi-view` aggregates to the `view` role, and `strimzi-admin` aggregates to the `edit` and `admin` roles. Because of the aggregation, you might not need to assign these roles to users who already have similar rights.  安装这些角色时，它们将自动将这些权限聚合（添加）到默认的Kubernetes集群角色。 strimzi-view聚合为view角色，strimzi-admin聚合为edit和admin角色。 由于聚合，您可能不需要将这些角色分配给已经具有相似权限的用户。

The following procedure shows how to assign a `strimzi-admin` role that allows non-cluster administrators to manage Strimzi resources.  以下过程显示了如何分配strimzi-admin角色，该角色允许非集群管理员管理Strimzi资源。

A system administrator can designate Strimzi administrators after the Cluster Operator is deployed.  部署集群操作员后，系统管理员可以指定Strimzi管理员。

Prerequisites

- The Strimzi Custom Resource Definitions (CRDs) and role-based access control (RBAC) resources to manage the CRDs have been [deployed with the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str).

Procedure

1. Create the `strimzi-view` and `strimzi-admin` cluster roles in Kubernetes.

   ```shell
   kubectl apply -f install/strimzi-admin
   ```

2. If needed, assign the roles that provide access rights to users that require them.

   ```shell
   kubectl create clusterrolebinding strimzi-admin --clusterrole=strimzi-admin --user=user1 --user=user2
   ```

#### [2.1.5. Alternative cluster deployment options](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-alternatives_str)

This section suggests alternatives to using a Kubernetes cluster.

If a Kubernetes cluster is unavailable, you can use:

- *Minikube* to create a local cluster
- *Minishift* to create a local OpenShift cluster and use OpenShift-specific features

##### [Installing a local Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-kubernetes-str)

The easiest way to get started with Kubernetes is using Minikube. This section provides basic guidance on how to use it. For more information on the tools, refer to the documentation available online.

In order to interact with a Kubernetes cluster the [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) utility needs to be installed.

You can download and install Minikube from the [Kubernetes website](https://kubernetes.io/docs/getting-started-guides/minikube/). Depending on the number of brokers you want to deploy inside the cluster, and if you need Kafka Connect running as well, try running Minikube with at least with 4 GB of RAM instead of the default 2 GB.

Once installed, start Minikube using:

```shell
minikube start --memory 4096
```

##### [Installing a local OpenShift cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-openshift-str)

The easiest way to get started with OpenShift is using Minishift or `oc cluster up`. This section provides basic guidance on how to use them. For more information on the tools, refer to the documentation available online.

###### [oc cluster up](https://strimzi.io/docs/operators/0.18.0/using.html#oc_cluster_up)

The [`oc`](https://github.com/openshift/origin/releases) utility is one of the main tools for interacting with OpenShift. It provides a simple way of starting a local cluster using the command:

```shell
oc cluster up
```

This command requires Docker to be installed. You can find more inforation on [here](https://github.com/openshift/origin/blob/release-3.11/docs/cluster_up_down.md).

###### [Minishift](https://strimzi.io/docs/operators/0.18.0/using.html#minishift)

Minishift is an OpenShift installation within a VM. It can be downloaded and installed from the [Minishift website](https://docs.openshift.org/latest/minishift/index.html). Depending on the number of brokers you want to deploy inside the cluster, and if you need Kafka Connect running as well, try running Minishift with at least 4 GB of RAM instead of the default 2 GB.

Once installed, start Minishift using:

```shell
minishift start --memory 4GB
```

If you want to use `kubectl` with either an `oc cluster up` or `minishift` cluster, you will need to [configure it](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/), as unlike with Minikube this won’t be done automatically.

###### [`oc` and `kubectl` commands](https://strimzi.io/docs/operators/0.18.0/using.html#oc_and_kubectl_commands)

The `oc` command functions as an alternative to `kubectl`. In almost all cases the example `kubectl` commands given in this guide can be done using `oc` simply by replacing the command name (options and arguments remain the same).

In other words, instead of using:

```shell
kubectl apply -f your-file
```

when using OpenShift you can use

```shell
oc apply -f your-file
```

> NOTE As an exception to this general rule, `oc` uses `oc adm` subcommands for *cluster management*, while `kubectl` does not make such a distinction. For example, the `oc` equivalent of `kubectl taint` is `oc adm taint`.

### [2.2. Create the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-create-cluster_str)

In order to create your Kafka cluster, you deploy the Cluster Operator to manage the Kafka cluster, then deploy the Kafka cluster.

When deploying the Kafka cluster using the `Kafka` resource, you can configure the deployment to deploy the Topic Operator and User Operator at the same time. Alternatively, if you are using a non-Strimzi Kafka cluster, you can deploy the Topic Operator and User Operator as standalone components.  当使用 Kafka 资源部署Kafka集群时，您可以配置部署以同时部署Topic Operator和User Operator。 另外，如果您使用的是非Strimzi Kafka集群，则可以将Topic Operator和User Operator部署为独立组件。

#### Deploying a Kafka cluster with the Topic Operator and User Operator

Perform these deployment steps if you want to use the Topic Operator and User Operator with a Kafka cluster managed by Strimzi.

1. [Deploy the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str)
2. Use the Cluster Operator to deploy the:
   1. [Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-cluster-str)
   2. [Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-using-the-cluster-operator-str)
   3. [User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-using-the-cluster-operator-str)

#### Deploying a standalone Topic Operator and User Operator

Perform these deployment steps if you want to use the Topic Operator and User Operator with a Kafka cluster that is **not managed** by Strimzi.

1. [Deploy the standalone Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-standalone-str)
2. [Deploy the standalone User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-standalone-str)

#### [2.2.1. Deploying the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str)

The Cluster Operator is responsible for deploying and managing Apache Kafka clusters within a Kubernetes cluster.

The procedures in this section show:

- How to deploy the Cluster Operator to *watch*:
  - [A single namespace](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)
  - [Multiple namespaces](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-to-watch-multiple-namespaces-str)
  - [All namespaces](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-to-watch-whole-cluster-str)
- Alternative deployment options:
  - [How to deploy the Cluster Operator using a Helm chart](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-helm-chart-str)
  - [How to deploy the Cluster Operator from *OperatorHub.io*](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-from-operator-hub-str)

##### [Watch options for a Cluster Operator deployment](https://strimzi.io/docs/operators/0.18.0/using.html#con-cluster-operator-watch-options-str)

When the Cluster Operator is running, it starts to *watch* for updates of Kafka resources.

You can choose to deploy the Cluster Operator to watch Kafka resources from:

- A single namespace (the same namespace containing the Cluster Operator)
- Multiple namespaces
- All namespaces

> NOTE Strimzi provides example YAML files to make the deployment process easier.

The Cluster Operator watches for changes to the following resources:

- `Kafka` for the Kafka cluster.
- `KafkaConnect` for the Kafka Connect cluster.
- `KafkaConnectS2I` for the Kafka Connect cluster with Source2Image support.
- `KafkaConnector` for creating and managing connectors in a Kafka Connect cluster.
- `KafkaMirrorMaker` for the Kafka MirrorMaker instance.
- `KafkaBridge` for the Kafka Bridge instance

When one of these resources is created in the Kubernetes cluster, the operator gets the cluster description from the resource and starts creating a new cluster for the resource by creating the necessary Kubernetes resources, such as StatefulSets, Services and ConfigMaps.

Each time a Kafka resource is updated, the operator performs corresponding updates on the Kubernetes resources that make up the cluster for the resource.

Resources are either patched or deleted, and then recreated in order to make the cluster for the resource reflect the desired state of the cluster. This operation might cause a rolling update that might lead to service disruption.

When a resource is deleted, the operator undeploys the cluster and deletes all related Kubernetes resources.

##### [Deploying the Cluster Operator to watch a single namespace](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

This procedure shows how to deploy the Cluster Operator to watch Strimzi resources in a single namespace in your Kubernetes cluster.

Prerequisites

- This procedure requires use of a Kubernetes user account which is able to create `CustomResourceDefinitions`, `ClusterRoles` and `ClusterRoleBindings`. Use of Role Base Access Control (RBAC) in the Kubernetes cluster usually means that permission to create, edit, and delete these resources is limited to Kubernetes cluster administrators, such as `system:admin`.

Procedure

1. Edit the Strimzi installation files to use the namespace the Cluster Operator is going to be installed to.

   For example, in this procedure the Cluster Operator is installed to the namespace `*my-cluster-operator-namespace*`.

   On Linux, use:

   ```none
   sed -i 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
   ```

   On MacOS, use:

   ```none
   sed -i '' 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
   ```

2. Deploy the Cluster Operator:

   ```shell
   kubectl apply -f install/cluster-operator -n my-cluster-operator-namespace
   ```

3. Verify that the Cluster Operator was successfully deployed:

   ```shell
   kubectl get deployments
   ```

##### [Deploying the Cluster Operator to watch multiple namespaces](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-to-watch-multiple-namespaces-str)

This procedure shows how to deploy the Cluster Operator to watch Strimzi resources across multiple namespaces in your Kubernetes cluster.

Prerequisites

- This procedure requires use of a Kubernetes user account which is able to create `CustomResourceDefinitions`, `ClusterRoles` and `ClusterRoleBindings`. Use of Role Base Access Control (RBAC) in the Kubernetes cluster usually means that permission to create, edit, and delete these resources is limited to Kubernetes cluster administrators, such as `system:admin`.

Procedure

1. Edit the Strimzi installation files to use the namespace the Cluster Operator is going to be installed to.

   For example, in this procedure the Cluster Operator is installed to the namespace `*my-cluster-operator-namespace*`.

   On Linux, use:

   ```none
   sed -i 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
   ```

   On MacOS, use:

   ```none
   sed -i '' 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
   ```

2. Edit the `install/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml` file to add a list of all the namespaces the Cluster Operator will watch to the `STRIMZI_NAMESPACE` environment variable.

   For example, in this procedure the Cluster Operator will watch the namespaces `watched-namespace-1`, `watched-namespace-2`, `watched-namespace-3`.

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   spec:
     # ...
     template:
       spec:
         serviceAccountName: strimzi-cluster-operator
         containers:
         - name: strimzi-cluster-operator
           image: strimzi/operator:0.18.0
           imagePullPolicy: IfNotPresent
           env:
           - name: STRIMZI_NAMESPACE
             value: watched-namespace-1,watched-namespace-2,watched-namespace-3
   ```

   

3. For each namespace listed, install the `RoleBindings`.

   In this example, we replace `*watched-namespace*` in these commands with the namespaces listed in the previous step, repeating them for `watched-namespace-1`, `watched-namespace-2`, `watched-namespace-3`:

   ```shell
   kubectl apply -f install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n watched-namespace
   kubectl apply -f install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n watched-namespace
   kubectl apply -f install/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml -n watched-namespace
   ```

4. Deploy the Cluster Operator

   ```shell
   kubectl apply -f install/cluster-operator -n my-cluster-operator-namespace
   ```

5. Verify that the Cluster Operator was successfully deployed:

   ```shell
   kubectl get deployments
   ```

##### [Deploying the Cluster Operator to watch all namespaces](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-to-watch-whole-cluster-str)

This procedure shows how to deploy the Cluster Operator to watch Strimzi resources across all namespaces in your Kubernetes cluster.

When running in this mode, the Cluster Operator automatically manages clusters in any new namespaces that are created.

Prerequisites

- This procedure requires use of a Kubernetes user account which is able to create `CustomResourceDefinitions`, `ClusterRoles` and `ClusterRoleBindings`. Use of Role Base Access Control (RBAC) in the Kubernetes cluster usually means that permission to create, edit, and delete these resources is limited to Kubernetes cluster administrators, such as `system:admin`.

Procedure

1. Edit the `install/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml` file to set the value of the `STRIMZI_NAMESPACE` environment variable to `*`.

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   spec:
     # ...
     template:
       spec:
         # ...
         serviceAccountName: strimzi-cluster-operator
         containers:
         - name: strimzi-cluster-operator
           image: strimzi/operator:0.18.0
           imagePullPolicy: IfNotPresent
           env:
           - name: STRIMZI_NAMESPACE
             value: "*"
           # ...
   ```

2. Create `ClusterRoleBindings` that grant cluster-wide access for all namespaces to the Cluster Operator.

   ```shell
   kubectl create clusterrolebinding strimzi-cluster-operator-namespaced --clusterrole=strimzi-cluster-operator-namespaced --serviceaccount my-cluster-operator-namespace:strimzi-cluster-operator
   
   kubectl create clusterrolebinding strimzi-cluster-operator-entity-operator-delegation --clusterrole=strimzi-entity-operator --serviceaccount my-cluster-operator-namespace:strimzi-cluster-operator
   
   kubectl create clusterrolebinding strimzi-cluster-operator-topic-operator-delegation --clusterrole=strimzi-topic-operator --serviceaccount my-cluster-operator-namespace:strimzi-cluster-operator
   ```

   Replace `*my-cluster-operator-namespace*` with the namespace you want to install the Cluster Operator to.

3. Deploy the Cluster Operator to your Kubernetes cluster.

   ```shell
   kubectl apply -f install/cluster-operator -n my-cluster-operator-namespace
   ```

4. Verify that the Cluster Operator was successfully deployed:

   ```shell
   kubectl get deployments
   ```

##### [Deploying the Cluster Operator using a Helm Chart](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-helm-chart-str)

As an alternative to using the YAML deployment files, this procedure shows how to deploy the the Cluster Operator using a Helm chart provided with Strimzi.

Prerequisites

- The Helm client must be installed on a local machine.
- Helm must be installed to the Kubernetes cluster.

For more information about Helm, see the [Helm website](https://helm.sh/).

Procedure

1. Add the Strimzi Helm Chart repository:

   ```shell
   helm repo add strimzi https://strimzi.io/charts/
   ```

2. Deploy the Cluster Operator using the Helm command line tool:

   ```shell
   helm install strimzi/strimzi-kafka-operator
   ```

3. Verify that the Cluster Operator has been deployed successfully using the Helm command line tool:

   ```shell
   helm ls
   ```

##### [Deploying the Cluster Operator from OperatorHub.io](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-from-operator-hub-str)

[OperatorHub.io](https://operatorhub.io/) is a catalog of Kubernetes Operators sourced from multiple providers. It offers you an alternative way to install stable versions of Strimzi using the Strimzi Kafka Operator.

The [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager) is used for the installation and management of all Operators published on [OperatorHub.io](https://operatorhub.io/).

To install Strimzi from [OperatorHub.io](https://operatorhub.io/), locate the *Strimzi Kafka Operator* and follow the instructions provided.

#### [2.2.2. Deploying Kafka](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-cluster-str)

Apache Kafka is an open-source distributed publish-subscribe messaging system for fault-tolerant real-time data feeds.

The procedures in this section show:

- How to use the Cluster Operator to deploy:
  - [An *ephemeral* or *persistent* Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str)  临时或持久Kafka集群
  - The Topic Operator and User Operator by configuring the `Kafka` custom resource:
    - [Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-using-the-cluster-operator-str)
    - [User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-using-the-cluster-operator-str)
- Alternative standalone deployment procedures for the Topic Operator and User Operator:
  - [Deploy the standalone Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-standalone-str)
  - [Deploy the standalone User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-standalone-str)

When installing Kafka, Strimzi also installs a ZooKeeper cluster and adds the necessary configuration to connect Kafka with ZooKeeper.

##### [Deploying the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str)

This procedure shows how to deploy a Kafka cluster to your Kubernetes using the Cluster Operator.

The deployment uses a YAML file to provide the specification to create a `Kafka` resource.

Strimzi provides example YAMLs files for deployment in `examples/kafka/`:

- `kafka-persistent.yaml`

  Deploys a persistent cluster with three ZooKeeper and three Kafka nodes.

- `kafka-jbod.yaml`

  Deploys a persistent cluster with three ZooKeeper and three Kafka nodes (each using multiple persistent volumes).

- `kafka-persistent-single.yaml`

  Deploys a persistent cluster with a single ZooKeeper node and a single Kafka node.

- `kafka-ephemeral.yaml`

  Deploys an ephemeral cluster with three ZooKeeper and three Kafka nodes.

- `kafka-ephemeral-single.yaml`

  Deploys an ephemeral cluster with three ZooKeeper nodes and a single Kafka node.

In this procedure, we use the examples for an *ephemeral* and *persistent* Kafka cluster deployment:

- Ephemeral cluster

  In general, an ephemeral (or temporary) Kafka cluster is suitable for development and testing purposes, not for production. This deployment uses `emptyDir` volumes for storing broker information (for ZooKeeper) and topics or partitions (for Kafka). Using an `emptyDir` volume means that its content is strictly related to the pod life cycle and is deleted when the pod goes down.

- Persistent cluster

  A persistent Kafka cluster uses `PersistentVolumes` to store ZooKeeper and Kafka data. The `PersistentVolume` is acquired using a `PersistentVolumeClaim` to make it independent of the actual type of the `PersistentVolume`. For example, it can use Amazon EBS volumes in Amazon AWS deployments without any changes in the YAML files. The `PersistentVolumeClaim` can use a `StorageClass` to trigger automatic volume provisioning.

The example clusters are named `my-cluster` by default. The cluster name is defined by the name of the resource and cannot be changed after the cluster has been deployed. To change the cluster name before you deploy the cluster, edit the `Kafka.metadata.name` property of the `Kafka` resource in the relevant YAML file.

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
# ...
```

For more information about configuring the `Kafka` resource, see [Kafka cluster configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-str)

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Create and deploy an *ephemeral* or *persistent* cluster.

   For development or testing, you might prefer to use an ephemeral cluster. You can use a persistent cluster in any situation.

   - To create and deploy an *ephemeral* cluster:

     ```shell
     kubectl apply -f examples/kafka/kafka-ephemeral.yaml
     ```

   - To create and deploy a *persistent* cluster:

     ```shell
     kubectl apply -f examples/kafka/kafka-persistent.yaml
     ```

2. Verify that the Kafka cluster was successfully deployed:

   ```shell
   kubectl get deployments
   ```

##### [Deploying the Topic Operator using the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-using-the-cluster-operator-str)

This procedure describes how to deploy the Topic Operator using the Cluster Operator.

You configure the `entityOperator` property of the `Kafka` resource to include the `topicOperator`.

If you want to use the Topic Operator with a Kafka cluster that is not managed by Strimzi, you must [deploy the Topic Operator as a standalone component](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-standalone-str).

For more information about configuring the `entityOperator` and `topicOperator` properties, see [Entity Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-entity-operator-deployment-configuration-kafka).

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Edit the `entityOperator` properties of the `Kafka` resource to include `topicOperator`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     #...
     entityOperator:
       topicOperator: {}
       userOperator: {}
   ```

2. Configure the Topic Operator `spec` using the properties described in [`EntityTopicOperatorSpec` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-EntityTopicOperatorSpec-reference).

   Use an empty object (`{}`) if you want all properties to use their default values.

3. Create or update the resource:

   Use `kubectl apply`:

   ```shell
   kubectl apply -f <your-file>
   ```

##### [Deploying the User Operator using the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-using-the-cluster-operator-str)

This procedure describes how to deploy the User Operator using the Cluster Operator.

You configure the `entityOperator` property of the `Kafka` resource to include the `userOperator`.

If you want to use the User Operator with a Kafka cluster that is not managed by Strimzi, you must [deploy the User Operator as a standalone component](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-standalone-str).

For more information about configuring the `entityOperator` and `userOperator` properties, see [Entity Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-entity-operator-deployment-configuration-kafka).

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Edit the `entityOperator` properties of the `Kafka` resource to include `userOperator`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     #...
     entityOperator:
       topicOperator: {}
       userOperator: {}
   ```

2. Configure the User Operator `spec` using the properties described in [`EntityUserOperatorSpec` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-EntityUserOperatorSpec-reference).

   Use an empty object (`{}`) if you want all properties to use their default values.

3. Create or update the resource:

   ```shell
   kubectl apply -f <your-file>
   ```

#### [2.2.3. Alternative standalone deployment options for Strimzi Operators](https://strimzi.io/docs/operators/0.18.0/using.html#deploy-standalone-operators_str)

When deploying a Kafka cluster using the Cluster Operator, you can also deploy the Topic Operator and User Operator. Alternatively, you can perform a standalone deployment.

A standalone deployment means the Topic Operator and User Operator can operate with a Kafka cluster that is not managed by Strimzi.

##### [Deploying the standalone Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-standalone-str)

This procedure shows how to deploy the Topic Operator as a standalone component.

A standalone deployment requires configuration of environment variables, and is more complicated than [deploying the Topic Operator using the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-topic-operator-using-the-cluster-operator-str). However, a standalone deployment is more flexible as the Topic Operator can operate with *any* Kafka cluster, not necessarily one deployed by the Cluster Operator.

For more information about the environment variables used to configure the Topic Operator, see [Topic Operator environment](https://strimzi.io/docs/operators/0.18.0/using.html#topic-operator-environment-deploying).

Prerequisites

- You need an existing Kafka cluster for the Topic Operator to connect to.

Procedure

1. Edit the `Deployment.spec.template.spec.containers[0].env` properties in the `install/topic-operator/05-Deployment-strimzi-topic-operator.yaml` file by setting:

   1. `STRIMZI_KAFKA_BOOTSTRAP_SERVERS` to list the bootstrap brokers in your Kafka cluster, given as a comma-separated list of `*hostname*:‍*port*` pairs.
   2. `STRIMZI_ZOOKEEPER_CONNECT` to list the ZooKeeper nodes, given as a comma-separated list of `*hostname*:‍*port*` pairs. This should be the same ZooKeeper cluster that your Kafka cluster is using.
   3. `STRIMZI_NAMESPACE` to the Kubernetes namespace in which you want the operator to watch for `KafkaTopic` resources.
   4. `STRIMZI_RESOURCE_LABELS` to the label selector used to identify the `KafkaTopic` resources managed by the operator.
   5. `STRIMZI_FULL_RECONCILIATION_INTERVAL_MS` to specify the interval between periodic reconciliations, in milliseconds.
   6. `STRIMZI_TOPIC_METADATA_MAX_ATTEMPTS` to specify the number of attempts at getting topic metadata from Kafka. The time between each attempt is defined as an exponential back-off. Consider increasing this value when topic creation could take more time due to the number of partitions or replicas. Default `6`.  STRIMZI_TOPIC_METADATA_MAX_ATTEMPTS，用于指定尝试从Kafka获取主题元数据的次数。 每次尝试之间的时间定义为指数补偿。 由于分区或副本的数量，创建主题可能需要更多时间时，请考虑增加此值。 默认值为6。
   7. `STRIMZI_ZOOKEEPER_SESSION_TIMEOUT_MS` to the ZooKeeper session timeout, in milliseconds. For example, `10000`. Default `20000` (20 seconds).
   8. `STRIMZI_TOPICS_PATH` to the Zookeeper node path where the Topic Operator stores its metadata. Default `/strimzi/topics`.
   9. `STRIMZI_TLS_ENABLED` to enable TLS support for encrypting the communication with Kafka brokers. Default `true`.
   10. `STRIMZI_TRUSTSTORE_LOCATION` to the path to the truststore containing certificates for enabling TLS based communication. Mandatory only if TLS is enabled through `STRIMZI_TLS_ENABLED`.
   11. `STRIMZI_TRUSTSTORE_PASSWORD` to the password for accessing the truststore defined by `STRIMZI_TRUSTSTORE_LOCATION`. Mandatory only if TLS is enabled through `STRIMZI_TLS_ENABLED`.
   12. `STRIMZI_KEYSTORE_LOCATION` to the path to the keystore containing private keys for enabling TLS based communication. Mandatory only if TLS is enabled through `STRIMZI_TLS_ENABLED`.
   13. `STRIMZI_KEYSTORE_PASSWORD` to the password for accessing the keystore defined by `STRIMZI_KEYSTORE_LOCATION`. Mandatory only if TLS is enabled through `STRIMZI_TLS_ENABLED`.
   14. `STRIMZI_LOG_LEVEL` to the level for printing logging messages. The value can be set to: `ERROR`, `WARNING`, `INFO`, `DEBUG`, and `TRACE`. Default `INFO`.
   15. `STRIMZI_JAVA_OPTS` *(optional)* to the Java options used for the JVM running the Topic Operator. An example is `-Xmx=512M -Xms=256M`.
   16. `STRIMZI_JAVA_SYSTEM_PROPERTIES` *(optional)* to list the `-D` options which are set to the Topic Operator. An example is `-Djavax.net.debug=verbose -DpropertyName=value`.

2. Deploy the Topic Operator:

   ```shell
   kubectl apply -f install/topic-operator
   ```

3. Verify that the Topic Operator has been deployed successfully:

   ```shell
   kubectl describe deployment strimzi-topic-operator
   ```

   The Topic Operator is deployed when the `Replicas:` entry shows `1 available`.

   > NOTE You may experience a delay with the deployment if you have a slow connection to the Kubernetes cluster and the images have not been downloaded before.

##### [Deploying the standalone User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-standalone-str)

This procedure shows how to deploy the User Operator as a standalone component.

A standalone deployment requires configuration of environment variables, and is more complicated than [deploying the User Operator using the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-the-user-operator-using-the-cluster-operator-str). However, a standalone deployment is more flexible as the User Operator can operate with *any* Kafka cluster, not necessarily one deployed by the Cluster Operator.

Prerequisites

- You need an existing Kafka cluster for the User Operator to connect to.

Procedure

1. Edit the following `Deployment.spec.template.spec.containers[0].env` properties in the `install/user-operator/05-Deployment-strimzi-user-operator.yaml` file by setting:

   1. `STRIMZI_KAFKA_BOOTSTRAP_SERVERS` to list the Kafka brokers, given as a comma-separated list of `*hostname*:‍*port*` pairs.
   2. `STRIMZI_ZOOKEEPER_CONNECT` to list the ZooKeeper nodes, given as a comma-separated list of `*hostname*:‍*port*` pairs. This must be the same ZooKeeper cluster that your Kafka cluster is using. Connecting to ZooKeeper nodes with TLS encryption is not supported.
   3. `STRIMZI_NAMESPACE` to the Kubernetes namespace in which you want the operator to watch for `KafkaUser` resources.
   4. `STRIMZI_LABELS` to the label selector used to identify the `KafkaUser` resources managed by the operator.
   5. `STRIMZI_FULL_RECONCILIATION_INTERVAL_MS` to specify the interval between periodic reconciliations, in milliseconds.
   6. `STRIMZI_ZOOKEEPER_SESSION_TIMEOUT_MS` to the ZooKeeper session timeout, in milliseconds. For example, `10000`. Default `20000` (20 seconds).
   7. `STRIMZI_CA_CERT_NAME` to point to a Kubernetes `Secret` that contains the public key of the Certificate Authority for signing new user certificates for TLS client authentication. The `Secret` must contain the public key of the Certificate Authority under the key `ca.crt`.
   8. `STRIMZI_CA_KEY_NAME` to point to a Kubernetes `Secret` that contains the private key of the Certificate Authority for signing new user certificates for TLS client authentication. The `Secret` must contain the private key of the Certificate Authority under the key `ca.key`.
   9. `STRIMZI_CLUSTER_CA_CERT_SECRET_NAME` to point to a Kubernetes `Secret` containing the public key of the Certificate Authority used for signing Kafka brokers certificates for enabling TLS-based communication. The `Secret` must contain the public key of the Certificate Authority under the key `ca.crt`. This environment variable is optional and should be set only if the communication with the Kafka cluster is TLS based.
   10. `STRIMZI_EO_KEY_SECRET_NAME` to point to a Kubernetes `Secret` containing the private key and related certificate for TLS client authentication against the Kafka cluster. The `Secret` must contain the keystore with the private key and certificate under the key `entity-operator.p12`, and the related password under the key `entity-operator.password`. This environment variable is optional and should be set only if TLS client authentication is needed when the communication with the Kafka cluster is TLS based.
   11. `STRIMZI_CA_VALIDITY` the validity period for the Certificate Authority. Default is `365` days.
   12. `STRIMZI_CA_RENEWAL` the renewal period for the Certificate Authority.
   13. `STRIMZI_LOG_LEVEL` to the level for printing logging messages. The value can be set to: `ERROR`, `WARNING`, `INFO`, `DEBUG`, and `TRACE`. Default `INFO`.
   14. `STRIMZI_GC_LOG_ENABLED` to enable garbage collection (GC) logging. Default `true`. Default is `30` days to initiate certificate renewal before the old certificates expire.
   15. `STRIMZI_JAVA_OPTS` *(optional)* to the Java options used for the JVM running User Operator. An example is `-Xmx=512M -Xms=256M`.
   16. `STRIMZI_JAVA_SYSTEM_PROPERTIES` *(optional)* to list the `-D` options which are set to the User Operator. An example is `-Djavax.net.debug=verbose -DpropertyName=value`.

2. Deploy the User Operator:

   ```shell
   kubectl apply -f install/user-operator
   ```

3. Verify that the User Operator has been deployed successfully:

   ```shell
   kubectl describe deployment strimzi-user-operator
   ```

   The User Operator is deployed when the `Replicas:` entry shows `1 available`.

   > NOTE You may experience a delay with the deployment if you have a slow connection to the Kubernetes cluster and the images have not been downloaded before.

### [2.3. Deploy Kafka Connect](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-connect-str)

[Kafka Connect](https://kafka.apache.org/documentation/#connect) is a tool for streaming data between Apache Kafka and external systems.

Using the concept of *connectors*, Kafka Connect provides a framework for moving large amounts of data into and out of your Kafka cluster while maintaining scalability and reliability.  通过使用连接器的概念，Kafka Connect提供了一个框架，用于在保持可伸缩性和可靠性的同时将大量数据移入和移出Kafka集群。

Kafka Connect is typically used to integrate Kafka with external databases and storage and messaging systems.  Kafka Connect通常用于将Kafka与外部数据库以及存储和消息传递系统集成。

The procedures in this section show how to:

- [Deploy a Kafka Connect cluster using a `KafkaConnect` resource](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-connect-str)
- [Create a Kafka Connect image containing the connectors you need to make your connection](https://strimzi.io/docs/operators/0.18.0/using.html#using-kafka-connect-with-plug-ins-str)
- [Create and manage connectors using a `KafkaConnector` resource or the Kafka Connect REST API](https://strimzi.io/docs/operators/0.18.0/using.html#con-creating-managing-connectors-str)
- [Deploy a `KafkaConnector` resource to Kafka Connect](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-kafkaconnector-str)

> NOTE The term *connector* is used interchangably to mean a connector instance running within a Kafka Connect cluster, or a connector class. In this guide, the term *connector* is used when the meaning is clear from the context.

#### [2.3.1. Deploying Kafka Connect to your Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-connect-str)

This procedure shows how to deploy a Kafka Connect cluster to your Kubernetes cluster using the Cluster Operator.

A Kafka Connect cluster is implemented as a `Deployment` with a configurable number of nodes (also called *workers*) that distribute the workload of connectors as *tasks* so that the message flow is highly scalable and reliable.

The deployment uses a YAML file to provide the specification to create a `KafkaConnect` resource.

In this procedure, we use the example file provided with Strimzi:

- `examples/kafka-connect/kafka-connect.yaml`

For more information about configuring the `KafkaConnect` resource, see:

- [Kafka Connect cluster configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-connect-str)
- [Kafka Connect cluster configuration with Source2Image support](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-connect-s2i-str)

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Deploy Kafka Connect to your Kubernetes cluster.

   ```shell
   kubectl apply -f examples/kafka-connect/kafka-connect.yaml
   ```

2. Verify that Kafka Connect was successfully deployed:

   ```shell
   kubectl get deployments
   ```

#### [2.3.2. Extending Kafka Connect with connector plug-ins](https://strimzi.io/docs/operators/0.18.0/using.html#using-kafka-connect-with-plug-ins-str)

The Strimzi container images for Kafka Connect include two built-in file connectors for moving file-based data into and out of your Kafka cluster.

| File Connector              | Description                                                  |
| :-------------------------- | :----------------------------------------------------------- |
| `FileStreamSourceConnector` | Transfers data to your Kafka cluster from a file (the source). |
| `FileStreamSinkConnector`   | Transfers data from your Kafka cluster to a file (the sink). |

The Cluster Operator can also use images that you have created to deploy a Kafka Connect cluster to your Kubernetes cluster.

The procedures in this section show how to add your own connector classes to connector images by:

- [Creating a container image from the Kafka Connect base image (manually or using continuous integration)](https://strimzi.io/docs/operators/0.18.0/using.html#creating-new-image-from-base-str)
- [Creating a container image using OpenShift builds and Source-to-Image (S2I) (available only on OpenShift)](https://strimzi.io/docs/operators/0.18.0/using.html#using-openshift-s2i-create-image-str)

##### [Creating a Docker image from the Kafka Connect base image](https://strimzi.io/docs/operators/0.18.0/using.html#creating-new-image-from-base-str)

This procedure shows how to create a custom image and add it to the `/opt/kafka/plugins` directory.

You can use the Kafka container image on [Docker Hub](https://hub.docker.com/u/strimzi) as a base image for creating your own custom image with additional connector plug-ins.

At startup, the Strimzi version of Kafka Connect loads any third-party connector plug-ins contained in the `/opt/kafka/plugins` directory.

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Create a new `Dockerfile` using `strimzi/kafka:0.18.0-kafka-2.5.0` as the base image:

   ```none
   FROM strimzi/kafka:0.18.0-kafka-2.5.0
   USER root:root
   COPY ./my-plugins/ /opt/kafka/plugins/
   USER 1001
   ```

2. Build the container image.

3. Push your custom image to your container registry.

4. Point to the new container image.

   You can either:

   - Edit the `KafkaConnect.spec.image` property of the `KafkaConnect` custom resource.

     If set, this property overrides the `STRIMZI_KAFKA_CONNECT_IMAGES` variable in the Cluster Operator.

     ```yaml
     apiVersion: kafka.strimzi.io/v1beta1
     kind: KafkaConnect
     metadata:
       name: my-connect-cluster
     spec:
       #...
       image: my-new-container-image
     ```

     or

   - In the `install/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml` file, edit the `STRIMZI_KAFKA_CONNECT_IMAGES` variable to point to the new container image, and then reinstall the Cluster Operator.

Additional resources

- For more information on the `KafkaConnect.spec.image property`, see [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka-connect).
- For more information on the `STRIMZI_KAFKA_CONNECT_IMAGES` variable, see [Cluster Operator Configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-operators-cluster-operator-configuration-deploying-co).

##### [Creating a container image using OpenShift builds and Source-to-Image](https://strimzi.io/docs/operators/0.18.0/using.html#using-openshift-s2i-create-image-str)

This procedure shows how to use OpenShift [builds](https://docs.okd.io/3.9/dev_guide/builds/index.html) and the [Source-to-Image (S2I)](https://docs.okd.io/3.9/creating_images/s2i.html) framework to create a new container image.

An OpenShift build takes a builder image with S2I support, together with source code and binaries provided by the user, and uses them to build a new container image. Once built, container images are stored in OpenShift’s local container image repository and are available for use in deployments.

A Kafka Connect builder image with S2I support is provided on the [Docker Hub](https://hub.docker.com/u/strimzi) as part of the `strimzi/kafka:0.18.0-kafka-2.5.0` image. This S2I image takes your binaries (with plug-ins and connectors) and stores them in the `/tmp/kafka-plugins/s2i` directory. It creates a new Kafka Connect image from this directory, which can then be used with the Kafka Connect deployment. When started using the enhanced image, Kafka Connect loads any third-party plug-ins from the `/tmp/kafka-plugins/s2i` directory.

Procedure

1. On the command line, use the `oc apply` command to create and deploy a Kafka Connect S2I cluster:

   ```shell
   oc apply -f examples/kafka-connect/kafka-connect-s2i.yaml
   ```

2. Create a directory with Kafka Connect plug-ins:

   ```none
   $ tree ./my-plugins/
   ./my-plugins/
   ├── debezium-connector-mongodb
   │   ├── bson-3.4.2.jar
   │   ├── CHANGELOG.md
   │   ├── CONTRIBUTE.md
   │   ├── COPYRIGHT.txt
   │   ├── debezium-connector-mongodb-0.7.1.jar
   │   ├── debezium-core-0.7.1.jar
   │   ├── LICENSE.txt
   │   ├── mongodb-driver-3.4.2.jar
   │   ├── mongodb-driver-core-3.4.2.jar
   │   └── README.md
   ├── debezium-connector-mysql
   │   ├── CHANGELOG.md
   │   ├── CONTRIBUTE.md
   │   ├── COPYRIGHT.txt
   │   ├── debezium-connector-mysql-0.7.1.jar
   │   ├── debezium-core-0.7.1.jar
   │   ├── LICENSE.txt
   │   ├── mysql-binlog-connector-java-0.13.0.jar
   │   ├── mysql-connector-java-5.1.40.jar
   │   ├── README.md
   │   └── wkb-1.0.2.jar
   └── debezium-connector-postgres
       ├── CHANGELOG.md
       ├── CONTRIBUTE.md
       ├── COPYRIGHT.txt
       ├── debezium-connector-postgres-0.7.1.jar
       ├── debezium-core-0.7.1.jar
       ├── LICENSE.txt
       ├── postgresql-42.0.0.jar
       ├── protobuf-java-2.6.1.jar
       └── README.md
   ```

3. Use the `oc start-build` command to start a new build of the image using the prepared directory:

   ```shell
   oc start-build my-connect-cluster-connect --from-dir ./my-plugins/
   ```

   > NOTE The name of the build is the same as the name of the deployed Kafka Connect cluster.

4. When the build has finished, the new image is used automatically by the Kafka Connect deployment.

#### [2.3.3. Creating and managing connectors](https://strimzi.io/docs/operators/0.18.0/using.html#con-creating-managing-connectors-str)

When you have created a container image for your connector plug-in, you need to create a connector instance in your Kafka Connect cluster. You can then configure, monitor, and manage a running connector instance.

A connector is an instance of a particular *connector class* that knows how to communicate with the relevant external system in terms of messages. Connectors are available for many external systems, or you can create your own.

You can create *source* and *sink* types of connector.

- Source connector

  A source connector is a runtime entity that fetches data from an external system and feeds it to Kafka as messages.

- Sink connector

  A sink connector is a runtime entity that fetches messages from Kafka topics and feeds them to an external system.

Strimzi provides two APIs for creating and managing connectors:

- `KafkaConnector` resources (referred to as `KafkaConnectors`)
- Kafka Connect REST API

Using the APIs, you can:

- Check the status of a connector instance
- Reconfigure a running connector
- Increase or decrease the number of tasks for a connector instance
- Restart failed tasks (not supported by `KafkaConnector` resource)
- Pause a connector instance
- Resume a previously paused connector instance
- Delete a connector instance

##### [`KafkaConnector` resources](https://strimzi.io/docs/operators/0.18.0/using.html#kafkaconnector_resources)

`KafkaConnectors` allow you to create and manage connector instances for Kafka Connect in a Kubernetes-native way, so an HTTP client such as cURL is not required. Like other Kafka resources, you declare a connector’s desired state in a `KafkaConnector` YAML file that is deployed to your Kubernetes cluster to create the connector instance.

You manage a running connector instance by updating its corresponding `KafkaConnector`, and then applying the updates. You remove a connector by deleting its corresponding `KafkaConnector`.

To ensure compatibility with earlier versions of Strimzi, `KafkaConnectors` are disabled by default. To enable them for a Kafka Connect cluster, you must use annotations on the `KafkaConnect` resource. For instructions, see [Enabling `KafkaConnector` resources](https://strimzi.io/docs/operators/0.18.0/using.html#proc-enabling-kafkaconnectors-deployment-configuration-kafka-connect).

When `KafkaConnectors` are enabled, the Cluster Operator begins to watch for them. It updates the configurations of running connector instances to match the configurations defined in their `KafkaConnectors`.

Strimzi includes an example `KafkaConnector`, named `examples/connector/source-connector.yaml`. You can use this example to create and manage a `FileStreamSourceConnector`.

##### [Availability of the Kafka Connect REST API](https://strimzi.io/docs/operators/0.18.0/using.html#availability_of_the_kafka_connect_rest_api)

The Kafka Connect REST API is available on port 8083 as the `-connect-api` service.

If `KafkaConnectors` are enabled, manual changes made directly using the Kafka Connect REST API are reverted by the Cluster Operator.

The operations supported by the REST API are described in the [Apache Kafka documentation](https://kafka.apache.org/documentation/#connect_rest).

#### [2.3.4. Deploying a `KafkaConnector` resource to Kafka Connect](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-kafkaconnector-str)

This procedure describes how to deploy the example `KafkaConnector` to a Kafka Connect cluster.

The example YAML will create a `FileStreamSourceConnector` to send each line of the license file to Kafka as a message in a topic named `my-topic`.

Prerequisites

- A Kafka Connect deployment in which [`KafkaConnectors` are enabled](https://strimzi.io/docs/operators/0.18.0/using.html#proc-enabling-kafkaconnectors-deployment-configuration-kafka-connect)
- A running Cluster Operator

Procedure

1. Edit the `examples/connector/source-connector.yaml` file:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaConnector
   metadata:
     name: my-source-connector (1)
     labels:
       strimzi.io/cluster: my-connect-cluster (2)
   spec:
     class: org.apache.kafka.connect.file.FileStreamSourceConnector (3)
     tasksMax: 2 (4)
     config: (5)
       file: "/opt/kafka/LICENSE"
       topic: my-topic
       # ...
   ```

   1. Enter a name for the `KafkaConnector` resource. This will be used as the name of the connector within Kafka Connect. You can choose any name that is valid for a Kubernetes resource.
   2. Enter the name of the Kafka Connect cluster in which to create the connector.
   3. The name or alias of the connector class. This should be present in the image being used by the Kafka Connect cluster.
   4. The maximum number of tasks that the connector can create.
   5. Configuration settings for the connector. Available configuration options depend on the connector class.

2. Create the `KafkaConnector` in your Kubernetes cluster:

   ```shell
   kubectl apply -f examples/connector/source-connector.yaml
   ```

3. Check that the resource was created:

   ```shell
   kubectl get kctr --selector strimzi.io/cluster=my-connect-cluster -o name
   ```

### [2.4. Deploy Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-mirror-maker-str)

The Cluster Operator deploys one or more Kafka MirrorMaker replicas to replicate data between Kafka clusters. This process is called mirroring to avoid confusion with the Kafka partitions replication concept. MirrorMaker consumes messages from the source cluster and republishes those messages to the target cluster.

#### [2.4.1. Deploying Kafka MirrorMaker to your Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-mirror-maker-str)

This procedure shows how to deploy a Kafka MirrorMaker cluster to your Kubernetes cluster using the Cluster Operator.

The deployment uses a YAML file to provide the specification to create a `KafkaMirrorMaker` or `KafkaMirrorMaker2` resource depending on the version of MirrorMaker deployed.

In this procedure, we use the example files provided with Strimzi:

- `examples/kafka-connect/kafka-mirror-maker.yaml`
- `examples/kafka-connect/kafka-mirror-maker2.yaml`

For information about configuring `KafkaMirrorMaker` or `KafkaMirrorMaker2` resources, see [Kafka MirrorMaker configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-mirror-maker-str).

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Deploy Kafka MirrorMaker to your Kubernetes cluster:

   For MirrorMaker:

   ```shell
   kubectl apply -f examples/kafka-mirror-maker/kafka-mirror-maker.yaml
   ```

   For MirrorMaker 2.0:

   ```shell
   kubectl apply -f examples/kafka-mirror-maker-2/kafka-mirror-maker-2.yaml
   ```

2. Verify that MirrorMaker was successfully deployed:

   ```shell
   kubectl get deployments
   ```

### [2.5. Deploy Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-bridge-str)

The Cluster Operator deploys one or more Kafka bridge replicas to send data between Kafka clusters and clients via HTTP API.

#### [2.5.1. Deploying Kafka Bridge to your Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-bridge-str)

This procedure shows how to deploy a Kafka Bridge cluster to your Kubernetes cluster using the Cluster Operator.

The deployment uses a YAML file to provide the specification to create a `KafkaBridge` resource.

In this procedure, we use the example file provided with Strimzi:

- `examples/kafka-bridge/kafka-bridge.yaml`

For information about configuring the `KafkaBridge` resource, see [Kafka Bridge configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-bridge-str).

Prerequisites

- [The Cluster Operator must be deployed.](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-cluster-operator-str)

Procedure

1. Deploy Kafka Bridge to your Kubernetes cluster:

   ```shell
   kubectl apply -f examples/kafka-bridge/kafka-bridge.yaml
   ```

2. Verify that Kafka Bridge was successfully deployed:

   ```shell
   kubectl get deployments
   ```

### [2.6. Deploying example clients](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-example-clients-str)

This procedure shows how to deploy example producer and consumer clients that use the Kafka cluster you created to send and receive messages.

Prerequisites

- The Kafka cluster is available for the clients.

Procedure

1. Deploy a Kafka producer.

   ```shell
   kubectl run kafka-producer -ti --image=strimzi/kafka:0.18.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list cluster-name-kafka-bootstrap:9092 --topic my-topic
   ```

2. Type a message into the console where the producer is running.

3. Press *Enter* to send the message.

4. Deploy a Kafka consumer.

   ```shell
   kubectl run kafka-consumer -ti --image=strimzi/kafka:0.18.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server cluster-name-kafka-bootstrap:9092 --topic my-topic --from-beginning
   ```

5. Confirm that you see the incoming messages in the consumer console.







