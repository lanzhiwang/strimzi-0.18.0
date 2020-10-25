## 12.1. Getting started with the Operator SDK

https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/operators/operator-sdk#osdk-getting-started

This guide outlines the basics of the Operator SDK and walks Operator authors with cluster administrator access to a Kubernetes-based cluster (such as OpenShift Container Platform) through an example of building a simple Go-based Memcached Operator and managing its lifecycle from installation to upgrade.  本指南概述了Operator SDK的基础知识，并通过构建简单的基于Go的Memcached Operator并管理其从安装到升级的生命周期的示例，引导具有集群管理员访问权限的Operator作者访问基于Kubernetes的集群（例如OpenShift Container Platform）。

This is accomplished using two centerpieces of the Operator Framework: the Operator SDK (the `operator-sdk` CLI tool and `controller-runtime` library API) and the Operator Lifecycle Manager (OLM).  这是通过使用Operator Framework的两个核心要素来完成的：Operator SDK（operator-SDK CLI工具和控制器运行时库API）和Operator Lifecycle Manager（OLM）。

> NOTE：OpenShift Container Platform 4.4 supports Operator SDK v0.15.0 or later.

### 12.1.1. Architecture of the Operator SDK

The [Operator Framework](https://coreos.com/operators/) is an open source toolkit to manage Kubernetes native applications, called *Operators*, in an effective, automated, and scalable way. Operators take advantage of Kubernetes' extensibility to deliver the automation advantages of cloud services like provisioning, scaling, and backup and restore, while being able to run anywhere that Kubernetes can run.  Operator Framework是一个开放源代码工具包，用于以有效，自动化和可扩展的方式管理称为Kubernetes的本机应用程序。 运营商可以利用Kubernetes的可扩展性来提供云服务的自动化优势，例如供应，扩展，备份和还原，同时可以在Kubernetes可以运行的任何位置运行。

Operators make it easy to manage complex, stateful applications on top of Kubernetes. However, writing an Operator today can be difficult because of challenges such as using low-level APIs, writing boilerplate, and a lack of modularity, which leads to duplication.  操作员可以轻松地在Kubernetes上管理复杂的有状态应用程序。 但是，由于诸如使用低级API，编写样板以及缺少模块化（导致重复）等挑战，今天编写操作员可能会很困难。

The Operator SDK is a framework designed to make writing Operators easier by providing:  Operator SDK是一个框架，旨在通过提供以下功能使编写Operators更加容易：

- High-level APIs and abstractions to write the operational logic more intuitively  高级API和抽象，可更直观地编写操作逻辑
- Tools for scaffolding and code generation to quickly bootstrap a new project  脚手架和代码生成工具，可快速引导新项目
- Extensions to cover common Operator use cases  扩展以涵盖常见的操作员用例

#### 12.1.1.1. Workflow

The Operator SDK provides the following workflow to develop a new Operator:

1. Create a new Operator project using the Operator SDK command line interface (CLI).
2. Define new resource APIs by adding Custom Resource Definitions (CRDs).
3. Specify resources to watch using the Operator SDK API.
4. Define the Operator reconciling logic in a designated handler and use the Operator SDK API to interact with resources.
5. Use the Operator SDK CLI to build and generate the Operator deployment manifests.

![](../../images/operator/01_osdk-workflow.png)

At a high level, an Operator using the Operator SDK processes events for watched resources in an Operator author-defined handler and takes actions to reconcile the state of the application.

#### 12.1.1.2. Manager file

The main program for the Operator is the manager file at `cmd/manager/main.go`. The manager automatically registers the scheme for all Custom Resources (CRs) defined under `pkg/apis/` and runs all controllers under `pkg/controller/`.

The manager can restrict the namespace that all controllers watch for resources:

```
mgr, err := manager.New(cfg, manager.Options{Namespace: namespace})
```

By default, this is the namespace that the Operator is running in. To watch all namespaces, you can leave the namespace option empty:

```
mgr, err := manager.New(cfg, manager.Options{Namespace: ""})
```

#### 12.1.1.3. Prometheus Operator support

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit. The Prometheus Operator creates, configures, and manages Prometheus clusters running on Kubernetes-based clusters, such as OpenShift Container Platform.

Helper functions exist in the Operator SDK by default to automatically set up metrics in any generated Go-based Operator for use on clusters where the Prometheus Operator is deployed.

### 12.1.2. Installing the Operator SDK CLI

The Operator SDK has a CLI tool that assists developers in creating, building, and deploying a new Operator project. You can install the SDK CLI on your workstation so you are prepared to start authoring your own Operators.

> NOTE：This guide uses [minikube](https://github.com/kubernetes/minikube#installation) v0.25.0+ as the local Kubernetes cluster and [Quay.io](https://quay.io/) for the public registry.

#### 12.1.2.1. Installing from GitHub release

You can download and install a pre-built release binary of the SDK CLI from the project on GitHub.

**Prerequisites**

- [Go](https://golang.org/dl/) v1.13+
- `docker` v17.03+, `podman` v1.2.0+, or `buildah` v1.7+
- OpenShift CLI (`oc`) 4.4+ installed
- Access to a cluster based on Kubernetes v1.12.0+
- Access to a container registry

**Procedure**

1. Set the release version variable:

   ```
   RELEASE_VERSION=v0.15.0
   ```

2. Download the release binary.

   - For Linux:

     ```
     $ curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
     ```

   - For macOS:

     ```
     $ curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin
     ```

3. Verify the downloaded release binary.

   1. Download the provided ASC file.

      - For Linux:

        ```
        $ curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu.asc
        ```

      - For macOS:

        ```
        $ curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin.asc
        ```

   2. Place the binary and corresponding ASC file into the same directory and run the following command to verify the binary:

      - For Linux:

        ```
        $ gpg --verify operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu.asc
        ```

      - For macOS:

        ```
        $ gpg --verify operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin.asc
        ```

      If you do not have the maintainer’s public key on your workstation, you will get the following error:

      ```
      $ gpg --verify operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin.asc
      $ gpg: assuming signed data in 'operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin'
      $ gpg: Signature made Fri Apr  5 20:03:22 2019 CEST
      $ gpg:                using RSA key <key_id>
      $ gpg: Can't check signature: No public key
      ```

      To download the key, run the following command, replacing `` with the RSA key string provided in the output of the previous command:

      ```
      $ gpg [--keyserver keys.gnupg.net] --recv-key "<key_id>"
      ```

4. Install the release binary in your `PATH`:

   - For Linux:

     ```
     $ chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
     $ sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk
     $ rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
     ```

   - For macOS:

     ```
     $ chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin
     $ sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin /usr/local/bin/operator-sdk
     $ rm operator-sdk-${RELEASE_VERSION}-x86_64-apple-darwin
     ```

5. Verify that the CLI tool was installed correctly:

   ```
   $ operator-sdk version
   ```

#### 12.1.2.2. Installing from Homebrew

You can install the SDK CLI using Homebrew.

**Prerequisites**

- [Homebrew](https://brew.sh/)
- `docker` v17.03+, `podman` v1.2.0+, or `buildah` v1.7+
- OpenShift CLI (`oc`) 4.4+ installed
- Access to a cluster based on Kubernetes v1.12.0+
- Access to a container registry

**Procedure**

1. Install the SDK CLI using the `brew` command:

   ```
   $ brew install operator-sdk
   ```

2. Verify that the CLI tool was installed correctly:

   ```
   $ operator-sdk version
   ```

#### 12.1.2.3. Compiling and installing from source

You can obtain the Operator SDK source code to compile and install the SDK CLI.

**Prerequisites**

- [Git](https://git-scm.com/downloads)
- [Go](https://golang.org/dl/) v1.13+
- `docker` v17.03+, `podman` v1.2.0+, or `buildah` v1.7+
- OpenShift CLI (`oc`) 4.4+ installed
- Access to a cluster based on Kubernetes v1.12.0+
- Access to a container registry

**Procedure**

1. Clone the `operator-sdk` repository:

   ```
   $ mkdir -p $GOPATH/src/github.com/operator-framework
   $ cd $GOPATH/src/github.com/operator-framework
   $ git clone https://github.com/operator-framework/operator-sdk
   $ cd operator-sdk
   ```

2. Check out the desired release branch:

   ```
   $ git checkout master
   ```

3. Compile and install the SDK CLI:

   ```
   $ make dep
   $ make install
   ```

   This installs the CLI binary `operator-sdk` at ***$GOPATH/bin\***.

4. Verify that the CLI tool was installed correctly:

   ```
   $ operator-sdk version
   ```

### 12.1.3. Building a Go-based Operator using the Operator SDK

The Operator SDK makes it easier to build Kubernetes native applications, a process that can require deep, application-specific operational knowledge. The SDK not only lowers that barrier, but it also helps reduce the amount of boilerplate code needed for many common management capabilities, such as metering or monitoring.  Operator SDK使构建Kubernetes本机应用程序变得更加容易，该过程可能需要深入的，特定于应用程序的操作知识。 SDK不仅降低了这种障碍，而且还有助于减少许多常见管理功能（例如计量或监视）所需的样板代码量。

This procedure walks through an example of building a simple Memcached Operator using tools and libraries provided by the SDK.

**Prerequisites**

- Operator SDK CLI installed on the development workstation
- Operator Lifecycle Manager (OLM) installed on a Kubernetes-based cluster (v1.8 or above to support the `apps/v1beta2` API group), for example OpenShift Container Platform 4.4
- Access to the cluster using an account with `cluster-admin` permissions
- OpenShift CLI (`oc`) v4.1+ installed

**Procedure**

1. **Create a new project.**

   Use the CLI to create a new `memcached-operator` project:

   ```
   $ mkdir -p $GOPATH/src/github.com/example-inc/
   $ cd $GOPATH/src/github.com/example-inc/
   $ operator-sdk new memcached-operator
   $ cd memcached-operator
   ```

2. **Add a new Custom Resource Definition (CRD).**

   1. Use the CLI to add a new CRD API called `Memcached`, with `APIVersion` set to `cache.example.com/v1apha1` and `Kind` set to `Memcached`:

      ```
      $ operator-sdk add api \
          --api-version=cache.example.com/v1alpha1 \
          --kind=Memcached
      ```

      This scaffolds the Memcached resource API under `pkg/apis/cache/v1alpha1/`.

   2. Modify the spec and status of the `Memcached` Custom Resource (CR) at the `pkg/apis/cache/v1alpha1/memcached_types.go` file:

      ```go
      type MemcachedSpec struct {
      	// Size is the size of the memcached deployment
      	Size int32 `json:"size"`
      }
      type MemcachedStatus struct {
      	// Nodes are the names of the memcached pods
      	Nodes []string `json:"nodes"`
      }
      ```

   3. After modifying the `*_types.go` file, always run the following command to update the generated code for that resource type:

      ```
      $ operator-sdk generate k8s
      ```

3. **Optional: Add custom validation to your CRD.**

   OpenAPI v3.0 schemas are added to CRD manifests in the `spec.validation` block when the manifests are generated. This validation block allows Kubernetes to validate the properties in a Memcached CR when it is created or updated.  清单生成时，OpenAPI v3.0模式会添加到`spec.validation`块中的CRD清单中。 此验证块允许Kubernetes在创建或更新Memcached CR时验证其属性。

   Additionally, a `pkg/apis///zz_generated.openapi.go` file is generated. This file contains the Go representation of this validation block if the `+k8s:openapi-gen=true annotation` is present above the `Kind` type declaration, which is present by default. This auto-generated code is your Go `Kind` type’s OpenAPI model, from which you can create a full OpenAPI Specification and generate a client.

   As an Operator author, you can use Kubebuilder markers (annotations) to configure custom validations for your API. These markers must always have a `+kubebuilder:validation` prefix. For example, adding an enum-type specification can be done by adding the following marker:

   ```go
   // +kubebuilder:validation:Enum=Lion;Wolf;Dragon
   type Alias string
   ```

   Usage of markers in API code is discussed in the Kubebuilder [Generating CRDs](https://book.kubebuilder.io/reference/generating-crd.html) and [Markers for Config/Code Generation](https://book.kubebuilder.io/reference/markers.html) documentation. A full list of OpenAPIv3 validation markers is also available in the Kubebuilder [CRD Validation](https://book.kubebuilder.io/reference/markers/crd-validation.html) documentation.

   If you add any custom validations, run the following command to update the OpenAPI validation section in the CRD’s `deploy/crds/cache.example.com_memcacheds_crd.yaml` file:

   ```
   $ operator-sdk generate crds
   ```

   **Example generated YAML**

   ```yaml
   spec:
     validation:
       openAPIV3Schema:
         properties:
           spec:
             properties:
               size:
                 format: int32
                 type: integer
   ```

   

4. **Add a new Controller.**

   1. Add a new Controller to the project to watch and reconcile the Memcached resource:

      ```
      $ operator-sdk add controller \
          --api-version=cache.example.com/v1alpha1 \
          --kind=Memcached
      ```

      This scaffolds a new Controller implementation under `pkg/controller/memcached/`.

   2. For this example, replace the generated controller file `pkg/controller/memcached/memcached_controller.go` with the [example implementation](https://github.com/operator-framework/operator-sdk/blob/master/example/memcached-operator/memcached_controller.go.tmpl).

      The example controller executes the following reconciliation logic for each `Memcached` CR:

      - Create a Memcached Deployment if it does not exist.
      - Ensure that the Deployment size is the same as specified by the `Memcached` CR spec.
      - Update the `Memcached` CR status with the names of the Memcached Pods.

      The next two sub-steps inspect how the Controller watches resources and how the reconcile loop is triggered. You can skip these steps to go directly to building and running the Operator.

   3. Inspect the Controller implementation at the `pkg/controller/memcached/memcached_controller.go` file to see how the Controller watches resources.

      The first watch is for the Memcached type as the primary resource. For each Add, Update, or Delete event, the reconcile loop is sent a reconcile `Request` (a `:` key) for that Memcached object:

      ```
      err := c.Watch(
        &source.Kind{Type: &cachev1alpha1.Memcached{}}, &handler.EnqueueRequestForObject{})
      ```

      The next watch is for Deployments, but the event handler maps each event to a reconcile `Request` for the owner of the Deployment. In this case, this is the Memcached object for which the Deployment was created. This allows the controller to watch Deployments as a secondary resource:

      ```
      err := c.Watch(&source.Kind{Type: &appsv1.Deployment{}}, &handler.EnqueueRequestForOwner{
      		IsController: true,
      		OwnerType:    &cachev1alpha1.Memcached{},
      	})
      ```

   4. Every Controller has a Reconciler object with a `Reconcile()` method that implements the reconcile loop. The reconcile loop is passed the `Request` argument which is a `:` key used to lookup the primary resource object, Memcached, from the cache:

      ```
      func (r *ReconcileMemcached) Reconcile(request reconcile.Request) (reconcile.Result, error) {
        // Lookup the Memcached instance for this reconcile request
        memcached := &cachev1alpha1.Memcached{}
        err := r.client.Get(context.TODO(), request.NamespacedName, memcached)
        ...
      }
      ```

      Based on the return value of `Reconcile()` the reconcile `Request` may be requeued and the loop may be triggered again:

      ```
      // Reconcile successful - don't requeue
      return reconcile.Result{}, nil
      // Reconcile failed due to error - requeue
      return reconcile.Result{}, err
      // Requeue for any reason other than error
      return reconcile.Result{Requeue: true}, nil
      ```

5. **Build and run the Operator.**

   1. Before running the Operator, the CRD must be registered with the Kubernetes API server:

      ```
      $ oc create \
          -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
      ```

   2. After registering the CRD, there are two options for running the Operator:

      - As a Deployment inside a Kubernetes cluster
      - As Go program outside a cluster

      Choose one of the following methods.

      1. *Option A:* Running as a Deployment inside the cluster.

         1. Build the `memcached-operator` image and push it to a registry:

            ```
            $ operator-sdk build quay.io/example/memcached-operator:v0.0.1
            ```

         2. The Deployment manifest is generated at `deploy/operator.yaml`. Update the Deployment image as follows since the default is just a placeholder:

            ```
            $ sed -i 's|REPLACE_IMAGE|quay.io/example/memcached-operator:v0.0.1|g' deploy/operator.yaml
            ```

         3. Ensure you have an account on [Quay.io](https://quay.io/) for the next step, or substitute your preferred container registry. On the registry, [create a new public image](https://quay.io/new/) repository named `memcached-operator`.

         4. Push the image to the registry:

            ```
            $ podman push quay.io/example/memcached-operator:v0.0.1
            ```

         5. Setup RBAC and deploy `memcached-operator`:

            ```
            $ oc create -f deploy/role.yaml
            $ oc create -f deploy/role_binding.yaml
            $ oc create -f deploy/service_account.yaml
            $ oc create -f deploy/operator.yaml
            ```

         6. Verify that `memcached-operator` is up and running:

            ```
            $ oc get deployment
            NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
            memcached-operator       1         1         1            1           1m
            ```

      2. *Option B:* Running locally outside the cluster.

         This method is preferred during development cycle to deploy and test faster.

         Run the Operator locally with the default Kubernetes configuration file present at `$HOME/.kube/config`:

         ```
         $ operator-sdk run --local --namespace=default
         ```

         You can use a specific `kubeconfig` using the flag `--kubeconfig=`.

6. **Verify that the Operator can deploy a Memcached application** by creating a Memcached CR.

   1. Create the example `Memcached` CR that was generated at `deploy/crds/cache_v1alpha1_memcached_cr.yaml`:

      ```
      $ cat deploy/crds/cache_v1alpha1_memcached_cr.yaml
      apiVersion: "cache.example.com/v1alpha1"
      kind: "Memcached"
      metadata:
        name: "example-memcached"
      spec:
        size: 3
      
      $ oc apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
      ```

   2. Ensure that `memcached-operator` creates the Deployment for the CR:

      ```
      $ oc get deployment
      NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
      memcached-operator       1         1         1            1           2m
      example-memcached        3         3         3            3           1m
      ```

   3. Check the Pods and CR status to confirm the status is updated with the `memcached` Pod names:

      ```
      $ oc get pods
      NAME                                  READY     STATUS    RESTARTS   AGE
      example-memcached-6fd7c98d8-7dqdr     1/1       Running   0          1m
      example-memcached-6fd7c98d8-g5k7v     1/1       Running   0          1m
      example-memcached-6fd7c98d8-m7vn7     1/1       Running   0          1m
      memcached-operator-7cc7cfdf86-vvjqk   1/1       Running   0          2m
      
      $ oc get memcached/example-memcached -o yaml
      apiVersion: cache.example.com/v1alpha1
      kind: Memcached
      metadata:
        clusterName: ""
        creationTimestamp: 2018-03-31T22:51:08Z
        generation: 0
        name: example-memcached
        namespace: default
        resourceVersion: "245453"
        selfLink: /apis/cache.example.com/v1alpha1/namespaces/default/memcacheds/example-memcached
        uid: 0026cc97-3536-11e8-bd83-0800274106a1
      spec:
        size: 3
      status:
        nodes:
        - example-memcached-6fd7c98d8-7dqdr
        - example-memcached-6fd7c98d8-g5k7v
        - example-memcached-6fd7c98d8-m7vn7
      ```

7. **Verify that the Operator can manage a deployed Memcached application** by updating the size of the deployment.

   1. Change the `spec.size` field in the `memcached` CR from `3` to `4`:

      ```
      $ cat deploy/crds/cache_v1alpha1_memcached_cr.yaml
      apiVersion: "cache.example.com/v1alpha1"
      kind: "Memcached"
      metadata:
        name: "example-memcached"
      spec:
        size: 4
      ```

   2. Apply the change:

      ```
      $ oc apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
      ```

   3. Confirm that the Operator changes the Deployment size:

      ```
      $ oc get deployment
      NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
      example-memcached    4         4         4            4           5m
      ```

8. **Clean up the resources:**

   ```
   $ oc delete -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
   $ oc delete -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
   $ oc delete -f deploy/operator.yaml
   $ oc delete -f deploy/role.yaml
   $ oc delete -f deploy/role_binding.yaml
   $ oc delete -f deploy/service_account.yaml
   ```

**Additional resources**

- For more information about OpenAPI v3.0 validation schemas in CRDs, refer to the [Kubernetes documentation](https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/#specifying-a-structural-schema).

### 12.1.4. Managing a Go-based Operator using the Operator Lifecycle Manager

The previous section has covered manually running an Operator. In the next sections, we will explore using the Operator Lifecycle Manager (OLM), which is what enables a more robust deployment model for Operators being run in production environments.

The OLM helps you to install, update, and generally manage the lifecycle of all of the Operators (and their associated services) on a Kubernetes cluster. It runs as an Kubernetes extension and lets you use `oc` for all the lifecycle management functions without any additional tools.

**Prerequisites**

- OLM installed on a Kubernetes-based cluster (v1.8 or above to support the `apps/v1beta2` API group), for example OpenShift Container Platform 4.4 Preview OLM enabled
- Memcached Operator built

**Procedure**

1. **Generate an Operator manifest.**

   An Operator manifest describes how to display, create, and manage the application, in this case Memcached, as a whole. It is defined by a `ClusterServiceVersion` (CSV) object and is required for the OLM to function.

   From the `memcached-operator/` directory that was created when you built the Memcached Operator, generate the CSV manifest:

   ```
   $ operator-sdk generate csv --csv-version 0.0.1
   ```

   > NOTE：See [Building a CSV for the Operator Framework](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/design/building-your-csv.md) for more information on manually defining a manifest file.

2. **Create an OperatorGroup** that specifies the namespaces that the Operator will target. Create the following OperatorGroup in the namespace where you will create the CSV. In this example, the `default` namespace is used:

   ```yaml
   apiVersion: operators.coreos.com/v1
   kind: OperatorGroup
   metadata:
     name: memcached-operator-group
     namespace: default
   spec:
     targetNamespaces:
     - default
   ```

3. **Deploy the Operator.** Use the files that were generated into the `deploy/` directory by the Operator SDK when you built the Memcached Operator.

   1. Apply the Operator’s CSV manifest to the specified namespace in the cluster:

      ```
      $ oc apply -f deploy/olm-catalog/memcached-operator/0.0.1/memcached-operator.v0.0.1.clusterserviceversion.yaml
      ```

      When you apply this manifest, the cluster does not immediately update because it does not yet meet the requirements specified in the manifest.  当您应用此清单时，群集不会立即更新，因为它尚未满足清单中指定的要求。

   2. Create the role, role binding, and service account to grant resource permissions to the Operator, and the Custom Resource Definition (CRD) to create the Memcached type that the Operator manages:

      ```
      $ oc create -f deploy/crds/cache.example.com_memcacheds_crd.yaml
      $ oc create -f deploy/service_account.yaml
      $ oc create -f deploy/role.yaml
      $ oc create -f deploy/role_binding.yaml
      ```

      Because the OLM creates Operators in a particular namespace when a manifest is applied, administrators can leverage the native Kubernetes RBAC permission model to restrict which users are allowed to install Operators.

4. **Create an application instance.**

   The Memcached Operator is now running in the `default` namespace. Users interact with Operators via instances of `CustomResources`; in this case, the resource has the kind `Memcached`. Native Kubernetes RBAC also applies to `CustomResources`, providing administrators control over who can interact with each Operator.

   Creating instances of Memcached in this namespace will now trigger the Memcached Operator to instantiate pods running the memcached server that are managed by the Operator. The more `CustomResources` you create, the more unique instances of Memcached are managed by the Memcached Operator running in this namespace.

   ```
   $ cat <<EOF | oc apply -f -
   apiVersion: "cache.example.com/v1alpha1"
   kind: "Memcached"
   metadata:
     name: "memcached-for-wordpress"
   spec:
     size: 1
   EOF
   
   $ cat <<EOF | oc apply -f -
   apiVersion: "cache.example.com/v1alpha1"
   kind: "Memcached"
   metadata:
     name: "memcached-for-drupal"
   spec:
     size: 1
   EOF
   
   $ oc get Memcached
   NAME                      AGE
   memcached-for-drupal      22s
   memcached-for-wordpress   27s
   
   $ oc get pods
   NAME                                       READY     STATUS    RESTARTS   AGE
   memcached-app-operator-66b5777b79-pnsfj    1/1       Running   0          14m
   memcached-for-drupal-5476487c46-qbd66      1/1       Running   0          3s
   memcached-for-wordpress-65b75fd8c9-7b9x7   1/1       Running   0          8s
   ```

5. **Update an application.**

   Manually apply an update to the Operator by creating a new Operator manifest with a `replaces` field that references the old Operator manifest. The OLM ensures that all resources being managed by the old Operator have their ownership moved to the new Operator without fear of any programs stopping execution. It is up to the Operators themselves to execute any data migrations required to upgrade resources to run under a new version of the Operator.

   The following command demonstrates applying a new [Operator manifest file](https://github.com/operator-framework/getting-started/blob/master/memcachedoperator.0.0.2.csv.yaml) using a new version of the Operator and shows that the pods remain executing:

   ```
   $ curl -Lo memcachedoperator.0.0.2.csv.yaml https://raw.githubusercontent.com/operator-framework/getting-started/master/memcachedoperator.0.0.2.csv.yaml
   $ oc apply -f memcachedoperator.0.0.2.csv.yaml
   $ oc get pods
   NAME                                       READY     STATUS    RESTARTS   AGE
   memcached-app-operator-66b5777b79-pnsfj    1/1       Running   0          3s
   memcached-for-drupal-5476487c46-qbd66      1/1       Running   0          14m
   memcached-for-wordpress-65b75fd8c9-7b9x7   1/1       Running   0          14m
   ```

### 12.1.5. Additional resources

- See [Appendices](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html-single/operators/#osdk-project-scaffolding-layout_operator-appendices) to learn about the project directory structures created by the Operator SDK.
- [Operator Development Guide for Red Hat Partners](https://operators.gitbook.io/operator-developer-guide-for-red-hat-partners/)


