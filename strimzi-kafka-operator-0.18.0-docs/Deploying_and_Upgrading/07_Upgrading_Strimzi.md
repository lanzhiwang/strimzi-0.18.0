## [7. Upgrading Strimzi](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-str)

Strimzi can be upgraded with no cluster downtime. Each version of Strimzi supports one or more versions of Apache Kafka. You can upgrade to a higher Kafka version as long as it is supported by your version of Strimzi. In some cases, you can also downgrade to a lower supported Kafka version.  Strimzi 可以在没有集群停机的情况下升级。 每个版本的Strimzi 都支持一个或多个版本的Apache Kafka。 只要您的 Strimzi 版本支持，您就可以升级到更高的 Kafka 版本。 在某些情况下，您还可以降级到支持较低的 Kafka 版本。

Newer versions of Strimzi may support newer versions of Kafka, but you need to upgrade Strimzi before you can upgrade to a higher supported Kafka version.  较新版本的Strimzi可能支持较新版本的Kafka，但您需要先升级Strimzi，然后才能升级到支持的更高版本的Kafka。

> IMPORTANT | If applicable, [Resource upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-resources-str) *must* be performed after upgrading Strimzi and Kafka. 如果适用，必须在升级Strimzi 和Kafka 后进行资源升级。

### [7.1. Strimzi and Kafka upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-kafka-str)

Upgrading Strimzi is a two-stage process. To upgrade brokers and clients without downtime, you must complete the upgrade procedures in the following order:  升级Strimzi 是一个两阶段的过程。 要在不停机的情况下升级代理和客户端，您必须按以下顺序完成升级过程：

1. Update your Cluster Operator to the latest Strimzi version.
   - [Upgrading the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-cluster-operator-str)
2. Upgrade all Kafka brokers and client applications to the latest Kafka version.
   - [Upgrading Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrading-kafka-versions-str)

#### [7.1.1. Kafka versions](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-kafka-versions-str)

Kafka’s log message format version and inter-broker protocol version specify the log format version appended to messages and the version of protocol used in a cluster. As a result, the upgrade process involves making configuration changes to existing Kafka brokers and code changes to client applications (consumers and producers) to ensure the correct versions are used.  Kafka 的日志消息格式版本和代理间协议版本指定了附加到消息的日志格式版本和集群中使用的协议版本。 因此，升级过程涉及对现有 Kafka 代理进行配置更改，并对客户端应用程序（消费者和生产者）进行代码更改，以确保使用正确的版本。

The following table shows the differences between Kafka versions:

| Kafka version | Interbroker protocol version | Log message format version | ZooKeeper version |
| :------------ | :--------------------------- | :------------------------- | :---------------- |
| 2.4.0         | 2.4                          | 2.4                        | 3.5.6             |
| 2.4.1         | 2.4                          | 2.4                        | 3.5.7             |
| 2.5.0         | 2.5                          | 2.5                        | 3.5.7             |

Message format version

When a producer sends a message to a Kafka broker, the message is encoded using a specific format. The format can change between Kafka releases, so messages include a version identifying which version of the format they were encoded with. You can configure a Kafka broker to convert messages from newer format versions to a given older format version before the broker appends the message to the log.  当生产者向 Kafka 代理发送消息时，该消息使用特定格式进行编码。 格式可以在 Kafka 版本之间改变，因此消息包括一个版本，标识它们被编码的格式版本。 您可以将 Kafka 代理配置为在代理将消息附加到日志之前将消息从较新的格式版本转换为给定的旧格式版本。

In Kafka, there are two different methods for setting the message format version:

- The `message.format.version` property is set on topics.
- The `log.message.format.version` property is set on Kafka brokers.

The default value of `message.format.version` for a topic is defined by the `log.message.format.version` that is set on the Kafka broker. You can manually set the `message.format.version` of a topic by modifying its topic configuration.

The upgrade tasks in this section assume that the message format version is defined by the `log.message.format.version`.

#### [7.1.2. Upgrading the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-cluster-operator-str)

The steps to upgrade your Cluster Operator deployment to use Strimzi 0.18.0 are outlined in this section.  本节概述了升级 Cluster Operator 部署以使用 Strimzi 0.18.0 的步骤。

The availability of Kafka clusters managed by the Cluster Operator is not affected by the upgrade operation.  Cluster Operator 管理的 Kafka 集群的可用性不受升级操作的影响。

> NOTE | Refer to the documentation supporting a specific version of Strimzi for information on how to upgrade to that version.  有关如何升级到该版本的信息，请参阅支持特定版本的 Strimzi 的文档。

##### [Upgrading the Cluster Operator to a later version](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrading-the-co-str)

This procedure describes how to upgrade a Cluster Operator deployment to a later version.

Prerequisites

- An existing Cluster Operator deployment is available.
- You have [downloaded the installation files for the new version](https://strimzi.io/docs/operators/0.18.0/deploying.html#downloads-str).

Procedure

1. Take note of any configuration changes made to the existing Cluster Operator resources (in the `/install/cluster-operator` directory). Any changes will be **overwritten** by the new version of the Cluster Operator.  记下对现有 Cluster Operator 资源（在 /install/cluster-operator 目录中）所做的任何配置更改。 任何更改都将被新版本的 Cluster Operator 覆盖。

2. Update the Cluster Operator.

   1. Modify the installation files for the new version according to the namespace the Cluster Operator is running in.

      On Linux, use:

      ```bash
      sed -i 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
      ```

      On MacOS, use:

      ```bash
      sed -i '' 's/namespace: .*/namespace: my-cluster-operator-namespace/' install/cluster-operator/*RoleBinding*.yaml
      ```

   2. If you modified one or more environment variables in your existing Cluster Operator `Deployment`, edit the `install/cluster-operator/050-Deployment-cluster-operator.yaml` file to use those environment variables.

3. When you have an updated configuration, deploy it along with the rest of the installation resources:

   ```shell
   kubectl apply -f install/cluster-operator
   ```

   Wait for the rolling updates to complete.

4. Get the image for the Kafka pod to ensure the upgrade was successful:

   ```shell
   kubectl get po my-cluster-kafka-0 -o jsonpath='{.spec.containers[0].image}'
   ```

   The image tag shows the new Strimzi version followed by the Kafka version. For example, `*<New Strimzi version>*-kafka-*<Current Kafka version>*`.

5. Update existing resources to handle deprecated custom resource properties.

   - [Strimzi resource upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-resources-str)

You now have an updated Cluster Operator, but the version of Kafka running in the cluster it manages is unchanged.

What to do next

Following the Cluster Operator upgrade, you can perform a [Kafka upgrade](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrading-kafka-versions-str).

#### [7.1.3. Upgrading Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrading-kafka-versions-str)

After you have upgraded your Cluster Operator, you can upgrade your brokers to a higher supported version of Kafka.

Kafka upgrades are performed using the Cluster Operator. How the Cluster Operator performs an upgrade depends on the differences between versions of:  Kafka 升级是使用 Cluster Operator 执行的。 Cluster Operator 如何执行升级取决于以下版本之间的差异：

- Interbroker protocol
- Log message format
- ZooKeeper

When the versions are the same for the current and target Kafka version, as is typically the case for a patch level upgrade, the Cluster Operator can upgrade through a single rolling update of the Kafka brokers.  当当前和目标 Kafka 版本的版本相同时，就像补丁级别升级的典型情况一样，Cluster Operator 可以通过 Kafka 代理的单个滚动更新进行升级。

When one or more of these versions differ, the Cluster Operator requires two or three rolling updates of the Kafka brokers to perform the upgrade.

Additional resources

- [Upgrading the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-cluster-operator-str)

##### [Kafka version and image mappings](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-versions-and-images-str)

When upgrading Kafka, consider your settings for the `STRIMZI_KAFKA_IMAGES` and `Kafka.spec.kafka.version` properties.

- Each `Kafka` resource can be configured with a `Kafka.spec.kafka.version`.
- The Cluster Operator’s `STRIMZI_KAFKA_IMAGES` environment variable provides a mapping between the Kafka version and the image to be used when that version is requested in a given `Kafka` resource.
  - If `Kafka.spec.kafka.image` is not configured, the default image for the given version is used.
  - If `Kafka.spec.kafka.image` is configured, the default image is overridden.

| WARNING | The Cluster Operator cannot validate that an image actually contains a Kafka broker of the expected version. Take care to ensure that the given image corresponds to the given Kafka version. |
| ------- | ------------------------------------------------------------ |
|         |                                                              |

##### [Strategies for upgrading clients](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-strategies-for-upgrading-clients-str)

The best approach to upgrading your client applications (including Kafka Connect connectors) depends on your particular circumstances.

Consuming applications need to receive messages in a message format that they understand. You can ensure that this is the case in one of two ways:

- By upgrading all the consumers for a topic *before* upgrading any of the producers.
- By having the brokers down-convert messages to an older format.

Using broker down-conversion puts extra load on the brokers, so it is not ideal to rely on down-conversion for all topics for a prolonged period of time. For brokers to perform optimally they should not be down converting messages at all.

Broker down-conversion is configured in two ways:

- The topic-level `message.format.version` configures it for a single topic.
- The broker-level `log.message.format.version` is the default for topics that do not have the topic-level `message.format.version` configured.

Messages published to a topic in a new-version format will be visible to consumers, because brokers perform down-conversion when they receive messages from producers, not when they are sent to consumers.

There are a number of strategies you can use to upgrade your clients:

- Consumers first

  Upgrade all the consuming applications.Change the broker-level `log.message.format.version` to the new version.Upgrade all the producing applications.This strategy is straightforward, and avoids any broker down-conversion. However, it assumes that all consumers in your organization can be upgraded in a coordinated way, and it does not work for applications that are both consumers and producers. There is also a risk that, if there is a problem with the upgraded clients, new-format messages might get added to the message log so that you cannot revert to the previous consumer version.

- Per-topic consumers first

  For each topic:Upgrade all the consuming applications.Change the topic-level `message.format.version` to the new version.Upgrade all the producing applications.This strategy avoids any broker down-conversion, and means you can proceed on a topic-by-topic basis. It does not work for applications that are both consumers and producers of the same topic. Again, it has the risk that, if there is a problem with the upgraded clients, new-format messages might get added to the message log.

- Per-topic consumers first, with down conversion

  For each topic:Change the topic-level `message.format.version` to the old version (or rely on the topic defaulting to the broker-level `log.message.format.version`).Upgrade all the consuming and producing applications.Verify that the upgraded applications function correctly.Change the topic-level `message.format.version` to the new version.This strategy requires broker down-conversion, but the load on the brokers is minimized because it is only required for a single topic (or small group of topics) at a time. It also works for applications that are both consumers and producers of the same topic. This approach ensures that the upgraded producers and consumers are working correctly before you commit to using the new message format version.The main drawback of this approach is that it can be complicated to manage in a cluster with many topics and applications.

Other strategies for upgrading client applications are also possible.

| NOTE | It is also possible to apply multiple strategies. For example, for the first few applications and topics the "per-topic consumers first, with down conversion" strategy can be used. When this has proved successful another, more efficient strategy can be considered acceptable to use instead. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

##### [Upgrading Kafka brokers and client applications](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrading-brokers-newer-kafka-str)

This procedure describes how to upgrade a Strimzi Kafka cluster to a higher version of Kafka.

Prerequisites

For the `Kafka` resource to be upgraded, check:

- The Cluster Operator, which supports both versions of Kafka, is up and running.

- The `Kafka.spec.kafka.config` does not contain options that are not supported in the version of Kafka that you are upgrading to.

- Whether the `log.message.format.version` for the current Kafka version needs to be updated for the new version.

  [Consult the Kafka versions table](https://strimzi.io/docs/operators/0.18.0/deploying.html#ref-kafka-versions-str).

Procedure

1. Update the Kafka cluster configuration in an editor, as required:

   ```shell
   kubectl edit kafka my-cluster
   ```

   1. If the `log.message.format.version` of the current Kafka version is the same as that of the new Kafka version, proceed to the next step.

      Otherwise, ensure that `Kafka.spec.kafka.config` has the `log.message.format.version` configured to the default for the *current* version.

      For example, if upgrading from Kafka 2.4.1:

      ```yaml
      kind: Kafka
      spec:
        # ...
        kafka:
          version: 2.4.1
          config:
            log.message.format.version: "2.4"
            # ...
      ```

      If the `log.message.format.version` is unset, set it to the current version.

      | NOTE | The value of `log.message.format.version` must be a string to prevent it from being interpreted as a floating point number. |
      | ---- | ------------------------------------------------------------ |
      |      |                                                              |

   2. Change the `Kafka.spec.kafka.version` to specify the new version (leaving the `log.message.format.version` as the current version).

      For example, if upgrading from Kafka 2.4.1 to 2.5.0:

      ```yaml
      apiVersion: v1alpha1
      kind: Kafka
      spec:
        # ...
        kafka:
          version: 2.5.0 (1)
          config:
            log.message.format.version: "2.4" (2)
            # ...
      ```

      1. This is changed to the new version
      2. This remains at the current version

   3. If the image for the Kafka version is different from the image defined in `STRIMZI_KAFKA_IMAGES` for the Cluster Operator, update `Kafka.spec.kafka.image`.

      See [Kafka version and image mappings](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-versions-and-images-str)

2. Save and exit the editor, then wait for rolling updates to complete.

   | NOTE | Additional rolling updates occur if the new version of Kafka has a new ZooKeeper version. |
   | ---- | ------------------------------------------------------------ |
   |      |                                                              |

   Check the update in the logs or by watching the pod state transitions:

   ```shell
   kubectl logs -f <cluster-operator-pod-name> | grep -E "Kafka version upgrade from [0-9.]+ to [0-9.]+, phase ([0-9]+) of \1 completed"
   ```

   ```shell
   kubectl get po -w
   ```

   If the current and new versions of Kafka have different interbroker protocol versions, check the Cluster Operator logs for an `INFO` level message:

   ```shell
   Reconciliation #<num>(watch) Kafka(<namespace>/<name>): Kafka version upgrade from <from-version> to <to-version>, phase 2 of 2 completed
   ```

   Alternatively, if the current and new versions of Kafka have the same interbroker protocol version, check for:

   ```shell
   Reconciliation #<num>(watch) Kafka(<namespace>/<name>): Kafka version upgrade from <from-version> to <to-version>, phase 1 of 1 completed
   ```

   The rolling updates:

   - Ensure each pod is using the broker binaries for the new version of Kafka

   - Configure the brokers to send messages using the interbroker protocol of the new version of Kafka

     | NOTE | Clients are still using the old version, so brokers will convert messages to the old version before sending them to the clients. To minimize this additional load, update the clients as quickly as possible. |
     | ---- | ------------------------------------------------------------ |
     |      |                                                              |

3. Depending on your chosen strategy for upgrading clients, upgrade all client applications to use the new version of the client binaries.

   See [Strategies for upgrading clients](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-strategies-for-upgrading-clients-str)

   | WARNING | You cannot downgrade after completing this step. If you need to revert the update at this point, follow the procedure [Downgrading Kafka brokers and client applications](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-downgrading-brokers-older-kafka-str). |
   | ------- | ------------------------------------------------------------ |
   |         |                                                              |

   If required, set the version property for Kafka Connect and MirrorMaker as the new version of Kafka:

   1. For Kafka Connect, update `KafkaConnect.spec.version`
   2. For MirrorMaker, update `KafkaMirrorMaker.spec.version`

4. If the `log.message.format.version` identified in step 1 is the same as the new version proceed to the next step.

   Otherwise change the `log.message.format.version` in `Kafka.spec.kafka.config` to the default version for the new version of Kafka now being used.

   For example, if upgrading to 2.5.0:

   ```yaml
   apiVersion: v1alpha1
   kind: Kafka
   spec:
     # ...
     kafka:
       version: 2.5.0
       config:
         log.message.format.version: "2.5"
         # ...
   ```

5. Wait for the Cluster Operator to update the cluster.

   The Kafka cluster and clients are now using the new Kafka version.

Additional resources

- See [Downgrading Kafka brokers and client applications](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-downgrading-brokers-older-kafka-str) for the procedure to downgrade a Strimzi Kafka cluster from one version to a lower version.

##### [Upgrading consumers and Kafka Streams applications to cooperative rebalancing](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrading-consumers-streams-cooperative-rebalancing_str)

You can upgrade Kafka consumers and Kafka Streams applications to use the *incremental cooperative rebalance* protocol for partition rebalances instead of the default *eager rebalance* protocol. The new protocol was added in Kafka 2.4.0.

Consumers keep their partition assignments in a cooperative rebalance and only revoke them at the end of the process, if needed to achieve a balanced cluster. This reduces the unavailability of the consumer group or Kafka Streams application.

| NOTE | Upgrading to the incremental cooperative rebalance protocol is optional. The eager rebalance protocol is still supported. |
| ---- | ------------------------------------------------------------ |
|      |                                                              |

Prerequisites

- You have [upgraded Kafka brokers and client applications](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrading-brokers-newer-kafka-str) to Kafka 2.5.0.

Procedure

**To upgrade a Kafka consumer to use the incremental cooperative rebalance protocol:**

1. Replace the Kafka clients `.jar` file with the new version.
2. In the consumer configuration, append `cooperative-sticky` to the `partition.assignment.strategy`. For example, if the `range` strategy is set, change the configuration to `range, cooperative-sticky`.
3. Restart each consumer in the group in turn, waiting for the consumer to rejoin the group after each restart.
4. Reconfigure each consumer in the group by removing the earlier `partition.assignment.strategy` from the consumer configuration, leaving only the `cooperative-sticky` strategy.
5. Restart each consumer in the group in turn, waiting for the consumer to rejoin the group after each restart.

**To upgrade a Kafka Streams application to use the incremental cooperative rebalance protocol:**

1. Replace the Kafka Streams `.jar` file with the new version.
2. In the Kafka Streams configuration, set the `upgrade.from` configuration parameter to the Kafka version you are upgrading from (for example, 2.3).
3. Restart each of the stream processors (nodes) in turn.
4. Remove the `upgrade.from` configuration parameter from the Kafka Streams configuration.
5. Restart each consumer in the group in turn.

Additional resources

- [Notable changes in 2.4.0](https://kafka.apache.org/documentation/#upgrade_240_notable) in the Apache Kafka documentation.

#### [7.1.4. Downgrading Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-downgrading-kafka-versions-str)

Kafka version downgrades are performed using the Cluster Operator.

Whether and how the Cluster Operator performs a downgrade depends on the differences between versions of:

- Interbroker protocol
- Log message format
- ZooKeeper

##### [Target downgrade version](https://strimzi.io/docs/operators/0.18.0/deploying.html#com-target-downgrade-version-str)

How the Cluster Operator handles a downgrade operation depends on the `log.message.format.version`.

- If the target downgrade version of Kafka has the same `log.message.format.version` as the current version, the Cluster Operator downgrades by performing a single rolling restart of the brokers.

- If the target downgrade version of Kafka has a different `log.message.format.version`, downgrading is only possible if the running cluster has *always* had `log.message.format.version` set to the version used by the downgraded version.

  This is typically only the case if the upgrade procedure was aborted before the `log.message.format.version` was changed. In this case, the downgrade requires:

  - Two rolling restarts of the brokers if the interbroker protocol of the two versions is different
  - A single rolling restart if they are the same

##### [Downgrading Kafka brokers and client applications](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-downgrading-brokers-older-kafka-str)

This procedure describes how you can downgrade a Strimzi Kafka cluster to a lower (previous) version of Kafka, such as downgrading from 2.5.0 to 2.4.1.

| IMPORTANT | Downgrading is *not possible* if the new version has ever used a `log.message.format.version` that is not supported by the previous version, including when the default value for `log.message.format.version` is used. For example, this resource can be downgraded to Kafka version 2.4.1 because the `log.message.format.version` has not been changed:`apiVersion: v1alpha1 kind: Kafka spec:  # ...  kafka:    version: 2.5.0    config:      log.message.format.version: "2.4"      # ...`The downgrade would not be possible if the `log.message.format.version` was set at `"2.5"` or a value was absent (so that the parameter took the default value for a 2.5.0 broker of 2.5). |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

Prerequisites

For the `Kafka` resource to be downgraded, check:

- The Cluster Operator, which supports both versions of Kafka, is up and running.
- The `Kafka.spec.kafka.config` does not contain options that are not supported in the version of Kafka you are downgrading to.
- The `Kafka.spec.kafka.config` has a `log.message.format.version` that is supported by the version being downgraded to.

Procedure

1. Update the Kafka cluster configuration in an editor, as required:

   Use `kubectl edit`:

   ```shell
   kubectl edit kafka my-cluster
   ```

   1. Change the `Kafka.spec.kafka.version` to specify the previous version.

      For example, if downgrading from Kafka 2.5.0 to 2.4.1:

      ```yaml
      apiVersion: v1alpha1
      kind: Kafka
      spec:
        # ...
        kafka:
          version: 2.4.1 (1)
          config:
            log.message.format.version: "2.4" (2)
            # ...
      ```

      1. This is changed to the previous version
      2. This is unchanged

      | NOTE | You must format the value of `log.message.format.version` as a string to prevent it from being interpreted as a floating point number. |
      | ---- | ------------------------------------------------------------ |
      |      |                                                              |

   2. If the image for the Kafka version is different from the image defined in `STRIMZI_KAFKA_IMAGES` for the Cluster Operator, update `Kafka.spec.kafka.image`.

      See [Kafka version and image mappings](https://strimzi.io/docs/operators/0.18.0/deploying.html#con-versions-and-images-str)

2. Save and exit the editor, then wait for rolling updates to complete.

   Check the update in the logs or by watching the pod state transitions:

   ```shell
   kubectl logs -f <cluster-operator-pod-name> | grep -E "Kafka version downgrade from [0-9.]+ to [0-9.]+, phase ([0-9]+) of \1 completed"
   ```

   ```shell
   kubectl get po -w
   ```

   If the previous and current versions of Kafka have different interbroker protocol versions, check the Cluster Operator logs for an `INFO` level message:

   ```shell
   Reconciliation #<num>(watch) Kafka(<namespace>/<name>): Kafka version downgrade from <from-version> to <to-version>, phase 2 of 2 completed
   ```

   Alternatively, if the previous and current versions of Kafka have the same interbroker protocol version, check for:

   ```shell
   Reconciliation #<num>(watch) Kafka(<namespace>/<name>): Kafka version downgrade from <from-version> to <to-version>, phase 1 of 1 completed
   ```

3. Downgrade all client applications (consumers) to use the previous version of the client binaries.

   The Kafka cluster and clients are now using the previous Kafka version.

### [7.2. Strimzi resource upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-resources-str)

The `kafka.strimzi.io/v1alpha1` API version is deprecated. Resources that use the API version `kafka.strimzi.io/v1alpha1` must be updated to use `kafka.strimzi.io/v1beta1`.

This section describes the upgrade steps for the resources.

| IMPORTANT | The upgrade of resources *must* be performed after [upgrading the Cluster Operator](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-str), so the Cluster Operator can understand the resources. |
| --------- | ------------------------------------------------------------ |
|           |                                                              |

What if the resource upgrade does not take effect?

If the upgrade does not take effect, a warning is given in the logs on reconciliation to indicate that the resource cannot be updated until the `apiVersion` is updated.

To trigger the update, make a cosmetic change to the custom resource, such as adding an annotation.

Example annotation:

```shell
metadata:
  # ...
  annotations:
    upgrade: "Upgraded to kafka.strimzi.io/v1beta1"
```

#### [7.2.1. Upgrading Kafka resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-resources-str)

Prerequisites

- A Cluster Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `Kafka` resource in your deployment.

1. Update the `Kafka` resource in an editor.

   ```shell
   kubectl edit kafka my-cluster
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. If the `Kafka` resource has:

   ```shell
   Kafka.spec.topicOperator
   ```

   Replace it with:

   ```shell
   Kafka.spec.entityOperator.topicOperator
   ```

   For example, replace:

   ```shell
   spec:
     # ...
     topicOperator: {}
   ```

   with:

   ```shell
   spec:
     # ...
     entityOperator:
       topicOperator: {}
   ```

4. If present, move:

   ```shell
   Kafka.spec.entityOperator.affinity
   ```

   ```shell
   Kafka.spec.entityOperator.tolerations
   ```

   to:

   ```shell
   Kafka.spec.entityOperator.template.pod.affinity
   ```

   ```shell
   Kafka.spec.entityOperator.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     entityOperator:
       affinity {}
       tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     entityOperator:
       template:
         pod:
           affinity {}
           tolerations {}
   ```

5. If present, move:

   ```shell
   Kafka.spec.kafka.affinity
   ```

   ```shell
   Kafka.spec.kafka.tolerations
   ```

   to:

   ```shell
   Kafka.spec.kafka.template.pod.affinity
   ```

   ```shell
   Kafka.spec.kafka.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     kafka:
       affinity {}
       tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     kafka:
       template:
         pod:
           affinity {}
           tolerations {}
   ```

6. If present, move:

   ```shell
   Kafka.spec.zookeeper.affinity
   ```

   ```shell
   Kafka.spec.zookeeper.tolerations
   ```

   to:

   ```shell
   Kafka.spec.zookeeper.template.pod.affinity
   ```

   ```shell
   Kafka.spec.zookeeper.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     zookeeper:
       affinity {}
       tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     zookeeper:
       template:
         pod:
           affinity {}
           tolerations {}
   ```

7. Save the file, exit the editor and wait for the updated resource to be reconciled.

#### [7.2.2. Upgrading Kafka Connect resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-connect-resources-str)

Prerequisites

- A Cluster Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `KafkaConnect` resource in your deployment.

1. Update the `KafkaConnect` resource in an editor.

   ```shell
   kubectl edit kafkaconnect my-connect
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. If present, move:

   ```shell
   KafkaConnect.spec.affinity
   ```

   ```shell
   KafkaConnect.spec.tolerations
   ```

   to:

   ```shell
   KafkaConnect.spec.template.pod.affinity
   ```

   ```shell
   KafkaConnect.spec.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     affinity {}
     tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     template:
       pod:
         affinity {}
         tolerations {}
   ```

4. Save the file, exit the editor and wait for the updated resource to be reconciled.

#### [7.2.3. Upgrading Kafka Connect S2I resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-connect-s2i-resources-str)

Prerequisites

- A Cluster Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `KafkaConnectS2I` resource in your deployment.

1. Update the `KafkaConnectS2I` resource in an editor.

   ```shell
   kubectl edit kafkaconnects2i my-connect
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. If present, move:

   ```shell
   KafkaConnectS2I.spec.affinity
   ```

   ```shell
   KafkaConnectS2I.spec.tolerations
   ```

   to:

   ```shell
   KafkaConnectS2I.spec.template.pod.affinity
   ```

   ```shell
   KafkaConnectS2I.spec.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     affinity {}
     tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     template:
       pod:
         affinity {}
         tolerations {}
   ```

4. Save the file, exit the editor and wait for the updated resource to be reconciled.

#### [7.2.4. Upgrading Kafka MirrorMaker resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-mirror-maker-resources-str)

Prerequisites

- A Cluster Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `KafkaMirrorMaker` resource in your deployment.

1. Update the `KafkaMirrorMaker` resource in an editor.

   ```shell
   kubectl edit kafkamirrormaker my-connect
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. If present, move:

   ```shell
   KafkaConnectMirrorMaker.spec.affinity
   ```

   ```shell
   KafkaConnectMirrorMaker.spec.tolerations
   ```

   to:

   ```shell
   KafkaConnectMirrorMaker.spec.template.pod.affinity
   ```

   ```shell
   KafkaConnectMirrorMaker.spec.template.pod.tolerations
   ```

   For example, move:

   ```shell
   spec:
     # ...
     affinity {}
     tolerations {}
   ```

   to:

   ```shell
   spec:
     # ...
     template:
       pod:
         affinity {}
         tolerations {}
   ```

4. Save the file, exit the editor and wait for the updated resource to be reconciled.

#### [7.2.5. Upgrading Kafka Topic resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-topic-resources-str)

Prerequisites

- A Topic Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `KafkaTopic` resource in your deployment.

1. Update the `KafkaTopic` resource in an editor.

   ```shell
   kubectl edit kafkatopic my-topic
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. Save the file, exit the editor and wait for the updated resource to be reconciled.

#### [7.2.6. Upgrading Kafka User resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#proc-upgrade-kafka-user-resources-str)

Prerequisites

- A User Operator supporting the `v1beta1` API version is up and running.

Procedure

Execute the following steps for each `KafkaUser` resource in your deployment.

1. Update the `KafkaUser` resource in an editor.

   ```shell
   kubectl edit kafkauser my-user
   ```

2. Replace:

   ```shell
   apiVersion: kafka.strimzi.io/v1alpha1
   ```

   with:

   ```shell
   apiVersion:kafka.strimzi.io/v1beta1
   ```

3. Save the file, exit the editor and wait for the updated resource to be reconciled.

Table of Contents

- 

  \1. Deployment overview

  - [1.1. How Strimzi supports Kafka](https://strimzi.io/docs/operators/0.18.0/deploying.html#key-features-product_str)
  - [1.2. Strimzi Operators](https://strimzi.io/docs/operators/0.18.0/deploying.html#overview-components_str)
  - [1.3. Strimzi custom resources](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-custom-resources-str)

- 

  \2. What is deployed with Strimzi

  - [2.1. Order of deployment](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-options-order-str)
  - [2.2. Additional deployment configuration options](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-options-scope-str)

- 

  \3. Preparing for your Strimzi deployment

  - [3.1. Deployment prerequisites](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-prereqs-str)
  - [3.2. Downloading Strimzi release artifacts](https://strimzi.io/docs/operators/0.18.0/deploying.html#downloads-str)
  - [3.3. Pushing container images to your own registry](https://strimzi.io/docs/operators/0.18.0/deploying.html#container-images-str)
  - [3.4. Designating Strimzi administrators](https://strimzi.io/docs/operators/0.18.0/deploying.html#adding-users-the-strimzi-admin-role-str)
  - [3.5. Alternative cluster deployment options](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-alternatives_str)

- 

  \4. Deploying Strimzi

  - [4.1. Create the Kafka cluster](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploy-create-cluster_str)
  - [4.2. Deploy Kafka Connect](https://strimzi.io/docs/operators/0.18.0/deploying.html#kafka-connect-str)
  - [4.3. Deploy Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/deploying.html#kafka-mirror-maker-str)
  - [4.4. Deploy Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/deploying.html#kafka-bridge-str)

- 

  \5. Verifying the Strimzi deployment

  - [5.1. Deploying example clients](https://strimzi.io/docs/operators/0.18.0/deploying.html#deploying-example-clients-str)

- 

  \6. Introducing Metrics to Kafka

  - [6.1. Add Prometheus and Grafana](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str)
  - [6.2. Add Kafka Exporter](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-kafka-exporter-str)

- 

  \7. Upgrading Strimzi

  - [7.1. Strimzi and Kafka upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-kafka-str)
  - [7.2. Strimzi resource upgrades](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-upgrade-resources-str)