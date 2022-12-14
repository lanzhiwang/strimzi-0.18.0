# KAFKA CONNECT

https://kafka.apache.org/25/documentation.html#connect

8. KAFKA CONNECT

  - 8.1 Overview

  - 8.2 User Guide

    - 8.2.1 Running Kafka Connect
    - 8.2.2 Configuring Connectors
    - 8.2.3 Transformations
    - 8.2.4 REST API

  - 8.3 Connector Development Guide

## 8.1 Overview

Kafka Connect is a tool for scalably and reliably streaming data between Apache Kafka and other systems. It makes it simple to quickly define connectors that move large collections of data into and out of Kafka. Kafka Connect can ingest entire databases or collect metrics from all your application servers into Kafka topics, making the data available for stream processing with low latency. An export job can deliver data from Kafka topics into secondary storage and query systems or into batch systems for offline analysis.  Kafka Connect 是一种用于在 Apache Kafka 和其他系统之间可扩展且可靠地流式传输数据的工具。 它使快速定义将大量数据移入和移出 Kafka 的连接器变得简单。 Kafka Connect 可以摄取整个数据库或将所有应用程序服务器的指标收集到 Kafka 主题中，使数据可用于低延迟的流处理。 导出作业可以将数据从 Kafka 主题传送到二级存储和查询系统或批处理系统进行离线分析。

Kafka Connect features include:  Kafka Connect 功能包括：

* **A common framework for Kafka connectors** - Kafka Connect standardizes integration of other data systems with Kafka, simplifying connector development, deployment, and management  Kafka 连接器的通用框架 - Kafka Connect 标准化了其他数据系统与 Kafka 的集成，简化了连接器的开发、部署和管理

* **Distributed and standalone modes** - scale up to a large, centrally managed service supporting an entire organization or scale down to development, testing, and small production deployments  分布式和独立模式 - 向上扩展为支持整个组织的大型集中管理服务，或向下扩展为开发、测试和小型生产部署

* **REST interface** - submit and manage connectors to your Kafka Connect cluster via an easy to use REST API  REST 接口 - 通过易于使用的 REST API 提交和管理到 Kafka Connect 集群的连接器

* **Automatic offset management** - with just a little information from connectors, Kafka Connect can manage the offset commit process automatically so connector developers do not need to worry about this error prone part of connector development  自动偏移管理 - 只需来自连接器的少量信息，Kafka Connect 就可以自动管理偏移提交过程，因此连接器开发人员无需担心连接器开发中这个容易出错的部分

* **Distributed and scalable by default** - Kafka Connect builds on the existing group management protocol. More workers can be added to scale up a Kafka Connect cluster.  默认情况下分布式和可扩展 - Kafka Connect 建立在现有的组管理协议上。可以添加更多工作人员来扩展 Kafka Connect 集群。

* **Streaming/batch integration** - leveraging Kafka's existing capabilities, Kafka Connect is an ideal solution for bridging streaming and batch data systems  流/批处理集成 - 利用 Kafka 的现有功能，Kafka Connect 是桥接流和批处理数据系统的理想解决方案

## 8.2 User Guide

The quickstart provides a brief example of how to run a standalone version of Kafka Connect. This section describes how to configure, run, and manage Kafka Connect in more detail.  快速入门提供了一个关于如何运行独立版本的 Kafka Connect 的简短示例。 本节更详细地介绍如何配置、运行和管理 Kafka Connect。

### 8.2.1 Running Kafka Connect

Kafka Connect currently supports two modes of execution: standalone (single process) and distributed.  Kafka Connect 目前支持两种执行模式：独立（单进程）和分布式。

In standalone mode all work is performed in a single process. This configuration is simpler to setup and get started with and may be useful in situations where only one worker makes sense (e.g. collecting log files), but it does not benefit from some of the features of Kafka Connect such as fault tolerance. You can start a standalone process with the following command:  在独立模式下，所有工作都在单个进程中执行。 此配置更易于设置和开始使用，并且在只有一个 worker 有意义的情况下可能很有用（例如收集日志文件），但它无法从 Kafka Connect 的某些功能（例如容错）中受益。 您可以使用以下命令启动独立进程：

```bash
$ bin/connect-standalone.sh config/connect-standalone.properties connector1.properties [connector2.properties ...]

$ cat /usr/local/kafka/config/connect-standalone.properties
bootstrap.servers=localhost:9092
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false
offset.storage.file.filename=/tmp/connect.offsets
offset.flush.interval.ms=10000
#plugin.path=

```

The first parameter is the configuration for the worker. This includes settings such as the Kafka connection parameters, serialization format, and how frequently to commit offsets. The provided example should work well with a local cluster running with the default configuration provided by `config/server.properties`. It will require tweaking to use with a different configuration or production deployment. All workers (both standalone and distributed) require a few configs:  第一个参数是worker的配置。 这包括诸如 Kafka 连接参数、序列化格式以及提交偏移的频率等设置。 提供的示例应该适用于使用 config/server.properties 提供的默认配置运行的本地集群。 它需要进行调整才能与不同的配置或生产部署一起使用。 所有工作人员（独立的和分布式的）都需要一些配置：

* `bootstrap.servers` - List of Kafka servers used to bootstrap connections to Kafka  bootstrap.servers - 用于引导到 Kafka 的连接的 Kafka 服务器列表

* `key.converter` - Converter class used to convert between Kafka Connect format and the serialized form that is written to Kafka. This controls the format of the keys in messages written to or read from Kafka, and since this is independent of connectors it allows any connector to work with any serialization format. Examples of common formats include JSON and Avro.  key.converter - 转换器类，用于在 Kafka Connect 格式和写入 Kafka 的序列化格式之间进行转换。 这控制了写入 Kafka 或从 Kafka 读取的消息中的密钥格式，并且由于它独立于连接器，因此它允许任何连接器使用任何序列化格式。 常见格式的示例包括 JSON 和 Avro。

* `value.converter` - Converter class used to convert between Kafka Connect format and the serialized form that is written to Kafka. This controls the format of the values in messages written to or read from Kafka, and since this is independent of connectors it allows any connector to work with any serialization format. Examples of common formats include JSON and Avro.  value.converter - 转换器类，用于在 Kafka Connect 格式和写入 Kafka 的序列化格式之间进行转换。 这控制了写入 Kafka 或从 Kafka 读取的消息中的值的格式，并且由于它独立于连接器，因此它允许任何连接器使用任何序列化格式。 常见格式的示例包括 JSON 和 Avro。

The important configuration options specific to standalone mode are:  特定于独立模式的重要配置选项是：

`offset.storage.file.filename` - File to store offset data in  用于存储偏移数据的文件

The parameters that are configured here are intended for producers and consumers used by Kafka Connect to access the configuration, offset and status topics. For configuration of the producers used by Kafka source tasks and the consumers used by Kafka sink tasks, the same parameters can be used but need to be prefixed with `producer.` and `consumer.` respectively. The only Kafka client parameter that is inherited without a prefix from the worker configuration is `bootstrap.servers`, which in most cases will be sufficient, since the same cluster is often used for all purposes. A notable exception is a secured cluster, which requires extra parameters to allow connections. These parameters will need to be set up to three times in the worker configuration, once for management access, once for Kafka sources and once for Kafka sinks.  此处配置的参数供Kafka Connect 使用的生产者和消费者访问配置、偏移和状态主题。 Kafka源任务使用的生产者和Kafka接收任务使用的消费者的配置，可以使用相同的参数，但需要以producer为前缀。 和消费者。 分别。 唯一从工作配置中没有前缀继承的 Kafka 客户端参数是 bootstrap.servers，这在大多数情况下就足够了，因为同一个集群通常用于所有目的。 一个值得注意的例外是安全集群，它需要额外的参数来允许连接。 这些参数最多需要在 worker 配置中设置三次，一次用于管理访问，一次用于 Kafka 源，一次用于 Kafka 接收器。

Starting with 2.3.0, client configuration overrides can be configured individually per connector by using the prefixes `producer.override`. and `consumer.override`. for Kafka sources or Kafka sinks respectively. These overrides are included with the rest of the connector's configuration properties.  从 2.3.0 开始，可以使用前缀 producer.override 为每个连接器单独配置客户端配置覆盖。 和消费者覆盖。 分别用于 Kafka 源或 Kafka 接收器。 这些覆盖包含在连接器的其余配置属性中。

The remaining parameters are connector configuration files. You may include as many as you want, but all will execute within the same process (on different threads).  其余参数是连接器配置文件。 您可以包含任意数量的内容，但所有内容都将在同一进程中（在不同线程上）执行。

Distributed mode handles automatic balancing of work, allows you to scale up (or down) dynamically, and offers fault tolerance both in the active tasks and for configuration and offset commit data. Execution is very similar to standalone mode:  分布式模式处理工作的自动平衡，允许您动态扩展（或缩减），并在活动任务以及配置和偏移提交数据中提供容错。 执行与独立模式非常相似：

```bash
$ bin/connect-distributed.sh config/connect-distributed.properties

$ cat /usr/local/kafka/config/connect-distributed.properties
bootstrap.servers=localhost:9092
group.id=connect-cluster
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=true
value.converter.schemas.enable=true

offset.storage.topic=connect-offsets
offset.storage.replication.factor=1
#offset.storage.partitions=25

config.storage.topic=connect-configs
config.storage.replication.factor=1

status.storage.topic=connect-status
status.storage.replication.factor=1
#status.storage.partitions=5

offset.flush.interval.ms=10000

#rest.host.name=
#rest.port=8083

#rest.advertised.host.name=
#rest.advertised.port=

#plugin.path=
```

The difference is in the class which is started and the configuration parameters which change how the Kafka Connect process decides where to store configurations, how to assign work, and where to store offsets and task statues. In the distributed mode, Kafka Connect stores the offsets, configs and task statuses in Kafka topics. It is recommended to manually create the topics for offset, configs and statuses in order to achieve the desired the number of partitions and replication factors. If the topics are not yet created when starting Kafka Connect, the topics will be auto created with default number of partitions and replication factor, which may not be best suited for its usage.  不同之处在于启动的类和更改 Kafka Connect 进程如何决定存储配置的位置、如何分配工作以及存储偏移量和任务状态的配置参数。 在分布式模式下，Kafka Connect 将偏移量、配置和任务状态存储在 Kafka 主题中。 建议手动创建偏移、配置和状态的主题，以达到所需的分区数和复制因子。 如果在启动 Kafka Connect 时尚未创建主题，则会使用默认分区数和复制因子自动创建主题，这可能不适合其使用。

In particular, the following configuration parameters, in addition to the common settings mentioned above, are critical to set before starting your cluster:  特别是，除了上面提到的常用设置之外，以下配置参数在启动集群之前设置至关重要：

* `group.id` (default `connect-cluster`) - unique name for the cluster, used in forming the Connect cluster group; note that this must not conflict with consumer group IDs  集群的唯一名称，用于形成 Connect 集群组； 请注意，这不能与消费者组 ID 冲突

* `config.storage.topic` (default `connect-configs`) - topic to use for storing connector and task configurations; note that this should be a single partition, highly replicated, compacted topic. You may need to manually create the topic to ensure the correct configuration as auto created topics may have multiple partitions or be automatically configured for deletion rather than compaction  用于存储连接器和任务配置的主题； 请注意，这应该是单个分区、高度复制、压缩的主题。 您可能需要手动创建主题以确保正确配置，因为自动创建的主题可能有多个分区或自动配置为删除而不是压缩

* `offset.storage.topic` (default `connect-offsets`) - topic to use for storing offsets; this topic should have many partitions, be replicated, and be configured for compaction  用于存储偏移量的主题； 这个主题应该有很多分区，被复制，并被配置为压缩

* `status.storage.topic` (default `connect-status`) - topic to use for storing statuses; this topic can have multiple partitions, and should be replicated and configured for compaction  用于存储状态的主题； 这个主题可以有多个分区，并且应该被复制和配置为压缩

Note that in distributed mode the connector configurations are not passed on the command line. Instead, use the REST API described below to create, modify, and destroy connectors.  请注意，在分布式模式下，连接器配置不会在命令行上传递。 相反，使用下面描述的 REST API 来创建、修改和销毁连接器。

### 8.2.2 Configuring Connectors

Connector configurations are simple key-value mappings. For standalone mode these are defined in a properties file and passed to the Connect process on the command line. In distributed mode, they will be included in the JSON payload for the request that creates (or modifies) the connector.  连接器配置是简单的键值映射。 对于独立模式，这些在属性文件中定义并通过命令行传递给 Connect 进程。 在分布式模式下，它们将包含在创建（或修改）连接器的请求的 JSON 负载中。

Most configurations are connector dependent, so they can't be outlined here. However, there are a few common options:  大多数配置都依赖于连接器，因此无法在此处进行概述。 但是，有一些常见的选项：

* `name` - Unique name for the connector. Attempting to register again with the same name will fail.  连接器的唯一名称。 尝试使用相同名称再次注册将失败。

* `connector.class` - The Java class for the connector  连接器的 Java 类

* `tasks.max` - The maximum number of tasks that should be created for this connector. The connector may create fewer tasks if it cannot achieve this level of parallelism.  应为此连接器创建的最大任务数。 如果连接器无法达到这种并行度，它可能会创建更少的任务。

* `key.converter` - (optional) Override the default key converter set by the worker.  （可选）覆盖工作人员设置的默认密钥转换器。

* `value.converter` - (optional) Override the default value converter set by the worker.  （可选）覆盖工作人员设置的默认值转换器。

The `connector.class` config supports several formats: the full name or alias of the class for this connector. If the connector is org.apache.kafka.connect.file.FileStreamSinkConnector, you can either specify this full name or use FileStreamSink or FileStreamSinkConnector to make the configuration a bit shorter.  connector.class 配置支持多种格式：此连接器的类的全名或别名。 如果连接器是 org.apache.kafka.connect.file.FileStreamSinkConnector，你可以指定这个全名，也可以使用 FileStreamSink 或 FileStreamSinkConnector 使配置更短一些。

Sink connectors also have a few additional options to control their input. Each sink connector must set one of the following:  Sink 连接器还有一些额外的选项来控制它们的输入。 每个接收器连接器必须设置以下之一：

* `topics` - A comma-separated list of topics to use as input for this connector  用作此连接器输入的主题的逗号分隔列表

* `topics.regex` - A Java regular expression of topics to use as input for this connector   用作此连接器输入的主题的 Java 正则表达式

For any other options, you should consult the documentation for the connector.  对于任何其他选项，您应该查阅连接器的文档。

```bash
$ cat connect-console-source.properties
name=local-console-source
connector.class=org.apache.kafka.connect.file.FileStreamSourceConnector
tasks.max=1
topic=connect-test

$ cat connect-console-sink.properties
name=local-console-sink
connector.class=org.apache.kafka.connect.file.FileStreamSinkConnector
tasks.max=1
topics=connect-test

##########################

$ cat connect-file-source.properties
name=local-file-source
connector.class=FileStreamSource
tasks.max=1
file=test.txt
topic=connect-test

$ cat connect-file-sink.properties
name=local-file-sink
connector.class=FileStreamSink
tasks.max=1
file=test.sink.txt
topics=connect-test

```

### 8.2.3 Transformations  转型

Connectors can be configured with transformations to make lightweight message-at-a-time modifications. They can be convenient for data massaging and event routing.  连接器可以配置转换以进行轻量级的消息一次修改。 它们可以方便地进行数据按摩和事件路由。

A transformation chain can be specified in the connector configuration.  可以在连接器配置中指定转换链。

* `transforms` - List of aliases for the transformation, specifying the order in which the transformations will be applied.  转换的别名列表，指定应用转换的顺序。

* `transforms.$alias.type` - Fully qualified class name for the transformation.  转换的完全限定类名。

* `transforms.$alias.$transformationSpecificConfig` Configuration properties for the transformation  转换的配置属性


For example, lets take the built-in file source connector and use a transformation to add a static field.  例如，让我们使用内置的文件源连接器并使用转换来添加静态字段。

Throughout the example we'll use schemaless JSON data format. To use schemaless format, we changed the following two lines in `connect-standalone.properties` from true to false:  在整个示例中，我们将使用无模式 JSON 数据格式。 为了使用无模式格式，我们将 connect-standalone.properties 中的以下两行从 true 更改为 false：

```bash
$ cat /usr/local/kafka/config/connect-standalone.properties
bootstrap.servers=localhost:9092
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false
offset.storage.file.filename=/tmp/connect.offsets
offset.flush.interval.ms=10000
#plugin.path=
```

The file source connector reads each line as a String. We will wrap each line in a Map and then add a second field to identify the origin of the event. To do this, we use two transformations:  文件源连接器将每一行作为字符串读取。 我们将把每一行包装在一个 Map 中，然后添加第二个字段来标识事件的来源。 为此，我们使用两种转换：

* `HoistField` to place the input line inside a Map  将输入线放置在地图内

* `InsertField` to add the static field. In this example we'll indicate that the record came from a file connector  添加静态字段。 在此示例中，我们将指示记录来自文件连接器

After adding the transformations, `connect-file-source.properties` file looks as following:

```
name=local-file-source
connector.class=FileStreamSource
tasks.max=1
file=test.txt
topic=connect-test

transforms=MakeMap, InsertSource
transforms.MakeMap.type=org.apache.kafka.connect.transforms.HoistField$Value
transforms.MakeMap.field=line
transforms.InsertSource.type=org.apache.kafka.connect.transforms.InsertField$Value
transforms.InsertSource.static.field=data_source
transforms.InsertSource.static.value=test-file-source
```

All the lines starting with `transforms` were added for the transformations. You can see the two transformations we created: "InsertSource" and "MakeMap" are aliases that we chose to give the transformations. The transformation types are based on the list of built-in transformations you can see below. Each transformation type has additional configuration: HoistField requires a configuration called "field", which is the name of the field in the map that will include the original String from the file. InsertField transformation lets us specify the field name and the value that we are adding.  为转换添加了所有以转换开头的行。 您可以看到我们创建的两个转换：“InsertSource”和“MakeMap”是我们为转换选择的别名。 转换类型基于您可以在下面看到的内置转换列表。 每个转换类型都有额外的配置：HoistField 需要一个名为“字段”的配置，它是映射中字段的名称，它将包含文件中的原始字符串。 InsertField 转换允许我们指定要添加的字段名称和值。 

When we ran the file source connector on my sample file without the transformations, and then read them using `kafka-console-consumer.sh`, the results were:  当我们在没有转换的示例文件上运行文件源连接器，然后使用 kafka-console-consumer.sh 读取它们时，结果是：

```
"foo"
"bar"
"hello world"
```

We then create a new file connector, this time after adding the transformations to the configuration file. This time, the results will be:  然后我们创建一个新的文件连接器，这次是在将转换添加到配置文件之后。 这一次，结果将是：

```
{"line":"foo","data_source":"test-file-source"}{"line":"bar","data_source":"test-file-source"}
{"line":"hello world","data_source":"test-file-source"}
```

You can see that the lines we've read are now part of a JSON map, and there is an extra field with the static value we specified. This is just one example of what you can do with transformations.  您可以看到我们读取的行现在是 JSON 映射的一部分，并且有一个带有我们指定的静态值的额外字段。 这只是您可以使用转换执行的操作的一个示例。

Several widely-applicable data and routing transformations are included with Kafka Connect:  Kafka Connect 包含几个广泛适用的数据和路由转换：

* **InsertField** - Add a field using either static data or record metadata  使用静态数据或记录元数据添加字段

* **ReplaceField** - Filter or rename fields  过滤或重命名字段

* **MaskField** - Replace field with valid null value for the type (0, empty string, etc)  用类型（0、空字符串等）的有效空值替换字段

* **ValueToKey**

* **HoistField** - Wrap the entire event as a single field inside a Struct or a Map  将整个事件包装为 Struct 或 Map 中的单个字段

* **ExtractField** - Extract a specific field from Struct and Map and include only this field in results  从 Struct 和 Map 中提取特定字段并在结果中仅包含该字段

* **SetSchemaMetadata** - modify the schema name or version  修改架构名称或版本

* **TimestampRouter** - Modify the topic of a record based on original topic and timestamp. Useful when using a sink that needs to write to different tables or indexes based on timestamps  根据原始主题和时间戳修改记录的主题。 在使用需要根据时间戳写入不同表或索引的接收器时很有用

* **RegexRouter** - modify the topic of a record based on original topic, replacement string and a regular expression  根据原始主题、替换字符串和正则表达式修改记录的主题

Details on how to configure each transformation are listed below:

##### org.apache.kafka.connect.transforms.InsertField


##### org.apache.kafka.connect.transforms.ReplaceField


##### org.apache.kafka.connect.transforms.MaskField


##### org.apache.kafka.connect.transforms.ValueToKey


##### org.apache.kafka.connect.transforms.HoistField


##### org.apache.kafka.connect.transforms.ExtractField


##### org.apache.kafka.connect.transforms.SetSchemaMetadata


##### org.apache.kafka.connect.transforms.TimestampRouter


##### org.apache.kafka.connect.transforms.RegexRouter


##### org.apache.kafka.connect.transforms.Flatten


##### org.apache.kafka.connect.transforms.Cast


##### org.apache.kafka.connect.transforms.TimestampConverter

### 8.2.4 REST API

Since Kafka Connect is intended to be run as a service, it also provides a REST API for managing connectors. The REST API server can be configured using the listeners configuration option. This field should contain a list of listeners in the following format: **protocol://host:port,protocol2://host2:port2**. Currently supported protocols are **http** and **https**. For example:  由于 Kafka Connect 旨在作为服务运行，因此它还提供了用于管理连接器的 REST API。 可以使用侦听器配置选项配置 REST API 服务器。 此字段应包含以下格式的侦听器列表：protocol://host:port,protocol2://host2:port2。 当前支持的协议是 http 和 https。 例如：

```
listeners=http://localhost:8080,https://localhost:8443
```

By default, if no `listeners` are specified, the REST server runs on port 8083 using the HTTP protocol. When using HTTPS, the configuration has to include the SSL configuration. By default, it will use the `ssl.*` settings. In case it is needed to use different configuration for the REST API than for connecting to Kafka brokers, the fields can be prefixed with `listeners.https`. When using the prefix, only the prefixed options will be used and the `ssl.*` options without the prefix will be ignored. Following fields can be used to configure HTTPS for the REST API:  默认情况下，如果未指定侦听器，则 REST 服务器使用 HTTP 协议在端口 8083 上运行。 使用 HTTPS 时，配置必须包含 SSL 配置。 默认情况下，它将使用 ssl.\* 设置。 如果需要为 REST API 使用不同的配置而不是连接到 Kafka 代理，这些字段可以以 listeners.https 为前缀。 使用前缀时，只会使用带前缀的选项，没有前缀的 ssl.\* 选项将被忽略。 以下字段可用于为 REST API 配置 HTTPS：

## 8.3 Connector Development Guide




