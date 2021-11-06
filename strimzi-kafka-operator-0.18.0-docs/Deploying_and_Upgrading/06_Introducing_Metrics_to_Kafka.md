## [6. Introducing Metrics to Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-str)

This section describes setup options for monitoring your Strimzi deployment.  本节介绍了用于监视Strimzi部署的设置选项。

Depending on your requirements, you can:

- [Set up and deploy Prometheus and Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str)
- [Configure the `Kafka` resource to deploy Kafka Exporter with your Kafka cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-kafka-exporter-str)

When you have Prometheus and Grafana enabled, Kafka Exporter provides additional monitoring related to consumer lag.  启用Prometheus和Grafana时，Kafka Exporter将提供与消费者滞后有关的其他监视。

Additionally, you can configure your deployment to track messages end-to-end by [setting up distributed tracing](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-distributed-tracing-str).  此外，您可以通过设置分布式跟踪将部署配置为端对端跟踪消息。

Additional resources

- For more information about Prometheus, see the [Prometheus documentation](https://prometheus.io/docs/introduction/overview/).
- For more information about Grafana, see the [Grafana documentation](https://grafana.com/docs/guides/getting_started/).
- [Apache Kafka Monitoring](http://kafka.apache.org/documentation/#monitoring) describes JMX metrics exposed by Apache Kafka.
- [ZooKeeper JMX](https://zookeeper.apache.org/doc/current/zookeeperJMX.html) describes JMX metrics exposed by Apache ZooKeeper.

### [6.1. Add Prometheus and Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str)

This section describes how to monitor Strimzi Kafka, ZooKeeper, Kafka Connect, and Kafka MirrorMaker and MirrorMaker 2.0 clusters using Prometheus to provide monitoring data for example Grafana dashboards.

Prometheus and Grafana can be also used to monitor the operators. The example Grafana dashboard for operators provides:

- Information about the operator such as the number of reconciliations or number of Custom Resources they are processing
- JVM metrics from the operators

In order to run the example Grafana dashboards, you must:

1. [Add metrics configuration to your Kafka cluster resource](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-kafka-str)
2. [Deploy Prometheus and Prometheus Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str)
3. [Deploy Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-grafana-str)

> NOTE  The resources referenced in this section are intended as a starting point for setting up monitoring, but they are provided as examples only. If you require further support on configuring and running Prometheus or Grafana in production, try reaching out to their respective communities.  本节中引用的资源旨在作为设置监视的起点，但仅作为示例提供。 如果您需要在生产中配置和运行Prometheus或Grafana的进一步支持，请尝试与各自的社区联系。

#### [6.1.1. Example Metrics files](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str)

You can find the example metrics configuration files in the `examples/metrics` directory.

```
metrics
├── grafana-install
│   ├── grafana.yaml (1)
├── grafana-dashboards (2)
│   ├── strimzi-kafka-connect.json
│   ├── strimzi-kafka.json
│   ├── strimzi-zookeeper.json
│   ├── strimzi-kafka-mirror-maker-2.json
│   ├── strimzi-operators.json
│   └── strimzi-kafka-exporter.json (3)
├── kafka-connect-metrics.yaml (4)
├── kafka-metrics.yaml (5)
├── prometheus-additional-properties
│   └── prometheus-additional.yaml (6)
├── prometheus-alertmanager-config
│   └── alert-manager-config.yaml (7)
└── prometheus-install
    ├── alert-manager.yaml (8)
    ├── prometheus-rules.yaml (9)
    ├── prometheus.yaml (10)
    ├── strimzi-pod-monitor.yaml (11)
    └── strimzi-service-monitor.yaml (12)
```

1. Installation file for the Grafana image
2. Grafana dashboards
3. Grafana dashboard specific to [Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-kafka-exporter-str)
4. Metrics configuration that defines Prometheus JMX Exporter relabeling rules for Kafka Connect
5. Metrics configuration that defines Prometheus JMX Exporter relabeling rules for Kafka and ZooKeeper
6. Configuration to add roles for service monitoring
7. Hook definitions for sending notifications through Alertmanager
8. Resources for deploying and configuring Alertmanager
9. Alerting rules examples for use with Prometheus Alertmanager (deployed with Prometheus)
10. Installation file for the Prometheus image
11. Prometheus job definitions to scrape metrics data from pods
12. Prometheus job definitions to scrape metrics data from services

#### [6.1.2. Exposing Prometheus metrics](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-kafka-str)

Strimzi uses the [Prometheus JMX Exporter](https://github.com/prometheus/jmx_exporter) to expose JMX metrics from Kafka and ZooKeeper using an HTTP endpoint, which is then scraped by the Prometheus server.

##### [Prometheus metrics configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-kafka-options-str)

Strimzi provides [example configuration files for Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

Grafana dashboards are dependent on Prometheus JMX Exporter relabeling rules, which are defined for:

- Kafka and ZooKeeper as a `Kafka` resource configuration in the example `kafka-metrics.yaml` file
- Kafka Connect as `KafkaConnect` and `KafkaConnectS2I` resources in the example `kafka-connect-metrics.yaml` file

A label is a name-value pair. Relabeling is the process of writing a label dynamically. For example, the value of a label may be derived from the name of a Kafka server and client ID.

> NOTE  We show metrics configuration using `kafka-metrics.yaml` in this section, but the process is the same when configuring Kafka Connect using the `kafka-connect-metrics.yaml` file.

Additional resources

For more information on the use of relabeling, see [Configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration) in the Prometheus documentation.

##### [Prometheus metrics deployment options](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-kafka-deploy-options-str)

To apply the example metrics configuration of relabeling rules to your Kafka cluster, do one of the following:

- [Copy the example configuration to your own `Kafka` resource definition](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-kafka-str)
- [Deploy an example Kafka cluster with the metrics configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-kafka-str)

##### [Copying Prometheus metrics configuration to a Kafka resource](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-kafka-str)

To use Grafana dashboards for monitoring, you can copy [the example metrics configuration to a `Kafka` resource](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

Procedure

Execute the following steps for each `Kafka` resource in your deployment.

1. Update the `Kafka` resource in an editor.

   ```shell
   kubectl edit kafka my-cluster
   ```

2. Copy the [example configuration in `kafka-metrics.yaml`](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str) to your own `Kafka` resource definition.

3. Save the file, exit the editor and wait for the updated resource to be reconciled.

##### [Deploying a Kafka cluster with Prometheus metrics configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-kafka-str)

To use Grafana dashboards for monitoring, you can deploy [an example Kafka cluster with metrics configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

Procedure

- Deploy the Kafka cluster with the metrics configuration:

  ```shell
  kubectl apply -f kafka-metrics.yaml
  ```

#### [6.1.3. Setting up Prometheus](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str)

[Prometheus](https://prometheus.io/) provides an open source set of components for systems monitoring and alert notification.

We describe here how you can use the [CoreOS Prometheus Operator](https://github.com/coreos/prometheus-operator) to run and manage a Prometheus server that is suitable for use in production environments, but with the correct configuration you can run any Prometheus server.

> NOTE The Prometheus server configuration uses service discovery to discover the pods in the cluster from which it gets metrics. For this feature to work correctly, the service account used for running the Prometheus service pod must have access to the API server so it can retrieve the pod list.For more information, see [Discovering services](https://kubernetes.io/docs/concepts/services-networking/service/#discovering-services).

##### [Prometheus configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-prometheus-options-str)

Strimzi provides [example configuration files for the Prometheus server](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

A Prometheus image is provided for deployment:

- `prometheus.yaml`

Additional Prometheus-related configuration is also provided in the following files:

- `prometheus-additional.yaml`
- `prometheus-rules.yaml`
- `strimzi-pod-monitor.yaml`
- `strimzi-service-monitor.yaml`

For Prometheus to obtain monitoring data:

- [Deploy the Prometheus Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-operator-str)

Then use the configuration files to:

- [Deploy Prometheus](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-operator-str)

Alerting rules

The `prometheus-rules.yaml` file provides [example alerting rule examples for use with Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-alertmanager-examples-str).

##### [Prometheus resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-prometheus-resources-str)

When you apply the Prometheus configuration, the following resources are created in your Kubernetes cluster and managed by the Prometheus Operator:

- A `ClusterRole` that grants permissions to Prometheus to read the health endpoints exposed by the Kafka and ZooKeeper pods, cAdvisor and the kubelet for container metrics.
- A `ServiceAccount` for the Prometheus pods to run under.
- A `ClusterRoleBinding` which binds the `ClusterRole` to the `ServiceAccount`.
- A `Deployment` to manage the Prometheus Operator pod.
- A `ServiceMonitor` to manage the configuration of the Prometheus pod.
- A `Prometheus` to manage the configuration of the Prometheus pod.
- A `PrometheusRule` to manage alerting rules for the Prometheus pod.
- A `Secret` to manage additional Prometheus settings.
- A `Service` to allow applications running in the cluster to connect to Prometheus (for example, Grafana using Prometheus as datasource).

##### [Deploying the Prometheus Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-operator-str)

To deploy the Prometheus Operator to your Kafka cluster, apply the YAML bundle resources file from the [Prometheus CoreOS repository](https://github.com/coreos/prometheus-operator).

Procedure

1. Download the resource file from the repository and replace the example `namespace` with your own:

   On Linux, use:

   ```shell
   curl -s https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml | sed -e 's/namespace: .*/namespace: my-namespace/' > prometheus-operator-deployment.yaml
   ```

   On MacOS, use:

   ```shell
   curl -s https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml | sed -e '' 's/namespace: .*/namespace: my-namespace/' > prometheus-operator-deployment.yaml
   ```

   > NOTE  If it is not required, you can manually remove the `spec.template.spec.securityContext` property from the `prometheus-operator-deployment.yaml` file.

2. Deploy the Prometheus Operator:

   ```shell
   kubectl apply -f prometheus-operator-deployment.yaml
   ```

   > NOTE  The Prometheus Operator installation works with Kubernetes 1.18+. To check which version to use with a different Kubernetes version, refer to the [Kubernetes compatibility matrix](https://github.com/coreos/kube-prometheus#kubernetes-compatibility-matrix).

##### [Deploying Prometheus](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-str)

To deploy Prometheus to your Kafka cluster to obtain monitoring data, apply the [example resource file for the Prometheus docker image and the YAML files for Prometheus-related resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

The deployment process creates a `ClusterRoleBinding` and discovers an Alertmanager instance in the namespace specified for the deployment.

> NOTE  By default, the Prometheus Operator only supports jobs that include an `endpoints` role for service discovery. Targets are discovered and scraped for each endpoint port address. For endpoint discovery, the port address may be derived from service (`role: service`) or pod (`role: pod`) discovery.

Prerequisites

- Check the [example alerting rules provided](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-alertmanager-examples-str)

Procedure

1. Modify the Prometheus installation file (`prometheus.yaml`) according to the namespace Prometheus is going to be installed in:

   On Linux, use:

   ```shell
   sed -i 's/namespace: .*/namespace: my-namespace/' prometheus.yaml
   ```

   On MacOS, use:

   ```shell
   sed -i '' 's/namespace: .*/namespace: my-namespace/' prometheus.yaml
   ```

2. Edit the `ServiceMonitor` resource in `strimzi-service-monitor.yaml` to define Prometheus jobs that will scrape the metrics data from services. `ServiceMonitor` is used to scrape metrics through services and is used for Apache Kafka, ZooKeeper.

3. Edit the `PodMonitor` resource in `strimzi-pod-monitor.yaml` to define Prometheus jobs that will scrape the metrics data from pods. `PodMonitor` is used to scrape data directly from pods and is used for Operators.

4. To use another role:

   1. Create a `Secret` resource:

      ```shell
      kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml
      ```

   2. Edit the `additionalScrapeConfigs` property in the `prometheus.yaml` file to include the name of the `Secret` and the YAML file (`prometheus-additional.yaml`) that contains the additional configuration.

5. Deploy the Prometheus resources:

   ```shell
   kubectl apply -f strimzi-service-monitor.yaml
   kubectl apply -f strimzi-pod-monitor.yaml
   kubectl apply -f prometheus-rules.yaml
   kubectl apply -f prometheus.yaml
   ```

#### [6.1.4. Setting up Prometheus Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-alertmanager-str)

[Prometheus Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) is a plugin for handling alerts and routing them to a notification service. Alertmanager supports an essential aspect of monitoring, which is to be notified of conditions that indicate potential issues based on alerting rules.

##### [Alertmanager configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-alertmanager-options-str)

Strimzi provides [example configuration files for Prometheus Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

A configuration file defines the resources for deploying Alertmanager:

- `alert-manager.yaml`

An additional configuration file provides the hook definitions for sending notifications from your Kafka cluster.

- `alert-manager-config.yaml`

For Alertmanger to handle Prometheus alerts, use the configuration files to:

- [Deploy Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-alertmanager-str)

##### [Alerting rules](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-prometheus-alerts-str)

Alerting rules provide notifications about specific conditions observed in the metrics. Rules are declared on the Prometheus server, but Prometheus Alertmanager is responsible for alert notifications.

Prometheus alerting rules describe conditions using [PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/) expressions that are continuously evaluated.

When an alert expression becomes true, the condition is met and the Prometheus server sends alert data to the Alertmanager. Alertmanager then sends out a notification using the communication method configured for its deployment.

Alertmanager can be configured to use email, chat messages or other notification methods.

Additional resources

For more information about setting up alerting rules, see [Configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration) in the Prometheus documentation.

##### [Alerting rule examples](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-alertmanager-examples-str)

Example alerting rules for Kafka and ZooKeeper metrics are provided with Strimzi for use in a [Prometheus deployment](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-str).

General points about the alerting rule definitions:

- A `for` property is used with the rules to determine the period of time a condition must persist before an alert is triggered.
- A tick is a basic ZooKeeper time unit, which is measured in milliseconds and configured using the `tickTime` parameter of `Kafka.spec.zookeeper.config`. For example, if ZooKeeper `tickTime=3000`, 3 ticks (3 x 3000) equals 9000 milliseconds.
- The availability of the `ZookeeperRunningOutOfSpace` metric and alert is dependent on the Kubernetes configuration and storage implementation used. Storage implementations for certain platforms may not be able to supply the information on available space required for the metric to provide an alert.

Kafka alerting rules

- `UnderReplicatedPartitions`

  Gives the number of partitions for which the current broker is the lead replica but which have fewer replicas than the `min.insync.replicas` configured for their topic. This metric provides insights about brokers that host the follower replicas. Those followers are not keeping up with the leader. Reasons for this could include being (or having been) offline, and over-throttled interbroker replication. An alert is raised when this value is greater than zero, providing information on the under-replicated partitions for each broker.

- `AbnormalControllerState`

  Indicates whether the current broker is the controller for the cluster. The metric can be 0 or 1. During the life of a cluster, only one broker should be the controller and the cluster always needs to have an active controller. Having two or more brokers saying that they are controllers indicates a problem. If the condition persists, an alert is raised when the sum of all the values for this metric on all brokers is not equal to 1, meaning that there is no active controller (the sum is 0) or more than one controller (the sum is greater than 1).

- `UnderMinIsrPartitionCount`

  Indicates that the minimum number of in-sync replicas (ISRs) for a lead Kafka broker, specified using `min.insync.replicas`, that must acknowledge a write operation has not been reached. The metric defines the number of partitions that the broker leads for which the in-sync replicas count is less than the minimum in-sync. An alert is raised when this value is greater than zero, providing information on the partition count for each broker that did not achieve the minimum number of acknowledgments.

- `OfflineLogDirectoryCount`

  Indicates the number of log directories which are offline (for example, due to a hardware failure) so that the broker cannot store incoming messages anymore. An alert is raised when this value is greater than zero, providing information on the number of offline log directories for each broker.

- `KafkaRunningOutOfSpace`

  Indicates the remaining amount of disk space that can be used for writing data. An alert is raised when this value is lower than 5GiB, providing information on the disk that is running out of space for each persistent volume claim. The threshold value may be changed in `prometheus-rules.yaml`.

ZooKeeper alerting rules

- `AvgRequestLatency`

  Indicates the amount of time it takes for the server to respond to a client request. An alert is raised when this value is greater than 10 (ticks), providing the actual value of the average request latency for each server.

- `OutstandingRequests`

  Indicates the number of queued requests in the server. This value goes up when the server receives more requests than it can process. An alert is raised when this value is greater than 10, providing the actual number of outstanding requests for each server.

- `ZookeeperRunningOutOfSpace`

  Indicates the remaining amount of disk space that can be used for writing data to ZooKeeper. An alert is raised when this value is lower than 5GiB., providing information on the disk that is running out of space for each persistent volume claim.

##### [Deploying Alertmanager](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-prometheus-alertmanager-str)

To deploy Alertmanager, apply the [example configuration files](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

The sample configuration provided with Strimzi configures the Alertmanager to send notifications to a Slack channel.

The following resources are defined on deployment:

- An `Alertmanager` to manage the Alertmanager pod.
- A `Secret` to manage the configuration of the Alertmanager.
- A `Service` to provide an easy to reference hostname for other services to connect to Alertmanager (such as Prometheus).

Prerequisites

- [Metrics are configured for the Kafka cluster resource](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-kafka-str)
- [Prometheus is deployed](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str)

Procedure

1. Create a `Secret` resource from the Alertmanager configuration file (`alert-manager-config.yaml`):

   ```shell
   kubectl create secret generic alertmanager-alertmanager --from-file=alertmanager.yaml=alert-manager-config.yaml
   ```

2. Update the `alert-manager-config.yaml` file to replace the:

   - `slack_api_url` property with the actual value of the Slack API URL related to the application for the Slack workspace
   - `channel` property with the actual Slack channel on which to send notifications

3. Deploy Alertmanager:

   ```shell
   kubectl apply -f alert-manager.yaml
   ```

#### [6.1.5. Setting up Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-grafana-str)

Grafana provides visualizations of Prometheus metrics.

You can deploy and enable the example Grafana dashboards provided with Strimzi.

##### [Grafana configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-grafana-options-str)

Strimzi provides [example dashboard configuration files for Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

A Grafana docker image is provided for deployment:

- `grafana.yaml`

Example dashboards are also provided as JSON files:

- `strimzi-kafka.json`
- `strimzi-kafka-connect.json`
- `strimzi-zookeeper.json`
- `strimzi-kafka-mirror-maker-2.json`
- `strimzi-kafka-exporter.json`
- `strimzi-operators.json`

The example dashboards are a good starting point for monitoring key metrics, but they do not represent all available metrics. You may need to modify the example dashboards or add other metrics, depending on your infrastructure.

For Grafana to present the dashboards, use the configuration files to:

- [Deploy Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-grafana-str)

##### [Deploying Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-grafana-str)

To deploy Grafana to provide visualizations of Prometheus metrics, apply the [example configuration file](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str).

Prerequisites

- [Metrics are configured for the Kafka cluster resource](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-kafka-str)
- [Prometheus and Prometheus Alertmanager are deployed](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str)

Procedure

1. Deploy Grafana:

   ```shell
   kubectl apply -f grafana.yaml
   ```

2. [Enable the Grafana dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-grafana-dashboard-str).

##### [Enabling the example Grafana dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-grafana-dashboard-str)

Set up a Prometheus data source and example dashboards to enable Grafana for monitoring.

| NOTE | No alert notification rules are defined. |
| ---- | ---------------------------------------- |
|      |                                          |

When accessing a dashboard, you can use the `port-forward` command to forward traffic from the Grafana pod to the host.

For example, you can access the Grafana user interface by:

1. Running `kubectl port-forward svc/grafana 3000:3000`
2. Pointing a browser to `http://localhost:3000`

| NOTE | The name of the Grafana pod is different for each user. |
| ---- | ------------------------------------------------------- |
|      |                                                         |

Procedure

1. Access the Grafana user interface using `admin/admin` credentials.

   On the initial view choose to reset the password.

   ![Grafana login](https://strimzi.io/docs/operators/0.18.0/images/grafana_login.png)

2. Click the **Add data source** button.

   ![Grafana home](https://strimzi.io/docs/operators/0.18.0/images/grafana_home.png)

3. Add Prometheus as a data source.

   - Specify a name
   - Add *Prometheus* as the type
   - Specify the connection string to the Prometheus server ([http://prometheus-operated:9090](http://prometheus-operated:9090/)) in the URL field

4. Click **Add** to test the connection to the data source.

   ![Add Prometheus data source](https://strimzi.io/docs/operators/0.18.0/images/grafana_prometheus_data_source.png)

5. Click **Dashboards**, then **Import** to open the *Import Dashboard* window and import the example dashboards (or paste the JSON).

   ![Add Grafana dashboard](https://strimzi.io/docs/operators/0.18.0/images/grafana_import_dashboard.png)

After importing the dashboards, the Grafana dashboard homepage presents Kafka and ZooKeeper dashboards.

When the Prometheus server has been collecting metrics for a Strimzi cluster for some time, the dashboards are populated.

![Kafka dashboard](https://strimzi.io/docs/operators/0.18.0/images/grafana_kafka_dashboard.png)

Kafka dashboardKafka dashboard

![ZooKeeper dashboard](https://strimzi.io/docs/operators/0.18.0/images/grafana_zookeeper_dashboard.png)

ZooKeeper dashboardZooKeeper dashboard

#### [6.1.6. Using metrics with Minikube or Minishift](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-kafka-mini-kube-shift-str)

When adding Prometheus and Grafana servers to an Apache Kafka deployment using Minikube or Minishift, the memory available to the virtual machine should be increased (to 4 GB of RAM, for example, instead of the default 2 GB).

For information on how to increase the default amount of memory, see:

- [Installing a Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-kubernetes-str)
- [Installing an OpenShift cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-openshift-str)

Additional resources

- [Prometheus - Monitoring Docker Container Metrics using cAdvisor](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/) describes how to use cAdvisor (short for container Advisor) metrics with Prometheus to analyze and expose resource usage (CPU, Memory, and Disk) and performance data from running containers within pods on Kubernetes.

### [6.2. Add Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-kafka-exporter-str)

[Kafka Exporter](https://github.com/danielqsj/kafka_exporter) is an open source project to enhance monitoring of Apache Kafka brokers and clients. Kafka Exporter is provided with Strimzi for deployment with a Kafka cluster to extract additional metrics data from Kafka brokers related to offsets, consumer groups, consumer lag, and topics.

The metrics data is used, for example, to help identify slow consumers.

Lag data is exposed as Prometheus metrics, which can then be presented in Grafana for analysis.

If you are already using Prometheus and Grafana for monitoring of built-in Kafka metrics, you can configure Prometheus to also scrape the Kafka Exporter Prometheus endpoint.

#### [6.2.1. Monitoring Consumer lag](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-kafka-exporter-lag-str)

Consumer lag indicates the difference in the rate of production and consumption of messages. Specifically, consumer lag for a given consumer group indicates the delay between the last message in the partition and the message being currently picked up by that consumer.

The lag reflects the position of the consumer offset in relation to the end of the partition log.

Consumer lag between the producer and consumer offset

![Consumer lag](https://strimzi.io/docs/operators/0.18.0/images/consumer-lag.png)

This difference is sometimes referred to as the *delta* between the producer offset and consumer offset: the read and write positions in the Kafka broker topic partitions.

Suppose a topic streams 100 messages a second. A lag of 1000 messages between the producer offset (the topic partition head) and the last offset the consumer has read means a 10-second delay.

##### The importance of monitoring consumer lag

For applications that rely on the processing of (near) real-time data, it is critical to monitor consumer lag to check that it does not become too big. The greater the lag becomes, the further the process moves from the real-time processing objective.

Consumer lag, for example, might be a result of consuming too much old data that has not been purged, or through unplanned shutdowns.

##### Reducing consumer lag

Typical actions to reduce lag include:

- Scaling-up consumer groups by adding new consumers
- Increasing the retention time for a message to remain in a topic
- Adding more disk capacity to increase the message buffer

Actions to reduce consumer lag depend on the underlying infrastructure and the use cases Strimzi is supporting. For instance, a lagging consumer is less likely to benefit from the broker being able to service a fetch request from its disk cache. And in certain cases, it might be acceptable to automatically drop messages until a consumer has caught up.

#### [6.2.2. Example Kafka Exporter alerting rules](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-kafka-exporter-alerts-str)

If you performed the steps to introduce metrics to your deployment, you will already have your Kafka cluster configured to use the alert notification rules that support Kafka Exporter.

The rules for Kafka Exporter are defined in `prometheus-rules.yaml`, and are deployed with Prometheus. For more information, see [Prometheus](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str).

The sample alert notification rules specific to Kafka Exporter are as follows:

- `UnderReplicatedPartition`

  An alert to warn that a topic is under-replicated and the broker is not replicating to enough partitions. The default configuration is for an alert if there are one or more under-replicated partitions for a topic. The alert might signify that a Kafka instance is down or the Kafka cluster is overloaded. A planned restart of the Kafka broker may be required to restart the replication process.

- `TooLargeConsumerGroupLag`

  An alert to warn that the lag on a consumer group is too large for a specific topic partition. The default configuration is 1000 records. A large lag might indicate that consumers are too slow and are falling behind the producers.

- `NoMessageForTooLong`

  An alert to warn that a topic has not received messages for a period of time. The default configuration for the time period is 10 minutes. The delay might be a result of a configuration issue preventing a producer from publishing messages to the topic.

Adapt the default configuration of these rules according to your specific needs.

Additional resources

- [Add Prometheus and Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str)
- [Example Metrics files](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-config-files-str)
- [Alerting rules](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-metrics-prometheus-alerts-str)

#### [6.2.3. Exposing Kafka Exporter metrics](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-metrics-kafka-exporter-str)

Lag information is exposed by Kafka Exporter as Prometheus metrics for presentation in Grafana.

Kafka Exporter exposes metrics data for brokers, topics and consumer groups.

The data extracted is described here.

| Name            | Information                            |
| :-------------- | :------------------------------------- |
| `kafka_brokers` | Number of brokers in the Kafka cluster |

| Name                                               | Information                                                  |
| :------------------------------------------------- | :----------------------------------------------------------- |
| `kafka_topic_partitions`                           | Number of partitions for a topic                             |
| `kafka_topic_partition_current_offset`             | Current topic partition offset for a broker                  |
| `kafka_topic_partition_oldest_offset`              | Oldest topic partition offset for a broker                   |
| `kafka_topic_partition_in_sync_replica`            | Number of in-sync replicas for a topic partition             |
| `kafka_topic_partition_leader`                     | Leader broker ID of a topic partition                        |
| `kafka_topic_partition_leader_is_preferred`        | Shows `1` if a topic partition is using the preferred broker |
| `kafka_topic_partition_replicas`                   | Number of replicas for this topic partition                  |
| `kafka_topic_partition_under_replicated_partition` | Shows `1` if a topic partition is under-replicated           |

| Name                                 | Information                                                  |
| :----------------------------------- | :----------------------------------------------------------- |
| `kafka_consumergroup_current_offset` | Current topic partition offset for a consumer group          |
| `kafka_consumergroup_lag`            | Current approximate lag for a consumer group at a topic partition |

#### [6.2.4. Configuring Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-kafka-exporter-configuring-str)

This procedure shows how to configure Kafka Exporter in the `Kafka` resource through `KafkaExporter` properties.

For more information about configuring the `Kafka` resource, see the [sample Kafka YAML configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-sample-kafka-resource-config-deployment-configuration-kafka).

The properties relevant to the Kafka Exporter configuration are shown in this procedure.

You can configure these properties as part of a deployment or redeployment of the Kafka cluster.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `KafkaExporter` properties for the `Kafka` resource.

   The properties you can configure are shown in this example configuration:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     # ...
     kafkaExporter:
       image: my-org/my-image:latest (1)
       groupRegex: ".*" (2)
       topicRegex: ".*" (3)
       resources: (4)
         requests:
           cpu: 200m
           memory: 64Mi
         limits:
           cpu: 500m
           memory: 128Mi
       logging: debug (5)
       enableSaramaLogging: true (6)
       template: (7)
         pod:
           metadata:
             labels:
               label1: value1
           imagePullSecrets:
             - name: my-docker-credentials
           securityContext:
             runAsUser: 1000001
             fsGroup: 0
           terminationGracePeriodSeconds: 120
       readinessProbe: (8)
         initialDelaySeconds: 15
         timeoutSeconds: 5
       livenessProbe: (9)
         initialDelaySeconds: 15
         timeoutSeconds: 5
   # ...
   ```

   1. ADVANCED OPTION: Container image configuration, which is [recommended only in special situations](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka).
   2. A regular expression to specify the consumer groups to include in the metrics.
   3. A regular expression to specify the topics to include in the metrics.
   4. [CPU and memory resources to reserve](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka).
   5. Logging configuration, to log messages with a given severity (debug, info, warn, error, fatal) or above.
   6. Boolean to enable Sarama logging, a Go client library used by Kafka Exporter.
   7. [Customization of deployment templates and pods](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-customizing-deployments-str).
   8. [Healthcheck readiness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).
   9. [Healthcheck liveness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).

2. Create or update the resource:

   ```shell
   kubectl apply -f kafka.yaml
   ```

What to do next

After configuring and deploying Kafka Exporter, you can [enable Grafana to present the Kafka Exporter dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-kafka-exporter-enabling-str).

Additional resources

[./using.html#type-KafkaExporterTemplate-reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaExporterTemplate-reference).

#### [6.2.5. Enabling the Kafka Exporter Grafana dashboard](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-kafka-exporter-enabling-str)

If you deployed Kafka Exporter with your Kafka cluster, you can enable Grafana to present the metrics data it exposes.

A Kafka Exporter dashboard is provided in the `examples/metrics` directory as a JSON file:

- `strimzi-kafka-exporter.json`

Prerequisites

- Kafka cluster is deployed with [Kafka Exporter metrics configuration](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-kafka-exporter-configuring-str)
- [Prometheus and Prometheus Alertmanager are deployed to the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-prometheus-str)
- [Grafana is deployed to the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-metrics-deploying-grafana-str)

This procedure assumes you already have access to the Grafana user interface and Prometheus has been added as a data source. If you are accessing the user interface for the first time, see [Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-grafana-str).

Procedure

1. Access the Grafana user interface.

2. Click **Dashboards**, then **Import** to open the *Import Dashboard* window and import the example Kafka Exporter dashboard (or paste the JSON).

   When metrics data has been collected for some time, the Kafka Exporter charts are populated.

Kafka Exporter Grafana charts

From the metrics, you can create charts to display:

- Message in per second (from topics)
- Message in per minute (from topics)
- Lag by consumer group
- Messages consumed per minute (by consumer groups)

Use the Grafana charts to analyze lag and to check if actions to reduce lag are having an impact on an affected consumer group. If, for example, Kafka brokers are adjusted to reduce lag, the dashboard will show the *Lag by consumer group* chart going down and the *Messages consumed per minute* chart going up.

