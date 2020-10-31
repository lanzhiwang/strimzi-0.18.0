



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

```

验证 my-user 用户是否有授权

```bash
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash


$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
F6ktzoBQOIXJ

$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
HOvapt6PU1nh

$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=F6ktzoBQOIXJ

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=HOvapt6PU1nh
ssl.key.password=HOvapt6PU1nh
EOF

kubectl -n kafka cp client-ssl.properties kafka-test:/home/kafka/
kubectl -n kafka cp user-keystore.jks kafka-test:/home/kafka/
kubectl -n kafka cp user-truststore.jks kafka-test:/home/kafka/


$ /opt/kafka/bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --command-config ./client-ssl.properties --list

$ /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --producer.config ./client-ssl.properties

$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group --consumer-property client.id=my-group-client-1

$ /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --command-config ./client-ssl.properties --describe --group my-group


```




```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
spec:
  version: 2.5.0
  replicas: 1
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
  config:
    group.id: my-group
    offset.storage.topic: connect-cluster-offsets
    config.storage.topic: connect-cluster-configs
    status.storage.topic: connect-cluster-status

```

验证：

```bash
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connectors
[]

$ curl -i -X POST -H "Content-type: application/json" -d '{"name": "test-file-source", "config": {"connector.class": "FileStreamSource", "tasks.max": 1, "file": "/opt/kafka/LICENSE", "topic": "my-topic"}}' http://my-connect-cluster-connect-api:8083/connectors

$ curl -i -X POST -H "Content-type: application/json" -d '{"name": "test-file-sink", "config": {"connector.class": "FileStreamSink", "tasks.max": 1, "file": "/home/kafka/LICENSE", "topics": "my-topic"}}' http://my-connect-cluster-connect-api:8083/connectors

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connectors
["test-file-source","test-file-sink"]

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connectors/test-file-source/status
{"name":"test-file-source","connector":{"state":"RUNNING","worker_id":"10.199.3.84:8083"},"tasks":[{"id":0,"state":"RUNNING","worker_id":"10.199.3.84:8083"}],"type":"source"}

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connectors/test-file-sink/status
{"name":"test-file-sink","connector":{"state":"RUNNING","worker_id":"10.199.3.84:8083"},"tasks":[{"id":0,"state":"FAILED","worker_id":"10.199.3.84:8083","trace":"org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: connect-test-file-sink\n"}],"type":"sink"}

curl -s -X DELETE http://my-connect-cluster-connect-api:8083/connectors/test-file-source
curl -s -X DELETE http://my-connect-cluster-connect-api:8083/connectors/test-file-sink

```















```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
  annotations:
    strimzi.io/use-connector-resources: "true"
spec:
  version: 2.5.0
  replicas: 1
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
  config:
    group.id: my-group
    offset.storage.topic: connect-cluster-offsets
    config.storage.topic: connect-cluster-configs
    status.storage.topic: connect-cluster-status

---

apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaConnector
metadata:
  name: my-source-connector
  labels:
    strimzi.io/cluster: my-connect-cluster
spec:
  class: org.apache.kafka.connect.file.FileStreamSourceConnector
  tasksMax: 2
  config:
    file: "/home/kafka/source"
    topic: my-topic

---

apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaConnector
metadata:
  name: my-sink-connector
  labels:
    strimzi.io/cluster: my-connect-cluster
spec:
  class: org.apache.kafka.connect.file.FileStreamSinkConnector
  tasksMax: 2
  config:
    file: "/home/kafka/sink"
    topics: my-topic

```







```bash


$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
SJ02vgvlvttH

$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
wpP7p2fPqkRV

$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=SJ02vgvlvttH

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=wpP7p2fPqkRV
ssl.key.password=wpP7p2fPqkRV
EOF

$ kubectl -n kafka cp client-ssl.properties kafka-test:/home/kafka/
$ kubectl -n kafka cp user-keystore.jks kafka-test:/home/kafka/
$ kubectl -n kafka cp user-truststore.jks kafka-test:/home/kafka/

/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group



```

