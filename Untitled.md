
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




```







