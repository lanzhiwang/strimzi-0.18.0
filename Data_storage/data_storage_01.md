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
[root@mw-init ssl]# kubectl -n kafka get pvc -o wide
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE     VOLUMEMODE
data-my-cluster-kafka-0       Bound    pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf   10Gi       RWO            intceph        2m21s   Filesystem
data-my-cluster-kafka-1       Bound    pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7   10Gi       RWO            intceph        2m21s   Filesystem
data-my-cluster-kafka-2       Bound    pvc-e60fb453-a0ae-443b-9471-19cfea46c133   10Gi       RWO            intceph        2m21s   Filesystem
data-my-cluster-zookeeper-0   Bound    pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb   10Gi       RWO            intceph        3m15s   Filesystem
data-my-cluster-zookeeper-1   Bound    pvc-b58c074a-3ebd-4749-b8ab-6966276af34b   10Gi       RWO            intceph        3m15s   Filesystem
data-my-cluster-zookeeper-2   Bound    pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc   10Gi       RWO            intceph        3m15s   Filesystem
[root@mw-init ssl]#
[root@mw-init ssl]#

[root@mw-init ~]# kubectl -n kafka get pvc data-my-cluster-kafka-0 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    pv.kubernetes.io/bind-completed: "yes"
    strimzi.io/delete-claim: "true"
  creationTimestamp: "2020-10-22T02:05:59Z"
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app.kubernetes.io/instance: my-cluster
    app.kubernetes.io/managed-by: strimzi-cluster-operator
    app.kubernetes.io/name: kafka
    app.kubernetes.io/part-of: strimzi-my-cluster
    strimzi.io/cluster: my-cluster
    strimzi.io/kind: Kafka
    strimzi.io/name: my-cluster-kafka
  name: data-my-cluster-kafka-0
  namespace: kafka
  ownerReferences:
  - apiVersion: kafka.strimzi.io/v1beta1
    blockOwnerDeletion: false
    controller: false
    kind: Kafka
    name: my-cluster
    uid: e6d98525-ca17-41ad-a245-5363403fe810
  resourceVersion: "59193884"
  selfLink: /api/v1/namespaces/kafka/persistentvolumeclaims/data-my-cluster-kafka-0
  uid: 3f73e2c0-1d3a-4874-8a79-5057174c6e69
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: intceph
  volumeMode: Filesystem
  volumeName: pvc-3f73e2c0-1d3a-4874-8a79-5057174c6e69
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  phase: Bound
[root@mw-init ~]#


[root@mw-init ~]# kubectl get pv pvc-3f73e2c0-1d3a-4874-8a79-5057174c6e69 -o yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    cephFSProvisionerIdentity: cephfs-provisioner-1
    cephShare: kubernetes-dynamic-pvc-2ba9e02d-690d-4c3b-8145-00101714e519
    pv.kubernetes.io/provisioned-by: ceph.com/cephfs
  creationTimestamp: "2020-10-22T02:06:02Z"
  finalizers:
  - kubernetes.io/pv-protection
  name: pvc-3f73e2c0-1d3a-4874-8a79-5057174c6e69
  resourceVersion: "59188610"
  selfLink: /api/v1/persistentvolumes/pvc-3f73e2c0-1d3a-4874-8a79-5057174c6e69
  uid: f4074fe8-2968-4592-a492-170522427840
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
    path: /kubernetes/kubernetes/kubernetes/kubernetes-dynamic-pvc-2ba9e02d-690d-4c3b-8145-00101714e519
    secretRef:
      name: ceph-kubernetes-dynamic-user-8b62896a-5186-4f34-a4cb-f71331aa3998-secret
      namespace: cpaas-system
    user: kubernetes-dynamic-user-8b62896a-5186-4f34-a4cb-f71331aa3998
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: data-my-cluster-kafka-0
    namespace: kafka
    resourceVersion: "59188496"
    uid: 3f73e2c0-1d3a-4874-8a79-5057174c6e69
  persistentVolumeReclaimPolicy: Delete
  storageClassName: intceph
  volumeMode: Filesystem
status:
  phase: Bound
[root@mw-init ~]#



[root@mw-init ssl]# kubectl get pv pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7 pvc-e60fb453-a0ae-443b-9471-19cfea46c133 pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb pvc-b58c074a-3ebd-4749-b8ab-6966276af34b pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE     VOLUMEMODE
pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-0       intceph                 5m      Filesystem
pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-1       intceph                 5m      Filesystem
pvc-e60fb453-a0ae-443b-9471-19cfea46c133   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-kafka-2       intceph                 5m      Filesystem
pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-0   intceph                 5m54s   Filesystem
pvc-b58c074a-3ebd-4749-b8ab-6966276af34b   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-1   intceph                 5m54s   Filesystem
pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc   10Gi       RWO            Delete           Bound    kafka/data-my-cluster-zookeeper-2   intceph                 5m54s   Filesystem
[root@mw-init ssl]#


修改
pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf
pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7
pvc-e60fb453-a0ae-443b-9471-19cfea46c133
pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb
pvc-b58c074a-3ebd-4749-b8ab-6966276af34b
pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc


Retain

[root@mw-init ssl]# kubectl get pv pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7 pvc-e60fb453-a0ae-443b-9471-19cfea46c133 pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb pvc-b58c074a-3ebd-4749-b8ab-6966276af34b pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE     VOLUMEMODE
pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-0       intceph                 9m2s    Filesystem
pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-1       intceph                 9m2s    Filesystem
pvc-e60fb453-a0ae-443b-9471-19cfea46c133   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-kafka-2       intceph                 9m2s    Filesystem
pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-0   intceph                 9m56s   Filesystem
pvc-b58c074a-3ebd-4749-b8ab-6966276af34b   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-1   intceph                 9m56s   Filesystem
pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc   10Gi       RWO            Retain           Bound    kafka/data-my-cluster-zookeeper-2   intceph                 9m56s   Filesystem
[root@mw-init ssl]#


备份 pvc

data-my-cluster-kafka-0
data-my-cluster-kafka-1
data-my-cluster-kafka-2
data-my-cluster-zookeeper-0
data-my-cluster-zookeeper-1
data-my-cluster-zookeeper-2


[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-kafka-0 -o yaml
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
  volumeName: pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf


[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-kafka-1 -o yaml
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
  volumeName: pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7


[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-kafka-2 -o yaml
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
  volumeName: pvc-e60fb453-a0ae-443b-9471-19cfea46c133



[root@mw-init ssl]#

[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-zookeeper-0 -o yaml
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
  volumeName: pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb


[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-zookeeper-1 -o yaml
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
  volumeName: pvc-b58c074a-3ebd-4749-b8ab-6966276af34b


[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get pvc data-my-cluster-zookeeper-2 -o yaml
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
  volumeName: pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc


[root@mw-init ssl]#
[root@mw-init ssl]#

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=hpO9TcK4R2KC
ssl.endpoint.identification.algorithm=

ssl.keystore.location=./user-keystore.jks
ssl.keystore.password=rPXqfQbGqHM6
ssl.key.password=rPXqfQbGqHM6
EOF

[root@mw-init ssl]# kafka-topics.sh --bootstrap-server 10.0.128.237:30609 --command-config ./client-ssl.properties --list
my-topic
[root@mw-init ssl]#

[root@mw-init ssl]# kafka-producer-perf-test.sh --num-records 500 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=10.0.128.237:30609 --producer.config ./client-ssl.properties
500 records sent, 551.876380 records/sec (0.53 MB/sec), 320.75 ms avg latency, 613.00 ms max latency, 319 ms 50th, 438 ms 95th, 440 ms 99th, 613 ms 99.9th.
[root@mw-init ssl]#


[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:30609 --topic my-topic --producer.config ./client-ssl.properties
>hello1
>hello2
>hello3
>hello4
>


[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:30647 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello4
hello1
hello3
hello2


[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30647 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          -               176             -               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        1          -               192             -               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        2          -               132             -               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1

[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30609 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          176             176             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        1          192             192             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        2          132             132             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
[root@mw-init ssl]#

[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30609 --command-config ./client-ssl.properties --describe --group my-group
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          176             176             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        1          192             192             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
my-group        my-topic        2          132             132             0               consumer-my-group-1-4b067430-fd88-4cfb-b4a2-6345298f33cb /10.0.128.64    consumer-my-group-1
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


[root@mw-init ssl]# kubectl -n kafka get pvc
No resources found in kafka namespace.
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl get pv pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7 pvc-e60fb453-a0ae-443b-9471-19cfea46c133 pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb pvc-b58c074a-3ebd-4749-b8ab-6966276af34b pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                               STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-0       intceph                 35m   Filesystem
pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-1       intceph                 35m   Filesystem
pvc-e60fb453-a0ae-443b-9471-19cfea46c133   10Gi       RWO            Retain           Released   kafka/data-my-cluster-kafka-2       intceph                 35m   Filesystem
pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-0   intceph                 36m   Filesystem
pvc-b58c074a-3ebd-4749-b8ab-6966276af34b   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-1   intceph                 36m   Filesystem
pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc   10Gi       RWO            Retain           Released   kafka/data-my-cluster-zookeeper-2   intceph                 36m   Filesystem
[root@mw-init ssl]#
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
  volumeName: pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf

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
  volumeName: pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7

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
  volumeName: pvc-e60fb453-a0ae-443b-9471-19cfea46c133

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
  volumeName: pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb

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
  volumeName: pvc-b58c074a-3ebd-4749-b8ab-6966276af34b

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
  volumeName: pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc



修改
pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf
pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7
pvc-e60fb453-a0ae-443b-9471-19cfea46c133
pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb
pvc-b58c074a-3ebd-4749-b8ab-6966276af34b
pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc


[root@mw-init ssl]# kubectl -n kafka get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-my-cluster-kafka-0       Bound    pvc-2e59d519-7b60-41c5-8f7d-364100a14eaf   10Gi       RWO            intceph        7m46s
data-my-cluster-kafka-1       Bound    pvc-a9849088-1acd-48e3-bdcf-1c0240a861b7   10Gi       RWO            intceph        7m46s
data-my-cluster-kafka-2       Bound    pvc-e60fb453-a0ae-443b-9471-19cfea46c133   10Gi       RWO            intceph        7m46s
data-my-cluster-zookeeper-0   Bound    pvc-2d8edad7-cef1-46e0-99e0-24e4c2fbcfbb   10Gi       RWO            intceph        7m46s
data-my-cluster-zookeeper-1   Bound    pvc-b58c074a-3ebd-4749-b8ab-6966276af34b   10Gi       RWO            intceph        7m46s
data-my-cluster-zookeeper-2   Bound    pvc-415cb469-1de5-4ca5-9622-8f251b6ce1fc   10Gi       RWO            intceph        7m46s
[root@mw-init ssl]#
[root@mw-init ssl]#

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


恢复 kafka 集群


[root@mw-init ssl]# kubectl -n kafka get kafkatopic
NAME                                                          PARTITIONS   REPLICATION FACTOR
consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a   50           3
[root@mw-init ssl]#


root@mw-init ssl]# kafka-topics.sh --bootstrap-server 10.0.128.237:30647 --command-config ./client-ssl.properties --list
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.truststore.location' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.keystore.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.key.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.keystore.location' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.truststore.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:32:06,341] WARN The configuration 'ssl.endpoint.identification.algorithm' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
__consumer_offsets
my-topic
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30647 --command-config ./client-ssl.properties --describe --group my-group
[2020-10-22 15:33:06,652] WARN The configuration 'ssl.truststore.location' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:33:06,653] WARN The configuration 'ssl.keystore.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:33:06,653] WARN The configuration 'ssl.key.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:33:06,653] WARN The configuration 'ssl.keystore.location' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:33:06,653] WARN The configuration 'ssl.truststore.password' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
[2020-10-22 15:33:06,653] WARN The configuration 'ssl.endpoint.identification.algorithm' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          0               0               0               consumer-my-group-1-ce861df6-e32e-4ced-ae3f-e49f5a303b3e /10.0.129.171   consumer-my-group-1
my-group        my-topic        1          0               0               0               consumer-my-group-1-ce861df6-e32e-4ced-ae3f-e49f5a303b3e /10.0.129.171   consumer-my-group-1
my-group        my-topic        2          0               0               0               consumer-my-group-1-ce861df6-e32e-4ced-ae3f-e49f5a303b3e /10.0.129.171   consumer-my-group-1
[root@mw-init ssl]#





kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30609 --command-config ./client-ssl.properties --list
kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30609 --command-config ./client-ssl.properties --describe --group my-group

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



