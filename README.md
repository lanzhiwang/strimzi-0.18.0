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

