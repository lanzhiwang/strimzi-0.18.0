## [3. Deployment configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-str)

This chapter describes how to configure different aspects of the supported deployments:  本章介绍如何配置支持的部署的不同方面：

- Kafka clusters
- Kafka Connect clusters
- Kafka Connect clusters with *Source2Image* support
- Kafka MirrorMaker
- Kafka Bridge
- OAuth 2.0 token-based authentication
- OAuth 2.0 token-based authorization
- Cruise Control

### [3.1. Kafka cluster configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-str)

The full schema of the `Kafka` resource is described in the [`Kafka` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Kafka-reference). All labels that are applied to the desired `Kafka` resource will also be applied to the Kubernetes resources making up the Kafka cluster. This provides a convenient mechanism for resources to be labeled as required.  Kafka模式参考中描述了Kafka资源的完整模式。 应用于所需Kafka资源的所有标签也将应用于构成Kafka集群的Kubernetes资源。 这提供了一种方便的机制，可以根据需要标记资源。

#### [3.1.1. Sample Kafka YAML configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-sample-kafka-resource-config-deployment-configuration-kafka)

For help in understanding the configuration options available for your Kafka deployment, refer to sample YAML file provided here.

The sample shows only some of the possible configuration options, but those that are particularly important include:

- Resource requests (CPU / Memory)
- JVM options for maximum and minimum memory allocation
- Listeners (and authentication)
- Authentication
- Storage
- Rack awareness
- Metrics

```shell
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    replicas: 3 (1)
    version: 0.18.0 (2)
    resources: (3)
      requests:
        memory: 64Gi
        cpu: "8"
      limits: (4)
        memory: 64Gi
        cpu: "12"
    jvmOptions: (5)
      -Xms: 8192m
      -Xmx: 8192m
    listeners: (6)
      tls:
        authentication:(7)
          type: tls
      external: (8)
        type: route
        authentication:
          type: tls
        configuration:
          brokerCertChainAndKey: (9)
            secretName: my-secret
            certificate: my-certificate.crt
            key: my-key.key
    authorization: (10)
      type: simple
    config: (11)
      auto.create.topics.enable: "false"
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
    storage: (12)
      type: persistent-claim (13)
      size: 10000Gi (14)
    rack: (15)
      topologyKey: failure-domain.beta.kubernetes.io/zone
    metrics: (16)
      lowercaseOutputName: true
      rules: (17)
      # Special cases and very specific rules
      - pattern : kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
        name: kafka_server_$1_$2
        type: GAUGE
        labels:
          clientId: "$3"
          topic: "$4"
          partition: "$5"
        # ...
  zookeeper: (18)
    replicas: 3
    resources:
      requests:
        memory: 8Gi
        cpu: "2"
      limits:
        memory: 8Gi
        cpu: "2"
    jvmOptions:
      -Xms: 4096m
      -Xmx: 4096m
    storage:
      type: persistent-claim
      size: 1000Gi
    metrics:
      # ...
  entityOperator: (19)
    topicOperator:
      resources:
        requests:
          memory: 512Mi
          cpu: "1"
        limits:
          memory: 512Mi
          cpu: "1"
    userOperator:
      resources:
        requests:
          memory: 512Mi
          cpu: "1"
        limits:
          memory: 512Mi
          cpu: "1"
  kafkaExporter: (20)
    # ...
  cruiseControl: (21)
    # ...
```

1. Replicas [specifies the number of broker nodes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-replicas-deployment-configuration-kafka).
2. Kafka version, [which can be changed by following the upgrade procedure](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-str).
3. Resource requests [specify the resources to reserve for a given container](https://strimzi.io/docs/operators/0.18.0/using.html#ref-resource-limits-and-requests-deployment-configuration-kafka).
4. Resource limits specify the maximum resources that can be consumed by a container.
5. JVM options can [specify the minimum (`-Xms`) and maximum (`-Xmx`) memory allocation for JVM](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka).
6. Listeners configure how clients connect to the Kafka cluster via bootstrap addresses. Listeners are [configured as `plain` (without encryption), `tls` or `external`](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-kafka-broker-listeners-deployment-configuration-kafka).
7. Listener authentication mechanisms may be configured for each listener, and [specified as mutual TLS or SCRAM-SHA](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-listener-authentication-deployment-configuration-kafka).  可以为每个侦听器配置侦听器身份验证机制，并将其指定为相互TLS或SCRAM-SHA
8. External listener configuration specifies [how the Kafka cluster is exposed outside Kubernetes, such as through a `route`, `loadbalancer` or `nodeport`](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-deployment-configuration-kafka).
9. Optional configuration for a [Kafka listener certificate](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-listener-certificates-str) managed by an external Certificate Authority. The `brokerCertChainAndKey` property specifies a `Secret` that holds a server certificate and a private key. Kafka listener certificates can also be configured for TLS listeners.
10. Authorization [enables `simple` authorization on the Kafka broker using the `SimpleAclAuthorizer` Kafka plugin](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authorization-deployment-configuration-kafka).
11. Config specifies the broker configuration. [Standard Apache Kafka configuration may be provided, restricted to those properties not managed directly by Strimzi](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-broker-configuration-deployment-configuration-kafka).  Config指定代理配置。 可以提供标准的Apache Kafka配置，但仅限于Strimzi不直接管理的那些属性
12. Storage is [configured as `ephemeral`, `persistent-claim` or `jbod`](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-storage-deployment-configuration-kafka).
13. Storage size for [persistent volumes may be increased](https://strimzi.io/docs/operators/0.18.0/using.html#proc-resizing-persistent-volumes-deployment-configuration-kafka) and additional [volumes may be added to JBOD storage](https://strimzi.io/docs/operators/0.18.0/using.html#proc-adding-volumes-to-jbod-storage-deployment-configuration-kafka).
14. Persistent storage has [additional configuration options](https://strimzi.io/docs/operators/0.18.0/using.html#ref-persistent-storage-deployment-configuration-kafka), such as a storage `id` and `class` for dynamic volume provisioning.
15. Rack awareness is configured to [spread replicas across different racks](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-rack-deployment-configuration-kafka). A `topology` key must match the label of a cluster node.
16. Kafka [metrics configuration for use with Prometheus](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str).
17. Kafka rules for exporting metrics to a Grafana dashboard through the JMX Exporter. A set of rules provided with Strimzi may be copied to your Kafka resource configuration.
18. [ZooKeeper-specific configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-zookeeper-node-configuration-deployment-configuration-kafka), which contains properties similar to the Kafka configuration.
19. Entity Operator configuration, which [specifies the configuration for the Topic Operator and User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-entity-operator-deployment-configuration-kafka).
20. Kafka Exporter configuration, which is used [to expose data as Prometheus metrics](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-exporter-configuration-deployment-configuration-kafka).
21. Cruise Control configuration, which is used [to monitor and balance data across the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str).

#### [3.1.2. Data storage considerations](https://strimzi.io/docs/operators/0.18.0/using.html#considerations-for-data-storage-deployment-configuration-kafka)

An efficient data storage infrastructure is essential to the optimal performance of Strimzi.  高效的数据存储基础架构对于Strimzi的最佳性能至关重要。

Block storage is required. File storage, such as NFS, does not work with Kafka.

For your block storage, you can choose, for example:

- Cloud-based block storage solutions, such as [Amazon Elastic Block Store (EBS)](https://aws.amazon.com/ebs/)
- [Local persistent volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local)
- Storage Area Network (SAN) volumes accessed by a protocol such as *Fibre Channel* or *iSCSI*

> NOTE Strimzi does not require Kubernetes raw block volumes.

##### [File systems](https://strimzi.io/docs/operators/0.18.0/using.html#file_systems)

It is recommended that you configure your storage system to use the *XFS* file system. Strimzi is also compatible with the *ext4* file system, but this might require additional configuration for best results.  建议您将存储系统配置为使用XFS文件系统。 Strimzi也与ext4文件系统兼容，但这可能需要附加配置才能获得最佳效果。

##### [Apache Kafka and ZooKeeper storage](https://strimzi.io/docs/operators/0.18.0/using.html#apache_kafka_and_zookeeper_storage)

Use separate disks for Apache Kafka and ZooKeeper.  将单独的磁盘用于Apache Kafka和ZooKeeper。

Three types of data storage are supported:

- Ephemeral (Recommended for development only)
- Persistent
- JBOD (Just a Bunch of Disks, suitable for Kafka only)

For more information, see [Kafka and ZooKeeper storage](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-storage-deployment-configuration-kafka).

Solid-state drives (SSDs), though not essential, can improve the performance of Kafka in large clusters where data is sent to and received from multiple topics asynchronously. SSDs are particularly effective with ZooKeeper, which requires fast, low latency data access.  固态驱动器（SSD）尽管不是必需的，但可以在大型集群中提高Kafka的性能，在大型集群中，数据是异步发送到多个主题或从多个主题接收的。 SSD对ZooKeeper尤其有效，它需要快速，低延迟的数据访问。

> NOTE You do not need to provision replicated storage because Kafka and ZooKeeper both have built-in data replication.

#### [3.1.3. Kafka and ZooKeeper storage types](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-storage-deployment-configuration-kafka)

As stateful applications, Kafka and ZooKeeper need to store data on disk. Strimzi supports three storage types for this data:

- Ephemeral
- Persistent
- JBOD storage

> NOTE JBOD storage is supported only for Kafka, not for ZooKeeper.

When configuring a `Kafka` resource, you can specify the type of storage used by the Kafka broker and its corresponding ZooKeeper node. You configure the storage type using the `storage` property in the following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.zookeeper`

The storage type is configured in the `type` field.

> WARNING The storage type cannot be changed after a Kafka cluster is deployed.

Additional resources

- For more information about ephemeral storage, see [ephemeral storage schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-EphemeralStorage-reference).
- For more information about persistent storage, see [persistent storage schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-PersistentClaimStorage-reference).
- For more information about JBOD storage, see [JBOD schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-JbodStorage-reference).
- For more information about the schema for `Kafka`, see [`Kafka` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Kafka-reference).

##### [Ephemeral storage](https://strimzi.io/docs/operators/0.18.0/using.html#ref-ephemeral-storage-deployment-configuration-kafka)

Ephemeral storage uses the `emptyDir` volumes to store data. To use ephemeral storage, the `type` field should be set to `ephemeral`.

> IMPORTANT `emptyDir` volumes are not persistent and the data stored in them will be lost when the Pod is restarted. After the new pod is started, it has to recover all data from other nodes of the cluster. Ephemeral storage is not suitable for use with single node ZooKeeper clusters and for Kafka topics with replication factor 1, because it will lead to data loss.

An example of Ephemeral storage

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    storage:
      type: ephemeral
    # ...
  zookeeper:
    # ...
    storage:
      type: ephemeral
    # ...
```

###### [Log directories](https://strimzi.io/docs/operators/0.18.0/using.html#log_directories)

The ephemeral volume will be used by the Kafka brokers as log directories mounted into the following path:

- `/var/lib/kafka/data/kafka-log_idx_`

  Where `*idx*` is the Kafka broker pod index. For example `/var/lib/kafka/data/kafka-log0`.

##### [Persistent storage](https://strimzi.io/docs/operators/0.18.0/using.html#ref-persistent-storage-deployment-configuration-kafka)

Persistent storage uses [Persistent Volume Claims](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) to provision persistent volumes for storing data. Persistent Volume Claims can be used to provision volumes of many different types, depending on the [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) which will provision the volume. The data types which can be used with persistent volume claims include many types of SAN storage as well as [Local persistent volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local).

To use persistent storage, the `type` has to be set to `persistent-claim`. Persistent storage supports additional configuration options:

- `id` (optional)

  Storage identification number. This option is mandatory for storage volumes defined in a JBOD storage declaration. Default is `0`.

- `size` (required)

  Defines the size of the persistent volume claim, for example, "1000Gi".

- `class` (optional)

  The Kubernetes [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) to use for dynamic volume provisioning.

- `selector` (optional)

  Allows selecting a specific persistent volume to use. It contains key:value pairs representing labels for selecting such a volume.

- `deleteClaim` (optional)

  Boolean value which specifies if the Persistent Volume Claim has to be deleted when the cluster is undeployed. Default is `false`.

> WARNING Increasing the size of persistent volumes in an existing Strimzi cluster is only supported in Kubernetes versions that support persistent volume resizing. The persistent volume to be resized must use a storage class that supports volume expansion. For other versions of Kubernetes and storage classes which do not support volume expansion, you must decide the necessary storage size before deploying the cluster. Decreasing the size of existing persistent volumes is not possible.

Example fragment of persistent storage configuration with 1000Gi `size`

```yaml
# ...
storage:
  type: persistent-claim
  size: 1000Gi
# ...
```

The following example demonstrates the use of a storage class.

Example fragment of persistent storage configuration with specific Storage Class

```yaml
# ...
storage:
  type: persistent-claim
  size: 1Gi
  class: my-storage-class
# ...
```

Finally, a `selector` can be used to select a specific labeled persistent volume to provide needed features such as an SSD.

Example fragment of persistent storage configuration with selector

```yaml
# ...
storage:
  type: persistent-claim
  size: 1Gi
  selector:
    hdd-type: ssd
  deleteClaim: true
# ...
```

###### [Storage class overrides](https://strimzi.io/docs/operators/0.18.0/using.html#storage_class_overrides)

You can specify a different storage class for one or more Kafka brokers, instead of using the default storage class. This is useful if, for example, storage classes are restricted to different availability zones or data centers. You can use the `overrides` field for this purpose.

In this example, the default storage class is named `my-storage-class`:

Example Strimzi cluster using storage class overrides

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  labels:
    app: my-cluster
  name: my-cluster
  namespace: myproject
spec:
  # ...
  kafka:
    replicas: 3
    storage:
      deleteClaim: true
      size: 100Gi
      type: persistent-claim
      class: my-storage-class
      overrides:
        - broker: 0
          class: my-storage-class-zone-1a
        - broker: 1
          class: my-storage-class-zone-1b
        - broker: 2
          class: my-storage-class-zone-1c
  # ...
```

As a result of the configured `overrides` property, the broker volumes use the following storage classes:

- The persistent volumes of broker 0 will use `my-storage-class-zone-1a`.
- The persistent volumes of broker 1 will use `my-storage-class-zone-1b`.
- The persistent volumes of broker 2 will use `my-storage-class-zone-1c`.

The `overrides` property is currently used only to override storage class configurations. Overriding other storage configuration fields is not currently supported. Other fields from the storage configuration are currently not supported.

###### [Persistent Volume Claim naming](https://strimzi.io/docs/operators/0.18.0/using.html#pvc-naming)

When persistent storage is used, it creates Persistent Volume Claims with the following names:

- `data-*cluster-name*-kafka-*idx*`

  Persistent Volume Claim for the volume used for storing data for the Kafka broker pod `*idx*`.

- `data-*cluster-name*-zookeeper-*idx*`

  Persistent Volume Claim for the volume used for storing data for the ZooKeeper node pod `*idx*`.

###### [Log directories](https://strimzi.io/docs/operators/0.18.0/using.html#log_directories_2)

The persistent volume will be used by the Kafka brokers as log directories mounted into the following path:

- `/var/lib/kafka/data/kafka-log_idx_`

  Where `*idx*` is the Kafka broker pod index. For example `/var/lib/kafka/data/kafka-log0`.

##### [Resizing persistent volumes](https://strimzi.io/docs/operators/0.18.0/using.html#proc-resizing-persistent-volumes-deployment-configuration-kafka)

You can provision increased storage capacity by increasing the size of the persistent volumes used by an existing Strimzi cluster. Resizing persistent volumes is supported in clusters that use either a single persistent volume or multiple persistent volumes in a JBOD storage configuration.

> NOTE You can increase but not decrease the size of persistent volumes. Decreasing the size of persistent volumes is not currently supported in Kubernetes.

Prerequisites

- A Kubernetes cluster with support for volume resizing.
- The Cluster Operator is running.
- A Kafka cluster using persistent volumes created using a storage class that supports volume expansion扩张.

Procedure

1. In a `Kafka` resource, increase the size of the persistent volume allocated to the Kafka cluster, the ZooKeeper cluster, or both.

   - To increase the volume size allocated to the Kafka cluster, edit the `spec.kafka.storage` property.

   - To increase the volume size allocated to the ZooKeeper cluster, edit the `spec.zookeeper.storage` property.

     For example, to increase the volume size from `1000Gi` to `2000Gi`:

     ```yaml
     apiVersion: kafka.strimzi.io/v1beta1
     kind: Kafka
     metadata:
       name: my-cluster
     spec:
       kafka:
         # ...
         storage:
           type: persistent-claim
           size: 2000Gi
           class: my-storage-class
         # ...
       zookeeper:
         # ...
     ```

2. Create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

   Kubernetes increases the capacity of the selected persistent volumes in response to a request from the Cluster Operator. When the resizing is complete, the Cluster Operator restarts all pods that use the resized persistent volumes. This happens automatically.

Additional resources

For more information about resizing persistent volumes in Kubernetes, see [Resizing Persistent Volumes using Kubernetes](https://kubernetes.io/blog/2018/07/12/resizing-persistent-volumes-using-kubernetes/).

##### [JBOD storage overview](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jbod-storage-deployment-configuration-kafka)

You can configure Strimzi to use JBOD, a data storage configuration of multiple disks or volumes. JBOD is one approach to providing increased data storage for Kafka brokers. It can also improve performance.

A JBOD configuration is described by one or more volumes, each of which can be either [ephemeral](https://strimzi.io/docs/operators/0.18.0/using.html#ref-ephemeral-storage-deployment-configuration-kafka) or [persistent](https://strimzi.io/docs/operators/0.18.0/using.html#ref-persistent-storage-deployment-configuration-kafka). The rules and constraints for JBOD volume declarations are the same as those for ephemeral and persistent storage. For example, you cannot change the size of a persistent storage volume after it has been provisioned.

###### [JBOD configuration](https://strimzi.io/docs/operators/0.18.0/using.html#jbod_configuration)

To use JBOD with Strimzi, the storage `type` must be set to `jbod`. The `volumes` property allows you to describe the disks that make up your JBOD storage array or configuration. The following fragment shows an example JBOD configuration:

```yaml
# ...
storage:
  type: jbod
  volumes:
  - id: 0
    type: persistent-claim
    size: 100Gi
    deleteClaim: false
  - id: 1
    type: persistent-claim
    size: 100Gi
    deleteClaim: false
# ...
```

The ids cannot be changed once the JBOD volumes are created.

Users can add or remove volumes from the JBOD configuration.

###### [JBOD and Persistent Volume Claims](https://strimzi.io/docs/operators/0.18.0/using.html#jbod-pvc)

When persistent storage is used to declare JBOD volumes, the naming scheme of the resulting Persistent Volume Claims is as follows:

- `data-*id*-*cluster-name*-kafka-*idx*`

  Where `*id*` is the ID of the volume used for storing data for Kafka broker pod `*idx*`.

###### [Log directories](https://strimzi.io/docs/operators/0.18.0/using.html#log_directories_3)

The JBOD volumes will be used by the Kafka brokers as log directories mounted into the following path:

- `/var/lib/kafka/data-*id*/kafka-log_idx_`

  Where `*id*` is the ID of the volume used for storing data for Kafka broker pod `*idx*`. For example `/var/lib/kafka/data-0/kafka-log0`.

##### [Adding volumes to JBOD storage](https://strimzi.io/docs/operators/0.18.0/using.html#proc-adding-volumes-to-jbod-storage-deployment-configuration-kafka)

This procedure describes how to add volumes to a Kafka cluster configured to use JBOD storage. It cannot be applied to Kafka clusters configured to use any other storage type.  此过程描述了如何将卷添加到配置为使用JBOD存储的Kafka群集中。 它不能应用于配置为使用任何其他存储类型的Kafka群集。

> NOTE When adding a new volume under an `id` which was already used in the past and removed, you have to make sure that the previously used `PersistentVolumeClaims` have been deleted.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator
- A Kafka cluster with JBOD storage

Procedure

1. Edit the `spec.kafka.storage.volumes` property in the `Kafka` resource. Add the new volumes to the `volumes` array. For example, add the new volume with id `2`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       storage:
         type: jbod
         volumes:
         - id: 0
           type: persistent-claim
           size: 100Gi
           deleteClaim: false
         - id: 1
           type: persistent-claim
           size: 100Gi
           deleteClaim: false
         - id: 2
           type: persistent-claim
           size: 100Gi
           deleteClaim: false
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

3. Create new topics or reassign existing partitions to the new disks.

Additional resources

For more information about reassigning topics, see [Partition reassignment](https://strimzi.io/docs/operators/0.18.0/using.html#con-partition-reassignment-deployment-configuration-kafka).

##### [Removing volumes from JBOD storage](https://strimzi.io/docs/operators/0.18.0/using.html#proc-removing-volumes-from-jbod-storage-deployment-configuration-kafka)

This procedure describes how to remove volumes from Kafka cluster configured to use JBOD storage. It cannot be applied to Kafka clusters configured to use any other storage type. The JBOD storage always has to contain at least one volume.

> IMPORTANT To avoid data loss, you have to move all partitions before removing the volumes.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator
- A Kafka cluster with JBOD storage with two or more volumes

Procedure

1. Reassign all partitions from the disks which are you going to remove. Any data in partitions still assigned to the disks which are going to be removed might be lost.

2. Edit the `spec.kafka.storage.volumes` property in the `Kafka` resource. Remove one or more volumes from the `volumes` array. For example, remove the volumes with ids `1` and `2`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       storage:
         type: jbod
         volumes:
         - id: 0
           type: persistent-claim
           size: 100Gi
           deleteClaim: false
       # ...
     zookeeper:
       # ...
   ```

3. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

For more information about reassigning topics, see [Partition reassignment](https://strimzi.io/docs/operators/0.18.0/using.html#con-partition-reassignment-deployment-configuration-kafka).

#### [3.1.4. Kafka broker replicas](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-replicas-deployment-configuration-kafka)

A Kafka cluster can run with many brokers. You can configure the number of brokers used for the Kafka cluster in `Kafka.spec.kafka.replicas`. The best number of brokers for your cluster has to be determined based on your specific use case.

##### [Configuring the number of broker nodes](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-broker-replicas-deployment-configuration-kafka)

This procedure describes how to configure the number of Kafka broker nodes in a new cluster. It only applies to new clusters with no partitions. If your cluster already has topics defined, see [Scaling clusters](https://strimzi.io/docs/operators/0.18.0/using.html#scaling-clusters-deployment-configuration-kafka).

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator
- A Kafka cluster with no topics defined yet

Procedure

1. Edit the `replicas` property in the `Kafka` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       replicas: 3
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

If your cluster already has topics defined, see [Scaling clusters](https://strimzi.io/docs/operators/0.18.0/using.html#scaling-clusters-deployment-configuration-kafka).

#### [3.1.5. Kafka broker configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-configuration-deployment-configuration-kafka)

Strimzi allows you to customize the configuration of the Kafka brokers in your Kafka cluster. You can specify and configure most of the options listed in the "Broker Configs" section of the [Apache Kafka documentation](http://kafka.apache.org/documentation/#brokerconfigs). You cannot configure options that are related to the following areas:

- Security (Encryption, Authentication, and Authorization)
- Listener configuration
- Broker ID configuration
- Configuration of log data directories
- Inter-broker communication
- ZooKeeper connectivity

These options are automatically configured by Strimzi.

##### [Kafka broker configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-broker-configuration-deployment-configuration-kafka)

The `config` property in `Kafka.spec.kafka` contains Kafka broker configuration options as keys with values in one of the following JSON types:

- String
- Number
- Boolean

You can specify and configure all of the options in the "Broker Configs" section of the [Apache Kafka documentation](http://kafka.apache.org/documentation/#brokerconfigs) apart from those managed directly by Strimzi. Specifically, you are prevented from modifying all configuration options with keys equal to or starting with one of the following strings:  除了由Strimzi直接管理的选项之外，您还可以在Apache Kafka文档的代理配置部分中指定和配置所有选项。 特别是，禁止您使用等于或以以下字符串之一开头的键修改所有配置选项

- `listeners`
- `advertised.`
- `broker.`
- `listener.`
- `host.name`
- `port`
- `inter.broker.listener.name`
- `sasl.`
- `ssl.`
- `security.`
- `password.`
- `principal.builder.class`
- `log.dir`
- `zookeeper.connect`
- `zookeeper.set.acl`
- `authorizer.`
- `super.user`

If the `config` property specifies a restricted option, it is ignored and a warning message is printed to the Cluster Operator log file. All other supported options are passed to Kafka.

An example Kafka broker configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    config:
      num.partitions: 1
      num.recovery.threads.per.data.dir: 1
      default.replication.factor: 3
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 1
      log.retention.hours: 168
      log.segment.bytes: 1073741824
      log.retention.check.interval.ms: 300000
      num.network.threads: 3
      num.io.threads: 8
      socket.send.buffer.bytes: 102400
      socket.receive.buffer.bytes: 102400
      socket.request.max.bytes: 104857600
      group.initial.rebalance.delay.ms: 0
    # ...
```

##### [Configuring Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-brokers-deployment-configuration-kafka)

You can configure an existing Kafka broker, or create a new Kafka broker with a specified configuration.

Prerequisites

- A Kubernetes cluster is available.
- The Cluster Operator is running.

Procedure

1. Open the YAML configuration file that contains the `Kafka` resource specifying the cluster deployment.

2. In the `spec.kafka.config` property in the `Kafka` resource, enter one or more Kafka configuration settings. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       config:
         default.replication.factor: 3
         offsets.topic.replication.factor: 3
         transaction.state.log.replication.factor: 3
         transaction.state.log.min.isr: 1
       # ...
     zookeeper:
       # ...
   ```

3. Apply the new configuration to create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f kafka.yaml
   ```

   where `*kafka.yaml*` is the YAML configuration file for the resource that you want to configure; for example, `kafka-persistent.yaml`.

#### [3.1.6. Kafka broker listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-kafka-broker-listeners-deployment-configuration-kafka)

You can configure the listeners enabled in Kafka brokers. The following types of listeners are supported:

- Plain listener on port 9092 (without TLS encryption)
- TLS listener on port 9093 (with TLS encryption)
- External listener on port 9094 for access from outside of Kubernetes

OAuth 2.0

If you are using OAuth 2.0 token-based authentication, you can configure the listeners to connect to your authorization server. For more information, see [Using OAuth 2.0 token-based authentication](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-oauth-authentication_str).

Listener certificates. 侦听器证书

You can provide your own server certificates, called *Kafka listener certificates*, for TLS listeners or external listeners which have TLS encryption enabled. For more information, see [Kafka listener certificates](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-listener-certificates-str).  您可以为启用了TLS加密的TLS侦听器或外部侦听器提供自己的服务器证书，称为Kafka侦听器证书。 有关更多信息，请参阅Kafka侦听器证书。

##### [Kafka listeners](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-listeners-deployment-configuration-kafka)

You can configure Kafka broker listeners using the `listeners` property in the `Kafka.spec.kafka` resource. The `listeners` property contains three sub-properties:

- `plain`
- `tls`
- `external`

Each listener will only be defined when the `listeners` object has the given property.

An example of `listeners` property with all listeners enabled

```yaml
# ...
listeners:
  plain: {}
  tls: {}
  external:
    type: loadbalancer
# ...
```

An example of `listeners` property with only the plain listener enabled

```yaml
# ...
listeners:
  plain: {}
# ...
```

##### [Configuring Kafka listeners](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-listeners-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `listeners` property in the `Kafka.spec.kafka` resource.

   An example configuration of the plain (unencrypted) listener without authentication:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         plain: {}
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For more information about the schema, see [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

##### [Listener authentication](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-listener-authentication-deployment-configuration-kafka)

The listener `authentication` property is used to specify an authentication mechanism specific to that listener:

- Mutual TLS authentication (only on the listeners with TLS encryption). 相互TLS身份验证（仅在具有TLS加密的侦听器上）
- SCRAM-SHA authentication. SCRAM-SHA认证

If no `authentication` property is specified then the listener does not authenticate clients which connect through that listener.

Authentication must be configured when using the User Operator to manage `KafkaUsers`.

###### [Authentication configuration for a listener](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-listener-authentication-example-deployment-configuration-kafka)

The following example shows:

- A `plain` listener configured for SCRAM-SHA authentication
- A `tls` listener with mutual TLS authentication
- An `external` listener with mutual TLS authentication

An example showing listener authentication configuration

```yaml
# ...
listeners:
  plain:
    authentication:
      type: scram-sha-512
  tls:
    authentication:
      type: tls
  external:
    type: loadbalancer
    tls: true
    authentication:
      type: tls
# ...
```

###### [Mutual TLS authentication](https://strimzi.io/docs/operators/0.18.0/using.html#con-mutual-tls-authentication-deployment-configuration-kafka)

Mutual TLS authentication is always used for the communication between Kafka brokers and ZooKeeper pods.  相互TLS身份验证始终用于Kafka代理与ZooKeeper之间的通信。

Mutual authentication or two-way authentication is when both the server and the client present certificates. Strimzi can configure Kafka to use TLS (Transport Layer Security) to provide encrypted communication between Kafka brokers and clients either with or without mutual authentication. When you configure mutual authentication, the broker authenticates the client and the client authenticates the broker.  双向身份验证或双向身份验证是服务器和客户端都提供证书时。 Strimzi可以将Kafka配置为使用TLS（传输层安全性）来提供Kafka代理与客户端之间的加密通信，无论是否进行相互认证。 配置相互身份验证时，代理对客户端进行身份验证，而客户端对代理进行身份验证。

> NOTE TLS authentication is more commonly one-way, with one party authenticating the identity of another. For example, when HTTPS is used between a web browser and a web server, the server obtains proof of the identity of the browser.  TLS身份验证更常见是一种单向方式，其中一方认证另一方的身份。 例如，当在Web浏览器和Web服务器之间使用HTTPS时，服务器将获得浏览器身份的证明。

[When to use mutual TLS authentication for clients](https://strimzi.io/docs/operators/0.18.0/using.html#when_to_use_mutual_tls_authentication_for_clients)

Mutual TLS authentication is recommended for authenticating Kafka clients when:

- The client supports authentication using mutual TLS authentication
- It is necessary to use the TLS certificates rather than passwords
- You can reconfigure and restart client applications periodically so that they do not use expired certificates.  您可以定期重新配置和重新启动客户端应用程序，以便它们不使用过期的证书。

###### [SCRAM-SHA authentication](https://strimzi.io/docs/operators/0.18.0/using.html#con-scram-sha-authentication-deployment-configuration-kafka)

SCRAM (Salted Challenge Response Authentication Mechanism) is an authentication protocol that can establish mutual authentication using passwords. Strimzi can configure Kafka to use SASL (Simple Authentication and Security Layer) SCRAM-SHA-512 to provide authentication on both unencrypted and TLS-encrypted client connections. TLS authentication is always used internally between Kafka brokers and ZooKeeper nodes. When used with a TLS client connection, the TLS protocol provides encryption, but is not used for authentication.  SCRAM 是一种认证协议，可以使用密码建立相互认证。 Strimzi可以将Kafka配置为使用SASL（简单身份验证和安全层）SCRAM-SHA-512在未加密和TLS加密的客户端连接上提供身份验证。 TLS身份验证始终在Kafka代理和ZooKeeper节点之间内部使用。 与TLS客户端连接一起使用时，TLS协议提供加密，但不用于身份验证。

The following properties of SCRAM make it safe to use SCRAM-SHA even on unencrypted connections:

- The passwords are not sent in the clear over the communication channel. Instead the client and the server are each challenged by the other to offer proof that they know the password of the authenticating user.  密码不是通过通信通道明文发送的。 取而代之的是，客户端和服务器各自受到对方的挑战，以提供证明他们知道身份验证用户密码的证据。
- The server and client each generate a new challenge for each authentication exchange. This means that the exchange is resilient against replay attacks.  服务器和客户端各自为每次身份验证交换生成新的挑战。 这意味着交换可以抵抗重放攻击。

[Supported SCRAM credentials](https://strimzi.io/docs/operators/0.18.0/using.html#supported_scram_credentials)

Strimzi supports SCRAM-SHA-512 only. When a `KafkaUser.spec.authentication.type` is configured with `scram-sha-512` the User Operator will generate a random 12 character password consisting of upper and lowercase ASCII letters and numbers.

[When to use SCRAM-SHA authentication for clients](https://strimzi.io/docs/operators/0.18.0/using.html#when_to_use_scram_sha_authentication_for_clients)

SCRAM-SHA is recommended for authenticating Kafka clients when:

- The client supports authentication using SCRAM-SHA-512
- It is necessary to use passwords rather than the TLS certificates
- Authentication for unencrypted communication is required

##### [External listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-deployment-configuration-kafka)

Use an external listener to expose your Strimzi Kafka cluster to a client outside a Kubernetes environment.

Additional resources

- [Accessing Apache Kafka in Strimzi](https://strimzi.io/2019/04/17/accessing-kafka-part-1.html)

###### [Customizing advertised addresses on external listeners](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-addresses-deployment-configuration-kafka)

By default, Strimzi tries to automatically determine the hostnames and ports that your Kafka cluster advertises to its clients. This is not sufficient in all situations, because the infrastructure on which Strimzi is running might not provide the right hostname or port through which Kafka can be accessed. You can customize the advertised hostname and port in the `overrides` property of the external listener. Strimzi will then automatically configure the advertised address in the Kafka brokers and add it to the broker certificates so it can be used for TLS hostname verification. Overriding the advertised host and ports is available for all types of external listeners.  默认情况下，Strimzi会尝试自动确定您的Kafka群集向其客户端发布的主机名和端口。 这在所有情况下都是不够的，因为运行Strimzi的基础架构可能无法提供可访问Kafka的正确主机名或端口。 您可以在外部侦听器的overrides属性中自定义播发的主机名和端口。 然后，Strimzi将在Kafka代理中自动配置广告地址，并将其添加到代理证书中，以便可用于TLS主机名验证。 覆盖公告的主机和端口可用于所有类型的外部侦听器。

Example of an external listener configured with overrides for advertised addresses

```yaml
# ...
listeners:
  external:
    type: route
    authentication:
      type: tls
    overrides:
      brokers:
      - broker: 0
        advertisedHost: example.hostname.0
        advertisedPort: 12340
      - broker: 1
        advertisedHost: example.hostname.1
        advertisedPort: 12341
      - broker: 2
        advertisedHost: example.hostname.2
        advertisedPort: 12342
# ...
```

Additionally, you can specify the name of the bootstrap service. This name will be added to the broker certificates and can be used for TLS hostname verification. Adding the additional bootstrap address is available for all types of external listeners.  此外，您可以指定引导服务的名称。 该名称将添加到代理证书中，并且可用于TLS主机名验证。 添加附加的引导程序地址可用于所有类型的外部侦听器。

Example of an external listener configured with an additional bootstrap address

```yaml
# ...
listeners:
  external:
    type: route
    authentication:
      type: tls
    overrides:
      bootstrap:
        address: example.hostname
# ...
```

###### [Route external listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-routes-deployment-configuration-kafka)

An external listener of type `route` exposes Kafka using OpenShift `Routes` and the HAProxy router.

> NOTE `route` is only supported on OpenShift

[Exposing Kafka using OpenShift `Routes`](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-routes-deployment-configuration-kafka)

When exposing Kafka using OpenShift `Routes` and the HAProxy router, a dedicated `Route` is created for every Kafka broker pod. An additional `Route` is created to serve as a Kafka bootstrap address. Kafka clients can use these `Routes` to connect to Kafka on port 443.

TLS encryption is always used with `Routes`.

By default, the route hosts are automatically assigned by OpenShift. However, you can override the assigned route hosts by specifying the requested hosts in the `overrides` property. Strimzi will not perform any validation that the requested hosts are available; you must ensure that they are free and can be used.

Example of an external listener of type `routes` configured with overrides for OpenShift route hosts

```yaml
# ...
listeners:
  external:
    type: route
    authentication:
      type: tls
    overrides:
      bootstrap:
        host: bootstrap.myrouter.com
      brokers:
      - broker: 0
        host: broker-0.myrouter.com
      - broker: 1
        host: broker-1.myrouter.com
      - broker: 2
        host: broker-2.myrouter.com
# ...
```

For more information on using `Routes` to access Kafka, see [Accessing Kafka using OpenShift routes](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-routes-deployment-configuration-kafka).

[Accessing Kafka using OpenShift routes](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-routes-deployment-configuration-kafka)

Prerequisites

- An OpenShift cluster
- A running Cluster Operator

Procedure

1. Deploy Kafka cluster with an external listener enabled and configured to the type `route`.

   An example configuration with an external listener configured to use `Routes`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         external:
           type: route
           # ...
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   ```shell
   oc apply -f your-file
   ```

3. Find the address of the bootstrap `Route`.

   ```shell
   oc get routes _cluster-name_-kafka-bootstrap -o=jsonpath='{.status.ingress[0].host}{"\n"}'
   ```

   Use the address together with port 443 in your Kafka client as the *bootstrap* address.

4. Extract the public certificate of the broker certification authority

   ```shell
   kubectl get secret _<cluster-name>_-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
   ```

   Use the extracted certificate in your Kafka client to configure TLS connection. If you enabled any authentication, you will also need to configure SASL or TLS authentication.

Additional resources

- For more information about the schema, see [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

###### [Loadbalancer external listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-loadbalancers-deployment-configuration-kafka)

External listeners of type `loadbalancer` expose Kafka by using `Loadbalancer` type `Services`.

[Exposing Kafka using loadbalancers](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-loadbalancers-deployment-configuration-kafka)

When exposing Kafka using `Loadbalancer` type `Services`, a new loadbalancer service is created for every Kafka broker pod. An additional loadbalancer is created to serve as a Kafka *bootstrap* address. Loadbalancers listen to connections on port 9094.

By default, TLS encryption is enabled. To disable it, set the `tls` field to `false`.

Example of an external listener of type `loadbalancer`

```yaml
# ...
listeners:
  external:
    type: loadbalancer
    authentication:
      type: tls
# ...
```

For more information on using loadbalancers to access Kafka, see [Accessing Kafka using loadbalancers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-loadbalancers-deployment-configuration-kafka).

[Customizing the DNS names of external loadbalancer listeners](https://strimzi.io/docs/operators/0.18.0/using.html#customizing_the_dns_names_of_external_loadbalancer_listeners)

On `loadbalancer` listeners, you can use the `dnsAnnotations` property to add additional annotations to the loadbalancer services. You can use these annotations to instrument DNS tooling such as [External DNS](https://github.com/kubernetes-incubator/external-dns), which automatically assigns DNS names to the loadbalancer services.

Example of an external listener of type `loadbalancer` using `dnsAnnotations`

```yaml
# ...
listeners:
  external:
    type: loadbalancer
    authentication:
      type: tls
    overrides:
      bootstrap:
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-bootstrap.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      brokers:
      - broker: 0
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-0.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      - broker: 1
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-1.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      - broker: 2
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-2.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
# ...
```

[Customizing the loadbalancer IP addresses](https://strimzi.io/docs/operators/0.18.0/using.html#customizing_the_loadbalancer_ip_addresses)

On `loadbalancer` listeners, you can use the `loadBalancerIP` property to request a specific IP address when creating a loadbalancer. Use this property when you need to use a loadbalancer with a specific IP address. The `loadBalancerIP` field is ignored if the cloud provider does not support the feature.

Example of an external listener of type `loadbalancer` with specific loadbalancer IP address requests

```yaml
# ...
listeners:
  external:
    type: loadbalancer
    authentication:
      type: tls
    overrides:
      bootstrap:
        loadBalancerIP: 172.29.3.10
      brokers:
      - broker: 0
        loadBalancerIP: 172.29.3.1
      - broker: 1
        loadBalancerIP: 172.29.3.2
      - broker: 2
        loadBalancerIP: 172.29.3.3
# ...
```

[Accessing Kafka using loadbalancers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-loadbalancers-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Deploy Kafka cluster with an external listener enabled and configured to the type `loadbalancer`.

   An example configuration with an external listener configured to use loadbalancers:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         external:
           type: loadbalancer
           authentication:
             type: tls
           # ...
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

3. Find the hostname of the bootstrap loadbalancer.

   This can be done using `kubectl get`:

   ```shell
   kubectl get service cluster-name-kafka-external-bootstrap -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
   ```

   If no hostname was found (nothing was returned by the command), use the loadbalancer IP address.

   This can be done using `kubectl get`:

   ```shell
   kubectl get service cluster-name-kafka-external-bootstrap -o=jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'
   ```

   Use the hostname or IP address together with port 9094 in your Kafka client as the *bootstrap* address.

4. Unless TLS encryption was disabled, extract the public certificate of the broker certification authority.

   This can be done using `kubectl get`:

   ```shell
   kubectl get secret cluster-name-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
   ```

   Use the extracted certificate in your Kafka client to configure TLS connection. If you enabled any authentication, you will also need to configure SASL or TLS authentication.

Additional resources

- For more information about the schema, see [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

###### [Node Port external listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-nodeports-deployment-configuration-kafka)

External listeners of type `nodeport` expose Kafka by using `NodePort` type `Services`.

[Exposing Kafka using node ports](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-nodeports-deployment-configuration-kafka)

When exposing Kafka using `NodePort` type `Services`, Kafka clients connect directly to the nodes of Kubernetes. You must enable access to the ports on the Kubernetes nodes for each client (for example, in firewalls or security groups). Each Kafka broker pod is then accessible on a separate port.

An additional `NodePort` type of service is created to serve as a Kafka bootstrap address.

When configuring the advertised addresses for the Kafka broker pods, Strimzi uses the address of the node on which the given pod is running. Nodes often have multiple addresses. The address type used is based on the first type found in the following order of priority:

1. ExternalDNS
2. ExternalIP
3. Hostname
4. InternalDNS
5. InternalIP

You can use the `preferredAddressType` property in your listener configuration to specify the first address type checked as the node address. This property is useful, for example, if your deployment does not have DNS support, or you only want to expose a broker internally through an internal DNS or IP address. If an address of this type is found, it is used. If the preferred address type is not found, Strimzi proceeds through the types in the standard order of priority.

Example of an external listener configured with a preferred address type

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
spec:
  kafka:
    # ...
    listeners:
      external:
        type: nodeport
        tls: true
        authentication:
          type: tls
        configuration:
          preferredAddressType: InternalDNS
    # ...
  zookeeper:
    # ...
```

By default, TLS encryption is enabled. To disable it, set the `tls` field to `false`.

> NOTE TLS hostname verification is not currently supported when exposing Kafka clusters using node ports.

By default, the port numbers used for the bootstrap and broker services are automatically assigned by Kubernetes. However, you can override the assigned node ports by specifying the requested port numbers in the `overrides` property. Strimzi does not perform any validation on the requested ports; you must ensure that they are free and available for use.

Example of an external listener configured with overrides for node ports

```yaml
# ...
listeners:
  external:
    type: nodeport
    tls: true
    authentication:
      type: tls
    overrides:
      bootstrap:
        nodePort: 32100
      brokers:
      - broker: 0
        nodePort: 32000
      - broker: 1
        nodePort: 32001
      - broker: 2
        nodePort: 32002
# ...
```

For more information on using node ports to access Kafka, see [Accessing Kafka using node ports](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-nodeports-deployment-configuration-kafka).

[Customizing the DNS names of external node port listeners](https://strimzi.io/docs/operators/0.18.0/using.html#customizing_the_dns_names_of_external_node_port_listeners)

On `nodeport` listeners, you can use the `dnsAnnotations` property to add additional annotations to the nodeport services. You can use these annotations to instrument DNS tooling such as [External DNS](https://github.com/kubernetes-incubator/external-dns), which automatically assigns DNS names to the cluster nodes.

Example of an external listener of type `nodeport` using `dnsAnnotations`

```yaml
# ...
listeners:
  external:
    type: nodeport
    tls: true
    authentication:
      type: tls
    overrides:
      bootstrap:
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-bootstrap.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      brokers:
      - broker: 0
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-0.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      - broker: 1
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-1.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
      - broker: 2
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: kafka-broker-2.mydomain.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
# ...
```

[Accessing Kafka using node ports](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-nodeports-deployment-configuration-kafka)

This procedure describes how to access a Strimzi Kafka cluster from an external client using node ports.

To connect to a broker, you need the hostname (advertised address) and port number for the Kafka *bootstrap* address, as well as the certificate used for authentication.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Deploy the Kafka cluster with an external listener enabled and configured to the type `nodeport`.

   For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         external:
           type: nodeport
           tls: true
           authentication:
             type: tls
           configuration:
             brokerCertChainAndKey: (1)
               secretName: my-secret
               certificate: my-certificate.crt
               key: my-key.key
             preferredAddressType: InternalDNS (2)
       # ...
     zookeeper:
       # ...
   ```

   1. Optional configuration for a [Kafka listener certificate](https://strimzi.io/docs/operators/0.18.0/using.html#kafka-listener-certificates-str) managed by an external Certificate Authority. The `brokerCertChainAndKey` property specifies a `Secret` that holds a server certificate and a private key. Kafka listener certificates can also be configured for TLS listeners.
   2. Optional configuration to [specify a preference for the first address type used by Strimzi as the node address](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-nodeports-deployment-configuration-kafka).

2. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

3. Find the port number of the bootstrap service.

   ```shell
   kubectl get service cluster-name-kafka-external-bootstrap -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}'
   ```

   The port is used in the Kafka *bootstrap* address.

4. Find the address of the Kubernetes node.

   ```shell
   kubectl get node node-name -o=jsonpath='{range .status.addresses[*]}{.type}{"\t"}{.address}{"\n"}'
   ```

   If several different addresses are returned, select the address type you want based on the following order:

   1. ExternalDNS
   2. ExternalIP
   3. Hostname
   4. InternalDNS
   5. InternalIP

   Use the address with the port found in the previous step in the Kafka *bootstrap* address.

5. Unless TLS encryption was disabled, extract the public certificate of the broker certification authority.

   ```shell
   kubectl get secret cluster-name-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
   ```

   Use the extracted certificate in your Kafka client to configure TLS connection. If you enabled any authentication, you will also need to configure SASL or TLS authentication.

Additional resources

- For more information about the schema, see [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

###### [Kubernetes Ingress external listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-external-listeners-ingressdeployment-configuration-kafka)

External listeners of type `ingress` exposes Kafka by using Kubernetes `Ingress` and the [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx).

[Exposing Kafka using Kubernetes `Ingress`](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-broker-external-listeners-ingress-deployment-configuration-kafka)

When exposing Kafka using using Kubernetes `Ingress` and the [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx), a dedicated `Ingress` resource is created for every Kafka broker pod. An additional `Ingress` resource is created to serve as a Kafka bootstrap address. Kafka clients can use these `Ingress` resources to connect to Kafka on port 443.

> NOTE External listeners using `Ingress` have been currently tested only with the [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx).

Strimzi uses the TLS passthrough feature of the [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx). Make sure TLS passthrough is enabled in your [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx) deployment. For more information about enabling TLS passthrough see [TLS passthrough documentation](https://kubernetes.github.io/ingress-nginx/user-guide/tls/#ssl-passthrough). Because it is using the TLS passthrough functionality, TLS encryption cannot be disabled when exposing Kafka using `Ingress`.

The Ingress controller does not assign any hostnames automatically. You have to specify the hostnames which should be used by the bootstrap and per-broker services in the `spec.kafka.listeners.external.configuration` section. You also have to make sure that the hostnames resolve to the Ingress endpoints. Strimzi will not perform any validation that the requested hosts are available and properly routed to the Ingress endpoints.

Example of an external listener of type `ingress`

```yaml
# ...
listeners:
  external:
    type: ingress
    authentication:
      type: tls
    configuration:
      bootstrap:
        host: bootstrap.myingress.com
      brokers:
      - broker: 0
        host: broker-0.myingress.com
      - broker: 1
        host: broker-1.myingress.com
      - broker: 2
        host: broker-2.myingress.com
# ...
```

For more information on using `Ingress` to access Kafka, see [Accessing Kafka using ingress](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-ingress-deployment-configuration-kafka).

[Configuring the `Ingress` class](https://strimzi.io/docs/operators/0.18.0/using.html#configuring_the_ingress_class)

By default, the `Ingress` class is set to `nginx`. You can change the `Ingress` class using the `class` property.

Example of an external listener of type `ingress` using `Ingress` class `nginx-internal`

```yaml
# ...
listeners:
  external:
    type: ingress
    class: nginx-internal
    # ...
# ...
```

[Customizing the DNS names of external ingress listeners](https://strimzi.io/docs/operators/0.18.0/using.html#customizing_the_dns_names_of_external_ingress_listeners)

On `ingress` listeners, you can use the `dnsAnnotations` property to add additional annotations to the ingress resources. You can use these annotations to instrument DNS tooling such as [External DNS](https://github.com/kubernetes-incubator/external-dns), which automatically assigns DNS names to the ingress resources.

Example of an external listener of type `ingress` using `dnsAnnotations`

```yaml
# ...
listeners:
  external:
    type: ingress
    authentication:
      type: tls
    configuration:
      bootstrap:
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: bootstrap.myingress.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
        host: bootstrap.myingress.com
      brokers:
      - broker: 0
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: broker-0.myingress.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
        host: broker-0.myingress.com
      - broker: 1
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: broker-1.myingress.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
        host: broker-1.myingress.com
      - broker: 2
        dnsAnnotations:
          external-dns.alpha.kubernetes.io/hostname: broker-2.myingress.com.
          external-dns.alpha.kubernetes.io/ttl: "60"
        host: broker-2.myingress.com
# ...
```

[Accessing Kafka using ingress](https://strimzi.io/docs/operators/0.18.0/using.html#proc-accessing-kafka-using-ingress-deployment-configuration-kafka)

This procedure shows how to access Strimzi Kafka clusters from outside of Kubernetes using Ingress.

Prerequisites

- An Kubernetes cluster
- Deployed [NGINX Ingress Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx) with TLS passthrough enabled
- A running Cluster Operator

Procedure

1. Deploy Kafka cluster with an external listener enabled and configured to the type `ingress`.

   An example configuration with an external listener configured to use `Ingress`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         external:
           type: ingress
           authentication:
             type: tls
           configuration:
             bootstrap:
               host: bootstrap.myingress.com
             brokers:
             - broker: 0
               host: broker-0.myingress.com
             - broker: 1
               host: broker-1.myingress.com
             - broker: 2
               host: broker-2.myingress.com
       # ...
     zookeeper:
       # ...
   ```

2. Make sure the hosts in the `configuration` section properly resolve to the Ingress endpoints.

3. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

4. Extract the public certificate of the broker certificate authority

   ```shell
   kubectl get secret cluster-name-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
   ```

5. Use the extracted certificate in your Kafka client to configure the TLS connection. If you enabled any authentication, you will also need to configure SASL or TLS authentication. Connect with your client to the host you specified in the configuration on port 443.

Additional resources

- For more information about the schema, see [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

##### [Network policies](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-listener-network-policies-deployment-configuration-kafka)

Strimzi automatically creates a `NetworkPolicy` resource for every listener that is enabled on a Kafka broker. By default, a `NetworkPolicy` grants access to a listener to all applications and namespaces.

If you want to restrict access to a listener at the network level to only selected applications or namespaces, use the `networkPolicyPeers` field.

Use network policies in conjunction with authentication and authorization.

Each listener can have a different `networkPolicyPeers` configuration.

###### [Network policy configuration for a listener](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-listener-network-policy-example-deployment-configuration-kafka)

The following example shows a `networkPolicyPeers` configuration for a `plain` and a `tls` listener:

```yaml
# ...
listeners:
  plain:
    authentication:
      type: scram-sha-512
    networkPolicyPeers:
      - podSelector:
          matchLabels:
            app: kafka-sasl-consumer
      - podSelector:
          matchLabels:
            app: kafka-sasl-producer
  tls:
    authentication:
      type: tls
    networkPolicyPeers:
      - namespaceSelector:
          matchLabels:
            project: myproject
      - namespaceSelector:
          matchLabels:
            project: myproject2
# ...
```

In the example:

- Only application pods matching the labels `app: kafka-sasl-consumer` and `app: kafka-sasl-producer` can connect to the `plain` listener. The application pods must be running in the same namespace as the Kafka broker.
- Only application pods running in namespaces matching the labels `project: myproject` and `project: myproject2` can connect to the `tls` listener.

The syntax of the `networkPolicyPeers` field is the same as the `from` field in `NetworkPolicy` resources. For more information about the schema, see [NetworkPolicyPeer API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#networkpolicypeer-v1-networking-k8s-io) and the [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

> NOTE Your configuration of Kubernetes must support ingress NetworkPolicies in order to use network policies in Strimzi.

###### [Restricting access to Kafka listeners using `networkPolicyPeers`](https://strimzi.io/docs/operators/0.18.0/using.html#proc-restricting-access-to-listeners-using-network-policies-deployment-configuration-kafka)

You can restrict access to a listener to only selected applications by using the `networkPolicyPeers` field.

Prerequisites

- A Kubernetes cluster with support for Ingress NetworkPolicies.
- The Cluster Operator is running.

Procedure

1. Open the `Kafka` resource.

2. In the `networkPolicyPeers` field, define the application pods or namespaces that will be allowed to access the Kafka cluster.

   For example, to configure a `tls` listener to allow connections only from application pods with the label `app` set to `kafka-client`:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         tls:
           networkPolicyPeers:
             - podSelector:
                 matchLabels:
                   app: kafka-client
       # ...
     zookeeper:
       # ...
   ```

3. Create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For more information about the schema, see [NetworkPolicyPeer API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#networkpolicypeer-v1-networking-k8s-io) and the [`KafkaListeners` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaListeners-reference).

#### [3.1.7. Authentication and Authorization](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-authentication-and-authorization-deployment-configuration-kafka)

Strimzi supports authentication and authorization. Authentication can be configured independently for each [listener](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-kafka-broker-listeners-deployment-configuration-kafka). Authorization is always configured for the whole Kafka cluster.

##### [Authentication](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authentication-deployment-configuration-kafka)

Authentication is configured as part of the [listener configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-kafka-broker-listeners-deployment-configuration-kafka) in the `authentication` property. The authentication mechanism is defined by the `type` field.

When the `authentication` property is missing, no authentication is enabled on a given listener. The listener will accept all connections without authentication.

Supported authentication mechanisms:

- TLS client authentication
- SASL SCRAM-SHA-512
- [OAuth 2.0 token based authentication](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-oauth-authentication_str)

###### [TLS client authentication](https://strimzi.io/docs/operators/0.18.0/using.html#tls_client_authentication)

TLS Client authentication is enabled by specifying the `type` as `tls`. The TLS client authentication is supported only on the `tls` listener.

An example of `authentication` with type `tls`

```yaml
# ...
authentication:
  type: tls
# ...
```

##### [Configuring authentication in Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-kafka-authentication-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster is available.
- The Cluster Operator is running.

Procedure

1. Open the YAML configuration file that contains the `Kafka` resource specifying the cluster deployment.

2. In the `spec.kafka.listeners` property in the `Kafka` resource, add the `authentication` field to the listeners for which you want to enable authentication. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       listeners:
         tls:
           authentication:
             type: tls
       # ...
     zookeeper:
       # ...
   ```

3. Apply the new configuration to create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f kafka.yaml
   ```

   where `*kafka.yaml*` is the YAML configuration file for the resource that you want to configure; for example, `kafka-persistent.yaml`.

Additional resources

- For more information about the supported authentication mechanisms, see [authentication reference](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authentication-deployment-configuration-kafka).
- For more information about the schema for `Kafka`, see [`Kafka` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Kafka-reference).

##### [Authorization](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authorization-deployment-configuration-kafka)

You can configure authorization for Kafka brokers using the `authorization` property in the `Kafka.spec.kafka` resource. If the `authorization` property is missing, no authorization is enabled. When enabled, authorization is applied to all enabled [listeners](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-kafka-broker-listeners-deployment-configuration-kafka). The authorization method is defined in the `type` field.

You can configure:

- Simple authorization
- [OAuth 2.0 authorization](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-oauth-authorization_str) (if you are using OAuth 2.0 token based authentication)

###### [Simple authorization](https://strimzi.io/docs/operators/0.18.0/using.html#simple_authorization)

Simple authorization in Strimzi uses the `SimpleAclAuthorizer` plugin, the default Access Control Lists (ACLs) authorization plugin provided with Apache Kafka. ACLs allow you to define which users have access to which resources at a granular level. To enable simple authorization, set the `type` field to `simple`.

An example of Simple authorization

```yaml
# ...
authorization:
  type: simple
# ...
```

Access rules for users are [defined using Access Control Lists (ACLs)](https://strimzi.io/docs/operators/0.18.0/using.html#simple-acl-str). You can optionally designate a list of super users in the `superUsers` field.

###### [Super users](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authorization-super-user-deployment-configuration-kafka)

Super users can access all resources in your Kafka cluster regardless of any access restrictions defined in ACLs. To designate super users for a Kafka cluster, enter a list of user principles in the `superUsers` field. If a user uses TLS Client Authentication, the username will be the common name from their certificate subject prefixed with `CN=`.

An example of designating super users

```yaml
# ...
authorization:
  type: simple
  superUsers:
    - CN=fred
    - sam
    - CN=edward
# ...
```

> NOTE The `super.user` configuration option in the `config` property in `Kafka.spec.kafka` is ignored. Designate super users in the `authorization` property instead. For more information, see [Kafka broker configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-broker-configuration-deployment-configuration-kafka).

##### [Configuring authorization in Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-kafka-authorization-deployment-configuration-kafka)

Configure authorization and designate super users for a particular Kafka broker.

Prerequisites

- A Kubernetes cluster
- The Cluster Operator is running

Procedure

1. Add or edit the `authorization` property in the `Kafka.spec.kafka` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       authorization:
         type: simple
         superUsers:
           - CN=fred
           - sam
           - CN=edward
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For more information about the supported authorization methods, see [authorization reference](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-authorization-deployment-configuration-kafka).
- For more information about the schema for `Kafka`, see [`Kafka` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Kafka-reference).
- For more information about configuring user authentication, see [Kafka User resource](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-user-str).

#### [3.1.8. ZooKeeper replicas](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-zookeeper-replicas-deployment-configuration-kafka)

ZooKeeper clusters or ensembles usually run with an odd number of nodes, typically three, five, or seven.

The majority of nodes must be available in order to maintain an effective quorum. If the ZooKeeper cluster loses its quorum, it will stop responding to clients and the Kafka brokers will stop working. Having a stable and highly available ZooKeeper cluster is crucial for Strimzi.

- Three-node cluster

  A three-node ZooKeeper cluster requires at least two nodes to be up and running in order to maintain the quorum. It can tolerate only one node being unavailable.

- Five-node cluster

  A five-node ZooKeeper cluster requires at least three nodes to be up and running in order to maintain the quorum. It can tolerate two nodes being unavailable.

- Seven-node cluster

  A seven-node ZooKeeper cluster requires at least four nodes to be up and running in order to maintain the quorum. It can tolerate three nodes being unavailable.

| NOTE | For development purposes, it is also possible to run ZooKeeper with a single node. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Having more nodes does not necessarily mean better performance, as the costs to maintain the quorum will rise with the number of nodes in the cluster. Depending on your availability requirements, you can decide for the number of nodes to use.

##### [Number of ZooKeeper nodes](https://strimzi.io/docs/operators/0.18.0/using.html#ref-zookeeper-replicas-deployment-configuration-kafka)

The number of ZooKeeper nodes can be configured using the `replicas` property in `Kafka.spec.zookeeper`.

An example showing replicas configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
    replicas: 3
    # ...
```

##### [Changing the number of ZooKeeper replicas](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-zookeeper-replicas-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster is available.
- The Cluster Operator is running.

Procedure

1. Open the YAML configuration file that contains the `Kafka` resource specifying the cluster deployment.

2. In the `spec.zookeeper.replicas` property in the `Kafka` resource, enter the number of replicated ZooKeeper servers. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
     zookeeper:
       # ...
       replicas: 3
       # ...
   ```

3. Apply the new configuration to create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f kafka.yaml
   ```

   where `*kafka.yaml*` is the YAML configuration file for the resource that you want to configure; for example, `kafka-persistent.yaml`.

#### [3.1.9. ZooKeeper configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-zookeeper-node-configuration-deployment-configuration-kafka)

Strimzi allows you to customize the configuration of Apache ZooKeeper nodes. You can specify and configure most of the options listed in the [ZooKeeper documentation](http://zookeeper.apache.org/doc/r3.4.13/zookeeperAdmin.html).

Options which cannot be configured are those related to the following areas:

- Security (Encryption, Authentication, and Authorization)
- Listener configuration
- Configuration of data directories
- ZooKeeper cluster composition

These options are automatically configured by Strimzi.

##### [ZooKeeper configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-zookeeper-node-configuration-deployment-configuration-kafka)

ZooKeeper nodes are configured using the `config` property in `Kafka.spec.zookeeper`. This property contains the ZooKeeper configuration options as keys. The values can be described using one of the following JSON types:

- String
- Number
- Boolean

Users can specify and configure the options listed in [ZooKeeper documentation](http://zookeeper.apache.org/doc/r3.4.13/zookeeperAdmin.html) with the exception of those options which are managed directly by Strimzi. Specifically, all configuration options with keys equal to or starting with one of the following strings are forbidden:

- `server.`
- `dataDir`
- `dataLogDir`
- `clientPort`
- `authProvider`
- `quorum.auth`
- `requireClientAuthScheme`

When one of the forbidden options is present in the `config` property, it is ignored and a warning message is printed to the Custer Operator log file. All other options are passed to ZooKeeper.

| IMPORTANT | The Cluster Operator does not validate keys or values in the provided `config` object. When invalid configuration is provided, the ZooKeeper cluster might not start or might become unstable. In such cases, the configuration in the `Kafka.spec.zookeeper.config` object should be fixed and the Cluster Operator will roll out the new configuration to all ZooKeeper nodes. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

Selected options have default values:

- `timeTick` with default value `2000`
- `initLimit` with default value `5`
- `syncLimit` with default value `2`
- `autopurge.purgeInterval` with default value `1`

These options will be automatically configured when they are not present in the `Kafka.spec.zookeeper.config` property.

An example showing ZooKeeper configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
spec:
  kafka:
    # ...
  zookeeper:
    # ...
    config:
      autopurge.snapRetainCount: 3
      autopurge.purgeInterval: 1
    # ...
```

##### [Configuring ZooKeeper](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-zookeeper-nodes-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster is available.
- The Cluster Operator is running.

Procedure

1. Open the YAML configuration file that contains the `Kafka` resource specifying the cluster deployment.

2. In the `spec.zookeeper.config` property in the `Kafka` resource, enter one or more ZooKeeper configuration settings. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
     zookeeper:
       # ...
       config:
         autopurge.snapRetainCount: 3
         autopurge.purgeInterval: 1
       # ...
   ```

3. Apply the new configuration to create or update the resource.

   Use `kubectl apply`:

   ```shell
   kubectl apply -f kafka.yaml
   ```

   where `*kafka.yaml*` is the YAML configuration file for the resource that you want to configure; for example, `kafka-persistent.yaml`.

#### [3.1.10. ZooKeeper connection](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-zookeeper-connection-deployment-configuration-kafka)

ZooKeeper services are secured with encryption and authentication and are not intended to be used by external applications that are not part of Strimzi.

However, if you want to use Kafka CLI tools that require a connection to ZooKeeper, such as the `kafka-topics` tool, you can use a terminal inside a Kafka container and connect to the local end of the TLS tunnel to ZooKeeper by using `localhost:2181` as the ZooKeeper address.

##### [Connecting to ZooKeeper from a terminal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-connnecting-to-zookeeper-deployment-configuration-kafka)

Open a terminal inside a Kafka container to use Kafka CLI tools that require a ZooKeeper connection.

Prerequisites

- A Kubernetes cluster is available.
- A kafka cluster is running.
- The Cluster Operator is running.

Procedure

1. Open the terminal using the Kubernetes console or run the `exec` command from your CLI.

   For example:

   ```shell
   kubectl exec -it my-cluster-kafka-0 -- bin/kafka-topics.sh --list --zookeeper localhost:2181
   ```

   Be sure to use `localhost:2181`.

   You can now run Kafka commands to ZooKeeper.

#### [3.1.11. Entity Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-entity-operator-deployment-configuration-kafka)

The Entity Operator is responsible for managing Kafka-related entities in a running Kafka cluster.

The Entity Operator comprises the:

- [Topic Operator](https://strimzi.io/docs/operators/0.18.0/using.html#overview-concepts-topic-operator-str) to manage Kafka topics
- [User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#overview-concepts-user-operator-str) to manage Kafka users

Through `Kafka` resource configuration, the Cluster Operator can deploy the Entity Operator, including one or both operators, when deploying a Kafka cluster.

| NOTE | When deployed, the Entity Operator contains the operators according to the deployment configuration. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

The operators are automatically configured to manage the topics and users of the Kafka cluster.

##### [Entity Operator configuration properties](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-entity-operator-deployment-configuration-kafka)

Use the `entityOperator` property in `Kafka.spec` to configure the Entity Operator.

The `entityOperator` property supports several sub-properties:

- `tlsSidecar`
- `topicOperator`
- `userOperator`
- `template`

The `tlsSidecar` property contains the configuration of the TLS sidecar container, which is used to communicate with ZooKeeper. For more information on configuring the TLS sidecar, see [TLS sidecar](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-tls-sidecar-deployment-configuration-kafka).

The `template` property contains the configuration of the Entity Operator pod, such as labels, annotations, affinity, and tolerations. For more information on configuring templates, see [Template properties](https://strimzi.io/docs/operators/0.18.0/using.html#con-customizing-template-properties-str).

The `topicOperator` property contains the configuration of the Topic Operator. When this option is missing, the Entity Operator is deployed without the Topic Operator.

The `userOperator` property contains the configuration of the User Operator. When this option is missing, the Entity Operator is deployed without the User Operator.

For more information on the properties to configure the Entity Operator, see the [`EntityUserOperatorSpec` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-EntityUserOperatorSpec-reference).

Example of basic configuration enabling both operators

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    topicOperator: {}
    userOperator: {}
```

If an empty object (`{}`) is used for the `topicOperator` and `userOperator`, all properties use their default values.

When both `topicOperator` and `userOperator` properties are missing, the Entity Operator is not deployed.

##### [Topic Operator configuration properties](https://strimzi.io/docs/operators/0.18.0/using.html#topic-operator-deployment-configuration-kafka)

Topic Operator deployment can be configured using additional options inside the `topicOperator` object. The following properties are supported:

- `watchedNamespace`

  The Kubernetes namespace in which the topic operator watches for `KafkaTopics`. Default is the namespace where the Kafka cluster is deployed.

- `reconciliationIntervalSeconds`

  The interval between periodic reconciliations in seconds. Default `90`.

- `zookeeperSessionTimeoutSeconds`

  The ZooKeeper session timeout in seconds. Default `20`.

- `topicMetadataMaxAttempts`

  The number of attempts at getting topic metadata from Kafka. The time between each attempt is defined as an exponential back-off. Consider increasing this value when topic creation could take more time due to the number of partitions or replicas. Default `6`.

- `image`

  The `image` property can be used to configure the container image which will be used. For more details about configuring custom container images, see [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).

- `resources`

  The `resources` property configures the amount of resources allocated to the Topic Operator. For more details about resource request and limit configuration, see [CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka).

- `logging`

  The `logging` property configures the logging of the Topic Operator. For more details, see [Operator loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-entity-operator-logging-deployment-configuration-kafka).

Example of Topic Operator configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    # ...
    topicOperator:
      watchedNamespace: my-topic-namespace
      reconciliationIntervalSeconds: 60
    # ...
```

##### [User Operator configuration properties](https://strimzi.io/docs/operators/0.18.0/using.html#user-operator-deployment-configuration-kafka)

User Operator deployment can be configured using additional options inside the `userOperator` object. The following properties are supported:

- `watchedNamespace`

  The Kubernetes namespace in which the user operator watches for `KafkaUsers`. Default is the namespace where the Kafka cluster is deployed.

- `reconciliationIntervalSeconds`

  The interval between periodic reconciliations in seconds. Default `120`.

- `zookeeperSessionTimeoutSeconds`

  The ZooKeeper session timeout in seconds. Default `6`.

- `image`

  The `image` property can be used to configure the container image which will be used. For more details about configuring custom container images, see [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).

- `resources`

  The `resources` property configures the amount of resources allocated to the User Operator. For more details about resource request and limit configuration, see [CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka).

- `logging`

  The `logging` property configures the logging of the User Operator. For more details, see [Operator loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-entity-operator-logging-deployment-configuration-kafka).

Example of User Operator configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    # ...
    userOperator:
      watchedNamespace: my-user-namespace
      reconciliationIntervalSeconds: 60
    # ...
```

##### [Operator loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-entity-operator-logging-deployment-configuration-kafka)

The Topic Operator and User Operator have a configurable logger:

- `rootLogger.level`

The operators use the Apache `log4j2` logger implementation.

Use the `logging` property in the `Kafka` resource to configure loggers and logger levels.

You can set the log levels by specifying the logger and level directly (inline) or use a custom (external) ConfigMap. If a ConfigMap is used, you set `logging.name` property to the name of the ConfigMap containing the external logging configuration. Inside the ConfigMap, the logging configuration is described using `log4j2.properties`.

Here we see examples of `inline` and `external` logging.

Inline logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    # ...
    topicOperator:
      watchedNamespace: my-topic-namespace
      reconciliationIntervalSeconds: 60
      logging:
        type: inline
        loggers:
          rootLogger.level: INFO
    # ...
    userOperator:
      watchedNamespace: my-topic-namespace
      reconciliationIntervalSeconds: 60
      logging:
        type: inline
        loggers:
          rootLogger.level: INFO
# ...
```

External logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    # ...
    topicOperator:
      watchedNamespace: my-topic-namespace
      reconciliationIntervalSeconds: 60
      logging:
        type: external
        name: customConfigMap
# ...
```

Additional resources

- Garbage collector (GC) logging can also be enabled (or disabled). For more information about GC logging, see [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka)
- For more information about log levels, see [Apache logging services](https://logging.apache.org/).

##### [Configuring the Entity Operator](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-entity-operator-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `entityOperator` property in the `Kafka` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
     zookeeper:
       # ...
     entityOperator:
       topicOperator:
         watchedNamespace: my-topic-namespace
         reconciliationIntervalSeconds: 60
       userOperator:
         watchedNamespace: my-user-namespace
         reconciliationIntervalSeconds: 60
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.12. CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka)

For every deployed container, Strimzi allows you to request specific resources and define the maximum consumption of those resources.

Strimzi supports two types of resources:

- CPU
- Memory

Strimzi uses the Kubernetes syntax for specifying CPU and memory resources.

##### [Resource limits and requests](https://strimzi.io/docs/operators/0.18.0/using.html#ref-resource-limits-and-requests-deployment-configuration-kafka)

Resource limits and requests are configured using the `resources` property in the following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.KafkaExporter`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaBridge.spec`

Additional resources

- For more information about managing computing resources on Kubernetes, see [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

###### [Resource requests](https://strimzi.io/docs/operators/0.18.0/using.html#resource_requests)

Requests specify the resources to reserve for a given container. Reserving the resources ensures that they are always available.

| IMPORTANT | If the resource request is for more than the available free resources in the Kubernetes cluster, the pod is not scheduled. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

Resources requests are specified in the `requests` property. Resources requests currently supported by Strimzi:

- `cpu`
- `memory`

A request may be configured for one or more supported resources.

Example resource request configuration with all resources

```yaml
# ...
resources:
  requests:
    cpu: 12
    memory: 64Gi
# ...
```

###### [Resource limits](https://strimzi.io/docs/operators/0.18.0/using.html#resource_limits)

Limits specify the maximum resources that can be consumed by a given container. The limit is not reserved and might not always be available. A container can use the resources up to the limit only when they are available. Resource limits should be always higher than the resource requests.

Resource limits are specified in the `limits` property. Resource limits currently supported by Strimzi:

- `cpu`
- `memory`

A resource may be configured for one or more supported limits.

Example resource limits configuration

```yaml
# ...
resources:
  limits:
    cpu: 12
    memory: 64Gi
# ...
```

###### [Supported CPU formats](https://strimzi.io/docs/operators/0.18.0/using.html#supported_cpu_formats)

CPU requests and limits are supported in the following formats:

- Number of CPU cores as integer (`5` CPU core) or decimal (`2.5` CPU core).
- Number or *millicpus* / *millicores* (`100m`) where 1000 *millicores* is the same `1` CPU core.

Example CPU units

```yaml
# ...
resources:
  requests:
    cpu: 500m
  limits:
    cpu: 2.5
# ...
```

| NOTE | The computing power of 1 CPU core may differ depending on the platform where Kubernetes is deployed. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Additional resources

- For more information on CPU specification, see the [Meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

###### [Supported memory formats](https://strimzi.io/docs/operators/0.18.0/using.html#supported_memory_formats)

Memory requests and limits are specified in megabytes, gigabytes, mebibytes, and gibibytes.

- To specify memory in megabytes, use the `M` suffix. For example `1000M`.
- To specify memory in gigabytes, use the `G` suffix. For example `1G`.
- To specify memory in mebibytes, use the `Mi` suffix. For example `1000Mi`.
- To specify memory in gibibytes, use the `Gi` suffix. For example `1Gi`.

An example of using different memory units

```yaml
# ...
resources:
  requests:
    memory: 512Mi
  limits:
    memory: 2Gi
# ...
```

Additional resources

- For more details about memory specification and additional supported units, see [Meaning of memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).

##### [Configuring resource requests and limits](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-resource-limits-and-requests-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `resources` property in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       resources:
         requests:
           cpu: "8"
           memory: 64Gi
         limits:
           cpu: "12"
           memory: 128Gi
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For more information about the schema, see [`Resources` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-ResourceRequirements-reference).

#### [3.1.13. Kafka loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-logging-deployment-configuration-kafka)

Kafka has its own configurable loggers:

- `kafka.root.logger.level`
- `log4j.logger.org.I0Itec.zkclient.ZkClient`
- `log4j.logger.org.apache.zookeeper`
- `log4j.logger.kafka`
- `log4j.logger.org.apache.kafka`
- `log4j.logger.kafka.request.logger`
- `log4j.logger.kafka.network.Processor`
- `log4j.logger.kafka.server.KafkaApis`
- `log4j.logger.kafka.network.RequestChannel$`
- `log4j.logger.kafka.controller`
- `log4j.logger.kafka.log.LogCleaner`
- `log4j.logger.state.change.logger`
- `log4j.logger.kafka.authorizer.logger`

ZooKeeper also has a configurable logger:

- `zookeeper.root.logger`

Kafka and ZooKeeper use the Apache `log4j` logger implementation.

Use the `logging` property to configure loggers and logger levels.

You can set the log levels by specifying the logger and level directly (inline) or use a custom (external) ConfigMap. If a ConfigMap is used, you set `logging.name` property to the name of the ConfigMap containing the external logging configuration. Inside the ConfigMap, the logging configuration is described using `log4j.properties`.

Here we see examples of `inline` and `external` logging.

Inline logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
spec:
  # ...
  logging:
    type: inline
    loggers:
      kafka.root.logger.level: "INFO"
  # ...
  zookeeper:
    # ...
    logging:
      type: inline
      loggers:
        zookeeper.root.logger: "INFO"
  # ...
  entityOperator:
    # ...
    topicOperator:
      # ...
      logging:
        type: inline
        loggers:
          rootLogger.level: INFO
    # ...
    userOperator:
      # ...
      logging:
        type: inline
        loggers:
          rootLogger.level: INFO
    # ...
```

External logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
spec:
  # ...
  logging:
    type: external
    name: customConfigMap
  # ...
```

Operators use the Apache `log4j2` logger implementation, so the logging configuration is described inside the ConfigMap using `log4j2.properties`. For more information, see [Operator loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-entity-operator-logging-deployment-configuration-kafka).

Additional resources

- Garbage collector (GC) logging can also be enabled (or disabled). For more information on garbage collection, see [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka)
- For more information about log levels, see [Apache logging services](https://logging.apache.org/).

#### [3.1.14. Kafka rack awareness](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-rack-deployment-configuration-kafka)

The rack awareness feature in Strimzi helps to spread the Kafka broker pods and Kafka topic replicas across different racks. Enabling rack awareness helps to improve availability of Kafka brokers and the topics they are hosting.

| NOTE | "Rack" might represent an availability zone, data center, or an actual rack in your data center. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

##### [Configuring rack awareness in Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-rack-awareness-deployment-configuration-kafka)

Kafka rack awareness can be configured in the `rack` property of `Kafka.spec.kafka`. The `rack` object has one mandatory field named `topologyKey`. This key needs to match one of the labels assigned to the Kubernetes cluster nodes. The label is used by Kubernetes when scheduling the Kafka broker pods to nodes. If the Kubernetes cluster is running on a cloud provider platform, that label should represent the availability zone where the node is running. Usually, the nodes are labeled with `failure-domain.beta.kubernetes.io/zone` that can be easily used as the `topologyKey` value. This has the effect of spreading the broker pods across zones, and also setting the brokers' `broker.rack` configuration parameter inside Kafka broker.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Consult your Kubernetes administrator regarding the node label that represents the zone / rack into which the node is deployed.

2. Edit the `rack` property in the `Kafka` resource using the label as the topology key.

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       rack:
         topologyKey: failure-domain.beta.kubernetes.io/zone
       # ...
   ```

3. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For information about Configuring init container image for Kafka rack awareness, see [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).

#### [3.1.15. Healthchecks](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka)

Healthchecks are periodical tests which verify the health of an application. When a Healthcheck probe fails, Kubernetes assumes that the application is not healthy and attempts to fix it.

Kubernetes supports two types of Healthcheck probes:

- Liveness probes
- Readiness probes

For more details about the probes, see [Configure Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/). Both types of probes are used in Strimzi components.

Users can configure selected options for liveness and readiness probes.

##### [Healthcheck configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-healthchecks-deployment-configuration-kafka)

Liveness and readiness probes can be configured using the `livenessProbe` and `readinessProbe` properties in following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.KafkaExporter`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaMirrorMaker.spec`
- `KafkaBridge.spec`

Both `livenessProbe` and `readinessProbe` support the following options:

- `initialDelaySeconds`
- `timeoutSeconds`
- `periodSeconds`
- `successThreshold`
- `failureThreshold`

For more information about the `livenessProbe` and `readinessProbe` options, see [`Probe` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Probe-reference).

An example of liveness and readiness probe configuration

```yaml
# ...
readinessProbe:
  initialDelaySeconds: 15
  timeoutSeconds: 5
livenessProbe:
  initialDelaySeconds: 15
  timeoutSeconds: 5
# ...
```

##### [Configuring healthchecks](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-healthchecks-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `livenessProbe` or `readinessProbe` property in the `Kafka`, `KafkaConnect` or `KafkaConnectS2I` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       readinessProbe:
         initialDelaySeconds: 15
         timeoutSeconds: 5
       livenessProbe:
         initialDelaySeconds: 15
         timeoutSeconds: 5
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.16. Prometheus metrics](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-metrics-deployment-configuration-kafka)

Strimzi supports Prometheus metrics using [Prometheus JMX exporter](https://github.com/prometheus/jmx_exporter) to convert the JMX metrics supported by Apache Kafka and ZooKeeper to Prometheus metrics. When metrics are enabled, they are exposed on port 9404.

For more information about setting up and deploying Prometheus and Grafana, see [Introducing Metrics to Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str).

##### [Metrics configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-metrics-deployment-configuration-kafka)

Prometheus metrics are enabled by configuring the `metrics` property in following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.zookeeper`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`

When the `metrics` property is not defined in the resource, the Prometheus metrics will be disabled. To enable Prometheus metrics export without any further configuration, you can set it to an empty object (`{}`).

Example of enabling metrics without any further configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    metrics: {}
    # ...
  zookeeper:
    # ...
```

The `metrics` property might contain additional configuration for the [Prometheus JMX exporter](https://github.com/prometheus/jmx_exporter).

Example of enabling metrics with additional Prometheus JMX Exporter configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    metrics:
      lowercaseOutputName: true
      rules:
        - pattern: "kafka.server<type=(.+), name=(.+)PerSec\\w*><>Count"
          name: "kafka_server_$1_$2_total"
        - pattern: "kafka.server<type=(.+), name=(.+)PerSec\\w*, topic=(.+)><>Count"
          name: "kafka_server_$1_$2_total"
          labels:
            topic: "$3"
    # ...
  zookeeper:
    # ...
```

##### [Configuring Prometheus metrics](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-metrics-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `metrics` property in the `Kafka`, `KafkaConnect` or `KafkaConnectS2I` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
     zookeeper:
       # ...
       metrics:
         lowercaseOutputName: true
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.17. JMX Options](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-jmx-options-deployment-configuration-kafka)

Strimzi supports obtaining JMX metrics from the Kafka brokers by opening a JMX port on 9999. You can obtain various metrics about each Kafka broker, for example, usage data such as the `BytesPerSecond` value or the request rate of the network of the broker. Strimzi supports opening a password and username protected JMX port or a non-protected JMX port.

##### [Configuring JMX options](https://strimzi.io/docs/operators/0.18.0/using.html#proc-kafka-jmx-options-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

You can configure JMX options by using the `jmxOptions` property in the following resources:

- `Kafka.spec.kafka`

You can configure username and password protection for the JMX port that is opened on the Kafka brokers.

Securing the JMX Port

You can secure the JMX port to prevent unauthorized pods from accessing the port. Currently the JMX port can only be secured using a username and password. To enable security for the JMX port, set the `type` parameter in the `authentication` field to `password`.:

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    jmxOptions:
      authentication:
        type: "password"
    # ...
  zookeeper:
    # ...
```

This allows you to deploy a pod internally into a cluster and obtain JMX metrics by using the headless service and specifying which broker you want to address. To get JMX metrics from broker *0* we address the headless service appending broker *0* in front of the headless service:

```shell
"<cluster-name>-kafka-0-<cluster-name>-<headless-service-name>"
```

If the JMX port is secured, you can get the username and password by referencing them from the JMX secret in the deployment of your pod.

Using an open JMX port

To disable security for the JMX port, do not fill in the `authentication` field

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    jmxOptions: {}
    # ...
  zookeeper:
    # ...
```

This will just open the JMX Port on the headless service and you can follow a similar approach as described above to deploy a pod into the cluster. The only difference is that any pod will be able to read from the JMX port.

#### [3.1.18. Retrieving JMX metrics with JMXTrans](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-jmxtrans-deployment-configuration-kafka)

JmxTrans is a way of retrieving JMX metrics data from Java processes and pushing that data in various formats to remote sinks inside or outside of the cluster. JmxTrans can communicate with a secure JMX port. Strimzi supports using JmxTrans to read JMX data from Kafka brokers.

##### [Jmxtrans](https://strimzi.io/docs/operators/0.18.0/using.html#con-jmxtrans-deployment-configuration-kafka)

JmxTrans reads JMX metrics data from secure or insecure Kafka brokers and pushes the data to remote sinks in various data formats. An example use case of the Jmxtrans would be to obtain JMX metrics about the request rate of each Kafka broker’s network and push it to a Logstash database outside of the Kubernetes cluster.

##### [Configuring a JMXTrans deployment](https://strimzi.io/docs/operators/0.18.0/using.html#proc-jmxtrans-deployment-deployment-configuration-kafka)

Prerequisites

- A running Kubernetes cluster

You can configure a JmxTrans deployment by using the `Kafka.spec.jmxTrans` property. A JmxTrans deployment can read from a secure or insecure Kafka broker. To configure a JmxTrans deployment, define the following properties:

- `Kafka.spec.jmxTrans.outputDefinitions`
- `Kafka.spec.jmxTrans.kafkaQueries`

For more information on these properties see, [JmxTransSpec schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-JmxTransSpec-reference).

| NOTE | JmxTrans will not come up enable you specify that JmxOptions on the Kafka broker. For more information see, [Kafka Jmx Options](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-jmx-options-deployment-configuration-kafka) .Configuring JmxTrans output definitions |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Output definitions specify where JMX metrics are pushed to, and in which data format. For information about supported data formats, see [Data formats](https://github.com/jmxtrans/jmxtrans/wiki/OutputWriters). How many seconds JmxTrans agent waits for before pushing new data can be configured through the `flushDelay` property. The `host` and `port` properties define the target host address and target port the data is pushed to. The `name` property is a required property that is referenced by the `Kafka.spec.kafka.jmxOptions.jmxTrans.queries` property.

Here is an example configuration pushing JMX data in the Graphite format every 5 seconds to a Logstash database on http://myLogstash:9999, and another pushing to `standardOut` (standard output):

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  jmxTrans:
    outputDefinitions:
      - outputType: "com.googlecode.jmxtrans.model.output.GraphiteWriter"
        host: "http://myLogstash"
        port: 9999
        flushDelay: 5
        name: "logstash"
      - outputType: "com.googlecode.jmxtrans.model.output.StdOutWriter"
        name: "standardOut"
        # ...
    # ...
  zookeeper:
    # ...
```

Configuring JmxTrans queries

JmxTrans queries specify what JMX metrics are read from the Kafka brokers. Currently JmxTrans queries can only be sent to the Kafka Brokers. Configure the `targetMBean` property to specify which target MBean on the Kafka broker is addressed. Configuring the `attributes` property specifies which MBean attribute is read as JMX metrics from the target MBean. JmxTrans supports wildcards to read from target MBeans, and filter by specifying the `typenames`. The `outputs` property defines where the metrics are pushed to by specifying the name of the output definitions.

The following JmxTrans deployment reads from all MBeans that match the pattern `kafka.server:type=BrokerTopicMetrics,name=*` and have `name` in the target MBean’s name. From those Mbeans, it obtains JMX metrics about the `Count` attribute and pushes the metrics to standard output as defined by `outputs`.

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  # ...
  jmxTrans:
    kafkaQueries:
      - targetMBean: "kafka.server:type=BrokerTopicMetrics,*"
        typeNames: ["name"]
        attributes:  ["Count"]
        outputs: ["standardOut"]
  zookeeper:
    # ...
```

##### [Additional resources](https://strimzi.io/docs/operators/0.18.0/using.html#additional_resources)

For more information about the Jmxtrans see [Jmxtrans github](https://github.com/jmxtrans/jmxtrans)

#### [3.1.19. JVM Options](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-jvm-options-deployment-configuration-kafka)

The following components of Strimzi run inside a Virtual Machine (VM):

- Apache Kafka
- Apache ZooKeeper
- Apache Kafka Connect
- Apache Kafka MirrorMaker
- Strimzi Kafka Bridge

JVM configuration options optimize the performance for different platforms and architectures. Strimzi allows you to configure some of these options.

##### [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka)

JVM options can be configured using the `jvmOptions` property in following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.zookeeper`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaMirrorMaker.spec`
- `KafkaBridge.spec`

Only a selected subset of available JVM options can be configured. The following options are supported:

-Xms and -Xmx

`-Xms` configures the minimum initial allocation heap size when the JVM starts. `-Xmx` configures the maximum heap size.

| NOTE | The units accepted by JVM settings such as `-Xmx` and `-Xms` are those accepted by the JDK `java` binary in the corresponding image. Accordingly, `1g` or `1G` means 1,073,741,824 bytes, and `Gi` is not a valid unit suffix. This is in contrast to the units used for [memory requests and limits](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka), which follow the Kubernetes convention where `1G` means 1,000,000,000 bytes, and `1Gi` means 1,073,741,824 bytes |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

The default values used for `-Xms` and `-Xmx` depends on whether there is a [memory request](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka) limit configured for the container:

- If there is a memory limit then the JVM’s minimum and maximum memory will be set to a value corresponding to the limit.
- If there is no memory limit then the JVM’s minimum memory will be set to `128M` and the JVM’s maximum memory will not be defined. This allows for the JVM’s memory to grow as-needed, which is ideal for single node environments in test and development.

| IMPORTANT | Setting `-Xmx` explicitly requires some care:The JVM’s overall memory usage will be approximately 4 × the maximum heap, as configured by `-Xmx`.If `-Xmx` is set without also setting an appropriate Kubernetes memory limit, it is possible that the container will be killed should the Kubernetes node experience memory pressure (from other Pods running on it).If `-Xmx` is set without also setting an appropriate Kubernetes memory request, it is possible that the container will be scheduled to a node with insufficient memory. In this case, the container will not start but crash (immediately if `-Xms` is set to `-Xmx`, or some later time if not). |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

When setting `-Xmx` explicitly, it is recommended to:

- set the memory request and the memory limit to the same value,
- use a memory request that is at least 4.5 × the `-Xmx`,
- consider setting `-Xms` to the same value as `-Xmx`.

| IMPORTANT | Containers doing lots of disk I/O (such as Kafka broker containers) will need to leave some memory available for use as operating system page cache. On such containers, the requested memory should be significantly higher than the memory used by the JVM. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

Example fragment configuring `-Xmx` and `-Xms`

```yaml
# ...
jvmOptions:
  "-Xmx": "2g"
  "-Xms": "2g"
# ...
```

In the above example, the JVM will use 2 GiB (=2,147,483,648 bytes) for its heap. Its total memory usage will be approximately 8GiB.

Setting the same value for initial (`-Xms`) and maximum (`-Xmx`) heap sizes avoids the JVM having to allocate memory after startup, at the cost of possibly allocating more heap than is really needed. For Kafka and ZooKeeper pods such allocation could cause unwanted latency. For Kafka Connect avoiding over allocation may be the most important concern, especially in distributed mode where the effects of over-allocation will be multiplied by the number of consumers.

-server

`-server` enables the server JVM. This option can be set to true or false.

Example fragment configuring `-server`

```yaml
# ...
jvmOptions:
  "-server": true
# ...
```

| NOTE | When neither of the two options (`-server` and `-XX`) is specified, the default Apache Kafka configuration of `KAFKA_JVM_PERFORMANCE_OPTS` will be used. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

-XX

`-XX` object can be used for configuring advanced runtime options of a JVM. The `-server` and `-XX` options are used to configure the `KAFKA_JVM_PERFORMANCE_OPTS` option of Apache Kafka.

Example showing the use of the `-XX` object

```yaml
jvmOptions:
  "-XX":
    "UseG1GC": true
    "MaxGCPauseMillis": 20
    "InitiatingHeapOccupancyPercent": 35
    "ExplicitGCInvokesConcurrent": true
    "UseParNewGC": false
```

The example configuration above will result in the following JVM options:

```none
-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -XX:-UseParNewGC
```

| NOTE | When neither of the two options (`-server` and `-XX`) is specified, the default Apache Kafka configuration of `KAFKA_JVM_PERFORMANCE_OPTS` will be used. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

###### [Garbage collector logging](https://strimzi.io/docs/operators/0.18.0/using.html#garbage_collector_logging)

The `jvmOptions` section also allows you to enable and disable garbage collector (GC) logging. GC logging is disabled by default. To enable it, set the `gcLoggingEnabled` property as follows:

Example of enabling GC logging

```yaml
# ...
jvmOptions:
  gcLoggingEnabled: true
# ...
```

##### [Configuring JVM options](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-jvm-options-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `jvmOptions` property in the `Kafka`, `KafkaConnect`, `KafkaConnectS2I`, `KafkaMirrorMaker`, or `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       jvmOptions:
         "-Xmx": "8g"
         "-Xms": "8g"
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.20. Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka)

Strimzi allows you to configure container images which will be used for its components. Overriding container images is recommended only in special situations, where you need to use a different container registry. For example, because your network does not allow access to the container repository used by Strimzi. In such a case, you should either copy the Strimzi images or build them from the source. If the configured image is not compatible with Strimzi images, it might not work properly.

##### [Container image configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-configuring-container-images-deployment-configuration-kafka)

You can specify which container image to use for each component using the `image` property in the following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.jmxTrans`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaBridge.spec`

###### [Configuring the `image` property for Kafka, Kafka Connect, and Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#configuring_the_image_property_for_kafka_kafka_connect_and_kafka_mirrormaker)

Kafka, Kafka Connect (including Kafka Connect with S2I support), and Kafka MirrorMaker support multiple versions of Kafka. Each component requires its own image. The default images for the different Kafka versions are configured in the following environment variables:

- `STRIMZI_KAFKA_IMAGES`
- `STRIMZI_KAFKA_CONNECT_IMAGES`
- `STRIMZI_KAFKA_CONNECT_S2I_IMAGES`
- `STRIMZI_KAFKA_MIRROR_MAKER_IMAGES`

These environment variables contain mappings between the Kafka versions and their corresponding images. The mappings are used together with the `image` and `version` properties:

- If neither `image` nor `version` are given in the custom resource then the `version` will default to the Cluster Operator’s default Kafka version, and the image will be the one corresponding to this version in the environment variable.
- If `image` is given but `version` is not, then the given image is used and the `version` is assumed to be the Cluster Operator’s default Kafka version.
- If `version` is given but `image` is not, then the image that corresponds to the given version in the environment variable is used.
- If both `version` and `image` are given, then the given image is used. The image is assumed to contain a Kafka image with the given version.

The `image` and `version` for the different components can be configured in the following properties:

- For Kafka in `spec.kafka.image` and `spec.kafka.version`.
- For Kafka Connect, Kafka Connect S2I, and Kafka MirrorMaker in `spec.image` and `spec.version`.

| WARNING | It is recommended to provide only the `version` and leave the `image` property unspecified. This reduces the chance of making a mistake when configuring the custom resource. If you need to change the images used for different versions of Kafka, it is preferable to configure the Cluster Operator’s environment variables. |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

###### [Configuring the `image` property in other resources](https://strimzi.io/docs/operators/0.18.0/using.html#configuring_the_image_property_in_other_resources)

For the `image` property in the other custom resources, the given value will be used during deployment. If the `image` property is missing, the `image` specified in the Cluster Operator configuration will be used. If the `image` name is not defined in the Cluster Operator configuration, then the default value will be used.

- For Kafka broker TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_KAFKA_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For ZooKeeper nodes:
- For ZooKeeper node TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_ZOOKEEPER_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Topic Operator:
  1. Container image specified in the `STRIMZI_DEFAULT_TOPIC_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For User Operator:
  1. Container image specified in the `STRIMZI_DEFAULT_USER_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For Entity Operator TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_ENTITY_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Kafka Exporter:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_EXPORTER_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Kafka Bridge:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_BRIDGE_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka-bridge:0.16.0` container image.
- For Kafka broker initializer:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_INIT_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For Kafka broker initializer:
  1. Container image specified in the `STRIMZI_DEFAULT_JMXTRANS_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.

| WARNING | Overriding container images is recommended only in special situations, where you need to use a different container registry. For example, because your network does not allow access to the container repository used by Strimzi. In such case, you should either copy the Strimzi images or build them from source. In case the configured image is not compatible with Strimzi images, it might not work properly. |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

Example of container image configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    image: my-org/my-image:latest
    # ...
  zookeeper:
    # ...
```

##### [Configuring container images](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-container-images-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `image` property in the `Kafka`, `KafkaConnect` or `KafkaConnectS2I` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       image: my-org/my-image:latest
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.21. TLS sidecar](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-tls-sidecar-deployment-configuration-kafka)

A sidecar is a container that runs in a pod but serves a supporting purpose. In Strimzi, the TLS sidecar uses TLS to encrypt and decrypt all communication between the various components and ZooKeeper. ZooKeeper does not have native TLS support.

The TLS sidecar is used in:

- Kafka brokers
- ZooKeeper nodes
- Entity Operator

##### [TLS sidecar configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-tls-sidecar-deployment-configuration-kafka)

The TLS sidecar can be configured using the `tlsSidecar` property in:

- `Kafka.spec.kafka`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator`

The TLS sidecar supports the following additional options:

- `image`
- `resources`
- `logLevel`
- `readinessProbe`
- `livenessProbe`

The `resources` property can be used to specify the [memory and CPU resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka) allocated for the TLS sidecar.

The `image` property can be used to configure the container image which will be used. For more details about configuring custom container images, see [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).

The `logLevel` property is used to specify the logging level. Following logging levels are supported:

- emerg
- alert
- crit
- err
- warning
- notice
- info
- debug

The default value is *notice*.

For more information about configuring the `readinessProbe` and `livenessProbe` properties for the healthchecks, see [Healthcheck configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-healthchecks-deployment-configuration-kafka).

Example of TLS sidecar configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    tlsSidecar:
      image: my-org/my-image:latest
      resources:
        requests:
          cpu: 200m
          memory: 64Mi
        limits:
          cpu: 500m
          memory: 128Mi
      logLevel: debug
      readinessProbe:
        initialDelaySeconds: 15
        timeoutSeconds: 5
      livenessProbe:
        initialDelaySeconds: 15
        timeoutSeconds: 5
    # ...
  zookeeper:
    # ...
```

##### [Configuring TLS sidecar](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-tls-sidecar-deployment-configuration-kafka)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `tlsSidecar` property in the `Kafka` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       tlsSidecar:
         resources:
           requests:
             cpu: 200m
             memory: 64Mi
           limits:
             cpu: 500m
             memory: 128Mi
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.22. Configuring pod scheduling](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-scheduling-deployment-configuration-kafka)

| IMPORTANT | When two applications are scheduled to the same Kubernetes node, both applications might use the same resources like disk I/O and impact performance. That can lead to performance degradation. Scheduling Kafka pods in a way that avoids sharing nodes with other critical workloads, using the right nodes or dedicated a set of nodes only for Kafka are the best ways how to avoid such problems. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

##### [Scheduling pods based on other applications](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-scheduling-pods-based-on-other-applications-deployment-configuration-kafka-scheduling-based-on-pods)

###### [Avoid critical applications to share the node](https://strimzi.io/docs/operators/0.18.0/using.html#con-scheduling-based-on-other-pods-deployment-configuration-kafka-scheduling-based-on-pods)

Pod anti-affinity can be used to ensure that critical applications are never scheduled on the same disk. When running Kafka cluster, it is recommended to use pod anti-affinity to ensure that the Kafka brokers do not share the nodes with other workloads like databases.

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-scheduling-based-on-pods)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Configuring pod anti-affinity in Kafka components](https://strimzi.io/docs/operators/0.18.0/using.html#configuring-pod-anti-affinity-in-kafka-components-deployment-configuration-kafka-scheduling-based-on-pods)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `affinity` property in the resource specifying the cluster deployment. Use labels to specify the pods which should not be scheduled on the same nodes. The `topologyKey` should be set to `kubernetes.io/hostname` to specify that the selected pods should not be scheduled on nodes with the same hostname. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           affinity:
             podAntiAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 - labelSelector:
                     matchExpressions:
                       - key: application
                         operator: In
                         values:
                           - postgresql
                           - mongodb
                   topologyKey: "kubernetes.io/hostname"
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

##### [Scheduling pods to specific nodes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-node-scheduling-deployment-configuration-kafka-node-scheduling)

###### [Node scheduling](https://strimzi.io/docs/operators/0.18.0/using.html#con-scheduling-to-specific-nodes-deployment-configuration-kafka-node-scheduling)

The Kubernetes cluster usually consists of many different types of worker nodes. Some are optimized for CPU heavy workloads, some for memory, while other might be optimized for storage (fast local SSDs) or network. Using different nodes helps to optimize both costs and performance. To achieve the best possible performance, it is important to allow scheduling of Strimzi components to use the right nodes.

Kubernetes uses node affinity to schedule workloads onto specific nodes. Node affinity allows you to create a scheduling constraint for the node on which the pod will be scheduled. The constraint is specified as a label selector. You can specify the label using either the built-in node label like `beta.kubernetes.io/instance-type` or custom labels to select the right node.

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-node-scheduling)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Configuring node affinity in Kafka components](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-node-affinity-deployment-configuration-kafka-node-scheduling)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Label the nodes where Strimzi components should be scheduled.

   This can be done using `kubectl label`:

   ```shell
   kubectl label node your-node node-type=fast-network
   ```

   Alternatively, some of the existing labels might be reused.

2. Edit the `affinity` property in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           affinity:
             nodeAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 nodeSelectorTerms:
                   - matchExpressions:
                     - key: node-type
                       operator: In
                       values:
                       - fast-network
       # ...
     zookeeper:
       # ...
   ```

3. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

##### [Using dedicated nodes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-dedidcated-nodes-deployment-configuration-kafka-dedicated-nodes)

###### [Dedicated nodes](https://strimzi.io/docs/operators/0.18.0/using.html#con-dedicated-nodes-deployment-configuration-kafka-dedicated-nodes)

Cluster administrators can mark selected Kubernetes nodes as tainted. Nodes with taints are excluded from regular scheduling and normal pods will not be scheduled to run on them. Only services which can tolerate the taint set on the node can be scheduled on it. The only other services running on such nodes will be system services such as log collectors or software defined networks.

Taints can be used to create dedicated nodes. Running Kafka and its components on dedicated nodes can have many advantages. There will be no other applications running on the same nodes which could cause disturbance or consume the resources needed for Kafka. That can lead to improved performance and stability.

To schedule Kafka pods on the dedicated nodes, configure [node affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-dedicated-nodes) and [tolerations](https://strimzi.io/docs/operators/0.18.0/using.html#tolerations-deployment-configuration-kafka-dedicated-nodes).

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-dedicated-nodes)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Tolerations](https://strimzi.io/docs/operators/0.18.0/using.html#tolerations-deployment-configuration-kafka-dedicated-nodes)

Tolerations can be configured using the `tolerations` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The format of the `tolerations` property follows the Kubernetes specification. For more details, see the [Kubernetes taints and tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/).

###### [Setting up dedicated nodes and scheduling pods on them](https://strimzi.io/docs/operators/0.18.0/using.html#proc-dedicated-nodes-deployment-configuration-kafka-dedicated-nodes)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Select the nodes which should be used as dedicated.

2. Make sure there are no workloads scheduled on these nodes.

3. Set the taints on the selected nodes:

   This can be done using `kubectl taint`:

   ```shell
   kubectl taint node your-node dedicated=Kafka:NoSchedule
   ```

4. Additionally, add a label to the selected nodes as well.

   This can be done using `kubectl label`:

   ```shell
   kubectl label node your-node dedicated=Kafka
   ```

5. Edit the `affinity` and `tolerations` properties in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           tolerations:
             - key: "dedicated"
               operator: "Equal"
               value: "Kafka"
               effect: "NoSchedule"
           affinity:
             nodeAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 nodeSelectorTerms:
                 - matchExpressions:
                   - key: dedicated
                     operator: In
                     values:
                     - Kafka
       # ...
     zookeeper:
       # ...
   ```

6. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.1.23. Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-exporter-configuration-deployment-configuration-kafka)

You can configure the `Kafka` resource to automatically deploy Kafka Exporter in your cluster.

Kafka Exporter extracts data for analysis as Prometheus metrics, primarily data relating to offsets, consumer groups, consumer lag and topics.

For information on Kafka Exporter and why it is important to monitor consumer lag for performance, see [Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-kafka-exporter-str).

##### [Configuring Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/using.html#proc-kafka-exporter-configuring-deployment-configuration-kafka)

This procedure shows how to configure Kafka Exporter in the `Kafka` resource through `KafkaExporter` properties.

For more information about configuring the `Kafka` resource, see the [sample Kafka YAML configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-sample-kafka-resource-config-deployment-configuration-kafka).

The properties relevant to the Kafka Exporter configuration are shown in this procedure.

You can configure these properties as part of a deployment or redeployment of the Kafka cluster.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `KafkaExporter` properties for the `Kafka` resource.

   The properties you can configure are shown in this example configuration:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     # ...
     kafkaExporter:
       image: my-org/my-image:latest (1)
       groupRegex: ".*" (2)
       topicRegex: ".*" (3)
       resources: (4)
         requests:
           cpu: 200m
           memory: 64Mi
         limits:
           cpu: 500m
           memory: 128Mi
       logging: debug (5)
       enableSaramaLogging: true (6)
       template: (7)
         pod:
           metadata:
             labels:
               label1: value1
           imagePullSecrets:
             - name: my-docker-credentials
           securityContext:
             runAsUser: 1000001
             fsGroup: 0
           terminationGracePeriodSeconds: 120
       readinessProbe: (8)
         initialDelaySeconds: 15
         timeoutSeconds: 5
       livenessProbe: (9)
         initialDelaySeconds: 15
         timeoutSeconds: 5
   # ...
   ```

   1. ADVANCED OPTION: Container image configuration, which is [recommended only in special situations](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).
   2. A regular expression to specify the consumer groups to include in the metrics.
   3. A regular expression to specify the topics to include in the metrics.
   4. [CPU and memory resources to reserve](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka).
   5. Logging configuration, to log messages with a given severity (debug, info, warn, error, fatal) or above.
   6. Boolean to enable Sarama logging, a Go client library used by Kafka Exporter.
   7. [Customization of deployment templates and pods](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-customizing-deployments-str).
   8. [Healthcheck readiness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).
   9. [Healthcheck liveness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).

2. Create or update the resource:

   ```shell
   kubectl apply -f kafka.yaml
   ```

What to do next

After configuring and deploying Kafka Exporter, you can [enable Grafana to present the Kafka Exporter dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-kafka-exporter-enabling-str).

Additional resources

[./using.html#type-KafkaExporterTemplate-reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaExporterTemplate-reference).

#### [3.1.24. Performing a rolling update of a Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-rolling-update-kafka-deployment-configuration-kafka)

This procedure describes how to manually trigger a rolling update of an existing Kafka cluster by using a Kubernetes annotation.

Prerequisites

- A running Kafka cluster.
- A running Cluster Operator.

Procedure

1. Find the name of the `StatefulSet` that controls the Kafka pods you want to manually update.

   For example, if your Kafka cluster is named *my-cluster*, the corresponding `StatefulSet` is named *my-cluster-kafka*.

2. Annotate the `StatefulSet` resource in Kubernetes. For example, using `kubectl annotate`:

   ```shell
   kubectl annotate statefulset cluster-name-kafka strimzi.io/manual-rolling-update=true
   ```

3. Wait for the next reconciliation to occur (every two minutes by default). A rolling update of all pods within the annotated `StatefulSet` is triggered, as long as the annotation was detected by the reconciliation process. When the rolling update of all the pods is complete, the annotation is removed from the `StatefulSet`.

Additional resources

- For more information about deploying the Cluster Operator, see [Deploying the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str).
- For more information about deploying the Kafka cluster, see [Deploying the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str).

#### [3.1.25. Performing a rolling update of a ZooKeeper cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-rolling-update-zookeeper-deployment-configuration-kafka)

This procedure describes how to manually trigger a rolling update of an existing ZooKeeper cluster by using a Kubernetes annotation.

Prerequisites

- A running ZooKeeper cluster.
- A running Cluster Operator.

Procedure

1. Find the name of the `StatefulSet` that controls the ZooKeeper pods you want to manually update.

   For example, if your Kafka cluster is named *my-cluster*, the corresponding `StatefulSet` is named *my-cluster-zookeeper*.

2. Annotate the `StatefulSet` resource in Kubernetes. For example, using `kubectl annotate`:

   ```shell
   kubectl annotate statefulset cluster-name-zookeeper strimzi.io/manual-rolling-update=true
   ```

3. Wait for the next reconciliation to occur (every two minutes by default). A rolling update of all pods within the annotated `StatefulSet` is triggered, as long as the annotation was detected by the reconciliation process. When the rolling update of all the pods is complete, the annotation is removed from the `StatefulSet`.

Additional resources

- For more information about deploying the Cluster Operator, see [Deploying the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str).
- For more information about deploying the ZooKeeper cluster, see [Deploying the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str).

#### [3.1.26. Scaling clusters](https://strimzi.io/docs/operators/0.18.0/using.html#scaling-clusters-deployment-configuration-kafka)

##### [Scaling Kafka clusters](https://strimzi.io/docs/operators/0.18.0/using.html#con-scaling-kafka-clusters-deployment-configuration-kafka)

###### [Adding brokers to a cluster](https://strimzi.io/docs/operators/0.18.0/using.html#adding_brokers_to_a_cluster)

The primary way of increasing throughput for a topic is to increase the number of partitions for that topic. That works because the extra partitions allow the load of the topic to be shared between the different brokers in the cluster. However, in situations where every broker is constrained by a particular resource (typically I/O) using more partitions will not result in increased throughput. Instead, you need to add brokers to the cluster.

When you add an extra broker to the cluster, Kafka does not assign any partitions to it automatically. You must decide which partitions to move from the existing brokers to the new broker.

Once the partitions have been redistributed between all the brokers, the resource utilization of each broker should be reduced.

###### [Removing brokers from a cluster](https://strimzi.io/docs/operators/0.18.0/using.html#removing_brokers_from_a_cluster)

Because Strimzi uses `StatefulSets` to manage broker pods, you cannot remove *any* pod from the cluster. You can only remove one or more of the highest numbered pods from the cluster. For example, in a cluster of 12 brokers the pods are named `*cluster-name*-kafka-0` up to `*cluster-name*-kafka-11`. If you decide to scale down by one broker, the `*cluster-name*-kafka-11` will be removed.

Before you remove a broker from a cluster, ensure that it is not assigned to any partitions. You should also decide which of the remaining brokers will be responsible for each of the partitions on the broker being decommissioned. Once the broker has no assigned partitions, you can scale the cluster down safely.

##### [Partition reassignment](https://strimzi.io/docs/operators/0.18.0/using.html#con-partition-reassignment-deployment-configuration-kafka)

The Topic Operator does not currently support reassigning replicas to different brokers, so it is necessary to connect directly to broker pods to reassign replicas to brokers.

Within a broker pod, the `kafka-reassign-partitions.sh` utility allows you to reassign partitions to different brokers.

It has three different modes:

- `--generate`

  Takes a set of topics and brokers and generates a *reassignment JSON file* which will result in the partitions of those topics being assigned to those brokers. Because this operates on whole topics, it cannot be used when you just need to reassign some of the partitions of some topics.

- `--execute`

  Takes a *reassignment JSON file* and applies it to the partitions and brokers in the cluster. Brokers that gain partitions as a result become followers of the partition leader. For a given partition, once the new broker has caught up and joined the ISR (in-sync replicas) the old broker will stop being a follower and will delete its replica.

- `--verify`

  Using the same *reassignment JSON file* as the `--execute` step, `--verify` checks whether all of the partitions in the file have been moved to their intended brokers. If the reassignment is complete, --verify also removes any [throttles](https://strimzi.io/docs/operators/0.18.0/using.html#con-reassignment-throttles-deployment-configuration-kafka) that are in effect. Unless removed, throttles will continue to affect the cluster even after the reassignment has finished.

It is only possible to have one reassignment running in a cluster at any given time, and it is not possible to cancel a running reassignment. If you need to cancel a reassignment, wait for it to complete and then perform another reassignment to revert the effects of the first reassignment. The `kafka-reassign-partitions.sh` will print the reassignment JSON for this reversion as part of its output. Very large reassignments should be broken down into a number of smaller reassignments in case there is a need to stop in-progress reassignment.

###### [Reassignment JSON file](https://strimzi.io/docs/operators/0.18.0/using.html#reassignment_json_file)

The *reassignment JSON file* has a specific structure:

```none
{
  "version": 1,
  "partitions": [
    <PartitionObjects>
  ]
}
```

Where ** is a comma-separated list of objects like:

```none
{
  "topic": <TopicName>,
  "partition": <Partition>,
  "replicas": [ <AssignedBrokerIds> ]
}
```

| NOTE | Although Kafka also supports a `"log_dirs"` property this should not be used in Strimzi. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

The following is an example reassignment JSON file that assigns topic `topic-a`, partition `4` to brokers `2`, `4` and `7`, and topic `topic-b` partition `2` to brokers `1`, `5` and `7`:

```json
{
  "version": 1,
  "partitions": [
    {
      "topic": "topic-a",
      "partition": 4,
      "replicas": [2,4,7]
    },
    {
      "topic": "topic-b",
      "partition": 2,
      "replicas": [1,5,7]
    }
  ]
}
```

Partitions not included in the JSON are not changed.

###### [Reassigning partitions between JBOD volumes](https://strimzi.io/docs/operators/0.18.0/using.html#reassigning_partitions_between_jbod_volumes)

When using JBOD storage in your Kafka cluster, you can choose to reassign the partitions between specific volumes and their log directories (each volume has a single log directory). To reassign a partition to a specific volume, add the `log_dirs` option to ** in the reassignment JSON file.

```none
{
  "topic": <TopicName>,
  "partition": <Partition>,
  "replicas": [ <AssignedBrokerIds> ],
  "log_dirs": [ <AssignedLogDirs> ]
}
```

The `log_dirs` object should contain the same number of log directories as the number of replicas specified in the `replicas` object. The value should be either an absolute path to the log directory, or the `any` keyword.

For example:

```none
{
      "topic": "topic-a",
      "partition": 4,
      "replicas": [2,4,7].
      "log_dirs": [ "/var/lib/kafka/data-0/kafka-log2", "/var/lib/kafka/data-0/kafka-log4", "/var/lib/kafka/data-0/kafka-log7" ]
}
```

##### [Generating reassignment JSON files](https://strimzi.io/docs/operators/0.18.0/using.html#proc-generating-reassignment-json-files-deployment-configuration-kafka)

This procedure describes how to generate a reassignment JSON file that reassigns all the partitions for a given set of topics using the `kafka-reassign-partitions.sh` tool.

Prerequisites

- A running Cluster Operator
- A `Kafka` resource
- A set of topics to reassign the partitions of

Procedure

1. Prepare a JSON file named `*topics.json*` that lists the topics to move. It must have the following structure:

   ```none
   {
     "version": 1,
     "topics": [
       <TopicObjects>
     ]
   }
   ```

   where ** is a comma-separated list of objects like:

   ```none
   {
     "topic": <TopicName>
   }
   ```

   For example if you want to reassign all the partitions of `topic-a` and `topic-b`, you would need to prepare a `*topics.json*` file like this:

   ```json
   {
     "version": 1,
     "topics": [
       { "topic": "topic-a"},
       { "topic": "topic-b"}
     ]
   }
   ```

2. Copy the `*topics.json*` file to one of the broker pods:

   ```none
   cat topics.json | kubectl exec -c kafka <BrokerPod> -i -- \
     /bin/bash -c \
     'cat > /tmp/topics.json'
   ```

3. Use the `kafka-reassign-partitions.sh` command to generate the reassignment JSON.

   ```none
   kubectl exec <BrokerPod> -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --topics-to-move-json-file /tmp/topics.json \
     --broker-list <BrokerList> \
     --generate
   ```

   For example, to move all the partitions of `topic-a` and `topic-b` to brokers `4` and `7`

   ```shell
   kubectl exec <BrokerPod> -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --topics-to-move-json-file /tmp/topics.json \
     --broker-list 4,7 \
     --generate
   ```

##### [Creating reassignment JSON files manually](https://strimzi.io/docs/operators/0.18.0/using.html#creating_reassignment_json_files_manually)

You can manually create the reassignment JSON file if you want to move specific partitions.

##### [Reassignment throttles](https://strimzi.io/docs/operators/0.18.0/using.html#con-reassignment-throttles-deployment-configuration-kafka)

Partition reassignment can be a slow process because it involves transferring large amounts of data between brokers. To avoid a detrimental impact on clients, you can throttle the reassignment process. This might cause the reassignment to take longer to complete.

- If the throttle is too low then the newly assigned brokers will not be able to keep up with records being published and the reassignment will never complete.
- If the throttle is too high then clients will be impacted.

For example, for producers, this could manifest as higher than normal latency waiting for acknowledgement. For consumers, this could manifest as a drop in throughput caused by higher latency between polls.

##### [Scaling up a Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-scaling-up-a-kafka-cluster-deployment-configuration-kafka)

This procedure describes how to increase the number of brokers in a Kafka cluster.

Prerequisites

- An existing Kafka cluster.
- A *reassignment JSON file* named `*reassignment.json*` that describes how partitions should be reassigned to brokers in the enlarged cluster.

Procedure

1. Add as many new brokers as you need by increasing the `Kafka.spec.kafka.replicas` configuration option.

2. Verify that the new broker pods have started.

3. Copy the `*reassignment.json*` file to the broker pod on which you will later execute the commands:

   ```shell
   cat reassignment.json | \
     kubectl exec broker-pod -c kafka -i -- /bin/bash -c \
     'cat > /tmp/reassignment.json'
   ```

   For example:

   ```shell
   cat reassignment.json | \
     kubectl exec my-cluster-kafka-0 -c kafka -i -- /bin/bash -c \
     'cat > /tmp/reassignment.json'
   ```

4. Execute the partition reassignment using the `kafka-reassign-partitions.sh` command line tool from the same broker pod.

   ```shell
   kubectl exec broker-pod -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --execute
   ```

   If you are going to throttle replication you can also pass the `--throttle` option with an inter-broker throttled rate in bytes per second. For example:

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --throttle 5000000 \
     --execute
   ```

   This command will print out two reassignment JSON objects. The first records the current assignment for the partitions being moved. You should save this to a local file (not a file in the pod) in case you need to revert the reassignment later on. The second JSON object is the target reassignment you have passed in your reassignment JSON file.

5. If you need to change the throttle during reassignment you can use the same command line with a different throttled rate. For example:

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --throttle 10000000 \
     --execute
   ```

6. Periodically verify whether the reassignment has completed using the `kafka-reassign-partitions.sh` command line tool from any of the broker pods. This is the same command as the previous step but with the `--verify` option instead of the `--execute` option.

   ```shell
   kubectl exec broker-pod -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --verify
   ```

   For example,

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --verify
   ```

7. The reassignment has finished when the `--verify` command reports each of the partitions being moved as completed successfully. This final `--verify` will also have the effect of removing any reassignment throttles. You can now delete the revert file if you saved the JSON for reverting the assignment to their original brokers.

##### [Scaling down a Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-scaling-down-a-kafka-cluster-deployment-configuration-kafka)

Additional resources

This procedure describes how to decrease the number of brokers in a Kafka cluster.

Prerequisites

- An existing Kafka cluster.
- A *reassignment JSON file* named `*reassignment.json*` describing how partitions should be reassigned to brokers in the cluster once the broker(s) in the highest numbered `Pod(s)` have been removed.

Procedure

1. Copy the `*reassignment.json*` file to the broker pod on which you will later execute the commands:

   ```shell
   cat reassignment.json | \
     kubectl exec broker-pod -c kafka -i -- /bin/bash -c \
     'cat > /tmp/reassignment.json'
   ```

   For example:

   ```shell
   cat reassignment.json | \
     kubectl exec my-cluster-kafka-0 -c kafka -i -- /bin/bash -c \
     'cat > /tmp/reassignment.json'
   ```

2. Execute the partition reassignment using the `kafka-reassign-partitions.sh` command line tool from the same broker pod.

   ```shell
   kubectl exec broker-pod -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --execute
   ```

   If you are going to throttle replication you can also pass the `--throttle` option with an inter-broker throttled rate in bytes per second. For example:

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --throttle 5000000 \
     --execute
   ```

   This command will print out two reassignment JSON objects. The first records the current assignment for the partitions being moved. You should save this to a local file (not a file in the pod) in case you need to revert the reassignment later on. The second JSON object is the target reassignment you have passed in your reassignment JSON file.

3. If you need to change the throttle during reassignment you can use the same command line with a different throttled rate. For example:

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --throttle 10000000 \
     --execute
   ```

4. Periodically verify whether the reassignment has completed using the `kafka-reassign-partitions.sh` command line tool from any of the broker pods. This is the same command as the previous step but with the `--verify` option instead of the `--execute` option.

   ```shell
   kubectl exec broker-pod -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --verify
   ```

   For example,

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 \
     --reassignment-json-file /tmp/reassignment.json \
     --verify
   ```

5. The reassignment has finished when the `--verify` command reports each of the partitions being moved as completed successfully. This final `--verify` will also have the effect of removing any reassignment throttles. You can now delete the revert file if you saved the JSON for reverting the assignment to their original brokers.

6. Once all the partition reassignments have finished, the broker(s) being removed should not have responsibility for any of the partitions in the cluster. You can verify this by checking that the broker’s data log directory does not contain any live partition logs. If the log directory on the broker contains a directory that does not match the extended regular expression `[a-zA-Z0-9.-]+\.[a-z0-9]+-delete$` then the broker still has live partitions and it should not be stopped.

   You can check this by executing the command:

   ```shell
   kubectl exec my-cluster-kafka-0 -c kafka -it -- \
     /bin/bash -c \
     "ls -l /var/lib/kafka/kafka-log_<N>_ | grep -E '^d' | grep -vE '[a-zA-Z0-9.-]+\.[a-z0-9]+-delete$'"
   ```

   where *N* is the number of the `Pod(s)` being deleted.

   If the above command prints any output then the broker still has live partitions. In this case, either the reassignment has not finished, or the reassignment JSON file was incorrect.

7. Once you have confirmed that the broker has no live partitions you can edit the `Kafka.spec.kafka.replicas` of your `Kafka` resource, which will scale down the `StatefulSet`, deleting the highest numbered broker `Pod(s)`.

#### [3.1.27. Deleting Kafka nodes manually](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-delete-pod-pvc-kafka-deployment-configuration-kafka)

Additional resources

This procedure describes how to delete an existing Kafka node by using a Kubernetes annotation. Deleting a Kafka node consists of deleting both the `Pod` on which the Kafka broker is running and the related `PersistentVolumeClaim` (if the cluster was deployed with persistent storage). After deletion, the `Pod` and its related `PersistentVolumeClaim` are recreated automatically.

| WARNING | Deleting a `PersistentVolumeClaim` can cause permanent data loss. The following procedure should only be performed if you have encountered storage issues. |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

Prerequisites

- A running Kafka cluster.
- A running Cluster Operator.

Procedure

1. Find the name of the `Pod` that you want to delete.

   For example, if the cluster is named *cluster-name*, the pods are named *cluster-name*-kafka-*index*, where *index* starts at zero and ends at the total number of replicas.

2. Annotate the `Pod` resource in Kubernetes.

   Use `kubectl annotate`:

   ```shell
   kubectl annotate pod cluster-name-kafka-index strimzi.io/delete-pod-and-pvc=true
   ```

3. Wait for the next reconciliation, when the annotated pod with the underlying persistent volume claim will be deleted and then recreated.

Additional resources

- For more information about deploying the Cluster Operator, see [Deploying the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str).
- For more information about deploying the Kafka cluster, see [Deploying the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str).

#### [3.1.28. Deleting ZooKeeper nodes manually](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-delete-pod-pvc-zookeeper-deployment-configuration-kafka)

This procedure describes how to delete an existing ZooKeeper node by using a Kubernetes annotation. Deleting a ZooKeeper node consists of deleting both the `Pod` on which ZooKeeper is running and the related `PersistentVolumeClaim` (if the cluster was deployed with persistent storage). After deletion, the `Pod` and its related `PersistentVolumeClaim` are recreated automatically.

| WARNING | Deleting a `PersistentVolumeClaim` can cause permanent data loss. The following procedure should only be performed if you have encountered storage issues. |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

Prerequisites

- A running ZooKeeper cluster.
- A running Cluster Operator.

Procedure

1. Find the name of the `Pod` that you want to delete.

   For example, if the cluster is named *cluster-name*, the pods are named *cluster-name*-zookeeper-*index*, where *index* starts at zero and ends at the total number of replicas.

2. Annotate the `Pod` resource in Kubernetes.

   Use `kubectl annotate`:

   ```shell
   kubectl annotate pod cluster-name-zookeeper-index strimzi.io/delete-pod-and-pvc=true
   ```

3. Wait for the next reconciliation, when the annotated pod with the underlying persistent volume claim will be deleted and then recreated.

Additional resources

- For more information about deploying the Cluster Operator, see [Deploying the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str).
- For more information about deploying the ZooKeeper cluster, see [Deploying the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#deploying-kafka-cluster-str).

#### [3.1.29. Maintenance time windows for rolling updates](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-maintenance-time-windows-deployment-configuration-kafka)

Maintenance time windows allow you to schedule certain rolling updates of your Kafka and ZooKeeper clusters to start at a convenient time.

##### [Maintenance time windows overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-maintenance-time-windows-overview-deployment-configuration-kafka)

In most cases, the Cluster Operator only updates your Kafka or ZooKeeper clusters in response to changes to the corresponding `Kafka` resource. This enables you to plan when to apply changes to a `Kafka` resource to minimize the impact on Kafka client applications.

However, some updates to your Kafka and ZooKeeper clusters can happen without any corresponding change to the `Kafka` resource. For example, the Cluster Operator will need to perform a rolling restart if a CA (Certificate Authority) certificate that it manages is close to expiry.

While a rolling restart of the pods should not affect *availability* of the service (assuming correct broker and topic configurations), it could affect *performance* of the Kafka client applications. Maintenance time windows allow you to schedule such spontaneous rolling updates of your Kafka and ZooKeeper clusters to start at a convenient time. If maintenance time windows are not configured for a cluster then it is possible that such spontaneous rolling updates will happen at an inconvenient time, such as during a predictable period of high load.

##### [Maintenance time window definition](https://strimzi.io/docs/operators/0.18.0/using.html#con-maintenance-time-window-definition-deployment-configuration-kafka)

You configure maintenance time windows by entering an array of strings in the `Kafka.spec.maintenanceTimeWindows` property. Each string is a [cron expression](http://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/tutorial-lesson-06.html) interpreted as being in UTC (Coordinated Universal Time, which for practical purposes is the same as Greenwich Mean Time).

The following example configures a single maintenance time window that starts at midnight and ends at 01:59am (UTC), on Sundays, Mondays, Tuesdays, Wednesdays, and Thursdays:

```yaml
# ...
maintenanceTimeWindows:
  - "* * 0-1 ? * SUN,MON,TUE,WED,THU *"
# ...
```

In practice, maintenance windows should be set in conjunction with the `Kafka.spec.clusterCa.renewalDays` and `Kafka.spec.clientsCa.renewalDays` properties of the `Kafka` resource, to ensure that the necessary CA certificate renewal can be completed in the configured maintenance time windows.

| NOTE | Strimzi does not schedule maintenance operations exactly according to the given windows. Instead, for each reconciliation, it checks whether a maintenance window is currently "open". This means that the start of maintenance operations within a given time window can be delayed by up to the Cluster Operator reconciliation interval. Maintenance time windows must therefore be at least this long. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Additional resources

- For more information about the Cluster Operator configuration, see [Cluster Operator Configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-operators-cluster-operator-configuration-deploying-co).

##### [Configuring a maintenance time window](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-maintenance-time-windows-deployment-configuration-kafka)

You can configure a maintenance time window for rolling updates triggered by supported processes.

Prerequisites

- A Kubernetes cluster.
- The Cluster Operator is running.

Procedure

1. Add or edit the `maintenanceTimeWindows` property in the `Kafka` resource. For example to allow maintenance between 0800 and 1059 and between 1400 and 1559 you would set the `maintenanceTimeWindows` as shown below:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
     zookeeper:
       # ...
     maintenanceTimeWindows:
       - "* * 8-10 * * ?"
       - "* * 14-15 * * ?"
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- Performing a rolling update of a Kafka cluster, see [Performing a rolling update of a Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-rolling-update-kafka-deployment-configuration-kafka)
- Performing a rolling update of a ZooKeeper cluster, see [Performing a rolling update of a ZooKeeper cluster](https://strimzi.io/docs/operators/0.18.0/using.html#proc-manual-rolling-update-zookeeper-deployment-configuration-kafka)

#### [3.1.30. Renewing CA certificates manually](https://strimzi.io/docs/operators/0.18.0/using.html#proc-renewing-ca-certs-manually-deployment-configuration-kafka)

Unless the `Kafka.spec.clusterCa.generateCertificateAuthority` and `Kafka.spec.clientsCa.generateCertificateAuthority` objects are set to `false`, the cluster and clients CA certificates will auto-renew at the start of their respective certificate renewal periods. You can manually renew one or both of these certificates before the certificate renewal period starts, if required for security reasons. A renewed certificate uses the same private key as the old certificate.

Prerequisites

- The Cluster Operator is running.
- A Kafka cluster in which CA certificates and private keys are installed.

Procedure

- Apply the `strimzi.io/force-renew` annotation to the `Secret` that contains the CA certificate that you want to renew.

  | Certificate | Secret             | Annotate command                                             |
  | :---------- | :----------------- | :----------------------------------------------------------- |
  | Cluster CA  | **-cluster-ca-cert | `kubectl annotate secret **-cluster-ca-cert strimzi.io/force-renew=true` |
  | Clients CA  | **-clients-ca-cert | `kubectl annotate secret **-clients-ca-cert strimzi.io/force-renew=true` |

At the next reconciliation the Cluster Operator will generate a new CA certificate for the `Secret` that you annotated. If maintenance time windows are configured, the Cluster Operator will generate the new CA certificate at the first reconciliation within the next maintenance time window.

Client applications must reload the cluster and clients CA certificates that were renewed by the Cluster Operator.

Additional resources

- [Secrets](https://strimzi.io/docs/operators/0.18.0/using.html#certificates-and-secrets-str)
- [Maintenance time windows for rolling updates](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-maintenance-time-windows-deployment-configuration-kafka)
- [`CertificateAuthority` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-CertificateAuthority-reference)

#### [3.1.31. Replacing private keys](https://strimzi.io/docs/operators/0.18.0/using.html#proc-replacing-private-keys-deployment-configuration-kafka)

You can replace the private keys used by the cluster CA and clients CA certificates. When a private key is replaced, the Cluster Operator generates a new CA certificate for the new private key.

Prerequisites

- The Cluster Operator is running.
- A Kafka cluster in which CA certificates and private keys are installed.

Procedure

- Apply the `strimzi.io/force-replace` annotation to the `Secret` that contains the private key that you want to renew.

  | Private key for | Secret        | Annotate command                                             |
  | :-------------- | :------------ | :----------------------------------------------------------- |
  | Cluster CA      | **-cluster-ca | `kubectl annotate secret **-cluster-ca strimzi.io/force-replace=true` |
  | Clients CA      | **-clients-ca | `kubectl annotate secret **-clients-ca strimzi.io/force-replace=true` |

At the next reconciliation the Cluster Operator will:

- Generate a new private key for the `Secret` that you annotated
- Generate a new CA certificate

If maintenance time windows are configured, the Cluster Operator will generate the new private key and CA certificate at the first reconciliation within the next maintenance time window.

Client applications must reload the cluster and clients CA certificates that were renewed by the Cluster Operator.

Additional resources

- [Secrets](https://strimzi.io/docs/operators/0.18.0/using.html#certificates-and-secrets-str)
- [Maintenance time windows for rolling updates](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-maintenance-time-windows-deployment-configuration-kafka)

#### [3.1.32. List of resources created as part of Kafka cluster](https://strimzi.io/docs/operators/0.18.0/using.html#ref-list-of-kafka-cluster-resources-deployment-configuration-kafka)

The following resources will created by the Cluster Operator in the Kubernetes cluster:

- `*cluster-name*-kafka`

  StatefulSet which is in charge of managing the Kafka broker pods.

- `*cluster-name*-kafka-brokers`

  Service needed to have DNS resolve the Kafka broker pods IP addresses directly.

- `*cluster-name*-kafka-bootstrap`

  Service can be used as bootstrap servers for Kafka clients.

- `*cluster-name*-kafka-external-bootstrap`

  Bootstrap service for clients connecting from outside of the Kubernetes cluster. This resource will be created only when external listener is enabled.

- `*cluster-name*-kafka-*pod-id*`

  Service used to route traffic from outside of the Kubernetes cluster to individual pods. This resource will be created only when external listener is enabled.

- `*cluster-name*-kafka-external-bootstrap`

  Bootstrap route for clients connecting from outside of the Kubernetes cluster. This resource will be created only when external listener is enabled and set to type `route`.

- `*cluster-name*-kafka-*pod-id*`

  Route for traffic from outside of the Kubernetes cluster to individual pods. This resource will be created only when external listener is enabled and set to type `route`.

- `*cluster-name*-kafka-config`

  ConfigMap which contains the Kafka ancillary辅助 configuration and is mounted as a volume by the Kafka broker pods.

- `*cluster-name*-kafka-brokers`

  Secret with Kafka broker keys.

- `*cluster-name*-kafka`

  Service account used by the Kafka brokers.

- `*cluster-name*-kafka`

  Pod Disruption Budget configured for the Kafka brokers.

- `strimzi-*namespace-name*-*cluster-name*-kafka-init`

  Cluster role binding used by the Kafka brokers.

- `*cluster-name*-zookeeper`

  StatefulSet which is in charge of managing the ZooKeeper node pods.

- `*cluster-name*-zookeeper-nodes`

  Service needed to have DNS resolve the ZooKeeper pods IP addresses directly.

- `*cluster-name*-zookeeper-client`

  Service used by Kafka brokers to connect to ZooKeeper nodes as clients.

- `*cluster-name*-zookeeper-config`

  ConfigMap which contains the ZooKeeper ancillary configuration and is mounted as a volume by the ZooKeeper node pods.

- `*cluster-name*-zookeeper-nodes`

  Secret with ZooKeeper node keys.

- `*cluster-name*-zookeeper`

  Pod Disruption Budget configured for the ZooKeeper nodes.

- `*cluster-name*-entity-operator`

  Deployment with Topic and User Operators. This resource will be created only if Cluster Operator deployed Entity Operator.

- `*cluster-name*-entity-topic-operator-config`

  Configmap with ancillary configuration for Topic Operators. This resource will be created only if Cluster Operator deployed Entity Operator.

- `*cluster-name*-entity-user-operator-config`

  Configmap with ancillary configuration for User Operators. This resource will be created only if Cluster Operator deployed Entity Operator.

- `*cluster-name*-entity-operator-certs`

  Secret with Entity operators keys for communication with Kafka and ZooKeeper. This resource will be created only if Cluster Operator deployed Entity Operator.

- `*cluster-name*-entity-operator`

  Service account used by the Entity Operator.

- `strimzi-*cluster-name*-topic-operator`

  Role binding used by the Entity Operator.

- `strimzi-*cluster-name*-user-operator`

  Role binding used by the Entity Operator.

- `*cluster-name*-cluster-ca`

  Secret with the Cluster CA used to encrypt the cluster communication.

- `*cluster-name*-cluster-ca-cert`

  Secret with the Cluster CA public key. This key can be used to verify the identity of the Kafka brokers.

- `*cluster-name*-clients-ca`

  Secret with the Clients CA used to encrypt the communication between Kafka brokers and Kafka clients.

- `*cluster-name*-clients-ca-cert`

  Secret with the Clients CA public key. This key can be used to verify the identity of the Kafka brokers.

- `*cluster-name*-cluster-operator-certs`

  Secret with Cluster operators keys for communication with Kafka and ZooKeeper.

- `data-*cluster-name*-kafka-*idx*`

  Persistent Volume Claim for the volume used for storing data for the Kafka broker pod `*idx*`. This resource will be created only if persistent storage is selected for provisioning persistent volumes to store data.

- `data-*id*-*cluster-name*-kafka-*idx*`

  Persistent Volume Claim for the volume `*id*` used for storing data for the Kafka broker pod `*idx*`. This resource is only created if persistent storage is selected for JBOD volumes when provisioning persistent volumes to store data.

- `data-*cluster-name*-zookeeper-*idx*`

  Persistent Volume Claim for the volume used for storing data for the ZooKeeper node pod `*idx*`. This resource will be created only if persistent storage is selected for provisioning persistent volumes to store data.

- `*cluster-name*-jmx`

  Secret with JMX username and password used to secure the Kafka broker port.

