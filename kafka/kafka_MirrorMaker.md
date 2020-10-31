
# KafkaMirrorMaker

kafka-mirror-maker.sh 常见参数

* --whitelist
指定一个正则表达式，指定拷贝源集群中的哪些 topic。比如 a|b 表示拷贝源集群上两个 topic 的数据 a 和 b。注意，当使用新版本 consumer 时必须指定该参数。

* --abort.on.send.failure
若设置为 true，当发送失败时则关闭 MirrorMaker。

* --consumer.config
指定 MirrorMaker 下 consumer 的属性文件。至少要在文件中指定 bootstrap.servers。

* --producer.config
指定 MirrorMaker 下 producer 的属性文件。

* --consumer.rebalance.listener
指定 MirrorMaker 使用的 consumer rebalance 监听器类。

* --rebalance.listener.args
指定 MirrorMaker 使用的 consumer rebalance 监听器的参数，与 consumer.rebalance.listener 一同使用。

* --message.handler
指定消息处理器类。消息处理器在 consumer 获取消息与 producer 发送消息之间被调用。

* --message.handler.args
指定消息处理器类的参数，与 message.handler 一同使用。

* --num.streams
指定 MirrorMaker 线程数。默认值是 1，即启动一个线程执行数据拷贝。

* --offset.commit.interval.ms
设定 MirrorMaker 位移提交间隔，默认值是 1 分钟。


现在在 k1上创建一个测试 topic：

```bash
$ bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic test --partitions 1 --replication-factor 1
Created topic "test".

```

consumer.properties

```
bootstrap.servers=localhost:9092
client.id=mm1.k1Andk2
group.id=mm1.k1Andk2.consumer
partition.assignment.strategy=org.apache.kafka.clients.consumer.RoundRob
```

producer.properties

```
bootstrap.servers=localhost:9092
client.id=mm1.k1Andk2
```

```bash
kafka-mirror-maker.sh --consumer.config consumer.properties --producer.config producer.properties --whitelist test

```





