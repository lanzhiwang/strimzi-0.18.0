# Xinfra Monitor

Xinfra Monitor (formerly Kafka Monitor) is a framework to implement and execute long-running kafka system tests in a real cluster. It complements Kafka’s existing system tests by capturing potential bugs or regressions that are only likely to occur after prolonged period of time or with low probability. Moreover, it allows you to monitor Kafka cluster using end-to-end pipelines to obtain a number of derived vital stats such as
Xinfra Monitor（以前称为 Kafka Monitor）是一个框架，用于在真实集群中实现和执行长时间运行的 kafka 系统测试。 它通过捕获仅可能在长时间后或低概率发生的潜在错误或回归来补充 Kafka 现有的系统测试。 此外，它允许您使用端到端管道监控 Kafka 集群，以获取许多派生的重要统计信息，例如

1. End-to-end latency  端到端延迟

2. Service availability  服务可用性

3. Produce and Consume availability  生产和消费可用性

4. Consumer offset commit availability  消费者偏移提交可用性

5. Consumer offset commit latency  消费者偏移提交延迟

6. Kafka message loss rate  Kafka消息丢失率

7. And many, many more.  还有很多很多。

You can easily deploy Xinfra Monitor to test and monitor your Kafka cluster without requiring any change to your application.  您可以轻松部署 Xinfra Monitor 来测试和监控您的 Kafka 集群，而无需对您的应用程序进行任何更改。

Xinfra Monitor can automatically create the monitor topic with the specified config and increase partition count of the monitor topic to ensure partition# >= broker#. It can also reassign partition and trigger preferred leader election to ensure that each broker acts as leader of at least one partition of the monitor topic. This allows Xinfra Monitor to detect performance issue on every broker without requiring users to manually manage the partition assignment of the monitor topic.  Xinfra Monitor 可以自动创建具有指定配置的监控主题，并增加监控主题的分区数，以确保 partition# >= broker#。 它还可以重新分配分区并触发首选领导者选举，以确保每个代理充当监控主题的至少一个分区的领导者。 这允许 Xinfra Monitor 检测每个代理上的性能问题，而无需用户手动管理监控主题的分区分配。

Xinfra Monitor is used in conjunction with different middle-layer services such as li-apache-kafka-clients in order to monitor single clusters, pipeline desination clusters, and other types of clusters as done in Linkedin engineering for real-time cluster healthchecks.  Xinfra Monitor 与不同的中间层服务（如 li-apache-kafka-clients）结合使用，以监控单个集群、管道目标集群和其他类型的集群，如 Linkedin 工程中所做的那样，用于实时集群健康检查。

These are some of the metrics emitted from a Xinfra Monitor instance.  这些是从 Xinfra Monitor 实例发出的一些指标。

```
kmf:type=kafka-monitor:offline-runnable-count
kmf.services:type=produce-service,name=*:produce-availability-avg
kmf.services:type=consume-service,name=*:consume-availability-avg
kmf.services:type=produce-service,name=*:records-produced-total
kmf.services:type=consume-service,name=*:records-consumed-total
kmf.services:type=produce-service,name=*:records-produced-rate
kmf.services:type=produce-service,name=*:produce-error-rate
kmf.services:type=consume-service,name=*:consume-error-rate
kmf.services:type=consume-service,name=*:records-lost-total
kmf.services:type=consume-service,name=*:records-lost-rate
kmf.services:type=consume-service,name=*:records-duplicated-total
kmf.services:type=consume-service,name=*:records-delay-ms-avg
kmf.services:type=commit-availability-service,name=*:offsets-committed-avg
kmf.services:type=commit-availability-service,name=*:offsets-committed-total
kmf.services:type=commit-availability-service,name=*:failed-commit-offsets-avg
kmf.services:type=commit-availability-service,name=*:failed-commit-offsets-total
kmf.services:type=commit-latency-service,name=*:commit-offset-latency-ms-avg
kmf.services:type=commit-latency-service,name=*:commit-offset-latency-ms-max
kmf.services:type=commit-latency-service,name=*:commit-offset-latency-ms-99th
kmf.services:type=commit-latency-service,name=*:commit-offset-latency-ms-999th
kmf.services:type=commit-latency-service,name=*:commit-offset-latency-ms-9999th
```

## Getting Started

### Prerequisites

Xinfra Monitor requires Gradle 2.0 or higher. Java 7 should be used for building in order to support both Java 7 and Java 8 at runtime.  Xinfra Monitor 需要 Gradle 2.0 或更高版本。 应使用 Java 7 进行构建，以便在运行时同时支持 Java 7 和 Java 8。

Xinfra Monitor supports Apache Kafka 0.8 to 2.0:  Xinfra Monitor 支持 Apache Kafka 0.8 到 2.0：

- Use branch 0.8.2.2 to work with Apache Kafka 0.8

- Use branch 0.9.0.1 to work with Apache Kafka 0.9

- Use branch 0.10.2.1 to work with Apache Kafka 0.10

- Use branch 0.11.x to work with Apache Kafka 0.11

- Use branch 1.0.x to work with Apache Kafka 1.0

- Use branch 1.1.x to work with Apache Kafka 1.1

- Use master branch to work with Apache Kafka 2.0

### Configuration Tips

1. We advise advanced users to run Xinfra Monitor with `./bin/xinfra-monitor-start.sh config/xinfra-monitor.properties`. The default xinfra-monitor.properties in the repo provides an simple example of how to monitor a single cluster. You probably need to change the value of `zookeeper.connect` and `bootstrap.servers` to point to your cluster.  我们建议高级用户使用 ./bin/xinfra-monitor-start.sh config/xinfra-monitor.properties 运行 Xinfra Monitor。存储库中默认的 xinfra-monitor.properties 提供了一个简单示例，说明如何监控单个集群。您可能需要更改 zookeeper.connect 和 bootstrap.servers 的值以指向您的集群。

2. The full list of configs and their documentation can be found in the code of Config class for respective service, e.g. ProduceServiceConfig.java and ConsumeServiceConfig.java.  配置及其文档的完整列表可以在相应服务的 Config 类的代码中找到，例如ProduceServiceConfig.java 和 ConsumeServiceConfig.java。

3. You can specify multiple SingleClusterMonitor in the xinfra-monitor.properties to monitor multiple Kafka clusters in one Xinfra Monitor process. As another advanced use-case, you can point ProduceService and ConsumeService to two different Kafka clusters that are connected by MirrorMaker to monitor their end-to-end latency.  您可以在 xinfra-monitor.properties 中指定多个 SingleClusterMonitor，以在一个 Xinfra Monitor 进程中监控多个 Kafka 集群。作为另一个高级用例，您可以将 ProduceService 和 ConsumeService 指向两个由 MirrorMaker 连接的不同 Kafka 集群，以监控它们的端到端延迟。

4. Xinfra Monitor by default will automatically create the monitor topic based on the e.g. `topic-management.replicationFactor` and `topic-management.partitionsToBrokersRatio` specified in the config.replicationFactor is 1 by default and you probably want to change it to the same replication factor as used for your existing topics. You can disable auto topic creation by setting `produce.topic.topicCreationEnabled` to false.  默认情况下，Xinfra Monitor 将根据例如自动创建监控主题。 topic-management.replicationFactor 和 topic-management.partitionsToBrokersRatio 在配置中指定。 replicationFactor 默认为 1，您可能希望将其更改为与现有主题相同的复制因子。您可以通过将 producer.topic.topicCreationEnabled 设置为 false 来禁用自动创建主题。

5. Xinfra Monitor can automatically increase partition count of the monitor topic to ensure partition# >= broker#. It can also reassign partition and trigger preferred leader election to ensure that each broker acts as leader of at least one partition of the monitor topic. To use this feature, use either EndToEndTest or TopicManagementService in the properties file.  Xinfra Monitor 可以自动增加监控主题的分区数，以确保 partition# >= broker#。它还可以重新分配分区并触发首选领导者选举，以确保每个代理充当监控主题的至少一个分区的领导者。要使用此功能，请在属性文件中使用 EndToEndTest 或 TopicManagementService。

6. When using `Secure Sockets Layer` (SSL) or any non-plaintext security protocol for AdminClient, please configure the following entries in the `single-cluster-monitor` props, `produce.producer.props`, as well as `consume.consumer.props` https://docs.confluent.io/current/installation/configuration/admin-configs.html  当为 AdminClient 使用安全套接字层 (SSL) 或任何非明文安全协议时，请在单集群监视器 props、produce.producer.props 和 consume.consumer.props 中配置以下条目。 https://docs.confluent.io/current/installation/configuration/admin-configs.html

* ssl.key.password
* ssl.keystore.location
* ssl.keystore.password
* ssl.truststore.location
* ssl.truststore.password

### Build Xinfra Monitor

```
$ git clone https://github.com/linkedin/kafka-monitor.git
$ cd kafka-monitor
$ ./gradlew jar
Downloading https://services.gradle.org/distributions/gradle-5.2.1-all.zip
Unzipping /Users/huzhi/.gradle/wrapper/dists/gradle-5.2.1-all/bviwmvmbexq6idcscbicws5me/gradle-5.2.1-all.zip to /Users/huzhi/.gradle/wrapper/dists/gradle-5.2.1-all/bviwmvmbexq6idcscbicws5me
Set executable permissions for: /Users/huzhi/.gradle/wrapper/dists/gradle-5.2.1-all/bviwmvmbexq6idcscbicws5me/gradle-5.2.1/bin/gradle

Welcome to Gradle 5.2.1!

Here are the highlights of this release:
 - Define sets of dependencies that work together with Java Platform plugin
 - New C++ plugins with dependency management built-in
 - New C++ project types for gradle init
 - Service injection into plugins and project extensions

For more details see https://docs.gradle.org/5.2.1/release-notes.html

Starting a Gradle Daemon (subsequent builds will be faster)

> Task :compileJava
注: /Users/huzhi/work/code/java_code/kafka-monitor/src/main/java/com/linkedin/xinfra/monitor/consumer/NewConsumer.java使用或覆盖了已过时的 API。
注: 有关详细信息, 请使用 -Xlint:deprecation 重新编译。
注: 某些输入文件使用了未经检查或不安全的操作。
注: 有关详细信息, 请使用 -Xlint:unchecked 重新编译。

BUILD SUCCESSFUL in 1m 4s
3 actionable tasks: 3 executed

$ tree -L 4 build
build
├── classes
│   └── java
│       └── main
│           └── com
├── dependant-libs
│   ├── argparse4j-0.5.0.jar
│   ├── audience-annotations-0.5.0.jar
│   ├── avro-1.9.2.jar
│   ├── commons-cli-1.4.jar
│   ├── commons-compress-1.19.jar
│   ├── commons-lang3-3.12.0.jar
│   ├── graphite-client-1.1.0-RELEASE.jar
│   ├── helper-all-0.2.81.jar
│   ├── jackson-annotations-2.10.2.jar
│   ├── jackson-core-2.10.2.jar
│   ├── jackson-databind-2.10.2.jar
│   ├── jackson-dataformat-csv-2.10.0.jar
│   ├── jackson-datatype-jdk8-2.10.0.jar
│   ├── jackson-module-paranamer-2.10.0.jar
│   ├── jackson-module-scala_2.12-2.10.0.jar
│   ├── java-statsd-client-3.0.1.jar
│   ├── jolokia-core-1.6.2.jar
│   ├── jolokia-jvm-1.6.2.jar
│   ├── jopt-simple-5.0.4.jar
│   ├── json-20140107.jar
│   ├── json-simple-1.1.1.jar
│   ├── kafka-clients-2.4.0.jar
│   ├── kafka_2.12-2.4.0.jar
│   ├── log4j-api-2.17.1.jar
│   ├── log4j-core-2.17.1.jar
│   ├── log4j-slf4j-impl-2.17.1.jar
│   ├── lz4-java-1.6.0.jar
│   ├── metrics-core-2.2.0.jar
│   ├── metrics-core-3.2.3.jar
│   ├── netty-buffer-4.1.42.Final.jar
│   ├── netty-codec-4.1.42.Final.jar
│   ├── netty-common-4.1.42.Final.jar
│   ├── netty-handler-4.1.42.Final.jar
│   ├── netty-resolver-4.1.42.Final.jar
│   ├── netty-transport-4.1.42.Final.jar
│   ├── netty-transport-native-epoll-4.1.42.Final.jar
│   ├── netty-transport-native-unix-common-4.1.42.Final.jar
│   ├── paranamer-2.8.jar
│   ├── scala-collection-compat_2.12-2.1.2.jar
│   ├── scala-java8-compat_2.12-0.9.0.jar
│   ├── scala-library-2.12.10.jar
│   ├── scala-logging_2.12-3.9.2.jar
│   ├── scala-reflect-2.12.10.jar
│   ├── signalfx-codahale-0.0.47.jar
│   ├── slf4j-api-1.7.28.jar
│   ├── snappy-java-1.1.7.3.jar
│   ├── zookeeper-3.5.6.jar
│   ├── zookeeper-jute-3.5.6.jar
│   └── zstd-jni-1.4.3-1.jar
├── generated
│   └── sources
│       └── annotationProcessor
│           └── java
├── libs
│   └── kafka-monitor-2.5.13-SNAPSHOT.jar
└── tmp
    ├── compileJava
    └── jar
        └── MANIFEST.MF

13 directories, 51 files


$ tree -a build/classes/java/main/com/linkedin/xinfra/monitor/
build/classes/java/main/com/linkedin/xinfra/monitor/
├── XinfraMonitor.class
├── XinfraMonitorConstants.class
├── apps
│   ├── App.class
│   ├── MultiClusterMonitor.class
│   ├── SingleClusterMonitor.class
│   └── configs
│       └── MultiClusterMonitorConfig.class
├── common
│   ├── ConfigDocumentationGenerator.class
│   ├── ConsumerGroupCoordinatorUtils.class
│   ├── DefaultTopicSchema.class
│   ├── MbeanAttributeValue.class
│   └── Utils.class
├── consumer
│   ├── BaseConsumerRecord.class
│   ├── KMBaseConsumer.class
│   ├── NewConsumer.class
│   └── NewConsumerConfig.class
├── partitioner
│   ├── KMPartitioner.class
│   └── NewKMPartitioner.class
├── producer
│   ├── BaseProducerRecord.class
│   ├── KMBaseProducer.class
│   └── NewProducer.class
├── services
│   ├── AbstractService.class
│   ├── ClusterTopicManipulationService$1.class
│   ├── ClusterTopicManipulationService$ClusterTopicManipulationServiceRunnable.class
│   ├── ClusterTopicManipulationService.class
│   ├── ClusterTopicManipulationServiceFactory.class
│   ├── ConsumeService$1.class
│   ├── ConsumeService.class
│   ├── ConsumeServiceFactory.class
│   ├── ConsumerFactory.class
│   ├── ConsumerFactoryImpl.class
│   ├── DefaultMetricsReporterService.class
│   ├── DefaultMetricsReporterServiceFactory.class
│   ├── GraphiteMetricsReporterService$1.class
│   ├── GraphiteMetricsReporterService.class
│   ├── GraphiteMetricsReporterServiceFactory.class
│   ├── JolokiaService.class
│   ├── JolokiaServiceFactory.class
│   ├── KafkaMetricsReporterService.class
│   ├── KafkaMetricsReporterServiceFactory.class
│   ├── MultiClusterTopicManagementService$1.class
│   ├── MultiClusterTopicManagementService$PreferredLeaderElectionRunnable.class
│   ├── MultiClusterTopicManagementService$TopicManagementHelper.class
│   ├── MultiClusterTopicManagementService$TopicManagementRunnable.class
│   ├── MultiClusterTopicManagementService.class
│   ├── MultiClusterTopicManagementServiceFactory.class
│   ├── OffsetCommitService$1.class
│   ├── OffsetCommitService$OffsetCommitServiceRunnable.class
│   ├── OffsetCommitService.class
│   ├── OffsetCommitServiceFactory.class
│   ├── ProduceService$1.class
│   ├── ProduceService$HandleNewPartitionsThreadFactory.class
│   ├── ProduceService$NewPartitionHandler.class
│   ├── ProduceService$ProduceRunnable.class
│   ├── ProduceService$ProduceServiceThreadFactory.class
│   ├── ProduceService.class
│   ├── ProduceServiceFactory.class
│   ├── Service.class
│   ├── ServiceFactory.class
│   ├── SignalFxMetricsReporterService.class
│   ├── SignalFxMetricsReporterServiceFactory.class
│   ├── StatsdMetricsReporterService.class
│   ├── StatsdMetricsReporterServiceFactory.class
│   ├── TopicManagementService.class
│   ├── TopicManagementServiceFactory.class
│   ├── configs
│   │   ├── CommonServiceConfig.class
│   │   ├── ConsumeServiceConfig.class
│   │   ├── DefaultMetricsReporterServiceConfig.class
│   │   ├── GraphiteMetricsReporterServiceConfig.class
│   │   ├── JettyServiceConfig.class
│   │   ├── KafkaMetricsReporterServiceConfig.class
│   │   ├── MultiClusterTopicManagementServiceConfig.class
│   │   ├── ProduceServiceConfig.class
│   │   ├── SignalFxMetricsReporterServiceConfig.class
│   │   ├── StatsdMetricsReporterServiceConfig.class
│   │   └── TopicManagementServiceConfig.class
│   └── metrics
│       ├── ClusterTopicManipulationMetrics.class
│       ├── CommitAvailabilityMetrics.class
│       ├── CommitLatencyMetrics.class
│       ├── ConsumeMetrics.class
│       ├── OffsetCommitServiceMetrics$1.class
│       ├── OffsetCommitServiceMetrics.class
│       ├── ProduceMetrics.class
│       └── XinfraMonitorMetrics.class
├── tests
│   ├── BasicEndToEndTest.class
│   └── Test.class
└── topicfactory
    ├── DefaultTopicFactory.class
    └── TopicFactory.class

11 directories, 87 files
$


```

### Start XinfraMonitor to run tests/services specified in the config file

```
$ ./bin/xinfra-monitor-start.sh config/xinfra-monitor.properties
```

### Run Xinfra Monitor with arbitrary producer/consumer configuration (e.g. SASL enabled client)

Edit `config/xinfra-monitor.properties` to specify custom configurations for producer in the key/value map `produce.producer.props` in `config/xinfra-monitor.properties`. Similarly specify configurations for consumer as well. The documentation for producer and consumer in the key/value maps can be found in the Apache Kafka wiki.

```
$ ./bin/xinfra-monitor-start.sh config/xinfra-monitor.properties
```

### Run SingleClusterMonitor app to monitor kafka cluster

Metrics `produce-availability-avg` and `consume-availability-avg` demonstrate whether messages can be properly produced to and consumed from this cluster. See Service Overview wiki for how these metrics are derived.

```
$ ./bin/single-cluster-monitor.sh --topic test --broker-list localhost:9092 --zookeeper localhost:2181
```

### Run MultiClusterMonitor app to monitor a pipeline of Kafka clusters connected by MirrorMaker

Edit `config/multi-cluster-monitor.properties` to specify the right broker and zookeeper url as suggested by the comment in the properties file

Metrics `produce-availability-avg` and `consume-availability-avg` demonstrate whether messages can be properly produced to the source cluster and consumed from the destination cluster. See config/multi-cluster-monitor.properties for the full jmx path for these metrics.

```
$ ./bin/xinfra-monitor-start.sh config/multi-cluster-monitor.properties
```

### Run checkstyle on the java code

```
./gradlew checkstyleMain checkstyleTest
```

### Build IDE project

```
./gradlew idea
./gradlew eclipse
```

## Wiki

- [Motivation](https://github.com/linkedin/kafka-monitor/wiki/Motivation)  动机

- [Design Overview](https://github.com/linkedin/kafka-monitor/wiki/Design-Overview)  设计概述

- [Service and App Overview](https://github.com/linkedin/kafka-monitor/wiki)  服务和应用概述

- [Future Work](https://github.com/linkedin/kafka-monitor/wiki/Future-Work)  未来的工作

- [Application Configuration](https://github.com/linkedin/kafka-monitor/wiki/App-Configuration)  应用程序配置

