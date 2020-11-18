# Strimzi HTTP Bridge for Apache Kafka

适用于Apache Kafka的Strimzi HTTP桥提供了REST API，用于将基于HTTP的客户端应用程序与Kafka集群集成在一起。 您可以使用API来创建和管理使用者，并通过HTTP（而非本机Kafka协议）发送和接收记录。

## 实践

Strimzi HTTP Bridge 提供的是一个 REST API，使用 API 来操作 Kafka 中的相关资源，因此部署和使用都比较简单。

对于部署，只需要部署 kafka 集群和相关的资源，然后部署 KafkaBridge 连接到 kafka 集群即可。

对于使用，只需要知道 KafkaBridge 提供了哪些 API ，使用 http 客户端工具（比如curl）访问 API 即可。由于 Strimzi HTTP Bridge 提供的 API 不是很完善，功能也不是很全，所以 Strimzi HTTP Bridge 基本只能作为适用性功能使用

1. 部署 kafka 集群及相关资源

```yaml
# 创建 Kafka 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    jmxOptions: {}
    listeners:
      tls:
        authentication:
          type: tls
    authorization:
      type: simple
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}

---

# 创建 KafkaUser 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: tls
  authorization:
    type: simple
    acls:
      # topic my-topic
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-offsets
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-configs
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-status
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Write
        host: '*'

      # group
      - resource:
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'

      - resource:
          type: group
          name: connect-test-file-sink
          patternType: literal
        operation: Read
        host: '*'

      - resource:
          type: group
          name: connect-my-sink-connector
          patternType: literal
        operation: Read
        host: '*'

---

# 创建 KafkaTopic 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824

```

2. 部署 Strimzi HTTP Bridge

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  replicas: 2
  bootstrapServers: my-cluster-kafka-bootstrap:9093
  tls:
    trustedCertificates:
    - secretName: my-cluster-cluster-ca-cert
      certificate: ca.crt
  authentication:
    type: tls
    certificateAndKey:
      secretName: my-user
      certificate: user.crt
      key: user.key
  http:
    port: 8080

```

3. 获取 Strimzi HTTP Bridge 提供的 API

```bash
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

$ curl -i -X GET -H "Content-Type: application/json" http://my-bridge-bridge-service:8080/openapi

```

4.根据不同的 API 进行调用

每个 API 的详细用法参考[文档](https://strimzi.io/docs/bridge/master/)，文档提供了比较全面的API 说明，但不同版本的 Strimzi HTTP Bridge 实现却不相同，因此需要以实际操作为准。
