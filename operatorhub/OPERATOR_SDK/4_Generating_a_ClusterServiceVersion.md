## 12.4. Generating a ClusterServiceVersion (CSV)

https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/operators/operator-sdk#osdk-generating-csvs

A *ClusterServiceVersion* (CSV) is a YAML manifest created from Operator metadata that assists the Operator Lifecycle Manager (OLM) in running the Operator in a cluster. It is the metadata that accompanies an Operator container image, used to populate user interfaces with information like its logo, description, and version. It is also a source of technical information that is required to run the Operator, like the RBAC rules it requires and which Custom Resources (CRs) it manages or depends on.  ClusterServiceVersion（CSV）是从操作员元数据创建的YAML清单，可帮助操作员生命周期管理器（OLM）在集群中运行操作员。 它是Operator容器图像随附的元数据，用于用徽标，说明和版本等信息填充用户界面。 它也是运行操作员所需的技术信息的来源，例如它要求的RBAC规则以及它管理或依赖的自定义资源（CR）。

The Operator SDK includes the `generate csv` subcommand to generate a *ClusterServiceVersion* (CSV) for the current Operator project customized using information contained in manually-defined YAML manifests and Operator source files.  Operator SDK包含generate csv子命令，用于为使用手动定义的YAML清单和Operator源文件中包含的信息自定义的当前Operator项目生成ClusterServiceVersion（CSV）。

A CSV-generating command removes the responsibility of Operator authors having in-depth OLM knowledge in order for their Operator to interact with OLM or publish metadata to the Catalog Registry. Further, because the CSV spec will likely change over time as new Kubernetes and OLM features are implemented, the Operator SDK is equipped to easily extend its update system to handle new CSV features going forward.  CSV生成命令消除了具有深入OLM知识的操作员作者的责任，以便他们的操作员与OLM进行交互或将元数据发布到目录注册表。 此外，由于随着新的Kubernetes和OLM功能的实施，CSV规范可能会随时间变化，因此Operator SDK可以轻松扩展其更新系统，以处理将来的新CSV功能。

The CSV version is the same as the Operator’s, and a new CSV is generated when upgrading Operator versions. Operator authors can use the `--csv-version` flag to have their Operators' state encapsulated in a CSV with the supplied semantic version:

```
$ operator-sdk generate csv --csv-version <version>
```

This action is idempotent and only updates the CSV file when a new version is supplied, or a YAML manifest or source file is changed. Operator authors should not have to directly modify most fields in a CSV manifest. Those that require modification are defined in this guide. For example, the CSV version must be included in `metadata.name`.  此操作是幂等的，仅在提供新版本或更改了YAML清单或源文件时才更新CSV文件。 操作员作者不必直接修改CSV清单中的大多数字段。 本指南定义了需要修改的内容。 例如，CSV版本必须包含在metadata.name中。

### 12.4.1. How CSV generation works

An Operator project’s `deploy/` directory is the standard location for all manifests required to deploy an Operator. The Operator SDK can use data from manifests in `deploy/` to write a CSV. The following command:

```
$ operator-sdk generate csv --csv-version <version>
```

writes a CSV YAML file to the `deploy/olm-catalog/` directory by default.

Exactly three types of manifests are required to generate a CSV:

- `operator.yaml`
- `*_{crd,cr}.yaml`
- RBAC role files, for example `role.yaml`

Operator authors may have different versioning requirements for these files and can configure which specific files are included in the `deploy/olm-catalog/csv-config.yaml` file.

##### Workflow

Depending on whether an existing CSV is detected, and assuming all configuration defaults are used, the `generate csv` subcommand either:  取决于是否检测到现有的CSV，并假设使用了所有配置缺省值，generate csv子命令之一：

- Creates a new CSV, with the same location and naming convention as exists currently, using available data in YAML manifests and source files.  使用YAML清单和源文件中的可用数据，以与当前相同的位置和命名约定创建新的CSV。
  1. The update mechanism checks for an existing CSV in `deploy/`. When one is not found, it creates a ClusterServiceVersion object, referred to here as a *cache*, and populates fields easily derived from Operator metadata, such as Kubernetes API `ObjectMeta`.  更新机制检查deploy/中是否存在现有CSV。 如果找不到该对象，它将创建一个ClusterServiceVersion对象（在此称为缓存），并填充易于从操作员元数据派生的字段，例如Kubernetes API ObjectMeta。
  2. The update mechanism searches `deploy/` for manifests that contain data a CSV uses, such as a Deployment resource, and sets the appropriate CSV fields in the cache with this data.  更新机制会在deploy /中搜索包含CSV使用的数据（例如Deployment资源）的清单，并使用此数据在缓存中设置适当的CSV字段。
  3. After the search completes, every cache field populated is written back to a CSV YAML file.  搜索完成后，将填充的每个缓存字段写回到CSV YAML文件。

or:

- Updates an existing CSV at the currently pre-defined location, using available data in YAML manifests and source files.  使用YAML清单和源文件中的可用数据在当前预定义的位置更新现有CSV。
  1. The update mechanism checks for an existing CSV in `deploy/`. When one is found, the CSV YAML file contents are marshaled into a ClusterServiceVersion cache.  更新机制检查deploy/中是否存在现有CSV。 找到一个后，CSV YAML文件内容将编组到ClusterServiceVersion缓存中。
  2. The update mechanism searches `deploy/` for manifests that contain data a CSV uses, such as a Deployment resource, and sets the appropriate CSV fields in the cache with this data.  更新机制会在deploy/中搜索包含CSV使用的数据（例如Deployment资源）的清单，并使用此数据在缓存中设置适当的CSV字段。
  3. After the search completes, every cache field populated is written back to a CSV YAML file.  搜索完成后，将填充的每个缓存字段写回到CSV YAML文件。

> NOTE：Individual YAML fields are overwritten and not the entire file, as descriptions and other non-generated parts of a CSV should be preserved.  单个YAML字段将被覆盖，而不是整个文件，因为应保留CSV的说明和其他未生成的部分。

### 12.4.2. CSV composition configuration

Operator authors can configure CSV composition by populating several fields in the `deploy/olm-catalog/csv-config.yaml` file:

| Field                                  | Description                                                  |
| :------------------------------------- | :----------------------------------------------------------- |
| `operator-path` (string)               | The Operator resource manifest file path. Defaults to `deploy/operator.yaml`. |
| `crd-cr-path-list` (string(, string)*) | A list of CRD and CR manifest file paths. Defaults to `[deploy/crds/*_{crd,cr}.yaml]`. |
| `rbac-path-list` (string(, string)*)   | A list of RBAC role manifest file paths. Defaults to `[deploy/role.yaml]`. |

### 12.4.3. Manually-defined CSV fields

Many CSV fields cannot be populated using generated, non-SDK-specific manifests. These fields are mostly human-written, English metadata about the Operator and various Custom Resource Definitions (CRDs).  无法使用生成的非SDK专用清单填充许多CSV字段。 这些字段大多是人工编写的有关操作员和各种自定义资源定义（CRD）的英文元数据。

Operator authors must directly modify their CSV YAML file, adding personalized data to the following required fields. The Operator SDK gives a warning CSV generation when a lack of data in any of the required fields is detected.  操作员作者必须直接修改其CSV YAML文件，并将个性化数据添加到以下必填字段。 当在任何必填字段中检测到数据不足时，Operator SDK会发出警告CSV生成警告。

**Table 12.5. Required**

| Field                            | Description                                                  |
| :------------------------------- | :----------------------------------------------------------- |
| `metadata.name`                  | A unique name for this CSV. Operator version should be included in the name to ensure uniqueness, for example `app-operator.v0.1.1`. |
| `metadata.capabilities`          | The Operator’s capability level according to the Operator maturity model. Options include `Basic Install`, `Seamless Upgrades`, `Full Lifecycle`, `Deep Insights`, and `Auto Pilot`. |
| `spec.displayName`               | A public name to identify the Operator.                      |
| `spec.description`               | A short description of the Operator’s functionality.         |
| `spec.keywords`                  | Keywords describing the operator.                            |
| `spec.maintainers`               | Human or organizational entities maintaining the Operator, with a `name` and `email`. |
| `spec.provider`                  | The Operators' provider (usually an organization), with a `name`. |
| `spec.labels`                    | Key-value pairs to be used by Operator internals.            |
| `spec.version`                   | Semantic version of the Operator, for example `0.1.1`.       |
| `spec.customresourcedefinitions` | Any CRDs the Operator uses. This field is populated automatically by the Operator SDK if any CRD YAML files are present in `deploy/`. However, several fields not in the CRD manifest spec require user input: 1、`description`: description of the CRD. 2、`resources`: any Kubernetes resources leveraged by the CRD, for example Pods and StatefulSets. 3、`specDescriptors`: UI hints for inputs and outputs of the Operator.  运营商使用的所有CRD。 如果deploy /中存在任何CRD YAML文件，则该字段由Operator SDK自动填充。 但是，CRD清单规范中未包含的几个字段需要用户输入： |

**Table 12.6. Optional**

| Field           | Description                                                  |
| :-------------- | :----------------------------------------------------------- |
| `spec.replaces` | The name of the CSV being replaced by this CSV.  CSV的名称被该CSV取代。 |
| `spec.links`    | URLs (for example, websites and documentation) pertaining to the Operator or application being managed, each with a `name` and `url`. |
| `spec.selector` | Selectors by which the Operator can pair resources in a cluster. |
| `spec.icon`     | A base64-encoded icon unique to the Operator, set in a `base64data` field with a `mediatype`. |
| `spec.maturity` | The level of maturity the software has achieved at this version. Options include `planning`, `pre-alpha`, `alpha`, `beta`, `stable`, `mature`, `inactive`, and `deprecated`. |

Further details on what data each field above should hold are found in the [CSV spec](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/design/building-your-csv.md).

> NOTE：Several YAML fields currently requiring user intervention can potentially be parsed from Operator code; such Operator SDK functionality will be addressed in a future design document.  可以从操作员代码中解析当前需要用户干预的多个YAML字段； 这样的Operator SDK功能将在以后的设计文档中讨论。

**Additional resources**

- [Operator maturity model](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html-single/operators/#olm-maturity-model_olm-what-operators-are)

### 12.4.4. Generating a CSV

**Prerequisites**

- An Operator project generated using the Operator SDK

**Procedure**

1. In your Operator project, configure your CSV composition by modifying the `deploy/olm-catalog/csv-config.yaml` file, if desired.

2. Generate the CSV:

   ```
   $ operator-sdk generate csv --csv-version <version>
   ```

3. In the new CSV generated in the `deploy/olm-catalog/` directory, ensure all required, manually-defined fields are set appropriately.

### 12.4.5. Enabling your Operator for restricted network environments  使运营商能够在受限的网络环境中使用

As an Operator author, your CSV must meet the following additional requirements for your Operator to run properly in a restricted network environment:  作为操作员作者，您的CSV必须满足以下附加要求，才能使操作员在受限的网络环境中正常运行：

- List any *related images*, or other container images that your Operator might require to perform their functions.
- Reference all specified images by a digest (SHA) and not by a tag.

You must use SHA references to related images in two places in the Operator’s CSV:

- in `spec.relatedImages`:

  ```yaml
  ...
  spec:
    # Create a relatedImages section and set the list of related images.
    relatedImages:
        # Specify a unique identifier for the image.
      - name: etcd-operator
        # Specify each image by a digest (SHA), not by an image tag.
        image: quay.io/etcd-operator/operator@sha256:d134a9865524c29fcf75bbc4469013bc38d8a15cb5f41acfddb6b9e492f556e4 
      - name: etcd-image
        image: quay.io/etcd-operator/etcd@sha256:13348c15263bd8838ec1d5fc4550ede9860fcbb0f843e48cbccec07810eebb68
  ...
  ```

- in the `env` section of the Operators Deployments when declaring environment variables that inject the image that the Operator should use:

  ```yaml
  spec:
    install:
      spec:
        deployments:
        - name: etcd-operator-v3.1.1
          spec:
            replicas: 1
            selector:
              matchLabels:
                name: etcd-operator
            strategy:
              type: Recreate
            template:
              metadata:
                labels:
                  name: etcd-operator
              spec:
                containers:
                - args:
                  - /opt/etcd/bin/etcd_operator_run.sh
                  env:
                  - name: WATCH_NAMESPACE
                    valueFrom:
                      fieldRef:
                        fieldPath: metadata.annotations['olm.targetNamespaces']
                  - name: ETCD_OPERATOR_DEFAULT_ETCD_IMAGE
                    value: quay.io/etcd-operator/etcd@sha256:13348c15263bd8838ec1d5fc4550ede9860fcbb0f843e48cbccec07810eebb68
                  - name: ETCD_LOG_LEVEL
                    value: INFO
                  image: quay.io/etcd-operator/operator@sha256:d134a9865524c29fcf75bbc4469013bc38d8a15cb5f41acfddb6b9e492f556e4 
                  imagePullPolicy: IfNotPresent
                  livenessProbe:
                    httpGet:
                      path: /healthy
                      port: 8080
                    initialDelaySeconds: 10
                    periodSeconds: 30
                  name: etcd-operator
                  readinessProbe:
                    httpGet:
                      path: /ready
                      port: 8080
                    initialDelaySeconds: 10
                    periodSeconds: 30
                  resources: {}
                serviceAccountName: etcd-operator
      strategy: deployment
  ```


### 12.4.6. Enabling your Operator for multiple architectures and operating systems

Operator Lifecycle Manager (OLM) assumes that all Operators run on Linux hosts. However, as an Operator author, you can specify whether your Operator supports managing workloads on other architectures, if worker nodes are available in the OpenShift Container Platform cluster.

If your Operator supports variants other than AMD64 and Linux, you can add labels to the CSV that provides the Operator to list the supported variants. Labels indicating supported architectures and operating systems are defined by the following:  如果您的操作员支持AMD64和Linux以外的其他变体，则可以将标签添加到CSV，以便为操作员列出支持的变体。 指示受支持的体系结构和操作系统的标签由以下定义：

```yaml
labels:
    operatorframework.io/arch.<arch>: supported 1
    operatorframework.io/os.<os>: supported 2
```

> NOTE：Only the labels on the channel head of the default channel are considered for filtering PackageManifests by label. This means, for example, that providing an additional architecture for an Operator in the non-default channel is possible, but that architecture is not available for filtering in the PackageManifest API.  仅考虑默认通道的通道头上的标签，才能按标签过滤PackageManifests。 例如，这意味着可以在非默认通道中为操作员提供其他体系结构，但是该体系结构不可用于PackageManifest API中的过滤。

If a CSV does not include an `os` label, it is treated as if it has the following Linux support label by default:

```yaml
labels:
    operatorframework.io/os.linux: supported
```

If a CSV does not include an `arch` label, it is treated as if it has the following AMD64 support label by default:

```yaml
labels:
    operatorframework.io/arch.amd64: supported
```

If an Operator supports multiple node architectures or operating systems, you can add multiple labels, as well.

**Prerequisites**

- An Operator project with a CSV.
- To support listing multiple architectures and operating systems, your Operator image referenced in the CSV must be a manifest list image.
- For the Operator to work properly in restricted network, or disconnected, environments, the image referenced must also be specified using a digest (SHA) and not by a tag.

**Procedure**

- Add a label in your CSV’s `metadata.labels` for each supported architecture and operating system that your Operator supports:

  ```yaml
  labels:
    operatorframework.io/arch.s390x: supported
    operatorframework.io/os.zos: supported
    operatorframework.io/os.linux: supported
    operatorframework.io/arch.amd64: supported
  ```


**Additional resources**

- See the [Image Manifest V 2, Schema 2](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list) specification for more information on manifest lists.

#### 12.4.6.1. Architecture and operating system support for Operators

The following strings are supported in Operator Lifecycle Manager (OLM) on OpenShift Container Platform when labeling or filtering Operators that support multiple architectures and operating systems:

**Table 12.7. Architectures supported on OpenShift Container Platform**

| Architecture                 | String    |
| :--------------------------- | :-------- |
| AMD64                        | `amd64`   |
| 64-bit PowerPC little-endian | `ppc64le` |
| IBM Z                        | `s390x`   |

**Table 12.8. Operating systems supported on OpenShift Container Platform**

| Operating system | String  |
| :--------------- | :------ |
| Linux            | `linux` |
| z/OS             | `zos`   |

> NOTE：Different versions of OpenShift Container Platform and other Kubernetes-based distributions might support a different set of architectures and operating systems.

### 12.4.7. Setting a suggested namespace

Some Operators must be deployed in a specific namespace, or with ancillary resources in specific namespaces, in order to work properly. If resolved from a Subscription, OLM defaults the namespaced resources of an Operator to the namespace of its Subscription.

As an Operator author, you can instead express a desired target namespace as part of your CSV to maintain control over the final namespaces of the resources installed for their Operators. When adding the Operator to a cluster using OperatorHub, this enables the web console to autopopulate the suggested namespace for the cluster administrator during the installation process.

**Procedure**

- In your CSV, set the `operatorframework.io/suggested-namespace` annotation to your suggested namespace:

  ```yaml
  metadata:
    annotations:
      operatorframework.io/suggested-namespace: <namespace>
  ```


### 12.4.8. Understanding your Custom Resource Definitions (CRDs)

There are two types of Custom Resource Definitions (CRDs) that your Operator may use: ones that are *owned* by it and ones that it depends on, which are *required*.

#### 12.4.8.1. Owned CRDs

The CRDs owned by your Operator are the most important part of your CSV. This establishes the link between your Operator and the required RBAC rules, dependency management, and other Kubernetes concepts.

It is common for your Operator to use multiple CRDs to link together concepts, such as top-level database configuration in one object and a representation of ReplicaSets in another. Each one should be listed out in the CSV file.

**Table 12.9. Owned CRD fields**

| Field                                                        | Description                                                  | Required/Optional |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :---------------- |
| `Name`                                                       | The full name of your CRD.                                   | Required          |
| `Version`                                                    | The version of that object API.                              | Required          |
| `Kind`                                                       | The machine readable name of your CRD.                       | Required          |
| `DisplayName`                                                | A human readable version of your CRD name, for example `MongoDB Standalone`. | Required          |
| `Description`                                                | A short description of how this CRD is used by the Operator or a description of the functionality provided by the CRD. | Required          |
| `Group`                                                      | The API group that this CRD belongs to, for example `database.example.com`. | Optional          |
| `Resources`                                                  | Your CRDs own one or more types of Kubernetes objects. These are listed in the resources section to inform your users of the objects they might need to troubleshoot or how to connect to the application, such as the Service or Ingress rule that exposes a database.It is recommended to only list out the objects that are important to a human, not an exhaustive list of everything you orchestrate. For example, ConfigMaps that store internal state that should not be modified by a user should not appear here. | Optional          |
| `SpecDescriptors`, `StatusDescriptors`, and `ActionDescriptors` | These Descriptors are a way to hint UIs with certain inputs or outputs of your Operator that are most important to an end user. If your CRD contains the name of a Secret or ConfigMap that the user must provide, you can specify that here. These items are linked and highlighted in compatible UIs.There are three types of descriptors:`SpecDescriptors`: A reference to fields in the `spec` block of an object.`StatusDescriptors`: A reference to fields in the `status` block of an object.`ActionDescriptors`: A reference to actions that can be performed on an object.All Descriptors accept the following fields:`DisplayName`: A human readable name for the Spec, Status, or Action.`Description`: A short description of the Spec, Status, or Action and how it is used by the Operator.`Path`: A dot-delimited path of the field on the object that this descriptor describes.`X-Descriptors`: Used to determine which "capabilities" this descriptor has and which UI component to use. See the **openshift/console** project for a canonical [list of React UI X-Descriptors](https://github.com/openshift/console/tree/release-4.3/frontend/packages/operator-lifecycle-manager/src/components/descriptors/types.ts) for OpenShift Container Platform.Also see the **openshift/console** project for more information on [Descriptors](https://github.com/openshift/console/tree/release-4.3/frontend/packages/operator-lifecycle-manager/src/components/descriptors) in general. | Optional          |

The following example depicts a `MongoDB Standalone` CRD that requires some user input in the form of a Secret and ConfigMap, and orchestrates Services, StatefulSets, Pods and ConfigMaps:

**Example owned CRD**



```yaml
      - displayName: MongoDB Standalone
        group: mongodb.com
        kind: MongoDbStandalone
        name: mongodbstandalones.mongodb.com
        resources:
          - kind: Service
            name: ''
            version: v1
          - kind: StatefulSet
            name: ''
            version: v1beta2
          - kind: Pod
            name: ''
            version: v1
          - kind: ConfigMap
            name: ''
            version: v1
        specDescriptors:
          - description: Credentials for Ops Manager or Cloud Manager.
            displayName: Credentials
            path: credentials
            x-descriptors:
              - 'urn:alm:descriptor:com.tectonic.ui:selector:core:v1:Secret'
          - description: Project this deployment belongs to.
            displayName: Project
            path: project
            x-descriptors:
              - 'urn:alm:descriptor:com.tectonic.ui:selector:core:v1:ConfigMap'
          - description: MongoDB version to be installed.
            displayName: Version
            path: version
            x-descriptors:
              - 'urn:alm:descriptor:com.tectonic.ui:label'
        statusDescriptors:
          - description: The status of each of the Pods for the MongoDB cluster.
            displayName: Pod Status
            path: pods
            x-descriptors:
              - 'urn:alm:descriptor:com.tectonic.ui:podStatuses'
        version: v1
        description: >-
          MongoDB Deployment consisting of only one host. No replication of
          data.
```



#### 12.4.8.2. Required CRDs

Relying on other required CRDs is completely optional and only exists to reduce the scope of individual Operators and provide a way to compose multiple Operators together to solve an end-to-end use case.

An example of this is an Operator that might set up an application and install an etcd cluster (from an etcd Operator) to use for distributed locking and a Postgres database (from a Postgres Operator) for data storage.

The Operator Lifecycle Manager (OLM) checks against the available CRDs and Operators in the cluster to fulfill these requirements. If suitable versions are found, the Operators are started within the desired namespace and a Service Account created for each Operator to create, watch, and modify the Kubernetes resources required.

**Table 12.10. Required CRD fields**

| Field         | Description                                                  | Required/Optional |
| :------------ | :----------------------------------------------------------- | :---------------- |
| `Name`        | The full name of the CRD you require.                        | Required          |
| `Version`     | The version of that object API.                              | Required          |
| `Kind`        | The Kubernetes object kind.                                  | Required          |
| `DisplayName` | A human readable version of the CRD.                         | Required          |
| `Description` | A summary of how the component fits in your larger architecture. | Required          |

**Example required CRD**



```yaml
    required:
    - name: etcdclusters.etcd.database.coreos.com
      version: v1beta2
      kind: EtcdCluster
      displayName: etcd Cluster
      description: Represents a cluster of etcd nodes.
```



#### 12.4.8.3. CRD templates

Users of your Operator will need to be aware of which options are required versus optional. You can provide templates for each of your Custom Resource Definitions (CRDs) with a minimum set of configuration as an annotation named `alm-examples`. Compatible UIs will pre-fill this template for users to further customize.

The annotation consists of a list of the `kind`, for example, the CRD name and the corresponding `metadata` and `spec` of the Kubernetes object.

The following full example provides templates for `EtcdCluster`, `EtcdBackup` and `EtcdRestore`:

```yaml
metadata:
  annotations:
    alm-examples: >-
      [{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdCluster","metadata":{"name":"example","namespace":"default"},"spec":{"size":3,"version":"3.2.13"}},{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdRestore","metadata":{"name":"example-etcd-cluster"},"spec":{"etcdCluster":{"name":"example-etcd-cluster"},"backupStorageType":"S3","s3":{"path":"<full-s3-path>","awsSecret":"<aws-secret>"}}},{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdBackup","metadata":{"name":"example-etcd-cluster-backup"},"spec":{"etcdEndpoints":["<etcd-cluster-endpoints>"],"storageType":"S3","s3":{"path":"<full-s3-path>","awsSecret":"<aws-secret>"}}}]
```

#### 12.4.8.4. Hiding internal objects

It is common practice for Operators to use Custom Resource Definitions (CRDs) internally to accomplish a task. These objects are not meant for users to manipulate and can be confusing to users of the Operator. For example, a database Operator might have a Replication CRD that is created whenever a user creates a Database object with `replication: true`.

If any CRDs are not meant for manipulation by users, they can be hidden in the user interface using the `operators.operatorframework.io/internal-objects` annotation in the Operator’s ClusterServiceVersion (CSV):

**Internal object annotation**



```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: ClusterServiceVersion
metadata:
  name: my-operator-v1.2.3
  annotations:
    operators.operatorframework.io/internal-objects: '["my.internal.crd1.io","my.internal.crd2.io"]' 1
...
```



- [1](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/operators/operator-sdk#CO40-1)

  Set any internal CRDs as an array of strings.

Before marking one of your CRDs as internal, make sure that any debugging information or configuration that might be required to manage the application is reflected on the CR’s status or `spec` block, if applicable to your Operator.

### 12.4.9. Understanding your API services

As with CRDs, there are two types of APIServices that your Operator may use: *owned* and *required*.

#### 12.4.9.1. Owned APIServices

When a CSV owns an APIService, it is responsible for describing the deployment of the extension `api-server` that backs it and the `group-version-kinds` it provides.

An APIService is uniquely identified by the `group-version` it provides and can be listed multiple times to denote the different kinds it is expected to provide.

**Table 12.11. Owned APIService fields**

| Field                                                        | Description                                                  | Required/Optional |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :---------------- |
| `Group`                                                      | Group that the APIService provides, for example `database.example.com`. | Required          |
| `Version`                                                    | Version of the APIService, for example `v1alpha1`.           | Required          |
| `Kind`                                                       | A kind that the APIService is expected to provide.           | Required          |
| `Name`                                                       | The plural name for the APIService provided                  | Required          |
| `DeploymentName`                                             | Name of the deployment defined by your CSV that corresponds to your APIService (required for owned APIServices). During the CSV pending phase, the OLM Operator searches your CSV’s InstallStrategy for a deployment spec with a matching name, and if not found, does not transition the CSV to the install ready phase. | Required          |
| `DisplayName`                                                | A human readable version of your APIService name, for example `MongoDB Standalone`. | Required          |
| `Description`                                                | A short description of how this APIService is used by the Operator or a description of the functionality provided by the APIService. | Required          |
| `Resources`                                                  | Your APIServices own one or more types of Kubernetes objects. These are listed in the resources section to inform your users of the objects they might need to troubleshoot or how to connect to the application, such as the Service or Ingress rule that exposes a database.It is recommended to only list out the objects that are important to a human, not an exhaustive list of everything you orchestrate. For example, ConfigMaps that store internal state that should not be modified by a user should not appear here. | Optional          |
| `SpecDescriptors`, `StatusDescriptors`, and `ActionDescriptors` | Essentially the same as for owned CRDs.                      | Optional          |

##### 12.4.9.1.1. APIService Resource Creation

The Operator Lifecycle Manager (OLM) is responsible for creating or replacing the Service and APIService resources for each unique owned APIService:

- Service Pod selectors are copied from the CSV deployment matching the APIServiceDescription’s `DeploymentName`.
- A new CA key/cert pair is generated for each installation and the base64-encoded CA bundle is embedded in the respective APIService resource.

##### 12.4.9.1.2. APIService Serving Certs

The OLM handles generating a serving key/cert pair whenever an owned APIService is being installed. The serving certificate has a CN containing the host name of the generated Service resource and is signed by the private key of the CA bundle embedded in the corresponding APIService resource.

The cert is stored as a type `kubernetes.io/tls` Secret in the deployment namespace, and a Volume named `apiservice-cert` is automatically appended to the Volumes section of the deployment in the CSV matching the APIServiceDescription’s `DeploymentName` field.

If one does not already exist, a VolumeMount with a matching name is also appended to all containers of that deployment. This allows users to define a VolumeMount with the expected name to accommodate any custom path requirements. The generated VolumeMount’s path defaults to `/apiserver.local.config/certificates` and any existing VolumeMounts with the same path are replaced.

#### 12.4.9.2. Required APIServices

The OLM ensures all required CSVs have an APIService that is available and all expected `group-version-kinds` are discoverable before attempting installation. This allows a CSV to rely on specific kinds provided by APIServices it does not own.

**Table 12.12. Required APIService fields**

| Field         | Description                                                  | Required/Optional |
| :------------ | :----------------------------------------------------------- | :---------------- |
| `Group`       | Group that the APIService provides, for example `database.example.com`. | Required          |
| `Version`     | Version of the APIService, for example `v1alpha1`.           | Required          |
| `Kind`        | A kind that the APIService is expected to provide.           | Required          |
| `DisplayName` | A human readable version of your APIService name, for example `MongoDB Standalone`. | Required          |
| `Description` | A short description of how this APIService is used by the Operator or a description of the functionality provided by the APIService. | Required          |


