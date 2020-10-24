https://operatorhub.io/operator/strimzi-kafka-operator




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





https://github.com/operator-framework/getting-started/





## Manage the operator using the Operator Lifecycle Manager

> NOTE: This section of the Getting Started Guide is out-of-date. We're working on some improvements to Operator SDK to streamline the experience of using OLM. For further information see, for example, this enhancement [proposal](https://github.com/operator-framework/operator-sdk/blob/master/proposals/sdk-integration-with-olm.md ). In the meantime, you might find the following documentation helpful: 《入门指南》的本节已过时。 我们正在对Operator SDK进行一些改进，以简化使用OLM的体验。 有关更多信息，请参见此增强功能提案。 同时，您可能会发现以下文档会有所帮助：

The previous section has covered manually running an operator. In the next sections, we will explore using the [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager) (OLM) which is what enables a more robust deployment model for operators being run in production environments.  上一节介绍了手动运行操作员。 在下一部分中，我们将探索使用操作员生命周期管理器（OLM）的方法，该方法为在生产环境中运行的操作员提供了更强大的部署模型。

OLM helps you to install, update, and generally manage the lifecycle of all of the operators (and their associated services) on a Kubernetes cluster. It runs as an Kubernetes extension and lets you use `kubectl` for all the lifecycle management functions without any additional tools.  OLM可帮助您在Kubernetes集群上安装，更新和总体管理所有操作员（及其相关服务）的生命周期。 它作为Kubernetes扩展运行，可让您将kubectl用于所有生命周期管理功能，而无需任何其他工具。

**NOTE:** Various public, OLM-ready operator projects are available at [operatorhub.io](https://operatorhub.io/).  可在operatorhub.io上获得各种支持OLM的公共运营商项目。

### Generate an operator manifest

The first step to leveraging OLM is to create a [Cluster Service Version](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/design/building-your-csv.md) (CSV) manifest. An operator manifest describes how to display, create and manage the application, in this case memcached, as a whole. It is required for OLM to function. 利用OLM的第一步是创建群集服务版本（CSV）清单。 操作员清单描述了整体上如何显示，创建和管理应用程序（在本例中为memcached）。 OLM起作用是必需的。

The Operator SDK CLI can generate CSV manifests via the following command:

```console
$ operator-sdk generate csv --csv-version 0.0.1 --update-crds
```

Several fields must be updated after generating the CSV. See the CSV generation doc for a list of [required fields](https://sdk.operatorframework.io/docs/olm-integration/generating-a-csv/), and the memcached-operator [CSV](https://github.com/operator-framework/operator-sdk/blob/master/test/test-framework/deploy/olm-catalog/memcached-operator/0.0.3/memcached-operator.v0.0.3.clusterserviceversion.yaml) for an example of a complete CSV.

**NOTE:** You are able to preview and validate your CSV manifest syntax in the [operatorhub.io CSV Preview](https://operatorhub.io/preview) tool.

### Testing locally

The next step is to ensure your project deploys correctly with OLM and runs as expected. Follow this [testing guide](https://github.com/operator-framework/community-operators/blob/master/docs/testing-operators.md) to deploy and test your operator.

**NOTE:** Also, check out some of the new OLM integrations in operator-sdk:

- [`operator-sdk olm`](https://sdk.operatorframework.io/docs/cli/operator-sdk_olm/) to install and manage an OLM installation in your cluster.
- [`operator-sdk run --olm`](https://sdk.operatorframework.io/docs/cli/operator-sdk_run/) to run your operator using the CSV generated by `operator-sdk generate csv`.
- [`operator-sdk bundle`](https://sdk.operatorframework.io/docs/cli/operator-sdk_bundle/ ) to create and validate operator bundle images.

### Promoting operator standards  促进运营商标准

We recommend running `operator-sdk scorecard` against your operator to see whether your operator's OLM integration follows best practices. For further information on running the scorecard and results, see the [scorecard documentation](https://sdk.operatorframework.io/docs/scorecard/).  我们建议对您的运营商运行operator-sdk记分卡，以查看您的运营商的OLM集成是否遵循最佳实践。 有关运行记分卡和结果的更多信息，请参阅记分卡文档。

**NOTE:** the scorecard is undergoing changes to give informative and helpful feedback. The original scorecard functionality will still be available while and after changes are made.  计分卡正在进行更改，以提供有用的反馈信息。 进行更改时和更改后，原始的计分卡功能仍然可用。







https://aijishu.com/a/1060000000136799





