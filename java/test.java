

private Properties kafkaProps = new Properties();
kafkaProps.put("bootstrap.servers", "");
kafkaProps.put("group.id", "");  // 消费者群组
kafkaProps.put("key.deserializer", "");
kafkaProps.put("value.deserializer", "");


private class OffsetCommitCallback(){
    public void onComplete(Map<TopicPartition, OffsetAndMetadata> offsets, Exception e){
        //
    }
}

Map<TopicPartition, OffsetAndMetadata> currentOffsets = new HashMap()
int count = 0;

private class HandleRebalance implements ConsumerRebalanceListener {
    //消费者停止读取消息之后和再均衡开始之前调用
    public void onPartitionsAssigned(Collections<TopicPartition> partitions) {
        //
    }

    // 重新分配分区之后和消费者开始读取消息之前调用
    publoc void onPartitionsRevoked(Collections<TopicPartition> partitions) {
        //
    }
}


KafkaConsumer consumer = new KafkaConsumer(kafkaProps);

// 订阅主题，可以订阅多个主题
consumer.subscribe(Collections.SingletonList(""), new HandleRebalance());

try {
    while(true) {
        // 超时时间，如果该参数设置为 0，poll() 会立即返回，否则它会在指定的毫秒数内一直等待 broker 返回数据
        ConsumerRecords records = consumer.poll(100);
        for(ConsumerRecords record : records){
            // 业务逻辑
            record.topic();
            record.partition();
            record.offset();
            record.key();
            record.value();

            currentOffsets.put(
                new TopicPartition(record.topic(), record.partition()),
                new OffsetAndMetadata(record.offset() + 1, "no metadata")
            );
            if (count % 1000 == 0) {
                consumer.commitAsync(currentOffsets, null)
                // consumer.commitSync(currentOffsets, null)
            }
            count++;

        }

    }
} catch (Exception e) {
    //
} finally {
    try {
        consumer.commitSync();
    } finally {
        consumer.close();
    }
}



