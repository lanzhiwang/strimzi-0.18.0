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

