## apollo

https://gitlab-ce.alauda.cn/ait/apollo

https://gitlab-ce.alauda.cn/ait/chart-alauda-base

## morgans

https://gitlab-ce.alauda.cn/ait/morgans

## lanaya

https://gitlab-ce.alauda.cn/ait/lanaya

https://gitlab-ce.alauda.cn/ait/chart-alauda-aiops

## kafka/zookeeper

https://gitlab-ce.alauda.cn/ait/chart-kafka-zookeeper


```bash
删除 kafka 和 zookeeper elasticsearch
[root@mw-m1 prometheus]# kubectl edit prdb base  -n default
productbase.product.alauda.io/base edited
[root@mw-m1 prometheus]#

删除数据目录


KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="pvythagxxb"
    password="LQyHJcXReiEkjHT"
    user_pvythagxxb="LQyHJcXReiEkjHT";
};

KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="pvythagxxb"
    password="LQyHJcXReiEkjHT"
    user_pvythagxxb="LQyHJcXReiEkjHT";
};


sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="pvythagxxb" password="LQyHJcXReiEkjHT";
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN



kafka-topics.sh --bootstrap-server 10.0.129.171:9092 --list --command-config ./client.properties

kafka-topics.sh --bootstrap-server localhost:9092 --create --topic first-topic --partitions 2 --replication-factor 3
kafka-producer-perf-test.sh --num-records 500 --topic first-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=localhost:9092

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic --from-beginning --group first-consumer

kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group first-consumer



[root@mw-region-s2 data]# echo 1 >  zookeeper-1/myid
[root@mw-region-s2 data]# echo 2 >  zookeeper-2/myid
[root@mw-region-s2 data]# echo 3 >  zookeeper-3/myid
[root@mw-region-s2 data]#

[root@mw-region-s2 data]# rm -rf broker-0/meta.properties
[root@mw-region-s2 data]# rm -rf broker-1/meta.properties
[root@mw-region-s2 data]# rm -rf broker-2/meta.properties
[root@mw-region-s2 data]#


[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 1] ls /
[admin, brokers, cluster, config, consumers, controller_epoch, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]


[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 25] ls /config/users
[ANONYMOUS, CN%3Dlocalhost%2COU%3Dalauda%2CO%3Dalauda%2CL%3Dalauda%2CST%3Dbeijing%2CC%3Dbeijing, CN%3Dlocalhost%2COU%3Dalauda%2CO%3Dalauda%2CL%3Dbeijing%2CST%3Dbeijing%2CC%3DCN, broker-admin]
[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 26]


[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 2]
[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 2] ls /brokers/ids
[]
[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 3] getAcl /brokers/ids
'world,'anyone
: cdrwa
[zk: localhost:2181,localhost:2182,localhost:2183(CONNECTED) 4]



[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]# ./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9091,localhost:8091,localhost:7091 --list
__consumer_offsets
[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]#

[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]# ./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9091,localhost:8091,localhost:7091 --list
__consumer_offsets
first-topic
[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]#


[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]#
[root@mw-region-s2 kafka2.5.0_and_zookeeper3.5.9]# ./kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9091,localhost:8091,localhost:7091 --topic first-topic --from-beginning --group first-consumer
^CProcessed a total of 500 messages













[root@mw-m1 ~]# kafka-topics.sh --bootstrap-server localhost:9092 --list
ALAUDA_AUDIT_TOPIC
ALAUDA_EVENT_TOPIC
ALAUDA_LOG_TOPIC
__consumer_offsets
[root@mw-m1 ~]#
[root@mw-m1 ~]#

kafka-topics.sh --bootstrap-server localhost:9092 --create --topic first-topic --partitions 2 --replication-factor 3


[root@mw-m1 ~]# kafka-topics.sh --bootstrap-server localhost:9092 --create --topic first-topic --partitions 2 --replication-factor 3
Created topic first-topic.
[root@mw-m1 ~]# kafka-topics.sh --bootstrap-server localhost:9092 --list
ALAUDA_AUDIT_TOPIC
ALAUDA_EVENT_TOPIC
ALAUDA_LOG_TOPIC
__consumer_offsets
first-topic
[root@mw-m1 ~]#
[root@mw-m1 ~]#


kafka-producer-perf-test.sh --num-records 500 --topic first-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=localhost:9092






[root@mw-m1 prometheus]# kubectl -n cpaas-system get pods -o wide | grep kafka
cpaas-kafka-8587979cb8-4qlzf                           1/1     Running             0          7h53m   10.0.128.237   10.0.128.237   <none>           <none>
cpaas-kafka-8587979cb8-bl72w                           1/1     Running             0          7h53m   10.0.129.171   10.0.129.171   <none>           <none>
cpaas-kafka-8587979cb8-dpxp8                           1/1     Running             0          7h53m   10.0.128.64    10.0.128.64    <none>           <none>
[root@mw-m1 prometheus]#
[root@mw-m1 prometheus]#
[root@mw-m1 prometheus]# kubectl -n cpaas-system get pods -o wide | grep zookeeper
cpaas-zookeeper-649ff6fcdb-d5t5c                       0/1     Terminating         0          7h53m   10.0.129.171   10.0.129.171   <none>           <none>
cpaas-zookeeper-649ff6fcdb-qtvfh                       0/1     Terminating         0          7h53m   10.0.128.64    10.0.128.64    <none>           <none>
cpaas-zookeeper-649ff6fcdb-z7fsq                       0/1     Terminating         0          7h53m   10.0.128.237   10.0.128.237   <none>           <none>
[root@mw-m1 prometheus]#




$ helm install alauda-base ./ --debug --dry-run
$ helm template .

kubectl -n cpaas-system get CatalogSource platform -o yaml
harbor-b.alauda.cn/3rdparty/operators-index:v3.0.1-460.gf7e94b9

$ tree -a /kafka-zookeeper-data/
/kafka-zookeeper-data/
├── kafka-0
│   └── kafka-log0
│       ├── cleaner-offset-checkpoint
│       ├── __consumer_offsets-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-10
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-11
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-12
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000008.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-13
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-14
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-15
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-16
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-17
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-18
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-19
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-20
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-21
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-22
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-23
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-24
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-25
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-26
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-27
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-28
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-29
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-3
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-30
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-31
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-32
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-33
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-34
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-35
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-36
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-37
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-38
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-39
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-4
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-40
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-41
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-42
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-43
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-44
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-45
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-46
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-47
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-48
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-49
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-5
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-6
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-7
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-8
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-9
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── .lock
│       ├── log-start-offset-checkpoint
│       ├── meta.properties
│       ├── my-topic-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000176.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000164.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000160.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── recovery-point-offset-checkpoint
│       └── replication-offset-checkpoint
├── kafka-1
│   └── kafka-log1
│       ├── cleaner-offset-checkpoint
│       ├── __consumer_offsets-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-10
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-11
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-12
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000008.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-13
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-14
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-15
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-16
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-17
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-18
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-19
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-20
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-21
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-22
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-23
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-24
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-25
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-26
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-27
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-28
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-29
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-3
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-30
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-31
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-32
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-33
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-34
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-35
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-36
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-37
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-38
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-39
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-4
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-40
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-41
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-42
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-43
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-44
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-45
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-46
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-47
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-48
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-49
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-5
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-6
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-7
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-8
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-9
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── .lock
│       ├── log-start-offset-checkpoint
│       ├── meta.properties
│       ├── my-topic-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000176.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000164.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000160.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── recovery-point-offset-checkpoint
│       └── replication-offset-checkpoint
├── kafka-2
│   └── kafka-log2
│       ├── cleaner-offset-checkpoint
│       ├── __consumer_offsets-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-10
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-11
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-12
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000008.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-13
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-14
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-15
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-16
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-17
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-18
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-19
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-20
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-21
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-22
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-23
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-24
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-25
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-26
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-27
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-28
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-29
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-3
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-30
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-31
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-32
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-33
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-34
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-35
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-36
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-37
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-38
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-39
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-4
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-40
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-41
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-42
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-43
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-44
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-45
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-46
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-47
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-48
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-49
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-5
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-6
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-7
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-8
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── __consumer_offsets-9
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   └── leader-epoch-checkpoint
│       ├── .lock
│       ├── log-start-offset-checkpoint
│       ├── meta.properties
│       ├── my-topic-0
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000176.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-1
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000164.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── my-topic-2
│       │   ├── 00000000000000000000.index
│       │   ├── 00000000000000000000.log
│       │   ├── 00000000000000000000.timeindex
│       │   ├── 00000000000000000160.snapshot
│       │   └── leader-epoch-checkpoint
│       ├── recovery-point-offset-checkpoint
│       └── replication-offset-checkpoint
├── zookeeper-0
│   ├── data
│   │   ├── myid
│   │   └── version-2
│   │       ├── acceptedEpoch
│   │       ├── currentEpoch
│   │       ├── log.100000001
│   │       ├── log.200000001
│   │       └── snapshot.0
│   └── logs
├── zookeeper-1
│   ├── data
│   │   ├── myid
│   │   └── version-2
│   │       ├── acceptedEpoch
│   │       ├── currentEpoch
│   │       ├── log.100000001
│   │       ├── log.200000001
│   │       └── snapshot.0
│   └── logs
└── zookeeper-2
    ├── data
    │   ├── myid
    │   └── version-2
    │       ├── acceptedEpoch
    │       ├── currentEpoch
    │       ├── log.100000001
    │       ├── log.200000001
    │       ├── snapshot.0
    │       └── snapshot.1000000c1
    └── logs

177 directories, 685 files



2021-02-04 08:38:35,563 ERROR Unable to load database on disk (org.apache.zookeeper.server.quorum.QuorumPeer) [main]
java.io.IOException: No snapshot found, but there are log entries. Something is broken!
	at org.apache.zookeeper.server.persistence.FileTxnSnapLog.restore(FileTxnSnapLog.java:240)
	at org.apache.zookeeper.server.ZKDatabase.loadDataBase(ZKDatabase.java:240)
	at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:901)
	at org.apache.zookeeper.server.quorum.QuorumPeer.start(QuorumPeer.java:887)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.runFromConfig(QuorumPeerMain.java:205)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:123)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:82)
2021-02-04 08:38:35,565 ERROR Unexpected exception, exiting abnormally (org.apache.zookeeper.server.quorum.QuorumPeerMain) [main]
java.lang.RuntimeException: Unable to run quorum server
	at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:938)
	at org.apache.zookeeper.server.quorum.QuorumPeer.start(QuorumPeer.java:887)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.runFromConfig(QuorumPeerMain.java:205)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:123)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:82)
Caused by: java.io.IOException: No snapshot found, but there are log entries. Something is broken!
	at org.apache.zookeeper.server.persistence.FileTxnSnapLog.restore(FileTxnSnapLog.java:240)
	at org.apache.zookeeper.server.ZKDatabase.loadDataBase(ZKDatabase.java:240)
	at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:901)
	... 4 more
[root@hudi-arm-master-0003 ~]#



2021-01-18 07:57:12,463 INFO [ZooKeeperClient] Connected. (kafka.zookeeper.ZooKeeperClient) [main]
2021-01-18 07:57:12,550 ERROR Fatal error during KafkaServer startup. Prepare to shutdown (kafka.server.KafkaServer) [main]
org.apache.zookeeper.KeeperException$NoAuthException: KeeperErrorCode = NoAuth for /brokers/ids
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:116)
	at org.apache.zookeeper.KeeperException.create(KeeperException.java:54)
	at kafka.zookeeper.AsyncResponse.maybeThrow(ZooKeeperClient.scala:544)
	at kafka.zk.KafkaZkClient.createRecursive(KafkaZkClient.scala:1610)
	at kafka.zk.KafkaZkClient.makeSurePersistentPathExists(KafkaZkClient.scala:1532)
	at kafka.zk.KafkaZkClient.$anonfun$createTopLevelPaths$1(KafkaZkClient.scala:1524)
	at kafka.zk.KafkaZkClient.$anonfun$createTopLevelPaths$1$adapted(KafkaZkClient.scala:1524)
	at scala.collection.immutable.List.foreach(List.scala:392)
	at kafka.zk.KafkaZkClient.createTopLevelPaths(KafkaZkClient.scala:1524)
	at kafka.server.KafkaServer.initZkClient(KafkaServer.scala:386)
	at kafka.server.KafkaServer.startup(KafkaServer.scala:205)
	at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:38)
	at kafka.Kafka$.main(Kafka.scala:75)
	at kafka.Kafka.main(Kafka.scala)
2021-01-18 07:57:12,552 INFO shutting down (kafka.server.KafkaServer) [main]
2021-01-18 07:57:12,556 INFO [ZooKeeperClient] Closing. (kafka.zookeeper.ZooKeeperClient) [main]
2021-01-18 07:57:12,560 INFO Session: 0x101a73e679c000a closed (org.apache.zookeeper.ZooKeeper) [main]
2021-01-18 07:57:12,561 INFO EventThread shut down for session: 0x101a73e679c000a (org.apache.zookeeper.ClientCnxn) [main-EventThread]
2021-01-18 07:57:12,562 INFO [ZooKeeperClient] Closed. (kafka.zookeeper.ZooKeeperClient) [main]
2021-01-18 07:57:12,565 INFO shut down completed (kafka.server.KafkaServer) [main]
2021-01-18 07:57:12,565 ERROR Exiting Kafka. (kafka.server.KafkaServerStartable) [main]
2021-01-18 07:57:12,567 INFO shutting down (kafka.server.KafkaServer) [kafka-shutdown-hook]
[root@mw-region-s2 huzhi]#




2021-01-18 06:49:35,733 ERROR Fatal error during KafkaServer startup. Prepare to shutdown (kafka.server.KafkaServer) [main]
kafka.common.InconsistentBrokerIdException: Configured broker.id 0 doesn't match stored broker.id 1001 in meta.properties. If you moved your data, make sure your configured broker.id matches. If you intend to create a new broker, you should remove all data in your data directories (log.dirs).
	at kafka.server.KafkaServer.getBrokerIdAndOfflineDirs(KafkaServer.scala:710)
	at kafka.server.KafkaServer.startup(KafkaServer.scala:212)
	at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:38)
	at kafka.Kafka$.main(Kafka.scala:75)
	at kafka.Kafka.main(Kafka.scala)
2021-01-18 06:49:35,735 INFO shutting down (kafka.server.KafkaServer) [main]
2021-01-18 06:49:35,738 INFO [ZooKeeperClient] Closing. (kafka.zookeeper.ZooKeeperClient) [main]
2021-01-18 06:49:35,742 INFO Session: 0x101a713732e0003 closed (org.apache.zookeeper.ZooKeeper) [main]
2021-01-18 06:49:35,744 INFO [ZooKeeperClient] Closed. (kafka.zookeeper.ZooKeeperClient) [main]
2021-01-18 06:49:35,748 INFO EventThread shut down for session: 0x101a713732e0003 (org.apache.zookeeper.ClientCnxn) [main-EventThread]
2021-01-18 06:49:35,748 INFO shut down completed (kafka.server.KafkaServer) [main]
2021-01-18 06:49:35,749 ERROR Exiting Kafka. (kafka.server.KafkaServerStartable) [main]
2021-01-18 06:49:35,752 INFO shutting down (kafka.server.KafkaServer) [kafka-shutdown-hook]
[root@mw-region-s2 huzhi]#



apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    chart: kafka-zookeeper
    service_name: cpaas-kafka
  name: cpaas-kafka
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      service_name: cpaas-kafka
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        cpaas.io/product: Platform-Center
        service_name: cpaas-kafka
      namespace: cpaas-system
    spec:
      affinity:
        podAffinity: {}
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: service_name
                operator: In
                values:
                - cpaas-kafka
            topologyKey: kubernetes.io/hostname
      containers:
      - env:
        - name: ACCESS_CONTROL_SWITCH
          value: "false"
        - name: KAFKA_NAMESPACE
          value: cpaas-system
        - name: COMP_NAME
          value: kafka
        - name: KAFKA_ADVERTISED_PORT
          value: "9092"
        - name: KAFKA_ADVERTISED_LISTENERS
          value: plan
        - name: HOST_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.hostIP
        - name: KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS
          value: "6000"
        - name: KAFKA_HEAP_OPTS
          value: -Xmx1g -Xms512m
        - name: KAFKA_HOME
          value: /opt/kafka_2.12-2.2.1
        - name: KAFKA_LOG_DIRS
          value: /kafka0
        - name: KAFKA_LOG_RETENTION_HOURS
          value: "48"
        - name: KAFKA_LOG_ROLL_HOURS
          value: "12"
        - name: KAFKA_LOG_SEGMENT_DELETE_DELAY_MS
          value: "0"
        - name: KAFKA_MAX_MESSAGE_BYTES
          value: "1048576000"
        - name: KAFKA_MAX_REQUEST_SIZE
          value: "10000000000"
        - name: KAFKA_MESSAGE_MAX_BYTES
          value: "1048576000"
        - name: KAFKA_NUM_PARTITIONS
          value: "30"
        - name: KAFKA_REPLICA_FETCH_MAX_BYTES
          value: "1048576000"
        - name: KAFKA_REPLICA_FETCH_RESPONSE_MAX_BYTES
          value: "1048576000"
        - name: KAFKA_SOCKET_REQUEST_MAX_BYTES
          value: "1000000000"
        - name: KAFKA_ZOOKEEPER_CONNECT
          value: cpaas-zookeeper
        - name: __ALAUDA_FILE_LOG_PATH__
          value: /opt/kafka_2.12-2.2.1/logs/*.log
        image: 192.168.34.81:60080/ait/kafka:v3.0.2
        imagePullPolicy: Always
        livenessProbe:
          failureThreshold: 2
          initialDelaySeconds: 100
          periodSeconds: 2
          successThreshold: 1
          tcpSocket:
            port: 9092
          timeoutSeconds: 15
        name: cpaas-kafka
        readinessProbe:
          failureThreshold: 3
          periodSeconds: 5
          successThreshold: 1
          tcpSocket:
            port: 9092
          timeoutSeconds: 15
        resources:
          limits:
            cpu: "2"
            memory: 4Gi
          requests:
            cpu: 200m
            memory: 256Mi
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/cpaas/log-config
          name: acp-config-secret
          readOnly: true
        - mountPath: /kafka
          name: kafka-data
        - mountPath: /kafka0
          name: kafka0
      dnsPolicy: ClusterFirstWithHostNet
      hostNetwork: true
      nodeSelector:
        kafka: "true"
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 10
      tolerations:
      - effect: NoSchedule
        key: no-other-pod
        operator: Equal
        value: "true"
      - effect: NoSchedule
        key: no-cpaas-pod
        operator: Equal
        value: "true"
      volumes:
      - name: acp-config-secret
        secret:
          defaultMode: 420
          secretName: acp-config-secret
      - hostPath:
          path: /cpaas/data/kafka
          type: ""
        name: kafka-data
      - hostPath:
          path: /cpaas/data/kafka0
          type: ""
        name: kafka0

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    chart: kafka-zookeeper
    service_name: cpaas-zookeeper
  name: cpaas-zookeeper
  namespace: cpaas-system
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      service_name: cpaas-zookeeper
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        cpaas.io/product: Platform-Center
        service_name: cpaas-zookeeper
      namespace: cpaas-system
    spec:
      affinity:
        podAffinity: {}
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: service_name
                operator: In
                values:
                - cpaas-zookeeper
            topologyKey: kubernetes.io/hostname
      containers:
      - env:
        - name: ACCESS_CONTROL_SWITCH
          value: "false"
        - name: SERVERS
          value: 192.168.34.81
        - name: HOST_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.hostIP
        image: 192.168.34.81:60080/ait/zookeeper:v3.0.2
        imagePullPolicy: Always
        name: cpaas-zookeeper
        resources:
          limits:
            cpu: "2"
            memory: 4Gi
          requests:
            cpu: 50m
            memory: 264Mi
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/cpaas/log-config
          name: acp-config-secret
          readOnly: true
        - mountPath: /tmp/zookeeper
          name: zookeeper-data
      dnsPolicy: ClusterFirst
      hostNetwork: true
      nodeSelector:
        zk: "true"
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 10
      tolerations:
      - effect: NoSchedule
        key: no-other-pod
        operator: Equal
        value: "true"
      - effect: NoSchedule
        key: no-cpaas-pod
        operator: Equal
        value: "true"
      volumes:
      - name: acp-config-secret
        secret:
          defaultMode: 420
          secretName: acp-config-secret
      - hostPath:
          path: /cpaas/data/zookeeper
          type: ""
        name: zookeeper-data


    volumeMounts:
    - mountPath: /etc/cpaas/log-config
      name: acp-config-secret
      readOnly: true
    - mountPath: /kafka
      name: kafka-data
    - mountPath: /kafka0
      name: kafka0
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-7x5dn
      readOnly: true



       volumes:
  - name: acp-config-secret
    secret:
      defaultMode: 420
      secretName: acp-config-secret
  - hostPath:
      path: /cpaas/data/kafka
      type: ""
    name: kafka-data
  - hostPath:
      path: /cpaas/data/kafka0
      type: ""
    name: kafka0
  - name: default-token-7x5dn
    secret:
      defaultMode: 420
      secretName: default-token-7x5dn
      
      
      
```





10.0.129.0:60080/ait/kafka:v3.3.0



10.0.129.0:60080/ait/zookeeper:v3.3.0




整体思路

1、zookeeper 3.5.6 部署为三个节点的集群，不配置任何加密和认证。kafka 2.2.1 也部署为三个 broker 的集群，不配置任何加密和认证方式，正常向 kafka 生产和消费数据。验证使用 operator 0.15 托管数据目录，kafka 版本是 2.2.1，检查 operator 是否可以成功运行，功能是否正常，之前的数据是否丢失。

2、zookeeper 3.5.6 部署为三个节点的集群，不配置任何加密和认证。kafka 2.2.1 也部署为三个 broker 的集群，不配置任何加密和认证方式，正常向 kafka 生产和消费数据。验证删除 zookeeper 数据目录中的数据，operator 和 kafka 是否会回写相关数据，保障功能正常。

3、zookeeper 3.5.6 部署为三个节点的集群，配置 sasl 认证方式。kafka 2.5.0 也部署为三个 broker 的集群，采用 sasl 认证方式，正常向 kafka 生产和消费数据。验证使用 operator 0.18 托管数据目录，检查 operator 是否可以成功运行，功能是否正常，之前的数据是否丢失。

4、zookeeper 3.5.6 部署为三个节点的集群，配置 sasl 认证方式。kafka 2.5.0 也部署为三个 broker 的集群，采用 sasl 认证方式，正常向 kafka 生产和消费数据。验证删除 zookeeper 数据目录中的数据，operator 和 kafka 是否会回写相关数据，保障功能正常。

5、zookeeper 3.5.6 部署为三个节点的集群，不配置任何加密和认证。kafka 2.2.1 也部署为三个 broker 的集群，不配置任何加密和认证方式，正常向 kafka 生产和消费数据。验证使用 operator 0.18 托管数据目录，kafka 版本是 2.5.0，检查 operator 是否可以成功运行，功能是否正常，之前的数据是否丢失。






























































