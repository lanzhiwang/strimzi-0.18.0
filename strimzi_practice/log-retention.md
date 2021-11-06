


```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster-local
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
      log.cleanup.policy: delete
      log.retention.hours: 1
      log.retention.minutes: 60
      log.retention.ms: 3600000
      log.roll.hours: 1
      log.roll.ms: 3600000
      segment.bytes: 10000000
      log.segment.bytes: 0000000
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: persistent-claim
      size: 3Gi
      class: top
      deleteClaim: true
    template:
      pod:
        securityContext:
          runAsUser: 0
          fsGroup: 0
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 3Gi
      class: top
      deleteClaim: true
  entityOperator:
    topicOperator: {}
    userOperator: {}



```

