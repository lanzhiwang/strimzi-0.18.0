```yaml
# 创建 Kafka 集群的 yaml 文件
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
      tls:
        authentication:
          type: tls
    authorization:
      type: simple
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

---

# 创建 KafkaUser 集群的 yaml 文件
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
      # topic my-topic
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
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-offsets
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-offsets
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-configs
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-configs
          patternType: literal
        operation: Write
        host: '*'

      # topic connect-cluster-status
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: topic
          name: connect-cluster-status
          patternType: literal
        operation: Write
        host: '*'

      # group
      - resource:
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'

      - resource:
          type: group
          name: connect-test-file-sink
          patternType: literal
        operation: Read
        host: '*'

      - resource:
          type: group
          name: connect-my-sink-connector
          patternType: literal
        operation: Read
        host: '*'

---

# 创建 KafkaTopic 集群的 yaml 文件
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

apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  replicas: 2
  bootstrapServers: my-cluster-kafka-bootstrap:9093
  tls:
    trustedCertificates:
    - secretName: my-cluster-cluster-ca-cert
      certificate: ca.crt
  authentication:
    type: tls
    certificateAndKey:
      secretName: my-user
      certificate: user.crt
      key: user.key
  http:
    port: 8080




```

验证：

```bash
kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

curl -i -X GET -H "Content-Type: application/json" http://my-bridge-bridge-service:8080/

3.1. GET /

3.2. POST /consumers/{groupid}

3.3. DELETE /consumers/{groupid}/instances/{name}

3.4. POST /consumers/{groupid}/instances/{name}/assignments

3.5. POST /consumers/{groupid}/instances/{name}/offsets

3.6. POST /consumers/{groupid}/instances/{name}/positions

3.7. POST /consumers/{groupid}/instances/{name}/positions/beginning

3.8. POST /consumers/{groupid}/instances/{name}/positions/end

3.9. GET /consumers/{groupid}/instances/{name}/records

3.10. POST /consumers/{groupid}/instances/{name}/subscription

3.11. GET /consumers/{groupid}/instances/{name}/subscription

3.12. DELETE /consumers/{groupid}/instances/{name}/subscription

3.13. GET /healthy

3.14. GET /openapi

3.15. GET /ready

3.16. GET /topics

3.17. POST /topics/{topicname}

3.18. GET /topics/{topicname}

3.19. GET /topics/{topicname}/partitions

3.20. POST /topics/{topicname}/partitions/{partitionid}

3.21. GET /topics/{topicname}/partitions/{partitionid}







```









```


```















3.1. GET /

3.2. POST /consumers/{groupid}

3.3. DELETE /consumers/{groupid}/instances/{name}

3.4. POST /consumers/{groupid}/instances/{name}/assignments

3.5. POST /consumers/{groupid}/instances/{name}/offsets

3.6. POST /consumers/{groupid}/instances/{name}/positions

3.7. POST /consumers/{groupid}/instances/{name}/positions/beginning

3.8. POST /consumers/{groupid}/instances/{name}/positions/end

3.9. GET /consumers/{groupid}/instances/{name}/records

3.10. POST /consumers/{groupid}/instances/{name}/subscription

3.11. GET /consumers/{groupid}/instances/{name}/subscription

3.12. DELETE /consumers/{groupid}/instances/{name}/subscription

3.13. GET /healthy

3.14. GET /openapi

3.15. GET /ready

3.16. GET /topics

3.17. POST /topics/{topicname}

3.18. GET /topics/{topicname}

3.19. GET /topics/{topicname}/partitions

3.20. POST /topics/{topicname}/partitions/{partitionid}

3.21. GET /topics/{topicname}/partitions/{partitionid}
