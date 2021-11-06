# 源码安装

ServiceAccount：strimzi-cluster-operator

| ClusterRole                         | Role | ClusterRoleBinding                               | RoleBinding                                         |
| ----------------------------------- | ---- | ------------------------------------------------ | --------------------------------------------------- |
| strimzi-cluster-operator-namespaced |      |                                                  | strimzi-cluster-operator                            |
| strimzi-cluster-operator-global     |      | strimzi-cluster-operator                         |                                                     |
| strimzi-kafka-broker                |      | strimzi-cluster-operator-kafka-broker-delegation |                                                     |
| strimzi-entity-operator             |      |                                                  | strimzi-cluster-operator-entity-operator-delegation |
| strimzi-topic-operator              |      |                                                  | strimzi-cluster-operator-topic-operator-delegation  |

# operator hub 安装

ServiceAccount：strimzi-cluster-operator

| ClusterRole                     | Role                                | ClusterRoleBinding       | RoleBinding              |                                      |
| ------------------------------- | ----------------------------------- | ------------------------ | ------------------------ | ------------------------------------ |
|                                 | strimzi-cluster-operator-namespaced |                          | strimzi-cluster-operator | spec.install.spec.permissions        |
| strimzi-cluster-operator-global |                                     | strimzi-cluster-operator |                          | spec.install.spec.clusterPermissions |
| strimzi-kafka-broker            |                                     |                          |                          |                                      |
| strimzi-entity-operator         |                                     |                          |                          |                                      |
| strimzi-topic-operator          |                                     |                          |                          |                                      |



```bash
[root@dataservice-master ~]# kubectl get ClusterRole -l olm.owner=strimzi-cluster-operator.v0.18.0
NAME                                          CREATED AT
strimzi-cluster-operator.v0.18.0-6c657fc756   2021-06-07T12:40:30Z
strimzi-entity-operator                       2021-06-07T12:40:30Z
strimzi-kafka-broker                          2021-06-07T12:40:30Z
strimzi-topic-operator                        2021-06-07T12:40:30Z
[root@dataservice-master ~]#

[root@dataservice-master ~]# kubectl -n kafka-develop get Role -l olm.owner=strimzi-cluster-operator.v0.18.0
NAME                                                              CREATED AT
strimzi-cluster-operator.v0.18.0-strimzi-cluster-oper-86595b8f8   2021-06-07T12:40:30Z
[root@dataservice-master ~]#


[root@dataservice-master ~]# kubectl get ClusterRoleBinding -l olm.owner=strimzi-cluster-operator.v0.18.0
NAME                                          ROLE                                                      AGE
strimzi-cluster-operator.v0.18.0-6c657fc756   ClusterRole/strimzi-cluster-operator.v0.18.0-6c657fc756   27m
[root@dataservice-master ~]#

[root@dataservice-master ~]# kubectl -n kafka-develop get Rolebinding -l olm.owner=strimzi-cluster-operator.v0.18.0
NAME                                                              ROLE                                                                   AGE
strimzi-cluster-operator.v0.18.0-strimzi-cluster-oper-86595b8f8   Role/strimzi-cluster-operator.v0.18.0-strimzi-cluster-oper-86595b8f8   29m
[root@dataservice-master ~]#


########
创建 kafka 实例后会增加 Rolebinding

[root@dataservice-master ~]# kubectl get ClusterRole -l app.kubernetes.io/managed-by=strimzi-cluster-operator
No resources found
[root@dataservice-master ~]#
[root@dataservice-master ~]# kubectl -n kafka-develop get Role -l app.kubernetes.io/managed-by=strimzi-cluster-operator
No resources found in kafka-develop namespace.
[root@dataservice-master ~]#
[root@dataservice-master ~]# kubectl get ClusterRoleBinding -l app.kubernetes.io/managed-by=strimzi-cluster-operator
No resources found
[root@dataservice-master ~]#
[root@dataservice-master ~]# kubectl -n kafka-develop get Rolebinding -l app.kubernetes.io/managed-by=strimzi-cluster-operator
NAME                                       ROLE                                  AGE
strimzi-my-cluster-entity-topic-operator   ClusterRole/strimzi-entity-operator   7m21s
strimzi-my-cluster-entity-user-operator    ClusterRole/strimzi-entity-operator   7m21s
[root@dataservice-master ~]#
[root@dataservice-master ~]#


[root@dataservice-master ~]# kubectl get ClusterRole -l olm.owner=strimzi-kafka-operator.v3.5.0-st-jenkins.2106071620
NAME                                                             CREATED AT
strimzi-entity-operator                                          2021-06-07T13:32:36Z
strimzi-kafka-broker                                             2021-06-07T13:32:36Z
strimzi-kafka-operator.v3.5.0-st-jenkins.2106071620-549ff67cfc   2021-06-07T13:32:36Z
strimzi-topic-operator                                           2021-06-07T13:32:36Z
[root@dataservice-master ~]#


```















