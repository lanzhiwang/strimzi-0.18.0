# 管理 kafka

## 集群管理

### 启动 kafka

```bash
# 后台启动
$ kafka-server-start.sh [-daemon] server.properties [--override property=value]*

$ nohup kafka-server-start.sh server.properties [--override property=value]* &

```

### 关闭 kafka

```bash
# 前台启动
$ kafka-server-start.sh server.properties [--override property=value]*
$ Ctrl + C


# 后台启动
$ kafka-server-start.sh [-daemon] server.properties [--override property=value]*

$ nohup kafka-server-start.sh server.properties [--override property=value]* &

$ kafka-server-stop.sh
$ kill -s $SIGNAL $PIDS

```

### 设置 JMX 端口

```bash
$ JMX_PORT=9997 kafka-server-start.sh server.properties [--override property=value]*

$ export JMX_PORT=9997
$ kafka-server-start.sh [-daemon] server.properties [--override property=value]*

```

### 新增 broker

```
broker.id
zookeeper.connect

```

### 升级 broker

## Topic 管理

利用 kafka-configs.sh 查找所有的 client 和 user 的方法







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
        tls: false
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


[root@mw-init ~]# kafka-topics.sh --bootstrap-server 10.0.128.237:30385 --list
my-topic
[root@mw-init ~]#


# 生产者 指定 client.id=client-producer
[root@mw-init ~]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:30385 --topic my-topic --producer-property client.id=client-producer
>hello1
>hello2
>hello3
>hello4
>hello5
>

# 消费者 指定 client.id=client-consumer
[root@mw-init ~]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:30385 --topic my-topic --consumer-property client.id=client-consumer --from-beginning --group my-group
hello1
hello3
hello5
hello2
hello4

# 生产者和消费者都处于运行状态，查看生产者和消费者的配置信息
kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-producer --describe

kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-consumer --describe

# 生产者和消费者都处于运行状态，限速设置
$ kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-producer --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=1024'

$ kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-consumer --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=1024'

# 生产者和消费者都处于运行状态，查看生产者和消费者的配置信息，限速配置成功
[root@mw-init ~]# kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-producer --describe
Warning: --zookeeper is deprecated and will be removed in a future version of Kafka.
Use --bootstrap-server instead to specify a broker to connect to.
Configs for client-id 'client-producer' are producer_byte_rate=1024,consumer_byte_rate=1024
[root@mw-init ~]#
[root@mw-init ~]#
[root@mw-init ~]#
[root@mw-init ~]# kafka-configs.sh --zookeeper 10.0.128.237:31818 --entity-type clients --entity-name client-consumer --describe
Warning: --zookeeper is deprecated and will be removed in a future version of Kafka.
Use --bootstrap-server instead to specify a broker to connect to.
Configs for client-id 'client-consumer' are producer_byte_rate=1024,consumer_byte_rate=1024
[root@mw-init ~]#

10.99.57.70:2181
cpaas-zookeeper:2181
./kafka-topics.sh --zookeeper 10.99.57.70:2181 --create --topic test --partitions 2 --replication-factor 2


10.101.98.52:9092
cpaas-kafka:9092
./kafka-topics.sh --bootstrap-server cpaas-kafka:9092 --create --topic test --partitions 2 --replication-factor 2



10.99.57.70:2181

10.101.98.52:9092

./kafka-acls.sh --bootstrap-server cpaas-kafka:9092 --principal admin



./bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test --partitions 2 --replication-factor 2


# kafka 2.2.1 版本
$ ./bin/kafka-server-start.sh --version
2.2.1 (Commit:55783d3133a5a49a)

# 创建 topic 
$ ./bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test --partitions 2 --replication-factor 1
# 查看 topic 是否创建成功
$ ./bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
test

# 生产者
$ ./bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test --producer-property client.id=client-producer
>hello1
>hello2
>hello3
>

# 消费者
$ ./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --consumer-property client.id=client-consumer --from-beginning --group my-group
hello2
hello1
hello3

# 配置限速之前
$ ./bin/kafka-configs.sh --zookeeper localhost:2181 --entity-name client-producer --entity-type clients --describe
Configs for client-id 'client-producer' are

# 配置限速
$ ./bin/kafka-configs.sh --zookeeper localhost:2181 --entity-name client-producer --entity-type clients --alter --add-config 'producer_byte_rate=1024, consumer_byte_rate=1024'
Completed Updating config for entity: client-id 'client-producer'.

# 配置限速之后
$ ./bin/kafka-configs.sh --zookeeper localhost:2181 --entity-name client-producer --entity-type clients --describe
Configs for client-id 'client-producer' are producer_byte_rate=1024,consumer_byte_rate=1024






```







1、apollo 是什么？没有看到关于 apollo 的说明

2、日志收集 Agent(nevermore) 部署在包含 Global 集群和业务集群的主机中，负责收集当前主机相关日志，并且发送给 Global 集群的 morgans。 morgans 将收到的日志存储到 kafka 进行缓存。lanaya 则负责从 kafka 中读取日志，然后存储到 ElasticSearch。

morgans 和 lanaya 连接 kafka 配置了哪些配置选项？

3、lanaya、kafka 和 morgans 以 Deployment 的形式部署在 Global 集群。是否支持部署多套，也就是在一段时间内，存在原始的 kafka 集群，也存在 使用 operator 部署的 kafka集群（operator-kafka），切换是否方便

4、ACP 2.5 之前存在的 tiny 组件是否还需要支持？

5、对于生产环境（包括部署到客户那边的和公司内部每个团队使用开发和测试环境）对性能的要求如何，大致每天的数据量或者常见的吞吐量和延迟指标

5、如何监控日志系统整个功能是否是正常的，也就是替换后怎么确定系统是否是正常的？







```bash

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic


bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:* --allow-host * --deny-principal User:BadBob --deny-host 198.51.100.3 --operation Read --topic Test-topic

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Peter --allow-host 198.51.200.1 --producer --topic *

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Jane --producer --topic Test- --resource-pattern-type prefixed


bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic 

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Jane --producer --topic Test- --resource-pattern-type Prefixed



bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic *

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic --resource-pattern-type match

bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1 


bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --producer --topic Test-topic

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --list --topic Test-topic


.kafka.svc.cluster.local


alauda-audit-topic
alauda-event-topic
alauda-log-topic


- name: KAFKA_EVENT_GROUPNAME
          value: alauda_event
        - name: KAFKA_EVENT_TOPICNAME
          value: alauda-event-topic
          
        - name: KAFKA_AUDIT_GROUPNAME
          value: alauda_audit
        - name: KAFKA_AUDIT_TOPICNAME
          value: alauda-audit-topic
          
        - name: KAFKA_TOPIC_NAME
          value: alauda-log-topic
        - name: KAFKA_GROUPNAME
          value: alauda_log
          
          
```





















