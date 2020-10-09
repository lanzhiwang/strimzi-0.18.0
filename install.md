## [2. Evaluate Strimzi](https://strimzi.io/docs/operators/latest/quickstart.html#assembly-evaluation-str)  评估 Strimzi

The procedures in this chapter provide a quick way to evaluate the functionality of Strimzi.  本章中的过程提供了一种评估Strimzi功能的快速方法。

Follow the steps in the order provided to install Strimzi, and start sending and receiving messages from a topic:  请按照提供的顺序执行以下步骤来安装Strimzi，并开始从主题发送和接收消息：

- Ensure you have the required prerequisites  确保您具有必需的先决条件
- Install and start Minikube
- Install Strimzi
- Create a Kafka cluster
- Access the Kafka cluster to send and receive messages

### [2.1. Prerequisites](https://strimzi.io/docs/operators/latest/quickstart.html#ref-install-prerequisites-str)

- [Install and start Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/).
- You need to be able to access Strimzi [GitHub](https://github.com/strimzi/strimzi-kafka-operator/releases).

### [2.2. Downloading Strimzi](https://strimzi.io/docs/operators/latest/quickstart.html#proc-product-downloads-str)

The resources and artifacts required to install Strimzi, along with examples for configuration, are provided in a ZIP file.  ZIP文件中提供了安装Strimzi所需的资源和工件以及配置示例。

Procedure

1. Download the `strimzi-x.y.z.zip` file from [GitHub](https://github.com/strimzi/strimzi-kafka-operator/releases).

2. Unzip the file to any destination.

   - Windows or Mac: Extract the contents of the ZIP archive by double-clicking on the ZIP file.
   - Linux: Open a terminal window in the target machine and navigate to where the ZIP file was downloaded.

   Extract the ZIP file with this command:

   ```shell
   unzip strimzi-xyz.zip
   ```

### [2.3. Installing Strimzi](https://strimzi.io/docs/operators/latest/quickstart.html#proc-install-product-str)

Using the [download files](https://strimzi.io/docs/operators/latest/quickstart.html#proc-product-downloads-str), install Strimzi with the Custom Resource Definitions (CRDs) and RBAC configuration required for deployment.

In this task you create namespaces in the cluster for your deployment. Use namespaces to separate functions.

Prerequisites

- Installation requires a Kubernetes account with cluster admin credentials.  安装需要具有集群管理员凭据的Kubernetes帐户。

Procedure

1. Log in to the Kubernetes cluster using an account that has cluster admin privileges.

2. Create a new `kafka` namespace for the Strimzi Kafka Cluster Operator.

   ```shell
   kubectl create ns kafka
   ```

3. Modify the installation files to reference the `kafka` namespace where you will install the Strimzi Kafka Cluster Operator.  修改安装文件以引用“ kafka”命名空间，您将在其中安装Strimzi Kafka Cluster Operator。

> NOTE By default, the files work in the `myproject` namespace.

   - On Linux, use:

     ```shell
     sed -i 's/namespace: .*/namespace: kafka/' install/cluster-operator/*RoleBinding*.yaml
     ```

   - On Mac, use:

     ```shell
     sed -i '' 's/namespace: .*/namespace: kafka/' install/cluster-operator/*RoleBinding*.yaml
     ```

4. Create a new `my-kafka-project` namespace where you will deploy your Kafka cluster.

   ```shell
   kubectl create ns my-kafka-project
   ```

5. Edit the `install/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml` file and set the `STRIMZI_NAMESPACE` environment variable to the namespace `my-kafka-project`.

   ```yaml
   # ...
   env:
   - name: STRIMZI_NAMESPACE
     value: my-kafka-project
   # ...
   ```

6. Deploy the CRDs and role-based access control (RBAC) resources to manage the CRDs.

   ```shell
   kubectl apply -f install/cluster-operator/ -n kafka
   ```

7. Give permission to the Cluster Operator to watch the `my-kafka-project` namespace.

   ```shell
   kubectl apply -f install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n my-kafka-project
   ```

   ```shell
   kubectl apply -f install/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml -n my-kafka-project
   ```

   ```shell
   kubectl apply -f install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n my-kafka-project
   ```

   The commands create role bindings that grant permission for the Cluster Operator to access the Kafka cluster.

### [2.4. Creating a cluster](https://strimzi.io/docs/operators/latest/quickstart.html#proc-kafka-cluster-str)

With Strimzi installed, you create a Kafka cluster, then a topic within the cluster.

When you create a cluster, the Cluster Operator you deployed when installing Strimzi watches for new Kafka resources.

Prerequisites

- For the Kafka cluster, ensure a Cluster Operator is deployed.
- For the topic, you must have a running Kafka cluster.

Procedure

1. Log in to the Kubernetes cluster as a non-privileged user.

2. Create a new `my-cluster` Kafka cluster with one ZooKeeper and one Kafka broker.

   - Use `persistent-claim` storage

   - Expose the Kafka cluster outside of the Kubernetes cluster using an external listener configured to use a `nodeport`.

     ```yaml
     cat << EOF | kubectl create -n my-kafka-project -f -
     apiVersion: kafka.strimzi.io/v1beta1
     kind: Kafka
     metadata:
       name: my-cluster
     spec:
       kafka:
         replicas: 1
         listeners:
           plain: {}
           tls: {}
           external:
             type: nodeport
             tls: false
         storage:
           type: jbod
           volumes:
           - id: 0
             type: persistent-claim
             size: 100Gi
             deleteClaim: false
         config:
           offsets.topic.replication.factor: 1
           transaction.state.log.replication.factor: 1
           transaction.state.log.min.isr: 1
       zookeeper:
         replicas: 1
         storage:
           type: persistent-claim
           size: 100Gi
           deleteClaim: false
       entityOperator:
         topicOperator: {}
         userOperator: {}
     EOF
     ```

3. Wait for the cluster to be deployed:

   ```shell
   kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n my-kafka-project
   ```

4. When your cluster is ready, create a topic to publish and subscribe from your external client.

   Create the following `my-topic` custom resource definition with 3 partitions and replication factor 1 in the `my-cluster` Kafka cluster:

   ```yaml
   cat << EOF | kubectl create -n my-kafka-project -f -
   apiVersion: kafka.strimzi.io/v1beta1
   kind: KafkaTopic
   metadata:
     name: my-topic
     labels:
       strimzi.io/cluster: "my-cluster"
   spec:
     partitions: 3
     replicas: 1
   EOF
   ```

### [2.5. Sending and receiving messages from a topic](https://strimzi.io/docs/operators/latest/quickstart.html#proc-using-amq-streams-str)

You can test your Strimzi installation by sending and receiving messages to `my-topic` from outside the cluster.

Use a terminal to run a Kafka producer and consumer on a local machine.

Prerequisites

- Ensure Strimzi is installed on the Kubernetes cluster.
- ZooKeeper and Kafka must be running to be able to send and receive messages.

Procedure

1. Download the latest Kafka binaries and install Kafka on your local machine.

   [Apache Kafka download](http://kafka.apache.org/)

2. Find the port of the bootstrap service:

   ```shell
   kubectl get service my-cluster-kafka-external-bootstrap -n my-kafka-project -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}'
   ```

3. Find the IP address of the Minikube node:

   ```shell
   kubectl get nodes --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}'
   ```

4. Open a terminal, and start the Kafka console producer with the topic `my-topic`:

   ```shell
   bin/kafka-console-producer.sh --broker-list <node-address>:_<node-port>_ --topic my-topic
   ```

5. Type your message into the console where the producer is running.

6. Open a new terminal tab or window, and start the consumer to receive the messages:

   ```shell
   bin/kafka-console-consumer.sh --bootstrap-server <node-address>:_<node-port>_ --topic my-topic --from-beginning
   ```

7. Verify that you see the incoming messages in the consumer console.

8. Press Crtl+C to exit the Kafka console producer and consumer.

