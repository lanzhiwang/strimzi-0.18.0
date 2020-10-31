### [3.4. Kafka MirrorMaker configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-mirror-maker-str)

This chapter describes how to configure a Kafka MirrorMaker deployment in your Strimzi cluster to replicate data between Kafka clusters.

You can use Strimzi with MirrorMaker or MirrorMaker 2.0. MirrorMaker 2.0 is the latest version, and offers a more efficient way to mirror data between Kafka clusters.  您可以将Strimzi与MirrorMaker或MirrorMaker 2.0一起使用。 MirrorMaker 2.0是最新版本，并提供了一种更有效的方式来在Kafka群集之间镜像数据。

#### MirrorMaker

If you are using MirrorMaker, you configure the `KafkaMirrorMaker` resource.

The following procedure shows how the resource is configured:

- [Configuring Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#configuring-kafka-mirror-maker-deployment-configuration-kafka-mirror-maker)

Supported properties are also described in more detail for your reference:

- [Kafka MirrorMaker configuration properties](https://strimzi.io/docs/operators/0.18.0/using.html#con-configuring-mirror-maker-deployment-configuration-kafka-mirror-maker)

The full schema of the `KafkaMirrorMaker` resource is described in the [KafkaMirrorMaker schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaMirrorMaker-reference).

> NOTE： Labels applied to a `KafkaMirrorMaker` resource are also applied to the Kubernetes resources comprising Kafka MirrorMaker. This provides a convenient mechanism for resources to be labeled as required.  应用于KafkaMirrorMaker资源的标签也将应用于包括Kafka MirrorMaker的Kubernetes资源。 这提供了一种方便的机制，可以根据需要标记资源。

#### MirrorMaker 2.0

If you are using MirrorMaker 2.0, you configure the `KafkaMirrorMaker2` resource.

MirrorMaker 2.0 introduces an entirely new way of replicating data between clusters. MirrorMaker 2.0引入了一种在群集之间复制数据的全新方法。

As a result, the resource configuration differs from the previous version of MirrorMaker. If you choose to use MirrorMaker 2.0, there is currently no legacy support, so any resources must be manually converted into the new format. 因此，资源配置与MirrorMaker的早期版本不同。 如果选择使用MirrorMaker 2.0，则当前不支持旧版，因此必须将任何资源手动转换为新格式。

How MirrorMaker 2.0 replicates data is described here:

- [MirrorMaker 2.0 data replication](https://strimzi.io/docs/operators/0.18.0/using.html#con-mirrormaker-deployment-configuration-kafka-mirror-maker)

The following procedure shows how the resource is configured for MirrorMaker 2.0:

- [Synchronizing data between Kafka clusters](https://strimzi.io/docs/operators/0.18.0/using.html#proc-mirrormaker-replication-deployment-configuration-kafka-mirror-maker)

The full schema of the `KafkaMirrorMaker2` resource is described in the [KafkaMirrorMaker2 schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaMirrorMaker2-reference).

#### [3.4.1. Configuring Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#configuring-kafka-mirror-maker-deployment-configuration-kafka-mirror-maker)

Use the properties of the `KafkaMirrorMaker` resource to configure your Kafka MirrorMaker deployment.

You can configure access control for producers and consumers using TLS or SASL authentication. This procedure shows a configuration that uses TLS encryption and authentication on the consumer and producer side.

Prerequisites

- [Strimzi and Kafka is deployed](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str)
- Source and target Kafka clusters are available

Procedure

1. Edit the `spec` properties for the `KafkaMirrorMaker` resource.

   The properties you can configure are shown in this example configuration:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: KafkaMirrorMaker
   metadata:
     name: my-mirror-maker
   spec:
     replicas: 3 (1)
     consumer:
       bootstrapServers: my-source-cluster-kafka-bootstrap:9092 (2)
       groupId: "my-group" (3)
       numStreams: 2 (4)
       offsetCommitInterval: 120000 (5)
       tls: (6)
         trustedCertificates:
         - secretName: my-source-cluster-ca-cert
           certificate: ca.crt
       authentication: (7)
         type: tls
         certificateAndKey:
           secretName: my-source-secret
           certificate: public.crt
           key: private.key
       config: (8)
         max.poll.records: 100
         receive.buffer.bytes: 32768
     producer:
       bootstrapServers: my-target-cluster-kafka-bootstrap:9092
       abortOnSendFailure: false (9)
       tls:
         trustedCertificates:
         - secretName: my-target-cluster-ca-cert
           certificate: ca.crt
       authentication:
         type: tls
         certificateAndKey:
           secretName: my-target-secret
           certificate: public.crt
           key: private.key
       config:
         compression.type: gzip
         batch.size: 8192
     whitelist: "my-topic|other-topic" (10)
     resources: (11)
       requests:
         cpu: "1"
         memory: 2Gi
       limits:
         cpu: "2"
         memory: 2Gi
     logging: (12)
       type: inline
       loggers:
         mirrormaker.root.logger: "INFO"
     readinessProbe: (13)
       initialDelaySeconds: 15
       timeoutSeconds: 5
     livenessProbe:
       initialDelaySeconds: 15
       timeoutSeconds: 5
     metrics: (14)
       lowercaseOutputName: true
       rules:
         - pattern: "kafka.server<type=(.+), name=(.+)PerSec\\w*><>Count"
           name: "kafka_server_$1_$2_total"
         - pattern: "kafka.server<type=(.+), name=(.+)PerSec\\w*,
           topic=(.+)><>Count"
           name: "kafka_server_$1_$2_total"
           labels:
             topic: "$3"
     jvmOptions: (15)
       "-Xmx": "1g"
       "-Xms": "1g"
     image: my-org/my-image:latest (16)
     template: (17)
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
   ```

   1. The number of replica nodes.
   2. Bootstrap servers for consumer and producer.
   3. Group ID for the consumer.
   4. The number of consumer streams.
   5. The offset auto-commit interval in milliseconds.
   6. TLS encryption with key names under which TLS certificates are stored in X.509 format for consumer or producer. For more details see [`KafkaMirrorMakerTls` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaMirrorMakerTls-reference).
   7. Authentication for consumer or producer, using the [TLS mechanism](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationTls-reference), as shown here, using [OAuth bearer tokens](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationOAuth-reference), or a SASL-based [SCRAM-SHA-512](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationScramSha512-reference) or [PLAIN](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationPlain-reference) mechanism.
   8. Kafka configuration options for consumer and producer.
   9. If set to `true`, Kafka MirrorMaker will exit and the container will restart following a send failure for a message.
   10. Topics mirrored from source to target Kafka cluster.
   11. Requests for reservation of supported resources, currently `cpu` and `memory`, and limits to specify the maximum resources that can be consumed.
   12. Specified loggers and log levels added directly (`inline`) or indirectly (`external`) through a ConfigMap. A custom ConfigMap must be placed under the `log4j.properties` or `log4j2.properties` key. MirrorMaker has a single logger called `mirrormaker.root.logger`. You can set the log level to INFO, ERROR, WARN, TRACE, DEBUG, FATAL or OFF.
   13. Healthchecks to know when to restart a container (liveness) and when a container can accept traffic (readiness).
   14. Prometheus metrics, which are enabled with configuration for the Prometheus JMX exporter in this example. You can enable metrics without further configuration using `metrics: {}`.
   15. JVM configuration options to optimize performance for the Virtual Machine (VM) running Kafka MirrorMaker.
   16. ADVANCED OPTION: Container image configuration, which is [recommended only in special situations](https://strimzi.io/docs/operators/0.18.0/using.html#con-configuring-container-images-deployment-configuration-kafka-mirror-maker).
   17. [Template customization](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-customizing-deployments-str). Here a pod is scheduled based with anti-affinity, so the pod is not scheduled on nodes with the same hostname.

   > WARNING：With the `abortOnSendFailure` property set to `false`, the producer attempts to send the next message in a topic. The original message might be lost, as there is no attempt to resend a failed message.

2. Create or update the resource:

   ```shell
   kubectl apply -f <your-file>
   ```

#### [3.4.2. Kafka MirrorMaker configuration properties](https://strimzi.io/docs/operators/0.18.0/using.html#con-configuring-mirror-maker-deployment-configuration-kafka-mirror-maker)

Use the `spec` configuration properties of the `KafkaMirrorMaker` resource to set up your MirrorMaker deployment.

Supported properties are described here for your reference.

##### [Replicas](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-replicas-deployment-configuration-kafka-mirror-maker)

Use the `replicas` property to configure replicas.

You can run multiple MirrorMaker replicas to provide better availability and scalability. When running Kafka MirrorMaker on Kubernetes it is not absolutely necessary to run multiple replicas of the Kafka MirrorMaker for high availability. When the node where the Kafka MirrorMaker has deployed crashes, Kubernetes will automatically reschedule the Kafka MirrorMaker pod to a different node. However, running Kafka MirrorMaker with multiple replicas can provide faster failover times as the other nodes will be up and running.

##### [Bootstrap servers](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-bootstrap-servers-deployment-configuration-kafka-mirror-maker)

Use the `consumer.bootstrapServers` and `producer.bootstrapServers` properties to configure lists of bootstrap servers for the consumer and producer.

Kafka MirrorMaker always works together with two Kafka clusters (source and target). The source and the target Kafka clusters are specified in the form of two lists of comma-separated list of `**:‍**` pairs. Each comma-separated list contains one or more Kafka brokers or a `Service` pointing to Kafka brokers specified as a `:` pairs.

The bootstrap server lists can refer to Kafka clusters that do not need to be deployed in the same Kubernetes cluster. They can even refer to a Kafka cluster not deployed by Strimzi, or deployed by Strimzi but on a different Kubernetes cluster accessible outside.

If on the same Kubernetes cluster, each list must ideally contain the Kafka cluster bootstrap service which is named `**-kafka-bootstrap` and a port of 9092 for plain traffic or 9093 for encrypted traffic. If deployed by Strimzi but on different Kubernetes clusters, the list content depends on the approach used for exposing the clusters (routes, nodeports or loadbalancers).

When using Kafka MirrorMaker with a Kafka cluster not managed by Strimzi, you can specify the bootstrap servers list according to the configuration of the given cluster.

##### [Whitelist](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-whitelist-deployment-configuration-kafka-mirror-maker)

Use the `whitelist` property to configure a list of topics that Kafka MirrorMaker mirrors from the source to the target Kafka cluster.

The property allows any regular expression from the simplest case with a single topic name to complex patterns. For example, you can mirror topics A and B using "A|B" or all topics using "*". You can also pass multiple regular expressions separated by commas to the Kafka MirrorMaker.

##### [Consumer group identifier](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-groupid-deployment-configuration-kafka-mirror-maker)

Use the `consumer.groupId` property to configure a consumer group identifier for the consumer.

Kafka MirrorMaker uses a Kafka consumer to consume messages, behaving like any other Kafka consumer client. Messages consumed from the source Kafka cluster are mirrored to a target Kafka cluster. A group identifier is required, as the consumer needs to be part of a consumer group for the assignment of partitions.

##### [Consumer streams](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-numstreams-deployment-configuration-kafka-mirror-maker)

Use the `consumer.numStreams` property to configure the number of streams for the consumer.

You can increase the throughput in mirroring topics by increasing the number of consumer threads. Consumer threads belong to the consumer group specified for Kafka MirrorMaker. Topic partitions are assigned across the consumer threads, which consume messages in parallel.

##### [Offset auto-commit interval](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-offset-commit-interval-deployment-configuration-kafka-mirror-maker)

Use the `consumer.offsetCommitInterval` property to configure an offset auto-commit interval for the consumer.

You can specify the regular time interval at which an offset is committed after Kafka MirrorMaker has consumed data from the source Kafka cluster. The time interval is set in milliseconds, with a default value of 60,000.

##### [Abort on message send failure](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-abort-on-send-failure-deployment-configuration-kafka-mirror-maker)

Use the `producer.abortOnSendFailure` property to configure how to handle message send failure from the producer.

By default, if an error occurs when sending a message from Kafka MirrorMaker to a Kafka cluster:

- The Kafka MirrorMaker container is terminated in Kubernetes.
- The container is then recreated.

If the `abortOnSendFailure` option is set to `false`, message sending errors are ignored.

##### [Kafka producer and consumer](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-configuration-deployment-configuration-kafka-mirror-maker)

Use the `consumer.config` and `producer.config` properties to configure Kafka options for the consumer and producer.

The `config` property contains the Kafka MirrorMaker consumer and producer configuration options as keys, with values set in one of the following JSON types:

- String
- Number
- Boolean

Exceptions

You can specify and configure standard Kafka consumer and producer options:

- [Apache Kafka configuration documentation for producers](http://kafka.apache.org/20/documentation.html#producerconfigs)
- [Apache Kafka configuration documentation for consumers](http://kafka.apache.org/20/documentation.html#newconsumerconfigs)

However, there are exceptions for options automatically configured and managed directly by Strimzi related to:

- Kafka cluster bootstrap address
- Security (encryption, authentication, and authorization)
- Consumer group identifier

Specifically, all configuration options with keys equal to or starting with one of the following strings are forbidden:

- `ssl.`
- `sasl.`
- `security.`
- `bootstrap.servers`
- `group.id`

When a forbidden option is present in the `config` property, it is ignored and a warning message is printed to the Custer Operator log file. All other options are passed to Kafka MirrorMaker.

| IMPORTANT | The Cluster Operator does not validate keys or values in the provided `config` object. When an invalid configuration is provided, the Kafka MirrorMaker might not start or might become unstable. In such cases, the configuration in the `KafkaMirrorMaker.spec.consumer.config` or `KafkaMirrorMaker.spec.producer.config` object should be fixed and the Cluster Operator will roll out the new configuration for Kafka MirrorMaker. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

##### [CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#con-resource-limits-and-requests-deployment-configuration-kafka-mirror-maker)

Use the `reources.requests` and `resources.limits` properties to configure resource requests and limits.

For every deployed container, Strimzi allows you to request specific resources and define the maximum consumption of those resources.

Strimzi supports requests and limits for the following types of resources:

- `cpu`
- `memory`

Strimzi uses the Kubernetes syntax for specifying these resources.

For more information about managing computing resources on Kubernetes, see [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

Resource requests

Requests specify the resources to reserve for a given container. Reserving the resources ensures that they are always available.

| IMPORTANT | If the resource request is for more than the available free resources in the Kubernetes cluster, the pod is not scheduled. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

A request may be configured for one or more supported resources.

Resource limits

Limits specify the maximum resources that can be consumed by a given container. The limit is not reserved and might not always be available. A container can use the resources up to the limit only when they are available. Resource limits should be always higher than the resource requests.

A resource may be configured for one or more supported limits.

Supported CPU formats

CPU requests and limits are supported in the following formats:

- Number of CPU cores as integer (`5` CPU core) or decimal (`2.5` CPU core).
- Number or *millicpus* / *millicores* (`100m`) where 1000 *millicores* is the same `1` CPU core.

| NOTE | The computing power of 1 CPU core may differ depending on the platform where Kubernetes is deployed. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

For more information on CPU specification, see the [Meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

Supported memory formats

Memory requests and limits are specified in megabytes, gigabytes, mebibytes, and gibibytes.

- To specify memory in megabytes, use the `M` suffix. For example `1000M`.
- To specify memory in gigabytes, use the `G` suffix. For example `1G`.
- To specify memory in mebibytes, use the `Mi` suffix. For example `1000Mi`.
- To specify memory in gibibytes, use the `Gi` suffix. For example `1Gi`.

For more details about memory specification and additional supported units, see [Meaning of memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).

##### [Kafka MirrorMaker loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-mirror-maker-logging-deployment-configuration-kafka-mirror-maker)

Kafka MirrorMaker has its own configurable logger:

- `mirrormaker.root.logger`

MirrorMaker uses the Apache `log4j` logger implementation.

Use the `logging` property to configure loggers and logger levels.

You can set the log levels by specifying the logger and level directly (inline) or use a custom (external) ConfigMap. If a ConfigMap is used, you set `logging.name` property to the name of the ConfigMap containing the external logging configuration. Inside the ConfigMap, the logging configuration is described using `log4j.properties`.

Here we see examples of `inline` and `external` logging:

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
spec:
  # ...
  logging:
    type: inline
    loggers:
      mirrormaker.root.logger: "INFO"
  # ...
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
spec:
  # ...
  logging:
    type: external
    name: customConfigMap
  # ...
```

Additional resources

- Garbage collector (GC) logging can also be enabled (or disabled). For more information about GC logging, see [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka)
- For more information about log levels, see [Apache logging services](https://logging.apache.org/).

##### [Healthchecks](https://strimzi.io/docs/operators/0.18.0/using.html#con-healthchecks-deployment-configuration-kafka-mirror-maker)

Use the `livenessProbe` and `readinessProbe` properties to configure healthcheck probes supported in Strimzi.

Healthchecks are periodical tests which verify the health of an application. When a Healthcheck probe fails, Kubernetes assumes that the application is not healthy and attempts to fix it.

For more details about the probes, see [Configure Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/).

Both `livenessProbe` and `readinessProbe` support the following options:

- `initialDelaySeconds`
- `timeoutSeconds`
- `periodSeconds`
- `successThreshold`
- `failureThreshold`

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

For more information about the `livenessProbe` and `readinessProbe` options, see [Probe schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Probe-reference).

##### [Prometheus metrics](https://strimzi.io/docs/operators/0.18.0/using.html#con-metrics-deployment-configuration-kafka-mirror-maker)

Use the `metrics` property to enable and configure Prometheus metrics.

The `metrics` property can also contain additional configuration for the [Prometheus JMX exporter](https://github.com/prometheus/jmx_exporter). Strimzi supports Prometheus metrics using Prometheus JMX exporter to convert the JMX metrics supported by Apache Kafka and ZooKeeper to Prometheus metrics.

To enable Prometheus metrics export without any further configuration, you can set it to an empty object (`{}`).

When metrics are enabled, they are exposed on port 9404.

When the `metrics` property is not defined in the resource, the Prometheus metrics are disabled.

For more information about setting up and deploying Prometheus and Grafana, see [Introducing Metrics to Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str).

##### [JVM Options](https://strimzi.io/docs/operators/0.18.0/using.html#con-jvm-options-deployment-configuration-kafka-mirror-maker)

Use the `jvmOptions` property to configure supported options for the JVM on which the component is running.

Supported JVM options help to optimize performance for different platforms and architectures.

For more information on the supported options, see [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka).

##### [Container images](https://strimzi.io/docs/operators/0.18.0/using.html#con-configuring-container-images-deployment-configuration-kafka-mirror-maker)

Use the `image` property to configure the container image used by the component.

Overriding container images is recommended only in special situations where you need to use a different container registry or a customized image.

For example, if your network does not allow access to the container repository used by Strimzi, you can copy the Strimzi images or build them from the source. However, if the configured image is not compatible with Strimzi images, it might not work properly.

A copy of the container image might also be customized and used for debugging.

For more information see [Container image configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-configuring-container-images-deployment-configuration-kafka).

#### [3.4.3. List of resources created as part of Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#ref-list-of-kafka-mirror-maker-resources-deployment-configuration-kafka-mirror-maker)

The following resources are created by the Cluster Operator in the Kubernetes cluster:

- **-mirror-maker

  Deployment which is responsible for creating the Kafka MirrorMaker pods.

- **-config

  ConfigMap which contains ancillary configuration for the the Kafka MirrorMaker, and is mounted as a volume by the Kafka broker pods.

- **-mirror-maker

  Pod Disruption Budget configured for the Kafka MirrorMaker worker nodes.

#### [3.4.4. Using Strimzi with MirrorMaker 2.0.](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-mirrormaker-deployment-configuration-kafka-mirror-maker)

This section describes using Strimzi with MirrorMaker 2.0.

MirrorMaker 2.0 is used to replicate data between two or more active Kafka clusters, within or across data centers.

Data replication across clusters supports scenarios that require:

- Recovery of data in the event of a system failure
- Aggregation of data for analysis
- Restriction of data access to a specific cluster
- Provision of data at a specific location to improve latency

| NOTE | MirrorMaker 2.0 has features not supported by the previous version of MirrorMaker. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

##### [MirrorMaker 2.0 data replication](https://strimzi.io/docs/operators/0.18.0/using.html#con-mirrormaker-deployment-configuration-kafka-mirror-maker)

MirrorMaker 2.0 consumes messages from a source Kafka cluster and writes them to a target Kafka cluster.

MirrorMaker 2.0 uses:

- Source cluster configuration to consume data from the source cluster
- Target cluster configuration to output data to the target cluster

MirrorMaker 2.0 is based on the Kafka Connect framework, *connectors* managing the transfer of data between clusters. A MirrorMaker 2.0 `MirrorSourceConnector` replicates topics from a source cluster to a target cluster.

The process of *mirroring* data from one cluster to another cluster is asynchronous. The recommended pattern is for messages to be produced locally alongside the source Kafka cluster, then consumed remotely close to the target Kafka cluster.

MirrorMaker 2.0 can be used with more than one source cluster.

![MirrorMaker 2.0 replication](https://strimzi.io/docs/operators/0.18.0/images/mirrormaker.png)

Figure 1. Replication across two clusters

##### [Cluster configuration](https://strimzi.io/docs/operators/0.18.0/using.html#cluster_configuration)

You can use MirrorMaker 2.0 in *active/passive* or *active/active* cluster configurations.

- In an *active/passive* configuration, the data from an active cluster is replicated in a passive cluster, which remains on standby, for example, for data recovery in the event of system failure.
- In an *active/active* configuration, both clusters are active and provide the same data simultaneously, which is useful if you want to make the same data available locally in different geographical locations.

The expectation is that producers and consumers connect to active clusters only.

###### [Bidirectional replication](https://strimzi.io/docs/operators/0.18.0/using.html#bidirectional_replication)

The MirrorMaker 2.0 architecture supports bidirectional replication in an *active/active* cluster configuration. A MirrorMaker 2.0 cluster is required at each target destination.

Each cluster replicates the data of the other cluster using the concept of *source* and *remote* topics. As the same topics are stored in each cluster, remote topics are automatically renamed by MirrorMaker 2.0 to represent the source cluster.

![MirrorMaker 2.0 bidirectional architecture](https://strimzi.io/docs/operators/0.18.0/images/mirrormaker-renaming.png)

Figure 2. Topic renaming

By flagging the originating cluster, topics are not replicated back to that cluster.

The concept of replication through *remote* topics is useful when configuring an architecture that requires data aggregation. Consumers can subscribe to source and remote topics within the same cluster, without the need for a separate aggregation cluster.

###### [Topic configuration synchronization](https://strimzi.io/docs/operators/0.18.0/using.html#topic_configuration_synchronization)

Topic configuration is automatically synchronized between source and target clusters. By synchronizing configuration properties, the need for rebalancing is reduced.

###### [Data integrity](https://strimzi.io/docs/operators/0.18.0/using.html#data_integrity)

MirrorMaker 2.0 monitors source topics and propagates any configuration changes to remote topics, checking for and creating missing partitions. Only MirrorMaker 2.0 can write to remote topics.

###### [Offset tracking](https://strimzi.io/docs/operators/0.18.0/using.html#offset_tracking)

MirrorMaker 2.0 tracks offsets for consumer groups using *internal topics*.

- The *offset sync* topic maps the source and target offsets for replicated topic partitions from record metadata
- The *checkpoint* topic maps the last committed offset in the source and target cluster for replicated topic partitions in each consumer group

Offsets for the *checkpoint* topic are tracked at predetermined intervals through configuration. Both topics enable replication to be fully restored from the correct offset position on failover.

MirrorMaker 2.0 uses its `MirrorCheckpointConnector` to emit *checkpoints* for offset tracking.

###### [Connectivity checks](https://strimzi.io/docs/operators/0.18.0/using.html#connectivity_checks)

A *heartbeat* internal topic checks connectivity between clusters.

The *heartbeat* topic is replicated from the source cluster.

Target clusters use the topic to check:

- The connector managing connectivity between clusters is running
- The source cluster is available

MirrorMaker 2.0 uses its `MirrorHeartbeatConnector` to emit *heartbeats* that perform these checks.

##### [ACL rules synchronization](https://strimzi.io/docs/operators/0.18.0/using.html#con-mirrormaker-aclsdeployment-configuration-kafka-mirror-maker)

ACL access to remote topics is possible if you are **not** using the User Operator.

If `SimpleAclAuthorizer` is being used, without the User Operator, ACL rules that manage access to brokers also apply to remote topics. Users that can read a source topic can read its remote equivalent.

| NOTE | OAuth 2.0 authorization does not support access to remote topics in this way. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

##### [Synchronizing data between Kafka clusters using MirrorMaker 2.0](https://strimzi.io/docs/operators/0.18.0/using.html#proc-mirrormaker-replication-deployment-configuration-kafka-mirror-maker)

Use MirrorMaker 2.0 to synchronize data between Kafka clusters through configuration.

The previous version of MirrorMaker continues to be supported. If you wish to use the resources configured for the previous version, they must be updated to the format supported by MirrorMaker 2.0.

The configuration must specify:

- Each Kafka cluster
- Connection information for each cluster, including TLS authentication
- The replication flow and direction
  - Cluster to cluster
  - Topic to topic

Use the properties of the `KafkaMirrorMaker2` resource to configure your Kafka MirrorMaker 2.0 deployment.

MirrorMaker 2.0 provides default configuration values for properties such as replication factors. A minimal configuration, with defaults left unchanged, would be something like this example:

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaMirrorMaker2
metadata:
  name: my-mirror-maker2
spec:
  version: 2.5.0
  connectCluster: "my-cluster-target"
  clusters:
  - alias: "my-cluster-source"
    bootstrapServers: my-cluster-source-kafka-bootstrap:9092
  - alias: "my-cluster-target"
    bootstrapServers: my-cluster-target-kafka-bootstrap:9092
  mirrors:
  - sourceCluster: "my-cluster-source"
    targetCluster: "my-cluster-target"
    sourceConnector: {}
```

You can configure access control for source and target clusters using TLS or SASL authentication. This procedure shows a configuration that uses TLS encryption and authentication for the source and target cluster.

Prerequisites

- [Strimzi and Kafka is deployed](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-operator-str)
- Source and target Kafka clusters are available

Procedure

1. Edit the `spec` properties for the `KafkaMirrorMaker2` resource.

   The properties you can configure are shown in this example configuration:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaMirrorMaker2
   metadata:
     name: my-mirror-maker2
   spec:
     version: 2.5.0 (1)
     replicas: 3 (2)
     connectCluster: "my-cluster-target" (3)
     clusters: (4)
     - alias: "my-cluster-source" (5)
       authentication: (6)
         certificateAndKey:
           certificate: source.crt
           key: source.key
           secretName: my-user-source
         type: tls
       bootstrapServers: my-cluster-source-kafka-bootstrap:9092 (7)
       tls: (8)
         trustedCertificates:
         - certificate: ca.crt
           secretName: my-cluster-source-cluster-ca-cert
     - alias: "my-cluster-target" (9)
       authentication: (10)
         certificateAndKey:
           certificate: target.crt
           key: target.key
           secretName: my-user-target
         type: tls
       bootstrapServers: my-cluster-target-kafka-bootstrap:9092 (11)
       config: (12)
         config.storage.replication.factor: 1
         offset.storage.replication.factor: 1
         status.storage.replication.factor: 1
       tls: (13)
         trustedCertificates:
         - certificate: ca.crt
           secretName: my-cluster-target-cluster-ca-cert
     mirrors: (14)
     - sourceCluster: "my-cluster-source" (15)
       targetCluster: "my-cluster-target" (16)
       sourceConnector: (17)
         config:
           replication.factor: 1 (18)
           offset-syncs.topic.replication.factor: 1 (19)
           sync.topic.acls.enabled: "false" (20)
       heartbeatConnector: (21)
         config:
           heartbeats.topic.replication.factor: 1 (22)
       checkpointConnector: (23)
         config:
           checkpoints.topic.replication.factor: 1 (24)
       topicsPattern: ".*" (25)
       groupsPattern: "group1|group2|group3" (26)
   ```

   1. The Kafka Connect version.
   2. The number of replica nodes.
   3. The cluster alias for Kafka Connect.
   4. Specification for the Kafka clusters being synchronized.
   5. The cluster alias for the source Kafka cluster.
   6. Authentication for the source cluster, using the [TLS mechanism](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationTls-reference), as shown here, using [OAuth bearer tokens](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationOAuth-reference), or a SASL-based [SCRAM-SHA-512](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationScramSha512-reference) or [PLAIN](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaClientAuthenticationPlain-reference) mechanism.
   7. Bootstrap server for connection to the source Kafka cluster.
   8. TLS encryption with key names under which TLS certificates are stored in X.509 format for the source Kafka cluster. For more details see [`KafkaMirrorMaker2Tls` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaMirrorMaker2Tls-reference).
   9. The cluster alias for the target Kafka cluster.
   10. Authentication for the target Kafka cluster is configured in the same way as for the source Kafka cluster.
   11. Bootstrap server for connection to the target Kafka cluster.
   12. [Kafka Connect configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-connect-configuration-deployment-configuration-kafka-connect). Standard Apache Kafka configuration may be provided, restricted to those properties not managed directly by Strimzi.
   13. TLS encryption for the target Kafka cluster is configured in the same way as for the source Kafka cluster.
   14. MirrorMaker 2.0 connectors.
   15. The alias of the source cluster used by the MirrorMaker 2.0 connectors.
   16. The alias of the target cluster used by the MirrorMaker 2.0 connectors.
   17. The configuration for the `MirrorSourceConnector` that creates remote topics. The `config` overrides the default configuration options.
   18. The replication factor for mirrored topics created at the target cluster.
   19. The replication factor for the `MirrorSourceConnector` `offset-syncs` internal topic that maps the offsets of the source and target clusters.
   20. When enabled, ACLs are applied to synchronized topics. The default is `true`.
   21. The configuration for the `MirrorHeartbeatConnector` that performs connectivity checks. The `config` overrides the default configuration options.
   22. The replication factor for the heartbeat topic created at the target cluster.
   23. The configuration for the `MirrorCheckpointConnector` that tracks offsets. The `config` overrides the default configuration options.
   24. The replication factor for the checkpoints topic created at the target cluster.
   25. Topic replication from the source cluster defined as regular expression patterns. Here we request all topics.
   26. Consumer group replication from the source cluster defined as regular expression patterns. Here we request three consumer groups by name. You can use comma-separated lists.

2. Create or update the resource:

   ```shell
   kubectl apply -f <your-file>
   ```

### [3.5. Kafka Bridge configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-bridge-str)

The full schema of the `KafkaBridge` resource is described in the [`KafkaBridge` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaBridge-reference). All labels that are applied to the desired `KafkaBridge` resource w