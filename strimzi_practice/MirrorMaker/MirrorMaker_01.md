# MirrorMake

## MirrorMake 基础

![](../../images/mirrormake/01.png)

Kafka 默认提供了一个工具 MirrorMaker，用来帮助用户实现数据在两个 Kafka 集群间的拷贝。就具体实现而言，MirrorMaker 是一个 consumer + producer 的混合体。对于源 kafka 集群而言，它是一个 consumer；而对于目标 kafka 集群而言，它又是一个producer。MirrorMaker 读取源 kafka 集群指定 topic 的数据，然后写入目标 kafka 集群中的`同名 topic` 下。

## MirrorMake 实践

实践思路如下：

1. 假设有两个 k8s 集群：`k8s-01`和 `k8s-02`，在 k8s-01 上部署源 kafka 集群，在 k8s-02上部署目标 kafka 集群。在两个集群上也分别部署 user 和 topic。部署完成后再集群中会生成相关的 Secret 和 Service。如下如所示。

![](../../images/mirrormake/02.png)

2. 在 k8s-01上部署 MirrorMaker。部署 MirrorMaker 时需要配置 consumer 连接到源 kafka 集群，配置 producer 连接到目标 kafka 集群。连接源 kafka 集群使用 k8s-01 上的 Secret 和 Service。连接目标 kafka 集群需要使用 k8s-02 上的 Secret 和 Service。所以需要根据 k8s-02 上的 Secret 和 Service 信息在 k8s-01 上部署额外的 Secret 和 Service。如下图所示。

![](../../images/mirrormake/03.png)

3. 在 k8s-01上部署 MirrorMaker。

![](../../images/mirrormake/04.png)

## MirrorMake 操作

1. 在 k8s-01 上部署源 kafka 集群，user，topic

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
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'
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
        operation: Describe
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

2. 在 k8s-02 上部署目标 kafka 集群，user，topic

```yaml
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
      external:
        type: nodeport
        tls: true
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
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'
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
        operation: Describe
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

3. 根据 k8s-02 上的 Secret 和 Service 信息在 k8s-01 上部署 Secret 和 Service

部署 kafka 集群后每次生成的 Secret 和 Service 信息都不一样，所以不能直接复制粘贴下面的示例，需要根据实际信息修改。

```yaml
# destination-my-cluster-cluster-ca-cert.yaml
apiVersion: v1
data:
  ca.crt: LS0tLS1CRU
  ca.p12: MIIEVg==
  ca.password: Z2wxej
kind: Secret
metadata:
  name: destination-my-cluster-cluster-ca-cert
  namespace: kafka

---

# destination-my-user.yaml
apiVersion: v1
data:
  ca.crt: LS0tLS1C
  user.crt: LS0tLS1CRU==
  user.key: LS0tLS1C
  user.p12: MIIJOAIB
  user.password: U2lBN
kind: Secret
metadata:
  name: destination-my-user
  namespace: kafka

---

# destination-service.yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: destination-service
subsets:
  - addresses:
    - ip: 10.0.128.237
    ports:
    - port: 31818

```

4. 在 k8s-01 上部署 MirrorMaker

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
metadata:
  name: my-mirror-maker
spec:
  replicas: 3
  version: 2.5.0
  consumer:
    bootstrapServers: my-cluster-kafka-bootstrap:9093
    groupId: my-group
    numStreams: 2
    offsetCommitInterval: 120000
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
    config:
      max.poll.records: 100
      receive.buffer.bytes: 32768
  producer:
    bootstrapServers: destination-service:31818
    abortOnSendFailure: false
    tls:
      trustedCertificates:
      - secretName: destination-my-cluster-cluster-ca-cert
        certificate: ca.crt
    authentication:
      type: tls
      certificateAndKey:
        secretName: destination-my-user
        certificate: user.crt
        key: user.key
    config:
      compression.type: gzip
      batch.size: 8192
      ssl.endpoint.identification.algorithm: ''
  whitelist: my-topic
  resources:
    requests:
      cpu: "1"
      memory: 2Gi
    limits:
      cpu: "2"
      memory: 2Gi

```

5. 验证

在 k8s-01 上往 topic 写入数据，在 k8s-02 上的 topic 消费数据，验证数据是否在两个集群中传输。


[参考](https://github.com/strimzi/strimzi-kafka-operator/issues/3887)


