# 6.6 Monitoring

- Monitoring
    - Selector Monitoring
    - Common Node Monitoring
    - Producer Monitoring
    - Consumer Monitoring
    - Connect Monitoring
    - Streams Monitoring
    - Others

Kafka uses Yammer Metrics for metrics reporting in the server. The Java clients use Kafka Metrics, a built-in metrics registry that minimizes transitive dependencies pulled into client applications. Both expose metrics via JMX and can be configured to report stats using pluggable stats reporters to hook up to your monitoring system.  Kafka 使用 Yammer Metrics 在服务器中报告指标。 Java 客户端使用 Kafka Metrics，这是一个内置的指标注册表，可以最大限度地减少引入客户端应用程序的传递依赖关系。 两者都通过 JMX 公开指标，并且可以配置为使用可插拔的统计报告器来报告统计数据，以连接到您的监控系统。

All Kafka rate metrics have a corresponding cumulative count metric with suffix `-total`. For example, `records-consumed-rate` has a corresponding metric named `records-consumed-total`.  所有 Kafka 速率指标都有一个相应的累积计数指标，后缀为 -total。 例如，records-consumed-rate 有一个对应的度量，名为records-consumed-total。

The easiest way to see the available metrics is to fire up jconsole and point it at a running kafka client or server; this will allow browsing all metrics with JMX.  查看可用指标的最简单方法是启动 jconsole 并将其指向正在运行的 kafka 客户端或服务器； 这将允许使用 JMX 浏览所有指标。

## Security Considerations for Remote Monitoring using JMX

Apache Kafka disables remote JMX by default. You can enable remote monitoring using JMX by setting the environment variable `JMX_PORT` for processes started using the CLI or standard Java system properties to enable remote JMX programmatically. You must enable security when enabling remote JMX in production scenarios to ensure that unauthorized users cannot monitor or control your broker or application as well as the platform on which these are running. Note that authentication is disabled for JMX by default in Kafka and security configs must be overridden for production deployments by setting the environment variable `KAFKA_JMX_OPTS` for processes started using the CLI or by setting appropriate Java system properties. See [Monitoring and Management Using JMX Technology](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html") for details on securing JMX.  Apache Kafka 默认禁用远程 JMX。 您可以通过为使用 CLI 或标准 Java 系统属性启动的进程设置环境变量 JMX_PORT 以编程方式启用远程 JMX 来启用使用 JMX 的远程监控。 在生产场景中启用远程 JMX 时，您必须启用安全性，以确保未经授权的用户无法监视或控制您的代理或应用程序以及运行它们的平台。 请注意，Kafka 中默认禁用 JMX 身份验证，并且必须通过为使用 CLI 启动的进程设置环境变量 KAFKA_JMX_OPTS 或设置适当的 Java 系统属性来覆盖生产部署的安全配置。 有关保护 JMX 的详细信息，请参阅使用 JMX 技术进行监控和管理。

We do graphing and alerting on the following metrics:  我们对以下指标进行绘图和警报：

| DESCRIPTION 描述 | MBEAN NAME  MBean 名称 | NORMAL VALUE  正常值 |
| ---- | ---- | ---- |
|      |      |      |

* Message in rate  消息率
* Byte in rate from clients  来自客户的字节速率
* Byte in rate from other brokers  来自其他经纪人的字节率
* Request rate  请求率
* Error rate  错误率
* Request size in bytes  请求大小（以字节为单位）
* Temporary memory size in bytes  临时内存大小（以字节为单位）
* Message conversion time  消息转换时间
* Message conversion rate  消息转化率
* Byte out rate to clients  给客户的字节输出率
* Byte out rate to other brokers 其他经纪商的字节输出率
* Message validation failure rate due to no key specified for compacted topic  由于没有为压缩主题指定密钥，消息验证失败率
* Message validation failure rate due to invalid magic number  无效幻数导致的消息验证失败率
* Message validation failure rate due to incorrect crc checksum  由于不正确的 crc 校验和导致的消息验证失败率
* Message validation failure rate due to non-continuous offset or sequence number in batch  由于批量不连续偏移或序列号导致的消息验证失败率
* Log flush rate and time  日志刷新率和时间
* of under replicated partitions (the number of non-reassigning replicas - the number of ISR > 0)  复制不足的分区（非重新分配副本的数量 - ISR 的数量 > 0）
* of under minIsr partitions (\|ISR\| < min.insync.replicas)  在 minIsr 分区下 (\|ISR\| < min.insync.replicas)
* of at minIsr partitions (\|ISR\| = min.insync.replicas)  在 minIsr 分区 (\|ISR\| = min.insync.replicas)
* of offline log directories  离线日志目录
* Is controller active on broker  控制器是否在代理上处于活动状态
* Leader election rate  领袖选举率
* Unclean leader election rate  不洁领导人选举率
* Pending topic deletes  待删除的主题
* Pending replica deletes  待删除的副本
* Ineligible pending topic deletes  不合格的待处理主题删除
* Ineligible pending replica deletes  不合格的挂起副本删除
* Partition counts  分区计数
* Leader replica counts  领导者副本数
* ISR shrink rate  ISR 收缩率
* ISR expansion rate  ISR 扩展率
* Max lag in messages btw follower and leader replicas  消息 btw 跟随者和领导者副本的最大滞后
* Lag in messages per follower replica  每个追随者副本的消息滞后
* Requests waiting in the producer purgatory  在生产者炼狱中等待的请求
* Requests waiting in the fetch purgatory  在提取炼狱中等待的请求
* Request total time  请求总时间
* Time the request waits in the request queue  请求在请求队列中等待的时间
* Time the request is processed at the leader  在leader处理请求的时间
* Time the request waits for the follower  请求等待跟随者的时间
* Time the request waits in the response queue  请求在响应队列中等待的时间
* Time to send the response  发送响应的时间
* Number of messages the consumer lags behind the producer by. Published by the consumer, not broker.   消费者落后于生产者的消息数。由消费者而非经纪人发布。
* The average fraction of time the network processors are idle  网络处理器空闲的平均时间比例
* The number of connections disconnected on a processor due to a client not re-authenticating and then using the connection beyond its expiration time for anything other than re-authentication  由于客户端未重新进行身份验证，然后在过期时间之外使用该连接进行除重新身份验证之外的任何其他操作而在处理器上断开的连接数
* The total number of connections disconnected, across all processors, due to a client not re-authenticating and then using the connection beyond its expiration time for anything other than re-authentication  由于客户端未重新进行身份验证，然后在过期时间之外使用连接进行除重新身份验证之外的任何其他操作，所有处理器中断开的连接总数
* The average fraction of time the request handler threads are idle  请求处理线程空闲的平均时间比例
* Bandwidth quota metrics per (user, client-id), user or client-id  每个（用户、客户端 ID）、用户或客户端 ID 的带宽配额指标
* Request quota metrics per (user, client-id), user or client-id  请求每个（用户、客户端 ID）、用户或客户端 ID 的配额指标
* Requests exempt from throttling  请求免于限制
* ZooKeeper client request latency  ZooKeeper 客户端请求延迟
* ZooKeeper connection status  ZooKeeper 连接状态
* Max time to load group metadata  加载组元数据的最长时间
* Avg time to load group metadata  加载组元数据的平均时间
* Max time to load transaction metadata  加载交易元数据的最长时间
* Avg time to load transaction metadata  加载事务元数据的平均时间
* Number of reassigning partitions  重新分配分区的数量
* Outgoing byte rate of reassignment traffic  重新分配流量的传出字节率
* Incoming byte rate of reassignment traffic  重新分配流量的传入字节率



## Common monitoring metrics for producer consumer connect streams

The following metrics are available on producer/consumer/connector/streams instances. For specific metrics, please see following sections.  以下指标可用于生产者/消费者/连接器/流实例。 有关具体指标，请参阅以下部分。

| METRIC/ATTRIBUTE NAME  指标/属性名称 | DESCRIPTION 描述 | MBEAN NAME |
| ---------------------------------- | --------------- | ---------- |
| | |


* Connections closed per second in the window.  窗口中每秒关闭的连接数。
* Total connections closed in the window.  窗口中关闭的连接总数。
* New connections established per second in the window.  每秒在窗口中建立新的连接。
* Total new connections established in the window.  在窗口中建立的新连接总数。
* The average number of network operations (reads or writes) on all connections per second.  每秒所有连接上的平均网络操作（读取或写入）数。
* The total number of network operations (reads or writes) on all connections.  所有连接上的网络操作（读取或写入）总数。
* The average number of outgoing bytes sent per second to all servers.  每秒发送到所有服务器的平均传出字节数。
* The total number of outgoing bytes sent to all servers.  发送到所有服务器的传出字节总数。
* The average number of requests sent per second.  每秒发送的平均请求数。
* The total number of requests sent.  发送的请求总数。
* The average size of all requests in the window.  窗口中所有请求的平均大小。
* The maximum size of any request sent in the window.  在窗口中发送的任何请求的最大大小。
* Bytes/second read off all sockets.  字节/秒读取所有套接字。
* Total bytes read off all sockets.  从所有套接字读取的总字节数。
* Responses received per second.  每秒收到的响应。
* Total responses received.  收到的回复总数。
* Number of times the I/O layer checked for new I/O to perform per second.  I/O 层每秒检查新 I/O 执行的次数。
* Total number of times the I/O layer checked for new I/O to perform.  I/O 层检查新 I/O 执行的总次数。
* The average length of time the I/O thread spent waiting for a socket ready for reads or writes in nanoseconds.  I/O 线程等待套接字准备好读取或写入所花费的平均时间长度（以纳秒为单位）。
* The fraction of time the I/O thread spent waiting.  I/O 线程等待的时间比例。
* The average length of time for I/O per select call in nanoseconds.  每个选择调用的平均 I/O 时间长度（以纳秒为单位）。
* The fraction of time the I/O thread spent doing I/O.  I/O 线程花费在 I/O 上的时间比例。
* The current number of active connections.  当前活动连接数。
* Connections per second that were successfully authenticated using SASL or SSL.  使用 SASL 或 SSL 成功验证的每秒连接数。
* Total connections that were successfully authenticated using SASL or SSL.  使用 SASL 或 SSL 成功验证的连接总数。
* Connections per second that failed authentication.  认证失败的每秒连接数。
* Total connections that failed authentication.  认证失败的连接总数。
* Connections per second that were successfully re-authenticated using SASL.  使用 SASL 成功重新验证的每秒连接数。
* Total connections that were successfully re-authenticated using SASL.  使用 SASL 成功重新验证的连接总数。
* The maximum latency in ms observed due to re-authentication.  由于重新验证而观察到的最大延迟（以毫秒为单位）。
* The average latency in ms observed due to re-authentication.  由于重新验证而观察到的平均延迟（以毫秒为单位）。
* Connections per second that failed re-authentication.  重新认证失败的每秒连接数。
* Total connections that failed re-authentication.  重新认证失败的连接总数。
* Total connections that were successfully authenticated by older, pre-2.2.0 SASL clients that do not support re-authentication. May only be non-zero  由不支持重新验证的较旧的 2.2.0 之前的 SASL 客户端成功验证的连接总数。只能是非零



## Common Per-broker metrics for producer consumer connect streams

The following metrics are available on producer/consumer/connector/streams instances. For specific metrics, please see following sections.

* The average number of outgoing bytes sent per second for a node.  一个节点每秒发送的平均传出字节数。
* The total number of outgoing bytes sent for a node.  为节点发送的传出字节总数。
* The average number of requests sent per second for a node.  一个节点每秒发送的平均请求数。
* The total number of requests sent for a node.  为一个节点发送的请求总数。
* The average size of all requests in the window for a node.  一个节点窗口中所有请求的平均大小。
* The maximum size of any request sent in the window for a node.  在窗口中为节点发送的任何请求的最大大小。
* The average number of bytes received per second for a node.  节点每秒接收的平均字节数。
* The total number of bytes received for a node. 节点接收的总字节数。
* The average request latency in ms for a node.  节点的平均请求延迟（以毫秒为单位）。
* The maximum request latency in ms for a node.  节点的最大请求延迟（以毫秒为单位）。
* Responses received per second for a node.  节点每秒收到的响应。
* Total responses received for a node.  一个节点收到的总响应。


## Producer monitoring

The following metrics are available on producer instances.

* The number of user threads blocked waiting for buffer memory to enqueue their records.
* The maximum amount of buffer memory the client can use (whether or not it is currently used).
* The total amount of buffer memory that is not being used (either unallocated or in the free list).
* The fraction of time an appender waits for space allocation.

### Producer Sender Metrics

* The average number of bytes sent per partition per-request.  每个分区每个请求发送的平均字节数。
* The max number of bytes sent per partition per-request.  每个分区每个请求发送的最大字节数。
* The average number of batch splits per second  每秒批处理的平均分裂次数
* The total number of batch splits  批量拆分的总数
* The average compression rate of record batches.  记录批次的平均压缩率。
* The age in seconds of the current producer metadata being used.  当前正在使用的生产者元数据的时间（以秒为单位）。
* The average time in ms a request was throttled by a broker  请求被代理限制的平均时间（以毫秒为单位）
* The maximum time in ms a request was throttled by a broker 请求被代理限制的最长时间（以毫秒为单位）
* The average per-second number of record sends that resulted in errors  导致错误的平均每秒记录发送数
* The total number of record sends that resulted in errors  导致错误的记录发送总数
* The average time in ms record batches spent in the send buffer.  在发送缓冲区中花费的记录批次的平均时间（以毫秒为单位）。
* The maximum time in ms record batches spent in the send buffer.  在发送缓冲区中花费的记录批次的最长时间（以毫秒为单位）。
* The average per-second number of retried record sends  平均每秒重试记录发送次数
* The total number of retried record sends  重试记录发送总数
* The average number of records sent per second.  每秒发送的平均记录数。
* The total number of records sent.  发送的记录总数。
* The average record size  平均记录大小
* The maximum record size  最大记录大小
* The average number of records per request.  每个请求的平均记录数。
* The average request latency in ms  以毫秒为单位的平均请求延迟
* The maximum request latency in ms  以毫秒为单位的最大请求延迟
* The current number of in-flight requests awaiting a response.  当前等待响应的进行中请求数。
* The average number of bytes sent per second for a topic.  主题每秒发送的平均字节数。
* The total number of bytes sent for a topic.  为一个主题发送的总字节数。
* The average compression rate of record batches for a topic.  一个主题的记录批次的平均压缩率。
* The average per-second number of record sends that resulted in errors for a topic  导致主题错误的记录发送的平均每秒数量
* The total number of record sends that resulted in errors for a topic  导致主题错误的记录发送总数
* The average per-second number of retried record sends for a topic  为一个主题发送的平均每秒重试记录数
* The total number of retried record sends for a topic  为一个主题发送的重试记录总数
* The average number of records sent per second for a topic.  一个主题每秒发送的平均记录数。
* The total number of records sent for a topic.  为一个主题发送的记录总数。


## consumer monitoring

The following metrics are available on consumer instances.

* The average delay between invocations of poll().  调用 poll() 之间的平均延迟。
* The max delay between invocations of poll().  调用 poll() 之间的最大延迟。
* The number of seconds since the last poll() invocation.  自上次 poll() 调用以来的秒数。
* The average fraction of time the consumer's poll() is idle as opposed to waiting for the user code to process records.  消费者的 poll() 空闲时间的平均分数，而不是等待用户代码处理记录。 


### Consumer Group Metrics

* The average time taken for a commit request  提交请求的平均时间
* The max time taken for a commit request  提交请求所花费的最长时间
* The number of commit calls per second  每秒提交调用次数
* The total number of commit calls  提交调用的总数
* The number of partitions currently assigned to this consumer  当前分配给该消费者的分区数
* The max time taken to receive a response to a heartbeat request  收到对心跳请求的响应所花费的最长时间
* The average number of heartbeats per second  平均每秒心跳次数
* The total number of heartbeats  心跳总数
* The average time taken for a group rejoin  一个组重新加入的平均时间
* The max time taken for a group rejoin  重新加入群组所需的最长时间
* The number of group joins per second  每秒加入的组数
* The total number of group joins  群组加入总数
* The average time taken for a group sync  组同步所需的平均时间
* The max time taken for a group sync  组同步所需的最长时间
* The number of group syncs per second  每秒组同步数
* The total number of group syncs  群组同步总数
* The average time taken for a group rebalance  组重新平衡所需的平均时间
* The max time taken for a group rebalance  组重新平衡所需的最长时间
* The total time taken for group rebalances so far  到目前为止组重新平衡所用的总时间
* The total number of group rebalances participated  参与的组再平衡总数
* The number of group rebalance participated per hour  每小时参与的组再平衡次数
* The total number of failed group rebalances  失败的组重新平衡总数
* The number of failed group rebalance event per hour  每小时失败的组重新平衡事件数
* The number of seconds since the last rebalance event  自上次重新平衡事件以来的秒数
* The number of seconds since the last controller heartbeat  自上次控制器心跳以来的秒数
* The average time taken by the on-partitions-revoked rebalance listener callback  分区上撤销的重新平衡侦听器回调所花费的平均时间
* The max time taken by the on-partitions-revoked rebalance listener callback  分区上撤销的重新平衡侦听器回调所花费的最长时间
* The average time taken by the on-partitions-assigned rebalance listener callback  分区上分配的重新平衡侦听器回调所花费的平均时间
* The max time taken by the on-partitions-assigned rebalance listener callback  分区上分配的重新平衡侦听器回调所花费的最长时间
* The average time taken by the on-partitions-lost rebalance listener callback  on-partitions-lost 重新平衡监听器回调所花费的平均时间
* The max time taken by the on-partitions-lost rebalance listener callback  on-partitions-lost 重新平衡侦听器回调所花费的最长时间


### Consumer Fetch Metrics

* The average number of bytes consumed per second  平均每秒消耗的字节数
* The total number of bytes consumed  消耗的总字节数
* The average time taken for a fetch request.  获取请求所用的平均时间。
* The max time taken for any fetch request.  任何获取请求所花费的最长时间。
* The number of fetch requests per second.  每秒获取请求的数量。
* The average number of bytes fetched per request  每个请求获取的平均字节数
* The maximum number of bytes fetched per request  每个请求获取的最大字节数
* The average throttle time in ms  平均油门时间（ms）
* The maximum throttle time in ms  最大油门时间（ms）
* The total number of fetch requests.  获取请求的总数。
* The average number of records consumed per second  平均每秒消耗的记录数
* The total number of records consumed  消耗的记录总数
* The maximum lag in terms of number of records for any partition in this window  此窗口中任何分区在记录数方面的最大滞后
* The minimum lead in terms of number of records for any partition in this window  此窗口中任何分区的记录数的最小领先
* The average number of records in each request  每个请求的平均记录数
* The average number of bytes consumed per second for a topic  一个主题每秒消耗的平均字节数
* The total number of bytes consumed for a topic  一个主题消耗的总字节数
* The average number of bytes fetched per request for a topic  每个主题请求获取的平均字节数
* The maximum number of bytes fetched per request for a topic  每个主题请求获取的最大字节数
* The average number of records consumed per second for a topic  一个主题每秒平均消耗的记录数
* The total number of records consumed for a topic  一个主题消耗的记录总数
* The average number of records in each request for a topic  每个主题请求的平均记录数
* The current read replica for the partition, or -1 if reading from leader  分区的当前只读副本，如果从领导者读取，则为 -1
* The latest lag of the partition  分区的最新滞后
* The average lag of the partition  分区的平均滞后
* The max lag of the partition  分区的最大滞后
* The latest lead of the partition  分区的最新领先
* The average lead of the partition  分区的平均铅
* The min lead of the partition  分区的最小导程


## Connect Monitoring


## Streams Monitoring


## Others

We recommend monitoring GC time and other stats and various server stats such as CPU utilization, I/O service time, etc. On the client side, we recommend monitoring the message/byte rate (global and per topic), request rate/size/time, and on the consumer side, max lag in messages among all partitions and min fetch request rate. For a consumer to keep up, max lag needs to be less than a threshold and min fetch rate needs to be larger than 0.  我们建议监控 GC 时间和其他统计信息以及各种服务器统计信息，例如 CPU 利用率、I/O 服务时间等。在客户端，我们建议监控消息/字节率（全局和每个主题）、请求率/大小/ 时间，在消费者方面，所有分区之间消息的最大滞后和最小获取请求率。 为了让消费者跟上，最大滞后需要小于阈值，最小提取率需要大于 0。


