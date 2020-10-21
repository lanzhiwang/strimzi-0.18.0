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





```



验证结果：



```bash
cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=./user-truststore.jks
ssl.truststore.password=u0knY9zACqci
ssl.endpoint.identification.algorithm=

ssl.keystore.location=./user-keystore.jks
ssl.keystore.password=mRTxo6kS81kN
ssl.key.password=mRTxo6kS81kN
EOF

[root@mw-init ssl]# kafka-console-producer.sh --bootstrap-server 10.0.128.237:32090 --topic my-topic --producer.config ./client-ssl.properties
>hello1
>hello2
>hello3
>hello4
>


[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:32090 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello4
hello1
hello3
hello2





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



