## [1. Overview of Strimzi](https://strimzi.io/docs/operators/0.18.0/using.html#overview-str)

Strimzi simplifies the process of running Apache Kafka in a Kubernetes cluster. Strimzi 简化了在 Kubernetes集群中运行 Apache Kafka 的过程。

### [1.1. Kafka capabilities](https://strimzi.io/docs/operators/0.18.0/using.html#key-features-kafka_str)

The underlying data stream-processing capabilities and component architecture of Kafka can deliver:  Kafka的基础数据流处理功能和组件体系结构可以提供：

- Microservices and other applications to share data with extremely high throughput and low latency  微服务和其他应用程序以极高的吞吐量和低延迟共享数据
- Message ordering guarantees  消息订购保证
- Message rewind/replay from data storage to reconstruct an application state  从数据存储中倒回/重放消息以重建应用程序状态
- Message compaction to remove old records when using a key-value log  使用键值日志时，压缩邮件以删除旧记录
- Horizontal scalability in a cluster configuration  集群配置中的水平可伸缩性
- Replication of data to control fault tolerance  复制数据以控制容错
- Retention of high volumes of data for immediate access  保留大量数据以立即访问

### [1.2. Kafka use cases](https://strimzi.io/docs/operators/0.18.0/using.html#kafka_use_cases)

Kafka’s capabilities make it suitable for:

- Event-driven architectures
- Event sourcing to capture changes to the state of an application as a log of events  事件源以捕获应用程序状态的更改作为事件日志
- Message brokering  消息代理
- Website activity tracking  网站活动跟踪
- Operational monitoring through metrics  通过指标进行运营监控
- Log collection and aggregation  日志收集与汇总
- Commit logs for distributed systems  提交分布式系统的日志
- Stream processing so that applications can respond to data in real time  流处理，以便应用程序可以实时响应数据

### [1.3. How Strimzi supports Kafka](https://strimzi.io/docs/operators/0.18.0/using.html#key-features-product_str)

Strimzi provides container images and Operators for running Kafka on Kubernetes. Strimzi Operators are fundamental to the running of Strimzi. The Operators provided with Strimzi are purpose-built with specialist operational knowledge to effectively manage Kafka.  Strimzi提供了容器映像和操作员，用于在Kubernetes上运行Kafka。 Strimzi操作员是Strimzi运行的基础。 Strimzi提供的操作员是专门构建的，具有专业的操作知识，可以有效地管理Kafka。

Operators simplify the process of:

- Deploying and running Kafka clusters  部署和运行Kafka集群
- Deploying and running Kafka components  部署和运行Kafka组件
- Configuring access to Kafka  配置对Kafka的访问
- Securing access to Kafka  确保对Kafka的访问
- Upgrading Kafka  升级
- Managing brokers  管理 brokers
- Creating and managing topics  创建和管理主题
- Creating and managing users  创建和管理用户

### [1.4. Strimzi Operators](https://strimzi.io/docs/operators/0.18.0/using.html#overview-components_str)

Strimzi supports Kafka using *Operators* to deploy and manage the components and dependencies of Kafka to Kubernetes.  Strimzi使用Operators支持Kafka来部署和管理Kafka到Kubernetes的组件和依赖项。

Operators are a method of packaging, deploying, and managing a Kubernetes application. Strimzi Operators extend Kubernetes functionality, automating common and complex tasks related to a Kafka deployment. By implementing knowledge of Kafka operations in code, Kafka administration tasks are simplified and require less manual intervention.  Operator 是打包，部署和管理Kubernetes应用程序的一种方法。 Strimzi Operators扩展了Kubernetes功能，自动执行与Kafka部署相关的常见和复杂任务。 通过在代码中实现对Kafka操作的了解，简化了Kafka管理任务，并减少了人工干预。

#### Operators

Strimzi provides Operators for managing a Kafka cluster running within a Kubernetes cluster.

- Cluster Operator

  Deploys and manages Apache Kafka clusters, Kafka Connect, Kafka MirrorMaker, Kafka Bridge, Kafka Exporter, and the Entity Operator

- Entity Operator

  Comprises the Topic Operator and User Operator  包括Topic Operator and User Operator

- Topic Operator

  Manages Kafka topics

- User Operator

  Manages Kafka users

The Cluster Operator can deploy the Topic Operator and User Operator as part of an **Entity Operator** configuration at the same time as a Kafka cluster.

Operators within the Strimzi architecture

![Operators](./images/01_operators.png)

#### [1.4.1. Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#overview-components-cluster-operator-str)

Strimzi uses the Cluster Operator to deploy and manage clusters for:

- Kafka (including ZooKeeper, Entity Operator, Kafka Exporter, and Cruise Control)
- Kafka Connect
- Kafka MirrorMaker
- Kafka Bridge

Custom resources are used to deploy the clusters.

For example, to deploy a Kafka cluster:

- A `Kafka` resource with the cluster configuration is created within the Kubernetes cluster.
- The Cluster Operator deploys a corresponding 相应 Kafka cluster, based on what is declared 声明 in the `Kafka` resource.

The Cluster Operator can also deploy (through configuration of the `Kafka` resource):

- A Topic Operator to provide operator-style topic management through `KafkaTopic` custom resources
- A User Operator to provide operator-style user management through `KafkaUser` custom resources

The Topic Operator and User Operator function within the Entity Operator on deployment.

Example architecture for the Cluster Operator

![Cluster Operator](./images/02_cluster-operator.png)

#### [1.4.2. Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#overview-concepts-topic-operator-str)

The Topic Operator provides a way of managing topics in a Kafka cluster through Kubernetes resources.

Example architecture for the Topic Operator

![Topic Operator](./images/03_topic-operator.png)

The role of the Topic Operator is to keep a set of `KafkaTopic` Kubernetes resources describing Kafka topics in-sync with corresponding Kafka topics.

Specifically, if a `KafkaTopic` is:

- Created, the Topic Operator creates the topic
- Deleted, the Topic Operator deletes the topic
- Changed, the Topic Operator updates the topic

Working in the other direction, if a topic is:

- Created within the Kafka cluster, the Operator creates a `KafkaTopic`
- Deleted from the Kafka cluster, the Operator deletes the `KafkaTopic`
- Changed in the Kafka cluster, the Operator updates the `KafkaTopic`

This allows you to declare a `KafkaTopic` as part of your application’s deployment and the Topic Operator will take care of creating the topic for you. Your application just needs to deal with producing or consuming from the necessary topics.

If the topic is reconfigured or reassigned to different Kafka nodes, the `KafkaTopic` will always be up to date.

#### [1.4.3. User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#overview-concepts-user-operator-str)

The User Operator manages Kafka users for a Kafka cluster by watching for `KafkaUser` resources that describe Kafka users, and ensuring that they are configured properly in the Kafka cluster.

For example, if a `KafkaUser` is:

- Created, the User Operator creates the user it describes
- Deleted, the User Operator deletes the user it describes
- Changed, the User Operator updates the user it describes

Unlike the Topic Operator, the User Operator does not sync any changes from the Kafka cluster with the Kubernetes resources. Kafka topics can be created by applications directly in Kafka, but it is not expected that the users will be managed directly in the Kafka cluster in parallel with the User Operator.

The User Operator allows you to declare a `KafkaUser` resource as part of your application’s deployment. You can specify the authentication and authorization mechanism for the user. You can also configure *user quotas* that control usage of Kafka resources to ensure, for example, that a user does not monopolize access to a broker.

When the user is created, the user credentials are created in a `Secret`. Your application needs to use the user and its credentials for authentication and to produce or consume messages.

In addition to managing credentials for authentication, the User Operator also manages authorization rules by including a description of the user’s access rights in the `KafkaUser` declaration.

### [1.5. Strimzi custom resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-custom-resources-str)

A deployment of Kafka components to a Kubernetes cluster using Strimzi is highly configurable through the application of custom resources. Custom resources are created as instances of APIs added by Custom resource definitions (CRDs) to extend Kubernetes resources.  使用Strimzi将Kafka组件部署到Kubernetes集群是可以通过应用自定义资源进行高度配置的。 自定义资源被创建为自定义资源定义（CRD）添加的API实例，以扩展Kubernetes资源。

CRDs act as configuration instructions to describe the custom resources in a Kubernetes cluster, and are provided with Strimzi for each Kafka component used in a deployment, as well as users and topics. CRDs and custom resources are defined as YAML files. Example YAML files are provided with the Strimzi distribution.  CRD用作描述Kubernetes集群中自定义资源的配置指令，并随Strimzi一起提供给部署中使用的每个Kafka组件以及用户和主题。 CRD和自定义资源定义为YAML文件。 Strimzi发行版随附了示例YAML文件。

CRDs also allow Strimzi resources to benefit from native Kubernetes features like CLI accessibility and configuration validation.  CRD还允许Strimzi资源受益于本地Kubernetes功能，例如CLI可访问性和配置验证。

Additional resources

- [Extend the Kubernetes API with CustomResourceDefinitions](https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/)

#### [1.5.1. Strimzi custom resource example](https://strimzi.io/docs/operators/0.18.0/using.html#con-custom-resources-example-str)

CRDs require a one-time installation in a cluster to define the schemas used to instantiate and manage Strimzi-specific resources.  CRD需要在集群中一次性安装，以定义用于实例化和管理Strimzi特定资源的架构。

After a new custom resource type is added to your cluster by installing a CRD, you can create instances of the resource based on its specification.  通过安装CRD将新的自定义资源类型添加到群集后，您可以根据其规范创建资源实例。

Depending on the cluster setup, installation typically requires cluster admin privileges.

> NOTE Access to manage custom resources is limited to [Strimzi administrators](https://strimzi.io/docs/operators/0.18.0/using.html#adding-users-the-strimzi-admin-role-str). 


A CRD defines a new `kind` of resource, such as `kind:Kafka`, within a Kubernetes cluster.

The Kubernetes API server allows custom resources to be created based on the `kind` and understands from the CRD how to validate and store the custom resource when it is added to the Kubernetes cluster.  Kubernetes API服务器允许基于 kind 创建自定义资源，并从CRD了解如何在将自定义资源添加到Kubernetes集群时验证和存储自定义资源。

> WARNING When CRDs are deleted, custom resources of that type are also deleted. Additionally, the resources created by the custom resource, such as pods and statefulsets are also deleted. 

Each Strimzi-specific custom resource conforms to the schema defined by the CRD for the resource’s `kind`. The custom resources for Strimzi components have common configuration properties, which are defined under `spec`.  每个特定于Strimzi的自定义资源都符合CRD为该资源的种类定义的架构。 Strimzi组件的自定义资源具有通用的配置属性，这些属性在规范中定义。

To understand the relationship between a CRD and a custom resource, let’s look at a sample of the CRD for a Kafka topic.

Kafka topic CRD

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: CustomResourceDefinition
metadata: (1)
  name: kafkatopics.kafka.strimzi.io
  labels:
    app: strimzi
spec: (2)
  group: kafka.strimzi.io
  versions:
    v1beta1
  scope: Namespaced
  names:
    # ...
    singular: kafkatopic
    plural: kafkatopics
    shortNames:
    - kt (3)
  additionalPrinterColumns: (4)
      # ...
  subresources:
    status: {} (5)
  validation: (6)
    openAPIV3Schema:
      properties:
        spec:
          type: object
          properties:
            partitions:
              type: integer
              minimum: 1
            replicas:
              type: integer
              minimum: 1
              maximum: 32767
      # ...
```

1. The metadata for the topic CRD, its name and a label to identify the CRD.
2. The specification for this CRD, including the group (domain) name, the plural name and the supported schema version, which are used in the URL to access the API of the topic. The other names are used to identify instance resources in the CLI. For example, `kubectl get kafkatopic my-topic` or `kubectl get kafkatopics`.
3. The shortname can be used in CLI commands. For example, `kubectl get kt` can be used as an abbreviation instead of `kubectl get kafkatopic`.
4. The information presented when using a `get` command on the custom resource.
5. The current status of the CRD as described in the [schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Kafka-reference) for the resource.
6. openAPIV3Schema validation provides validation for the creation of topic custom resources. For example, a topic requires at least one partition and one replica.

> NOTE You can identify the CRD YAML files supplied with the Strimzi installation files, because the file names contain an index number followed by ‘Crd’.

Here is a corresponding example of a `KafkaTopic` custom resource.

Kafka topic custom resource

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic (1)
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster (2)
spec: (3)
  partitions: 1
  replicas: 1
  config:
    retention.ms: 7200000
    segment.bytes: 1073741824
status:
  conditions: (4)
    lastTransitionTime: "2019-08-20T11:37:00.706Z"
    status: "True"
    type: Ready
  observedGeneration: 1
  / ...
```

1. The `kind` and `apiVersion` identify the CRD of which the custom resource is an instance.
2. A label, applicable only to `KafkaTopic` and `KafkaUser` resources, that defines the name of the Kafka cluster (which is same as the name of the `Kafka` resource) to which a topic or user belongs.
3. The spec shows the number of partitions and replicas for the topic as well as the configuration parameters for the topic itself. In this example, the retention period for a message to remain in the topic and the segment file size for the log are specified.
4. Status conditions for the `KafkaTopic` resource. The `type` condition changed to `Ready` at the `lastTransitionTime`.

Custom resources can be applied to a cluster through the platform CLI. When the custom resource is created, it uses the same validation as the built-in resources of the Kubernetes API.

After a `KafkaTopic` custom resource is created, the Topic Operator is notified and corresponding Kafka topics are created in Strimzi.

### [1.6. Document Conventions](https://strimzi.io/docs/operators/0.18.0/using.html#document-conventions-str)

Replaceables

In this document, replaceable text is styled in monospace and italics.  在本文档中，可替换文本采用等宽和斜体样式。

For example, in the following code, you will want to replace `*my-namespace*` with the name of your namespace:

```none
sed -i 's/namespace: .*/namespace: my-namespace/' install/cluster-operator/*RoleBinding*.yaml
```

