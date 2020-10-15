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

| 编号 | listeners          | authentication | authorization |
| ---- | ------------------ | -------------- | ------------- |
| 1    | plain              | scram-sha-512  | simple        |
| 2    | tls                | scram-sha-512  | simple        |
| 3    | tls                | tls            | simple        |
| 4    | external(nodeport) | scram-sha-512  | simple        |
| 5    | external(nodeport) | tls            | simple        |



## 组合1

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

## 组合2

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


## 组合3

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
[root@mw-init ssl]# kubectl -n kafka get secret
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      2d8h
my-cluster-clients-ca                    Opaque                                1      130m
my-cluster-clients-ca-cert               Opaque                                3      130m
my-cluster-cluster-ca                    Opaque                                1      130m
my-cluster-cluster-ca-cert               Opaque                                3      130m
my-cluster-cluster-operator-certs        Opaque                                4      130m
my-cluster-entity-operator-certs         Opaque                                4      128m
my-cluster-entity-operator-token-xs8v6   kubernetes.io/service-account-token   3      128m
my-cluster-kafka-brokers                 Opaque                                12     129m
my-cluster-kafka-token-9pphl             kubernetes.io/service-account-token   3      130m
my-cluster-zookeeper-nodes               Opaque                                12     130m
my-cluster-zookeeper-token-rsgj4         kubernetes.io/service-account-token   3      130m
my-user                                  Opaque                                5      128m
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      2d8h
[root@mw-init ssl]#

[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

kubectl -n kafka get secret my-user -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d > user.password

[root@mw-init ssl]# cat user.password
QrUWbsAYpU13

[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12
[root@mw-init ssl]#

[root@mw-init ssl]# keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令:
再次输入新口令:

[root@mw-init ssl]# keytool -importkeystore -srckeystore user.p12 -srcstoretype pkcs12 -destkeystore user-keystore.jks -deststoretype jks
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令:
再次输入新口令:
输入源密钥库口令:
已成功导入别名 my-user 的条目。

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/root/ssl/user-truststore.jks
ssl.truststore.password=QrUWbsAYpU13

ssl.keystore.location=/root/ssl/user-keystore.jks
ssl.keystore.password=QrUWbsAYpU13
ssl.key.password=QrUWbsAYpU13
EOF

$ kafka-console-producer.sh --bootstrap-server 10.108.84.26:9093 --topic my-topic --producer.config client-ssl.properties

$ kafka-console-consumer.sh --bootstrap-server 10.108.84.26:9093 --topic my-topic --producer.config client-ssl.properties



kubectl -n kafka run kafka-producer -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka-test:latest --rm=true --restart=Never -- export KAFKA_OPTS="-Djavax.net.debug=ssl"
./bin/kafka-console-producer.sh bin/kafka-console-producer.sh --bootstrap-server 10.108.84.26:9093 --topic my-topic --producer-property security.protocol=SSL --producer-property ssl.truststore.location=./bin/user-truststore.jks --producer-property ssl.truststore.password=QrUWbsAYpU13 --producer-property ssl.keystore.location=./bin/user-keystore.jks --producer-property ssl.keystore.password=QrUWbsAYpU13 --producer-property ssl.key.password=QrUWbsAYpU13



./kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --producer-property security.protocol=SSL --producer-property ssl.truststore.location=./user-truststore.jks --producer-property ssl.truststore.password=QrUWbsAYpU13 --producer-property ssl.keystore.location=./user-keystore.jks --producer-property ssl.keystore.password=QrUWbsAYpU13 --producer-property ssl.key.password=QrUWbsAYpU13

kubectl -n kafka run kafka-consumer -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka-test:latest --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server 10.108.84.26:9093 --topic my-topic --consumer-property security.protocol=SSL --consumer-property ssl.truststore.location=./bin/user-truststore.jks --consumer-property ssl.truststore.password=QrUWbsAYpU13 --consumer-property ssl.keystore.location=./bin/user-keystore.jks --consumer-property ssl.keystore.password=QrUWbsAYpU13 --consumer-property ssl.key.password=QrUWbsAYpU13

--producer-property

--consumer-property
--from-beginning

./kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer-property security.protocol=SSL --consumer-property ssl.truststore.location=./user-truststore.jks --consumer-property ssl.truststore.password=QrUWbsAYpU13 --consumer-property ssl.keystore.location=./user-keystore.jks --consumer-property ssl.keystore.password=QrUWbsAYpU13 --consumer-property ssl.key.password=QrUWbsAYpU13 --from-beginning

[kafka@kafka-producer bin]$
[kafka@kafka-producer bin]$ ./kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer-property security.protocol=SSL --consumer-property ssl.truststore.location=./user-truststore.jks --consumer-property ssl.truststore.password=QrUWbsAYpU13 --consumer-property ssl.keystore.location=./user-keystore.jks --consumer-property ssl.keystore.password=QrUWbsAYpU13 --consumer-property ssl.key.password=QrUWbsAYpU13 --from-beginning
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
[2020-10-15 14:51:00,701] ERROR Error processing message, terminating consumer process:  (kafka.tools.ConsoleConsumer$)
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: console-consumer-89814
Processed a total of 0 messages
[kafka@kafka-producer bin]$



keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA

openssl req -new -x509 -keyout ca-key -out ca-cert -days 365

keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert
keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert

keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days {validity} -CAcreateserial -passin pass:{ca-password}

```















https://github.com/strimzi/strimzi-kafka-operator/issues/3036











======================================================


1、创建 kafka 集群，plain + no authentication



```bash
[root@mw-init ~]# kubectl -n kafka get service
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-bootstrap    ClusterIP   10.96.192.250   <none>        9091/TCP,9092/TCP            26m
my-cluster-kafka-brokers      ClusterIP   None            <none>        9091/TCP,9092/TCP,9999/TCP   26m
my-cluster-zookeeper-client   ClusterIP   10.106.58.254   <none>        2181/TCP                     27m
my-cluster-zookeeper-nodes    ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP   27m
[root@mw-init ~]#


./kafka-topics.sh --create --bootstrap-server 10.96.192.250:9092 --topic test1 --partitions 6 --replication-factor 1

./kafka-topics.sh --create --bootstrap-server ${MY_CLUSTER_KAFKA_BOOTSTRAP_PORT_9092_TCP_ADDR}:${MY_CLUSTER_KAFKA_BOOTSTRAP_SERVICE_PORT_TCP_CLIENTS} --topic test2 --partitions 6 --replication-factor 1

[kafka@my-cluster-kafka-0 bin]$ cat /etc/resolv.conf
nameserver 10.96.0.10
search kafka.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
[kafka@my-cluster-kafka-0 bin]$

./kafka-topics.sh --create --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic test3 --partitions 6 --replication-factor 1

./kafka-topics.sh --create --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic test3 --partitions 6 --replication-factor 1

./kafka-topics.sh --create --bootstrap-server my-cluster-kafka-bootstrap.kafka:9092 --topic test4 --partitions 6 --replication-factor 1

./kafka-topics.sh --create --bootstrap-server my-cluster-kafka-bootstrap.kafka.svc:9092 --topic test5 --partitions 6 --replication-factor 1



kubectl -n kafka run kafka-producer -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server 10.96.192.250:9092 --topic test1

kubectl -n kafka run kafka-consumer -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic test1



```





1、创建 kafka 集群，plain + authentication



```bash

[root@mw-init ~]# kubectl -n kafka get service -o wide
No resources found in kafka namespace.
[root@mw-init ~]#
[root@mw-init ~]# kubectl -n kafka get secret -o wide
NAME                                   TYPE                                  DATA   AGE
default-token-r5ztg                    kubernetes.io/service-account-token   3      31h
strimzi-cluster-operator-token-8r97s   kubernetes.io/service-account-token   3      31h
[root@mw-init ~]#




kubectl -n kafka get secret
my-cluster-clients-ca                    Opaque                                1      2m57s
my-cluster-clients-ca-cert               Opaque                                3      2m57s
my-cluster-cluster-ca                    Opaque                                1      2m57s
my-cluster-cluster-ca-cert               Opaque                                3      2m57s
my-cluster-cluster-operator-certs        Opaque                                4      2m57s
my-cluster-entity-operator-certs         Opaque                                4      59s
my-cluster-entity-operator-token-28fld   kubernetes.io/service-account-token   3      59s
my-cluster-kafka-brokers                 Opaque                                12     85s
my-cluster-kafka-token-dshgf             kubernetes.io/service-account-token   3      86s
my-cluster-zookeeper-nodes               Opaque                                12     2m57s
my-cluster-zookeeper-token-dqgxj         kubernetes.io/service-account-token   3      2m57s



```
