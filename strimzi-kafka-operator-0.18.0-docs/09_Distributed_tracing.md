## 9. Distributed tracing

This chapter outlines the support for distributed tracing in Strimzi, using Jaeger.  本章概述了使用 Jaeger 在 Strimzi 中对分布式跟踪的支持。

How you configure distributed tracing varies by Strimzi client and component.  配置分布式跟踪的方式因 Strimzi 客户端和组件而异。

- You *instrument* Kafka Producer, Consumer, and Streams API applications for distributed tracing using an OpenTracing client library. This involves adding instrumentation code to these clients, which monitors the execution of individual transactions in order to generate trace data.  您可以使用 OpenTracing 客户端库对 Kafka Producer、Consumer 和 Streams API 应用程序进行检测以进行分布式跟踪。 这涉及向这些客户端添加检测代码，这些代码监视单个事务的执行以生成跟踪数据。

- Distributed tracing support is built in to the Kafka Connect, MirrorMaker, and Kafka Bridge components of Strimzi. To configure these components for distributed tracing, you configure and update the relevant custom resources.  Strimzi 的 Kafka Connect、MirrorMaker 和 Kafka Bridge 组件中内置了分布式跟踪支持。 要为分布式跟踪配置这些组件，您需要配置和更新相关的自定义资源。

Before configuring distributed tracing in Strimzi clients and components, you must first initialize and configure a Jaeger tracer in the Kafka cluster, as described in [Initializing a Jaeger tracer for Kafka clients](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-jaeger-tracer-kafka-clients-str).  在 Strimzi 客户端和组件中配置分布式跟踪之前，您必须首先在 Kafka 集群中初始化和配置 Jaeger 跟踪器，如为 Kafka 客户端初始化 Jaeger 跟踪器中所述。

> NOTE
> Distributed tracing is not supported for Kafka brokers.
> 

### 9.1. Overview of distributed tracing in Strimzi

Distributed tracing allows developers and system administrators to track the progress of transactions between applications (and services in a microservice architecture) in a distributed system. This information is useful for monitoring application performance and investigating issues with target systems and end-user applications.  分布式跟踪允许开发人员和系统管理员跟踪分布式系统中应用程序（和微服务架构中的服务）之间的事务进度。 此信息对于监视应用程序性能和调查目标系统和最终用户应用程序的问题很有用。

In Strimzi and data streaming platforms in general, distributed tracing facilitates the end-to-end tracking of messages: from source systems to the Kafka cluster and then to target systems and applications.  在 Strimzi 和一般的数据流平台中，分布式跟踪有助于端到端的消息跟踪：从源系统到 Kafka 集群，然后到目标系统和应用程序。

As an aspect of system observability, distributed tracing complements the metrics that are available to view in [Grafana dashboards](https://strimzi.io/docs/operators/0.18.0/deploying.html#assembly-metrics-setup-str) and the available loggers for each component.  作为系统可观察性的一个方面，分布式跟踪补充了可在 Grafana 仪表板中查看的指标以及每个组件的可用记录器。

#### OpenTracing overview  概述

Distributed tracing in Strimzi is implemented using the open source [OpenTracing](https://opentracing.io/) and [Jaeger](https://www.jaegertracing.io/) projects.  Strimzi 中的分布式跟踪是使用开源 OpenTracing 和 Jaeger 项目实现的。

The OpenTracing specification defines APIs that developers can use to instrument applications for distributed tracing. It is independent from the tracing system.  OpenTracing 规范定义了开发人员可用于检测应用程序以进行分布式跟踪的 API。 它独立于跟踪系统。

When instrumented, applications generate *traces* for individual transactions. Traces are composed of *spans*, which define specific units of work.  检测后，应用程序会为各个事务生成跟踪。 跟踪由跨度组成，跨度定义了特定的工作单元。

To simplify the instrumentation of the Kafka Bridge and Kafka Producer, Consumer, and Streams API applications, Strimzi includes the [OpenTracing Apache Kafka Client Instrumentation](https://github.com/opentracing-contrib/java-kafka-client/blob/master/README.md) library.  为了简化 Kafka Bridge 和 Kafka Producer、Consumer 和 Streams API 应用程序的检测，Strimzi 包含 OpenTracing Apache Kafka Client Instrumentation 库。

> NOTE
> The OpenTracing project is merging with the OpenCensus project. The new, combined project is named [OpenTelemetry](https://opentelemetry.io/). OpenTelemetry will provide compatibility for applications that are instrumented using the OpenTracing APIs.  OpenTracing 项目正在与 OpenCensus 项目合并。 新的组合项目名为 OpenTelemetry。 OpenTelemetry 将为使用 OpenTracing API 检测的应用程序提供兼容性。
> 

#### Jaeger overview

Jaeger, a tracing system, is an implementation of the OpenTracing APIs used for monitoring and troubleshooting microservices-based distributed systems. It consists of four main components and provides client libraries for instrumenting applications. You can use the Jaeger user interface to visualize, query, filter, and analyze trace data.  Jaeger 是一个跟踪系统，是 OpenTracing API 的一种实现，用于监控和故障排除基于微服务的分布式系统。 它由四个主要组件组成，并为检测应用程序提供客户端库。 您可以使用 Jaeger 用户界面来可视化、查询、过滤和分析跟踪数据。

An example of a query in the Jaeger user interface

![](../images/image_con-overview-distributed-tracing.png)

#### 9.1.1. Distributed tracing support in Strimzi

In Strimzi, distributed tracing is supported in:

- Kafka Connect (including Kafka Connect with Source2Image support)

- MirrorMaker

- The Strimzi Kafka Bridge

You enable and configure distributed tracing for these components by setting template configuration properties in the relevant custom resource (for example, `KafkaConnect` and `KafkaBridge`).  您可以通过在相关自定义资源（例如，KafkaConnect 和 KafkaBridge）中设置模板配置属性来启用和配置这些组件的分布式跟踪。

To enable distributed tracing in Kafka Producer, Consumer, and Streams API applications, you can instrument application code using the OpenTracing Apache Kafka Client Instrumentation library. When instrumented, these clients generate traces for messages (for example, when producing messages or writing offsets to the log).  要在 Kafka Producer、Consumer 和 Streams API 应用程序中启用分布式跟踪，您可以使用 OpenTracing Apache Kafka Client Instrumentation 库来检测应用程序代码。 检测后，这些客户端会生成消息跟踪（例如，在生成消息或将偏移量写入日志时）。

Traces are sampled according to a sampling strategy and then visualized in the Jaeger user interface. This trace data is useful for monitoring the performance of your Kafka cluster and debugging issues with target systems and applications.  根据采样策略对轨迹进行采样，然后在 Jaeger 用户界面中进行可视化。 此跟踪数据对于监控 Kafka 集群的性能以及调试目标系统和应用程序的问题很有用。

#### Outline of procedures

To set up distributed tracing for Strimzi, follow these procedures:  要为 Strimzi 设置分布式跟踪，请遵循以下过程：

- Initialize a Jaeger tracer for Kafka clients  为 Kafka 客户端初始化 Jaeger 跟踪器

- Instrument Kafka Producers and Consumers for tracing  使用 Kafka 生产者和消费者进行跟踪

- Instrument Kafka Streams applications for tracing  检测 Kafka Streams 应用程序以进行跟踪

- Set up tracing for MirrorMaker, Kafka Connect, and the Kafka Bridge  为 MirrorMaker、Kafka Connect 和 Kafka Bridge 设置跟踪

This chapter covers setting up distributed tracing for Strimzi clients and components only. Setting up distributed tracing for applications and systems beyond Strimzi is outside the scope of this chapter. To learn more about this subject, see the [OpenTracing documentation](https://opentracing.io/docs/overview/) and search for "inject and extract".  本章仅介绍为 Strimzi 客户端和组件设置分布式跟踪。 为 Strimzi 之外的应用程序和系统设置分布式跟踪超出了本章的范围。 要了解有关此主题的更多信息，请参阅 OpenTracing 文档并搜索“注入和提取”。

#### Before you start

Before you set up distributed tracing for Strimzi, it is helpful to understand:

- The basics of OpenTracing, including key concepts such as traces, spans, and tracers. Refer to the [OpenTracing documentation](https://opentracing.io/docs/overview/).

- The components of the [Jaeger architecure](https://www.jaegertracing.io/docs/1.14/architecture/).

#### Prerequisites

- The Jaeger backend components are deployed to your Kubernetes cluster. For deployment instructions, see the [Jaeger deployment documentation](https://www.jaegertracing.io/docs/1.14/deployment/).

### 9.2. Setting up tracing for Kafka clients

This section describes how to initialize a Jaeger tracer to allow you to instrument your client applications for distributed tracing.

#### 9.2.1. Initializing a Jaeger tracer for Kafka clients

Configure and initialize a Jaeger tracer using a set of tracing environment variables.

##### Procedure

Perform the following steps for each client application.

1. Add Maven dependencies for Jaeger to the `pom.xml` file for the client application:

```xml
<dependency>
    <groupId>io.jaegertracing</groupId>
    <artifactId>jaeger-client</artifactId>
    <version>1.1.0</version>
</dependency>
```

2. Define the configuration of the Jaeger tracer using the tracing environment variables.

3. Create the Jaeger tracer from the environment variables that you defined in step two:

```java
Tracer tracer = Configuration.fromEnv().getTracer();
```

> NOTE
> For alternative ways to initialize a Jaeger tracer, see the [Java OpenTracing library](https://github.com/jaegertracing/jaeger-client-java/tree/master/jaeger-core) documentation.
> 

4. Register the Jaeger tracer as a global tracer:

```java
GlobalTracer.register(tracer);
```

A Jaeger tracer is now initialized for the client application to use.

#### 9.2.2. Tracing environment variables

Use these environment variables when configuring a Jaeger tracer for Kafka clients.

> NOTE
> The tracing environment variables are part of the Jaeger project and are subject to change. For the latest environment variables, see the [Jaeger documentation](https://github.com/jaegertracing/jaeger-client-java/tree/master/jaeger-core#configuration-via-environment).
> 

| Property | Required | Description |
| -------- | -------- | ----------- |
| `JAEGER_SERVICE_NAME` | Yes | The name of the Jaeger tracer service. |
| `JAEGER_AGENT_HOST` | No | The hostname for communicating with the `jaeger-agent` through the User Datagram Protocol (UDP). |
| `JAEGER_AGENT_PORT` | No | The port used for communicating with the `jaeger-agent` through UDP. |
| `JAEGER_ENDPOINT` | No | The traces endpoint. Only define this variable if the client application will bypass the `jaeger-agent` and connect directly to the `jaeger-collector`. |
| `JAEGER_AUTH_TOKEN` | No | The authentication token to send to the endpoint as a bearer token. |
| `JAEGER_USER` | No | The username to send to the endpoint if using basic authentication. |
| `JAEGER_PASSWORD` | No | The password to send to the endpoint if using basic authentication. |
| `JAEGER_PROPAGATION` | No | A comma-separated list of formats to use for propagating the trace context. Defaults to the standard Jaeger format. Valid values are `jaeger` and `b3`. |
| `JAEGER_REPORTER_LOG_SPANS` | No | Indicates whether the reporter should also log the spans. |
| `JAEGER_REPORTER_MAX_QUEUE_SIZE` | No | The reporter’s maximum queue size. |
| `JAEGER_REPORTER_FLUSH_INTERVAL` | No | The reporter’s flush interval, in ms. Defines how frequently the Jaeger reporter flushes span batches. |
| `JAEGER_SAMPLER_TYPE` | No | The sampling strategy to use for client traces: Constant, Probabilistic, Rate Limiting, or Remote (the default type).To sample all traces, use the Constant sampling strategy with a parameter of 1.For more information, see the [Jaeger documentation](https://www.jaegertracing.io/docs/1.14/sampling/#client-sampling-configuration). |
| `JAEGER_SAMPLER_PARAM` | No | The sampler parameter (number). |
| `JAEGER_SAMPLER_MANAGER_HOST_PORT` | No | The hostname and port to use if a Remote sampling strategy is selected. |
| `JAEGER_TAGS` | No | A comma-separated list of tracer-level tags that are added to all reported spans.The value can also refer to an environment variable using the format `${envVarName:default}`. `:default` is optional and identifies a value to use if the environment variable cannot be found. |

Additional resources

- [Initializing a Jaeger tracer for Kafka clients](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-jaeger-tracer-kafka-clients-str)

### 9.3. Instrumenting Kafka clients with tracers

This section describes how to instrument Kafka Producer, Consumer, and Streams API applications for distributed tracing.

#### 9.3.1. Instrumenting Kafka Producers and Consumers for tracing

Use a Decorator pattern or Interceptors to instrument your Java Producer and Consumer application code for distributed tracing.

#### Procedure

Perform these steps in the application code of each Kafka Producer and Consumer application.

1. Add the Maven dependency for OpenTracing to the Producer or Consumer’s `pom.xml` file.

```xml
<dependency>
    <groupId>io.opentracing.contrib</groupId>
    <artifactId>opentracing-kafka-client</artifactId>
    <version>0.1.12</version>
</dependency>
```

2. Instrument your client application code using either a Decorator pattern or Interceptors.

- If you prefer to use a Decorator pattern, use following example:

```java
// Create an instance of the KafkaProducer:
KafkaProducer<Integer, String> producer = new KafkaProducer<>(senderProps);

// Create an instance of the TracingKafkaProducer:
TracingKafkaProducer<Integer, String> tracingProducer = new TracingKafkaProducer<>(producer, tracer);

// Send:
tracingProducer.send(...);

// Create an instance of the KafkaConsumer:
KafkaConsumer<Integer, String> consumer = new KafkaConsumer<>(consumerProps);

// Create an instance of the TracingKafkaConsumer:
TracingKafkaConsumer<Integer, String> tracingConsumer = new TracingKafkaConsumer<>(consumer, tracer);

// Subscribe:
tracingConsumer.subscribe(Collections.singletonList("messages"));

// Get messages:
ConsumerRecords<Integer, String> records = tracingConsumer.poll(1000);

// Retrieve SpanContext from polled record (consumer side):
ConsumerRecord<Integer, String> record = ...
SpanContext spanContext = TracingKafkaUtils.extractSpanContext(record.headers(), tracer);
```

- If you prefer to use Interceptors, use the following example:

```java
// Register the tracer with GlobalTracer:
GlobalTracer.register(tracer);

// Add the TracingProducerInterceptor to the sender properties:
senderProps.put(ProducerConfig.INTERCEPTOR_CLASSES_CONFIG, TracingProducerInterceptor.class.getName());

// Create an instance of the KafkaProducer:
KafkaProducer<Integer, String> producer = new KafkaProducer<>(senderProps);

// Send:
producer.send(...);

// Add the TracingConsumerInterceptor to the consumer properties:
consumerProps.put(ConsumerConfig.INTERCEPTOR_CLASSES_CONFIG, TracingConsumerInterceptor.class.getName());

// Create an instance of the KafkaConsumer:
KafkaConsumer<Integer, String> consumer = new KafkaConsumer<>(consumerProps);

// Subscribe:
consumer.subscribe(Collections.singletonList("messages"));

// Get messages:
ConsumerRecords<Integer, String> records = consumer.poll(1000);

// Retrieve the SpanContext from a polled message (consumer side):
ConsumerRecord<Integer, String> record = ...
SpanContext spanContext = TracingKafkaUtils.extractSpanContext(record.headers(), tracer);
```

##### Custom span names in a Decorator pattern

A *span* is a logical unit of work in Jaeger, with an operation name, start time, and duration.

If you use a Decorator pattern to instrument your Kafka Producer and Consumer applications, you can define custom span names by passing a `BiFunction` object as an additional argument when creating the `TracingKafkaProducer` and `TracingKafkaConsumer` objects. The OpenTracing Apache Kafka Client Instrumentation library includes several built-in span names, which are described below.

Example: Using custom span names to instrument client application code in a Decorator pattern

```java
// Create a BiFunction for the KafkaProducer that operates on (String operationName, ProducerRecord consumerRecord) and returns a String to be used as the name:

BiFunction<String, ProducerRecord, String> producerSpanNameProvider =
    (operationName, producerRecord) -> "CUSTOM_PRODUCER_NAME";

// Create an instance of the KafkaProducer:
KafkaProducer<Integer, String> producer = new KafkaProducer<>(senderProps);

// Create an instance of the TracingKafkaProducer
TracingKafkaProducer<Integer, String> tracingProducer = new TracingKafkaProducer<>(producer, tracer, producerSpanNameProvider);

// Spans created by the tracingProducer will now have "CUSTOM_PRODUCER_NAME" as the span name.

// Create a BiFunction for the KafkaConsumer that operates on (String operationName, ConsumerRecord consumerRecord) and returns a String to be used as the name:

BiFunction<String, ConsumerRecord, String> consumerSpanNameProvider =
    (operationName, consumerRecord) -> operationName.toUpperCase();

// Create an instance of the KafkaConsumer:
KafkaConsumer<Integer, String> consumer = new KafkaConsumer<>(consumerProps);

// Create an instance of the TracingKafkaConsumer, passing in the consumerSpanNameProvider BiFunction:

TracingKafkaConsumer<Integer, String> tracingConsumer = new TracingKafkaConsumer<>(consumer, tracer, consumerSpanNameProvider);

// Spans created by the tracingConsumer will have the operation name as the span name, in upper-case.
// "receive" -> "RECEIVE"
```

##### Built-in span names

When defining custom span names, you can use the following `BiFunctions` in the `ClientSpanNameProvider` class. If no `spanNameProvider` is specified, `CONSUMER_OPERATION_NAME` and `PRODUCER_OPERATION_NAME` are used.

| BiFunction | Description |
| ---------- | ----------- |
| `CONSUMER_OPERATION_NAME, PRODUCER_OPERATION_NAME` | Returns the `operationName` as the span name: "receive" for Consumers and "send" for Producers. |
| `CONSUMER_PREFIXED_OPERATION_NAME(String prefix), PRODUCER_PREFIXED_OPERATION_NAME(String prefix)` | Returns a String concatenation of `prefix` and `operationName`. |
| `CONSUMER_TOPIC, PRODUCER_TOPIC` | Returns the name of the topic that the message was sent to or retrieved from in the format `(record.topic())`. |
| `PREFIXED_CONSUMER_TOPIC(String prefix), PREFIXED_PRODUCER_TOPIC(String prefix)` | Returns a String concatenation of `prefix` and the topic name in the format `(record.topic())`. |
| `CONSUMER_OPERATION_NAME_TOPIC, PRODUCER_OPERATION_NAME_TOPIC` | Returns the operation name and the topic name: `"operationName - record.topic()"`. |
| `CONSUMER_PREFIXED_OPERATION_NAME_TOPIC(String prefix), PRODUCER_PREFIXED_OPERATION_NAME_TOPIC(String prefix)` | Returns a String concatenation of `prefix` and `"operationName - record.topic()"`. |

#### 9.3.2. Instrumenting Kafka Streams applications for tracing

This section describes how to instrument Kafka Streams API applications for distributed tracing.

##### Procedure

Perform the following steps for each Kafka Streams API application.

1. Add the `opentracing-kafka-streams` dependency to the pom.xml file for your Kafka Streams API application:

```xml
<dependency>
    <groupId>io.opentracing.contrib</groupId>
    <artifactId>opentracing-kafka-streams</artifactId>
    <version>0.1.12</version>
</dependency>
```

2. Create an instance of the `TracingKafkaClientSupplier` supplier interface:

```java
KafkaClientSupplier supplier = new TracingKafkaClientSupplier(tracer);
```

3. Provide the supplier interface to `KafkaStreams`:

```java
KafkaStreams streams = new KafkaStreams(builder.build(), new StreamsConfig(config), supplier);
streams.start();
```

### 9.4. Setting up tracing for MirrorMaker, Kafka Connect, and the Kafka Bridge

Distributed tracing is supported for MirrorMaker, Kafka Connect (including Kafka Connect with Source2Image support), and the Strimzi Kafka Bridge.

#### Tracing in MirrorMaker

For MirrorMaker, messages are traced from the source cluster to the target cluster; the trace data records messages entering and leaving the MirrorMaker component.

#### Tracing in Kafka Connect

Only messages produced and consumed by Kafka Connect itself are traced. To trace messages sent between Kafka Connect and external systems, you must configure tracing in the connectors for those systems. For more information, see [Kafka Connect cluster configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-connect-str).

#### Tracing in the Kafka Bridge

Messages produced and consumed by the Kafka Bridge are traced. Incoming HTTP requests from client applications to send and receive messages through the Kafka Bridge are also traced. In order to have end-to-end tracing, you must configure tracing in your HTTP clients.

#### 9.4.1. Enabling tracing in MirrorMaker, Kafka Connect, and Kafka Bridge resources

Update the configuration of `KafkaMirrorMaker`, `KafkaConnect`, `KafkaConnectS2I`, and `KafkaBridge` custom resources to specify and configure a Jaeger tracer service for each resource. Updating a tracing-enabled resource in your Kubernetes cluster triggers two events:

- Interceptor classes are updated in the integrated consumers and producers in MirrorMaker, Kafka Connect, or the Strimzi Kafka Bridge.

- For MirrorMaker and Kafka Connect, the tracing agent initializes a Jaeger tracer based on the tracing configuration defined in the resource.

- For the Kafka Bridge, a Jaeger tracer based on the tracing configuration defined in the resource is initialized by the Kafka Bridge itself.

##### Procedure

Perform these steps for each `KafkaMirrorMaker`, `KafkaConnect`, `KafkaConnectS2I`, and `KafkaBridge` resource.

1. In the `spec.template` property, configure the Jaeger tracer service. For example:

Jaeger tracer configuration for Kafka Connect

```yaml

apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
spec:
  #...
  template:
    connectContainer:
      env:
      - name: JAEGER_SERVICE_NAME
        value: my-jaeger-service
      - name: JAEGER_AGENT_HOST
        value: jaeger-agent-name
      - name: JAEGER_AGENT_PORT
        value: "6831"
  tracing:
    type: jaeger
  #...

```

Jaeger tracer configuration for MirrorMaker

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
metadata:
  name: my-mirror-maker
spec:
  #...
  template:
    mirrorMakerContainer:
      env:
      - name: JAEGER_SERVICE_NAME
        value: my-jaeger-service
      - name: JAEGER_AGENT_HOST
        value: jaeger-agent-name
      - name: JAEGER_AGENT_PORT
        value: "6831"
  tracing:
   type: jaeger
  #...
```

Jaeger tracer configuration for the Kafka Bridge

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  #...
  template:
    bridgeContainer:
      env:
      - name: JAEGER_SERVICE_NAME
        value: my-jaeger-service
      - name: JAEGER_AGENT_HOST
        value: jaeger-agent-name
      - name: JAEGER_AGENT_PORT
        value: "6831"
  tracing:
   type: jaeger

```

2. Create or update the resource:

```shell
kubectl apply -f your-file
```


