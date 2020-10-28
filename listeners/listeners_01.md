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
$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
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
NAME                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.104.210.5    <none>        9094:31913/TCP               2m54s
my-cluster-kafka-1                    NodePort    10.97.203.106   <none>        9094:31721/TCP               2m54s
my-cluster-kafka-2                    NodePort    10.110.27.217   <none>        9094:30672/TCP               2m53s
my-cluster-kafka-bootstrap            ClusterIP   10.97.82.137    <none>        9091/TCP                     2m54s
my-cluster-kafka-brokers              ClusterIP   None            <none>        9091/TCP,9999/TCP            2m54s
my-cluster-kafka-external-bootstrap   NodePort    10.100.83.54    <none>        9094:31122/TCP               2m54s
my-cluster-zookeeper-client           ClusterIP   10.110.12.204   <none>        2181/TCP                     4m42s
my-cluster-zookeeper-nodes            ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP   4m42s

# 检查 secret 是否创建成功
$ kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      3d7h
my-cluster-clients-ca                    Opaque                                1      5m26s
my-cluster-clients-ca-cert               Opaque                                3      5m26s
my-cluster-cluster-ca                    Opaque                                1      5m26s
my-cluster-cluster-ca-cert               Opaque                                3      5m26s
my-cluster-cluster-operator-certs        Opaque                                4      5m26s
my-cluster-entity-operator-certs         Opaque                                4      3m2s
my-cluster-entity-operator-token-hkvb6   kubernetes.io/service-account-token   3      3m2s
my-cluster-kafka-brokers                 Opaque                                12     3m37s
my-cluster-kafka-token-9ts6z             kubernetes.io/service-account-token   3      3m38s
my-cluster-zookeeper-nodes               Opaque                                12     5m26s
my-cluster-zookeeper-token-rg6hn         kubernetes.io/service-account-token   3      5m26s
my-user                                  Opaque                                1      2m54s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      3d7h








[root@mw-init ~]# kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
XkSJhKDdFxMx
[root@mw-init ~]#



cat << EOF > client.properties
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="XkSJhKDdFxMx";

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
EOF


[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.129.171:31122 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>

[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.129.171:31122 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2


```





错误：

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  creationTimestamp: '2020-10-28T06:44:02Z'
  generation: 1
  name: my-cluster
  namespace: kafka
  resourceVersion: '99607585'
  selfLink: /apis/kafka.strimzi.io/v1beta1/namespaces/kafka/kafkas/my-cluster
  uid: 0c83ca58-bfd5-4442-830d-7e06905fc6bc
spec:
  entityOperator:
    topicOperator: {}
    userOperator: {}
  kafka:
    authorization:
      type: simple
    config:
      log.message.format.version: '2.5'
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
    jmxOptions: {}
    listeners:
      external:
        authentication:
          type: scram-sha-512
        tls: false
        type: nodeport
    replicas: 3
    storage:
      type: ephemeral
    version: 2.5.0
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
status:
  conditions:
    - lastTransitionTime: '2020-10-28T06:44:36+0000'
      message: 'Failure executing: POST at: https://10.96.0.1/apis/rbac.authorization.k8s.io/v1/clusterrolebindings. Message: clusterroles.rbac.authorization.k8s.io "strimzi-kafka-broker" not found. Received status: Status(apiVersion=v1, code=404, details=StatusDetails(causes=[], group=rbac.authorization.k8s.io, kind=clusterroles, name=strimzi-kafka-broker, retryAfterSeconds=null, uid=null, additionalProperties={}), kind=Status, message=clusterroles.rbac.authorization.k8s.io "strimzi-kafka-broker" not found, metadata=ListMeta(_continue=null, remainingItemCount=null, resourceVersion=null, selfLink=null, additionalProperties={}), reason=NotFound, status=Failure, additionalProperties={}).'
      reason: KubernetesClientException
      status: 'True'
      type: NotReady
  observedGeneration: 1

```













## 组合五



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

```



验证结果：

```bash
[root@mw-init ssl]# kubectl get node
NAME           STATUS   ROLES    AGE   VERSION
10.0.128.237   Ready    master   52d   v1.16.9
10.0.128.64    Ready    master   52d   v1.16.9
10.0.129.171   Ready    master   52d   v1.16.9
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl get node 10.0.128.237 -o=jsonpath='{range .status.addresses[*]}{.type}{"\t"}{.address}{"\n"}'
InternalIP	10.0.128.237
Hostname	10.0.128.237

[root@mw-init ssl]# kubectl -n kafka get service
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.104.194.202   <none>        9094:30007/TCP               3m19s
my-cluster-kafka-1                    NodePort    10.100.106.32    <none>        9094:32546/TCP               3m19s
my-cluster-kafka-2                    NodePort    10.103.117.152   <none>        9094:32472/TCP               3m19s
my-cluster-kafka-bootstrap            ClusterIP   10.104.228.114   <none>        9091/TCP                     3m19s
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            3m19s
my-cluster-kafka-external-bootstrap   NodePort    10.111.81.162    <none>        9094:30346/TCP               3m19s
my-cluster-zookeeper-client           ClusterIP   10.111.38.244    <none>        2181/TCP                     5m8s
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   5m8s
[root@mw-init ssl]#

[root@mw-init ssl]# kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      3d11h
my-cluster-clients-ca                    Opaque                                1      5m50s
my-cluster-clients-ca-cert               Opaque                                3      5m50s
my-cluster-cluster-ca                    Opaque                                1      5m50s
my-cluster-cluster-ca-cert               Opaque                                3      5m50s
my-cluster-cluster-operator-certs        Opaque                                4      5m50s
my-cluster-entity-operator-certs         Opaque                                4      3m17s
my-cluster-entity-operator-token-mvkw6   kubernetes.io/service-account-token   3      3m17s
my-cluster-kafka-brokers                 Opaque                                12     3m59s
my-cluster-kafka-token-2fp79             kubernetes.io/service-account-token   3      4m
my-cluster-zookeeper-nodes               Opaque                                12     5m49s
my-cluster-zookeeper-token-jdhkn         kubernetes.io/service-account-token   3      5m49s
my-user                                  Opaque                                1      3m10s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      3d11h
[root@mw-init ssl]#


[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
FHDIaDaVdO6h
[root@mw-init ssl]#
[root@mw-init ssl]# keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令:
再次输入新口令:
是否信任此证书? [否]:  y
证书已添加到密钥库中
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.password}' | base64 -d
O4FmeeOQvbut
[root@mw-init ssl]#

cat << EOF > client.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=FHDIaDaVdO6h
ssl.endpoint.identification.algorithm=

sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user" \
    password="O4FmeeOQvbut";

security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
EOF


export KAFKA_OPTS="-Djavax.net.debug=ssl"

[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:30346 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>hello3
>

[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:30346 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2
hello3



```





参考：

* https://github.com/strimzi/strimzi-kafka-operator/issues/3829

* https://github.com/strimzi/strimzi-kafka-operator/issues/1486

















## 组合六



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






```



验证结果：



```bash
[root@mw-init ~]# kubectl get node
NAME           STATUS   ROLES    AGE   VERSION
10.0.128.237   Ready    master   52d   v1.16.9
10.0.128.64    Ready    master   52d   v1.16.9
10.0.129.171   Ready    master   52d   v1.16.9
[root@mw-init ~]#
[root@mw-init ~]# kubectl get node 10.0.128.237 -o=jsonpath='{range .status.addresses[*]}{.type}{"\t"}{.address}{"\n"}'
InternalIP	10.0.128.237
Hostname	10.0.128.237
[root@mw-init ~]#


[root@mw-init ~]# kubectl -n kafka get services
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.104.206.85    <none>        9094:31885/TCP               4m36s
my-cluster-kafka-1                    NodePort    10.99.116.28     <none>        9094:30574/TCP               4m36s
my-cluster-kafka-2                    NodePort    10.98.51.57      <none>        9094:32479/TCP               4m36s
my-cluster-kafka-bootstrap            ClusterIP   10.108.222.144   <none>        9091/TCP                     4m36s
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            4m36s
my-cluster-kafka-external-bootstrap   NodePort    10.107.161.253   <none>        9094:30532/TCP               4m36s
my-cluster-zookeeper-client           ClusterIP   10.103.1.62      <none>        2181/TCP                     5m3s
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   5m3s
[root@mw-init ~]#
[root@mw-init ~]# kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      4d4h
my-cluster-clients-ca                    Opaque                                1      5m12s
my-cluster-clients-ca-cert               Opaque                                3      5m12s
my-cluster-cluster-ca                    Opaque                                1      5m12s
my-cluster-cluster-ca-cert               Opaque                                3      5m12s
my-cluster-cluster-operator-certs        Opaque                                4      5m12s
my-cluster-entity-operator-certs         Opaque                                4      4m15s
my-cluster-entity-operator-token-v8mwn   kubernetes.io/service-account-token   3      4m15s
my-cluster-kafka-brokers                 Opaque                                12     4m44s
my-cluster-kafka-token-swt4k             kubernetes.io/service-account-token   3      4m45s
my-cluster-zookeeper-nodes               Opaque                                12     5m11s
my-cluster-zookeeper-token-bjs5z         kubernetes.io/service-account-token   3      5m12s
my-user                                  Opaque                                5      4m10s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      4d4h
[root@mw-init ~]#
[root@mw-init ~]#


[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
qbH1fqPpWooH
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
QLmKVNmY9XB9
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令:
再次输入新口令:
是否信任此证书? [否]:  y
证书已添加到密钥库中
[root@mw-init ssl]#

[root@mw-init ssl]# keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令:
再次输入新口令:
输入源密钥库口令:
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消
[root@mw-init ssl]#
[root@mw-init ssl]#

[root@mw-init ssl]# ll
总用量 16
-rw-r--r-- 1 root root 1164 10月 17 15:00 ca.crt
-rw-r--r-- 1 root root 2056 10月 17 15:02 user-keystore.jks
-rw-r--r-- 1 root root 2364 10月 17 15:01 user.p12
-rw-r--r-- 1 root root  880 10月 17 15:02 user-truststore.jks
[root@mw-init ssl]#

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=qbH1fqPpWooH
ssl.endpoint.identification.algorithm=

ssl.keystore.location=./user-keystore.jks
ssl.keystore.password=QLmKVNmY9XB9
ssl.key.password=QLmKVNmY9XB9
EOF


[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:30532 --topic my-topic --producer.config ./client-ssl.properties
>hello1
>hello2
>hello3
>


[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:30532 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group

hello1
hello2
hello3



```





