
```bash
$ vim manifests/redis-operator.v0.2.0.clusterserviceversion.yaml

$ git diff
diff --git a/manifests/redis-operator.v0.2.0.clusterserviceversion.yaml b/manifests/redis-operator.v0.2.0.clusterserviceversion.yaml
index 6348ab6..f6cb2b4 100644
--- a/manifests/redis-operator.v0.2.0.clusterserviceversion.yaml
+++ b/manifests/redis-operator.v0.2.0.clusterserviceversion.yaml
@@ -1,7 +1,7 @@
 apiVersion: operators.coreos.com/v1alpha1
 kind: ClusterServiceVersion
 metadata:
-  name: redis-operator.v0.2.0
+  name: redis-operator-test.v0.2.0
   namespace: placeholder
   annotations:
     alm-examples: >-
@@ -60,7 +60,7 @@ spec:

   maturity: alpha
   version: 0.2.0
-  replaces: redis-operator.v0.0.1
+  #replaces: redis-operator.v0.0.1
   skips: []
   minKubeVersion: 1.11.0
   keywords:

$ opm alpha bundle generate --directory ./manifests --package redis-operator-test.v0.2.0 --channels stable --default stable

$ docker build -t harbor.alauda.cn/operations/redis-manifest-bundle:5.0.0 -f bundle.Dockerfile .

$ docker push harbor.alauda.cn/operations/redis-manifest-bundle:5.0.0

$ opm index add --bundles harbor.alauda.cn/operations/redis-manifest-bundle:5.0.0 --tag harbor.alauda.cn/operations/redis-index:5.0.0 -p docker -u docker

$ docker push harbor.alauda.cn/operations/redis-index:5.0.0

$ kubectl create ns redis

$ cat << EOF > redis-manifests.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redis-catalog
  namespace: redis
spec:
  sourceType: grpc
  image: harbor.alauda.cn/operations/redis-index:5.0.0
  displayName: lanzhiwang-redis-index
  publisher: lanzhiwang.io
EOF

$ kubectl get catsrc --all-namespaces
NAMESPACE   NAME                    DISPLAY                  TYPE   PUBLISHER        AGE
olm         operatorhubio-catalog   Community Operators      grpc   OperatorHub.io   4h22m
redis       redis-catalog           lanzhiwang-redis-index   grpc   lanzhiwang.io    13m

$ kubectl get catsrc -n redis redis-catalog -o jsonpath={.status.connectionState.lastObservedState}
READY

$ kubectl -n redis get packagemanifests | grep redis
redis-operator-test.v0.2.0                 lanzhiwang-redis-index   64s
redis-enterprise                           Community Operators      9h
redis-operator                             Community Operators      9h

$ kubectl -n redis get packagemanifests redis-operator-test.v0.2.0 -o jsonpath='{.status.defaultChannel}'
stable


$ cat << EOF > redis-group.yaml
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: redis-group
  namespace: redis
spec:
  targetNamespaces:
  - redis

EOF


$ cat << EOF > redis-subscription.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redis-subscription
  namespace: redis 
spec:
  channel: stable
  name: redis-operator-test.v0.2.0
  source: redis-catalog
  sourceNamespace: redis

EOF

$ kubectl get og --all-namespaces
NAMESPACE   NAME               AGE
kafka       kafka-group        9h
olm         olm-operators      9h
operators   global-operators   9h
redis       redis-group        4m19s

$ kubectl get sub --all-namespaces
NAMESPACE   NAME                        PACKAGE                      SOURCE                  CHANNEL
kafka       my-strimzi-kafka-operator   strimzi-kafka-operator       operatorhubio-catalog   stable
redis       redis-subscription          redis-operator-test.v0.2.0   redis-catalog           stable

$ kubectl get ip --all-namespaces
NAMESPACE   NAME            CSV                                APPROVAL    APPROVED
kafka       install-n7tmr   strimzi-cluster-operator.v0.19.0   Manual      false
kafka       install-nczjj   strimzi-cluster-operator.v0.18.0   Manual      true
redis       install-wzbrf   redis-operator-test.v0.2.0         Automatic   true

$ kubectl get csv --all-namespaces
NAMESPACE   NAME                               DISPLAY          VERSION   REPLACES                           PHASE
kafka       strimzi-cluster-operator.v0.18.0   Strimzi          0.18.0    strimzi-cluster-operator.v0.17.0   Succeeded
olm         packageserver                      Package Server   0.16.1                                       Succeeded
redis       redis-operator-test.v0.2.0         Redis Operator   0.2.0                                        Succeeded

$ kubectl get crd
NAME                                          CREATED AT
catalogsources.operators.coreos.com           2020-12-10T01:36:13Z
clusterserviceversions.operators.coreos.com   2020-12-10T01:36:13Z
installplans.operators.coreos.com             2020-12-10T01:36:13Z
kafkabridges.kafka.strimzi.io                 2020-12-10T01:52:04Z
kafkaconnectors.kafka.strimzi.io              2020-12-10T01:52:03Z
kafkaconnects.kafka.strimzi.io                2020-12-10T01:52:04Z
kafkaconnects2is.kafka.strimzi.io             2020-12-10T01:52:03Z
kafkamirrormaker2s.kafka.strimzi.io           2020-12-10T01:52:03Z
kafkamirrormakers.kafka.strimzi.io            2020-12-10T01:52:03Z
kafkarebalances.kafka.strimzi.io              2020-12-10T01:52:05Z
kafkas.kafka.strimzi.io                       2020-12-10T01:52:05Z
kafkatopics.kafka.strimzi.io                  2020-12-10T01:52:03Z
kafkausers.kafka.strimzi.io                   2020-12-10T01:52:05Z
operatorgroups.operators.coreos.com           2020-12-10T01:36:13Z
operators.operators.coreos.com                2020-12-10T01:36:13Z
redis.redis.opstreelabs.in                    2020-12-10T11:22:16Z
subscriptions.operators.coreos.com            2020-12-10T01:36:14Z

$ kubectl get deployment -n redis
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
redis-operator   1/1     1            1           4m51s

$ kubectl get pods -n redis
NAME                                                              READY   STATUS      RESTARTS   AGE
4cef93e03ad7c35251ae53cdcd83697ca95563e14c59255965303842bbg4stk   0/1     Completed   0          5m16s
redis-catalog-km5lb                                               1/1     Running     0          9m2s
redis-operator-57996c99b7-54njj                                   1/1     Running     0          4m59s

#########################################

$ cat << EOF > operators-index-manifests.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: operators-index-catalog
  namespace: operator
spec:
  sourceType: grpc
  image: harbor-b.alauda.cn/3rdparty/operators-index:v3.0.1-129.gcddb75b
  displayName: operators-index
  publisher: operators-index.io
EOF

$ kubectl -n operator get packagemanifests | grep operators-index
devops-tool-operator                       operators-index       2m4s
consul-operator                            operators-index       2m4s
jaeger-operator                            operators-index       2m4s
strimzi-kafka-operator                     operators-index       2m4s
postgres-operator                          operators-index       2m4s
kong-operator                              operators-index       2m4s
redis-operator                             operators-index       2m4s
rabbitmq-cluster-operator                  operators-index       2m4s
percona-xtradb-cluster-operator            operators-index       2m4s
$


$ cat << EOF > kong-group.yaml
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: kong-group
  namespace: operator
spec:
  targetNamespaces:
  - operator

EOF


$ cat << EOF > kong-subscription.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kong-subscription
  namespace: operator
spec:
  channel: stable
  name: kong-operator
  source: operators-index-catalog
  sourceNamespace: operator

EOF



```















```
localhost:~ huzhi$ docker run -ti harbor.alauda.cn/devops/builder-java:openjdk8-v3.0.2 bash
root@4104b8121a4a:/#

root@4104b8121a4a:~# pwd
/root
root@4104b8121a4a:~# mkdir work
root@4104b8121a4a:~# cd work/
root@4104b8121a4a:~/work# pwd
/root/work
root@4104b8121a4a:~/work#
root@4104b8121a4a:~/work#


localhost:java_code huzhi$ docker cp strimzi-kafka-operator zealous_bhaskara:/root/work/
localhost:java_code huzhi$

root@4104b8121a4a:~/work/strimzi-kafka-operator# apt-get updata

root@4104b8121a4a:~/work/strimzi-kafka-operator# apt-get install -y git

root@4104b8121a4a:~/work/strimzi-kafka-operator# ./Jenkinsfile-script/install_tool.sh


$ docker build --network=host -t test -f Dockerfile_Base .







#Create consumer config
echo "exclude.internal.topics=false" > ./consumer.config
#Consume all offsets
kafka-console-consumer.sh --consumer.config ./consumer.config --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --bootstrap-server 10.0.128.237:30300 --topic __consumer_offsets --from-beginning






kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:31300 --describe --group my-group


[root@mw-init ~]# kafka-consumer-groups.sh --bootstrap-server 10.0.128.237:30300 --describe --group my-group

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
my-group        my-topic        0          1               1               0               consumer-my-group-1-3813656b-b1f8-4ea0-8ba7-535bbf98b6e9 /10.0.128.237   consumer-my-group-1
my-group        my-topic        1          2               2               0               consumer-my-group-1-3813656b-b1f8-4ea0-8ba7-535bbf98b6e9 /10.0.128.237   consumer-my-group-1
my-group        my-topic        2          2               2               0               consumer-my-group-1-3813656b-b1f8-4ea0-8ba7-535bbf98b6e9 /10.0.128.237   consumer-my-group-1
[root@mw-init ~]#


kafka-producer-perf-test.sh --num-records 50 --topic my-topic --throughput -1 --record-size 1000 --producer-props bootstrap.servers=10.0.128.237:30300





[INFO] Final Memory: 15M/431M
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-checkstyle-plugin:3.1.0:check (validate) on project strimzi: Execution validate of goal org.apache.maven.plugins:maven-checkstyle-plugin:3.1.0:check failed: Plugin org.apache.maven.plugins:maven-checkstyle-plugin:3.1.0 or one of its dependencies could not be resolved: The following artifacts could not be resolved: com.google.guava:guava:jar:28.2-jre, net.sf.saxon:Saxon-HE:jar:9.9.1-6, org.apache.velocity:velocity-tools:jar:2.0: Could not transfer artifact com.google.guava:guava:jar:28.2-jre from/to central (https://repo.maven.apache.org/maven2): GET request of: com/google/guava/guava/28.2-jre/guava-28.2-jre.jar from central failed: Premature end of Content-Length delimited message body (expected: 2788302; received: 2339856 -> [Help 1]
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/PluginResolutionException
make[1]: *** [java_install_root] Error 1
make[1]: Leaving directory `/root/work/kafka-agent'
make: *** [kafka-agent] Error 2
The command '/bin/sh -c yum -y update     && yum -y install java-${JAVA_VERSION}-openjdk-headless openssl git maven     && yum -y clean all     && chmod +x ./Jenkinsfile-script/yq_linux_arm64     && mv ./Jenkinsfile-script/yq_linux_arm64 /usr/bin/yq     && MVN_ARGS="-Dmaven.javadoc.skip=true -DskipITs -DskipTests" make all' returned a non-zero code: 2
[root@hudi-arm-master-0001 strimzi-kafka-operator]#
[root@hudi-arm-master-0001 strimzi-kafka-operator]#
[root@hudi-arm-master-0001 strimzi-kafka-operator]#






strimzi/test-client
strimzi/kafka
strimzi/operator
strimzi/jmxtrans
strimzi/base




tdsql/operator:arm-0.18.0
tdsql/kafka:arm-0.18.0-kafka-2.4.0
tdsql/kafka:arm-0.18.0-kafka-2.4.1
tdsql/kafka:arm-0.18.0-kafka-2.5.0

tdsql/kafka-bridge:0.16.0
tdsql/jmxtrans:arm-0.18.0



# Source: strimzi-kafka-operator/templates/050-Deployment-strimzi-cluster-operator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strimzi-cluster-operator
  labels:
    app: strimzi
    chart: strimzi-kafka-operator-0.18.0
    component: deployment
    release: kafka-operator
    heritage: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      name: strimzi-cluster-operator
      strimzi.io/kind: cluster-operator
  template:
    metadata:
      labels:
        name: strimzi-cluster-operator
        strimzi.io/kind: cluster-operator
    spec:
      serviceAccountName: strimzi-cluster-operator
      containers:
        - name: strimzi-cluster-operator
          image: harbor-b.alauda.cn/tdsql/operator:arm-0.18.0
          ports:
            - containerPort: 8080
              name: http
          args:
            - /opt/strimzi/bin/cluster_operator_run.sh
          env:
            - name: STRIMZI_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: STRIMZI_FULL_RECONCILIATION_INTERVAL_MS
              value: "120000"
            - name: STRIMZI_OPERATION_TIMEOUT_MS
              value: "300000"
            - name: STRIMZI_DEFAULT_TLS_SIDECAR_ENTITY_OPERATOR_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_DEFAULT_TLS_SIDECAR_KAFKA_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_DEFAULT_KAFKA_EXPORTER_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_DEFAULT_CRUISE_CONTROL_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_DEFAULT_TLS_SIDECAR_CRUISE_CONTROL_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_KAFKA_IMAGES
              value: |
                2.4.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.0
                2.4.1=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.1
                2.5.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_KAFKA_CONNECT_IMAGES
              value: |
                2.4.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.0
                2.4.1=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.1
                2.5.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_KAFKA_CONNECT_S2I_IMAGES
              value: |
                2.4.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.0
                2.4.1=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.1
                2.5.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_KAFKA_MIRROR_MAKER_IMAGES
              value: |
                2.4.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.0
                2.4.1=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.1
                2.5.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_KAFKA_MIRROR_MAKER_2_IMAGES
              value: |
                2.4.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.0
                2.4.1=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.4.1
                2.5.0=harbor-b.alauda.cn/tdsql/kafka:arm-0.18.0-kafka-2.5.0
            - name: STRIMZI_DEFAULT_TOPIC_OPERATOR_IMAGE
              value: harbor-b.alauda.cn/tdsql/operator:arm-0.18.0
            - name: STRIMZI_DEFAULT_USER_OPERATOR_IMAGE
              value: harbor-b.alauda.cn/tdsql/operator:arm-0.18.0
            - name: STRIMZI_DEFAULT_KAFKA_INIT_IMAGE
              value: harbor-b.alauda.cn/tdsql/operator:arm-0.18.0
            - name: STRIMZI_DEFAULT_KAFKA_BRIDGE_IMAGE
              value: harbor-b.alauda.cn/tdsql/kafka-bridge:0.16.0
            - name: STRIMZI_DEFAULT_JMXTRANS_IMAGE
              value: harbor-b.alauda.cn/tdsql/jmxtrans:arm-0.18.0
            - name: STRIMZI_LOG_LEVEL
              value: "INFO"

          livenessProbe:
            httpGet:
              path: /healthy
              port: http
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 10
            periodSeconds: 30
          resources:
            limits:
              cpu: 1000m
              memory: 384Mi
            requests:
              cpu: 200m
              memory: 384Mi
  strategy:
    type: Recreate

NOTES:
Thank you for installing strimzi-kafka-operator-0.18.0

To create a Kafka cluster refer to the following documentation.

https://strimzi.io/docs/0.18.0/#kafka-cluster-str
huzhideMacBook-Pro:strimzi-kafka-operator huzhi$


strimzi/test-client:build-kafka-2.5.0 strimzi/kafka:build-kafka-2.5.0 strimzi/kafka:latest strimzi/test-client:build-kafka-2.4.1 strimzi/kafka:build-kafka-2.4.1 strimzi/test-client:build-kafka-2.4.0 strimzi/kafka:build-kafka-2.4.0



apt-get install openjdk-8-jdk maven

docker run --rm -it --network=host  busybox sh


docker run --rm -it --network=host harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0 bash






docker           run            --rm -it   busybox sh
kubectl -n kafka run kafka-test --rm -ti --network=host --image=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0  --restart=Never bash



192.168.34.81:60080/3rdparty/operators-index:v3.0.1-243.g8af9fcf

harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka@sha256:37c46c8cf949a91c37f3ae090d022b39126f865c5b56dc8a730f017ceadc558f


huzhideMacBook-Pro:bin huzhi$ ./kafka-topics.sh --bootstrap-server 192.168.64.44:32390 --list
Error while executing topic command : org.apache.kafka.common.errors.TimeoutException: Call(callName=listTopics, deadlineMs=1610021201113) timed out at 9223372036854775807 after 1 attempt(s)
[2021-01-07 20:05:41,348] ERROR java.util.concurrent.ExecutionException: org.apache.kafka.common.errors.TimeoutException: Call(callName=listTopics, deadlineMs=1610021201113) timed out at 9223372036854775807 after 1 attempt(s)
	at org.apache.kafka.common.internals.KafkaFutureImpl.wrapAndThrow(KafkaFutureImpl.java:45)
	at org.apache.kafka.common.internals.KafkaFutureImpl.access$000(KafkaFutureImpl.java:32)
	at org.apache.kafka.common.internals.KafkaFutureImpl$SingleWaiter.await(KafkaFutureImpl.java:89)
	at org.apache.kafka.common.internals.KafkaFutureImpl.get(KafkaFutureImpl.java:260)
	at kafka.admin.TopicCommand$AdminClientTopicService.getTopics(TopicCommand.scala:333)
	at kafka.admin.TopicCommand$AdminClientTopicService.listTopics(TopicCommand.scala:252)
	at kafka.admin.TopicCommand$.main(TopicCommand.scala:66)
	at kafka.admin.TopicCommand.main(TopicCommand.scala)
Caused by: org.apache.kafka.common.errors.TimeoutException: Call(callName=listTopics, deadlineMs=1610021201113) timed out at 9223372036854775807 after 1 attempt(s)
Caused by: org.apache.kafka.common.errors.TimeoutException: The AdminClient thread has exited.
 (kafka.admin.TopicCommand$)
[2021-01-07 20:05:41,349] ERROR Uncaught exception in thread 'kafka-admin-client-thread | adminclient-1': (org.apache.kafka.common.utils.KafkaThread)
java.lang.OutOfMemoryError: Java heap space
	at java.nio.HeapByteBuffer.<init>(HeapByteBuffer.java:57)
	at java.nio.ByteBuffer.allocate(ByteBuffer.java:335)
	at org.apache.kafka.common.memory.MemoryPool$1.tryAllocate(MemoryPool.java:30)
	at org.apache.kafka.common.network.NetworkReceive.readFrom(NetworkReceive.java:113)
	at org.apache.kafka.common.network.KafkaChannel.receive(KafkaChannel.java:448)
	at org.apache.kafka.common.network.KafkaChannel.read(KafkaChannel.java:398)
	at org.apache.kafka.common.network.Selector.attemptRead(Selector.java:678)
	at org.apache.kafka.common.network.Selector.pollSelectionKeys(Selector.java:580)
	at org.apache.kafka.common.network.Selector.poll(Selector.java:485)
	at org.apache.kafka.clients.NetworkClient.poll(NetworkClient.java:549)
	at org.apache.kafka.clients.admin.KafkaAdminClient$AdminClientRunnable.processRequests(KafkaAdminClient.java:1272)
	at org.apache.kafka.clients.admin.KafkaAdminClient$AdminClientRunnable.run(KafkaAdminClient.java:1203)
	at java.lang.Thread.run(Thread.java:748)
huzhideMacBook-Pro:bin huzhi$




```





 

























