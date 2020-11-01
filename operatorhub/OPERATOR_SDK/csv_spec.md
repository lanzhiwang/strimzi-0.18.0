CSV spec

https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/design/building-your-csv.md

# Building a Cluster Service Version (CSV) for the Operator Framework

This guide is intended to guide an Operator author to package a version of their Operator to run with the [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager). This will be a manual method that will walk through each section of the file, what it’s used for and how to populate it. 本指南旨在指导操作员作者打包其操作员版本以与操作员生命周期管理器一起运行。 这将是一种手动方法，将逐步浏览文件的各个部分，其用途以及填充方式。

## What is a Cluster Service Version (CSV)?

A CSV is the metadata that accompanies your Operator container image. It can be used to populate user interfaces with info like your logo/description/version and it is also a source of technical information needed to run the Operator, like the RBAC rules it requires and which Custom Resources it manages or depends on.  CSV是操作员容器映像随附的元数据。 它可用于以徽标/描述/版本等信息填充用户界面，它也是运行操作员所需的技术信息的来源，例如其要求的RBAC规则以及它管理或依赖的自定义资源。

The Lifecycle Manager will parse this and do all of the hard work to wire up the correct Roles and Role Bindings, ensure that the Operator is started (or updated) within the desired namespace and check for various other requirements, all without the end users having to do anything.  生命周期管理器将对此进行解析，并进行所有艰苦的工作以连接正确的角色和角色绑定，确保在所需的名称空间内启动（或更新）操作员，并检查各种其他要求，而最终用户不必 做任何事。

You can read about the [full architecture in more detail](architecture.md#what-is-a-clusterserviceversion).

## CSV Metadata

The object has the normal Kubernetes metadata. Since the CSV pertains to the specific version, the naming scheme is the name of the Operator + the semantic version number, eg `mongodboperator.v0.3`.  该对象具有普通的Kubernetes元数据。 由于CSV与特定版本有关，因此命名方案为操作员名称+语义版本号，例如mongodboperator.v0.3。

The namespace is used when a CSV will remain private to a specific namespace. Only users of that namespace will be able to view or instantiate the Operator. If you plan on distributing your Operator to many namespaces or clusters, you may want to explore bundling it into a [Catalog](architecture.md#catalog-registry-design).  当CSV对特定名称空间保持私有时，将使用该名称空间。 只有该名称空间的用户才能查看或实例化操作员。 如果计划将Operator分配到许多名称空间或群集，则可能需要探索将其捆绑到Catalog中。

The namespace listed in the CSV within a catalog is actually a placeholder, so it is common to simply list `placeholder`. Otherwise, loading a CSV directly into a namespace requires that namespace, of course. 目录中CSV中列出的名称空间实际上是一个占位符，因此仅列出占位符是很常见的。 否则，将CSV直接加载到名称空间中当然需要该名称空间。

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: ClusterServiceVersion
metadata:
  name: mongodboperator.v0.3
  namespace: placeholder
```

## Your Custom Resource Definitions
There are two types of CRDs that your Operator may use, ones that are “owned” by it and ones that it depends on, which are “required”.  您的运营商可以使用两种类型的CARD，一种是其所拥有的，另一种是它所依赖的。
### Owned CRDs

The CRDs owned by your Operator are the most important part of your CSV. This establishes the link between your Operator and the required RBAC rules, dependency management and other under-the-hood Kubernetes concepts.  运营商拥有的CRD是CSV中最重要的部分。 这将在您的操作员与所需的RBAC规则，依赖项管理以及其他高级Kubernetes概念之间建立链接。

It’s common for your Operator to use multiple CRDs to link together concepts, such as top-level database configuration in one object and a representation of replica sets in another. List out each one in the CSV file.  对于您的操作员来说，通常使用多个CRD将概念链接在一起，例如，一个对象中的顶级数据库配置，另一个对象中的副本集表示。 列出CSV文件中的每一个。

**DisplayName**: A human readable version of your CRD name, eg. “MongoDB Standalone”

**Description**: A short description of how this CRD is used by the Operator or a description of the functionality provided by the CRD.

**Group**: The API group that this CRD belongs to, eg. database.example.com

**Kind**: The machine readable name of your CRD

**Name**: The full name of your CRD

The next two sections require more explanation.

**Resources**:
Your CRDs will own one or more types of Kubernetes objects. These are listed in the resources section to inform your end-users of the objects they might need to troubleshoot or how to connect to the application, such as the Service or Ingress rule that exposes a database.  您的CRD将拥有一种或多种类型的Kubernetes对象。 资源部分中列出了这些信息，以告知最终用户他们可能需要进行故障排除的对象或如何连接到应用程序，例如公开数据库的Service或Ingress规则。

It’s recommended to only list out the objects that are important to a human, not an exhaustive list of everything you orchestrate. For example, ConfigMaps that store internal state that shouldn’t be modified by a user shouldn’t appear here. 建议仅列出对人类重要的对象，而不是您精心安排的所有内容的详尽列表。 例如，存储不应由用户修改的内部状态的ConfigMap不应出现在此处。

**SpecDescriptors, StatusDescriptors, and ActionDescriptors**:
These are a way to hint UIs with certain inputs or outputs of your Operator that are most important to an end user. If your CRD contains the name of a Secret or ConfigMap that the user must provide, you can specify that here. These items will be linked and highlighted in compatible UIs. 这些是用某些操作员的输入或输出提示UI的方法，这些输入或输出对最终用户来说最重要。 如果CRD包含用户必须提供的Secret或ConfigMap的名称，则可以在此处指定。 这些项目将在兼容的UI中链接并突出显示。

There are three types of descriptors:

***SpecDescriptors***: A reference to fields in the `spec` block of an object.

***StatusDescriptors***: A reference to fields in the `status` block of an object.

***ActionDescriptors***: A reference to actions that can be performed on an object.  对可以在对象上执行的动作的引用。

All Descriptors accept the following fields:

**DisplayName**: A human readable name for the Spec, Status, or Action.

**Description**: A short description of the Spec, Status, or Action and how it is used by the Operator.

**Path**: A dot-delimited path of the field on the object that this descriptor describes.  该描述符描述的对象上字段的点分隔路径。

**X-Descriptors**: Used to determine which "capabilities" this descriptor has and which UI component to use. A canonical list of React UI X-Descriptors for OpenShift can be found [here](https://github.com/openshift/console/blob/master/frontend/packages/operator-lifecycle-manager/src/components/descriptors/types.ts). 用于确定此描述符具有哪些功能以及使用哪个UI组件。 可以在此处找到适用于OpenShift的React UI X描述符的规范列表。

More information on Descriptors can be found [here](https://github.com/openshift/console/tree/master/frontend/packages/operator-lifecycle-manager/src/components/descriptors).

Below is an example of a MongoDB “standalone” CRD that requires some user input in the form of a Secret and ConfigMap, and orchestrates Services, StatefulSets, Pods and ConfigMaps.

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

### Required CRDs

Relying on other “required” CRDs is completely optional and only exists to reduce the scope of individual Operators and provide a way to compose multiple Operators together to solve an end-to-end use case. An example of this is an Operator that might set up an application and install an etcd cluster (from an etcd Operator) to use for distributed locking and a Postgres database (from a Postgres Operator) for data storage.  依赖于其他必需的CRD是完全可选的，并且仅存在于缩小单个操作员的范围，并提供一种组合多个操作员以解决端到端用例的方法。 例如，一个Operator可能会设置一个应用程序并安装一个etcd集群（来自etcd Operator）以用于分布式锁定，并安装一个Postgres数据库（来自Postgres Operator）用于数据存储。

The Lifecycle Manager will check against the available CRDs and Operators in the cluster to fulfill these requirements. If suitable versions are found, the Operators will be started within the desired namespace and a Service Account created for each Operator to create/watch/modify the Kubernetes resources required.  Lifecycle Manager将检查群集中可用的CRD和操作员是否满足这些要求。 如果找到合适的版本，将在所需的名称空间内启动运营商，并为每个运营商创建一个服务帐户，以创建/监视/修改所需的Kubernetes资源。

**Name**: The full name of the CRD you require

**Version**: The version of that object API

**Kind**: The Kubernetes object kind

**DisplayName**: A human readable version of the CRD

**Description**: A summary of how the component fits in your larger architecture

```yaml
    required:
    - name: etcdclusters.etcd.database.coreos.com
      version: v1beta2
      kind: EtcdCluster
      displayName: etcd Cluster
      description: Represents a cluster of etcd nodes.
```
## CRD Templates
Users of your Operator will need to be aware of which options are required vs optional. You can provide templates for each of your CRDs with a minimum set of configuration as an annotation named `alm-examples`. Metadata for each template, for exmaple an expanded description, can be included in an annotation named `alm-examples-metadata`, which should be a hash indexed with the `metadata.name` of the example in the `alm-examples` list. Compatible UIs will pre-enter the `alm-examples` template for users to further customize, and use the `alm-examples-metadata` to help users decide which template to select.  操作员的用户将需要知道哪些选项是必需的还是可选的。 您可以为每个CRD提供模板，并使用最少的配置集作为名为alm-examples的注释。 每个模板的元数据（例如，扩展的说明）都可以包含在名为alm-examples-metadata的注释中，该注释应该是在alm-examples列表中以该示例的metadata.name索引的哈希。 兼容的UI将预先输入alm-examples模板供用户进一步自定义，并使用alm-examples-metadata帮助用户决定选择哪个模板。

The annotation consists of a list of the `kind`, eg. the CRD name, and the corresponding `metadata` and `spec` of the Kubernetes object. Here’s a full example that provides templates for `EtcdCluster`, `EtcdBackup` and `EtcdRestore`:  注释由种类列表组成，例如。 CRD名称以及Kubernetes对象的相应元数据和规范。 这是一个完整的示例，提供了EtcdCluster，EtcdBackup和EtcdRestore的模板：

```yaml
metadata:
  annotations:
    alm-examples-metadata: >-
      {"example-etcd-cluster":{"description":"Example EtcdCluster CR"},"example-etcd-restore":{"description":"Example EtcdRestore CR that restores data from S3"},"example-etcd-backup":{"description":"Example EtcdBackup CR that stores backups on S3"}}
    alm-examples: >-
      [{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdCluster","metadata":{"name":"example-etcd-cluster","namespace":"default"},"spec":{"size":3,"version":"3.2.13"}},{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdRestore","metadata":{"name":"example-etcd-restore"},"spec":{"etcdCluster":{"name":"example-etcd-cluster"},"backupStorageType":"S3","s3":{"path":"<full-s3-path>","awsSecret":"<aws-secret>"}}},{"apiVersion":"etcd.database.coreos.com/v1beta2","kind":"EtcdBackup","metadata":{"name":"example-etcd-backup"},"spec":{"etcdEndpoints":["<etcd-cluster-endpoints>"],"storageType":"S3","s3":{"path":"<full-s3-path>","awsSecret":"<aws-secret>"}}}]
```

## Your API Services
As with CRDs, there are two types of APIServices that your Operator may use, “owned” and "required".

### Owned APIServices

When a CSV owns an APIService, it is responsible for describing the deployment of the extension api-server that backs it and the group-version-kinds it provides.  CSV拥有APIService时，它负责描述支持它的扩展api服务器的部署以及它提供的group-version-kinds。

An APIService is uniquely identified by the group-version it provides and can be listed multiple times to denote the different kinds it is expected to provide.

**DisplayName**: A human readable version of your APIService name, eg. “MongoDB Standalone”

**Description**: A short description of how this APIService is used by the Operator or a description of the functionality provided by the APIService.

**Group**: Group that the APIService provides, eg. database.example.com.

**Version**: Version of the APIService, eg v1alpha1

**Kind**: A kind that the APIService is expected to provide.

**DeploymentName**:
Name of the deployment defined by your CSV that corresponds to your APIService (required for owned APIServices). During the CSV pending phase, the OLM Operator will search your CSV's InstallStrategy for a deployment spec with a matching name, and if not found, will not transition the CSV to the install ready phase.

**Resources**:
Your APIServices will own one or more types of Kubernetes objects. These are listed in the resources section to inform your end-users of the objects they might need to troubleshoot or how to connect to the application, such as the Service or Ingress rule that exposes a database.

It’s recommended to only list out the objects that are important to a human, not an exhaustive list of everything you orchestrate. For example, ConfigMaps that store internal state that shouldn’t be modified by a user shouldn’t appear here.

**SpecDescriptors, StatusDescriptors, and ActionDescriptors**:
Essentially the same as for owned CRDs.

### APIService Resource Creation
The Lifecycle Manager is responsible for creating or replacing the Service and APIService resources for each unique owned APIService.
* Service pod selectors are copied from the CSV deployment matching the APIServiceDescription's DeploymentName.
* A new CA key/cert pair is generated for for each installation and the base64 encoded CA bundle is embedded in the respective APIService resource.

### APIService Serving Certs
The Lifecycle Manager handles generating a serving key/cert pair whenever an owned APIService is being installed. The serving cert has a CN containing the host name of the generated Service resource and is signed by the private key of the CA bundle embedded in the corresponding APIService resource. The cert is stored as a type `kubernetes.io/tls` Secret in the deployment namespace and a Volume named "apiservice-cert" is automatically appended to the Volumes section of the deployment in the CSV matching the APIServiceDescription's `DeploymentName` field. If one does not already exist, a VolumeMount with a matching name is also appended to all containers of that deployment. This allows users to define a VolumeMount with the expected name to accommodate any custom path requirements. The generated VolumeMount's path defaults to `/apiserver.local.config/certificates` and any existing VolumeMounts with the same path are replaced.

### Required APIServices

The Lifecycle Manager will ensure all required CSVs have an APIService that is available and all expected group-version-kinds are discoverable before attempting installation. This allows a CSV to rely on specific kinds provided by APIServices it does not own.

**DisplayName**: A human readable version of your APIService name, eg. “MongoDB Standalone”

**Description**: A short description of how this APIService is used by the Operator or a description of the functionality provided by the APIService.

**Group**: Group that the APIService provides, eg. database.example.com.

**Version**: Version of the APIService, eg v1alpha1

**Kind**: A kind that the APIService is expected to provide.

## Operator Metadata
The metadata section contains general metadata around the name, version and other info that aids users in discovery of your Operator.

**DisplayName**: Human readable name that describes your Operator and the CRDs that it implements

**Keywords**: A list of categories that your Operator falls into. Used for filtering within compatible UIs.

**Provider**: The name of the publishing entity behind the Operator

**Maturity**: Level of maturity the Operator has achieved at this version, eg. planning, pre-alpha, alpha, beta, stable, mature, inactive, or deprecated.

**Version**: The semanic version of the Operator. This value should be incremented each time a new Operator image is published.

**Icon**: a base64 encoded image of the Operator logo or the logo of the publisher. The `base64data` parameter contains the data and the `mediatype` specifies the type of image, eg. `image/png` or `image/svg`.

**Links**: A list of relevant links for the Operator. Common links include documentation, how-to guides, blog posts, and the company homepage.

**Maintainers**: A list of names and email addresses of the maintainers of the Operator code. This can be a list of individuals or a shared email alias, eg. support@example.com.

**Description**: A markdown blob that describes the Operator. Important information to include: features, limitations and common use-cases for the Operator. If your Operator manages different types of installs, eg. standalone vs clustered, it is useful to give an overview of how each differs from each other, or which ones are supported for production use.

**MinKubeVersion**: A minimum version of Kubernetes that server is supposed to have so operator(s) can be deployed. The Kubernetes version must be in "Major.Minor.Patch" format (e.g: 1.11.0).

**Labels** (optional): Any key/value pairs used to organize and categorize this CSV object.  用于组织和分类此CSV对象的所有键/值对。 

**Selectors** (optional): A label selector to identify related resources. Set this to select on current labels applied to this CSV object (if applicable).  标签选择器，用于标识相关资源。 设置此项以选择应用于该CSV对象的当前标签（如果适用）。

**InstallModes**: A set of `InstallMode`s that tell OLM which `OperatorGroup`s an Operator can belong to. Belonging to an `OperatorGroup` means that OLM provides the set of targeted namespaces as an annotation on the Operator's CSV and any deployments defined therein. These deployments can then utilize [the Downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#the-downward-api) to inject the list of namespaces into their container(s). An `InstallMode` consists of an `InstallModeType` field and a boolean `Supported` field. There are four `InstallModeTypes`:
* `OwnNamespace`: If supported, the operator can be a member of an `OperatorGroup` that selects its own namespace
* `SingleNamespace`: If supported, the operator can be a member of an `OperatorGroup` that selects one namespace
* `MultiNamespace`: If supported, the operator can be a member of an `OperatorGroup` that selects more than one namespace
* `AllNamespaces`: If supported, the operator can be a member of an `OperatorGroup` that selects all namespaces (target namespace set is the empty string "")

Here's an example:

```yaml
   keywords: ['etcd', 'key value', 'database', 'coreos', 'open source']
   version: 0.9.2
   maturity: alpha
   replaces: etcdoperator.v0.9.0
   maintainers:
   - name: CoreOS, Inc
     email: support@coreos.com
   provider:
     name: CoreOS, Inc
   labels:
     alm-owner-etcd: etcdoperator
     operated-by: etcdoperator
   selector:
     matchLabels:
       alm-owner-etcd: etcdoperator
       operated-by: etcdoperator
   links:
   - name: Blog
     url: https://coreos.com/etcd
   - name: Documentation
     url: https://coreos.com/operators/etcd/docs/latest/
   - name: etcd Operator Source Code
     url: https://github.com/coreos/etcd-operator
   icon:
   - base64data: <base64-encoded-data>
     mediatype: image/png
   installModes:
   - type: OwnNamespace
     supported: true
   - type: SingleNamespace
     supported: true
   - type: MultiNamespace
     supported: false
   - type: AllNamespaces
     supported: true
```

## Operator Install
The install block is how the Lifecycle Manager will instantiate the Operator on the cluster. There are two subsections within install: one to describe the `deployment` that will be started within the desired namespace and one that describes the Role `permissions` required to successfully run the Operator.

Ensure that the `serviceAccountName` used in the `deployment` spec matches one of the Roles described under `permissions`.

Multiple Roles should be described to reduce the scope of any actions needed containers that the Operator may run on the cluster. For example, if you have a component that generates a TLS Secret upon start up, a Role that allows `create` but not `list` on Secrets is more secure than using a single all-powerful Service Account.

Here’s a full example:

```yaml
  install:
    spec:
      deployments:
        - name: example-operator
          spec:
            replicas: 1
            selector:
              matchLabels:
                k8s-app: example-operator
            template:
              metadata:
                labels:
                  k8s-app: example-operator
              spec:
                containers:
                    image: 'quay.io/example/example-operator:v0.0.1'
                    imagePullPolicy: Always
                    name: example-operator
                    resources:
                      limits:
                        cpu: 200m
                        memory: 100Mi
                      requests:
                        cpu: 100m
                        memory: 50Mi
                imagePullSecrets:
                  - name: ''
                nodeSelector:
                  kubernetes.io/os: linux
                serviceAccountName: example-operator
      permissions:
        - serviceAccountName: example-operator
          rules:
            - apiGroups:
                - ''
              resources:
                - configmaps
                - secrets
                - services
              verbs:
                - get
                - list
                - create
                - update
                - delete
            - apiGroups:
                - apps
              resources:
                - statefulsets
              verbs:
                - '*'
            - apiGroups:
                - apiextensions.k8s.io
              resources:
                - customresourcedefinitions
              verbs:
                - get
                - list
                - watch
                - create
                - delete
            - apiGroups:
                - mongodb.com
              resources:
                - '*'
              verbs:
                - '*'
        - serviceAccountName: example-operator-list
          rules:
            - apiGroups:
                - ''
              resources:
                - services
              verbs:
                - get
                - list
    strategy: deployment
```

## Full Examples

Several [complete examples of CSV files](https://github.com/operator-framework/community-operators) are stored in Github.








