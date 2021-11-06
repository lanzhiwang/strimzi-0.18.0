# kafka 性能测试

## 准备工作

1. 在 k8s 上部署 strimzi operator
2. 创建 kafka 集群，kafka 版本：2.5.0
3. 定义相关 topic，使用脚本操作 topic 的相关示例见附录
4. 使用 `kafka-producer-perf-test.sh` 脚本做生产者基础测试，脚本使用的说明见附录
5. 使用 `kafka-consumer-perf-test.sh` 脚本做消费者测试，脚本使用的说明见附录
6. 使用 `kafka-run-class.sh` 脚本做生产者高级测试，脚本使用的说明见附录

## 生产者测试

生产者测试，分别从分区数、副本数、Broker数、同步与异步模式、批处理大小、消息长度大小、数据压缩等维度来进行。

| kafka 节点数 | 分区数 | 副本数 | 同步与异步模式 | 批处理大小 | 消息长度大小 | 数据是否压缩 | 每秒发送消息数 | 消息平均大小 |
| ------------ | ------ | ------ | -------------- | ---------- | ------------ | ------------ | -------------- | ------------ |
|              |        |        |                |            |              |              |                |              |

note:
> 目前 kafka 自带的生产者压力测试脚本不支持多线程生产数据，所以如果需要测试多线程对性能的影响还需要使用其他工具。


### 1、生产者测试-分区数

向拥有不同分区的主题发送数据，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf6 --partitions 6 --replication-factor 1

$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf12 --partitions 12 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf6 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf12 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

```


### 2、生产者测试-副本数

向拥有不同副本数的主题发送数据，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_partitions3_replication3 --partitions 3 --replication-factor 3

$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_partitions3_replication5 --partitions 3 --replication-factor 5

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_partitions3_replication3 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_partitions3_replication5 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

```


### 3、生产者测试-Broker 数量

通过增加 Broker 节点数量来查看性能变化。

测试脚本如下：

```bash
# 分别部署拥有 3 个和 4 个 broker 的集群

# 在不同的集群中进行如下操作

# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

```


### 4、生产者测试-同步与异步模式

分别使用同步和异步模式发送相同数量的消息记录，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

## todo
# 同步生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link} sync=true

# 异步生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

```


### 5、生产者测试-批处理大小

使用异步模式发送相同数量的消息数据，改变批处理量的大小，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link} batch.size=200

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link} batch.size=400

```


### 6、生产者测试-消息长度的大小

改变消息的长度大小，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 2000 --producer-props bootstrap.servers=${kafka_link}

```


## 消费者测试

消费者测试，可以从线程数、分区数、副本数等维度来进行测试。

| kafka 节点数 | 线程数 | 分区数 | 副本数 | 每秒接收消息数 | 消息平均大小 |
| ------------ | ------ | ------ | ------ | -------------- | ------------ |
|              |        |        |        |                |              |

### 1、消费者测试-线程数

创建一个拥有 6 个分区、1 个副本的Topic，用不同的线程数读取相同的数据量，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

# 消费数据
$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf --timeout 100000 --threads 2

$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf --timeout 100000 --threads 3

$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf --timeout 100000 --threads 4

```


### 2、消费者测试-分区数

新建一个 Topic，改变它的分区数，读取相同数量的消息记录，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf6 --partitions 6 --replication-factor 1

$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf12 --partitions 12 --replication-factor 1

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf6 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf12 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

# 消费数据
$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf6 --timeout 100000

$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf12 --timeout 100000

```


### 3、消费者测试-副本数

新建Topic，改变Topic的副本数，读取相同数量的消息记录，查看性能变化。

测试脚本如下：

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_partitions3_replication3 --partitions 3 --replication-factor 3

$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_partitions3_replication5 --partitions 3 --replication-factor 5

# 生产数据
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_partitions3_replication3 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_partitions3_replication5 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}

# 消费数据
$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_partitions3_replication3 --timeout 100000

$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_partitions3_replication5 --timeout 100000

```

## 附录

### topic 相关操作 

```bash
# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# 创建主题
$ ./kafka-topics.sh --create --bootstrap-server ${kafka_link} --topic test_producer_perf --partitions 6 --replication-factor 1

# 删除主题
$ ./kafka-topics.sh --delete --bootstrap-server ${kafka_link} --topic test_producer_perf

# 主题列表
$ ./kafka-topics.sh --list --bootstrap-server ${kafka_link}

# 主题详细信息
$ ./kafka-topics.sh --describe --bootstrap-server ${kafka_link}

```

### kafka-producer-perf-test.sh 脚本参数和基本示例

```bash
$ ./kafka-producer-perf-test.sh
usage: producer-performance [-h] --topic TOPIC --num-records NUM-RECORDS [--payload-delimiter PAYLOAD-DELIMITER] --throughput THROUGHPUT [--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]] [--producer.config CONFIG-FILE] [--print-metrics] [--transactional-id TRANSACTIONAL-ID] [--transaction-duration-ms TRANSACTION-DURATION] (--record-size RECORD-SIZE | -payload-file PAYLOAD-FILE)

This tool is used to verify the producer performance.

optional arguments:

-h, --help
show this help message and exit

--topic TOPIC
produce messages to this topic

--num-records NUM-RECORDS
number of messages to produce  # 发送的消息数量

--payload-delimiter PAYLOAD-DELIMITER
provides delimiter to be used when --payload-file is provided. Defaults to new line. Note that this parameter will be ignored if --payload-file is not provided. (default: \n)

--throughput THROUGHPUT
throttle maximum message throughput to *approximately* THROUGHPUT messages/sec. Set this to -1 to disable throttling.  # 每秒的吞吐量，即每秒发送多少条消息, -1 表示没有限制

--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]
kafka producer related configuration properties like bootstrap.servers,client.id etc. These configs take precedence over those passed via --producer.config.  # kafka 生产者相关的配置属性，如 bootstrap.servers、client.id 等。这些配置优先于通过 --producer.config 传递的那些。

--producer.config CONFIG-FILE
producer config properties file.

--print-metrics
print out metrics at the end of the test. (default: false)

--transactional-id TRANSACTIONAL-ID
The transactionalId to use if transaction-duration-ms is > 0. Useful when testing the performance of concurrent transactions. (default: performance-producer-default-transactional-id)

--transaction-duration-ms TRANSACTION-DURATION
The max age of each transaction. The commitTransaction will be called after this time has elapsed. Transactions are only enabled if this value is positive. (default: 0)  # 多长时间后调用 commitTransaction
# 每笔交易的最大年龄。 在这段时间过后，将调用 commitTransaction。 仅当此值为正时才启用事务。 （默认值：0）

either --record-size or --payload-file must be specified but not both.

--record-size RECORD-SIZE
message size in bytes. Note that you must provide exactly one of --record-size or --payload-file.  # 单条信息大小，字节单位

--payload-file PAYLOAD-FILE
file to read the message payloads from. This works only for UTF-8 encoded text files.  Payloads  will  be  read from this file and a payload will be randomly selected when sending messages. Note that you must provide exactly one of --record-size or --payload-file.


usage:
producer-performance
[-h]
--topic TOPIC
--num-records NUM-RECORDS
[--payload-delimiter PAYLOAD-DELIMITER]
--throughput THROUGHPUT
[--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]]
[--producer.config CONFIG-FILE]
[--print-metrics]
[--transactional-id TRANSACTIONAL-ID]
[--transaction-duration-ms TRANSACTION-DURATION]
(--record-size RECORD-SIZE | -payload-file PAYLOAD-FILE)


# kafka-producer-perf-test 基本使用方法
$ ./kafka-producer-perf-test.sh --num-records 5000000 --topic test_producer_perf --throughput -1 --record-size 1000 --producer-props bootstrap.servers=${kafka_link}
43297 records sent, 8514.7 records/sec (8.12 MB/sec), 1700.5 ms avg latency, 2988.0 ms max latency.
...
178218 records sent, 35643.6 records/sec (33.99 MB/sec), 939.7 ms avg latency, 3401.0 ms max latency.
5000000 records sent, 31345.014575 records/sec (29.89 MB/sec), 1026.65 ms avg latency, 5803.00 ms max latency, 103 ms 50th, 3079 ms 95th, 5017 ms 99th, 5485 ms 99.9th.

结果说明：
5000000 records sent  # 发送的消息总数
31345.014575 records/sec (29.89 MB/sec)  # 平均每秒发送的消息数，平均每秒发送的消息大小（平均吞吐量）
1026.65 ms avg latency  # 平均延时
5803.00 ms max latency  # 最大延时
103 ms 50th, 3079 ms 95th, 5017 ms 99th, 5485 ms 99.9th.  # 不同延时时间占据的数据量百分比，也就是 50% 的消息发送需要 103ms，95% 的消息发送需要 3079 ms，99% 的消息发送需要 5017 ms

本次测试占用的带宽是：240MB/sec (8 * 29.89MB/sec)

```

### kafka-consumer-perf-test.sh 脚本参数和基本示例

```bash
$ ./kafka-consumer-perf-test.sh --help
This tool helps in performance test for the full zookeeper consumer
Option                                   Description
------                                   -----------

--bootstrap-server <String: server to connect to>
REQUIRED unless --broker-list (deprecated) is specified. The server(s) to connect to.

--broker-list <String: broker-list>
DEPRECATED, use --bootstrap-server instead; ignored if --bootstrap-server is specified.  The broker list string in the form HOST1:PORT1,HOST2:PORT2.

--consumer.config <String: config file>
Consumer config properties file.

--date-format <String: date format>
The date format to use for formatting the time field. See java.text.SimpleDateFormat for options. (default: yyyy-MM-dd HH:mm:ss:SSS)

--fetch-size <Integer: size>
The amount of data to fetch in a single request. (default: 1048576)  # 每次请求的消息数量，单位：字节

--from-latest
If the consumer does not already have an established offset to consume from, start with the latest message present in the log rather than the earliest message.  # 如果消费者还没有建立偏移量，则从最新的消息开始消费，而不是最早的消息

--group <String: gid>
The group id to consume on. (default:perf-consumer-3655)

--help
Print usage information.

--hide-header
If set, skips printing the header for the stats

--messages <Long: count>
REQUIRED: The number of messages to send or consume  # 请求消息的总数

--num-fetch-threads <Integer: count>
Number of fetcher threads. (default: 1)  # 请求消息的线程数

--print-metrics
Print out the metrics.

--reporting-interval <Integer: interval_ms>
Interval in milliseconds at which to print progress info. (default: 5000)

--show-detailed-stats
If set, stats are reported for each reporting interval as configured by reporting-interval

--socket-buffer-size <Integer: size>
The size of the tcp RECV size.(default: 2097152)

--threads <Integer: count> 
Number of processing threads. (default: 10)  # 处理消息的线程数

--timeout [Long: milliseconds]
The maximum allowed time in milliseconds between returned records. (default: 10000)  # 允许返回数据的最大超时时间

--topic <String: topic>
REQUIRED: The topic to consume from.

--version
Display Kafka version.

# 定义连接参数
zookeeper_link="localhost:2181"
kafka_link="localhost:9092"

# kafka-consumer-perf-test.sh 基本使用方法
$ ./kafka-consumer-perf-test.sh --bootstrap-server ${kafka_link} --messages 5000000 --topic test_producer_perf --timeout 100000
start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec
2020-10-12 07:10:18:102, 2020-10-12 07:11:06:914, 4768.7950, 97.6972, 5000444, 102442.9239, 1602486627696, -1602486578884, -0.0000, -0.0031

结果说明：
start.time
end.time
data.consumed.in.MB  # shows the size of all messages consumed.
MB.sec  # indicates how much data transferred in MB per sec(Throughput on size).
data.consumed.in.nMsg  # show the count of total message which were consumed during this test.
nMsg.sec  # shows how many messages consumed in a sec(Throughput on count of messages).
rebalance.time.ms
fetch.size  # shows the amount of data to fetch in a single request.
fetch.time.ms
fetch.MB.sec
fetch.nMsg.sec

```


### kafka-run-class.sh 相关参数

```bash
$ ./kafka-run-class.sh
USAGE: ./kafka-run-class.sh [-daemon] [-name servicename] [-loggc] classname [opts]

# classname
kafka.tools.ConsoleProducer
kafka.tools.ConsoleConsumer
org.apache.kafka.tools.ProducerPerformance

$ ./kafka-run-class.sh kafka.tools.ConsoleProducer --help
Option                                   Description
------                                   -----------
--batch-size <Integer: size>             Number of messages to send in a single
                                           batch if they are not being sent
                                           synchronously. (default: 200)
--bootstrap-server <String: server to    REQUIRED unless --broker-list
  connect to>                              (deprecated) is specified. The server
                                           (s) to connect to. The broker list
                                           string in the form HOST1:PORT1,HOST2:
                                           PORT2.
--broker-list <String: broker-list>      DEPRECATED, use --bootstrap-server
                                           instead; ignored if --bootstrap-
                                           server is specified.  The broker
                                           list string in the form HOST1:PORT1,
                                           HOST2:PORT2.
--compression-codec [String:             The compression codec: either 'none',
  compression-codec]                       'gzip', 'snappy', 'lz4', or 'zstd'.
                                           If specified without value, then it
                                           defaults to 'gzip'
--help                                   Print usage information.
--line-reader <String: reader_class>     The class name of the class to use for
                                           reading lines from standard in. By
                                           default each line is read as a
                                           separate message. (default: kafka.
                                           tools.
                                           ConsoleProducer$LineMessageReader)
--max-block-ms <Long: max block on       The max time that the producer will
  send>                                    block for during a send request
                                           (default: 60000)
--max-memory-bytes <Long: total memory   The total memory used by the producer
  in bytes>                                to buffer records waiting to be sent
                                           to the server. (default: 33554432)
--max-partition-memory-bytes <Long:      The buffer size allocated for a
  memory in bytes per partition>           partition. When records are received
                                           which are smaller than this size the
                                           producer will attempt to
                                           optimistically group them together
                                           until this size is reached.
                                           (default: 16384)
--message-send-max-retries <Integer>     Brokers can fail receiving the message
                                           for multiple reasons, and being
                                           unavailable transiently is just one
                                           of them. This property specifies the
                                           number of retires before the
                                           producer give up and drop this
                                           message. (default: 3)
--metadata-expiry-ms <Long: metadata     The period of time in milliseconds
  expiration interval>                     after which we force a refresh of
                                           metadata even if we haven't seen any
                                           leadership changes. (default: 300000)
--producer-property <String:             A mechanism to pass user-defined
  producer_prop>                           properties in the form key=value to
                                           the producer.
--producer.config <String: config file>  Producer config properties file. Note
                                           that [producer-property] takes
                                           precedence over this config.
--property <String: prop>                A mechanism to pass user-defined
                                           properties in the form key=value to
                                           the message reader. This allows
                                           custom configuration for a user-
                                           defined message reader. Default
                                           properties include:
                                         	parse.key=true|false
                                         	key.separator=<key.separator>
                                         	ignore.error=true|false
--request-required-acks <String:         The required acks of the producer
  request required acks>                   requests (default: 1)
--request-timeout-ms <Integer: request   The ack timeout of the producer
  timeout ms>                              requests. Value must be non-negative
                                           and non-zero (default: 1500)
--retry-backoff-ms <Integer>             Before each retry, the producer
                                           refreshes the metadata of relevant
                                           topics. Since leader election takes
                                           a bit of time, this property
                                           specifies the amount of time that
                                           the producer waits before refreshing
                                           the metadata. (default: 100)
--socket-buffer-size <Integer: size>     The size of the tcp RECV size.
                                           (default: 102400)
--sync                                   If set message send requests to the
                                           brokers are synchronously, one at a
                                           time as they arrive.
--timeout <Integer: timeout_ms>          If set and the producer is running in
                                           asynchronous mode, this gives the
                                           maximum amount of time a message
                                           will queue awaiting sufficient batch
                                           size. The value is given in ms.
                                           (default: 1000)
--topic <String: topic>                  REQUIRED: The topic id to produce
                                           messages to.
--version                                Display Kafka version.


$ ./kafka-run-class.sh kafka.tools.ConsoleConsumer ---help
Option                                   Description
------                                   -----------
--bootstrap-server <String: server to    REQUIRED: The server(s) to connect to.
  connect to>
--consumer-property <String:             A mechanism to pass user-defined
  consumer_prop>                           properties in the form key=value to
                                           the consumer.
--consumer.config <String: config file>  Consumer config properties file. Note
                                           that [consumer-property] takes
                                           precedence over this config.
--enable-systest-events                  Log lifecycle events of the consumer
                                           in addition to logging consumed
                                           messages. (This is specific for
                                           system tests.)
--formatter <String: class>              The name of a class to use for
                                           formatting kafka messages for
                                           display. (default: kafka.tools.
                                           DefaultMessageFormatter)
--from-beginning                         If the consumer does not already have
                                           an established offset to consume
                                           from, start with the earliest
                                           message present in the log rather
                                           than the latest message.
--group <String: consumer group id>      The consumer group id of the consumer.
--help                                   Print usage information.
--isolation-level <String>               Set to read_committed in order to
                                           filter out transactional messages
                                           which are not committed. Set to
                                           read_uncommitted to read all
                                           messages. (default: read_uncommitted)
--key-deserializer <String:
  deserializer for key>
--max-messages <Integer: num_messages>   The maximum number of messages to
                                           consume before exiting. If not set,
                                           consumption is continual.
--offset <String: consume offset>        The offset id to consume from (a non-
                                           negative number), or 'earliest'
                                           which means from beginning, or
                                           'latest' which means from end
                                           (default: latest)
--partition <Integer: partition>         The partition to consume from.
                                           Consumption starts from the end of
                                           the partition unless '--offset' is
                                           specified.
--property <String: prop>                The properties to initialize the
                                           message formatter. Default
                                           properties include:
                                         	print.timestamp=true|false
                                         	print.key=true|false
                                         	print.value=true|false
                                         	key.separator=<key.separator>
                                         	line.separator=<line.separator>
                                         	key.deserializer=<key.deserializer>
                                         	value.deserializer=<value.
                                           deserializer>
                                         Users can also pass in customized
                                           properties for their formatter; more
                                           specifically, users can pass in
                                           properties keyed with 'key.
                                           deserializer.' and 'value.
                                           deserializer.' prefixes to configure
                                           their deserializers.
--skip-message-on-error                  If there is an error when processing a
                                           message, skip it instead of halt.
--timeout-ms <Integer: timeout_ms>       If specified, exit if no message is
                                           available for consumption for the
                                           specified interval.
--topic <String: topic>                  The topic id to consume on.
--value-deserializer <String:
  deserializer for values>
--version                                Display Kafka version.
--whitelist <String: whitelist>          Regular expression specifying
                                           whitelist of topics to include for
                                           consumption.


```

