## 12.3. Creating Helm-based Operators

https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/operators/operator-sdk#osdk-helm

This guide outlines Helm chart support in the Operator SDK and walks Operator authors through an example of building and running an Nginx Operator with the `operator-sdk` CLI tool that uses an existing Helm chart.

### 12.3.1. Helm chart support in the Operator SDK

The [Operator Framework](https://coreos.com/operators/) is an open source toolkit to manage Kubernetes native applications, called *Operators*, in an effective, automated, and scalable way. This framework includes the Operator SDK, which assists developers in bootstrapping and building an Operator based on their expertise without requiring knowledge of Kubernetes API complexities.

One of the Operator SDK’s options for generating an Operator project includes leveraging an existing Helm chart to deploy Kubernetes resources as a unified application, without having to write any Go code. Such Helm-based Operators are designed to excel at stateless applications that require very little logic when rolled out, because changes should be applied to the Kubernetes objects that are generated as part of the chart. This may sound limiting, but can be sufficient for a surprising amount of use-cases as shown by the proliferation of Helm charts built by the Kubernetes community.  用于生成Operator项目的Operator SDK的选项之一包括利用现有的Helm图表将Kubernetes资源部署为统一的应用程序，而无需编写任何Go代码。 这种基于Helm的运算符旨在在无状态应用程序中脱颖而出，这些应用程序在推出时几乎不需要逻辑，因为应该将更改应用于作为图表一部分生成的Kubernetes对象。 这听起来似乎很局限，但对于Kubernetes社区构建的Helm图表激增所显示的用例而言，可能已经足够了。

The main function of an Operator is to read from a custom object that represents your application instance and have its desired state match what is running. In the case of a Helm-based Operator, the object’s spec field is a list of configuration options that are typically described in Helm’s `values.yaml` file. Instead of setting these values with flags using the Helm CLI (for example, `helm install -f values.yaml`), you can express them within a Custom Resource (CR), which, as a native Kubernetes object, enables the benefits of RBAC applied to it and an audit trail.

For an example of a simple CR called `Tomcat`:

```
apiVersion: apache.org/v1alpha1
kind: Tomcat
metadata:
  name: example-app
spec:
  replicaCount: 2
```

The `replicaCount` value, `2` in this case, is propagated into the chart’s templates where following is used:

```
{{ .Values.replicaCount }}
```

After an Operator is built and deployed, you can deploy a new instance of an app by creating a new instance of a CR, or list the different instances running in all environments using the `oc` command:

```
$ oc get Tomcats --all-namespaces
```

There is no requirement use the Helm CLI or install Tiller; Helm-based Operators import code from the Helm project. All you have to do is have an instance of the Operator running and register the CR with a Custom Resource Definition (CRD). And because it obeys RBAC, you can more easily prevent production changes.

### 12.3.2. Installing the Operator SDK CLI

The Operator SDK has a CLI tool that assists developers in creating, building, and deploying a new Operator project. You can install the SDK CLI on your workstation so you are prepared to start authoring your own Operators.

> NOTE：This guide uses [minikube](https://github.com/kubernetes/minikube#installation) v0.25.0+ as the local Kubernetes cluster and [Quay.io](https://quay.io/) for the public registry.

#### 12.3.2.1. Installing from GitHub release

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

#### 12.3.2.2. Installing from Homebrew

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

#### 12.3.2.3. Compiling and installing from source

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

### 12.3.3. Building a Helm-based Operator using the Operator SDK

This procedure walks through an example of building a simple Nginx Operator powered by a Helm chart using tools and libraries provided by the Operator SDK.

> TIP：It is best practice to build a new Operator for each chart. This can allow for more native-behaving Kubernetes APIs (for example, `oc get Nginx`) and flexibility if you ever want to write a fully-fledged Operator in Go, migrating away from a Helm-based Operator.  最佳做法是为每个图表构建一个新的运算符。 如果您想在Go中编写成熟的Operator，而不是从基于Helm的Operator迁移，则可以提供更多本机的Kubernetes API（例如，oc get Nginx）和灵活性。

**Prerequisites**

- Operator SDK CLI installed on the development workstation
- Access to a Kubernetes-based cluster v1.11.3+ (for example OpenShift Container Platform 4.4) using an account with `cluster-admin` permissions
- OpenShift CLI (`oc`) v4.1+ installed

**Procedure**

1. **Create a new Operator project.** A namespace-scoped Operator watches and manages resources in a single namespace. Namespace-scoped Operators are preferred because of their flexibility. They enable decoupled upgrades, namespace isolation for failures and monitoring, and differing API definitions.

   To create a new Helm-based, namespace-scoped `nginx-operator` project, use the following command:

   ```
   $ operator-sdk new nginx-operator \
     --api-version=example.com/v1alpha1 \
     --kind=Nginx \
     --type=helm
   $ cd nginx-operator
   ```

   This creates the `nginx-operator` project specifically for watching the Nginx resource with APIVersion `example.com/v1apha1` and Kind `Nginx`.

2. **Customize the Operator logic.**

   For this example, the `nginx-operator` executes the following reconciliation logic for each `Nginx` Custom Resource (CR):

   - Create a Nginx Deployment if it does not exist.
   - Create a Nginx Service if it does not exist.
   - Create a Nginx Ingress if it is enabled and does not exist.
   - Ensure that the Deployment, Service, and optional Ingress match the desired configuration (for example, replica count, image, service type) as specified by the Nginx CR.

   By default, the `nginx-operator` watches `Nginx` resource events as shown in the `watches.yaml` file and executes Helm releases using the specified chart:

   ```yaml
   - version: v1alpha1
     group: example.com
     kind: Nginx
     chart: /opt/helm/helm-charts/nginx
   ```

   1. **Review the Nginx Helm chart.**

      When a Helm Operator project is created, the Operator SDK creates an example Helm chart that contains a set of templates for a simple Nginx release.

      For this example, templates are available for Deployment, Service, and Ingress resources, along with a `NOTES.txt` template, which Helm chart developers use to convey helpful information about a release.

      If you are not already familiar with Helm Charts, take a moment to review the [Helm Chart developer documentation](https://docs.helm.sh/developing_charts/).

   2. **Understand the Nginx CR spec.**

      Helm uses a concept called [values](https://docs.helm.sh/using_helm/#customizing-the-chart-before-installing) to provide customizations to a Helm chart’s defaults, which are defined in the Helm chart’s `values.yaml` file.

      Override these defaults by setting the desired values in the CR spec. You can use the number of replicas as an example:

      1. First, inspect the `helm-charts/nginx/values.yaml` file to find that the chart has a value called `replicaCount` and it is set to `1` by default. To have 2 Nginx instances in your deployment, your CR spec must contain `replicaCount: 2`.

         Update the `deploy/crds/example.com_v1alpha1_nginx_cr.yaml` file to look like the following:

         ```yaml
         apiVersion: example.com/v1alpha1
         kind: Nginx
         metadata:
           name: example-nginx
         spec:
           replicaCount: 2
         ```

      2. Similarly, the default service port is set to `80`. To instead use `8080`, update the `deploy/crds/example.com_v1alpha1_nginx_cr.yaml` file again by adding the service port override:

         ```yaml
         apiVersion: example.com/v1alpha1
         kind: Nginx
         metadata:
           name: example-nginx
         spec:
           replicaCount: 2
           service:
             port: 8080
         ```

         The Helm Operator applies the entire spec as if it was the contents of a values file, just like the `helm install -f ./overrides.yaml` command works.

3. **Deploy the CRD.**

   Before running the Operator, Kubernetes needs to know about the new custom resource definition (CRD) the operator will be watching. Deploy the following CRD:

   ```
   $ oc create -f deploy/crds/example_v1alpha1_nginx_crd.yaml
   ```

4. **Build and run the Operator.**

   There are two ways to build and run the Operator:

   - As a Pod inside a Kubernetes cluster.
   - As a Go program outside the cluster using the `operator-sdk up` command.

   Choose one of the following methods:

   1. **Run as a Pod** inside a Kubernetes cluster. This is the preferred method for production use.

      1. Build the `nginx-operator` image and push it to a registry:

         ```
         $ operator-sdk build quay.io/example/nginx-operator:v0.0.1
         $ podman push quay.io/example/nginx-operator:v0.0.1
         ```

      2. Deployment manifests are generated in the `deploy/operator.yaml` file. The deployment image in this file needs to be modified from the placeholder `REPLACE_IMAGE` to the previous built image. To do this, run:

         ```
         $ sed -i 's|REPLACE_IMAGE|quay.io/example/nginx-operator:v0.0.1|g' deploy/operator.yaml
         ```

      3. Deploy the `nginx-operator`:

         ```
         $ oc create -f deploy/service_account.yaml
         $ oc create -f deploy/role.yaml
         $ oc create -f deploy/role_binding.yaml
         $ oc create -f deploy/operator.yaml
         ```

      4. Verify that the `nginx-operator` is up and running:

         ```
         $ oc get deployment
         NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
         nginx-operator       1         1         1            1           1m
         ```

   2. **Run outside the cluster.** This method is preferred during the development cycle to speed up deployment and testing.

      It is important that the chart path referenced in the `watches.yaml` file exists on your machine. By default, the `watches.yaml` file is scaffolded to work with an Operator image built with the `operator-sdk build` command. When developing and testing your operator with the `operator-sdk run --local` command, the SDK looks in your local file system for this path.

      1. Create a symlink at this location to point to your Helm chart’s path:

         ```
         $ sudo mkdir -p /opt/helm/helm-charts
         $ sudo ln -s $PWD/helm-charts/nginx /opt/helm/helm-charts/nginx
         ```

      2. To run the Operator locally with the default Kubernetes configuration file present at `$HOME/.kube/config`:

         ```
         $ operator-sdk run --local
         ```

         To run the Operator locally with a provided Kubernetes configuration file:

         ```
         $ operator-sdk run --local --kubeconfig=<path_to_config>
         ```

5. **Deploy the `Nginx` CR.**

   Apply the `Nginx` CR that you modified earlier:

   ```
   $ oc apply -f deploy/crds/example.com_v1alpha1_nginx_cr.yaml
   ```

   Ensure that the `nginx-operator` creates the Deployment for the CR:

   ```
   $ oc get deployment
   NAME                                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   example-nginx-b9phnoz9spckcrua7ihrbkrt1        2         2         2            2           1m
   ```

   Check the Pods to confirm two replicas were created:

   ```
   $ oc get pods
   NAME                                                      READY     STATUS    RESTARTS   AGE
   example-nginx-b9phnoz9spckcrua7ihrbkrt1-f8f9c875d-fjcr9   1/1       Running   0          1m
   example-nginx-b9phnoz9spckcrua7ihrbkrt1-f8f9c875d-ljbzl   1/1       Running   0          1m
   ```

   Check that the Service port is set to `8080`:

   ```
   $ oc get service
   NAME                                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
   example-nginx-b9phnoz9spckcrua7ihrbkrt1   ClusterIP   10.96.26.3   <none>        8080/TCP   1m
   ```

6. **Update the `replicaCount` and remove the port.**

   Change the `spec.replicaCount` field from `2` to `3`, remove the `spec.service` field, and apply the change:

   ```
   $ cat deploy/crds/example.com_v1alpha1_nginx_cr.yaml
   apiVersion: "example.com/v1alpha1"
   kind: "Nginx"
   metadata:
     name: "example-nginx"
   spec:
     replicaCount: 3
   
   $ oc apply -f deploy/crds/example.com_v1alpha1_nginx_cr.yaml
   ```

   Confirm that the Operator changes the Deployment size:

   ```
   $ oc get deployment
   NAME                                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   example-nginx-b9phnoz9spckcrua7ihrbkrt1        3         3         3            3           1m
   ```

   Check that the Service port is set to the default `80`:

   ```
   $ oc get service
   NAME                                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)  AGE
   example-nginx-b9phnoz9spckcrua7ihrbkrt1   ClusterIP   10.96.26.3   <none>        80/TCP   1m
   ```

7. **Clean up the resources:**

   ```
   $ oc delete -f deploy/crds/example.com_v1alpha1_nginx_cr.yaml
   $ oc delete -f deploy/operator.yaml
   $ oc delete -f deploy/role_binding.yaml
   $ oc delete -f deploy/role.yaml
   $ oc delete -f deploy/service_account.yaml
   $ oc delete -f deploy/crds/example_v1alpha1_nginx_crd.yaml
   ```

### 12.3.4. Additional resources

- See [Appendices](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html-single/operators/#osdk-project-scaffolding-layout_operator-appendices) to learn about the project directory structures created by the Operator SDK.
- [Operator Development Guide for Red Hat Partners](https://operators.gitbook.io/operator-developer-guide-for-red-hat-partners/)




