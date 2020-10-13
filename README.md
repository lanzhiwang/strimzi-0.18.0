# strimzi kafka operator

strimzi kafka operator 部署的资源如下：

## 1、cluster-operator

##### ServiceAccount
* strimzi-cluster-operator

##### ClusterRole
* strimzi-cluster-operator-namespaced
* strimzi-cluster-operator-global
* strimzi-kafka-broker
* strimzi-entity-operator
* strimzi-topic-operator

##### RoleBinding
* strimzi-cluster-operator
* strimzi-cluster-operator-entity-operator-delegation
* strimzi-cluster-operator-topic-operator-delegation

##### ClusterRoleBinding
* strimzi-cluster-operator
* strimzi-cluster-operator-kafka-broker-delegation

##### CustomResourceDefinition
* kafkas.kafka.strimzi.io
* kafkaconnects.kafka.strimzi.io
* kafkaconnects2is.kafka.strimzi.io
* kafkatopics.kafka.strimzi.io
* kafkausers.kafka.strimzi.io
* kafkamirrormakers.kafka.strimzi.io
* kafkabridges.kafka.strimzi.io
* kafkaconnectors.kafka.strimzi.io
* kafkamirrormaker2s.kafka.strimzi.io
* kafkarebalances.kafka.strimzi.io

##### Deployment
* strimzi-cluster-operator

## 2、strimzi-admin

##### ClusterRole
* strimzi-admin
* strimzi-view


## 3、topic-operator

##### ServiceAccount
* strimzi-topic-operator

##### Role
* strimzi-topic-operator

##### RoleBinding
* strimzi-topic-operator

##### CustomResourceDefinition
* kafkatopics.kafka.strimzi.io

##### Deployment
* strimzi-topic-operator


## 4、user-operator

##### ServiceAccount
* strimzi-user-operator

##### Role
* strimzi-user-operator

##### RoleBinding
* strimzi-user-operator

##### CustomResourceDefinition
* kafkausers.kafka.strimzi.io

##### Deployment
* strimzi-user-operator


## 在本地安装 strimzi

```bash
#
$ kind create cluster
$ kind delete cluster

#
huzhi@huzhideMacBook-Pro strimzi-0.18.0 % kubectl create ns kafka
namespace/kafka created

#
huzhi@huzhideMacBook-Pro strimzi-0.18.0 % sed -i '' 's/namespace: .*/namespace: kafka/' install/cluster-operator/*RoleBinding*.yaml

install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml
install/cluster-operator/021-ClusterRoleBinding-strimzi-cluster-operator.yaml
install/cluster-operator/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml
install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml
install/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml

#
huzhi@huzhideMacBook-Pro strimzi-0.18.0 % kubectl create ns my-kafka-project
namespace/my-kafka-project created
huzhi@huzhideMacBook-Pro strimzi-0.18.0 %

#
$ vim install/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml

         - /opt/strimzi/bin/cluster_operator_run.sh
         env:
         - name: STRIMZI_NAMESPACE
-          valueFrom:
-            fieldRef:
-              fieldPath: metadata.namespace
+          value: my-kafka-project
         - name: STRIMZI_FULL_RECONCILIATION_INTERVAL_MS
           value: "120000"
         - name: STRIMZI_OPERATION_TIMEOUT_MS

# 准备如下镜像：
strimzi/operator:0.18.0
strimzi/kafka:0.18.0-kafka-2.5.0
strimzi/kafka:0.18.0-kafka-2.4.0
strimzi/kafka:0.18.0-kafka-2.4.1
strimzi/kafka-bridge:0.16.0
strimzi/jmxtrans:0.18.0

#
huzhi@huzhideMacBook-Pro strimzi-0.18.0 % kubectl apply -f install/cluster-operator/ -n kafka
serviceaccount/strimzi-cluster-operator created
clusterrole.rbac.authorization.k8s.io/strimzi-cluster-operator-namespaced created
rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator created
clusterrole.rbac.authorization.k8s.io/strimzi-cluster-operator-global created
clusterrolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator created
clusterrole.rbac.authorization.k8s.io/strimzi-kafka-broker created
clusterrolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-kafka-broker-delegation created
clusterrole.rbac.authorization.k8s.io/strimzi-entity-operator created
rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-entity-operator-delegation created
clusterrole.rbac.authorization.k8s.io/strimzi-topic-operator created
rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-topic-operator-delegation created
Warning: apiextensions.k8s.io/v1beta1 CustomResourceDefinition is deprecated in v1.16+, unavailable in v1.22+; use apiextensions.k8s.io/v1 CustomResourceDefinition
customresourcedefinition.apiextensions.k8s.io/kafkas.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkaconnects.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkaconnects2is.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkatopics.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkausers.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkamirrormakers.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkabridges.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkaconnectors.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkamirrormaker2s.kafka.strimzi.io created
customresourcedefinition.apiextensions.k8s.io/kafkarebalances.kafka.strimzi.io created
deployment.apps/strimzi-cluster-operator created
huzhi@huzhideMacBook-Pro strimzi-0.18.0 %


```









部署的资源整理

```bash
kubectl get -n kafka customresourcedefinitions
kafkabridges.kafka.strimzi.io                    2020-09-18T11:39:55Z
kafkaconnectors.kafka.strimzi.io                 2020-09-18T11:39:55Z
kafkaconnects.kafka.strimzi.io                   2020-09-18T11:39:55Z
kafkaconnects2is.kafka.strimzi.io                2020-09-18T11:39:55Z
kafkamirrormaker2s.kafka.strimzi.io              2020-09-18T11:39:56Z
kafkamirrormakers.kafka.strimzi.io               2020-09-18T11:39:56Z
kafkarebalances.kafka.strimzi.io                 2020-09-18T11:39:56Z
kafkas.kafka.strimzi.io                          2020-09-11T02:44:14Z
kafkatopics.kafka.strimzi.io                     2020-08-31T03:35:06Z
kafkausers.kafka.strimzi.io                      2020-08-31T03:35:06Z


kubectl get -n kafka apiservices
NAME                                   SERVICE                                         AVAILABLE   AGE
v1alpha1.kafka.strimzi.io              Local                                           True        2d8h
v1beta1.kafka.strimzi.io               Local                                           True        3d19h

kubectl get -n kafka kafkabridges

kubectl get -n kafka kafkaconnectors

kubectl get -n kafka kafkaconnects

kubectl get -n kafka kafkaconnects2is

kubectl get -n kafka kafkamirrormaker2s

kubectl get -n kafka kafkamirrormakers

kubectl get -n kafka kafkarebalances

kubectl get -n kafka kafkas

kubectl get -n kafka kafkatopics

kubectl get -n kafka kafkausers

kubectl get -n kafka products
NAME            AGE
kafka           45d


kubectl get -n kafka packagemanifests
NAME                              CATALOG   AGE
strimzi-kafka-operator            平台自研      20d


kubectl get -n kafka clusterroles
NAME                                                                   AGE
kafkabridges.kafka.strimzi.io-v1alpha1-admin                           24d
kafkabridges.kafka.strimzi.io-v1alpha1-crdview                         24d
kafkabridges.kafka.strimzi.io-v1alpha1-edit                            24d
kafkabridges.kafka.strimzi.io-v1alpha1-view                            24d

kafkaconnectors.kafka.strimzi.io-v1alpha1-admin                        24d
kafkaconnectors.kafka.strimzi.io-v1alpha1-crdview                      24d
kafkaconnectors.kafka.strimzi.io-v1alpha1-edit                         24d
kafkaconnectors.kafka.strimzi.io-v1alpha1-view                         24d

kafkaconnects.kafka.strimzi.io-v1beta1-admin                           24d
kafkaconnects.kafka.strimzi.io-v1beta1-crdview                         24d
kafkaconnects.kafka.strimzi.io-v1beta1-edit                            24d
kafkaconnects.kafka.strimzi.io-v1beta1-view                            24d

kafkaconnects2is.kafka.strimzi.io-v1beta1-admin                        24d
kafkaconnects2is.kafka.strimzi.io-v1beta1-crdview                      24d
kafkaconnects2is.kafka.strimzi.io-v1beta1-edit                         24d
kafkaconnects2is.kafka.strimzi.io-v1beta1-view                         24d

kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-admin                     24d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-crdview                   24d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-edit                      24d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-view                      24d

kafkamirrormakers.kafka.strimzi.io-v1beta1-admin                       24d
kafkamirrormakers.kafka.strimzi.io-v1beta1-crdview                     24d
kafkamirrormakers.kafka.strimzi.io-v1beta1-edit                        24d
kafkamirrormakers.kafka.strimzi.io-v1beta1-view                        24d

kafkarebalances.kafka.strimzi.io-v1alpha1-admin                        24d
kafkarebalances.kafka.strimzi.io-v1alpha1-crdview                      24d
kafkarebalances.kafka.strimzi.io-v1alpha1-edit                         24d
kafkarebalances.kafka.strimzi.io-v1alpha1-view                         24d

kafkas.kafka.strimzi.io-v1beta1-admin                                  26d
kafkas.kafka.strimzi.io-v1beta1-crdview                                26d
kafkas.kafka.strimzi.io-v1beta1-edit                                   26d
kafkas.kafka.strimzi.io-v1beta1-view                                   26d

kafkatopics.kafka.strimzi.io-v1beta1-admin                             42d
kafkatopics.kafka.strimzi.io-v1beta1-crdview                           42d
kafkatopics.kafka.strimzi.io-v1beta1-edit                              42d
kafkatopics.kafka.strimzi.io-v1beta1-view                              42d

kafkausers.kafka.strimzi.io-v1beta1-admin                              42d
kafkausers.kafka.strimzi.io-v1beta1-crdview                            42d
kafkausers.kafka.strimzi.io-v1beta1-edit                               42d
kafkausers.kafka.strimzi.io-v1beta1-view                               42d

strimzi-entity-operator                                                26d
strimzi-kafka-broker                                                   26d

########################################################

[root@mw-init ~]# kubectl create namespace kafka
namespace/kafka created
[root@mw-init ~]#
[root@mw-init ~]#
[root@mw-init ~]# kubectl get namespaces | grep kafka
kafka                Active   3s
[root@mw-init ~]#
[root@mw-init ~]#
[root@mw-init ~]# kubectl get namespaces | grep kafka
kafka                Active   5s
[root@mw-init ~]#


部署 operator

kubectl get -n kafka clusterroles
NAME                                                                   AGE
kafka-7dpb8-admin                                                      3m32s
kafka-7dpb8-edit                                                       3m32s
kafka-7dpb8-view                                                       3m32s
strimzi-cluster-operator.v0.18.0-6jbmk                                 3m27s


kubectl get -n kafka componentstatuses

kubectl get -n kafka events

kubectl get -n kafka pods
NAME                                               READY   STATUS    RESTARTS   AGE
strimzi-cluster-operator-v0.18.0-99fc5c9f5-zsrx8   1/1     Running   0          43m

kubectl get -n kafka secrets
NAME                                   TYPE                                  DATA   AGE
default-token-r5ztg                    kubernetes.io/service-account-token   3      44m
strimzi-cluster-operator-token-8r97s   kubernetes.io/service-account-token   3      43m

kubectl get -n kafka serviceaccounts
NAME                       SECRETS   AGE
default                    1         44m
strimzi-cluster-operator   1         43m


kubectl get -n kafka productions

kubectl get -n kafka mutatingwebhookconfigurations

kubectl get -n kafka validatingwebhookconfigurations

kubectl get -n kafka deployments
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
strimzi-cluster-operator-v0.18.0   1/1     1            1           43m

kubectl get -n kafka replicasets
NAME                                         DESIRED   CURRENT   READY   AGE
strimzi-cluster-operator-v0.18.0-99fc5c9f5   1         1         1       43m

kubectl get -n kafka clusterserviceversions
NAME                               DISPLAY          VERSION   REPLACES   PHASE
strimzi-cluster-operator.v0.18.0   Kafka Operator   0.18.0               Succeeded

kubectl get -n kafka installplans
NAME            CSV                                APPROVAL    APPROVED
install-c47dn   strimzi-cluster-operator.v0.18.0   Automatic   true

kubectl get -n kafka operatorgroups
NAME          AGE
kafka-7dpb8   43m

kubectl get -n kafka subscriptions
NAME                     PACKAGE                  SOURCE     CHANNEL
strimzi-kafka-operator   strimzi-kafka-operator   platform   stable

kubectl get -n kafka rolebindings
NAME                                                              AGE
strimzi-cluster-operator.v0.18.0-5d4db-strimzi-cluster-opeczh7s   43m

kubectl get -n kafka roles
NAME                                     AGE
strimzi-cluster-operator.v0.18.0-5d4db   43m





部署 kafka 集群和 topic

kubectl get -n kafka configmaps
NAME                                      DATA   AGE
my-cluster-cruise-control-config          1      21s
my-cluster-entity-topic-operator-config   1      45s
my-cluster-entity-user-operator-config    1      45s
my-cluster-kafka-config                   2      71s
my-cluster-zookeeper-config               2      2m58s

kubectl get -n kafka endpoints
NAME                          ENDPOINTS                                                          AGE
my-cluster-cruise-control                                                                        21s
my-cluster-kafka-bootstrap    10.199.0.16:9091,10.199.1.208:9091,10.199.1.209:9091 + 6 more...   71s
my-cluster-kafka-brokers      10.199.0.16:9999,10.199.1.208:9999,10.199.1.209:9999 + 9 more...   71s
my-cluster-zookeeper-client   10.199.0.15:2181,10.199.1.206:2181,10.199.1.207:2181               2m58s
my-cluster-zookeeper-nodes    10.199.0.15:3888,10.199.1.206:3888,10.199.1.207:3888 + 6 more...   2m58s

kubectl get -n kafka events


kubectl get -n kafka pods
NAME                                               READY   STATUS    RESTARTS   AGE
my-cluster-cruise-control-68795c6bbd-bhpwd         1/2     Running   0          22s
my-cluster-entity-operator-9d996575b-lxr42         3/3     Running   0          46s
my-cluster-kafka-0                                 2/2     Running   0          72s
my-cluster-kafka-1                                 2/2     Running   0          72s
my-cluster-kafka-2                                 2/2     Running   0          71s
my-cluster-zookeeper-0                             1/1     Running   0          2m58s
my-cluster-zookeeper-1                             1/1     Running   0          2m58s
my-cluster-zookeeper-2                             1/1     Running   0          2m58s
strimzi-cluster-operator-v0.18.0-99fc5c9f5-zsrx8   1/1     Running   0          73m


kubectl get -n kafka secrets
NAME                                     TYPE                                  DATA   AGE
default-token-r5ztg                      kubernetes.io/service-account-token   3      73m
my-cluster-clients-ca                    Opaque                                1      2m59s
my-cluster-clients-ca-cert               Opaque                                3      2m59s
my-cluster-cluster-ca                    Opaque                                1      2m59s
my-cluster-cluster-ca-cert               Opaque                                3      2m59s
my-cluster-cluster-operator-certs        Opaque                                4      2m59s
my-cluster-cruise-control-certs          Opaque                                4      22s
my-cluster-cruise-control-token-lcjlr    kubernetes.io/service-account-token   3      22s
my-cluster-entity-operator-certs         Opaque                                4      46s
my-cluster-entity-operator-token-8btdr   kubernetes.io/service-account-token   3      46s
my-cluster-kafka-brokers                 Opaque                                12     72s
my-cluster-kafka-token-27bk4             kubernetes.io/service-account-token   3      72s
my-cluster-zookeeper-nodes               Opaque                                12     2m58s
my-cluster-zookeeper-token-fbjvm         kubernetes.io/service-account-token   3      2m59s
strimzi-cluster-operator-token-8r97s     kubernetes.io/service-account-token   3      73m

kubectl get -n kafka serviceaccounts
NAME                         SECRETS   AGE
default                      1         73m
my-cluster-cruise-control    1         22s
my-cluster-entity-operator   1         46s
my-cluster-kafka             1         72s
my-cluster-zookeeper         1         2m59s
strimzi-cluster-operator     1         73m

kubectl get -n kafka services
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE
my-cluster-cruise-control     ClusterIP   10.102.118.166   <none>        9090/TCP                              22s
my-cluster-kafka-bootstrap    ClusterIP   10.110.183.128   <none>        9091/TCP,9092/TCP,9093/TCP            72s
my-cluster-kafka-brokers      ClusterIP   None             <none>        9091/TCP,9092/TCP,9093/TCP,9999/TCP   72s
my-cluster-zookeeper-client   ClusterIP   10.108.1.215     <none>        2181/TCP                              2m59s
my-cluster-zookeeper-nodes    ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP            2m59s


kubectl get -n kafka controllerrevisions
NAME                              CONTROLLER                              REVISION   AGE
my-cluster-kafka-57c8c84f67       statefulset.apps/my-cluster-kafka       1          74s
my-cluster-zookeeper-7589447968   statefulset.apps/my-cluster-zookeeper   1          3m



kubectl get -n kafka deployments
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
my-cluster-cruise-control          1/1     1            1           24s
my-cluster-entity-operator         1/1     1            1           48s
strimzi-cluster-operator-v0.18.0   1/1     1            1           73m

kubectl get -n kafka replicasets
NAME                                         DESIRED   CURRENT   READY   AGE
my-cluster-cruise-control-68795c6bbd         1         1         1       24s
my-cluster-entity-operator-9d996575b         1         1         1       48s
strimzi-cluster-operator-v0.18.0-99fc5c9f5   1         1         1       73m

kubectl get -n kafka statefulsets
NAME                   READY   AGE
my-cluster-kafka       3/3     75s
my-cluster-zookeeper   3/3     3m1s











kubectl get -n kafka kafkas
NAME         DESIRED KAFKA REPLICAS   DESIRED ZK REPLICAS
my-cluster   3                        3

kubectl get -n kafka kafkatopics
NAME                                           PARTITIONS   REPLICATION FACTOR
strimzi.cruisecontrol.metrics                  1            1
strimzi.cruisecontrol.modeltrainingsamples     32           2
strimzi.cruisecontrol.partitionmetricsamples   32           2



kubectl get -n kafka pods
NAME                                               READY   STATUS    RESTARTS   AGE
my-cluster-cruise-control-68795c6bbd-bhpwd         2/2     Running   0          30s
my-cluster-entity-operator-9d996575b-lxr42         3/3     Running   0          54s
my-cluster-kafka-0                                 2/2     Running   0          80s
my-cluster-kafka-1                                 2/2     Running   0          80s
my-cluster-kafka-2                                 2/2     Running   0          79s
my-cluster-zookeeper-0                             1/1     Running   0          3m6s
my-cluster-zookeeper-1                             1/1     Running   0          3m6s
my-cluster-zookeeper-2                             1/1     Running   0          3m6s
strimzi-cluster-operator-v0.18.0-99fc5c9f5-zsrx8   1/1     Running   0          73m



kubectl get -n kafka networkpolicies
NAME                                       POD-SELECTOR                                AGE
my-cluster-network-policy-cruise-control   strimzi.io/name=my-cluster-cruise-control   30s
my-cluster-network-policy-kafka            strimzi.io/name=my-cluster-kafka            80s
my-cluster-network-policy-zookeeper        strimzi.io/name=my-cluster-zookeeper        3m7s


kubectl get -n kafka clusterserviceversions
NAME                               DISPLAY          VERSION   REPLACES   PHASE
strimzi-cluster-operator.v0.18.0   Kafka Operator   0.18.0               Succeeded

kubectl get -n kafka installplans
NAME            CSV                                APPROVAL    APPROVED
install-c47dn   strimzi-cluster-operator.v0.18.0   Automatic   true

kubectl get -n kafka operatorgroups
NAME          AGE
kafka-7dpb8   73m

kubectl get -n kafka subscriptions
NAME                     PACKAGE                  SOURCE     CHANNEL
strimzi-kafka-operator   strimzi-kafka-operator   platform   stable





kubectl get -n kafka poddisruptionbudgets
NAME                   MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
my-cluster-kafka       N/A             1                 1                     7s
my-cluster-zookeeper   N/A             1                 1                     8s

kubectl get -n kafka podsecuritypolicies
NAME                                  PRIV    CAPS   SELINUX    RUNASUSER   FSGROUP     SUPGROUP    READONLYROOTFS   VOLUMES
20-user-restricted                    true    *      RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            *
80-system-privileged                  true    *      RunAsAny   RunAsAny    RunAsAny    RunAsAny    false            *
kube-prometheus                       false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
kube-prometheus-alertmanager          false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
kube-prometheus-exporter-kube-state   false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
kube-prometheus-exporter-node         false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim,hostPath
kube-prometheus-grafana               false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim,hostPath
prometheus-operator                   false          RunAsAny   RunAsAny    MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim




kubectl get -n kafka clusterrolebindings
NAME                                                                 AGE
strimzi-cluster-operator.v0.18.0-6jbmk-strimzi-cluster-open52ng      73m



kubectl get -n kafka clusterroles
NAME                                                                   AGE
strimzi-cluster-operator.v0.18.0-6jbmk                                 73m


kubectl get -n kafka rolebindings
NAME                                                              AGE
strimzi-cluster-operator.v0.18.0-5d4db-strimzi-cluster-opeczh7s   73m
strimzi-my-cluster-entity-topic-operator                          57s
strimzi-my-cluster-entity-user-operator                           57s

kubectl get -n kafka roles
NAME                                     AGE
strimzi-cluster-operator.v0.18.0-5d4db   73m










```





















####################################

在集群中实际部署的资源情况如下：

## 1、cluster-operator

##### ServiceAccount
* strimzi-cluster-operator

```bash
[root@mw-init ~]# kubectl get ServiceAccount --all-namespaces=true | grep strimzi-cluster-operator
kafka                strimzi-cluster-operator                   1         9d
[root@mw-init ~]#
```

##### ClusterRole
* strimzi-cluster-operator-namespaced
* strimzi-cluster-operator-global
* strimzi-kafka-broker
* strimzi-entity-operator
* strimzi-topic-operator

```bash
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-cluster-operator-namespaced
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-cluster-operator-global
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-kafka-broker
strimzi-kafka-broker                                                   22d
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-entity-operator
strimzi-entity-operator                                                22d
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-topic-operator
[root@mw-init ~]#

```

##### RoleBinding
* strimzi-cluster-operator
* strimzi-cluster-operator-entity-operator-delegation
* strimzi-cluster-operator-topic-operator-delegation

```bash
[root@mw-init ~]# kubectl get RoleBinding --all-namespaces=true | grep strimzi-cluster-operator
kafka          strimzi-cluster-operator.v0.18.0-5qfpz-strimzi-cluster-ope7zk7p                            9d
[root@mw-init ~]#
[root@mw-init ~]# kubectl get RoleBinding --all-namespaces=true | grep strimzi-cluster-operator-entity-operator-delegation
[root@mw-init ~]#
[root@mw-init ~]# kubectl get RoleBinding --all-namespaces=true | grep strimzi-cluster-operator-topic-operator-delegation
[root@mw-init ~]#

```

##### ClusterRoleBinding
* strimzi-cluster-operator
* strimzi-cluster-operator-kafka-broker-delegation

```bash
[root@mw-init ~]# kubectl get ClusterRoleBinding --all-namespaces=true | grep strimzi-cluster-operator
strimzi-cluster-operator.v0.18.0-rp7ml-strimzi-cluster-ope8w9ct      9d
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRoleBinding --all-namespaces=true | grep strimzi-cluster-operator-kafka-broker-delegation
[root@mw-init ~]#

```

##### CustomResourceDefinition
* kafkas.kafka.strimzi.io
* kafkaconnects.kafka.strimzi.io
* kafkaconnects2is.kafka.strimzi.io
* kafkatopics.kafka.strimzi.io
* kafkausers.kafka.strimzi.io
* kafkamirrormakers.kafka.strimzi.io
* kafkabridges.kafka.strimzi.io
* kafkaconnectors.kafka.strimzi.io
* kafkamirrormaker2s.kafka.strimzi.io
* kafkarebalances.kafka.strimzi.io

```bash
[root@mw-init ~]# kubectl get CustomResourceDefinition | grep kafka
kafkabridges.kafka.strimzi.io                    2020-09-18T11:39:55Z
kafkaconnectors.kafka.strimzi.io                 2020-09-18T11:39:55Z
kafkaconnects.kafka.strimzi.io                   2020-09-18T11:39:55Z
kafkaconnects2is.kafka.strimzi.io                2020-09-18T11:39:55Z
kafkamirrormaker2s.kafka.strimzi.io              2020-09-18T11:39:56Z
kafkamirrormakers.kafka.strimzi.io               2020-09-18T11:39:56Z
kafkarebalances.kafka.strimzi.io                 2020-09-18T11:39:56Z
kafkas.kafka.strimzi.io                          2020-09-11T02:44:14Z
kafkatopics.kafka.strimzi.io                     2020-08-31T03:35:06Z
kafkausers.kafka.strimzi.io                      2020-08-31T03:35:06Z
[root@mw-init ~]#
```

##### Deployment
* strimzi-cluster-operator

```bash
[root@mw-init ~]# kubectl get deployment --all-namespaces=true | grep strimzi-cluster-operator
kafka                strimzi-cluster-operator-v0.18.0      1/1     1            1           9d
[root@mw-init ~]#

```


## 2、strimzi-admin

##### ClusterRole
* strimzi-admin
* strimzi-view

```bash
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-admin
[root@mw-init ~]#
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep strimzi-view
[root@mw-init ~]#

```


## 3、topic-operator

##### ServiceAccount
* strimzi-topic-operator

```bash
[root@mw-init ~]# kubectl get ServiceAccount --all-namespaces=true | grep strimzi-topic-operator
[root@mw-init ~]#
```

##### Role
* strimzi-topic-operator

```bash
[root@mw-init ~]# kubectl get Role --all-namespaces=true | grep strimzi-topic-operator
[root@mw-init ~]#
```

##### RoleBinding
* strimzi-topic-operator

```bash
[root@mw-init ~]# kubectl get RoleBinding --all-namespaces=true | grep strimzi-topic-operator
[root@mw-init ~]#
```

##### CustomResourceDefinition
* kafkatopics.kafka.strimzi.io

```bash
[root@mw-init ~]# kubectl get CustomResourceDefinition --all-namespaces=true | grep kafkatopics.kafka.strimzi.io
kafkatopics.kafka.strimzi.io                     2020-08-31T03:35:06Z
[root@mw-init ~]#
```

##### Deployment
* strimzi-topic-operator

```bash
[root@mw-init ~]# kubectl get deployment --all-namespaces=true | grep strimzi-topic-operator
[root@mw-init ~]#
```


## 4、user-operator

##### ServiceAccount
* strimzi-user-operator

```bash
[root@mw-init ~]# kubectl get ServiceAccount --all-namespaces=true | grep strimzi-user-operator
[root@mw-init ~]#

```

##### Role
* strimzi-user-operator

```bash
[root@mw-init ~]# kubectl get Role --all-namespaces=true | grep strimzi-user-operator
[root@mw-init ~]#
```

##### RoleBinding
* strimzi-user-operator

```bash
[root@mw-init ~]# kubectl get RoleBinding --all-namespaces=true | grep strimzi-user-operator
[root@mw-init ~]#
```

##### CustomResourceDefinition
* kafkausers.kafka.strimzi.io

```bash
[root@mw-init ~]# kubectl get CustomResourceDefinition --all-namespaces=true | grep kafkausers.kafka.strimzi.io
kafkausers.kafka.strimzi.io                      2020-08-31T03:35:06Z
[root@mw-init ~]#
```

##### Deployment
* strimzi-user-operator

```bash
[root@mw-init ~]# kubectl get deployment --all-namespaces=true | grep strimzi-user-operator
[root@mw-init ~]#
```







```bash
[root@mw-init ~]# kubectl get ClusterRole --all-namespaces=true | grep kafka
kafka-zm2bf-admin                                                      16d
kafka-zm2bf-edit                                                       16d
kafka-zm2bf-view                                                       16d
kafkabridges.kafka.strimzi.io-v1alpha1-admin                           20d
kafkabridges.kafka.strimzi.io-v1alpha1-crdview                         20d
kafkabridges.kafka.strimzi.io-v1alpha1-edit                            20d
kafkabridges.kafka.strimzi.io-v1alpha1-view                            20d
kafkaconnectors.kafka.strimzi.io-v1alpha1-admin                        20d
kafkaconnectors.kafka.strimzi.io-v1alpha1-crdview                      20d
kafkaconnectors.kafka.strimzi.io-v1alpha1-edit                         20d
kafkaconnectors.kafka.strimzi.io-v1alpha1-view                         20d
kafkaconnects.kafka.strimzi.io-v1beta1-admin                           20d
kafkaconnects.kafka.strimzi.io-v1beta1-crdview                         20d
kafkaconnects.kafka.strimzi.io-v1beta1-edit                            20d
kafkaconnects.kafka.strimzi.io-v1beta1-view                            20d
kafkaconnects2is.kafka.strimzi.io-v1beta1-admin                        20d
kafkaconnects2is.kafka.strimzi.io-v1beta1-crdview                      20d
kafkaconnects2is.kafka.strimzi.io-v1beta1-edit                         20d
kafkaconnects2is.kafka.strimzi.io-v1beta1-view                         20d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-admin                     20d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-crdview                   20d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-edit                      20d
kafkamirrormaker2s.kafka.strimzi.io-v1alpha1-view                      20d
kafkamirrormakers.kafka.strimzi.io-v1beta1-admin                       20d
kafkamirrormakers.kafka.strimzi.io-v1beta1-crdview                     20d
kafkamirrormakers.kafka.strimzi.io-v1beta1-edit                        20d
kafkamirrormakers.kafka.strimzi.io-v1beta1-view                        20d
kafkarebalances.kafka.strimzi.io-v1alpha1-admin                        20d
kafkarebalances.kafka.strimzi.io-v1alpha1-crdview                      20d
kafkarebalances.kafka.strimzi.io-v1alpha1-edit                         20d
kafkarebalances.kafka.strimzi.io-v1alpha1-view                         20d
kafkas.kafka.strimzi.io-v1beta1-admin                                  23d
kafkas.kafka.strimzi.io-v1beta1-crdview                                23d
kafkas.kafka.strimzi.io-v1beta1-edit                                   23d
kafkas.kafka.strimzi.io-v1beta1-view                                   23d
kafkatopics.kafka.strimzi.io-v1beta1-admin                             39d
kafkatopics.kafka.strimzi.io-v1beta1-crdview                           39d
kafkatopics.kafka.strimzi.io-v1beta1-edit                              39d
kafkatopics.kafka.strimzi.io-v1beta1-view                              39d
kafkausers.kafka.strimzi.io-v1beta1-admin                              39d
kafkausers.kafka.strimzi.io-v1beta1-crdview                            39d
kafkausers.kafka.strimzi.io-v1beta1-edit                               39d
kafkausers.kafka.strimzi.io-v1beta1-view                               39d
strimzi-kafka-broker                                                   23d
[root@mw-init ~]#





[root@mw-init ~]# kubectl describe ClusterRole kafka-zm2bf-admin
Name:         kafka-zm2bf-admin
Labels:       olm.owner=kafka-zm2bf
              olm.owner.kind=OperatorGroup
              olm.owner.namespace=kafka
Annotations:  <none>
PolicyRule:
  Resources                            Non-Resource URLs  Resource Names  Verbs
  ---------                            -----------------  --------------  -----
  kafkabridges.kafka.strimzi.io        []                 []              [*]
  kafkaconnectors.kafka.strimzi.io     []                 []              [*]
  kafkaconnects2is.kafka.strimzi.io    []                 []              [*]
  kafkaconnects.kafka.strimzi.io       []                 []              [*]
  kafkamirrormaker2s.kafka.strimzi.io  []                 []              [*]
  kafkamirrormakers.kafka.strimzi.io   []                 []              [*]
  kafkarebalances.kafka.strimzi.io     []                 []              [*]
  kafkas.kafka.strimzi.io              []                 []              [*]
  kafkatopics.kafka.strimzi.io         []                 []              [*]
  kafkausers.kafka.strimzi.io          []                 []              [*]
[root@mw-init ~]#



```

