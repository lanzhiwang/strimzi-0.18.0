### THE OPENMESSAGING BENCHMARK FRAMEWORK

The OpenMessaging Benchmark Framework is a suite of tools that make it easy to benchmark distributed messaging systems in the cloud.  OpenMessaging Benchmark Framework是一套工具，可轻松在云中对分布式消息系统进行基准测试。

## PROJECT GOALS

The goal of the OpenMessaging Benchmark Framework is to provide benchmarking suites for an ever-expanding variety of messaging platforms. These suites are intended to be:  OpenMessaging Benchmark Framework的目标是为不断扩展的各种消息传递平台提供基准测试套件。 这些套件旨在：

- **Cloud based** — All benchmarks are run on cloud infrastructure, not on your laptop  所有基准均在云基础架构上运行，而不是在笔记本电脑上运行
- **Easy to use** — Just a few CLI commands gets you from zero to completed benchmarks  只需几个CLI命令，您便可以从零开始完成基准测试
- **Transparent** — All benchmarking code is open source, with pull requests very welcome  所有基准测试代码都是开源的
- **Realistic** — Benchmarks should be largely oriented toward standard use cases rather than bizarre edge cases  基准应该主要针对标准用例，而不是离奇的边缘案例

> If you’re interested in contributing to the OpenMessaging Benchmark Framework, you can find the code [on GitHub](https://github.com/openmessaging/openmessaging-benchmark).

## SUPPORTED MESSAGING SYSTEMS

OpenMessaging benchmarking suites are currently available for the following systems:

- [Apache RocketMQ](https://rocketmq.apache.org/)
- [Apache Pulsar](https://pulsar.incubator.apache.org/)
- [Apache Kafka](https://kafka.apache.org/)

> Benchmarking suites for [RabbitMQ](https://www.rabbitmq.com/) will be available soon.

For each platform, the benchmarking suite includes easy-to-use scripts for deploying that platform on [AlibabaCloud](https://www.alibabacloud.com/) and [Amazon Web Services](https://aws.amazon.com/) (AWS) and then running benchmarks upon deployment. For end-to-end instructions, see platform-specific docs for:  对于每个平台，基准测试套件均包含易于使用的脚本，用于在AlibabaCloud和Amazon Web Services（AWS）上部署该平台，然后在部署时运行基准测试。 有关端到端说明，请参阅特定于平台的文档以：

- [Apache RocketMQ](http://openmessaging.cloud/docs/benchmarks/rocketmq)
- [Apache Pulsar](http://openmessaging.cloud/docs/benchmarks/pulsar)
- [Apache Kafka](http://openmessaging.cloud/docs/benchmarks/kafka)

## BENCHMARKING WORKLOADS

Benchmarking workloads are specified in [YAML](http://yaml.org/) configuration files that are available in the [`workloads`](http://openmessaging.cloud/docs/benchmarks/workloads) directory. The table below describes each workload in terms of the following parameters:  在工作负载目录中的YAML配置文件中指定了基准工作负载。 下表通过以下参数描述了每个工作负载：

```yaml
name: 1 topic / 1 partition / 100b

topics: 1
partitionsPerTopic: 1
messageSize: 100
payloadFile: "payload/payload-100b.data"
subscriptionsPerTopic: 1
consumerPerSubscription: 1
producersPerTopic: 1
producerRate: 50000
consumerBacklogSizeGB: 0
testDurationMinutes: 15

```

- The number of topics
- The size of the messages being produced and consumed
- The number of subscriptions per topic
- The number of producers per topic
- The rate at which producers produce messages (per second). **Note**: a value of 0 means that messages are produced as quickly as possible, with no rate limiting.
- The size of the consumer’s backlog (in gigabytes)
- The total duration of the test (in minutes)

| Workload                                  | Topics | Partitions per topic | Message size | Subscriptions per topic | Producers per topic | Producer rate (per second) | Consumer backlog size (GB) | Test duration (minutes) |
| :---------------------------------------- | :----- | :------------------- | :----------- | :---------------------- | :------------------ | :------------------------- | :------------------------- | :---------------------- |
| simple-workload.yaml                      | 1      | 10                   | 1 kB         | 1                       | 1                   | 10000                      | 0                          | 5                       |
| 1-topic-1-partition-1kb.yaml              | 1      | 1                    | 1 kB         | 1                       | 1                   | 50000                      | 0                          | 15                      |
| 1-topic-1-partition-100b.yaml             | 1      | 1                    | 100 bytes    | 1                       | 1                   | 50000                      | 0                          | 15                      |
| 1-topic-16-partitions-1kb.yaml            | 1      | 16                   | 1 kB         | 1                       | 1                   | 50000                      | 0                          | 15                      |
| backlog-1-topic-1-partition-1kb.yaml      | 1      | 1                    | 1 kB         | 1                       | 1                   | 100000                     | 100                        | 5                       |
| backlog-1-topic-16-partitions-1kb.yaml    | 1      | 16                   | 1 kB         | 1                       | 1                   | 100000                     | 100                        | 5                       |
| max-rate-1-topic-1-partition-1kb.yaml     | 1      | 1                    | 1 kB         | 1                       | 1                   | 0                          | 0                          | 5                       |
| max-rate-1-topic-1-partition-100b.yaml    | 1      | 1                    | 100 bytes    | 1                       | 1                   | 0                          | 0                          | 5                       |
| 1-topic-3-partition-100b-3producers.yaml  | 1      | 3                    | 100 bytes    | 1                       | 3                   | 0                          | 0                          | 15                      |
| max-rate-1-topic-16-partitions-1kb.yaml   | 1      | 16                   | 1 kB         | 1                       | 1                   | 0                          | 0                          | 5                       |
| max-rate-1-topic-16-partitions-100b.yaml  | 1      | 16                   | 100 bytes    | 1                       | 1                   | 0                          | 0                          | 5                       |
| max-rate-1-topic-100-partitions-1kb.yaml  | 1      | 100                  | 1 kB         | 1                       | 1                   | 0                          | 0                          | 5                       |
| max-rate-1-topic-100-partitions-100b.yaml | 1      | 100                  | 100 bytes    | 1                       | 1                   | 0                          | 0                          | 5                       |

> Instructions for running specific workloads—or all workloads sequentially—can be found in the platform-specific [documentation](http://openmessaging.cloud/docs/benchmarks/#supported-messaging-systems).  可以在特定于平台的文档中找到有关运行特定工作负载（或依次运行所有工作负载）的说明。

## INTERPRETING THE RESULTS

Initially, you should see a log message like this, which affirms that a warm-up phase is intiating:  最初，您应该看到类似这样的日志消息，该消息确认预热阶段即将开始：

```
22:03:19.125 [main] INFO - ----- Starting warm-up traffic ------
```

You should then see some just a handful of readings, followed by an aggregation message that looks like this:  然后，您应该会看到一些读数，然后是如下所示的汇总消息：

```
22:04:19.329 [main] INFO - ----- Aggregated Pub Latency (ms) avg:  2.1 - 50%:  1.7 - 95%:  3.0 - 99%: 11.8 - 99.9%: 45.4 - 99.99%: 52.6 - Max: 55.4
```

At this point, the benchmarking traffic will begin. You’ll start see readings like this emitted every few seconds:  此时，基准流量将开始。 您会开始每隔几秒钟看到一次这样的读数：

```
22:03:29.199 [main] INFO - Pub rate 50175.1 msg/s /  4.8 Mb/s | Cons rate 50175.2 msg/s /  4.8 Mb/s | Backlog:  0.0 K | Pub Latency (ms) avg:  3.5 - 50%:  1.9 - 99%: 39.8 - 99.9%: 52.3 - Max: 55.4
```

The table below breaks down the information presented in the benchmarking log messages (all figures are for the most recent 10-second time window):  下表细分了基准测试日志消息中显示的信息（所有数字均为最近的10秒时间窗口）：

| Measure                | Meaning                                                      | Units                                                        |
| :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `Pub rate`             | The rate at which messages are published to the topic        | Messages per second / Megabytes per second                   |
| `Cons rate`            | The rate at which messages are consumed from the topic       | Messages per second / Megabytes per second                   |
| `Backlog`              | The number of messages in the messaging system’s backlog     | Number of messages (in thousands)                            |
| `Pub latency (ms) avg` | The publish latency within the time range  时间范围内的发布延迟 | Milliseconds (average, 50th percentile, 99th percentile, and 99.9th percentile, and maximum) |

At the end of each [workload](http://openmessaging.cloud/docs/benchmarks/#benchmarking-workloads), you’ll see a log message that aggregages the results:  在每个工作负载结束时，您都会看到一条日志消息，该消息会汇总结果：

```
22:19:20.577 [main] INFO - ----- Aggregated Pub Latency (ms) avg:  1.8 - 50%:  1.7 - 95%:  2.8 - 99%:  3.0 - 99.9%:  8.0 - 99.99%: 17.1 - Max: 58.9
```

You’ll also see a message like this that tells into which JSON file the benchmarking results have been saved (all JSON results are saved to the `/opt/benchmark` directory):  您还将看到一条类似的消息，告诉您基准测试结果已保存到哪个JSON文件中（所有JSON结果都保存到 /opt/benchmark 目录中）：

```
22:19:20.592 [main] INFO - Writing test result into 1-topic-1-partition-100b-Kafka-2018-01-29-22-19-20.json
```

> The process explained above will repeat *for each [benchmarking workload](http://openmessaging.cloud/docs/benchmarks/#benchmarking-workloads)* that you run.  对于您运行的每个基准测试工作负载，将重复上述过程。

## ADDING A NEW PLATFORM

In order to add a new platform for benchmarking, you need to provide the following:

- A [Terraform](https://terraform.io/) configuration for creating the necessary AlibabaCloud or AWS resources ([example](https://github.com/openmessaging/openmessaging-benchmark/blob/master/driver-rocketmq/deploy/provision-rocketmq-alicloud.tf))
- An [Ansible playbook](http://docs.ansible.com/ansible/latest/playbooks.html) for installing and starting the platform on AWS ([example](https://github.com/openmessaging/openmessaging-benchmark/blob/master/driver-pulsar/deploy/deploy.yaml))
- An implementation of the Java [`driver-api`](https://github.com/streamlio/messaging-benchmark/tree/master/driver-api) library ([example](https://github.com/openmessaging/openmessaging-benchmark/tree/master/driver-kafka/src/main/java/io/openmessaging/benchmark/driver/kafka))
- A YAML configuration file that provides any necessary client configuration info ([example](https://github.com/openmessaging/openmessaging-benchmark/blob/master/driver-pulsar/pulsar.yaml))

参考：

* http://openmessaging.cloud/docs/benchmarks/

* https://github.com/openmessaging/openmessaging-benchmark

