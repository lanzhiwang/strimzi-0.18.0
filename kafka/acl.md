#### [Examples](http://kafka.apache.org/25/documentation.html#security_authz_examples)

- Adding Acls

Suppose you want to add an acl "Principals User:Bob and User:Alice are allowed to perform Operation Read and Write on Topic Test-Topic from IP 198.51.100.0 and IP 198.51.100.1". You can do that by executing the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic
```

By default, all principals that don't have an explicit acl that allows access for an operation to a resource are denied. In rare cases where an allow acl is defined that allows access to all but some principal we will have to use the --deny-principal and --deny-host option. For example, if we want to allow all users to Read from Test-topic but only deny User:BadBob from IP 198.51.100.3 we can do so using following commands:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:* --allow-host * --deny-principal User:BadBob --deny-host 198.51.100.3 --operation Read --topic Test-topic
```

Note that `--allow-host` and `deny-host` only support IP addresses (hostnames are not supported). Above examples add acls to a topic by specifying --topic [topic-name] as the resource pattern option. Similarly user can add acls to cluster by specifying --cluster and to a consumer group by specifying --group [group-name]. You can add acls on any resource of a certain type, e.g. suppose you wanted to add an acl "Principal User:Peter is allowed to produce to any Topic from IP 198.51.200.0" You can do that by using the wildcard resource '*', e.g. by executing the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Peter --allow-host 198.51.200.1 --producer --topic *
```

You can add acls on prefixed resource patterns, e.g. suppose you want to add an acl "Principal User:Jane is allowed to produce to any Topic whose name starts with 'Test-' from any host". You can do that by executing the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Jane --producer --topic Test- --resource-pattern-type prefixed
```

Note, --resource-pattern-type defaults to 'literal', which only affects resources with the exact same name or, in the case of the wildcard resource name '*', a resource with any name.

- Removing Acls

Removing acls is pretty much the same. The only difference is instead of --add option users will have to specify --remove option. To remove the acls added by the first example above we can execute the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic 
```

If you wan to remove the acl added to the prefixed resource pattern above we can execute the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Jane --producer --topic Test- --resource-pattern-type Prefixed
```

- List Acls

We can list acls for any resource by specifying the --list option with the resource. To list all acls on the literal resource pattern Test-topic, we can execute the CLI with following options:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic
```

However, this will only return the acls that have been added to this exact resource pattern. Other acls can exist that affect access to the topic, e.g. any acls on the topic wildcard '*', or any acls on prefixed resource patterns. Acls on the wildcard resource pattern can be queried explicitly:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic *
```

However, it is not necessarily possible to explicitly query for acls on prefixed resource patterns that match Test-topic as the name of such patterns may not be known. We can list all acls affecting Test-topic by using '--resource-pattern-type match', e.g.

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic --resource-pattern-type match
```

This will list acls on all matching literal, wildcard and prefixed resource patterns.

- Adding or removing a principal as producer or consumer

The most common use case for acl management are adding/removing a principal as producer or consumer so we added convenience options to handle these cases. In order to add User:Bob as a producer of Test-topic we can execute the following command:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --producer --topic Test-topic
```

Similarly to add Alice as a consumer of Test-topic with consumer group Group-1 we just have to pass --consumer option:

```bash
bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1 
```

Note that for consumer option we must also specify the consumer group. In order to remove a principal from producer or consumer role we just need to pass --remove option.

- Admin API based acl management

Users having Alter permission on ClusterResource can use Admin API for ACL management. kafka-acls.sh script supports AdminClient API to manage ACLs without interacting with zookeeper/authorizer directly. All the above examples can be executed by using `--bootstrap-server` option. For example:

```bash
bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --producer --topic Test-topic

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --list --topic Test-topic
```


```bash


# 创建 Kafka 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    jmxOptions: {}
    listeners:
      external:
        type: nodeport
        tls: false
        authentication:
          type: scram-sha-512
    authorization:
      type: simple
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}


---

# 创建 KafkaUser 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: my-user-allow
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      # Consumer ACLs
      - host: '*'
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: ClusterAction
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Describe
        resource:
          type: cluster
        type: allow
      # Producer ACLs
      - host: '*'
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: IdempotentWrite
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Create
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Alter
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow


apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: my-user-deny
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      # Consumer ACLs
      - host: '*'
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: ClusterAction
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Describe
        resource:
          type: cluster
        type: allow
      # Producer ACLs
      - host: 10.0.129.0
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: IdempotentWrite
        resource:
          type: cluster
        type: deny
      - host: 10.0.129.0
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: Create
        resource:
          type: cluster
        type: deny
      - host: 10.0.129.0
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: Alter
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny




---

# 创建 KafkaTopic 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824


kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --topic my-topic
kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --group my-group

kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --add --allow-principal User:my-user --allow-host * --deny-principal User:my-user --deny-host 10.0.129.0 --operation Read --topic my-topic

[root@mw-init test]# kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --topic my-topic
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=my-topic, patternType=LITERAL)`:
 	(principal=User:my-user, host=*, operation=READ, permissionType=ALLOW)
	(principal=User:my-user, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:my-user, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:my-user, host=*, operation=ALTER, permissionType=ALLOW)
	(principal=User:my-user, host=*, operation=DESCRIBE, permissionType=ALLOW)

[root@mw-init test]#
[root@mw-init test]# kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --group my-group
Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=my-group, patternType=LITERAL)`:
 	(principal=User:my-user, host=*, operation=READ, permissionType=ALLOW)
	(principal=User:my-user, host=*, operation=DESCRIBE, permissionType=ALLOW)

[root@mw-init test]#
[root@mw-init test]#
[root@mw-init test]#



    acls:
      # Consumer ACLs
      - host: '*'
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: ClusterAction
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Describe
        resource:
          type: cluster
        type: allow
      # Producer ACLs
      - host: 10.0.129.0
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: IdempotentWrite
        resource:
          type: cluster
        type: deny
      - host: 10.0.129.0
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: Create
        resource:
          type: cluster
        type: deny
      - host: 10.0.129.0
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny
      - host: 10.0.129.0
        operation: Alter
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: deny




$ kubectl -n kafka get secret my-user-allow -o jsonpath='{.data.password}' | base64 -d
JoRbZsERTsRF

$ kubectl -n kafka get secret my-user-deny -o jsonpath='{.data.password}' | base64 -d
fFFmBZG5ZctK





# 创建生产者和消费者客户端连接配置文件，注意用户密码
$ cat << EOF > client-allow.properties
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user-allow" \
    password="JoRbZsERTsRF";

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
EOF

$ cat << EOF > client-deny.properties
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="my-user-deny" \
    password="JDBzgCbpscVY";

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
EOF


# 生产者
$ kafka-console-producer.sh --bootstrap-server 10.0.128.237:30536 --topic my-topic --producer.config ./client-allow.properties
>hello1
>hello2
>

# 消费者
$ kafka-console-consumer.sh --bootstrap-server 10.0.128.237:31482 --topic my-topic --consumer.config ./client-allow.properties --from-beginning --group my-group
hello1
hello2




[root@mw-init test]# kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --topic my-topic
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=my-topic, patternType=LITERAL)`:
 	(principal=User:my-user, host=10.0.129.0, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=READ, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=ALL, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=DELETE, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=ALTER_CONFIGS, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=WRITE, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=CREATE, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=IDEMPOTENT_WRITE, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=DESCRIBE_CONFIGS, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=CLUSTER_ACTION, permissionType=ALLOW)
	(principal=User:my-user, host=10.0.129.0, operation=ALTER, permissionType=ALLOW)

[root@mw-init test]#
[root@mw-init test]#
[root@mw-init test]# kafka-acls.sh --authorizer-properties zookeeper.connect=10.0.128.237:30570 --list --group my-group
Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=my-group, patternType=LITERAL)`:
 	(principal=User:my-user, host=*, operation=READ, permissionType=ALLOW)

[root@mw-init test]#







# Consumer ACLs

      - host: '*'
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: ClusterAction
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Describe
        resource:
          type: cluster
        type: allow


# Producer ACLs




      - host: '*'
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: IdempotentWrite
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Create
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: '*'
        operation: Alter
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow


################################################


apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user-allow
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      - host: '*'
        operation: All
        resource:
          type: topic
          name: my-topic
          patternType: literal
        type: allow
      - host: '*'
        operation: All
        resource:
          type: group
          name: my-group
          patternType: literal
        type: allow
      - host: '*'
        operation: All
        resource:
          type: cluster
        type: allow
      - host: '*'
        operation: All
        resource:
          type: transactionalId
          name: '*'
          patternType: prefix
        type: allow



apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user-deny
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      - host: '*'
        operation: All
        resource:
          type: topic
          name: my-topic
          patternType: literal
        type: deny
      - host: '*'
        operation: All
        resource:
          type: group
          name: my-group
          patternType: literal
        type: deny
      - host: '*'
        operation: All
        resource:
          type: cluster
        type: deny
      - host: '*'
        operation: All
        resource:
          type: transactionalId
          name: '*'
          patternType: prefix
        type: deny





2020-12-24 14:47:13,989 INFO Principal = User:my-user-deny is Denied Operation = Write from host = 10.0.129.171 on resource = Topic:LITERAL:my-topic (kafka.authorizer.logger) [data-plane-kafka-request-handler-7]


2020-12-24 14:50:05,084 INFO Principal = User:my-user-deny is Denied Operation = Describe from host = 10.199.1.0 on resource = Topic:LITERAL:my-topic (kafka.authorizer.logger) [data-plane-kafka-request-handler-6]

2020-12-24 14:50:05,087 INFO Principal = User:my-user-deny is Denied Operation = Describe from host = 10.199.1.0 on resource = Group:LITERAL:my-group (kafka.authorizer.logger) [data-plane-kafka-request-handler-5]

2020-12-24 14:54:47,558 INFO Principal = User:my-user-deny is Denied Operation = Read from host = 10.0.129.171 on resource = Group:LITERAL:my-group (kafka.authorizer.logger) [data-plane-kafka-request-handler-7]


2020-12-24 14:56:26,181 INFO Principal = User:my-user-deny is Denied Operation = Read from host = 10.0.129.171 on resource = Group:LITERAL:my-group (kafka.authorizer.logger) [data-plane-kafka-request-handler-3]


2020-12-24 14:59:38,937 INFO Principal = User:my-user-deny is Denied Operation = Read from host = 10.0.129.171 on resource = Topic:LITERAL:my-topic (kafka.authorizer.logger) [data-plane-kafka-request-handler-1]
2020-12-24 14:59:38,967 INFO Principal = User:my-user-deny is Denied Operation = Read from host = 10.0.129.171 on resource = Topic:LITERAL:my-topic (kafka.authorizer.logger) [data-plane-kafka-request-handler-3]



apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  creationTimestamp: '2020-12-24T14:36:10Z'
  generation: 8
  labels:
    strimzi.io/cluster: my-cluster
  name: my-user-deny
  namespace: kafka
  resourceVersion: '137299793'
  selfLink: /apis/kafka.strimzi.io/v1beta1/namespaces/kafka/kafkausers/my-user-deny
  uid: 5c171666-b8de-48ea-802e-52b2c19e0836
spec:
  authentication:
    type: scram-sha-512
  authorization:
    acls:
      - host: 10.0.129.171
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: 10.0.129.171
        operation: Create
        resource:
          type: cluster
        type: allow
      - host: 10.0.129.171
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: 10.0.129.171
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: 10.199.1.0
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
      - host: 10.199.1.0
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: 10.0.129.171
        operation: Describe
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: 10.0.129.171
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
        type: allow
      - host: 10.0.129.171
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
        type: allow
    type: simple
status:
  conditions:
    - lastTransitionTime: '2020-12-24T15:01:26.921Z'
      status: 'True'
      type: Ready
  observedGeneration: 8
  secret: my-user-deny
  username: my-user-deny





```