```yaml

apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-kafka
  namespace: hz-kafka
spec:
  entityOperator:
    topicOperator:
      resources:
        limits:
        requests:
    userOperator:
      resources:
        limits:
        requests:
  kafka:
    livenessProbe:
      failureThreshold: 10
      initialDelaySeconds: 300
      periodSeconds: 300
      successThreshold: 1
      timeoutSeconds: 300
    readinessProbe:
      failureThreshold: 10
      initialDelaySeconds: 300
      periodSeconds: 300
      successThreshold: 1
      timeoutSeconds: 300    
    template:
      pod:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: kafka
                  strimzi.io/cluster: my-kafka
                  strimzi.io/kind: Kafka
                  strimzi.io/name: my-kafka-kafka
    config:
      log.message.format.version: '2.5'
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
    jmxOptions:
      '-Xms': 8192m
      '-Xmx': 8192m
    listeners:
      external:
        tls: false
        type: nodeport
      plain: {}
      tls: {}
    replicas: 5
    resources:
      limits:
        cpu: '1'
        memory: 1Gi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral
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
    version: 2.5.0
  zookeeper:
    template:
      pod:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: zookeeper
                  strimzi.io/cluster: my-kafka
                  strimzi.io/kind: Kafka
                  strimzi.io/name: my-kafka-zookeeper
    jmxOptions:
      '-Xms': 4096m
      '-Xmx': 4096m
    replicas: 5
    resources:
      limits:
        cpu: '1'
        memory: 1000Mi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral
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






---

apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
  namespace: operators
spec:
  kafka:
    replicas:
    image:
    storage:
    listeners:
    authorization:
    config:
    rack:
    brokerRackInitImage:
    affinity:
    tolerations:
    livenessProbe:
    readinessProbe:
    jvmOptions:
    jmxOptions:
    resources:
    metrics:
    logging:
    tlsSidecar:
    template:
      statefulset:
        metadata:
          labels:
          annotations:
        podManagementPolicy:
      pod:
        metadata:
        imagePullSecrets:
        securityContext:
        terminationGracePeriodSeconds:
        affinity:
        priorityClassName:
        schedulerName:
        tolerations:  
      bootstrapService:
        metadata:
          labels:
          annotations:
      brokersService:
      externalBootstrapService:
      perPodService:
      externalBootstrapRoute:
      perPodRoute:
      externalBootstrapIngress:
      perPodIngress:
      persistentVolumeClaim:
      podDisruptionBudget:
      kafkaContainer:
      tlsSidecarContainer:
      initContainer:  
    version:
  zookeeper:
  topicOperator:
  entityOperator:
  # 集群证书颁发机构的配置。
  clusterCa:
    # 如果为 true，则证书颁发机构证书将自动生成。 否则，用户将需要提供带有 CA 证书的 Secret。 默认为真。
    generateCertificateAuthority:
    # 生成的证书应有效的天数。 默认值为 365。
    validityDays:
    # 证书续订期内的天数。 这是证书到期前可以执行续订操作的天数。 
    # 当 generateCertificateAuthority 为 true 时，这将导致生成新证书。
    # 当 generateCertificateAuthority 为 true 时，这将导致在 WARN 级别对挂起的证书到期进行额外的日志记录。 默认值为 30。
    renewalDays:
    # 当 generateCertificateAuthority=true 时，CA 证书过期应该如何处理。 默认情况下，使用现有私钥生成新的 CA 证书。
    certificateExpirationPolicy:
  # 客户端证书颁发机构的配置。
  clientsCa:
  cruiseControl:
  jmxTrans:
  kafkaExporter:
  maintenanceTimeWindows:





```

