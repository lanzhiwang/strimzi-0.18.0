


1. 安装 OLM

```bash
$ curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/install.sh -o install.sh

$ ll
total 8
drwxr-xr-x   3 huzhi  staff    96 11  9 20:44 ./
drwxr-xr-x  15 huzhi  staff   480 11  9 20:44 ../
-rw-r--r--   1 huzhi  staff  1286 11  9 20:44 install.sh

$ chmod +x install.sh
$ ll
total 8
drwxr-xr-x   3 huzhi  staff    96 11  9 20:44 ./
drwxr-xr-x  15 huzhi  staff   480 11  9 20:44 ../
-rwxr-xr-x   1 huzhi  staff  1286 11  9 20:44 install.sh*

$ vim install.sh

$ ./install.sh 0.16.1
+ [[ 1 -ne 1 ]]
+ release=0.16.1
+ url=https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1
+ namespace=olm
+ kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/crds.yaml
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/operators.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com created
+ kubectl wait --for=condition=Established -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/crds.yaml
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/operators.operators.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com condition met
+ kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/olm.yaml
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
+ kubectl rollout status -w deployment/olm-operator --namespace=olm
Waiting for deployment "olm-operator" rollout to finish: 0 of 1 updated replicas are available...
deployment "olm-operator" successfully rolled out
+ kubectl rollout status -w deployment/catalog-operator --namespace=olm
deployment "catalog-operator" successfully rolled out
+ retries=30
+ [[ 30 == 0 ]]
++ kubectl get csv -n olm packageserver -o 'jsonpath={.status.phase}'
+ new_csv_phase=Installing
+ [[ Installing != '' ]]
+ csv_phase=Installing
+ echo 'Package server phase: Installing'
Package server phase: Installing
+ [[ Installing == \S\u\c\c\e\e\d\e\d ]]
+ sleep 10
+ retries=29
+ [[ 29 == 0 ]]
++ kubectl get csv -n olm packageserver -o 'jsonpath={.status.phase}'
+ new_csv_phase=Installing
+ [[ Installing != \I\n\s\t\a\l\l\i\n\g ]]
+ [[ Installing == \S\u\c\c\e\e\d\e\d ]]
+ sleep 10
+ retries=28
+ [[ 28 == 0 ]]
++ kubectl get csv -n olm packageserver -o 'jsonpath={.status.phase}'
+ new_csv_phase=Installing
+ [[ Installing != \I\n\s\t\a\l\l\i\n\g ]]
+ [[ Installing == \S\u\c\c\e\e\d\e\d ]]
+ sleep 10
+ retries=27
+ [[ 27 == 0 ]]
++ kubectl get csv -n olm packageserver -o 'jsonpath={.status.phase}'
+ new_csv_phase=Succeeded
+ [[ Succeeded != \I\n\s\t\a\l\l\i\n\g ]]
+ csv_phase=Succeeded
+ echo 'Package server phase: Succeeded'
Package server phase: Succeeded
+ [[ Succeeded == \S\u\c\c\e\e\d\e\d ]]
+ break
+ '[' 27 == 0 ']'
+ kubectl rollout status -w deployment/packageserver --namespace=olm
deployment "packageserver" successfully rolled out
$

```

2. 验证 OLM 安装的资源

```bash
$ kubectl get customresourcedefinition
NAME                                          CREATED AT
catalogsources.operators.coreos.com           2020-11-09T12:45:48Z
clusterserviceversions.operators.coreos.com   2020-11-09T12:45:48Z
installplans.operators.coreos.com             2020-11-09T12:45:48Z
operatorgroups.operators.coreos.com           2020-11-09T12:45:48Z
operators.operators.coreos.com                2020-11-09T12:45:48Z
subscriptions.operators.coreos.com            2020-11-09T12:45:48Z
$

$ kubectl get ns olm operators
NAME        STATUS   AGE
olm         Active   13m
operators   Active   13m
$

$ kubectl -n olm get ServiceAccount
NAME                          SECRETS   AGE
default                       1         15m
olm-operator-serviceaccount   1         15m
$

$ kubectl get ClusterRole system:controller:operator-lifecycle-manager
NAME                                           CREATED AT
system:controller:operator-lifecycle-manager   2020-11-09T12:45:56Z
$

$ kubectl get ClusterRoleBinding olm-operator-binding-olm -o wide
NAME                       ROLE                                                       AGE   USERS   GROUPS   SERVICEACCOUNTS
olm-operator-binding-olm   ClusterRole/system:controller:operator-lifecycle-manager   17m                    olm/olm-operator-serviceaccount
$

$ kubectl -n olm get deployment olm-operator
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
olm-operator   1/1     1            1           18m
$

$ kubectl -n olm get deployment catalog-operator
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
catalog-operator   1/1     1            1           19m
$
$ kubectl get ClusterRole aggregate-olm-edit aggregate-olm-view
NAME                 CREATED AT
aggregate-olm-edit   2020-11-09T12:45:56Z
aggregate-olm-view   2020-11-09T12:45:56Z
$

$ kubectl -n operators get OperatorGroup
NAME               AGE
global-operators   22m
$
$ kubectl -n olm get OperatorGroup
NAME            AGE
olm-operators   23m
$

$ kubectl -n olm get ClusterServiceVersion packageserver
NAME            DISPLAY          VERSION   REPLACES   PHASE
packageserver   Package Server   0.16.1               Succeeded
$
$ kubectl -n olm get deployment packageserver
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
packageserver   2/2     2            2           26m
$

$ kubectl -n olm get CatalogSource operatorhubio-catalog
NAME                    DISPLAY               TYPE   PUBLISHER        AGE
operatorhubio-catalog   Community Operators   grpc   OperatorHub.io   28m
$

```

3. 使用 OLM 自带的 catalog 安装 strimzi kafka operator

```bash
$ kubectl create -f https://operatorhub.io/install/stable/strimzi-kafka-operator.yaml
subscription.operators.coreos.com/my-strimzi-kafka-operator created

$ cat << EOF > strimzi-kafka-operator.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-strimzi-kafka-operator
  namespace: operators
spec:
  channel: stable
  name: strimzi-kafka-operator
  source: operatorhubio-catalog
  sourceNamespace: olm

EOF

# strimzi kafka operator 相关的自定义资源以及被安装
$ kubectl get crd
NAME                                          CREATED AT
catalogsources.operators.coreos.com           2020-11-10T01:04:54Z
clusterserviceversions.operators.coreos.com   2020-11-10T01:04:54Z
installplans.operators.coreos.com             2020-11-10T01:04:54Z
operatorgroups.operators.coreos.com           2020-11-10T01:04:54Z
operators.operators.coreos.com                2020-11-10T01:04:54Z
subscriptions.operators.coreos.com            2020-11-10T01:04:54Z

kafkabridges.kafka.strimzi.io                 2020-11-10T01:08:39Z
kafkaconnectors.kafka.strimzi.io              2020-11-10T01:08:39Z
kafkaconnects.kafka.strimzi.io                2020-11-10T01:08:39Z
kafkaconnects2is.kafka.strimzi.io             2020-11-10T01:08:40Z
kafkamirrormaker2s.kafka.strimzi.io           2020-11-10T01:08:40Z
kafkamirrormakers.kafka.strimzi.io            2020-11-10T01:08:39Z
kafkarebalances.kafka.strimzi.io              2020-11-10T01:08:40Z
kafkas.kafka.strimzi.io                       2020-11-10T01:08:41Z
kafkatopics.kafka.strimzi.io                  2020-11-10T01:08:39Z
kafkausers.kafka.strimzi.io                   2020-11-10T01:08:39Z
$

```


4. 准备自定义的 catalog 安装需要的镜像

```bash
# 从 community-operators 拷贝相关文件
$ git clone https://github.com/operator-framework/community-operators.git

$ cp community-operators/upstream-community-operators/strimzi-kafka-operator/0.18.0/* ./

# 生成 annotations.yaml
$ opm alpha bundle generate --directory ./manifests --package strimzi-cluster-operator.v0.18.0 --channels stable --default stable
INFO[0000] Building annotations.yaml
INFO[0000] Writing annotations.yaml in /Users/huzhi/work/code/go_code/olm/kafka/metadata
INFO[0000] Building Dockerfile
INFO[0000] Writing bundle.Dockerfile in /Users/huzhi/work/code/go_code/olm/kafka
$

$ tree -a .
.
├── bundle.Dockerfile
├── manifests
│   ├── kafkabridges.kafka.strimzi.io.crd.yaml
│   ├── kafkaconnectors.kafka.strimzi.io.yaml
│   ├── kafkaconnects.kafka.strimzi.io.crd.yaml
│   ├── kafkaconnects2is.kafka.strimzi.io.crd.yaml
│   ├── kafkamirrormaker2s.kafka.strimzi.io.crd.yaml
│   ├── kafkamirrormakers.kafka.strimzi.io.crd.yaml
│   ├── kafkarebalances.kafka.strimzi.io.crd.yaml
│   ├── kafkas.kafka.strimzi.io.crd.yaml
│   ├── kafkatopics.kafka.strimzi.io.crd.yaml
│   ├── kafkausers.kafka.strimzi.io.crd.yaml
│   ├── strimzi-cluster-operator.v0.18.0.clusterserviceversion.yaml
│   ├── strimzientityoperator.clusterrole.yaml
│   ├── strimzikafkabroker.clusterrole.yaml
│   └── strimzitopicoperator.clusterrole.yaml
└── metadata
    └── annotations.yaml

2 directories, 16 files
$

$ sed -i '' 's/replaces: strimzi-cluster-operator.v0.17.0/#replaces: strimzi-cluster-operator.v0.17.0/' manifests/strimzi-cluster-operator.v0.18.0.clusterserviceversion.yaml

$ docker build -t lanzhiwang/my-manifest-bundle:latest -f bundle.Dockerfile .

$ docker push lanzhiwang/my-manifest-bundle:latest

$ opm index add --bundles lanzhiwang/my-manifest-bundle:latest --tag lanzhiwang/index:1.0.0 -p docker -u docker

$ docker push lanzhiwang/index:1.0.0

```

4. 安装自定义的 catalog

```bash
$ kubectl create ns kafka

$ cat << EOF > example-manifests.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: example-catalog
  namespace: kafka
spec:
  sourceType: grpc
  image: lanzhiwang/index:1.0.0
  displayName: example
  publisher: example.io
EOF

$ kubectl -n kafka apply -f example-manifests.yaml
catalogsource.operators.coreos.com/example-catalog created

$ kubectl -n kafka get catalogsource example-catalog -o yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"operators.coreos.com/v1alpha1","kind":"CatalogSource","metadata":{"annotations":{},"name":"example-catalog","namespace":"kafka"},"spec":{"displayName":"example","image":"lanzhiwang/index:1.0.0","publisher":"example.io","sourceType":"grpc"}}
  creationTimestamp: "2020-11-10T08:15:45Z"
  generation: 1
  managedFields:
  - apiVersion: operators.coreos.com/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:kubectl.kubernetes.io/last-applied-configuration: {}
      f:spec:
        .: {}
        f:displayName: {}
        f:image: {}
        f:publisher: {}
        f:sourceType: {}
    manager: kubectl-client-side-apply
    operation: Update
    time: "2020-11-10T08:15:45Z"
  - apiVersion: operators.coreos.com/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:spec:
        f:icon:
          .: {}
          f:base64data: {}
          f:mediatype: {}
      f:status:
        .: {}
        f:connectionState:
          .: {}
          f:address: {}
          f:lastConnect: {}
          f:lastObservedState: {}
        f:registryService:
          .: {}
          f:createdAt: {}
          f:port: {}
          f:protocol: {}
          f:serviceName: {}
          f:serviceNamespace: {}
    manager: catalog
    operation: Update
    time: "2020-11-10T08:16:27Z"
  name: example-catalog
  namespace: kafka
  resourceVersion: "1717"
  selfLink: /apis/operators.coreos.com/v1alpha1/namespaces/kafka/catalogsources/example-catalog
  uid: 4c5f4c44-372f-486a-8b02-f149bfcea14a
spec:
  displayName: example
  image: lanzhiwang/index:1.0.0
  publisher: example.io
  sourceType: grpc
status:
  connectionState:
    address: example-catalog.kafka.svc:50051
    lastConnect: "2020-11-10T08:16:27Z"
    lastObservedState: READY
  registryService:
    createdAt: "2020-11-10T08:15:45Z"
    port: "50051"
    protocol: grpc
    serviceName: example-catalog
    serviceNamespace: kafka

$ kubectl -n kafka get packagemanifests strimzi-cluster-operator.v0.18.0
NAME                               CATALOG   AGE
strimzi-cluster-operator.v0.18.0   example   84s
$

$ kubectl -n kafka get packagemanifests strimzi-cluster-operator.v0.18.0 -o jsonpath='{.status.defaultChannel}'
stable
$

```

5. 安装 Subscription 和 OperatorGroup

```bash
$ cat << EOF > kafka-group.yaml
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: kafka-group
  namespace: kafka
spec:
  targetNamespaces:
  - kafka

EOF


$ cat << EOF > kafka-subscription.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kafka-subscription
  namespace: kafka 
spec:
  channel: stable
  name: strimzi-cluster-operator.v0.18.0
  source: example-catalog
  sourceNamespace: kafka

EOF

$ kubectl -n kafka get Subscription kafka-subscription -o yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"operators.coreos.com/v1alpha1","kind":"Subscription","metadata":{"annotations":{},"name":"kafka-subscription","namespace":"kafka"},"spec":{"channel":"stable","name":"strimzi-cluster-operator.v0.18.0","source":"example-catalog","sourceNamespace":"kafka"}}
  creationTimestamp: "2020-11-13T05:49:10Z"
  generation: 1
  labels:
    operators.coreos.com/strimzi-cluster-operator.v0.18.0.kafka: ""
  managedFields:
  - apiVersion: operators.coreos.com/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:kubectl.kubernetes.io/last-applied-configuration: {}
      f:spec:
        .: {}
        f:channel: {}
        f:name: {}
        f:source: {}
        f:sourceNamespace: {}
    manager: kubectl-client-side-apply
    operation: Update
    time: "2020-11-13T05:49:10Z"
  - apiVersion: operators.coreos.com/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:labels:
          .: {}
          f:operators.coreos.com/strimzi-cluster-operator.v0.18.0.kafka: {}
    manager: olm
    operation: Update
    time: "2020-11-13T05:49:11Z"
  - apiVersion: operators.coreos.com/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:spec:
        f:config:
          .: {}
          f:resources: {}
      f:status:
        .: {}
        f:catalogHealth: {}
        f:conditions: {}
        f:currentCSV: {}
        f:installPlanGeneration: {}
        f:installPlanRef:
          .: {}
          f:apiVersion: {}
          f:kind: {}
          f:name: {}
          f:namespace: {}
          f:resourceVersion: {}
          f:uid: {}
        f:installedCSV: {}
        f:installplan:
          .: {}
          f:apiVersion: {}
          f:kind: {}
          f:name: {}
          f:uuid: {}
        f:lastUpdated: {}
        f:state: {}
    manager: catalog
    operation: Update
    time: "2020-11-13T05:49:45Z"
  name: kafka-subscription
  namespace: kafka
  resourceVersion: "1208"
  selfLink: /apis/operators.coreos.com/v1alpha1/namespaces/kafka/subscriptions/kafka-subscription
  uid: f9d695c3-af4d-49a0-8050-a0d49eed2da2
spec:
  channel: stable
  name: strimzi-cluster-operator.v0.18.0
  source: example-catalog
  sourceNamespace: kafka
status:
  catalogHealth:
  - catalogSourceRef:
      apiVersion: operators.coreos.com/v1alpha1
      kind: CatalogSource
      name: example-catalog
      namespace: kafka
      resourceVersion: "1050"
      uid: 9e9d4012-7003-40b4-9bb6-4c6c17e22530
    healthy: true
    lastUpdated: "2020-11-13T05:49:12Z"
  - catalogSourceRef:
      apiVersion: operators.coreos.com/v1alpha1
      kind: CatalogSource
      name: operatorhubio-catalog
      namespace: olm
      resourceVersion: "856"
      uid: 973696bd-c6eb-4799-96b6-615bded17e5f
    healthy: true
    lastUpdated: "2020-11-13T05:49:12Z"
  conditions:
  - lastTransitionTime: "2020-11-13T05:49:12Z"
    message: all available catalogsources are healthy
    reason: AllCatalogSourcesHealthy
    status: "False"
    type: CatalogSourcesUnhealthy
  currentCSV: strimzi-cluster-operator.v0.18.0
  installPlanGeneration: 1
  installPlanRef:
    apiVersion: operators.coreos.com/v1alpha1
    kind: InstallPlan
    name: install-ck5lv
    namespace: kafka
    resourceVersion: "1034"
    uid: 4582c965-597b-4935-9106-fd69b71b9dd4
  installedCSV: strimzi-cluster-operator.v0.18.0
  installplan:
    apiVersion: operators.coreos.com/v1alpha1
    kind: InstallPlan
    name: install-ck5lv
    uuid: 4582c965-597b-4935-9106-fd69b71b9dd4
  lastUpdated: "2020-11-13T05:49:45Z"
  state: AtLatestKnown
$
$ kubectl -n kafka get ip install-ck5lv -o yaml


```

6. 本地验证

```bash
$ ./operator-registry/bin/initializer -m ./kafka/manifests/ -o sqlite.db

$ ./operator-registry/bin/registry-server -d sqlite.db
WARN[0000] unable to set termination log path            error="open /dev/termination-log: operation not permitted"
INFO[0000] serving registry                              database=sqlite.db port=50051


$ grpcurl -plaintext  localhost:50051 list api.Registry
api.Registry.GetBundle
api.Registry.GetBundleForChannel
api.Registry.GetBundleThatReplaces
api.Registry.GetChannelEntriesThatProvide
api.Registry.GetChannelEntriesThatReplace
api.Registry.GetDefaultBundleThatProvides
api.Registry.GetLatestChannelEntriesThatProvide
api.Registry.GetPackage
api.Registry.ListBundles
api.Registry.ListPackages

# 没有找到 Packages
$ grpcurl -plaintext  localhost:50051 api.Registry/ListPackages

```


