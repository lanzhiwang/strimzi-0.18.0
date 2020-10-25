## 使用 OperatorHub.io 管理 Strimzi

https://operatorhub.io/operator/strimzi-kafka-operator

### 具体步骤

1. Install Operator Lifecycle Manager (OLM), a tool to help manage the Operators running on your cluster.

```bash
$ curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/install.sh | bash -s 0.16.1
```

2. Install the operator by running the following command:

```bash
$ kubectl create -f https://operatorhub.io/install/stable/strimzi-kafka-operator.yaml
```

This Operator will be installed in the "operators" namespace and will be usable from all namespaces in the cluster.

3. After install, watch your operator come up using next command.

```bash
$ kubectl get csv -n operators
```

To use it, checkout the custom resource definitions (CRDs) introduced by this operator to start using it.

### 步骤说明

###### https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/install.sh

```bash
#!/usr/bin/env bash


# This script is for installing OLM from a GitHub release

set -e

if [[ ${#@} -ne 1 ]]; then
    echo "Usage: $0 version"
    echo "* version: the github release version"
    exit 1
fi

release=$1
url=https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${release}
namespace=olm

kubectl apply -f "${url}/crds.yaml"
kubectl wait --for=condition=Established -f "${url}/crds.yaml"
kubectl apply -f "${url}/olm.yaml"

# wait for deployments to be ready
kubectl rollout status -w deployment/olm-operator --namespace="${namespace}"
kubectl rollout status -w deployment/catalog-operator --namespace="${namespace}"

retries=30
until [[ $retries == 0 ]]; do
    new_csv_phase=$(kubectl get csv -n "${namespace}" packageserver -o jsonpath='{.status.phase}' 2>/dev/null || echo "Waiting for CSV to appear")
    if [[ $new_csv_phase != "$csv_phase" ]]; then
        csv_phase=$new_csv_phase
        echo "Package server phase: $csv_phase"
    fi
    if [[ "$new_csv_phase" == "Succeeded" ]]; then
	break
    fi
    sleep 10
    retries=$((retries - 1))
done

if [ $retries == 0 ]; then
    echo "CSV \"packageserver\" failed to reach phase succeeded"
    exit 1
fi

kubectl rollout status -w deployment/packageserver --namespace="${namespace}"

```

###### https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/crds.yaml

| CustomResourceDefinition |
| ------------------------ |
| CatalogSource            |
| ClusterServiceVersion    |
| InstallPlan              |
| OperatorGroup            |
| Operator                 |
| Subscription             |


###### https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.16.1/olm.yaml


| Namespace | ServiceAccount              | ClusterRole                                  | ClusterRoleBinding       | Deployment       | OperatorGroup    | ClusterServiceVersion | CatalogSource         |
| --------- | --------------------------- | -------------------------------------------- | ------------------------ | ---------------- | ---------------- | --------------------- | --------------------- |
| olm       | olm-operator-serviceaccount | system:controller:operator-lifecycle-manager | olm-operator-binding-olm | olm-operator     | global-operators | packageserver         | operatorhubio-catalog |
| operators |                             | aggregate-olm-edit                           |                          | catalog-operator | olm-operators    |                       |                       |
|           |                             | aggregate-olm-view                           |                          |                  |                  |                       |                       |

###### https://operatorhub.io/install/stable/strimzi-kafka-operator.yaml

```yaml
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
```



| 资源名称              | 简称   | 所属 Operator | 描述                                                         |
| --------------------- | ------ | ------------- | ------------------------------------------------------------ |
| ClusterServiceVersion | CSV    | OLM           | 业务应用的元数据，包括应用名称、版本、图标、依赖资源、安装方式等信息 |
| InstallPlan           | ip     | Catalog       | 计算自动安装或升级 CSV 过程中需要创建的资源集                |
| CatalogSource         | catsrc | Catalog       | 用于定义应用的 CSVs，CRDs，或是安装包的仓库                  |
| Subscription          | sub    | Catalog       | 通过跟踪安装包中的 channel 保证 CSVs 的版本更新              |
| OperatorGroup         | og     | OLM           | 用于 Operators 安装过程中的多租配置，可以定义一组目标 namespaces 指定创建 Operators 所需的 RBAC 等资源配置 |