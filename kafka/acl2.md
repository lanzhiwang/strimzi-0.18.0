# Getting started with Kafka ACLs

If this is your first encounter with a task of configuring Kafka auth, you have probably found a lot of pretty good articles on configuring the auth itself and enabling the ACL mechanism. But there are no readily available lists of permissions that typical consumer and producer need, so here’s the one compiled from official docs and tested in several labs.  如果这是您第一次遇到配置Kafka身份验证的任务，那么您可能已经找到了很多有关配置身份验证本身和启用ACL机制的不错的文章。 但是没有典型的消费者和生产者需要的现成的权限列表，因此这里是由官方文档编译并经过多个实验室测试的列表。

Kafka ACLs are defined in the general format of “Principal P is [Allowed/Denied] Operation O From Host H On Resource R matching ResourcePattern RP”. So below I’m giving the Operation you need to allow on a Resource in a following format:  Kafka ACL的通用格式为“主体P是[允许/拒绝]操作O从主机H在资源R上匹配ResourcePattern RP”。 因此，在下面，我以以下格式提供您需要对资源进行允许的操作：

`Operation` `Resource` Description

# Producer ACLs

`WRITE` `Topic` This applies to a normal produce action.

`WRITE` `TransactionalId` An transactional producer which has its`transactional.id` set requires this privilege.

`DESCRIBE` `TransactionalId` This applies only on transactional producers and checked when a producer tries to find the transaction coordinator.

`IDEMPOTENT_WRITE` `Cluster` An idempotent幂等 produce action requires this privilege.

In certain cases (when producer should be allowed to create and configure the topics), those resources may be needed as well.

`CREATE` `Topic` This authorizes auto topic creation if enabled but the given user doesn’t have a cluster level permission

`CREATE` `Cluster` If topic auto-creation is enabled, then the broker-side API will check for the existence of a `Cluster` level privilege. If it’s found then it’ll allow creating the topic, otherwise it’ll iterate through the `Topic` level privileges(see previous)

`DESCRIBE` `Topic` ListOffsets

`ALTER` `Topic` This is needed to be able to create partitions

# Consumer ACLs

`READ` `Topic` Regular Kafka consumers need `READ` permission on each partition they are fetching.

`READ` `Group` To consume from a topic, the principal of the consumer will require the `READ` operation on the `topic` and `group` resources. If your consumer isn’t configured to be a part of a certain `ConsumerGroup`, you need to give it a `READ` permission an all groups `(*)` since it’s going to use automatically assigned group with a unique number.

`CLUSTER_ACTION` `Cluster` A follower must have `ClusterAction` on the `Cluster` resource in order to fetch partition data.

`DESCRIBE` `Group` The application must have privileges on `group` and `topic` level too to be able to fetch offset. `Group` access is checked first, then `Topic` access.

`DESCRIBE` `Topic` See above.

`DESCRIBE` `Cluster` When the broker checks to authorize a `list_groups` request it first checks for this cluster level authorization. If none found then it proceeds to check the groups individually(see above).

# Conclusion

This should cover basic configuration of your Kafka ACLs. Please comment your experience below as this list may be an incomplete or inaccurate.




