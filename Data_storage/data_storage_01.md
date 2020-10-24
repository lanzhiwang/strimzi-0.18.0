# 持久化存储

## 临时存储

临时存储配置选项：

| Property  | Type    | Description                                                  |
| :-------- | ------- | :----------------------------------------------------------- |
| id        | integer | Storage identification number. It is mandatory only for storage volumes defined in a storage of type 'jbod'.  存储标识号。 仅对于在 jbod 类型的存储中定义的存储卷是必需的。 |
| sizeLimit | string  | When type=ephemeral, defines the total amount of local storage required for this EmptyDir volume (for example 1Gi).  当type = ephemeral时，定义此EmptyDir卷所需的本地存储总量（例如1Gi）。 |
| type      | string  | Must be `ephemeral`.                                         |

示例：

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
      plain: {}
      tls: {}
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

```

结果验证：

```bash
[root@mw-init ~]# kubectl -n kafka exec -ti my-cluster-kafka-0 bash
[kafka@my-cluster-kafka-0 kafka]$ cd /var/lib/kafka/data/kafka-log0/
[kafka@my-cluster-kafka-0 kafka-log0]$ pwd
/var/lib/kafka/data/kafka-log0
[kafka@my-cluster-kafka-0 kafka-log0]$ ll
total 4
-rw-r--r-- 1 kafka root  0 Oct 20 04:26 cleaner-offset-checkpoint
-rw-r--r-- 1 kafka root  0 Oct 20 04:26 log-start-offset-checkpoint
-rw-r--r-- 1 kafka root 88 Oct 20 04:26 meta.properties
-rw-r--r-- 1 kafka root  0 Oct 20 04:26 recovery-point-offset-checkpoint
-rw-r--r-- 1 kafka root  0 Oct 20 04:26 replication-offset-checkpoint
[kafka@my-cluster-kafka-0 kafka-log0]$


[root@mw-init ~]# kubectl -n kafka exec -ti my-cluster-zookeeper-0 bash
[kafka@my-cluster-zookeeper-0 kafka]$ cd /var/lib/zookeeper/
[kafka@my-cluster-zookeeper-0 zookeeper]$
[kafka@my-cluster-zookeeper-0 zookeeper]$ ll
total 8
drwxr-xr-x 3 kafka root 4096 Oct 20 04:25 data
drwxr-xr-x 2 kafka root 4096 Oct 20 04:25 logs
[kafka@my-cluster-zookeeper-0 zookeeper]$  ll data/
total 8
-rw-r--r-- 1 kafka root    2 Oct 20 04:25 myid
drwxr-xr-x 2 kafka root 4096 Oct 20 04:26 version-2
[kafka@my-cluster-zookeeper-0 zookeeper]$
[kafka@my-cluster-zookeeper-0 zookeeper]$  ll logs/
total 0
[kafka@my-cluster-zookeeper-0 zookeeper]$

```


## 持久化存储

持久化存储配置：

| Property    | Type                                 | Description                                                  |
| :---------- | ------------------------------------ | :----------------------------------------------------------- |
| type        | string                               | Must be `persistent-claim`.                                  |
| size        | string                               | When type=persistent-claim, defines the size of the persistent volume claim (i.e 1Gi). Mandatory when type=persistent-claim.  定义持久卷声明的大小，例如“ 1000Gi”。 |
| selector    | map                                  | Specifies a specific persistent volume to use. It contains key:value pairs representing labels for selecting such a volume.  允许选择要使用的特定永久卷。 它包含key：value对，代表用于选择此类音量的标签。 |
| deleteClaim | boolean                              | Specifies if the persistent volume claim has to be deleted when the cluster is un-deployed.  一个布尔值，它指定在取消部署集群时是否必须删除持久卷声明。 默认值为“ false”。 |
| class       | string                               | The storage class to use for dynamic volume allocation.  用于动态卷配置的Kubernetes存储类。 |
| id          | integer                              | Storage identification number. It is mandatory only for storage volumes defined in a storage of type 'jbod'.  存储标识号。 对于JBOD存储声明中定义的存储卷，此选项是必需的。 默认值为0。 |
| overrides   | PersistentClaimStorageOverride array | Overrides for individual brokers. The `overrides` field allows to specify a different configuration for different brokers.  对个人经纪人的替代。 “覆盖”字段允许为不同的代理指定不同的配置。 |

PersistentClaimStorageOverride schema reference：

| Property | type    | Description                                                  |
| :------- | ------- | :----------------------------------------------------------- |
| class    | string  | The storage class to use for dynamic volume allocation for this broker. |
| broker   | integer | Id of the kafka broker (broker identifier).                  |

示例：

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
      plain: {}
      tls: {}
      external:
        type: nodeport
        tls: true
        authentication:
          type: tls
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: persistent-claim
      size: 1000Gi
      class: intceph
      selector:
        hdd-type: ssd
      deleteClaim: true
      overrides:
        - broker: 0
          class: my-storage-class-zone-1a
        - broker: 1
          class: my-storage-class-zone-1b
        - broker: 2
          class: my-storage-class-zone-1c
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 1000Gi
      class: intceph
      selector:
        hdd-type: ssd
      deleteClaim: true
      overrides:
        - broker: 0
          class: my-storage-class-zone-1a
        - broker: 1
          class: my-storage-class-zone-1b
        - broker: 2
          class: my-storage-class-zone-1c
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0
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

---

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

---

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    cpaas.io/creator: admin@cpaas.io
    cpaas.io/display-name: intceph
    cpaas.io/updated-at: '2020-10-15T06:38:24Z'
    storageclass.kubernetes.io/is-default-class: 'true'
  creationTimestamp: '2020-09-14T06:28:39Z'
  labels:
    project.cpaas.io/name: ALL_ALL
  name: intceph
  resourceVersion: '52279920'
  selfLink: /apis/storage.k8s.io/v1/storageclasses/intceph
  uid: 5f49d6b5-8ebe-4ce4-864e-9afc062cd1df
parameters:
  adminId: admin
  adminSecretName: ceph-secret-admin
  adminSecretNamespace: cpaas-system
  claimRoot: /kubernetes
  monitors: '192.168.16.172:6789,192.168.16.173:6790,192.168.16.174:6791'
provisioner: ceph.com/cephfs
reclaimPolicy: Delete
volumeBindingMode: Immediate




```



验证结果：



```bash
[root@mw-init ~]# kubectl -n kafka get pvc -o wide
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
data-my-cluster-kafka-0       Bound    pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5   10Gi       RWO            intceph        14m   Filesystem
data-my-cluster-kafka-1       Bound    pvc-bcb9ff07-733f-4481-a13f-188cfdddd738   10Gi       RWO            intceph        14m   Filesystem
data-my-cluster-kafka-2       Bound    pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822   10Gi       RWO            intceph        14m   Filesystem
data-my-cluster-zookeeper-0   Bound    pvc-ffb2101e-df03-4b5b-918c-0a217730fde3   10Gi       RWO            intceph        27m   Filesystem
data-my-cluster-zookeeper-1   Bound    pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64   10Gi       RWO            intceph        27m   Filesystem
data-my-cluster-zookeeper-2   Bound    pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3   10Gi       RWO            intceph        27m   Filesystem
[root@mw-init ~]#

# pv
pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3

[root@mw-init ~]# kubectl get pv pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5 pvc-bcb9ff07-733f-4481-a13f-188cfdddd738 pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822 pvc-ffb2101e-df03-4b5b-918c-0a217730fde3 pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64 pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3 -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-0       intceph                 17m   Filesystem
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-1       intceph                 17m   Filesystem
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-2       intceph                 17m   Filesystem
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-0   intceph                 29m   Filesystem
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-1   intceph                 29m   Filesystem
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-2   intceph                 29m   Filesystem
[root@mw-init ~]#
[root@mw-init ~]#



修改
pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3


Retain
[root@mw-init ~]# kubectl get pv pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5 pvc-bcb9ff07-733f-4481-a13f-188cfdddd738 pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822 pvc-ffb2101e-df03-4b5b-918c-0a217730fde3 pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64 pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3 -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-0       intceph                 21m   Filesystem
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-1       intceph                 21m   Filesystem
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-2       intceph                 21m   Filesystem
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-0   intceph                 33m   Filesystem
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-1   intceph                 33m   Filesystem
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-2   intceph                 33m   Filesystem
[root@mw-init ~]#
[root@mw-init ~]#

备份 pvc

data-my-cluster-kafka-0
data-my-cluster-kafka-1
data-my-cluster-kafka-2
data-my-cluster-zookeeper-0
data-my-cluster-zookeeper-1
data-my-cluster-zookeeper-2

[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-kafka-0 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5

[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-kafka-1 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-bcb9ff07-733f-4481-a13f-188cfdddd738


[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-kafka-2 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822



[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-zookeeper-0 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-ffb2101e-df03-4b5b-918c-0a217730fde3


[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-zookeeper-1 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64


[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-zookeeper-2 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3






cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=ZVkSTdcr3Wwo
ssl.endpoint.identification.algorithm=

ssl.keystore.location=./user-keystore.jks
ssl.keystore.password=JpNNDCiSbA0c
ssl.key.password=JpNNDCiSbA0c
EOF

[root@mw-init ssl]# kafka-topics.sh --bootstrap-server 10.0.128.237:30298 --command-config ./client-ssl.properties --list
my-topic
[root@mw-init ssl]#

[root@mw-init ssl]# kafka-producer-perf-test.sh --num-records 500 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=10.0.128.237:30298 --producer.config ./client-ssl.properties
500 records sent, 551.876380 records/sec (0.53 MB/sec), 320.75 ms avg latency, 613.00 ms max latency, 319 ms 50th, 438 ms 95th, 440 ms 99th, 613 ms 99.9th.
[root@mw-init ssl]#


[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:30298 --topic my-topic --producer.config ./client-ssl.properties
>hello1
>hello2
>hello3
>hello4
>


[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:30298 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello4
hello1
hello3
hello2

[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30298 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          176             176             0               consumer-my-group-1-713423ee-515d-4b6d-93e2-65f3ec7ed0b2 /10.0.129.171   consumer-my-group-1
my-group        my-topic        1          176             176             0               consumer-my-group-1-713423ee-515d-4b6d-93e2-65f3ec7ed0b2 /10.0.129.171   consumer-my-group-1
my-group        my-topic        2          148             148             0               consumer-my-group-1-713423ee-515d-4b6d-93e2-65f3ec7ed0b2 /10.0.129.171   consumer-my-group-1
[root@mw-init ssl]#




[root@mw-init ssl]# kubectl -n kafka get kafkatopic
NAME                                                          PARTITIONS   REPLICATION FACTOR
consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a   50           3
my-topic                                                      3            3
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get kafkatopic my-topic -o yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: my-topic
  namespace: kafka
spec:
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
  partitions: 3
  replicas: 3


[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get kafkatopic consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a -o yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a
  namespace: kafka
spec:
  config:
    cleanup.policy: compact
    compression.type: producer
    segment.bytes: "104857600"
  partitions: 50
  replicas: 3
  topicName: __consumer_offsets










[root@mw-init ssl]# kubectl -n kafka delete kafkatopic consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a my-topic

[root@mw-init ssl]# kubectl -n kafka delete kafkauser my-user
kafkauser.kafka.strimzi.io "my-user" deleted
[root@mw-init ssl]#

[root@mw-init ssl]# kubectl -n kafka delete kafka my-cluster
kafka.kafka.strimzi.io "my-cluster" deleted
[root@mw-init ssl]#


删除 namespaces

[root@mw-init ssl]# kubectl get ns kafka -o wide
NAME    STATUS   AGE
kafka   Active   10d
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl delete ns kafka
namespace "kafka" deleted
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl get ns kafka -o wide
Error from server (NotFound): namespaces "kafka" not found
[root@mw-init ssl]#
[root@mw-init ssl]#


[root@mw-init ssl]# kubectl get pv pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5 pvc-bcb9ff07-733f-4481-a13f-188cfdddd738 pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822 pvc-ffb2101e-df03-4b5b-918c-0a217730fde3 pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64 pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3 -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                               STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-0       intceph                 41m   Filesystem
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-1       intceph                 41m   Filesystem
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-2       intceph                 41m   Filesystem
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-0   intceph                 53m   Filesystem
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-1   intceph                 53m   Filesystem
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-2   intceph                 53m   Filesystem
[root@mw-init ssl]#
[root@mw-init ssl]#



[root@mw-init ssl]# kubectl create namespace kafka
namespace/kafka created
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl get ns kafka -o wide
NAME    STATUS   AGE
kafka   Active   11s
[root@mw-init ssl]#










恢复数据 pvc


apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-bcb9ff07-733f-4481-a13f-188cfdddd738

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-kafka-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-ffb2101e-df03-4b5b-918c-0a217730fde3

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-zookeeper-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3





修改

pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5
pvc-bcb9ff07-733f-4481-a13f-188cfdddd738
pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822
pvc-ffb2101e-df03-4b5b-918c-0a217730fde3
pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64
pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3


[root@mw-init ssl]# kubectl -n kafka get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-my-cluster-kafka-0       Bound    pvc-bac2c497-296e-4a0b-8c92-4acd4f3a0de5   10Gi       RWO            intceph        4m37s
data-my-cluster-kafka-1       Bound    pvc-bcb9ff07-733f-4481-a13f-188cfdddd738   10Gi       RWO            intceph        4m37s
data-my-cluster-kafka-2       Bound    pvc-f4f03b45-42f3-4b8b-b0c7-96237453b822   10Gi       RWO            intceph        4m37s
data-my-cluster-zookeeper-0   Bound    pvc-ffb2101e-df03-4b5b-918c-0a217730fde3   10Gi       RWO            intceph        4m37s
data-my-cluster-zookeeper-1   Bound    pvc-e77853b9-4ea6-4c1f-aa3f-417453f90c64   10Gi       RWO            intceph        4m37s
data-my-cluster-zookeeper-2   Bound    pvc-e293a339-0b3a-40ef-ae69-ebfcf7ad14f3   10Gi       RWO            intceph        4m37s
[root@mw-init ssl]#



kubectl apply -f install/cluster-operator -n kafka



恢复 User

恢复 Topic


apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: my-topic
  namespace: kafka
spec:
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a
  namespace: kafka
spec:
  config:
    cleanup.policy: compact
    compression.type: producer
    segment.bytes: "104857600"
  partitions: 50
  replicas: 3
  topicName: __consumer_offsets



[root@mw-init ssl]# kubectl -n kafka get kafkatopic
NAME                                                          PARTITIONS   REPLICATION FACTOR
consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a   50           3
my-topic                                                      3            3
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get kafkausers
NAME      AUTHENTICATION   AUTHORIZATION
my-user   tls              simple
[root@mw-init ssl]#
[root@mw-init ssl]#





恢复 kafka 集群


cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=JQGjv40A5uPV
ssl.endpoint.identification.algorithm=

ssl.keystore.location=./user-keystore.jks
ssl.keystore.password=MomRHe1bTa3T
ssl.key.password=MomRHe1bTa3T
EOF

[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:31995 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
my-group        my-topic        0          176             176             0               -               -               -
my-group        my-topic        1          176             176             0               -               -               -
my-group        my-topic        2          148             148             0               -               -               -


kafka-console-consumer.sh --bootstrap-server 10.0.128.237:31995 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group


[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:31995 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          176             176             0               consumer-my-group-1-bc7092f8-d531-498c-a971-d8c33c080f41 /10.0.129.171   consumer-my-group-1
my-group        my-topic        1          176             176             0               consumer-my-group-1-bc7092f8-d531-498c-a971-d8c33c080f41 /10.0.129.171   consumer-my-group-1
my-group        my-topic        2          148             148             0               consumer-my-group-1-bc7092f8-d531-498c-a971-d8c33c080f41 /10.0.129.171   consumer-my-group-1
[root@mw-init ssl]#


```


Ceph 参考：

* https://github.com/kubernetes/examples/tree/master/volumes/cephfs/

```yaml
# 第一种用法
apiVersion: v1
kind: PersistentVolume
metadata:
  name: kafka-cluster-pv
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  cephfs:
    monitors:
    - 192.168.16.172:6789
    - 192.168.16.173:6790
    - 192.168.16.174:6791
    path: /kubernetes
    secretRef:
      name: ceph-secret-admin
      namespace: cpaas-system
    user: admin
  persistentVolumeReclaimPolicy: Delete
  volumeMode: Filesystem

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-pvc
spec:
  resources:
    requests:
      storage: 10Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: ""

---

apiVersion: v1
kind: Pod
metadata:
  name: fortune
spec:
  containers:
  - image: nginx
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    persistentVolumeClaim:
      claimName: kafka-pvc

#########################################

# 第二种用法
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-pvc
spec:
  resources:
    requests:
      storage: 10Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: intceph

---

apiVersion: v1
kind: Pod
metadata:
  name: fortune
spec:
  containers:
  - image: nginx
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
    ports:
    - containerPort: 80
      protocol: TCP
  volumes:
  - name: html
    persistentVolumeClaim:
      claimName: kafka-pvc

```



- *monitors*: Array of Ceph monitors.
- *path*: Used as the mounted root, rather than the full Ceph tree. If not provided, default */* is used.
- *user*: The RADOS user name. If not provided, default *admin* is used.
- *secretFile*: The path to the keyring file. If not provided, default */etc/ceph/user.secret* is used.
- *secretRef*: Reference to Ceph authentication secrets. If provided, *secret* overrides *secretFile*.
- *readOnly*: Whether the filesystem is used as readOnly.





https://strimzi.io/docs/operators/latest/using.html
https://strimzi.io/docs/operators/0.18.0/using.html

https://strimzi.io/docs/operators/latest/full/using.html#type-PodTemplate-reference
https://strimzi.io/docs/operators/0.18.0/full/using.html#type-PodTemplate-reference


Kafka -> KafkaSpec -> KafkaClusterSpec -> KafkaClusterTemplate -> PodTemplate





https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podsecuritycontext-v1-core

https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podsecuritycontext-v1-core



