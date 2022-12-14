



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
    jmxOptions:
      '-Xms': 8192m
      '-Xmx': 8192m
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1Gi
        cpu: '1'
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
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1000Mi
        cpu: '1'
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
$ kubectl -n kafka run kafka-test -ti --image=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0-v3.4.0 --rm=true --restart=Never bash


$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
XGQXL8n4zRFT

$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
GAbgozR2VClP

$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12

cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=XGQXL8n4zRFT

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=GAbgozR2VClP
ssl.key.password=GAbgozR2VClP
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

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
spec:
  replicas: The number of pods in the Kafka Connect group. | integer
  version: The Kafka Connect version. Defaults to 2.5.0. 
           Consult the user documentation to understand the process required to 
           upgrade or downgrade the version.
  image: The docker image for the pods.
  bootstrapServers: Bootstrap servers to connect to. 
                    This should be given as a comma separated list of <hostname>:<port> pairs.
  tls: TLS configuration.
  authentication: Authentication configuration for Kafka Connect. 
                  The type depends on the value of the authentication.type property within the given object, 
                  which must be one of [tls, scram-sha-512, plain, oauth].
  config: The Kafka Connect configuration. Properties with the following prefixes cannot be set: 
          ssl., 
          sasl., 
          security., 
          listeners, 
          plugin.path, 
          rest., 
          bootstrap.servers, 
          consumer.interceptor.classes, 
          producer.interceptor.classes 
          (with the exception of: 
          ssl.endpoint.identification.algorithm, 
          ssl.cipher.suites, 
          ssl.protocol, 
          ssl.enabled.protocols).
  resources: The maximum limits for CPU and memory resources and the requested initial resources.
  livenessProbe: Pod liveness checking.
  readinessProbe: Pod readiness checking.
  jvmOptions: JVM Options for pods.
  affinity:
  tolerations:
  logging:
  metrics:
  tracing:
  template: Template for Kafka Connect and Kafka Connect S2I resources. 
            The template allows users to specify how the Deployment, Pods and Service are generated.
  externalConfiguration: Pass data from Secrets or ConfigMaps to the Kafka Connect 
                         pods and use them to configure connectors.

```

验证：

```bash
$ kubectl -n kafka run kafka-test -ti --image=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0-v3.4.0 --rm=true --restart=Never bash

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/
{"version":"2.5.0","commit":"66563e712b0b9f84","kafka_cluster_id":"AyNHc5HMTqCZ5a8GDbTuBA"}

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connector-plugins
[{"class":"org.apache.kafka.connect.file.FileStreamSinkConnector","type":"sink","version":"2.5.0"},{"class":"org.apache.kafka.connect.file.FileStreamSourceConnector","type":"source","version":"2.5.0"},{"class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector","type":"source","version":"1"},{"class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector","type":"source","version":"1"},{"class":"org.apache.kafka.connect.mirror.MirrorSourceConnector","type":"source","version":"1"}]

$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connectors
[]

$ curl -i -X POST -H "Content-type: application/json" -d '{"name": "test-file-source", "config": {"connector.class": "FileStreamSource", "tasks.max": 1, "file": "/opt/kafka/LICENSE", "topic": "my-topic"}}' http://my-connect-cluster-connect-api:8083/connectors
HTTP/1.1 201 Created
Date: Wed, 31 Mar 2021 06:44:09 GMT
Location: http://my-connect-cluster-connect-api:8083/connectors/test-file-source
Content-Type: application/json
Content-Length: 191
Server: Jetty(9.4.24.v20191120)

{"name":"test-file-source","config":{"connector.class":"FileStreamSource","tasks.max":"1","file":"/opt/kafka/LICENSE","topic":"my-topic","name":"test-file-source"},"tasks":[],"type":"source"}


$ curl -i -X POST -H "Content-type: application/json" -d '{"name": "test-file-sink", "config": {"connector.class": "FileStreamSink", "tasks.max": 1, "file": "/home/kafka/LICENSE", "topics": "my-topic"}}' http://my-connect-cluster-connect-api:8083/connectors
HTTP/1.1 201 Created
Date: Wed, 31 Mar 2021 06:45:20 GMT
Location: http://my-connect-cluster-connect-api:8083/connectors/test-file-sink
Content-Type: application/json
Content-Length: 185
Server: Jetty(9.4.24.v20191120)

{"name":"test-file-sink","config":{"connector.class":"FileStreamSink","tasks.max":"1","file":"/home/kafka/LICENSE","topics":"my-topic","name":"test-file-sink"},"tasks":[],"type":"sink"}

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
    file: /opt/kafka/LICENSE
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
    file: /home/kafka/sink
    topics: my-topic

```







