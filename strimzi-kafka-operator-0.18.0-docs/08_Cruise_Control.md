## [8. Cruise Control](https://strimzi.io/docs/operators/0.18.0/using.html#cruise-control-concepts-str)

You can deploy [Cruise Control](https://github.com/linkedin/cruise-control) and access a subset of its features through Strimzi custom resources.  您可以部署 Cruise Control 并通过 Strimzi 自定义资源访问其功能的子集。

Example YAML files for deploying Cruise Control and setting optimization goals are provided in `examples/cruise-control/`.  在 /examples/cruise-control/ 中提供了用于部署 Cruise Control 和设置优化目标的示例 YAML 文件。

### [8.1. Why use Cruise Control?](https://strimzi.io/docs/operators/0.18.0/using.html#con-cruise-control-overview-str)

Cruise Control reduces the time and effort involved in running an efficient and balanced Kafka cluster.  巡航控制减少了运行高效且平衡的Kafka集群所需的时间和精力。

A typical cluster can become unevenly loaded over time. Partitions that handle large amounts of message traffic might be unevenly distributed across the available brokers. To rebalance the cluster, administrators must monitor the load on brokers and manually reassign busy partitions to brokers with spare capacity.

Cruise Control automates the cluster rebalancing process. It constructs a *workload model* of resource utilization for the cluster—based on CPU, disk, and network load—and generates *optimization proposals* (that you can approve or reject) for more balanced partition assignments. A set of configurable *optimization goals* is used to calculate these proposals.

When you approve an optimization proposal, Cruise Control applies it to your Kafka cluster. When the cluster rebalancing operation is complete, the broker pods are used more effectively and the Kafka cluster is more evenly balanced.

Additional resources

- [Cruise Control Wiki](https://github.com/linkedin/cruise-control/wiki)

### [8.2. Optimization goals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-goals-str)

To rebalance a Kafka cluster, Cruise Control uses optimization goals to generate [optimization proposals](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str), which you can approve or reject.

Optimization goals are constraints on workload redistribution and resource utilization across a Kafka cluster. With a few exceptions, Strimzi supports all the optimization goals developed in the Cruise Control project. These are as follows, in descending priority order:

1. Rack-awareness
2. Replica capacity
3. Capacity: Disk capacity, Network inbound capacity, Network outbound capacity
4. Replica distribution
5. Potential network output
6. Resource distribution: Disk utilization distribution, Network inbound utilization distribution, Network outbound utilization distribution
7. Leader bytes-in rate distribution
8. Topic replica distribution
9. Leader replica distribution
10. Preferred leader election

For more information on each optimization goal, see [Goals](https://github.com/linkedin/cruise-control/wiki/Pluggable-Components#goals) in the Cruise Control Wiki.

| NOTE | CPU goals, intra-broker disk goals, "Write your own" goals, and Kafka assigner goals are not yet supported. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

As described in the following sections, you can customize the supported optimization goals by reordering them in terms of priority, and disabling goals to exclude from optimization proposal calculations.

#### Goals configuration in Strimzi

You configure optimization goals in the `Kafka` and `KafkaRebalance` custom resources. Cruise Control has configurations for [hard](https://strimzi.io/docs/operators/0.18.0/using.html#hard-soft-goals) optimization goals that must be satisfied, as well as [master](https://strimzi.io/docs/operators/0.18.0/using.html#master-goals), [default](https://strimzi.io/docs/operators/0.18.0/using.html#default-goals), and [user-provided](https://strimzi.io/docs/operators/0.18.0/using.html#user-provided-goals) optimization goals.

The following sections describe each goal configuration in more detail.

##### Hard goals and soft goals

*Hard goals* are goals that *must* be satisfied in optimization proposals. Goals that are not hard goals are known as *soft goals*, and might not be satisfied by optimization proposals. You can think of soft goals as *best effort* goals: they do *not* need to be satisfied in optimization proposals, but are included in optimization calculations. An optimization proposal that violates one or more soft goals, but satisfies all hard goals, is valid.

Cruise control will calculate optimization proposals that satisfy all the hard goals and as many soft goals as possible (in their priority order). An optimization proposal that does *not* satisfy all the hard goals is rejected by Cruise Control and not sent to the user for approval.

| NOTE | For example, you might have a soft goal to distribute a topic’s replicas evenly across the cluster (the topic replica distribution goal). Cruise Control will ignore this goal if doing so enables all the configured hard goals to be met. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

In Cruise Control, six of the [master optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#master-goals) are preset as hard goals:

```none
RackAwareGoal; ReplicaCapacityGoal; DiskCapacityGoal; NetworkInboundCapacityGoal; NetworkOutboundCapacityGoal; CpuCapacityGoal
```

Hard goals are controlled in the Cruise Control deployment configuration, by editing the `hard.goals` property in `Kafka.spec.cruiseControl.config`.

- To inherit the six preset hard goals from Cruise Control, do not specify the `hard.goals` property in `Kafka.spec.cruiseControl.config`
- To change the preset hard goals, specify the desired goals in the `hard.goals` configuration option.

Increasing the number of hard goals will reduce the likelihood of Cruise Control generating valid optimization proposals.

| NOTE | If `skipHardGoalCheck: true` is specified in the `KafkaRebalance` custom resource, Cruise Control does not check that the list of user-provided optimization goals (`goals`) contains *all* the configured hard goals (`hard.goals`). Therefore, if some, but not all, of the user-provided optimization goals are in the `hard.goals` list, Cruise Control will still treat them as hard goals even if `skipHardGoalCheck: true` is specified. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

##### Master optimization goals

The *master optimization goals* are available to all users. Goals that are not listed in the master optimization goals are not available to use for Cruise Control operations.

Unless you change the Cruise Control [deployment configuration](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str), Strimzi will inherit the following master optimization goals from Cruise Control, in descending priority order:

```none
RackAwareGoal; ReplicaCapacityGoal; DiskCapacityGoal; NetworkInboundCapacityGoal; NetworkOutboundCapacityGoal; CpuCapacityGoal; ReplicaDistributionGoal; PotentialNwOutGoal; DiskUsageDistributionGoal; NetworkInboundUsageDistributionGoal; NetworkOutboundUsageDistributionGoal; CpuUsageDistributionGoal; TopicReplicaDistributionGoal; LeaderReplicaDistributionGoal; LeaderBytesInDistributionGoal; PreferredLeaderElectionGoal
```

Six of these goals are preset as [hard goals](https://strimzi.io/docs/operators/0.18.0/using.html#hard-soft-goals).

To reduce complexity, we recommend that you use the inherited master optimization goals, unless you need to *completely* exclude one or more goals from use in `KafkaRebalance` resources. The priority order of the master optimization goals can be modified, if desired, in the [default optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#default-goals).

Master optimization goals are controlled, if needed, in the Cruise Control deployment configuration: `Kafka.spec.cruiseControl.config.goals`

- To accept the inherited master optimization goals, do not specify the `goals` property in `Kafka.spec.cruiseControl.config`.
- If you need to modify the inherited master optimization goals, specify a list of goals in the `goals` configuration option.

##### Default optimization goals

Cruise Control uses the *default optimization goals* to generate the *cached optimization proposal*. For more information about the cached optimization proposal, see [Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str).

You can override the default optimization goals by setting [user-provided optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#user-provided-goals) in a `KafkaRebalance` custom resource.

Unless you change the Cruise Control [deployment configuration](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str), the default optimization goals are the same as the master optimization goals.

- To use the master optimization goals as the default goals, do not specify the `default.goals` property in `Kafka.spec.cruiseControl.config`.
- To modify the default optimization goals, edit the `default.goals` property in `Kafka.spec.cruiseControl.config`. You must use a subset of the master optimization goals.

Example `Kafka` configuration for default optimization goals

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
  zookeeper:
    # ...
  entityOperator:
    topicOperator: {}
    userOperator: {}
  cruiseControl: {}
    capacity:
      networkIn: 10000KB/s
      networkOut: 10000KB/s
    config:
      default.goals: >
         com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
         com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
         com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal
      # ...
```

| NOTE | For an example of the complete deployment configuration, see [Deploying Cruise Control](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str). |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

If no default optimization goals are specified, the cached proposal is generated using the master optimization goals.

##### User-provided optimization goals

*User-provided optimization goals* narrow down the default goals. You can set them, if required, in the `KafkaRebalance` custom resource for a particular optimization proposal: `KafkaRebalance.spec.goals`

They are useful for generating an optimization proposal that addresses a particular scenario. For example, you might want to optimize leader replica distribution across the Kafka cluster without considering goals for disk capacity or disk utilization. So, you create a `KafkaRebalance` custom resource containing a user-provided goal for leader replica distribution only.

User-provided optimization goals must:

- Include all configured [hard goals](https://strimzi.io/docs/operators/0.18.0/using.html#hard-soft-goals), or an error occurs
- Be a subset of the master optimization goals

To ignore the configured hard goals in an optimization proposal, add the `skipHardGoalCheck: true` option to the `KafkaRebalance` custom resource.

Additional resources

- [Cruise Control configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-cruise-control-configuration-str)
- [Configurations](https://github.com/linkedin/cruise-control/wiki/Configurations) in the Cruise Control Wiki.

### [8.3. Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str)

An *optimization proposal* is a summary of proposed changes that would produce a more balanced Kafka cluster, with partition workloads distributed more evenly among the brokers. Each optimization proposal is based on the set of [optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-goals-str) that were used to generate it.

Use the summary (shown in the `status` of the `KafkaRebalance` resource) to decide whether to:

- Approve the optimization proposal. This instructs Cruise Control to apply the proposal to the Kafka cluster and start a cluster rebalance operation.
- Reject the optimization proposal. You can change the optimization goals and then generate another proposal.

| NOTE | All optimization proposals are dry runs: you cannot approve a cluster rebalance without first generating an optimization proposal. There is no limit to the number of optimization proposals that can be generated. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

#### Cached optimization proposal

Cruise Control maintains a *cached optimization proposal* based on the configured default optimization goals. Generated from the workload model, the cached optimization proposal is updated every 15 minutes to reflect the current state of the Kafka cluster. If you generate an optimization proposal using the default optimization goals, Cruise Control returns the most recent cached proposal.

To change the cached optimization proposal refresh interval, edit the `proposal.expiration.ms` setting in the Cruise Control deployment configuration. Consider a shorter interval for fast changing clusters, although this increases the load on the Cruise Control server.

#### Contents of optimization proposals

The following table explains the properties contained in an optimization proposal:

| JSON property                                                | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `numIntraBrokerReplicaMovements`                             | The total number of partition replicas that will be transferred between the disks of the cluster’s brokers.**Performance impact during rebalance operation**: Relatively high, but lower than `numReplicaMovements`. |
| `excludedBrokersForLeadership`                               | Not yet supported. An empty list is returned.                |
| `numReplicaMovements`                                        | The number of partition replicas that will be moved between separate brokers.**Performance impact during rebalance operation**: Relatively high. |
| `onDemandBalancednessScoreBefore, onDemandBalancednessScoreAfter` | A measurement of the overall *balancedness* of a Kafka Cluster, before and after the optimization proposal was generated.The calculation is 100 minus the sum of the `BalancednessScore` of each violated soft goal. Cruise Control assigns a `BalancednessScore` to every optimization goal based on several factors, including priority (the goal’s position in the list of `default.goals` or user-provided goals).The `Before` score is based on the current configuration of the Kafka cluster. The `After` score is based on the generated optimization proposal. |
| `intraBrokerDataToMoveMB`                                    | The sum of the size of each partition replica that will be moved between disks on the same broker (see also `numIntraBrokerReplicaMovements`).**Performance impact during rebalance operation**: Variable. The larger the number, the longer the cluster rebalance will take to complete. Moving a large amount of data between disks on the same broker has less impact than between separate brokers (see `dataToMoveMB`). |
| `recentWindows`                                              | The number of metrics windows upon which the optimization proposal is based. |
| `dataToMoveMB`                                               | The sum of the size of each partition replica that will be moved to a separate broker (see also `numReplicaMovements`).**Performance impact during rebalance operation**: Variable. The larger the number, the longer the cluster rebalance will take to complete. |
| `monitoredPartitionsPercentage`                              | The percentage of partitions in the Kafka cluster covered by the optimization proposal. Affected by the number of `excludedTopics`. |
| `excludedTopics`                                             | Not yet supported. An empty list is returned.                |
| `numLeaderMovements`                                         | The number of partitions whose leaders will be switched to different replicas. This involves a change to ZooKeeper configuration.**Performance impact during rebalance operation**: Relatively low. |
| `excludedBrokersForReplicaMove`                              | Not yet supported. An empty list is returned.                |

Additional resources

- [Optimization goals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-goals-str)
- [Generating optimization proposals](https://strimzi.io/docs/operators/0.18.0/using.html#proc-generating-optimization-proposals-str)
- [Approving an optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-approving-optimization-proposal-str)

### [8.4. Deploying Cruise Control](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str)

Cruise Control is configured using the `cruiseControl` property in the `Kafka` resource. Once configured, you can deploy a Cruise Control instance to your Strimzi cluster by creating or updating the `Kafka` resource.

For an overview of the `Kafka` resource, see the [sample Kafka YAML configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-sample-kafka-resource-config-deployment-configuration-kafka).

You can configure `cruiseControl` properties as part of a deployment or redeployment of a Kafka cluster. Deploy one instance of Cruise Control per Kafka cluster.

This procedure uses the following example file provided with Strimzi:

- `examples/cruise-control/cruise-control-topic.yaml`

This creates a `strimzi.cruisecontrol.metrics` topic in your Kafka cluster, which collects information from the Cruise Control Metrics Reporter for use in generating rebalance proposals. You do not need to interact with this topic after Cruise Control is deployed.

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Create the Cruise Control metrics topic in your Kafka cluster:

   ```shell
   kubectl apply -f examples/cruise-control/cruise-control-topic.yaml
   ```

2. Edit the `cruiseControl` property of the `Kafka` resource.

   The properties you can configure are shown in this example configuration:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     # ...
     cruiseControl:
       capacity: (1)
         networkIn: 10000KB/s
         networkOut: 10000KB/s
         # ...
       config: (2)
         default.goals: >
            com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
            com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal
            # ...
         goals: {}
         cpu.balance.threshold: 1.1
         metadata.max.age.ms: 300000
         send.buffer.bytes: 131072
         # ...
       resources: (3)
         requests:
           cpu: 200m
           memory: 64Mi
         limits:
           cpu: 500m
           memory: 128Mi
       logging: (4)
           type: inline
           loggers:
             cruisecontrol.root.logger: "INFO"
       template: (5)
         pod:
           metadata:
             labels:
               label1: value1
           securityContext:
             runAsUser: 1000001
             fsGroup: 0
           terminationGracePeriodSeconds: 120
       readinessProbe: (6)
         initialDelaySeconds: 15
         timeoutSeconds: 5
       livenessProbe: (7)
         initialDelaySeconds: 15
         timeoutSeconds: 5
   # ...
   ```

   1. Specifies capacity limits for broker resources. For more information, see [Capacity configuration](https://strimzi.io/docs/operators/0.18.0/using.html#capacity_configuration).
   2. Defines the Cruise Control configuration, including default and enabled optimization goals. You can provide any [standard configuration option](https://strimzi.io/docs/operators/0.18.0/using.html#ref-cruise-control-configuration-str) apart from those managed directly by Strimzi.
   3. CPU and memory resources reserved for Cruise Control. For more information, see [CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka).
   4. Defined loggers and log levels added directly (inline) or indirectly (external) through a ConfigMap. A custom ConfigMap must be placed under the log4j.properties key. Cruise Control has a single logger called cruisecontrol.root.logger. You can set the log level to INFO, ERROR, WARN, TRACE, DEBUG, FATAL or OFF. For more information, see [Logging configuration](https://strimzi.io/docs/operators/0.18.0/using.html#logging_configuration).
   5. [Customization of deployment templates and pods](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-customizing-deployments-str).
   6. [Healthcheck readiness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).
   7. [Healthcheck liveness probes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka).

3. Create or update the resource:

   ```shell
   kubectl apply -f kafka.yaml
   ```

4. Verify that Cruise Control was successfully deployed:

   ```shell
   kubectl get deployments -l app.kubernetes.io/name=strimzi
   ```

What to do next

After configuring and deploying Cruise Control, you can [generate optimization proposals](https://strimzi.io/docs/operators/0.18.0/using.html#proc-generating-optimization-proposals-str).

Additional resources

[`CruiseControlTemplate` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-CruiseControlTemplate-reference).

### [8.5. Cruise Control configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-cruise-control-configuration-str)

The `config` property in `Kafka.spec.cruiseControl` contains configuration options as keys with values as one of the following JSON types:

- String
- Number
- Boolean

| NOTE | Strings that look like JSON or YAML will need to be explicitly quoted. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

You can specify and configure all the options listed in the "Configurations" section of the [Cruise Control documentation](https://github.com/linkedin/cruise-control/wiki/Configurations), apart from those managed directly by Strimzi. Specifically, you **cannot** modify configuration options with keys equal to or starting with one of the following strings:

- `bootstrap.servers`
- `zookeeper.`
- `ssl.`
- `security.`
- `failed.brokers.zk.path`
- `webserver.http.port`
- `webserver.http.address`
- `webserver.api.urlprefix`
- `metric.reporter.sampler.bootstrap.servers`
- `metric.reporter.topic`
- `metric.reporter.topic.pattern`
- `partition.metric.sample.store.topic`
- `broker.metric.sample.store.topic`
- `capacity.config.file`
- `skip.sample.store.topic.rack.awareness.check`
- `cruise.control.metrics.topic`
- `sasl.`

If restricted options are specified, they are ignored and a warning message is printed to the Cluster Operator log file. All supported options are passed to Cruise Control.

An example Cruise Control configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  # ...
  cruiseControl:
    # ...
    config:
      default.goals: >
         com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
         com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal
      cpu.balance.threshold: 1.1
      metadata.max.age.ms: 300000
      send.buffer.bytes: 131072
    # ...
```

#### [8.5.1. Capacity configuration](https://strimzi.io/docs/operators/0.18.0/using.html#capacity_configuration)

Cruise Control uses *capacity limits* to determine if optimization goals for broker resources are being broken. An optimization will fail if a goal is broken, preventing the optimization from being used to generate an optimization proposal for balanced partition assignments. For example, an optimization that would cause a broker to exceed its CPU capacity would not be used if the `CpuCapacityGoal` is set as a hard goal.

You specify capacity limits for broker resources in the `brokerCapacity` property in `Kafka.spec.cruiseControl` . Capacity limits can be set for the following broker resources in the described units:

- `disk` - Disk storage in bytes
- `cpuUtilization` - CPU utilization as a percent (0-100)
- `inboundNetwork` - Inbound network throughput in bytes per second
- `outboundNetwork` - Outbound network throughput in bytes per second

Because Strimzi Kafka brokers are homogeneous, Cruise Control applies the same capacity limits to every broker it is monitoring.

An example Cruise Control brokerCapacity configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  # ...
  cruiseControl:
    # ...
    brokerCapacity:
      disk: 100G
      cpuUtilization: 100
      inboundNetwork: 10000KB/s
      outboundNetwork: 10000KB/s
    # ...
```

Additional resources

For more information, refer to the [`BrokerCapacity` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-BrokerCapacity-reference).

#### [8.5.2. Topic creation and configuration](https://strimzi.io/docs/operators/0.18.0/using.html#topic_creation_and_configuration)

Cruise Control requires the following three topics to be created in order to function properly:

- `strimzi.cruisecontrol.partitionmetricsamples`
- `strimzi.cruisecontrol.modeltrainingsamples`
- `strimzi.cruisecontrol.metrics`

Cruise Control will create the `strimzi.cruisecontrol.partitionmetricsamples` and `strimzi.cruisecontrol.modeltrainingsamples` topics after the Cruise Control metric reporters create the `strimzi.cruisecontrol.metrics` topic. However, if automatic topic creation is disabled in Kafka with a configuration of `auto.create.topics.enable: false` in `spec.kafka.config` when starting a new Kafka cluster, the Cruise Control metric reporters will be unable to create the `strimzi.cruisecontrol.metrics` topic. In this situation, the `strimzi.cruisecontrol.metrics` topic will need to be created manually.

To manually create the `strimzi.cruisecontrol.metrics` Cruise Control topic in your Kubernetes cluster:

```shell
kubectl apply -f examples/cruise-control/cruise-control-topic.yaml
```

Since log compaction may remove records needed by Cruise Control, all topics created by Cruise Control must be configured with `cleanup.policy=delete` to disable log compaction. Cruise Control will automatically disable log compaction for the `strimzi.cruisecontrol.partitionmetricsamples` and `strimzi.cruisecontrol.modeltrainingsamples` topics. The Cruise Control metric reporters will attempt to disable log compaction for the `strimzi.cruisecontrol.metrics` topic but will fail when being started with a new Kafka cluster. This will only become a problem when log compaction is enabled in Kafka with the setting `log.cleanup.policy=compact` in the `spec.kafka.config`. In this situation, log compaction will be enabled for `strimzi.cruisecontrol.metrics` topic and will need to be overridden with a `cleanup.policy=delete` in the `strimzi.cruisecontrol.metrics` KafkaTopic.

Here we see an example of log compaction being disabled in a Cruise Control KafkaTopic.

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: strimzi.cruisecontrol.metrics
spec:
  partitions: 1
  replicas: 1
  config:
    cleanup.policy: delete
```

#### [8.5.3. Logging configuration](https://strimzi.io/docs/operators/0.18.0/using.html#logging_configuration)

Cruise Control has its own configurable logger:

- `cruisecontrol.root.logger`

Cruise Control uses the Apache `log4j` logger implementation.

Use the `logging` property to configure loggers and logger levels.

You can set the log levels by specifying the logger and level directly (inline) or use a custom (external) ConfigMap. If a ConfigMap is used, you set `logging.name` property to the name of the ConfigMap containing the external logging configuration. Inside the ConfigMap, the logging configuration is described using `log4j.properties`.

Here we see examples of `inline` and `external` logging.

Inline logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
# ...
spec:
  cruiseControl:
    # ...
    logging:
      type: inline
      loggers:
        cruisecontrol.root.logger: "INFO"
    # ...
```

External logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
# ...
spec:
  cruiseControl:
    # ...
    logging:
      type: external
      name: customConfigMap
    # ...
```

### [8.6. Generating optimization proposals](https://strimzi.io/docs/operators/0.18.0/using.html#proc-generating-optimization-proposals-str)

When you create or update a `KafkaRebalance` resource, Cruise Control generates an [optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str) for the Kafka cluster based on the configured [optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-goals-str).

You can then analyze the summary information in the optimization proposal and decide whether to approve it.

Prerequisites

- You have [deployed Cruise Control](https://strimzi.io/docs/operators/0.18.0/using.html#proc-deploying-cruise-control-str) to your Strimzi cluster.
- You have configured [optimization goals](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-goals-str).

Procedure

1. Create a `KafkaRebalance` resource:

   1. To use the *default optimization goals* defined in the `Kafka` resource, leave the `spec` property empty:

      ```yaml
      apiVersion: kafka.strimzi.io/v1beta1
      kind: KafkaRebalance
      metadata:
        name: my-rebalance
        labels:
          strimzi.io/cluster: my-cluster
      spec: {}
      ```

   2. To set *user-provided optimization goals* instead of using the default goals, edit the `goals` property and enter one or more goals.

      In the following example, rack awareness and replica capacity are user-provided optimization goals:

      ```yaml
      apiVersion: kafka.strimzi.io/v1beta1
      kind: KafkaRebalance
      metadata:
        name: my-rebalance
        labels:
          strimzi.io/cluster: my-cluster
      spec:
        goals:
          - RackAwareGoal
          - ReplicaCapacityGoal
      ```

2. Create or update the resource:

   ```shell
   kubectl apply -f your-file
   ```

   The Cluster Operator requests the optimization proposal from Cruise Control. This might take a few minutes depending on the size of the Kafka cluster.

3. Check the status of the `KafkaRebalance` resource:

   ```shell
   kubectl describe kafkarebalance rebalance-cr-name
   ```

   Cruise Control returns one of two statuses:

   - `PendingProposal`: The rebalance operator is polling the Cruise Control API to check if the optimization proposal is ready.
   - `ProposalReady`: The optimization proposal is ready for review and, if desired, approval. The status contains the optimization proposal, in the `status.summary` property of the `KafkaRebalance` resource.

4. Review the optimization proposal.

   ```shell
   kubectl describe kafkarebalance rebalance-cr-name
   ```

   Here is an example proposal:

   ```shell
   Status:
     Conditions:
       Last Transition Time:  2020-05-19T13:50:12.533Z
       Status:                ProposalReady
       Type:                  State
     Observed Generation:     1
     Optimization Result:
       Data To Move MB:  0
       Excluded Brokers For Leadership:
       Excluded Brokers For Replica Move:
       Excluded Topics:
       Intra Broker Data To Move MB:         0
       Monitored Partitions Percentage:      100
       Num Intra Broker Replica Movements:   0
       Num Leader Movements:                 0
       Num Replica Movements:                26
       On Demand Balancedness Score After:   81.8666802863978
       On Demand Balancedness Score Before:  78.01176356230222
       Recent Windows:                       1
     Session Id:                             05539377-ca7b-45ef-b359-e13564f1458c
   ```

   For information about the different properties, see [Contents of optimization proposals](https://strimzi.io/docs/operators/0.18.0/using.html#contents-optimization-proposals).

What to do next

[Approving an optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-approving-optimization-proposal-str)

Additional resources

- [Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str)

### [8.7. Approving an optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-approving-optimization-proposal-str)

You can approve an [optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str) generated by Cruise Control, if its status is `ProposalReady`. Cruise Control will then apply the optimization proposal to the Kafka cluster, reassigning partitions to brokers and changing partition leadership.

| CAUTION | **This is not a dry run.** Before you approve an optimization proposal, you must:Refresh the proposal in case it has become out of date.Carefully review the [contents of the proposal](https://strimzi.io/docs/operators/0.18.0/using.html#contents-optimization-proposals). |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

Prerequisites

- You have [generated an optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-generating-optimization-proposals-str) from Cruise Control.
- The `KafkaRebalance` custom resource status is `ProposalReady`.

Procedure

Perform these steps for the optimization proposal that you want to approve:

1. Unless the optimization proposal is newly generated, check that it is based on current information about the state of the Kafka cluster. To do so, refresh the optimization proposal to make sure it uses the latest cluster metrics:

   1. Annotate the `KafkaRebalance` resource in Kubernetes:

      ```shell
      kubectl annotate kafkarebalance rebalance-cr-name strimzi.io/rebalance=refresh
      ```

   2. Check the status of the `KafkaRebalance` resource:

      ```shell
      kubectl describe kafkarebalance rebalance-cr-name
      ```

   3. Wait until the status changes to `ProposalReady`.

2. Approve the optimization proposal that you want Cruise Control to apply.

   Annotate the `KafkaRebalance` resource in Kubernetes:

   ```shell
   kubectl annotate kafkarebalance rebalance-cr-name strimzi.io/rebalance=approve
   ```

3. The Cluster Operator detects the annotated resource and instructs Cruise Control to rebalance the Kafka cluster.

4. Check the status of the `KafkaRebalance` resource:

   ```shell
   kubectl describe kafkarebalance rebalance-cr-name
   ```

5. Cruise Control returns one of three statuses:

   - Rebalancing: The cluster rebalance operation is in progress.
   - Ready: The cluster rebalancing operation completed successfully.
   - NotReady: An error occurred—see [Fixing problems with a `KafkaRebalance` resource](https://strimzi.io/docs/operators/0.18.0/using.html#proc-fixing-problems-with-kafkarebalance-str).

Additional resources

- [Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str)
- [Stopping a cluster rebalance](https://strimzi.io/docs/operators/0.18.0/using.html#proc-stopping-cluster-rebalance-str)

### [8.8. Stopping a cluster rebalance](https://strimzi.io/docs/operators/0.18.0/using.html#proc-stopping-cluster-rebalance-str)

Once started, a cluster rebalance operation might take some time to complete and affect the overall performance of the Kafka cluster.

If you want to stop a cluster rebalance operation that is in progress, apply a `stop` annotation to the `KafkaRebalance` custom resource. This causes Cruise Control to finish the current batch of partition reassignments and then stop the rebalance. Any partition reassignments before this point will have been successfully applied, so the Kafka cluster will be in a different state compared to before the rebalance operation started. Therefore, if further rebalancing is required, you should generate a new optimization proposal.

| NOTE | The performance of the Kafka cluster in the intermediate (stopped) state might be worse than in the initial state. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Prerequisites

- You have [approved the optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-approving-optimization-proposal-str) by annotating the `KafkaRebalance` custom resource with `approve`.
- The status of the `KafkaRebalance` custom resource is `Rebalancing`.

Procedure

1. Annotate the `KafkaRebalance` resource in Kubernetes:

   ```shell
   kubectl annotate kafkarebalance rebalance-cr-name strimzi.io/rebalance=stop
   ```

2. Check the status of the `KafkaRebalance` resource:

   ```shell
   kubectl get kafka kafkarebalance -o jsonpath='{.status}'
   ```

3. Wait until the status changes to `Stopped`.

Additional resources

- [Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str)

### [8.9. Fixing problems with a `KafkaRebalance` resource](https://strimzi.io/docs/operators/0.18.0/using.html#proc-fixing-problems-with-kafkarebalance-str)

If an issue occurs in the process of creating a `KafkaRebalance` resource, or when interacting with Cruise Control, the error is reported in the resource status, along with details of how to fix it. The resource also moves to the `NotReady` state.

To continue with the cluster rebalance operation, you must fix the problem in the `KafkaRebalance` resource itself. Problems can include the following:

- A misconfigured parameter.
- The Cruise Control server is not reachable.

When you believe that you have fixed the issue, you need to add the `refresh` annotation to the resource. During a “refresh”, a new optimization proposal is requested from the Cruise Control server.

Prerequisites

- You have [approved an optimization proposal](https://strimzi.io/docs/operators/0.18.0/using.html#proc-approving-optimization-proposal-str).
- The status of the `KafkaRebalance` custom resource for the rebalance operation is `NotReady`.

Procedure

1. Get information about the error from the `KafkaRebalance` status and resolve the issue if possible.

2. Annotate the `KafkaRebalance` resource in Kubernetes:

   ```shell
   kubectl annotate kafkarebalance cluster-rebalance-name strimzi.io/rebalance=refresh
   ```

3. Check the status of the `KafkaRebalance` resource:

   ```shell
   kubectl describe kafkarebalance rebalance-cr-name
   ```

4. Wait until the status changes to `PendingProposal`, or directly to `ProposalReady`.

Additional resources

- [Optimization proposals overview](https://strimzi.io/docs/operators/0.18.0/using.html#con-optimization-proposals-str)

## [9. Distributed tracing](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-distributed-tracing-str)

This chapter outlines the support for distributed tracing in Strimzi, using Jaeger.

How you configure distributed tracing varies by Strimzi client and component.

- You *instrument* Kafka Producer, Consumer, and Streams API applications for distributed tracing using an OpenTracing client library. This involves adding instrumentation code to these clients, which monitors the execution of individual transactions in order to generate trace data.
- Distributed tracing support is built in to the Kafka Connect, MirrorMaker, and Kafka Bridge components of Strimzi. To configure these components for distributed tracing, you configure and update the relevant custom resources.

Before configuring distributed tracing in Strimzi clients and components, you must first initialize and configure a Jaeger tracer in the Kafka cluster, as described in [Initializing a Jaeger tracer for Kafka clients](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-jaeger-tracer-kafka-clients-str).

| NOTE | Distributed tracing is not supported for Kafka brokers. |
| ---- | ------------------------------------------------------- |
|      |                                                         |

### [9.1. Overview of distributed tracing in Strimzi](https://strimzi.io/docs/operators/0.18.0/using.html#con-overview-distributed-tracing-str)

Distributed tracing allows developers and system administrators to track the progress of transactions between applications (and services in a microservice architecture) in a distributed system. This information is useful for monitoring application performance and investigating issues with target systems and end-user applications.

In Strimzi and data streaming platforms in general, distributed tracing facilitates the end-to-end tracking of messages: from source systems to the Kafka cluster and then to target systems and applications.

As an aspect of system observability, distributed tracing complements the metrics that are available to view in [Grafana dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str) and the available loggers for each component.

OpenTracing overview

Distributed tracing in Strimzi is implemented using the open source [OpenTracing](https://opentracing.io/) and [Jaeger](https://www.jaegertracing.io/) projects.

The OpenTracing specification defines APIs that developers can use to instrument applications for distributed tracing. It is independent from the tracing system.

When instrumented, applications generate *traces* for individual transactions. Traces are composed of *spans*, which define specific units of work.

To simplify the instrumentation of the Kafka Bridge and Kafka Producer, Consumer, and Streams API applications, Strimzi includes the [OpenTracing Apache Kafka Client Instrumentation](https://github.com/opentracing-contrib/java-kafka-client/blob/master/README.md) library.

| NOTE | The OpenTracing project is merging with the OpenCensus project. The new, combined project is named [OpenTelemetry](https://opentelemetry.io/). OpenTelemetry will provide compatibility for applications that are instrumented using the OpenTracing APIs. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Jaeger overview

Jaeger, a tracing system, is an implementation of the OpenTracing APIs used for monitoring and troubleshooting microservices-based distributed systems. It consists of four main components and provides client libraries for instrumenting applications. You can use the Jaeger user interface to visualize, query, filter, and analyze trace data.

An example of a query in the Jaeger user interface