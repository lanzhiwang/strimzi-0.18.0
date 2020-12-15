cmak

https://github.com/yahoo/CMAK

https://github.com/hleb-albau/kafka-manager-docker


```bash
docker pull hlebalbau/kafka-manager


docker run -d -p 9000:9000 -e ZK_HOSTS="10.0.128.237:32188" hlebalbau/kafka-manager





[kafka@my-cluster-kafka-0 kafka]$ echo ${MY_CLUSTER_ZOOKEEPER_CLIENT_PORT_2181_TCP_ADDR}:${MY_CLUSTER_ZOOKEEPER_CLIENT_SERVICE_PORT}
10.105.45.147:2181
[kafka@my-cluster-kafka-0 kafka]$

kubectl -n kafka run cmak --port=9000 --env="ZK_HOSTS=${MY_CLUSTER_ZOOKEEPER_CLIENT_PORT_2181_TCP_ADDR}:${MY_CLUSTER_ZOOKEEPER_CLIENT_SERVICE_PORT}" --image=hlebalbau/kafka-manager





kubectl run -name cmak -ti 
```







1. https://github.com/yahoo/CMAK
2. https://github.com/linkedin/kafka-monitor
3. https://github.com/Morningstar/kafka-offset-monitor
4. https://github.com/linkedin/cruise-control









kafka 集群的使用场景

数据丢失

集群挂掉







