### [11.3. Recovering a cluster from persistent volumes](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-recovery_str)

You can recover a Kafka cluster from persistent volumes (PVs) if they are still present.  您可以从持久卷（PV）中恢复Kafka群集（如果它们仍然存在）。

You might want to do this, for example, after:  您可能想要这样做，例如，在之后：

- A namespace was deleted unintentionally  命名空间被无意删除
- A whole Kubernetes cluster is lost, but the PVs remain in the infrastructure  整个Kubernetes集群丢失了，但PV保留在基础架构中

#### [11.3.1. Recovery from namespace deletion](https://strimzi.io/docs/operators/0.18.0/using.html#namespace-deletion_str)

Recovery from namespace deletion is possible because of the relationship between persistent volumes and namespaces. A `PersistentVolume` (PV) is a storage resource that lives outside of a namespace. A PV is mounted into a Kafka pod using a `PersistentVolumeClaim` (PVC), which lives inside a namespace.  由于永久卷和名称空间之间的关系，可以从名称空间删除中恢复。 PersistentVolume（PV）是驻留在名称空间之外的存储资源。 使用PersistentVolumeClaim（PVC）将PV安装到Kafka吊舱中，该容器位于命名空间中。

The reclaim policy for a PV tells a cluster how to act when a namespace is deleted. If the reclaim policy is set as:  PV的回收策略告诉集群删除命名空间时如何操作。 如果将回收策略设置为：

- *Delete* (default), PVs are deleted when PVCs are deleted within a namespace
- *Retain*, PVs are not deleted when a namespace is deleted

To ensure that you can recover from a PV if a namespace is deleted unintentionally, the policy must be reset from *Delete* to *Retain* in the PV specification using the `persistentVolumeReclaimPolicy` property:

```shell
apiVersion: v1
kind: PersistentVolume
# ...
spec:
  # ...
  persistentVolumeReclaimPolicy: Retain
```

Alternatively, PVs can inherit the reclaim policy of an associated storage class. Storage classes are used for dynamic volume allocation.  或者，PV可以继承关联存储类的回收策略。 存储类用于动态卷分配。

By configuring the `reclaimPolicy` property for the storage class, PVs that use the storage class are created with the appropriate reclaim policy. The storage class is configured for the PV using the `storageClassName` property.

```yaml
apiVersion: v1
kind: StorageClass
metadata:
  name: gp2-retain
parameters:
  # ...
# ...
reclaimPolicy: Retain
```

```yaml
apiVersion: v1
kind: PersistentVolume
# ...
spec:
  # ...
  storageClassName: gp2-retain
```

> NOTE If you are using *Retain* as the reclaim policy, but you want to delete an entire cluster, you need to delete the PVs manually. Otherwise they will not be deleted, and may cause unnecessary expenditure on resources.  如果您使用保留作为回收策略，但是要删除整个集群，则需要手动删除PV。 否则它们将不会被删除，并可能导致不必要的资源支出。

#### [11.3.2. Recovery from loss of a Kubernetes cluster](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-loss_str)

When a cluster is lost, you can use the data from disks/volumes to recover the cluster if they were preserved within the infrastructure. The recovery procedure is the same as with namespace deletion, assuming PVs can be recovered and they were created manually.  当群集丢失时，如果磁盘/卷中的数据保留在基础架构中，则可以使用它们来恢复群集。 恢复过程与删除命名空间的过程相同，假定PV可以恢复并且是手动创建的。

#### [11.3.3. Recovering a deleted cluster from persistent volumes](https://strimzi.io/docs/operators/0.18.0/using.html#cluster-recovery-volume_str)

This procedure describes how to recover a deleted cluster from persistent volumes (PVs).

In this situation, the Topic Operator identifies that topics exist in Kafka, but the `KafkaTopic` resources do not exist.  在这种情况下，主题运算符会确定主题存在于Kafka中，但KafkaTopic资源不存在。

When you get to the step to recreate your cluster, you have two options:  在执行重新创建集群的步骤时，有两个选择：

1. Use *Option 1* when you can recover all `KafkaTopic` resources.  当您可以恢复所有`KafkaTopic`资源时，请使用选项1。

   The `KafkaTopic` resources must therefore be recovered before the cluster is started so that the corresponding topics are not deleted by the Topic Operator.  必须在启动群集之前恢复KafkaTopic资源，以使主题运算符不会删除相应的主题。

2. Use *Option 2* when you are unable to recover all `KafkaTopic` resources.

   This time you deploy your cluster without the Topic Operator, delete the Topic Operator data in ZooKeeper, and then redeploy it so that the Topic Operator can recreate the `KafkaTopic` resources from the corresponding topics. 这次，您在没有主题操作符的情况下部署集群，请在ZooKeeper中删除主题操作符数据，然后重新部署它，以便主题操作符可以从相应的主题重新创建KafkaTopic资源。

> NOTE If the Topic Operator is not deployed, you only need to recover the `PersistentVolumeClaim` (PVC) resources.

Before you begin

In this procedure, it is essential that PVs are mounted into the correct PVC to avoid data corruption. A `volumeName` is specified for the PVC and this must match the name of the PV.  在此过程中，至关重要的是将PV安装到正确的PVC中，以避免数据损坏。 为PVC指定了volumeName，它必须与PV的名称匹配。

For more information, see:

- [Persistent Volume Claim naming](https://strimzi.io/docs/operators/0.18.0/ref-persistent-storage-str.html#pvc-naming)
- [JBOD and Persistent Volume Claims](https://strimzi.io/docs/operators/0.18.0/ref-jbod-storage-str.html#jbod-pvc)

> NOTE The procedure does not include recovery of `KafkaUser` resources, which must be recreated manually. If passwords and certificates need to be retained, secrets must be recreated before creating the `KafkaUser` resources.

Procedure

1. Check information on the PVs in the cluster:

   ```shell
   kubectl get pv
   ```

   Information is presented for PVs with data.

   Example output showing columns important to this procedure:

   ```shell
   NAME                                         RECLAIMPOLICY CLAIM
   pvc-5e9c5c7f-3317-11ea-a650-06e1eadd9a4c ... Retain ...    myproject/data-my-cluster-zookeeper-1
   pvc-5e9cc72d-3317-11ea-97b0-0aef8816c7ea ... Retain ...    myproject/data-my-cluster-zookeeper-0
   pvc-5ead43d1-3317-11ea-97b0-0aef8816c7ea ... Retain ...    myproject/data-my-cluster-zookeeper-2
   pvc-7e1f67f9-3317-11ea-a650-06e1eadd9a4c ... Retain ...    myproject/data-0-my-cluster-kafka-0
   pvc-7e21042e-3317-11ea-9786-02deaf9aa87e ... Retain ...    myproject/data-0-my-cluster-kafka-1
   pvc-7e226978-3317-11ea-97b0-0aef8816c7ea ... Retain ...    myproject/data-0-my-cluster-kafka-2
   ```

   - *NAME* shows the name of each PV.
   - *RECLAIM POLICY* shows that PVs are *retained*.
   - *CLAIM* shows the link to the original PVCs.

2. Recreate the original namespace:

   ```shell
   kubectl create namespace myproject
   ```

3. Recreate the original PVC resource specifications, linking the PVCs to the appropriate PV:

   For example:

   ```shell
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: data-0-my-cluster-kafka-0
   spec:
     accessModes:
     - ReadWriteOnce
     resources:
       requests:
         storage: 100Gi
     storageClassName: gp2-retain
     volumeMode: Filesystem
     volumeName: pvc-7e1f67f9-3317-11ea-a650-06e1eadd9a4c
   ```

4. Edit the PV specifications to delete the `claimRef` properties that bound the original PVC.

   For example:

   ```shell
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     annotations:
       kubernetes.io/createdby: aws-ebs-dynamic-provisioner
       pv.kubernetes.io/bound-by-controller: "yes"
       pv.kubernetes.io/provisioned-by: kubernetes.io/aws-ebs
     creationTimestamp: "<date>"
     finalizers:
     - kubernetes.io/pv-protection
     labels:
       failure-domain.beta.kubernetes.io/region: eu-west-1
       failure-domain.beta.kubernetes.io/zone: eu-west-1c
     name: pvc-7e226978-3317-11ea-97b0-0aef8816c7ea
     resourceVersion: "39431"
     selfLink: /api/v1/persistentvolumes/pvc-7e226978-3317-11ea-97b0-0aef8816c7ea
     uid: 7efe6b0d-3317-11ea-a650-06e1eadd9a4c
   spec:
     accessModes:
     - ReadWriteOnce
     awsElasticBlockStore:
       fsType: xfs
       volumeID: aws://eu-west-1c/vol-09db3141656d1c258
     capacity:
       storage: 100Gi
     claimRef:
       apiVersion: v1
       kind: PersistentVolumeClaim
       name: data-0-my-cluster-kafka-2
       namespace: myproject
       resourceVersion: "39113"
       uid: 54be1c60-3319-11ea-97b0-0aef8816c7ea
     nodeAffinity:
       required:
         nodeSelectorTerms:
         - matchExpressions:
           - key: failure-domain.beta.kubernetes.io/zone
             operator: In
             values:
             - eu-west-1c
           - key: failure-domain.beta.kubernetes.io/region
             operator: In
             values:
             - eu-west-1
     persistentVolumeReclaimPolicy: Retain
     storageClassName: gp2-retain
     volumeMode: Filesystem
   ```

   In the example, the following properties are deleted:

   ```shell
   claimRef:
     apiVersion: v1
     kind: PersistentVolumeClaim
     name: data-0-my-cluster-kafka-2
     namespace: myproject
     resourceVersion: "39113"
     uid: 54be1c60-3319-11ea-97b0-0aef8816c7ea
   ```

5. Deploy the Cluster Operator.

   ```shell
   kubectl apply -f install/cluster-operator -n my-project
   ```

6. Recreate your cluster.

   Follow the steps depending on whether or not you have all the `KafkaTopic` resources needed to recreate your cluster.

   ***Option 1\***: If you have **all** the `KafkaTopic` resources that existed before you lost your cluster, including internal topics such as committed offsets from `__consumer_offsets`:

   1. Recreate all `KafkaTopic` resources.

      It is essential that you recreate the resources before deploying the cluster, or the Topic Operator will delete the topics.

   2. Deploy the Kafka cluster.

      For example:

      ```shell
      kubectl apply -f kafka.yaml
      ```

   ***Option 2\***: If you do not have all the `KafkaTopic` resources that existed before you lost your cluster:

   1. Deploy the Kafka cluster, as with the first option, but without the Topic Operator by removing the `topicOperator` property from the Kafka resource before deploying.

      If you include the Topic Operator in the deployment, the Topic Operator will delete all the topics.

   2. Run an `exec` command to one of the Kafka broker pods to open the ZooKeeper shell script.

      For example, where *my-cluster-kafka-0* is the name of the broker pod:

      ```shell
      kubectl exec my-cluster-kafka-0 bin/zookeeper-shell.sh localhost:2181
      ```

   3. Delete the whole `/strimzi` path to remove the Topic Operator storage:

      ```shell
      deleteall /strimzi
      ```

   4. Enable the Topic Operator by redeploying the Kafka cluster with the `topicOperator` property to recreate the `KafkaTopic` resources.

      For example:

      ```shell
      apiVersion: kafka.strimzi.io/v1beta1
      kind: Kafka
      metadata:
        name: my-cluster
      spec:
        #...
        entityOperator:
          topicOperator: {} (1)
          #...
      ```

   1. Here we show the default configuration, which has no additional properties. You specify the required configuration using the properties described in [`EntityTopicOperatorSpec` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-EntityTopicOperatorSpec-reference).

7. Verify the recovery by listing the `KafkaTopic` resources:

   ```shell
   kubectl get KafkaTopic
   ```

