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


RoleBinding

| RoleBinding                                         | ClusterRole                         | ServiceAccount           |
| --------------------------------------------------- | ----------------------------------- | ------------------------ |
| strimzi-cluster-operator                            | strimzi-cluster-operator-namespaced | strimzi-cluster-operator |
| strimzi-cluster-operator-entity-operator-delegation | strimzi-entity-operator             | strimzi-cluster-operator |
| strimzi-cluster-operator-topic-operator-delegation  | strimzi-topic-operator              | strimzi-cluster-operator |


ClusterRoleBinding

| ClusterRoleBinding                               | ClusterRole                     | ServiceAccount           |
| ------------------------------------------------ | ------------------------------- | ------------------------ |
| strimzi-cluster-operator                         | strimzi-cluster-operator-global | strimzi-cluster-operator |
| strimzi-cluster-operator-kafka-broker-delegation | strimzi-kafka-broker            | strimzi-cluster-operator |




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

# https://minikube.sigs.k8s.io/docs/
$ minikube start --image-mirror-country='cn' --iso-url='https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.14.0.iso' --driver='hyperkit' --memory='4g'

#
$ kubectl create ns kafka
namespace/kafka created

#
$ sed -i '' 's/namespace: .*/namespace: kafka/' install/cluster-operator/*RoleBinding*.yaml

install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml
install/cluster-operator/021-ClusterRoleBinding-strimzi-cluster-operator.yaml
install/cluster-operator/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml
install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml
install/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml

huzhi@huzhideMacBook-Pro strimzi-0.18.0 % kubectl apply -f install/cluster-operator -n kafka
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



olm

```bash
$ curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/install.sh | bash -s 0.16.1
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/operators.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/operators.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com condition met
namespace/olm created
namespace/operators created
serviceaccount/olm-operator-serviceaccount created
clusterrole.rbac.authorization.k8s.io/system:controller:operator-lifecycle-manager created
clusterrolebinding.rbac.authorization.k8s.io/olm-operator-binding-olm created
deployment.apps/olm-operator created
deployment.apps/catalog-operator created
clusterrole.rbac.authorization.k8s.io/aggregate-olm-edit created
clusterrole.rbac.authorization.k8s.io/aggregate-olm-view created
operatorgroup.operators.coreos.com/global-operators created
operatorgroup.operators.coreos.com/olm-operators created
clusterserviceversion.operators.coreos.com/packageserver created
catalogsource.operators.coreos.com/operatorhubio-catalog created
Waiting for deployment "olm-operator" rollout to finish: 0 of 1 updated replicas are available...
deployment "olm-operator" successfully rolled out
deployment "catalog-operator" successfully rolled out
Package server phase: Installing
Package server phase: Succeeded
deployment "packageserver" successfully rolled out
huzhi@huzhideMacBook-Pro strimzi-0.18.0 %

```

