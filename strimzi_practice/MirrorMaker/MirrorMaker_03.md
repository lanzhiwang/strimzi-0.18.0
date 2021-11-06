https://cloud.tencent.com/developer/article/1530716
https://blog.csdn.net/weixin_48182198/article/details/112562573



```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
metadata:
  name: my-mirror-maker
spec:
  replicas:
  image:
  whitelist:
  resources:
  affinity:
  tolerations:
  jvmOptions:
  logging:
  metrics:
  tracing:
  template:
  livenessProbe:
  readinessProbe:
  version:
  #
  consumer:
    numStreams: Specifies the number of consumer stream threads to create.
    offsetCommitInterval: Specifies the offset auto-commit interval in ms. Default value is 60000.
    groupId:
    bootstrapServers:
    authentication:
    config: "The MirrorMaker consumer config. Properties with the following prefixes cannot be set: ssl., bootstrap.servers, group.id, sasl., security., interceptor.classes (with the exception of: ssl.endpoint.identification.algorithm, ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols)."
    tls:
  producer:
    bootstrapServers:
    abortOnSendFailure: Flag to set the MirrorMaker to exit on a failed send. Default value is true.
    authentication:
    config: "The MirrorMaker producer config. Properties with the following prefixes cannot be set: ssl., bootstrap.servers, sasl., security., interceptor.classes (with the exception of: ssl.endpoint.identification.algorithm, ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols)."
    tls:

---

apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaMirrorMaker2
metadata:
  name: my-mm2-cluster
spec:
  replicas:
  version: The Kafka Connect version. Defaults to 2.5.0. Consult the user documentation to understand the process required to upgrade or downgrade the version.
  image:
  resources:
  livenessProbe:
  readinessProbe:
  jvmOptions:
  affinity:
  tolerations:
  logging:
  metrics:
  tracing:
  template:
  #
  connectCluster:
  clusters:
    - alias:
      bootstrapServers:
      config:
      tls:
      authentication:
  mirrors:
    - sourceCluster:
      targetCluster:
      sourceConnector:
        tasksMax:
        config:
        pause:
      checkpointConnector:
        tasksMax:
        config:
        pause:
      heartbeatConnector:
        tasksMax:
        config:
        pause:
      topicsPattern:
      topicsBlacklistPattern:
      groupsPattern:
      groupsBlacklistPattern:
  externalConfiguration:
    # Pass data from Secrets or ConfigMaps to the Kafka Connect pods and use them to configure connectors.
    env:
    volumes:


```

# 实践 KafkaMirrorMaker

## 源 kafka

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: source-kafka
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
      type: ephemeral
  zookeeper:
    replicas: 3
    jmxOptions:
      '-Xms': 4096m
      '-Xmx': 4096m
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
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: source-kafka
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824

---
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
metadata:
  name: my-mirror-maker
spec:
  replicas: 3
  version: 2.5.0
  consumer:
    bootstrapServers: source-kafka-kafka-bootstrap:9092
    groupId: my-group
    numStreams: 2
    offsetCommitInterval: 120000
    config:
      max.poll.records: 100
      receive.buffer.bytes: 32768
  producer:
    bootstrapServers: 10.0.129.27:32226
    abortOnSendFailure: false
    config:
      compression.type: gzip
      batch.size: 8192
  whitelist: my-topic
  resources:
    requests:
      cpu: "1"
      memory: 2Gi
    limits:
      cpu: "2"
      memory: 2Gi


----

$ cat /opt/kafka/kafka_mirror_maker_run.sh
#!/usr/bin/env bash
set +x

# Generate temporary keystore password
export CERTS_STORE_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)

# Create dir where keystores and truststores will be stored
mkdir -p /tmp/kafka

# Import certificates into keystore and truststore
# $1 = trusted certs, $2 = TLS auth cert, $3 = TLS auth key, $4 = truststore path, $5 = keystore path, $6 = certs and key path
./kafka_mirror_maker_tls_prepare_certificates.sh \
    "$KAFKA_MIRRORMAKER_TRUSTED_CERTS_CONSUMER" \
    "$KAFKA_MIRRORMAKER_TLS_AUTH_CERT_CONSUMER" \
    "$KAFKA_MIRRORMAKER_TLS_AUTH_KEY_CONSUMER" \
    "/tmp/kafka/consumer.truststore.p12" \
    "/tmp/kafka/consumer.keystore.p12" \
    "/opt/kafka/consumer-certs" \
    "/opt/kafka/consumer-oauth-certs" \
    "/tmp/kafka/consumer-oauth.keystore.p12"

./kafka_mirror_maker_tls_prepare_certificates.sh \
    "$KAFKA_MIRRORMAKER_TRUSTED_CERTS_PRODUCER" \
    "$KAFKA_MIRRORMAKER_TLS_AUTH_CERT_PRODUCER" \
    "$KAFKA_MIRRORMAKER_TLS_AUTH_KEY_PRODUCER" \
    "/tmp/kafka/producer.truststore.p12" \
    "/tmp/kafka/producer.keystore.p12" \
    "/opt/kafka/producer-certs" \
    "/opt/kafka/producer-oauth-certs" \
    "/tmp/kafka/producer-oauth.keystore.p12"

# Generate and print the consumer config file
echo "Kafka Mirror Maker consumer configuration:"
./kafka_mirror_maker_consumer_config_generator.sh | tee /tmp/strimzi-consumer.properties | sed -e 's/sasl.jaas.config=.*/sasl.jaas.config=[hidden]/g' -e 's/password=.*/password=[hidden]/g'
echo ""

# Generate and print the producer config file
echo "Kafka Mirror Maker producer configuration:"
./kafka_mirror_maker_producer_config_generator.sh | tee /tmp/strimzi-producer.properties | sed -e 's/sasl.jaas.config=.*/sasl.jaas.config=[hidden]/g' -e 's/password=.*/password=[hidden]/g'
echo ""

# Disable Kafka's GC logging (which logs to a file)...
export GC_LOG_ENABLED="false"

if [ -z "$KAFKA_LOG4J_OPTS" ]; then
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$KAFKA_HOME/custom-config/log4j.properties"
fi

# We don't need LOG_DIR because we write no log files, but setting it to a
# directory avoids trying to create it (and logging a permission denied error)
export LOG_DIR="$KAFKA_HOME"

# Enabling the Mirror Maker agent which monitors readiness / liveness
rm /tmp/mirror-maker-ready /tmp/mirror-maker-alive 2> /dev/null
export KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls $KAFKA_HOME/libs/mirror-maker-agent*.jar)=/tmp/mirror-maker-ready:/tmp/mirror-maker-alive:${STRIMZI_READINESS_PERIOD:-10}:${STRIMZI_LIVENESS_PERIOD:-10}"

# enabling Prometheus JMX exporter as Java agent
if [ "$KAFKA_MIRRORMAKER_METRICS_ENABLED" = "true" ]; then
  export KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls $KAFKA_HOME/libs/jmx_prometheus_javaagent*.jar)=9404:$KAFKA_HOME/custom-config/metrics-config.yml"
fi

# enabling Tracing agent (initializes Jaeger tracing) as Java agent
if [ "$STRIMZI_TRACING" = "jaeger" ]; then
  export KAFKA_OPTS="$KAFKA_OPTS -javaagent:$(ls $KAFKA_HOME/libs/tracing-agent*.jar)=jaeger"
fi

if [ -z "$KAFKA_HEAP_OPTS" -a -n "${DYNAMIC_HEAP_FRACTION}" ]; then
    . ./dynamic_resources.sh
    # Calculate a max heap size based some DYNAMIC_HEAP_FRACTION of the heap
    # available to a jvm using 100% of the GCroup-aware memory
    # up to some optional DYNAMIC_HEAP_MAX
    CALC_MAX_HEAP=$(get_heap_size ${DYNAMIC_HEAP_FRACTION} ${DYNAMIC_HEAP_MAX})
    if [ -n "$CALC_MAX_HEAP" ]; then
      export KAFKA_HEAP_OPTS="-Xms${CALC_MAX_HEAP} -Xmx${CALC_MAX_HEAP}"
    fi
fi

if [ -n "$KAFKA_MIRRORMAKER_WHITELIST" ]; then
    whitelist="--whitelist \""${KAFKA_MIRRORMAKER_WHITELIST}"\""
fi

if [ -n "$KAFKA_MIRRORMAKER_NUMSTREAMS" ]; then
    numstreams="--num.streams ${KAFKA_MIRRORMAKER_NUMSTREAMS}"
fi

if [ -n "$KAFKA_MIRRORMAKER_OFFSET_COMMIT_INTERVAL" ]; then
    offset_commit_interval="--offset.commit.interval.ms $KAFKA_MIRRORMAKER_OFFSET_COMMIT_INTERVAL"
fi

if [ -n "$KAFKA_MIRRORMAKER_ABORT_ON_SEND_FAILURE" ]; then
    abort_on_send_failure="--abort.on.send.failure $KAFKA_MIRRORMAKER_ABORT_ON_SEND_FAILURE"
fi

if [ -n "$KAFKA_MIRRORMAKER_MESSAGE_HANDLER" ]; then
    message_handler="--message.handler $KAFKA_MIRRORMAKER_MESSAGE_HANDLER"
fi

if [ -n "$KAFKA_MIRRORMAKER_MESSAGE_HANDLER_ARGS" ]; then
    message_handler_args="--message.handler.args \""${$KAFKA_MIRRORMAKER_MESSAGE_HANDLER_ARGS}"\""
fi

if [ -n "$STRIMZI_JAVA_SYSTEM_PROPERTIES" ]; then
    export KAFKA_OPTS="${KAFKA_OPTS} ${STRIMZI_JAVA_SYSTEM_PROPERTIES}"
fi

. ./set_kafka_gc_options.sh

# starting Kafka Mirror Maker with final configuration
exec $KAFKA_HOME/bin/kafka-mirror-maker.sh \
--consumer.config /tmp/strimzi-consumer.properties \
--producer.config /tmp/strimzi-producer.properties \
$whitelist \
$numstreams \
$offset_commit_interval \
$abort_on_send_failure \
$message_handler \
$message_handler_args


java
-Xms1911260446
-Xmx1911260446
-server
-XX:+UseG1GC
-XX:MaxGCPauseMillis=20
-XX:InitiatingHeapOccupancyPercent=35
-XX:+ExplicitGCInvokesConcurrent
-XX:MaxInlineLevel=15
-Djava.awt.headless=true
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dkafka.logs.dir=/opt/kafka
-Dlog4j.configuration=file:/opt/kafka/custom-config/log4j.properties
-cp /opt/kafka/bin/../libs/activation-1.1.1.jar:
    /opt/kafka/bin/../libs/annotations-13.0.jar:
    ......
    /opt/kafka/bin/../libs/zstd-jni-1.4.4-7.jar
-javaagent:/opt/kafka/libs/mirror-maker-agent.jar=/tmp/mirror-maker-ready:/tmp/mirror-maker-alive:10:10
kafka.tools.MirrorMaker
--consumer.config /tmp/strimzi-consumer.properties
--producer.config /tmp/strimzi-producer.properties
--whitelist "my-topic"
--num.streams 2
--offset.commit.interval.ms 120000
--abort.on.send.failure false




```

## 目标 kafka

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: destination-kafka
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
      type: ephemeral
  zookeeper:
    replicas: 3
    jmxOptions:
      '-Xms': 4096m
      '-Xmx': 4096m
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



```



# 实践 KafkaMirrorMaker2


```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaMirrorMaker2
metadata:
  name: my-mm2-cluster
spec:
  version: 2.5.0
  replicas: 1
  connectCluster: "my-cluster-target"
  clusters:
  - alias: "my-cluster-source"
    bootstrapServers: source-kafka-kafka-bootstrap:9092
  - alias: "my-cluster-target"
    bootstrapServers: 10.0.129.27:31587
    config:
      config.storage.replication.factor: 1
      offset.storage.replication.factor: 1
      status.storage.replication.factor: 1
  mirrors:
  - sourceCluster: "my-cluster-source"
    targetCluster: "my-cluster-target"
    sourceConnector:
      config:
        replication.factor: 1
        offset-syncs.topic.replication.factor: 1
        sync.topic.acls.enabled: "false"
    heartbeatConnector:
      config:
        heartbeats.topic.replication.factor: 1
    checkpointConnector:
      config:
        checkpoints.topic.replication.factor: 1
    topicsPattern: my-topic
    groupsPattern: ".*"



$ cat /opt/kafka/kafka_mirror_maker_2_run.sh

./kafka_mirror_maker_2_connector_config_generator.sh | tee /tmp/strimzi-mirrormaker2-connector.properties | sed -e 's/sasl.jaas.config=.*/sasl.jaas.config=[hidden]/g' -e 's/password=.*/password=[hidden]/g'

exec ./kafka_connect_run.sh


$ cat /opt/kafka/kafka_connect_run.sh

./kafka_connect_config_generator.sh | tee /tmp/strimzi-connect.properties | sed -e 's/sasl.jaas.config=.*/sasl.jaas.config=[hidden]/g' -e 's/password=.*/password=[hidden]/g'

exec /usr/bin/tini -w -e 143 -- sh -c "${KAFKA_HOME}/bin/connect-distributed.sh /tmp/strimzi-connect.properties"


java
-Xms128M
-server
-XX:+UseG1GC
-XX:MaxGCPauseMillis=20
-XX:InitiatingHeapOccupancyPercent=35
-XX:+ExplicitGCInvokesConcurrent
-XX:MaxInlineLevel=15
-Djava.awt.headless=true
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dkafka.logs.dir=/opt/kafka
-Dlog4j.configuration=file:/opt/kafka/custom-config/log4j.properties
-cp /opt/kafka/bin/../libs/activation-1.1.1.jar:
    ......
    /opt/kafka/bin/../libs/zookeeper-jute-3.5.7.jar:
    /opt/kafka/bin/../libs/zstd-jni-1.4.4-7.jar
org.apache.kafka.connect.cli.ConnectDistributed
/tmp/strimzi-connect.properties


$ cat /tmp/strimzi-connect.properties
# Bootstrap servers
bootstrap.servers=10.0.129.27:31587
# REST Listeners
rest.port=8083
rest.advertised.host.name=10.199.0.149
rest.advertised.port=8083
# Plugins
plugin.path=/opt/kafka/plugins
# Provided configuration
config.storage.topic=mirrormaker2-cluster-configs
group.id=mirrormaker2-cluster
status.storage.topic=mirrormaker2-cluster-status
config.providers.file.class=org.apache.kafka.common.config.provider.FileConfigProvider
offset.storage.topic=mirrormaker2-cluster-offsets
config.providers=file
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter
config.storage.replication.factor=1
offset.storage.replication.factor=1
status.storage.replication.factor=1


security.protocol=PLAINTEXT
producer.security.protocol=PLAINTEXT
consumer.security.protocol=PLAINTEXT
admin.security.protocol=PLAINTEXT


$ curl -s -X GET -H "Content-Type: application/json" http://my-mm2-cluster-mirrormaker2-api:8083/connector-plugins
[
    {"class":"org.apache.kafka.connect.file.FileStreamSinkConnector","type":"sink","version":"2.5.0"},
    {"class":"org.apache.kafka.connect.file.FileStreamSourceConnector","type":"source","version":"2.5.0"},
    {"class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector","type":"source","version":"1"},
    {"class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector","type":"source","version":"1"},
    {"class":"org.apache.kafka.connect.mirror.MirrorSourceConnector","type":"source","version":"1"}
]



$ curl -s -X GET -H "Content-Type: application/json" http://my-mm2-cluster-mirrormaker2-api:8083/connectors
[
    "my-cluster-source->my-cluster-target.MirrorHeartbeatConnector",
    "my-cluster-source->my-cluster-target.MirrorSourceConnector",
    "my-cluster-source->my-cluster-target.MirrorCheckpointConnector"
]



$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorHeartbeatConnector/status"
{
    "name":"my-cluster-source->my-cluster-target.MirrorHeartbeatConnector",
    "connector":{"state":"RUNNING","worker_id":"10.199.0.149:8083"},
    "tasks":[
        {"id":0,"state":"RUNNING","worker_id":"10.199.0.149:8083"}
    ],
    "type":"source"
}


$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorSourceConnector/status"
{
    "name":"my-cluster-source->my-cluster-target.MirrorSourceConnector",
    "connector":{"state":"RUNNING","worker_id":"10.199.0.149:8083"},
    "tasks":[
        {"id":0,"state":"RUNNING","worker_id":"10.199.0.149:8083"}
    ],
    "type":"source"
}


$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorCheckpointConnector/status"
{
    "name":"my-cluster-source->my-cluster-target.MirrorCheckpointConnector",
    "connector":{"state":"RUNNING","worker_id":"10.199.0.149:8083"},
    "tasks":[],
    "type":"source"
}


$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorHeartbeatConnector/config"
{
    "target.cluster.status.storage.replication.factor":"1",
    "target.cluster.offset.storage.replication.factor":"1",
    "connector.class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector",
    "target.cluster.alias":"my-cluster-target",
    "topics":"my-topic",
    "heartbeats.topic.replication.factor":"1",
    "target.cluster.config.storage.replication.factor":"1",
    "source.cluster.alias":"my-cluster-source",
    "name":"my-cluster-source->my-cluster-target.MirrorHeartbeatConnector",
    "target.cluster.bootstrap.servers":"10.0.129.27:30400",
    "groups":".*",
    "source.cluster.bootstrap.servers":"source-kafka-kafka-bootstrap:9092"
}


$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorSourceConnector/config"
{
    "target.cluster.status.storage.replication.factor":"1",
    "connector.class":"org.apache.kafka.connect.mirror.MirrorSourceConnector",
    "offset-syncs.topic.replication.factor":"1",
    "replication.factor":"1",
    "sync.topic.acls.enabled":"false",
    "topics":"my-topic",
    "target.cluster.config.storage.replication.factor":"1",
    "source.cluster.alias":"my-cluster-source",
    "groups":".*",
    "source.cluster.bootstrap.servers":"source-kafka-kafka-bootstrap:9092",
    "target.cluster.offset.storage.replication.factor":"1",
    "target.cluster.alias":"my-cluster-target",
    "name":"my-cluster-source->my-cluster-target.MirrorSourceConnector",
    "target.cluster.bootstrap.servers":"10.0.129.27:30400"
}


$ curl -s -X GET -H "Content-Type: application/json" "http://my-mm2-cluster-mirrormaker2-api:8083/connectors/my-cluster-source->my-cluster-target.MirrorCheckpointConnector/config"
{
    "target.cluster.status.storage.replication.factor":"1",
    "target.cluster.offset.storage.replication.factor":"1",
    "connector.class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector",
    "target.cluster.alias":"my-cluster-target",
    "topics":"my-topic",
    "target.cluster.config.storage.replication.factor":"1",
    "source.cluster.alias":"my-cluster-source",
    "name":"my-cluster-source->my-cluster-target.MirrorCheckpointConnector",
    "target.cluster.bootstrap.servers":"10.0.129.27:30400",
    "groups":".*",
    "checkpoints.topic.replication.factor":"1",
    "source.cluster.bootstrap.servers":"source-kafka-kafka-bootstrap:9092"
}







```









