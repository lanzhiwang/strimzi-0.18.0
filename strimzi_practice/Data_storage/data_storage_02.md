```
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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-cpaas-system-kafka-0

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-cpaas-system-kafka-0
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/broker-0
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem


-----------------------------------------------------------------------------------------------






data-my-cluster-kafka-0
data-my-cluster-kafka-1
data-my-cluster-kafka-2
data-my-cluster-zookeeper-0
data-my-cluster-zookeeper-1
data-my-cluster-zookeeper-2


pv-data-my-cluster-kafka-0
pv-data-my-cluster-kafka-1
pv-data-my-cluster-kafka-2
pv-data-my-cluster-zookeeper-0
pv-data-my-cluster-zookeeper-1
pv-data-my-cluster-zookeeper-2




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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-kafka-0

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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-kafka-1

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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-kafka-2

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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-zookeeper-0

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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-zookeeper-1

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
      storage: 1Gi
  storageClassName: ""
  volumeMode: Filesystem
  volumeName: pv-data-my-cluster-zookeeper-2


-----------------------------------------------------------

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-kafka-0
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/broker-0
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-kafka-1
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/broker-1
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-kafka-2
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/broker-2
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-zookeeper-0
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/zookeeper-0
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-zookeeper-1
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/zookeeper-1
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem


---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data-my-cluster-zookeeper-2
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /cpaas/test/zookeeper-2
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 10.0.132.0
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem



-----------------------------------------------------------


apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
  namespace: kafka
spec:
  entityOperator:
    topicOperator: {}
    userOperator: {}
  kafka:
    config:
      log.message.format.version: '2.5'
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
    jmxOptions: {}
    listeners:
      external:
        tls: false
        type: nodeport
      plain: {}
      tls: {}
    replicas: 3
    storage:
      class: ""
      deleteClaim: true
      size: 1Gi
      type: persistent-claim
    version: 2.5.0
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0
  zookeeper:
    replicas: 3
    storage:
      class: ""
      deleteClaim: true
      size: 1Gi
      type: persistent-claim
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0


-----------------------------------------------------------


kafka-producer-perf-test.sh --num-records 500 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=10.0.132.141:30357

kafka-console-consumer.sh --bootstrap-server 10.0.132.141:30357 --topic my-topic --from-beginning --group my-group







```

