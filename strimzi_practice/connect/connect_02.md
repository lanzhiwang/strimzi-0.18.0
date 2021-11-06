# Deploying Debezium using the new KafkaConnector resource

https://strimzi.io/blog/2020/01/27/deploying-debezium-with-kafkaconnector-resource/

https://strimzi.io/blog/2020/05/07/camel-kafka-connectors/

https://strimzi.io/blog/2021/03/29/connector-build/



January 27, 2020 by Tom Bentley

For too long our Kafka Connect story hasn’t been quite as “Kubernetes-native” as it could have been. We had a `KafkaConnect` resource to configure a Kafka Connect *cluster* but you still had to use the Kafka Connect REST API to actually create a *connector* within it. While this wasn’t especially difficult using something like `curl`, it stood out because everything else could be done using `kubectl` and it meant that connectors didn’t fit into our Kubernetes-native vision. With the help of a contribution from the community, Strimzi now supports a `KafkaConnector` custom resource and the rest of this blog post is going to explain how to use it using [Debezium](https://debezium.io/) as an example. As if that wasn’t enough, there’s some awesome ASCII art to help explain how it all fits together. So read on to find out about this new Kubernetes-native way of managing connectors.  长期以来，我们的Kafka Connect故事还没有像“ Kubernetes-native”那样真实。我们有一个KafkaConnect资源配置卡夫卡连接集群，但你仍然不得不使用卡夫卡连接REST API实际上在其中创建的连接器。虽然这种使用像袅袅不是特别困难，它站了出来，因为一切可以利用kubectl来完成，它意味着连接器没有融入我们的Kubernetes本土视野。从社区作出贡献的帮助下，现在Strimzi支持KafkaConnector自定义资源，该博客文章的其余部分将介绍如何使用Debezium作为例子来使用它。如果这还不够，有一些真棒ASCII艺术，以帮助解释这一切是如何结合在一起的。因此，阅读，了解有关管理接口的新Kubernetes原生方式。

# Debezi-what?

If you haven’t heard of Debezium before, it is an open source project for applying the [Change Data Capture](https://en.wikipedia.org/wiki/Change_data_capture) (CDC) pattern to your applications using Kafka.  如果您以前从未听说过Debezium，那么它是一个开源项目，用于使用Kafka将更改数据捕获（CDC）模式应用于您的应用程序。

But what is CDC? You probably have several databases in your organization; silos full of business-critical data. While you can query those databases any time you want, the essence of your business revolves around how that data gets modified. Those modifications trigger, and are triggered by, real world business events (e.g. a phone call from a customer, or a successful payment or whatever) In order to reflect this, modern application architectures are frequently event-based. And so asking for the *current state* of some tables is not enough; what these architectures need is a stream of *events representing modifications* to those tables. That’s what CDC is: Capturing the changes to the state data as event data.  但是什么是CDC？ 您的组织中可能有多个数据库。 充满业务关键数据的孤岛。 尽管您可以随时查询那些数据库，但是业务的本质围绕着如何修改数据进行。 这些修改触发并由现实世界中的业务事件（例如，来自客户的电话，成功的付款或其他任何事情）触发。为了反映这一点，现代应用程序体系结构经常基于事件。 因此，仅要求某些表的当前状态是不够的。 这些体系结构需要的是一系列事件，这些事件表示对这些表的修改。 这就是CDC：将状态数据的更改捕获为事件数据。

Concretely, Debezium works with a number of common DBMSs (MySQL, MongoDB, PostgreSQL, Oracle, SQL Server and Cassandra) and runs as a source connector within a Kafka Connect cluster. How Debezium works on the database side depends which database it’s using. For example for MySQL it reads the commit log in order to know what transactions are happening, but for MongoDB it hooks into the native replication mechanism. In any case, the changes get represented by default as JSON events (other serializations are also possible) which are sent to Kafka.  具体来说，Debezium可与许多常见的DBMS（MySQL，MongoDB，PostgreSQL，Oracle，SQL Server和Cassandra）配合使用，并作为Kafka Connect集群中的源连接器运行。 Debezium在数据库方面的工作方式取决于所使用的数据库。 例如，对于MySQL，它读取提交日志以了解正在发生的事务，但是对于MongoDB，它会挂接到本机复制机制中。 无论如何，这些更改默认情况下都表示为发送到Kafka的JSON事件（也可以进行其他序列化）。

It should be apparent, then, that Debezium provides a route for getting events out of database applications (which otherwise might not expose any kind of event-based API) and make them available to Kafka applications.  显然，Debezium提供了一种从数据库应用程序中获取事件的途径（否则该事件可能不会公开任何基于事件的API）并使它们可用于Kafka应用程序。

So that’s what Debezium *is* and what it *does*. Its role in this blog post is just to be an example connector to use with the `KafkaConnector` which is new in Strimzi 0.16.  这就是Debezium及其作用。 它在此博客文章中的作用只是成为与Strimzi 0.16中新增的KafkaConnector一起使用的示例连接器。

Let’s get cracking with the walkthrough…

# Fire up MySQL

Let’s follow the steps from the [Debezium tutorial](https://debezium.io/documentation/reference/1.0/tutorial.html) for getting a demo MySQL server up and running.

First we fire up the database server in a Docker container:

```
docker run -it --rm --name mysql -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser \
  -e MYSQL_PASSWORD=mysqlpw debezium/example-mysql:1.0
```

Once we see the following we know the server is ready:

```
...
2020-01-24T12:20:18.183194Z 0 [Note] mysqld: ready for connections.
Version: '5.7.29-log'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
```

Then, in another terminal, we can run the command line client:

```
docker run -it --rm --name mysqlterm --link mysql --rm mysql:5.7 sh \
  -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" \
  -P"$MYSQL_PORT_3306_TCP_PORT" \
  -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```

At the `mysql>` prompt we can switch to the “inventory” database and show the tables in it:

```
mysql> use inventory;
mysql> show tables;
```

The output will look like this:

```
+---------------------+
| Tables_in_inventory |
+---------------------+
| addresses           |
| customers           |
| geom                |
| orders              |
| products            |
| products_on_hand    |
+---------------------+
6 rows in set (0.01 sec)
```

> Don’t worry, this isn’t the awesome ASCII art.

If you want, you can have a poke around this demo database, but when you’re done leave this MySQL client running in its own terminal window, so you can come back to it later.

# Create a Kafka cluster

Now we can follow some of the [Strimzi quickstart](https://strimzi.io/quickstarts/minikube/) to create a Kafka cluster running inside `minikube`.

First start minikube:

```
minikube start --memory=4096
```

When the command finishes you can create a namespace for the resources we’re going to create:

```
kubectl create namespace kafka
```

Then install the cluster operator and associated resources:

```
curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.16.1/strimzi-cluster-operator-0.16.1.yaml \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl apply -f - -n kafka 
```

And spin up a Kafka cluster, waiting until it’s ready:

```
kubectl -n kafka \
    apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.16.1/examples/kafka/kafka-persistent-single.yaml \
  && kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka
```

This can take a while, depending on the speed of your connection.

What we’ve got so far looks like this

```
┌────────────────────────────────┐         ┌────────────────────────────────┐
│ minikube, namespace: kafka     │         │ docker                         │
│                                │         │                                │
│ Kafka                          │         │ MySQL                          │
│  name: my-cluster              │         │                                │
│                                │         └────────────────────────────────┘
│                                │
│                                │
│                                │
└────────────────────────────────┘
```

> Don’t worry, the ASCII art gets a lot better than this!

What’s missing from this picture is Kafka Connect in the minikube box.

# Kafka Connect image

The next step is to [create a Strimzi Kafka Connect image](https://strimzi.io/docs/master/#creating-new-image-from-base-str) which includes the Debezium MySQL connector and its dependencies.

First download and extract the Debezium MySQL connector archive

```
curl https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.0.0.Final/debezium-connector-mysql-1.0.0.Final-plugin.tar.gz \
| tar xvz
```

Prepare a `Dockerfile` which adds those connector files to the Strimzi Kafka Connect image

```
cat <<EOF >Dockerfile
FROM strimzi/kafka:0.18.0-kafka-2.5.0
USER root:root
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/
USER 1001
EOF
```

Then build the image from that `Dockerfile` and push it to dockerhub.

```
# You can use your own dockerhub organization
export DOCKER_ORG=tjbentley
docker build . -t ${DOCKER_ORG}/connect-debezium
docker push ${DOCKER_ORG}/connect-debezium
```

# Secure the database credentials

To make this a bit more realistic we’re going to use Kafka’s `config.providers` mechanism to avoid having to pass secret information over Kafka Connect REST interface (which uses unencrypted HTTP). We’ll to use a Kubernetes `Secret` called `my-sql-credentials` to store the database credentials. This will be mounted as a secret volume within the connect pods. We can then configure the connector with the path to this file.  为了使这一点更加现实，我们将使用Kafka的config.providers机制，以避免必须通过Kafka Connect REST接口（使用未加密的HTTP）传递秘密信息。 我们将使用称为my-sql-credentials的Kubernetes Secret来存储数据库凭据。 这将作为秘密卷安装在连接盒内。 然后，我们可以使用该文件的路径配置连接器。

Let’s create the secret:

```
cat <<EOF > debezium-mysql-credentials.properties
mysql_username: debezium
mysql_password: dbz
EOF
kubectl -n kafka create secret generic my-sql-credentials \
  --from-file=debezium-mysql-credentials.properties
rm debezium-mysql-credentials.properties
```

# Create the Connect cluster

Now we can create a `KafkaConnect` cluster in Kubernetes:

```
cat <<EOF | kubectl -n kafka apply -f -
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
  annotations:
  # use-connector-resources configures this KafkaConnect
  # to use KafkaConnector resources to avoid
  # needing to call the Connect REST API directly
    strimzi.io/use-connector-resources: "true"
spec:
  image: ${DOCKER_ORG}/connect-debezium
  replicas: 1
  bootstrapServers: my-cluster-kafka-bootstrap:9093
  tls:
    trustedCertificates:
      - secretName: my-cluster-cluster-ca-cert
        certificate: ca.crt
  config:
    config.storage.replication.factor: 1
    offset.storage.replication.factor: 1
    status.storage.replication.factor: 1
    config.providers: file
    config.providers.file.class: org.apache.kafka.common.config.provider.FileConfigProvider
  externalConfiguration:
    volumes:
      - name: connector-config
        secret:
          secretName: my-sql-credentials

EOF
```

It’s worth pointing out a couple of things about the above resource:

- In the `metadata.annotations` the `strimzi.io/use-connector-resources: "true"` annotation tells the cluster operator that `KafkaConnector` resources will be used to configure connectors within this Kafka Connect cluster.
- The `spec.image` is the image we created with `docker`.
- In the `config` we’re using replication factor 1 because we created a single-broker Kafka cluster.
- In the `externalConfiguration` we’re referencing the secret we just created.

# Create the connector

The last piece is to create the `KafkaConnector` resource configured to connect to our “inventory” database in MySQL.

Here’s what the `KafkaConnector` resource looks like:

```
cat | kubectl -n kafka apply -f - << 'EOF'
apiVersion: "kafka.strimzi.io/v1alpha1"
kind: "KafkaConnector"
metadata:
  name: "inventory-connector"
  labels:
    strimzi.io/cluster: my-connect-cluster
spec:
  class: io.debezium.connector.mysql.MySqlConnector
  tasksMax: 1
  config:
    database.hostname: 192.168.99.1
    database.port: "3306"
    database.user: "${file:/opt/kafka/external-configuration/connector-config/debezium-mysql-credentials.properties:mysql_username}"
    database.password: "${file:/opt/kafka/external-configuration/connector-config/debezium-mysql-credentials.properties:mysql_password}"
    database.server.id: "184054"
    database.server.name: "dbserver1"
    database.whitelist: "inventory"
    database.history.kafka.bootstrap.servers: "my-cluster-kafka-bootstrap:9092"
    database.history.kafka.topic: "schema-changes.inventory"
    include.schema.changes: "true" 
EOF
```

In `metadata.labels`, `strimzi.io/cluster` names the `KafkaConnect` cluster which this connector will be created in.

The `spec.class` names the Debezium MySQL connector and `spec.tasksMax` must be 1 because that’s all this connector ever uses.

The `spec.config` object contains the rest of the connector configuration. The [Debezium documentation](https://debezium.io/documentation/reference/0.10/connectors/mysql.html#connector-properties) explains the available properties, but it’s worth calling out some specifically:

- I’m using `database.hostname: 192.168.99.1` as IP address for connecting to MySQL because I’m using `minikube` with the virtualbox VM driver If you’re using a different VM driver with `minikube` you might need a different IP address.
- The `database.port: "3306"` works because of the `-p 3306:3306` argument we used when we started up the MySQL server.
- The `${file:...}` used for the `database.user` and `database.password` is a placeholder which gets replaced with the referenced property from the given file in the secret we created.
- The `database.whitelist: "inventory"` basically tells Debezium to only watch the `inventory` database.
- The `database.history.kafka.topic: "schema-changes.inventory"` configured Debezium to use the `schema-changes.inventory` topic to store the database schema history.

A while after you’ve created this connector you can have a look at its `status`, using `kubectl get kctr inventory-connector -o yaml`:

```
#...
status:
  conditions:
  - lastTransitionTime: "2020-01-24T14:28:32.406Z"
    status: "True"
    type: Ready
  connectorStatus:
    connector:
      state: RUNNING
      worker_id: 172.17.0.9:8083
    name: inventory-connector
    tasks:
    - id: 0
      state: RUNNING
      worker_id: 172.17.0.9:8083
    type: source
  observedGeneration: 3
```

This tells us that the connector is running within the `KafkaConnect` cluster we created in the last step.

To summarise, we’ve now the complete picture with the connector talking to MySQL:

```
┌────────────────────────────────┐         ┌────────────────────────────────┐
│ minikube, namespace: kafka     │         │ docker                         │
│                                │         │                                │
│ Kafka                          │     ┏━━━┿━▶ MySQL                        │
│  name: my-cluster              │     ┃   │                                │
│                                │     ┃   └────────────────────────────────┘
│ KafkaConnect                   │     ┃
│  name: my-connect              │     ┃
│                                │     ┃
│ KafkaConnector                 │     ┃
│  name: inventory-connector ◀━━━┿━━━━━┛
│                                │
└────────────────────────────────┘
```

> OK, I admit it: I was lying about the ASCII art being awesome.

# Showtime!

If you list the topics, for example using `kubectl -n kafka exec my-cluster-kafka-0 -c kafka -i -t -- bin/kafka-topics.sh --bootstrap-server localhost:9092 --list` you should see:

```
__consumer_offsets
connect-cluster-configs
connect-cluster-offsets
connect-cluster-status
dbserver1
dbserver1.inventory.addresses
dbserver1.inventory.customers
dbserver1.inventory.geom
dbserver1.inventory.orders
dbserver1.inventory.products
dbserver1.inventory.products_on_hand
schema-changes.inventory
```

The `connect-cluster-*` topics are the usual internal Kafka Connect topics. Debezium has created a topic for the server itself (`dbserver1`), and one for each table within the `inventory` database.

Let’s start consuming from one of those change topics:

```
kubectl -n kafka exec my-cluster-kafka-0 -c kafka -i -t -- \
  bin/kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic dbserver1.inventory.customers 
```

This will block waiting for records/messages. To produce those messages we have to make some changes in the database. So back in the terminal window we left open with the MySQL command line client running we can make some changes to the data. First let’s see the existing customers:  这将阻止等待记录/消息。 为了产生这些消息，我们必须在数据库中进行一些更改。 因此，在终端窗口中，我们保持打开状态，并运行MySQL命令行客户端，我们可以对数据进行一些更改。 首先，让我们看看现有的客户：

```
mysql> SELECT * FROM customers;
+------+------------+-----------+-----------------------+
| id   | first_name | last_name | email                 |
+------+------------+-----------+-----------------------+
| 1001 | Sally      | Thomas    | sally.thomas@acme.com |
| 1002 | George     | Bailey    | gbailey@foobar.com    |
| 1003 | Edward     | Walker    | ed@walker.com         |
| 1004 | Anne       | Kretchmar | annek@noanswer.org    |
+------+------------+-----------+-----------------------+
4 rows in set (0.00 sec)
```

Now let’s change the `first_name` of the last customer:

```
mysql> UPDATE customers SET first_name='Anne Marie' WHERE id=1004;
```

Switching terminal window again we should be able to see this name change event in the `dbserver1.inventory.customers` topic:

```
{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"version"},{"type":"string","optional":false,"field":"connector"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"ts_ms"},{"type":"string","optional":true,"name":"io.debezium.data.Enum","version":1,"parameters":{"allowed":"true,last,false"},"default":"false","field":"snapshot"},{"type":"string","optional":false,"field":"db"},{"type":"string","optional":true,"field":"table"},{"type":"int64","optional":false,"field":"server_id"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"query"}],"optional":false,"name":"io.debezium.connector.mysql.Source","field":"source"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"}],"optional":false,"name":"dbserver1.inventory.customers.Envelope"},"payload":{"before":{"id":1004,"first_name":"Anne","last_name":"Kretchmar","email":"annek@noanswer.org"},"after":{"id":1004,"first_name":"Anne Mary","last_name":"Kretchmar","email":"annek@noanswer.org"},"source":{"version":"0.10.0.Final","connector":"mysql","name":"dbserver1","ts_ms":1574090237000,"snapshot":"false","db":"inventory","table":"customers","server_id":223344,"gtid":null,"file":"mysql-bin.000003","pos":4311,"row":0,"thread":3,"query":null},"op":"u","ts_ms":1574090237089}}
```

which is rather a lot of JSON, but if we reformat it (e.g. using copying, paste and `jq`) we see:

```
{
  "schema": {
    "type": "struct",
    "fields": [
      {
        "type": "struct",
        "fields": [
          {
            "type": "int32",
            "optional": false,
            "field": "id"
          },
          {
            "type": "string",
            "optional": false,
            "field": "first_name"
          },
          {
            "type": "string",
            "optional": false,
            "field": "last_name"
          },
          {
            "type": "string",
            "optional": false,
            "field": "email"
          }
        ],
        "optional": true,
        "name": "dbserver1.inventory.customers.Value",
        "field": "before"
      },
      {
        "type": "struct",
        "fields": [
          {
            "type": "int32",
            "optional": false,
            "field": "id"
          },
          {
            "type": "string",
            "optional": false,
            "field": "first_name"
          },
          {
            "type": "string",
            "optional": false,
            "field": "last_name"
          },
          {
            "type": "string",
            "optional": false,
            "field": "email"
          }
        ],
        "optional": true,
        "name": "dbserver1.inventory.customers.Value",
        "field": "after"
      },
      {
        "type": "struct",
        "fields": [
          {
            "type": "string",
            "optional": false,
            "field": "version"
          },
          {
            "type": "string",
            "optional": false,
            "field": "connector"
          },
          {
            "type": "string",
            "optional": false,
            "field": "name"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "ts_ms"
          },
          {
            "type": "string",
            "optional": true,
            "name": "io.debezium.data.Enum",
            "version": 1,
            "parameters": {
              "allowed": "true,last,false"
            },
            "default": "false",
            "field": "snapshot"
          },
          {
            "type": "string",
            "optional": false,
            "field": "db"
          },
          {
            "type": "string",
            "optional": true,
            "field": "table"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "server_id"
          },
          {
            "type": "string",
            "optional": true,
            "field": "gtid"
          },
          {
            "type": "string",
            "optional": false,
            "field": "file"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "pos"
          },
          {
            "type": "int32",
            "optional": false,
            "field": "row"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "thread"
          },
          {
            "type": "string",
            "optional": true,
            "field": "query"
          }
        ],
        "optional": false,
        "name": "io.debezium.connector.mysql.Source",
        "field": "source"
      },
      {
        "type": "string",
        "optional": false,
        "field": "op"
      },
      {
        "type": "int64",
        "optional": true,
        "field": "ts_ms"
      }
    ],
    "optional": false,
    "name": "dbserver1.inventory.customers.Envelope"
  },
  "payload": {
    "before": {
      "id": 1004,
      "first_name": "Anne",
      "last_name": "Kretchmar",
      "email": "annek@noanswer.org"
    },
    "after": {
      "id": 1004,
      "first_name": "Anne Mary",
      "last_name": "Kretchmar",
      "email": "annek@noanswer.org"
    },
    "source": {
      "version": "1.0.0.Final",
      "connector": "mysql",
      "name": "dbserver1",
      "ts_ms": 1574090237000,
      "snapshot": "false",
      "db": "inventory",
      "table": "customers",
      "server_id": 223344,
      "gtid": null,
      "file": "mysql-bin.000003",
      "pos": 4311,
      "row": 0,
      "thread": 3,
      "query": null
    },
    "op": "u",
    "ts_ms": 1574090237089
  }
}
```

The `schema` object is describing the schema of the actual event payload.

What’s more interesting for this post is the `payload` itself. Working backwards we have:

- `ts_ms` is the timestamp of when the change happened
- `op` tells us this was an `u`pdate (an insert would be `c` and a delete would be `d`)
- the `source` which tells us exactly which table of which database in which server got changed.
- `before` and `after` are pretty self-explanatory, describing the row before and after the update.

You can of course experiment with inserting and deleting rows in different tables (remember, there’s a topic for each table).

But what about that `dbserver1` topic which I glossed over? If we look at the messages in there (using `kubectl -n kafka exec my-cluster-kafka-0 -c kafka -i -t -- bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic dbserver1 --from-beginning`) we can see records representing the DDL which was used (when the docker image was created) to create the database. For example:

```
{
  "schema": {
    "type": "struct",
    "fields": [
      {
        "type": "struct",
        "fields": [
          {
            "type": "string",
            "optional": false,
            "field": "version"
          },
          {
            "type": "string",
            "optional": false,
            "field": "connector"
          },
          {
            "type": "string",
            "optional": false,
            "field": "name"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "ts_ms"
          },
          {
            "type": "string",
            "optional": true,
            "name": "io.debezium.data.Enum",
            "version": 1,
            "parameters": {
              "allowed": "true,last,false"
            },
            "default": "false",
            "field": "snapshot"
          },
          {
            "type": "string",
            "optional": false,
            "field": "db"
          },
          {
            "type": "string",
            "optional": true,
            "field": "table"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "server_id"
          },
          {
            "type": "string",
            "optional": true,
            "field": "gtid"
          },
          {
            "type": "string",
            "optional": false,
            "field": "file"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "pos"
          },
          {
            "type": "int32",
            "optional": false,
            "field": "row"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "thread"
          },
          {
            "type": "string",
            "optional": true,
            "field": "query"
          }
        ],
        "optional": false,
        "name": "io.debezium.connector.mysql.Source",
        "field": "source"
      },
      {
        "type": "string",
        "optional": false,
        "field": "databaseName"
      },
      {
        "type": "string",
        "optional": false,
        "field": "ddl"
      }
    ],
    "optional": false,
    "name": "io.debezium.connector.mysql.SchemaChangeValue"
  },
  "payload": {
    "source": {
      "version": "1.0.0.Final",
      "connector": "mysql",
      "name": "dbserver1",
      "ts_ms": 0,
      "snapshot": "true",
      "db": "inventory",
      "table": "products_on_hand",
      "server_id": 0,
      "gtid": null,
      "file": "mysql-bin.000003",
      "pos": 2324,
      "row": 0,
      "thread": null,
      "query": null
    },
    "databaseName": "inventory",
    "ddl": "CREATE TABLE `products_on_hand` (\n  `product_id` int(11) NOT NULL,\n  `quantity` int(11) NOT NULL,\n  PRIMARY KEY (`product_id`),\n  CONSTRAINT `products_on_hand_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)\n) ENGINE=InnoDB DEFAULT CHARSET=latin1"
  }
}
```

Again we have a `schema` and `payload`. This time the `payload` has:

- `source`, like before,
- `databaseName`, which tells us which database this record is for
- the `ddl` string tells us how the `products_on_hand` table was created.

# Conclusion

In this post we’ve learned that Strimzi now supports a `KafkaConnector` custom resource which you can use to define connectors. We’ve demonstrated this generic functionality using the Debezium connector as an example. By creating a `KafkaConnector` resource, linked to our `KafkaConnect` cluster via the `strimzi.io/cluster` label, we were able to observe changes made in a MySQL database as records in a Kafka topic. And finally, we’ve been left with a feeling of disappointment about the unfulfilled promise of awesome ASCII art.


# 实践

```bash
$ docker run -it --rm --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser -e MYSQL_PASSWORD=mysqlpw -d debezium/example-mysql:1.0
6f9564f52be71f459ea7e4aa642f3a5f12da8a42f0c7e3dc9b4107cd17f0459e

$ docker exec -ti mysql bash
root@c51551ea0117:/# env
MYSQL_MAJOR=5.7
HOSTNAME=c51551ea0117
PWD=/
MYSQL_ROOT_PASSWORD=debezium
MYSQL_PASSWORD=mysqlpw
MYSQL_USER=mysqluser
HOME=/root
MYSQL_VERSION=5.7.30-1debian10
GOSU_VERSION=1.12
TERM=xterm
SHLVL=1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
_=/usr/bin/env
root@c51551ea0117:/#

$ mysql -h 10.0.129.171 -P 3306 -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.30-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| inventory          |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use inventory;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+---------------------+
| Tables_in_inventory |
+---------------------+
| addresses           |
| customers           |
| geom                |
| orders              |
| products            |
| products_on_hand    |
+---------------------+
6 rows in set (0.00 sec)

mysql>




cat <<EOF >Dockerfile
FROM strimzi/kafka:0.18.0-kafka-2.5.0
USER root:root
RUN mkdir -p /opt/kafka/plugins/debezium
COPY ./debezium-connector-mysql/ /opt/kafka/plugins/debezium/
USER 1001
EOF
docker build . -t 10.0.129.0:60080/kafka/connect-debezium
docker push 10.0.129.0:60080/kafka/connect-debezium



cat <<EOF > debezium-mysql-credentials.properties
mysql_username: root
mysql_password: debezium
EOF

kubectl -n kafka create secret generic my-sql-credentials --from-file=debezium-mysql-credentials.properties


apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    jmxOptions:
      '-Xms': 8192m
      '-Xmx': 8192m
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1Gi
        cpu: '1'
    listeners:
      plain: {}
      tls: {}
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1000Mi
        cpu: '1'
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}


cat <<EOF | kubectl -n kafka apply -f -
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
  annotations:
    strimzi.io/use-connector-resources: "true"
spec:
  version: 2.5.0
  image: 10.0.129.0:60080/kafka/connect-debezium
  replicas: 1
  bootstrapServers: my-cluster-kafka-bootstrap:9092
  config:
    group.id: my-group
    offset.storage.topic: connect-cluster-offsets
    config.storage.topic: connect-cluster-configs
    status.storage.topic: connect-cluster-status
    config.storage.replication.factor: 1
    offset.storage.replication.factor: 1
    status.storage.replication.factor: 1
    config.providers: file
    config.providers.file.class: org.apache.kafka.common.config.provider.FileConfigProvider
  externalConfiguration:
    volumes:
      - name: connector-config
        secret:
          secretName: my-sql-credentials

EOF


[root@mw-m1 huzhi]# kubectl -n kafka run kafka-test -ti --image=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0-v3.4.0 --rm=true --restart=Never bash
If you don't see a command prompt, try pressing enter.
[kafka@kafka-test kafka]$
[kafka@kafka-test kafka]$
[kafka@kafka-test kafka]$ curl -s -X GET -H "Content-Type: application/json" http://my-connect-cluster-connect-api:8083/connector-plugins
[{"class":"io.debezium.connector.mysql.MySqlConnector","type":"source","version":"1.0.0.Final"},{"class":"org.apache.kafka.connect.file.FileStreamSinkConnector","type":"sink","version":"2.5.0"},{"class":"org.apache.kafka.connect.file.FileStreamSourceConnector","type":"source","version":"2.5.0"},{"class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector","type":"source","version":"1"},{"class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector","type":"source","version":"1"},{"class":"org.apache.kafka.connect.mirror.MirrorSourceConnector","type":"source","version":"1"}]
[kafka@kafka-test kafka]$




cat | kubectl -n kafka apply -f - << 'EOF'
apiVersion: "kafka.strimzi.io/v1alpha1"
kind: "KafkaConnector"
metadata:
  name: "inventory-connector"
  labels:
    strimzi.io/cluster: my-connect-cluster
spec:
  class: io.debezium.connector.mysql.MySqlConnector
  tasksMax: 1
  config:
    database.hostname: 10.0.129.171
    database.port: "3306"
    database.user: "${file:/opt/kafka/external-configuration/connector-config/debezium-mysql-credentials.properties:mysql_username}"
    database.password: "${file:/opt/kafka/external-configuration/connector-config/debezium-mysql-credentials.properties:mysql_password}"
    database.whitelist: "inventory"
    database.history.kafka.topic: "schema-changes.inventory"
    database.history.kafka.bootstrap.servers: "my-cluster-kafka-bootstrap:9092"
    include.schema.changes: "true"
    database.server.id: "184054"
    database.server.name: "dbserver1"
EOF



$ kubectl -n kafka run kafka-test -ti --image=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0-v3.4.0 --rm=true --restart=Never bash
If you don't see a command prompt, try pressing enter.
[kafka@kafka-test kafka]$
[kafka@kafka-test kafka]$ /opt/kafka/bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
__consumer_offsets
connect-cluster-configs
connect-cluster-offsets
connect-cluster-status
dbserver1
dbserver1.inventory.addresses
dbserver1.inventory.customers
dbserver1.inventory.geom
dbserver1.inventory.orders
dbserver1.inventory.products
dbserver1.inventory.products_on_hand
schema-changes.inventory
[kafka@kafka-test kafka]$

mysql> show tables;
+---------------------+
| Tables_in_inventory |
+---------------------+
| addresses           |
| customers           |
| geom                |
| orders              |
| products            |
| products_on_hand    |
+---------------------+
6 rows in set (0.00 sec)

mysql>


[kafka@kafka-test kafka]$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic dbserver1.inventory.customers
{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"version"},{"type":"string","optional":false,"field":"connector"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"ts_ms"},{"type":"string","optional":true,"name":"io.debezium.data.Enum","version":1,"parameters":{"allowed":"true,last,false"},"default":"false","field":"snapshot"},{"type":"string","optional":false,"field":"db"},{"type":"string","optional":true,"field":"table"},{"type":"int64","optional":false,"field":"server_id"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"query"}],"optional":false,"name":"io.debezium.connector.mysql.Source","field":"source"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"}],"optional":false,"name":"dbserver1.inventory.customers.Envelope"},"payload":{"before":{"id":1004,"first_name":"Anne","last_name":"Kretchmar","email":"annek@noanswer.org"},"after":{"id":1004,"first_name":"Anne Marie","last_name":"Kretchmar","email":"annek@noanswer.org"},"source":{"version":"1.0.0.Final","connector":"mysql","name":"dbserver1","ts_ms":1617186710000,"snapshot":"false","db":"inventory","table":"customers","server_id":223344,"gtid":null,"file":"mysql-bin.000003","pos":364,"row":0,"thread":7,"query":null},"op":"u","ts_ms":1617186710324}}


```

