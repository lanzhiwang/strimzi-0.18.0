Properties kafkaProps = new Properties();
// 生产者配置
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("key.serializer", "");
kafkaProps.put("value.serializer", "");

// 根据配置创建生产者对象
KafkaProducer producer = new KafkaProducer(kafkaProps);

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
} finally {
    // 最后关闭生产者对象
    producer.close()

}


////////////////////////////////////////////////




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