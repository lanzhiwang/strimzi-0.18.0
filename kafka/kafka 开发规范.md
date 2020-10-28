# Kafka 开发规范

## kafka 概览

### kafka 基本组成元素

![](../images/kafka_04.png)

1. 一个 Kafka 集群由多个 Broker 组成，一个 Broker 在逻辑上为在一台服务端机器上运行的进程。Broker 是 Kafka 集群中的服务端节点，负责存储数据、协调分区副本、管理消费者群组、处理客户端请求 等工作。

2. Kafka 集群通过 Zookeeper 维护集群节点，进行控制器选举以及集群配置管理等活动，是 Kakfa 的基础依赖。

3. Client 为开发人员使用的客户端，不属于 Kafka 集群的节点，但是是组成 Kafka 集群的重要角色，分为生产者与消费者两种类型。
   * Producer：生产者是集群中生产数据的地方，通过 push 的方式将数据推送到集群服务端存储。
   * Consumer：消费者是集群中消费数据的地方，通过 pull 的方式将数据从集群服务器中拉取并消费。


#### kafka 功能说明

![](../images/kafka_01.png)

如上图所示：Kafka 集群由 broker1 和 broker2 组成。在 Broker 服务端中，Kafka 以 Topic 的形式来组织数据，每条发送到服务端的消息必须要指定其属于哪个 Topic，不同的 Topic 中的数据在物理上分开存储。在上图中，主题 A 中的数据就分别存储在 broker1 和 broker2 。

每个 Topic 包含一个或多个 Partition（在创建 Topic 时指定），同一个 Topic 的不同 Partition 可能存在不同的 Broker 中，从而实现数据和请求的负载均衡。主题 A 有两个分区，分别是分区 0 和分区 1。

每个 Partition 都拥有自己的副本（副本数可配置），在上图中，每个分区都有两个副本，每个副本分别存储在不同的 broker 上。

![](../images/kafka_08.png)

主题、分区、副本之间的关系如上图所示：下图中的主题拥有 3 个分区，每个分区有 4 个副本。每个分区中的副本分为 Leader 与 Follower。 Leader 副本负责统一接受客户端读写请求，保持数据一致性。Follower 副本从 Leader 副本同步数据，并时刻准备成为 Leader 副本提供服务。根据 Follower 副本从 Leader 副本同步数据的情况，Follower 副本有同步和不同步两种状态。同步副本就是和 Leader 数据相差不是很大的副本，不同步副本就是和 Leader 副本数据差距比较大的副本，具体差距可以通过相关配置进行定制。


## 生产者实现

producer 实现过程如下所示：

![](../images/kafka_02.png)

### 消息组成

1. 目标主题
2. 目标分区
3. key
4. Value，消息本身
5. Timestamp（新版本中加入的功能）

向 Kafka 发送数据，从创建一个 `ProducerRecord` 对象开始，ProducerRecord 对象需要包含`目标主题`和要`发送的内容`。还可以指定`键`或`分区`。在发送 ProducerRecord 对象时，生产者要先把键和值对象`序列化`成字节数组，这样它们才能够在网络上传输。

接下来，数据被传给`分区器`。如果之前在 ProducerRecord 对象里指定了分区，那么分区器就不会再做任何事情，直接把指定的分区返回。如果没有指定分区，那么分区器会根据 ProducerRecord 对象的键来选择一个分区。选好分区以后，生产者就知道该往哪个主题和分区发送这条记录了。

紧接着，这条记录被添加到一个`记录批次`里，这个批次里的所有消息会被发送到相同的主题和分区上。有一个独立的线程负责把这些记录批次发送到相应的 broker 上。

服务器在收到这些消息时会返回一个响应。如果消息成功写入 Kafka，就返回一个 `RecordMetaData` 对象，它包含了主题和分区信息，以及记录在分区里的偏移量。如果写入失败，则会返回一个错误。生产者在收到错误之后会尝试重新发送消息，几次之后如果还是失败，就返回错误信息。


### 代码示例

```java
Properties kafkaProps = new Properties();
// 生产者配置
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("key.serializer", "");
kafkaProps.put("value.serializer", "");

// 根据配置创建生产者对象
KafkaProducer producer = new KafkaProducer(kafkaProps);

// 创建消息对象，指定 "topic", "key", "value"
ProducerRecord record = new ProducerRecord("topic", "key", "value");
try {
    // 使用 send() 方法向 broker 发送消息
    producer.send(record);
} catch (Exception e) {
    e.printStackTrace();
} finally {
    // 最后关闭生产者对象
    producer.close()
}

```

Send() 方法在内部获取了元数据，并且处理了网络请求相关的细节。代码中没有对 send() 的返回结果进行处理。对 send() 返回结果有如下几种处理方式：

1. **同步发送**

```java
// 创建消息对象，指定 "topic", "key", "value"
ProducerRecord record = new ProducerRecord("topic", "key", "value");
try {
    // 使用 send() 方法向 broker 发送消息
    // 同步发送数据，阻塞线程直到 broker 返回结果或者抛出异常
    producer.send(record).get();
} catch (Exception e) {
    e.printStackTrace();
}

```

2. **异步发送**

```java
// 定义消息发送成功时的回调
private class DemoProducerCallback implements callback {
    public void onCompletion(RecordMetadata recordMetadata, Exception e){
        // recordMetadata 中包含了消息在分区中的偏移量
    }
}

// 创建消息对象，指定 "topic", "key", "value"
ProducerRecord record = new ProducerRecord("topic", "key", "value");
try {
    // 使用 send() 方法向 broker 发送消息
    // 异步发送数据
    producer.send(record, new DemoProducerCallback());
} catch (Exception e) {
    e.printStackTrace();
}

```

### 生产者配置

1. **acks**

acks 参数指定了必须要有多少个分区副本收到消息，生产者才会认为消息写入是成功的。这个参数对消息丢失的可能性有重要影响。该参数有如下选项。

* 如果 acks=0，生产者在成功写入消息之前不会等待任何来自服务器的响应。也就是说， 如果当中出现了问题，导致服务器没有收到消息，那么生产者就无从得知，消息也就丢失了。不过，因为生产者不需要等待服务器的响应，所以它可以以网络能够支持的最大速度发送消息，从而达到很高的吞吐量。

* 如果 acks=1，只要集群的首领副本收到消息，生产者就会收到一个来自服务器的成功响应。如果消息无法到达首领副本（比如首领节点崩溃，新的首领还没有被选举出来），生产者会收到一个错误响应，为了避免数据丢失，生产者会重发消息。不过，如果一个没有收到消息的节点成为新首领，消息还是会丢失（这种情况主要是元数据更新不及时造成的）。这个时候的吞吐量取决于使用的是同步发送还是异步发送。如果让发送客户端等待服务器的响应（通过调用 Future 对象的 get() 方法），显然会增加延迟（在网络上传输一个来回的延迟)。如果客户端使用回调，延迟问题就可以得到缓解，不过吞吐量还是会受发送中消息数量的限制（比如，生产者在收到服务器响应之前可以发送多少个消息)。

* 如果 acks=all，只有当所有参与复制的节点全部收到消息时，生产者才会收到一个来自服务器的成功响应。这种模式是最安全的，它可以保证不止一个服务器收到消息，就算有服务器发生崩溃，整个集群仍然可以运行。不过，它的延迟比 acks=1 时更高，因为我们要等待不只一个服务器节点接收消息。

------

2. **buffer.memory**

该参数用来设置生产者内存缓冲区的大小，生产者用它缓冲要发送到服务器的消息。如果应用程序发送消息的速度超过发送到服务器的速度，会导致生产者空间不足。这个时候， send() 方法调用要么被阻塞，要么抛出异常，取决于如何设置 `block.on.buffer.full` 参数 (在 0.9.0.0 版本里被替换成了 `max.block.ms`，表示在抛出异常之前可以阻塞一段时间）。

------

3. **compression.type**

默认情况下，消息发送时不会被压缩。该参数可以设置为 `snappy`、`gzip`或 `lz4`，它指定了消息被发送给 broker 之前使用哪一种压缩算法进行压缩。使用压缩可以降低网络传输开销和存储开销，而这往往是向 Kafka 发送消息的瓶颈所在。

------

4. **retries**

生产者从服务器收到的错误有可能是临时性的错误（比如分区找不到首领）。在这种情况 下，retries 参数的值决定了生产者可以重发消息的次数，如果达到这个次数，生产者会放弃重试并返回错误。默认情况下，生产者会在每次重试之间等待 100ms，不过可以通过 `retry.backoff.ms` 参数来改变这个时间间隔。建议在设置重试次数和重试时间间隔之前， 先测试一下恢复一个崩溃节点需要多少时间（比如所有分区选举出首领需要多长时间），让总的重试时间比 Kafka 集群从崩溃中恢复的时间长，否则生产者会过早地放弃重试。不过有些错误不是临时性错误，没办法通过重试来解决（比如“消息太大”错误）。一般情况下，因为生产者会自动进行重试，所以就没必要在代码逻辑里处理那些可重试的错误。 你只需要处理那些不可重试的错误或重试次数超出上限的情况。

------

5. **batch.size**

当有多个消息需要被发送到同一个分区时，生产者会把它们放在同一个批次里。该参数指定了一个批次可以使用的内存大小，按照字节数计算（而不是消息个数)。当批次被填满，批次里的所有消息会被发送出去。不过生产者并不一定都会等到批次被填满才发送，半满的批次，甚至只包含一个消息的批次也有可能被发送。所以就算把批次大小设置得很大， 也不会造成延迟，只是会占用更多的内存而已。但如果设置得太小，因为生产者需要更频繁地发送消息，会增加一些额外的开销。

------

6. **linger.ms**

该参数指定了生产者在发送批次之前等待更多消息加入批次的时间。KafkaProducer 会在批次填满或 linger.ms 达到上限时把批次发送出去。默认情况下，只要有可用的线程，生产者就会把消息发送出去，就算批次里只有一个消息。把 linger.ms 设置成比 0 大的数， 让生产者在发送批次之前等待一会儿，使更多的消息加入到这个批次。虽然这样会增加延迟，但也会提升吞吐量（因为一次性发送更多的消息，每个消息的开销就变小了）。

------

7. **client.id**

该参数可以是任意的字符串，服务器会用它来识别消息的来源，还可以用在日志和配额指标里。

------

8. **max.in.flight.requests.per.connection**

该参数指定了生产者在收到服务器响应之前可以发送多少个消息。它的值越高，就会占用越多的内存，不过也会提升吞吐量。把它设为 1 可以保证消息是按照发送的顺序写入服务器的，即使发生了重试。

------

9. **timeout.ms**、**request.timeout.ms** 和 **metadata.fetch.timeout.ms**

`request.timeout.ms` 指定了生产者在发送数据时等待服务器返回响应的时间，`metadata.fetch.timeout.ms` 指定了生产者在获取元数据（比如目标分区的首领是谁）时等待服务器返回响应的时间。如果等待响应超时，那么生产者要么重试发送数据，要么返回一个错误(抛出异常或执行回调）。`timeout.ms` 指定了 broker 等待同步副本返回消息确认的时间，与 acks 的配置相匹配——如果在指定时间内没有收到同步副本的确认，那么 broker 就会返回一个错误。

------

10. **max.block.ms**

该参数指定了在调用 `send()`方法或使用 `partitionFor()` 方法获取元数据时生产者的阻塞 时间。当生产者的发送缓冲区已满，或者没有可用的元数据时，这些方法就会阻塞。在阻塞时间达到 max.block.ms 时，生产者会抛出超时异常。

------

11. **max.request.size**

该参数用于控制生产者发送的请求大小。它可以指能发送的单个消息的最大值，也可以指单个请求里所有消息总的大小。例如，假设这个值为 1MB，那么可以发送的单个最大消息为 1MB，或者生产者可以在单个请求里发送一个批次，该批次包含了 1000 个消息，每个消息大小为 1KB。另外，broker 对可接收的消息最大值也有自己的限制（`message.max.bytes`)，所以两边的配置最好可以匹配，避免生产者发送的消息被 broker 拒绝。

------

12. **receive.buffer.bytes** 和 **send.buffer.bytes**

这两个参数分别指定了 TCP Socket 接收和发送数据包的缓冲区大小。如果它们被设为 -1，就使用操作系统的默认值。如果生产者或消费者与 broker 处于不同的数据中心，那么可以适当增大这些值，因为跨数据中心的网络一般都有比较高的延迟和比较低的带宽。


## 消费者实现


## 消费者

#### 消费者群组

消费者使用一个消费者组名(即 `group.id`)来标记自己，topic 的每条消息都只会被发送到每个订阅它的消费者组的一个消费者实例上。

所以消费者群组具有如下特点：

1. 一个 consumer group 可能有若干个 consumer 实例(一个 group 只有一个实例也是允许的)
2. 对于同一个 group 而言，topic 的每条消息只能被发送到 group 下的一个 consumer 实例上，同一个 group 中的 consumer 实例可以消费多个分区上的消息。
3. topic 消息可以被发送到多个 group 中。

![](../images/kafka_03.png)

##### 为什么需要 consumer group

consumer group 是用于实现高伸缩性、高容错性的 consumer 机制。group 组内多个 consumer 实例可以同时读取 Kafka 消息，而且一旦有某个 consumer 宕机了，consumer group 会立即将已崩溃 consumer 负责的分区转交给其他 consumer 来负责，从而保证整个 group 可以继续工作，不会丢失数据。

#### 消费者群组再均衡

消费者组再平衡(consumer group rebalance)本质上是一种协议，规定了一个 consumer group 下所有 consumer 如何达成一致来分配订阅 topic 的所有分区。

举个例子，假设我们有一个 consumer group，它有 20 个 consumer 实例。该 group 订阅了一个具有 100 个分区的 topic。那么正常情况下，consumer group 平均会为每个 consumer 分配 5 个分区，即每个 consumer 负责读取 5 个分区的数据。这个分配过程就被称作 rebalance。

什么时候触发消费者群组再均衡：

1. 当有新的消费者群组被创建
2. 当消费者群组中加入新的 consumer 实例
3. 当消费者群组中的 consumer 实例崩溃了
4. 当一个主题的分区数增加了

#### 代码示例

```java
Properties kafkaProps = new Properties();
// 消费者配置
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("group.id", "");  // 消费者群组
kafkaProps.put("key.deserializer", "");
kafkaProps.put("value.deserializer", "");

// 根据配置创建消费者对象
KafkaConsumer consumer = new KafkaConsumer(kafkaProps);

// 订阅主题，可以订阅多个主题
consumer.subscribe(Collections.SingletonList(""));

try {
    while(true) {
        /*
         * poll() 参数为超时时间
         * 如果该参数设置为 0，poll() 会立即返回，
         * 否则它会在指定的毫秒数内一直等待 broker 返回数据
         */
        ConsumerRecords records = consumer.poll(100);
        for(ConsumerRecords record : records) {
            // 业务逻辑
            record.topic();
            record.partition();
            record.offset();
            record.key();
            record.value();
        }
    }
} finally {
    consumer.close();
}

```

#### 消费者参数

1. **fetch.min.bytes**

该属性指定了消费者从服务器获取记录的最小字节数。broker 在收到消费者的数据请求时，如果可用的数据量小于 fetch.min.bytes 指定的大小，那么它会等到有足够的可用数据时才把它返回给消费者。这样可以降低消费者和 broker 的工作负载，因为它们在主题不是很活跃的时候（或者一天里的低谷时段）就不需要来来回回地处理消息。如果没有很多可用数据，但消费者的 CPU 使用率却很高，那么就需要把该属性的值设得比默认值大。如果消费者的数量比较多，把该属性的值设置得大一点可以降低 broker 的工作负载。

------

2. **fetch.max.wait.ms**

我们通过 fetch.min.bytes 告诉 Kafka，等到有足够的数据时才把它返回给消费者。而 fetch.max.wait.ms 则用于指定 broker 的等待时间， 默认是 500ms。如果没有足够的数据流入 Kafka， 消费者获取最小数据量的要求就得不到满足，最终导致 500ms 的延迟。如果要降低潜在的延迟， 可以把该参数值设置得小一些。如果 fetch.max.wait.ms 被设为 100ms， 并且 fetch.min.bytes 被设为 1MB， 那么 Kafka 在收到消费者的请求后， 要么返回 1MB 数据，要么在 100ms 后返回所有可用的数据，就看哪个条件先得到满足。

------

3. **max.partition.fetch.bytes**

该属性指定了服务器从每个分区里返回给消费者的最大字节数。它的默认值是 1MB，也就是说， KafkaConsumer.poll() 方法从每个分区里返回的记录最多不超过 max.partition.fetch.bytes 指定的字节。如果一个主题有 20 个分区和 5 个消费者，那么每个消费者需要至少 4MB 的可用内存来接收记录。在为消费者分配内存时，可以给它们多分配一些，因为如果群组里有消费者发生崩溃，剩下的消费者需要处理更多的分区。max.partition.fetch.bytes 的值必须比 broker 能够接收的最大消息的字节数（通过 `message.max.bytes` 属性配置）大，否则消费者可能无法读取这些消息，导致消费者一直挂起重试。在设置该属性时，另一个需要考虑的因素是消费者处理数据的时间。消费者需要频繁调用 poll() 方法来避免会话过期和发生分区再均衡，如果单次调用 poll() 返回的数据太多，消费者需要更多的时间来处理，可能无法及时进行下一个轮询来避免会话过期。如果出现这种情况，可以把 max.partition.fetch.bytes 值改小，或者延长会话过期时间。

------

4. **session.timeout.ms**

该属性指定了消费者在被认为死亡之前可以与服务器断开连接的时间，默认是 3s。如果消费者没有在 session.timeout.ms 指定的时间内发送心跳给群组协调器，就被认为已经死亡，协调器就会触发再均衡，把它的分区分配给群组里的其他消费者。该属性与 `heartbeat.interval.ms` 紧密相关。heartbeat.interval.ms 指定了 poll() 方法向协调器发送心跳的频率，session.timeout.ms 则指定了消费者可以多久不发送心跳。所以，一般需要同时修改这两个属性，heartbeat.interval.ms 必须比 session.timeout.ms 小。一般是 session.timeout.ms 的三分之一。如果 session.timeout.ms 是 3s，那么 heartbeat.interval.ms 应该是 1s。把 session.timeout.ms 值设得比默认值小，可以更快地检测和恢复崩溃的节点，不过长时间的轮询或垃圾收集可能导致非预期的再均衡。把该属性的值设置得大一些，可以减少意外的再均衡，不过检测节点崩溃需要更长的时间。

------

5. **auto.offset.reset**

该属性指定了消费者在读取一个没有偏移量的分区或者偏移量无效的情况下（因消费者长时间失效，包含偏移量的记录已经过时并被删除）该作何处理。它的默认值是 latest，意思是说，在偏移量无效的情况下，消费者将从最新的记录开始读取数据（在消费者启动之后生成的记录）。另一个值是 earliest，意思是说，在偏移量无效的情况下，消费者将从起始位置读取分区的记录。

------

6. **enable.auto.commit**

该属性指定了消费者是否自动提交偏移量，默认值是 true。为了尽量避免出现重复数据和数据丢失，可以把它设为 false，由自己控制何时提交偏移量。如果把它设为 true，还可以通过配置 `auto.commit.interval.ms` 属性来控制提交的频率。

------

7. **partition.assignment.strategy**

分区会被分配给群组里的消费者。PartitionAssignor 根据给定的消费者和主题，决定哪些分区应该被分配给哪个消费者。Kafka 有两个默认的分配策略。

* Range

该策略会把主题的若干个连续的分区分配给消费者。假设消费者 C1 和消费者 C2 同时订阅了主题 T1 和主题 T2，并且每个主题有 3 个分区。那么消费者 C1 有可能分配到这两个主题的分区 0 和分区 1，而消费者 C2 分配到这两个主题的分区 2。因为每个主题拥有奇数个分区，而分配是在主题内独立完成的，第一个消费者最后分配到比第二个消费者更多的分区。只要使用了 Range 策略，而且分区数量无法被消费者数量整除，就会出现这种情况。

* RoundRobin

该策略把主题的所有分区逐个分配给消费者。如果使用 RoundRobin 策略来给消费者 C1 和消费者 C2 分配分区，那么消费者 C1 将分到主题 T1 的分区 0 和分区 2 以及主题 T2 的分区 1，消费者 C2 将分配到主题 T1 的分区 1 以及主题 T2 的分区 0 和分区 2。一般来说，如果所有消费者都订阅相同的主题（这种情况很常见），RoundRobin 策略会给所有消费者分配相同数量的分区（或最多就差一个分区）。

可以通过设置 partition.assignment.strategy 来选择分区策略。 默认使用的是 
org. apache.kafka.clients.consumer.RangeAssignor， 这个类实现了 Range 策略，不过也可以把它改成 org.apache.kafka.clients.consumer.RoundRobinAssignor。我们还可以使用自定义策略，在这种情况下，partition.assignment.strategy 属性的值就是自定义类的名字。

------

8. **client.id**

该属性可以是任意字符串，broker 用它来标识从客户端发送过来的消息，通常被用在日志、度量指标和配额里。

------

9. **max.poll.records**

该属性用于控制单次调用 poll() 方法能够返回的记录数量，可以帮你控制在轮询里需要处理的数据量。

------

10. **receive.buffer.bytes** 和 **send.buffer.bytes**

socket 在读写数据时用到的 TCP 缓冲区也可以设置大小。如果它们被设为 -1，就使用操作系统的默认值。如果生产者或消费者与 broker 处于不同的数据中心内，可以适当增大这些值，因为跨数据中心的网络一般都有比较高的延迟和比较低的带宽。

#### 位移和位移提交

consumer 端需要为每个它要读取的分区保存消费进度，即分区中当前最新消费消息的位置。该位置就被称为位移(offset) 。consumer 需要定期地向 Kafka 提交自己的位置信息，实际上，这里的位移值通常是下一条待消费的消息的位置。总而言之，offset 就是 consumer 端维护的位置信息。

消费者消费分区消息涉及的相关位置信息：

![](../images/kafka_09.png)

* 上次提交位移( last committed offset )：consumer 最近一次提交的 offset 值。
* 当前位置( current position )：consumer 已读取但尚未提交时的位置。
* 水位( watermark )：也被称为高水位( highwatermark )，严格来说它不属于 consumer 管理的范围，而是属于分区日志的概念。对于处于水位之下的所有消息，consumer 都是可以读取的，consumer 无法读取水位以上的消息。
* 日志终端位移( Log End Offset，LEO )：也被称为日志最新位移。同样不属于 
consumer 范畴，而是属于分区日志管辖。它表示了某个分区副本当前保存消息对应的最大的位移值。值得注意的是，正常情况下 LEO 不会比水位值小。事实上，只有分区所有副本都保存了某条消息，该分区的 leader 副本才会向上移动水位值。

##### 位移提交

1. 自动提交，优点是方便，缺点是可能出现重复数据和数据丢失
2. 手动提交

**在处理当前获取到的消息之前提交偏移量**

```java
while(true) {
    ConsumerRecords records = consumer.poll(100);
    // 在处理当前获取到的消息之前提交偏移量
    consumer.commitSync();
    for(ConsumerRecords record : records) {
        // 业务逻辑
        record.topic();
        record.partition();
        record.offset();
        record.key();
        record.value();
    }
}
```

**在处理当前获取到的消息之后提交偏移量**

```java
while(true) {
    ConsumerRecords records = consumer.poll(100);
    for(ConsumerRecords record : records) {
        // 业务逻辑
        record.topic();
        record.partition();
        record.offset();
        record.key();
        record.value();
    }
    // 在处理当前获取到的消息之后提交偏移量
    consumer.commitSync();
}
```

**提交特定偏移量**

```java
Map<TopicPartition, OffsetAndMetadata> currentOffsets = new HashMap()
int count = 0;
while(true) {
    ConsumerRecords records = consumer.poll(100);
    for(ConsumerRecords record : records) {
        currentOffsets.put(
            new TopicPartition(record.topic(), record.partition()),
            new OffsetAndMetadata(record.offset() + 1, "no metadata")
        );
        if (count % 2 == 0) {
            consumer.commitSync(currentOffsets, null);
        }

        // 业务逻辑
        record.topic();
        record.partition();
        record.offset();
        record.key();
        record.value();

        count++;
    }
}

// 或者

Map<TopicPartition, OffsetAndMetadata> currentOffsets = new HashMap()
int count = 0;
while(true) {
    ConsumerRecords records = consumer.poll(100);
    for(ConsumerRecords record : records) {
        currentOffsets.put(
            new TopicPartition(record.topic(), record.partition()),
            new OffsetAndMetadata(record.offset() + 1, "no metadata")
        );
        // 业务逻辑
        record.topic();
        record.partition();
        record.offset();
        record.key();
        record.value();

        if (count % 2 == 0) {
            consumer.commitSync(currentOffsets, null);
        }
        count++;
    }
}

```

**异步提交**
上述提交采用的都是同步提交的方式，都可以改成异步提交的方式。

```java
class OffsetCommitCallback() {
    //提交成功或者抛出异常时进行调用
    public void onComplete(Map<TopicPartition, OffsetAndMetadata> offsets, Exception e) {
        //
    }
}

while(true) {
    ConsumerRecords records = consumer.poll(100);
    for(ConsumerRecords record : records) {
        // 业务逻辑
        record.topic();
        record.partition();
        record.offset();
        record.key();
        record.value();
    }
    // 在处理当前获取到的消息之后异步提交偏移量
    consumer.commitAsync(new OffsetCommitCallback());
}

```

**同步提交与异步提交相结合**

```java
class OffsetCommitCallback() {
    //提交成功或者抛出异常时进行调用
    public void onComplete(Map<TopicPartition, OffsetAndMetadata> offsets, Exception e) {
        //
    }
}

try {
    while(true) {
        ConsumerRecords records = consumer.poll(100);
        for(ConsumerRecords record : records) {
            // 业务逻辑
            record.topic();
            record.partition();
            record.offset();
            record.key();
            record.value();
        }
        // 在处理当前获取到的消息之后异步提交偏移量
        consumer.commitAsync(new OffsetCommitCallback());
    }
} catch (Exception e) {
    //
} finally {
    try {
        //最后同步提交
        consumer.commitSync();
    } finally {
        consumer.close();
    }
}

```

#### 消费者群组再均衡时监听和回调

```java
Properties kafkaProps = new Properties();
// 消费者配置
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("group.id", "");  // 消费者群组
kafkaProps.put("key.deserializer", "");
kafkaProps.put("value.deserializer", "");

// 根据配置创建消费者对象
KafkaConsumer consumer = new KafkaConsumer(kafkaProps);

class HandleRebalance implements ConsumerRebalanceListener {
    // 消费者停止读取消息之后和再均衡开始之前调用
    public void onPartitionsAssigned(Collections<TopicPartition> partitions) {
        //
    }

    // 重新分配分区之后和消费者开始读取消息之前调用
    publoc void onPartitionsRevoked(Collections<TopicPartition> partitions) {
        //
    }
}

// 订阅主题，可以订阅多个主题
consumer.subscribe(Collections.SingletonList(""), new HandleRebalance());

try {
    while(true) {
        ConsumerRecords records = consumer.poll(100);
        for(ConsumerRecords record : records) {
            // 业务逻辑
            record.topic();
            record.partition();
            record.offset();
            record.key();
            record.value();
        }
    }
} finally {
    consumer.close();
}

```


#### 从特定的偏移量开始读取数据

使用 poll() 方法从分区获取数据时，broker 都是从上次提交位移之后的位置返回一定数量的消息，使用如下三个方法可以从特定的偏移量开始读取数据。

* `consumer.seekToBeginning(Collection<TopicPartition> tp)` 从分区起始位置开始读取消息
* `consumer.seekToEndllection<TopicPartition> tp)` 从分区末尾开始读取消息
* `consumer.seek(partition, offset)` 从指定位置开始读取消息

例如：重新分配分区之后和消费者开始读取消息之前，调用 `consumer.seek(partition, offset)` 从偏移量为 5 的位置开始读取消息，示例代码如下：

```java
Properties kafkaProps = new Properties();
// 消费者配置
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("group.id", "");  // 消费者群组
kafkaProps.put("key.deserializer", "");
kafkaProps.put("value.deserializer", "");

// 根据配置创建消费者对象
KafkaConsumer consumer = new KafkaConsumer(kafkaProps);

class HandleRebalance implements ConsumerRebalanceListener {
    // 消费者停止读取消息之后和再均衡开始之前调用
    public void onPartitionsAssigned(Collections<TopicPartition> partitions) {
        //
    }

    // 重新分配分区之后和消费者开始读取消息之前调用
    publoc void onPartitionsRevoked(Collections<TopicPartition> partitions) {
        for(TopicPartition partition: partitions) {
            consumer.seek(partition, 5)
        }
    }
}

// 订阅主题，可以订阅多个主题
consumer.subscribe(Collections.SingletonList(""), new HandleRebalance());

try {
    while(true) {
        ConsumerRecords records = consumer.poll(100);
        for(ConsumerRecords record : records) {
            // 业务逻辑
            record.topic();
            record.partition();
            record.offset();
            record.key();
            record.value();
        }
    }
} finally {
    consumer.close();
}

```

