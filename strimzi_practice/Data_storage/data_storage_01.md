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







# NFS 验证



```yaml
# kafka 和 KafkaTopic 部署的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster-nfs
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
        tls: false
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: persistent-claim
      size: 2Gi
      class: galaxy-sc
      deleteClaim: false
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 1Gi
      class: galaxy-sc
      deleteClaim: false
  entityOperator:
    topicOperator: {}
    userOperator: {}

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster-nfs
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

# 验证成功创建 PVC，也找到对应的的 PV
[root@192 ~]# kubectl -n kafka get pvc
NAME                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-my-cluster-nfs-kafka-0       Bound    pvc-311b15bf-5758-4c43-acc7-b1d32d540890   2Gi        RWO            galaxy-sc      2m30s
data-my-cluster-nfs-kafka-1       Bound    pvc-f64e5c96-85b8-4192-b63b-8c71472cf9c8   2Gi        RWO            galaxy-sc      2m30s
data-my-cluster-nfs-kafka-2       Bound    pvc-78dfb238-9a72-44f9-bb69-fd6b0a7b82d2   2Gi        RWO            galaxy-sc      2m30s
data-my-cluster-nfs-zookeeper-0   Bound    pvc-57aad475-33b1-4626-a47f-3531bb611edc   1Gi        RWO            galaxy-sc      3m2s
data-my-cluster-nfs-zookeeper-1   Bound    pvc-a88782b5-1089-43cc-bc39-f8622850e9b9   1Gi        RWO            galaxy-sc      3m2s
data-my-cluster-nfs-zookeeper-2   Bound    pvc-f7c342e2-6af2-471f-aeb1-efc4d9dd7587   1Gi        RWO            galaxy-sc      3m2s
[root@192 ~]#


kubectl get pv pvc-311b15bf-5758-4c43-acc7-b1d32d540890 pvc-f64e5c96-85b8-4192-b63b-8c71472cf9c8 pvc-78dfb238-9a72-44f9-bb69-fd6b0a7b82d2 pvc-57aad475-33b1-4626-a47f-3531bb611edc pvc-a88782b5-1089-43cc-bc39-f8622850e9b9 pvc-f7c342e2-6af2-471f-aeb1-efc4d9dd7587

# 修改 PV 的 RECLAIM POLICY 为 Retain
[root@192 ~]# kubectl get pv pvc-311b15bf-5758-4c43-acc7-b1d32d540890 pvc-f64e5c96-85b8-4192-b63b-8c71472cf9c8 pvc-78dfb238-9a72-44f9-bb69-fd6b0a7b82d2 pvc-57aad475-33b1-4626-a47f-3531bb611edc pvc-a88782b5-1089-43cc-bc39-f8622850e9b9 pvc-f7c342e2-6af2-471f-aeb1-efc4d9dd7587
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                   STORAGECLASS   REASON   AGE
pvc-311b15bf-5758-4c43-acc7-b1d32d540890   2Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-kafka-0       galaxy-sc               7m32s
pvc-f64e5c96-85b8-4192-b63b-8c71472cf9c8   2Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-kafka-1       galaxy-sc               7m32s
pvc-78dfb238-9a72-44f9-bb69-fd6b0a7b82d2   2Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-kafka-2       galaxy-sc               7m32s
pvc-57aad475-33b1-4626-a47f-3531bb611edc   1Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-zookeeper-0   galaxy-sc               8m4s
pvc-a88782b5-1089-43cc-bc39-f8622850e9b9   1Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-zookeeper-1   galaxy-sc               8m4s
pvc-f7c342e2-6af2-471f-aeb1-efc4d9dd7587   1Gi        RWO            Retain           Bound    kafka/data-my-cluster-nfs-zookeeper-2   galaxy-sc               8m4s
[root@192 ~]#


# 备份 PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-kafka-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-311b15bf-5758-4c43-acc7-b1d32d540890

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-kafka-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-f64e5c96-85b8-4192-b63b-8c71472cf9c8

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-kafka-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-78dfb238-9a72-44f9-bb69-fd6b0a7b82d2

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-zookeeper-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-57aad475-33b1-4626-a47f-3531bb611edc

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-zookeeper-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-a88782b5-1089-43cc-bc39-f8622850e9b9

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-my-cluster-nfs-zookeeper-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: galaxy-sc
  volumeMode: Filesystem
  volumeName: pvc-f7c342e2-6af2-471f-aeb1-efc4d9dd7587


# 向集群写入数据
kafka-producer-perf-test.sh --num-records 500 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=my-cluster-nfs-kafka-bootstrap:9092

# 消费数据
kafka-console-consumer.sh --bootstrap-server my-cluster-nfs-kafka-bootstrap:9092 --topic my-topic --from-beginning --group my-group

kafka-consumer-groups.sh --bootstrap-server my-cluster-nfs-kafka-bootstrap:9092 --list

# 确定数据数量
kafka-consumer-groups.sh --bootstrap-server my-cluster-nfs-kafka-bootstrap:9092 --describe --group my-group

# 备份 kafkatopic
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster-nfs
  name: my-topic
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: my-cluster-nfs
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

#############################################################

# 删除 kafka 命名空间
kubectl delete ns kafka

# 恢复 PVC，删除 PV 的 claimRef 的属性
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-my-cluster-nfs-zookeeper-2
    namespace: kafka
    resourceVersion: "31518082"
    uid: 30230d27-fc0b-47c0-880c-e734ece69831

# 创建 kafka 命名空间
kubectl create ns kafka

# 恢复 kafkatopic

# 恢复 kafka 集群

# 确认数据存在
[root@my-cluster-nfs-kafka-1 bin]# ./kafka-consumer-groups.sh --bootstrap-server my-cluster-nfs-kafka-bootstrap:9092 --describe --group my-group
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using-XX:ParallelGCThreads=N

Consumer group 'my-group' has no active members.

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
my-group        my-topic        0          128             128             0               -               -               -
my-group        my-topic        1          196             196             0               -               -               -
my-group        my-topic        2          176             176             0               -               -               -
[root@my-cluster-nfs-kafka-1 bin]#








```











# hostpath 验证



```yaml
apiVersion: v1
kind: Secret
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  name: admin
  namespace: kafka
data:
  password: bVR0Q0dDV0tab0FfeFJ6Vw==
type: Opaque

---

apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: acp-kafka-cluster
  namespace: kafka
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    resources:
      limits:
        cpu: "2"
        memory: 4Gi
      requests:
        cpu: 200m
        memory: 256Mi
    jmxOptions: {}
    listeners:
      plain:
        authentication:
          type: scram-sha-512
      external:
        type: nodeport
        tls: false
        authentication:
          type: scram-sha-512
    config:
      group.initial.rebalance.delay.ms: 6000
      default.replication.factor: 3
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
      log.retention.hours: 48
      log.roll.hours: 12
      log.segment.delete.delay.ms: 0
      max.message.bytes: 1048576000
      max.request.size: 10000000000
      message.max.bytes: 1048576000
      num.partitions: 30
      replica.fetch.max.bytes: 1048576000
      replica.fetch.response.max.bytes: 1048576000
      socket.request.max.bytes: 1000000000
      log.message.format.version: "2.5"
    storage:
      type: persistent-claim
      size: 1Gi
      class: local-path
      deleteClaim: false
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 1Gi
      class: local-path
      deleteClaim: false
  entityOperator:
    topicOperator: {}
    userOperator: {}

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: admin
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  namespace: kafka
spec:
  authentication:
    type: scram-sha-512

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: alauda-audit-topic
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: alauda-event-topic
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: alauda-log-topic
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

```

验证：

```bash
[root@mw-init test]# kubectl -n kafka get pvc
NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-acp-kafka-cluster-kafka-0       Bound    pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e   1Gi        RWO            local-path     2m32s
data-acp-kafka-cluster-kafka-1       Bound    pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e   1Gi        RWO            local-path     2m32s
data-acp-kafka-cluster-kafka-2       Bound    pvc-9988de37-be6f-403a-a04b-7fe9561f2f44   1Gi        RWO            local-path     2m32s
data-acp-kafka-cluster-zookeeper-0   Bound    pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33   1Gi        RWO            local-path     3m3s
data-acp-kafka-cluster-zookeeper-1   Bound    pvc-ae828e1a-3aa5-4857-818a-47ab57076869   1Gi        RWO            local-path     3m3s
data-acp-kafka-cluster-zookeeper-2   Bound    pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305   1Gi        RWO            local-path     3m3s
[root@mw-init test]#

[root@mw-init test]# kubectl get pv pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e pvc-9988de37-be6f-403a-a04b-7fe9561f2f44 pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33 pvc-ae828e1a-3aa5-4857-818a-47ab57076869 pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-kafka-0       local-path              4m46s
pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-kafka-1       local-path              4m46s
pvc-9988de37-be6f-403a-a04b-7fe9561f2f44   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-kafka-2       local-path              4m45s
pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-zookeeper-0   local-path              5m17s
pvc-ae828e1a-3aa5-4857-818a-47ab57076869   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-zookeeper-1   local-path              5m16s
pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305   1Gi        RWO            Delete           Bound    kafka/data-acp-kafka-cluster-zookeeper-2   local-path              5m15s
[root@mw-init test]#


[root@mw-init test]# kubectl get pv pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e pvc-9988de37-be6f-403a-a04b-7fe9561f2f44 pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33 pvc-ae828e1a-3aa5-4857-818a-47ab57076869 pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-kafka-0       local-path              8m50s
pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-kafka-1       local-path              8m50s
pvc-9988de37-be6f-403a-a04b-7fe9561f2f44   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-kafka-2       local-path              8m49s
pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-zookeeper-0   local-path              9m21s
pvc-ae828e1a-3aa5-4857-818a-47ab57076869   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-zookeeper-1   local-path              9m20s
pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305   1Gi        RWO            Retain           Bound    kafka/data-acp-kafka-cluster-zookeeper-2   local-path              9m19s
[root@mw-init test]#


apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-kafka-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-a64a1912-c150-44d6-bf01-3c0bef03c16e

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-kafka-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-39ff0bcf-1642-4889-bf22-54f945c88b0e

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-kafka-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-9988de37-be6f-403a-a04b-7fe9561f2f44

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-zookeeper-0
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-a2e03cc0-6daa-4c5d-9826-67c3adf81f33

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-zookeeper-1
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-ae828e1a-3aa5-4857-818a-47ab57076869

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-acp-kafka-cluster-zookeeper-2
  namespace: kafka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeMode: Filesystem
  volumeName: pvc-655a3c85-ffaf-4f84-8f6c-25142feb9305



kafka-producer-perf-test.sh --num-records 500 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=10.0.128.237:31827 --producer.config ./client.properties

kafka-console-consumer.sh --bootstrap-server 10.0.128.237:31827 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group

kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:31827 --command-config ./client.properties --list

kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:31827 --command-config ./client.properties --describe --group my-group


apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  name: alauda-audit-topic
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  name: alauda-event-topic
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  name: alauda-log-topic
  namespace: kafka
spec:
  partitions: 3
  replicas: 3

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
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

---

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  labels:
    strimzi.io/cluster: acp-kafka-cluster
  name: my-topic
  namespace: kafka
spec:
  partitions: 3
  replicas: 3


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


```









