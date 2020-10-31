# Strimzi Kafka Operator listeners

Strimzi Kafka Operator 目前支持三种监听方法，分别是：

1. Plain listener on port 9092 (without TLS encryption)
2. TLS listener on port 9093 (with TLS encryption)
3. External listener on port 9094 for access from outside of Kubernetes

对于每一种监听方法又分别有不同的认证方式：

1. Plain listener on port 9092 (without TLS encryption) 只支持 SCRAM-SHA authentication
2. TLS listener on port 9093 (with TLS encryption) 支持两种认证方式，分别是：
	- SCRAM-SHA authentication.
	- Mutual TLS authentication
3. External listener on port 9094 for access from outside of Kubernetes，External listener 有多种不同的类型，不同的类型又分别支持不同的认证方式，后续具体说明。

对于授权方式，两点说明如下：
1. 只有配置了认证方式授权方式才可能生效。
2. 目前只有一种授权方式，Simple authorization

所以，验证 Strimzi Kafka Operator 的三种监听过程的组合如下：

| 编号 | listeners                  | authentication | authorization |
| ---- | -------------------------- | -------------- | ------------- |
| 1    | plain                      | scram-sha-512  | simple        |
| 2    | tls                        | scram-sha-512  | simple        |
| 3    | tls                        | tls            | simple        |
| 4    | external(nodeport) - plain | scram-sha-512  | simple        |
| 5    | external(nodeport) - tls   | scram-sha-512  | simple        |
| 6    | external(nodeport) - tls   | tls            | simple        |



## 组合1

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
      plain:
        authentication:
          type: scram-sha-512
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
    type: scram-sha-512
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

验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get service
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-bootstrap    ClusterIP   10.109.109.51   <none>        9091/TCP,9092/TCP            4m35s
my-cluster-kafka-brokers      ClusterIP   None            <none>        9091/TCP,9092/TCP,9999/TCP   4m35s
my-cluster-zookeeper-client   ClusterIP   10.102.243.14   <none>        2181/TCP                     5m34s
my-cluster-zookeeper-nodes    ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP   5m34s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      3d3h
my-cluster-clients-ca                    Opaque                                1      5m41s
my-cluster-clients-ca-cert               Opaque                                3      5m41s
my-cluster-cluster-ca                    Opaque                                1      5m41s
my-cluster-cluster-ca-cert               Opaque                                3      5m41s
my-cluster-cluster-operator-certs        Opaque                                4      5m40s
my-cluster-entity-operator-certs         Opaque                                4      3m50s
my-cluster-entity-operator-token-m9ckq   kubernetes.io/service-account-token   3      3m50s
my-cluster-kafka-brokers                 Opaque                                12     4m41s
my-cluster-kafka-token-klp64             kubernetes.io/service-account-token   3      4m41s
my-cluster-zookeeper-nodes               Opaque                                12     5m40s
my-cluster-zookeeper-token-xz6cc         kubernetes.io/service-account-token   3      5m40s
my-user                                  Opaque                                1      3m35s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      3d3h

# 获取 my-user 用户密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
BR3OK7wIaWYM

# 创建生产者和消费者客户端连接配置文件，注意用户密码
$ cat << EOF > client.properties
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="BR3OK7wIaWYM";

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
EOF

# 创建 pod 作为生产者和消费者客户端
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

# 将相关文件复制到 pod 中
$ kubectl -n kafka cp client.properties kafka-test:/home/kafka/

# 进入 pod 运行生产者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>hello3
>hello4
>

# 进入 pod 运行消费者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4


```



## 组合2

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
          type: scram-sha-512
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
    type: scram-sha-512
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

验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get services
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-bootstrap    ClusterIP   10.103.136.140   <none>        9091/TCP,9093/TCP            4m23s
my-cluster-kafka-brokers      ClusterIP   None             <none>        9091/TCP,9093/TCP,9999/TCP   4m23s
my-cluster-zookeeper-client   ClusterIP   10.105.52.251    <none>        2181/TCP                     4m49s
my-cluster-zookeeper-nodes    ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   4m49s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      3d4h
my-cluster-clients-ca                    Opaque                                1      4m57s
my-cluster-clients-ca-cert               Opaque                                3      4m57s
my-cluster-cluster-ca                    Opaque                                1      4m57s
my-cluster-cluster-ca-cert               Opaque                                3      4m57s
my-cluster-cluster-operator-certs        Opaque                                4      4m57s
my-cluster-entity-operator-certs         Opaque                                4      74s
my-cluster-entity-operator-token-d7cg4   kubernetes.io/service-account-token   3      74s
my-cluster-kafka-brokers                 Opaque                                12     4m29s
my-cluster-kafka-token-rrb22             kubernetes.io/service-account-token   3      4m30s
my-cluster-zookeeper-nodes               Opaque                                12     4m56s
my-cluster-zookeeper-token-5fqg9         kubernetes.io/service-account-token   3      4m56s
my-user                                  Opaque                                1      70s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      3d4h

# 获取 CA 证书
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
dfpUDbSaXp7v

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令: CA 证书密码 dfpUDbSaXp7v
再次输入新口令: CA 证书密码 dfpUDbSaXp7v
是否信任此证书? [否]:  y
证书已添加到密钥库中

# 获取 my-user 用户密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
IQFS1dZGzY9E

# 创建生产者和消费者客户端连接配置文件，注意用户密码，CA 证书密码
$ cat << EOF > client.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=dfpUDbSaXp7v

sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="IQFS1dZGzY9E";

security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
EOF


# 创建 pod 作为生产者和消费者客户端
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

# 将相关文件复制到 pod 中
$ kubectl -n kafka cp client.properties kafka-test:/home/kafka/
$ kubectl -n kafka cp user-truststore.jks kafka-test:/home/kafka/

# 进入 pod 运行生产者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>hello3
>hello4
>

# 进入 pod 运行消费者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4

```




## 组合3

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

验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get services
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-bootstrap    ClusterIP   10.101.141.154   <none>        9091/TCP,9093/TCP            4m
my-cluster-kafka-brokers      ClusterIP   None             <none>        9091/TCP,9093/TCP,9999/TCP   4m
my-cluster-zookeeper-client   ClusterIP   10.105.220.161   <none>        2181/TCP                     4m52s
my-cluster-zookeeper-nodes    ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   4m52s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      6d23h
my-cluster-clients-ca                    Opaque                                1      4m55s
my-cluster-clients-ca-cert               Opaque                                3      4m55s
my-cluster-cluster-ca                    Opaque                                1      4m55s
my-cluster-cluster-ca-cert               Opaque                                3      4m55s
my-cluster-cluster-operator-certs        Opaque                                4      4m55s
my-cluster-entity-operator-certs         Opaque                                4      50s
my-cluster-entity-operator-token-42wj7   kubernetes.io/service-account-token   3      50s
my-cluster-kafka-brokers                 Opaque                                12     4m2s
my-cluster-kafka-token-lxff5             kubernetes.io/service-account-token   3      4m3s
my-cluster-zookeeper-nodes               Opaque                                12     4m54s
my-cluster-zookeeper-token-c2cxt         kubernetes.io/service-account-token   3      4m55s
my-user                                  Opaque                                5      46s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      6d23h

# 获取 CA 证书
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
EiwtHlsw34RT

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令: CA 证书密码 EiwtHlsw34RT
再次输入新口令: CA 证书密码 EiwtHlsw34RT
是否信任此证书? [否]:  y
证书已添加到密钥库中


# 获取用户证书
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

# 获取用户证书密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
iq4b1jjmaFUy

# 将用户证书导入 user-keystore.jks 文件中
$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令: 用户证书密码 iq4b1jjmaFUy
再次输入新口令: 用户证书密码 iq4b1jjmaFUy
输入源密钥库口令: 用户证书密码 iq4b1jjmaFUy
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消


# 创建生产者和消费者客户端连接配置文件，注意用户证书密码，CA 证书密码
cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=EiwtHlsw34RT

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=iq4b1jjmaFUy
ssl.key.password=iq4b1jjmaFUy
EOF


# 创建 pod 作为生产者和消费者客户端
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

# 将相关文件复制到 pod 中
$ kubectl -n kafka cp client-ssl.properties kafka-test:/home/kafka/
$ kubectl -n kafka cp user-keystore.jks kafka-test:/home/kafka/
$ kubectl -n kafka cp user-truststore.jks kafka-test:/home/kafka/


# 进入 pod 运行生产者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>hello3
>hello4
>

# 进入 pod 运行消费者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4

```


参考：

* https://github.com/strimzi/strimzi-kafka-operator/issues/3036



## 组合四

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
      external:
        type: nodeport
        tls: false
        authentication:
          type: scram-sha-512
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
    type: scram-sha-512
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



验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get service
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.106.253.254   <none>        9094:32606/TCP               4m8s
my-cluster-kafka-1                    NodePort    10.100.84.94     <none>        9094:30086/TCP               4m8s
my-cluster-kafka-2                    NodePort    10.106.135.189   <none>        9094:32275/TCP               4m8s
my-cluster-kafka-bootstrap            ClusterIP   10.97.216.52     <none>        9091/TCP                     4m8s
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            4m8s
my-cluster-kafka-external-bootstrap   NodePort    10.100.72.236    <none>        9094:31189/TCP               4m8s
my-cluster-zookeeper-client           ClusterIP   10.110.162.153   <none>        2181/TCP                     4m36s
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   4m36s


# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-6g2dg                      kubernetes.io/service-account-token   3      4h37m
my-cluster-clients-ca                    Opaque                                1      5m17s
my-cluster-clients-ca-cert               Opaque                                3      5m17s
my-cluster-cluster-ca                    Opaque                                1      5m17s
my-cluster-cluster-ca-cert               Opaque                                3      5m17s
my-cluster-cluster-operator-certs        Opaque                                4      5m17s
my-cluster-entity-operator-certs         Opaque                                4      4m19s
my-cluster-entity-operator-token-nhkbm   kubernetes.io/service-account-token   3      4m19s
my-cluster-kafka-brokers                 Opaque                                12     4m49s
my-cluster-kafka-token-vbsm2             kubernetes.io/service-account-token   3      4m49s
my-cluster-zookeeper-nodes               Opaque                                12     5m17s
my-cluster-zookeeper-token-h8rkv         kubernetes.io/service-account-token   3      5m17s
my-user                                  Opaque                                1      3m10s
strimzi-cluster-operator-token-mf7xq     kubernetes.io/service-account-token   3      4h33m


# 获取 my-user 用户密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
p1ZZpYSfmRiI


# 创建生产者和消费者客户端连接配置文件，注意用户密码
$ cat << EOF > client.properties
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="p1ZZpYSfmRiI";

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
EOF

# 生产者
$ kafka-console-producer.sh --bootstrap-server 10.0.128.202:31189 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>

# 消费者
$ kafka-console-consumer.sh --bootstrap-server 10.0.128.202:31189 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2


```



## 组合五

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
      external:
        type: nodeport
        tls: true
        authentication:
          type: scram-sha-512
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
    type: scram-sha-512
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



验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get service
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.102.78.56     <none>        9094:31857/TCP               59s
my-cluster-kafka-1                    NodePort    10.102.7.189     <none>        9094:30687/TCP               59s
my-cluster-kafka-2                    NodePort    10.110.191.76    <none>        9094:32256/TCP               59s
my-cluster-kafka-bootstrap            ClusterIP   10.109.250.169   <none>        9091/TCP                     59s
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            59s
my-cluster-kafka-external-bootstrap   NodePort    10.97.183.174    <none>        9094:30784/TCP               59s
my-cluster-zookeeper-client           ClusterIP   10.105.56.72     <none>        2181/TCP                     85s
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   85s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-6g2dg                      kubernetes.io/service-account-token   3      4h49m
my-cluster-clients-ca                    Opaque                                1      90s
my-cluster-clients-ca-cert               Opaque                                3      90s
my-cluster-cluster-ca                    Opaque                                1      90s
my-cluster-cluster-ca-cert               Opaque                                3      90s
my-cluster-cluster-operator-certs        Opaque                                4      90s
my-cluster-entity-operator-certs         Opaque                                4      35s
my-cluster-entity-operator-token-4cc4p   kubernetes.io/service-account-token   3      35s
my-cluster-kafka-brokers                 Opaque                                12     63s
my-cluster-kafka-token-ptml7             kubernetes.io/service-account-token   3      64s
my-cluster-zookeeper-nodes               Opaque                                12     89s
my-cluster-zookeeper-token-4p94q         kubernetes.io/service-account-token   3      90s
my-user                                  Opaque                                1      32s
strimzi-cluster-operator-token-mf7xq     kubernetes.io/service-account-token   3      4h45m


# 获取 CA 证书
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
kgOg9JkSg7Qi

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令: CA 证书密码 kgOg9JkSg7Qi
再次输入新口令: CA 证书密码 kgOg9JkSg7Qi
是否信任此证书? [否]:  y
证书已添加到密钥库中

# 获取 my-user 用户密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
wasXcyTWsuOr


# 创建生产者和消费者客户端连接配置文件，注意用户密码，CA 证书密码
$ cat << EOF > client.properties
security.protocol=SSL
ssl.truststore.location=/root/ssl/user-truststore.jks
ssl.truststore.password=kgOg9JkSg7Qi
ssl.endpoint.identification.algorithm=

sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="wasXcyTWsuOr";

security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
EOF

# 生产者
$ kafka-console-producer.sh --bootstrap-server 10.0.128.202:30784 --topic my-topic --producer.config /root/ssl/client.properties
>hello1
>hello2
>hello3
>hello4
>

# 消费者
$ kafka-console-consumer.sh --bootstrap-server 10.0.128.202:30784 --topic my-topic --consumer.config /root/ssl/client.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4

```



参考：

* https://github.com/strimzi/strimzi-kafka-operator/issues/3829

* https://github.com/strimzi/strimzi-kafka-operator/issues/1486



## 组合六



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

验证结果：

```bash
# 检查 service 是否创建成功
$ kubectl -n kafka get services
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.102.246.58    <none>        9094:31312/TCP               41s
my-cluster-kafka-1                    NodePort    10.111.252.191   <none>        9094:31991/TCP               41s
my-cluster-kafka-2                    NodePort    10.102.75.199    <none>        9094:30844/TCP               41s
my-cluster-kafka-bootstrap            ClusterIP   10.106.104.107   <none>        9091/TCP                     41s
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            41s
my-cluster-kafka-external-bootstrap   NodePort    10.110.237.137   <none>        9094:30762/TCP               41s
my-cluster-zookeeper-client           ClusterIP   10.109.245.138   <none>        2181/TCP                     66s
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   66s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-6g2dg                      kubernetes.io/service-account-token   3      5h8m
my-cluster-clients-ca                    Opaque                                1      71s
my-cluster-clients-ca-cert               Opaque                                3      71s
my-cluster-cluster-ca                    Opaque                                1      71s
my-cluster-cluster-ca-cert               Opaque                                3      71s
my-cluster-cluster-operator-certs        Opaque                                4      71s
my-cluster-entity-operator-certs         Opaque                                4      17s
my-cluster-entity-operator-token-jm4ch   kubernetes.io/service-account-token   3      18s
my-cluster-kafka-brokers                 Opaque                                12     46s
my-cluster-kafka-token-vbv7s             kubernetes.io/service-account-token   3      46s
my-cluster-zookeeper-nodes               Opaque                                12     71s
my-cluster-zookeeper-token-t67ng         kubernetes.io/service-account-token   3      71s
my-user                                  Opaque                                5      14s
strimzi-cluster-operator-token-mf7xq     kubernetes.io/service-account-token   3      5h4m




# 获取 CA 证书
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
V27UGXKJ1c2a

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令: CA 证书密码 V27UGXKJ1c2a
再次输入新口令: CA 证书密码 V27UGXKJ1c2a
是否信任此证书? [否]:  y
证书已添加到密钥库中


# 获取用户证书
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

# 获取用户证书密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
hU6HgL78Bw6x

# 将用户证书导入 user-keystore.jks 文件中
$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令: 用户证书密码 hU6HgL78Bw6x
再次输入新口令: 用户证书密码 hU6HgL78Bw6x
输入源密钥库口令: 用户证书密码 hU6HgL78Bw6x
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消

# 创建生产者和消费者客户端连接配置文件，注意用户密码，CA 证书密码
$ cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/root/ssl/user-truststore.jks
ssl.truststore.password=V27UGXKJ1c2a
ssl.endpoint.identification.algorithm=

ssl.keystore.location=/root/ssl/user-keystore.jks
ssl.keystore.password=hU6HgL78Bw6x
ssl.key.password=hU6HgL78Bw6x
EOF

# 生产者
$ kafka-console-producer.sh --bootstrap-server 10.0.128.202:30762 --topic my-topic --producer.config ./client-ssl.properties
>hello1
>hello2
>hello3
>hello4
>

# 消费者
$ kafka-console-consumer.sh --bootstrap-server 10.0.128.202:30762 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4

```





