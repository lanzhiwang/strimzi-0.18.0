

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

