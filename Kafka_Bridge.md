# Strimzi Kafka Bridge Documentation (0.19.0)

# [Strimzi HTTP Bridge for Apache Kafka](https://strimzi.io/docs/bridge/0.19.0/#api_reference-book)

## [1. Overview](https://strimzi.io/docs/bridge/0.19.0/#_overview)

The Strimzi HTTP Bridge for Apache Kafka provides a REST API for integrating HTTP based client applications with a Kafka cluster. You can use the API to create and manage consumers and send and receive records over HTTP rather than the native Kafka protocol.

### [1.1. Version information](https://strimzi.io/docs/bridge/0.19.0/#version_information)

*Version* : 0.1.0

### [1.2. Contact information](https://strimzi.io/docs/bridge/0.19.0/#contact_information)

*Contact Email* : [cncf-strimzi-dev@lists.cncf.io](mailto:cncf-strimzi-dev@lists.cncf.io)

### [1.3. License information](https://strimzi.io/docs/bridge/0.19.0/#license_information)

*License* : Apache 2.0
*License URL* : http://www.apache.org/licenses/LICENSE-2.0.html
*Terms of service* : http://swagger.io/terms/

### [1.4. URI scheme](https://strimzi.io/docs/bridge/0.19.0/#uri_scheme)

*Host* : bridge.swagger.io
*BasePath* : /
*Schemes* : HTTP

### [1.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags)

- Consumers : Consumer operations to create consumers in your Kafka cluster and perform common actions, such as subscribing to topics, retrieving processed records, and committing offsets.
- Producer : Producer operations to send records to a specified topic or topic partition.
- Seek : Seek operations that enable a consumer to begin receiving messages from a given offset position.
- Topics : Topic operations to send messages to a specified topic or topic partition, optionally including message keys in requests. You can also retrieve topics and topic metadata.

### [1.6. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes)

- `application/json`

### [1.7. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces)

- `application/json`

### [1.8. External Docs](https://strimzi.io/docs/bridge/0.19.0/#external_docs)

*Description* : Find out more about the Strimzi HTTP Bridge
*URL* : https://strimzi.io/documentation/

## [2. Definitions](https://strimzi.io/docs/bridge/0.19.0/#_definitions)

### [2.1. AssignedTopicPartitions](https://strimzi.io/docs/bridge/0.19.0/#_assignedtopicpartitions)

*Type* : < string, < integer (int32) > array > map

### [2.2. BridgeInfo](https://strimzi.io/docs/bridge/0.19.0/#_bridgeinfo)

Information about Kafka Bridge instance.

| Name                          | Schema |
| :---------------------------- | :----- |
| **bridge_version** *optional* | string |

### [2.3. Consumer](https://strimzi.io/docs/bridge/0.19.0/#_consumer)

| Name                                       | Description                                                  | Schema  |
| :----------------------------------------- | :----------------------------------------------------------- | :------ |
| **auto.offset.reset** *optional*           | Resets the offset position for the consumer. If set to `earliest`, messages are read from the first offset. If set to `latest`, messages are read from the latest offset. | string  |
| **consumer.request.timeout.ms** *optional* | Sets the maximum amount of time, in milliseconds, for the consumer to wait for messages for a request. If the timeout period is reached without a response, an error is returned. | integer |
| **enable.auto.commit** *optional*          | If set to `true`, message offsets are committed automatically for the consumer. If set to `false`, message offsets must be committed manually. | boolean |
| **fetch.min.bytes** *optional*             | Sets the minimum ammount of data, in bytes, for the consumer to receive. The broker waits until the data to send exceeds this amount. | integer |
| **format** *optional*                      | The allowable message format for the consumer, which can be `binary` (default) or `json`. The messages are converted into a JSON format. | string  |
| **name** *optional*                        | The unique name for the consumer instance. The name is unique within the scope of the consumer group. The name is used in URLs. | string  |

### [2.4. ConsumerRecord](https://strimzi.io/docs/bridge/0.19.0/#_consumerrecord)

| Name                     | Schema                                                       |
| :----------------------- | :----------------------------------------------------------- |
| **headers** *optional*   | [KafkaHeaderList](https://strimzi.io/docs/bridge/0.19.0/#_kafkaheaderlist) |
| **key** *optional*       | string                                                       |
| **offset** *optional*    | integer (int64)                                              |
| **partition** *optional* | integer (int32)                                              |
| **topic** *optional*     | string                                                       |
| **value** *optional*     | string                                                       |

### [2.5. ConsumerRecordList](https://strimzi.io/docs/bridge/0.19.0/#_consumerrecordlist)

*Type* : < [ConsumerRecord](https://strimzi.io/docs/bridge/0.19.0/#_consumerrecord) > array

### [2.6. CreatedConsumer](https://strimzi.io/docs/bridge/0.19.0/#_createdconsumer)

| Name                       | Description                                                  | Schema |
| :------------------------- | :----------------------------------------------------------- | :----- |
| **base_uri** *optional*    | Base URI used to construct URIs for subsequent requests against this consumer instance.  基本URI，用于构造针对此使用者实例的后续请求的URI。 | string |
| **instance_id** *optional* | Unique ID for the consumer instance in the group.            | string |

### [2.7. Error](https://strimzi.io/docs/bridge/0.19.0/#_error)

| Name                      | Schema          |
| :------------------------ | :-------------- |
| **error_code** *optional* | integer (int32) |
| **message** *optional*    | string          |

### [2.8. KafkaHeader](https://strimzi.io/docs/bridge/0.19.0/#_kafkaheader)

| Name                 | Description                                                  | Schema        |
| :------------------- | :----------------------------------------------------------- | :------------ |
| **key** *required*   |                                                              | string        |
| **value** *required* | The header value in binary format, base64-encoded **Pattern** : `"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"` | string (byte) |

### [2.9. KafkaHeaderList](https://strimzi.io/docs/bridge/0.19.0/#_kafkaheaderlist)

*Type* : < [KafkaHeader](https://strimzi.io/docs/bridge/0.19.0/#_kafkaheader) > array

### [2.10. OffsetCommitSeek](https://strimzi.io/docs/bridge/0.19.0/#_offsetcommitseek)

| Name                     | Schema          |
| :----------------------- | :-------------- |
| **offset** *required*    | integer (int64) |
| **partition** *required* | integer (int32) |
| **topic** *required*     | string          |

### [2.11. OffsetCommitSeekList](https://strimzi.io/docs/bridge/0.19.0/#_offsetcommitseeklist)

| Name                   | Schema                                                       |
| :--------------------- | :----------------------------------------------------------- |
| **offsets** *optional* | < [OffsetCommitSeek](https://strimzi.io/docs/bridge/0.19.0/#_offsetcommitseek) > array |

### [2.12. OffsetRecordSent](https://strimzi.io/docs/bridge/0.19.0/#_offsetrecordsent)

| Name                     | Schema          |
| :----------------------- | :-------------- |
| **offset** *optional*    | integer (int64) |
| **partition** *optional* | integer (int32) |

### [2.13. OffsetRecordSentList](https://strimzi.io/docs/bridge/0.19.0/#_offsetrecordsentlist)

| Name                   | Schema                                                       |
| :--------------------- | :----------------------------------------------------------- |
| **offsets** *optional* | < [OffsetRecordSent](https://strimzi.io/docs/bridge/0.19.0/#_offsetrecordsent) > array |

### [2.14. Partition](https://strimzi.io/docs/bridge/0.19.0/#_partition)

| Name                     | Schema          |
| :----------------------- | :-------------- |
| **partition** *optional* | integer (int32) |
| **topic** *optional*     | string          |

### [2.15. PartitionMetadata](https://strimzi.io/docs/bridge/0.19.0/#_partitionmetadata)

| Name                     | Schema                                                       |
| :----------------------- | :----------------------------------------------------------- |
| **leader** *optional*    | integer (int32)                                              |
| **partition** *optional* | integer (int32)                                              |
| **replicas** *optional*  | < [Replica](https://strimzi.io/docs/bridge/0.19.0/#_replica) > array |

### [2.16. Partitions](https://strimzi.io/docs/bridge/0.19.0/#_partitions)

| Name                      | Schema                                                       |
| :------------------------ | :----------------------------------------------------------- |
| **partitions** *optional* | < [Partition](https://strimzi.io/docs/bridge/0.19.0/#_partition) > array |

### [2.17. ProducerRecord](https://strimzi.io/docs/bridge/0.19.0/#_producerrecord)

| Name                     | Schema                                                       |
| :----------------------- | :----------------------------------------------------------- |
| **headers** *optional*   | [KafkaHeaderList](https://strimzi.io/docs/bridge/0.19.0/#_kafkaheaderlist) |
| **partition** *optional* | integer (int32)                                              |

### [2.18. ProducerRecordList](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordlist)

| Name                   | Schema                                                       |
| :--------------------- | :----------------------------------------------------------- |
| **records** *optional* | < [ProducerRecord](https://strimzi.io/docs/bridge/0.19.0/#_producerrecord) > array |

### [2.19. ProducerRecordToPartition](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordtopartition)

*Type* : object

### [2.20. ProducerRecordToPartitionList](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordtopartitionlist)

| Name                   | Schema                                                       |
| :--------------------- | :----------------------------------------------------------- |
| **records** *optional* | < [ProducerRecordToPartition](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordtopartition) > array |

### [2.21. Replica](https://strimzi.io/docs/bridge/0.19.0/#_replica)

| Name                   | Schema          |
| :--------------------- | :-------------- |
| **broker** *optional*  | integer (int32) |
| **in_sync** *optional* | boolean         |
| **leader** *optional*  | boolean         |

### [2.22. SubscribedTopicList](https://strimzi.io/docs/bridge/0.19.0/#_subscribedtopiclist)

| Name                      | Schema                                                       |
| :------------------------ | :----------------------------------------------------------- |
| **partitions** *optional* | < [AssignedTopicPartitions](https://strimzi.io/docs/bridge/0.19.0/#_assignedtopicpartitions) > array |
| **topics** *optional*     | [Topics](https://strimzi.io/docs/bridge/0.19.0/#_topics)     |

### [2.23. TopicMetadata](https://strimzi.io/docs/bridge/0.19.0/#_topicmetadata)

| Name                      | Description                       | Schema                                                       |
| :------------------------ | :-------------------------------- | :----------------------------------------------------------- |
| **configs** *optional*    | Per-topic configuration overrides | < string, string > map                                       |
| **name** *optional*       | Name of the topic                 | string                                                       |
| **partitions** *optional* |                                   | < [PartitionMetadata](https://strimzi.io/docs/bridge/0.19.0/#_partitionmetadata) > array |

### [2.24. Topics](https://strimzi.io/docs/bridge/0.19.0/#_topics)

| Name                         | Description                                        | Schema           |
| :--------------------------- | :------------------------------------------------- | :--------------- |
| **topic_pattern** *optional* | A regex topic pattern for matching multiple topics | string           |
| **topics** *optional*        |                                                    | < string > array |

## [3. Paths](https://strimzi.io/docs/bridge/0.19.0/#_paths)

### [3.1. GET /](https://strimzi.io/docs/bridge/0.19.0/#_info)

#### [3.1.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description)

Retrieves information about the Kafka Bridge instance, in JSON format.

#### [3.1.2. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses)

| HTTP Code | Description                              | Schema                                                       |
| :-------- | :--------------------------------------- | :----------------------------------------------------------- |
| **200**   | Information about Kafka Bridge instance. | [BridgeInfo](https://strimzi.io/docs/bridge/0.19.0/#_bridgeinfo) |

#### [3.1.3. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_2)

- `application/json`

#### [3.1.4. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200)

```json
{
  "bridge_version" : "0.16.0"
}
```

### [3.2. POST /consumers/{groupid}](https://strimzi.io/docs/bridge/0.19.0/#_createconsumer)

#### [3.2.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_2)

Creates a consumer instance in the given consumer group. You can optionally specify a consumer name and supported configuration options. It returns a base URI which must be used to construct URLs for subsequent requests against this consumer instance.

#### [3.2.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters)

| Type     | Name                   | Description                                                  | Schema                                                       |
| :------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group in which to create the consumer.    | string                                                       |
| **Body** | **body** *required*    | Name and configuration of the consumer. The name is unique within the scope of the consumer group. If a name is not specified, a randomly generated name is assigned. All parameters are optional. The supported configuration options are shown in the following example. | [Consumer](https://strimzi.io/docs/bridge/0.19.0/#_consumer) |

#### [3.2.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_2)

| HTTP Code | Description                                                  | Schema                                                       |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **200**   | Consumer created successfully.                               | [CreatedConsumer](https://strimzi.io/docs/bridge/0.19.0/#_createdconsumer) |
| **409**   | A consumer instance with the specified name already exists in the Kafka Bridge. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |
| **422**   | One or more consumer configuration options have invalid values. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.2.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_2)

- `application/vnd.kafka.v2+json`

#### [3.2.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_3)

- `application/vnd.kafka.v2+json`

#### [3.2.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_2)

- Consumers

#### [3.2.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body)

```json
{
  "name" : "consumer1",
  "format" : "binary",
  "auto.offset.reset" : "earliest",
  "enable.auto.commit" : false,
  "fetch.min.bytes" : 512,
  "consumer.request.timeout.ms" : 30000
}
```

#### [3.2.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_2)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_2)

```json
{
  "application/vnd.kafka.v2+json" : {
    "instance_id" : "consumer1",
    "base_uri" : "http://localhost:8080/consumers/my-group/instances/consumer1"
  }
}
```

##### [Response 409](https://strimzi.io/docs/bridge/0.19.0/#response_409)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 409,
    "message" : "A consumer instance with the specified name already exists in the Kafka Bridge."
  }
}
```

##### [Response 422](https://strimzi.io/docs/bridge/0.19.0/#response_422)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 422,
    "message" : "One or more consumer configuration options have invalid values."
  }
}
```

### [3.3. DELETE /consumers/{groupid}/instances/{name}](https://strimzi.io/docs/bridge/0.19.0/#_deleteconsumer)

#### [3.3.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_3)

Deletes a specified consumer instance. The request for this operation MUST use the base URL (including the host and port) returned in the response from the `POST` request to `/consumers/{groupid}` that was used to create this consumer.

#### [3.3.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_2)

| Type     | Name                   | Description                                             | Schema |
| :------- | :--------------------- | :------------------------------------------------------ | :----- |
| **Path** | **groupid** *required* | ID of the consumer group to which the consumer belongs. | string |
| **Path** | **name** *required*    | Name of the consumer to delete.                         | string |

#### [3.3.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_3)

| HTTP Code | Description                                    | Schema                                                 |
| :-------- | :--------------------------------------------- | :----------------------------------------------------- |
| **204**   | Consumer removed successfully.                 | No Content                                             |
| **404**   | The specified consumer instance was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.3.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_3)

- `application/vnd.kafka.v2+json`

#### [3.3.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_4)

- `application/vnd.kafka.v2+json`

#### [3.3.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_3)

- Consumers

#### [3.3.7. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_3)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.4. POST /consumers/{groupid}/instances/{name}/assignments](https://strimzi.io/docs/bridge/0.19.0/#_assign)

#### [3.4.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_4)

Assigns one or more topic partitions to a consumer.

#### [3.4.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_3)

| Type     | Name                   | Description                                             | Schema                                                       |
| :------- | :--------------------- | :------------------------------------------------------ | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the consumer belongs. | string                                                       |
| **Path** | **name** *required*    | Name of the consumer to assign topic partitions to.     | string                                                       |
| **Body** | **body** *required*    | List of topic partitions to assign to the consumer.     | [Partitions](https://strimzi.io/docs/bridge/0.19.0/#_partitions) |

#### [3.4.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_4)

| HTTP Code | Description                                                  | Schema                                                 |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------- |
| **204**   | Partitions assigned successfully.                            | No Content                                             |
| **404**   | The specified consumer instance was not found.               | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |
| **409**   | Subscriptions to topics, partitions, and patterns are mutually exclusive. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.4.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_4)

- `application/vnd.kafka.v2+json`

#### [3.4.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_5)

- `application/vnd.kafka.v2+json`

#### [3.4.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_4)

- Consumers

#### [3.4.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_2)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_2)

```json
{
  "partitions" : [ {
    "topic" : "topic",
    "partition" : 0
  }, {
    "topic" : "topic",
    "partition" : 1
  } ]
}
```

#### [3.4.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_4)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_2)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

##### [Response 409](https://strimzi.io/docs/bridge/0.19.0/#response_409_2)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 409,
    "message" : "Subscriptions to topics, partitions, and patterns are mutually exclusive."
  }
}
```

### [3.5. POST /consumers/{groupid}/instances/{name}/offsets](https://strimzi.io/docs/bridge/0.19.0/#_commit)

#### [3.5.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_5)

Commits a list of consumer offsets. To commit offsets for all records fetched by the consumer, leave the request body empty.

#### [3.5.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_4)

| Type     | Name                   | Description                                                  | Schema                                                       |
| :------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the consumer belongs.      | string                                                       |
| **Path** | **name** *required*    | Name of the consumer.                                        | string                                                       |
| **Body** | **body** *optional*    | List of consumer offsets to commit to the consumer offsets commit log. You can specify one or more topic partitions to commit offsets for. | [OffsetCommitSeekList](https://strimzi.io/docs/bridge/0.19.0/#_offsetcommitseeklist) |

#### [3.5.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_5)

| HTTP Code | Description                                    | Schema                                                 |
| :-------- | :--------------------------------------------- | :----------------------------------------------------- |
| **204**   | Commit made successfully.                      | No Content                                             |
| **404**   | The specified consumer instance was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.5.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_5)

- `application/vnd.kafka.v2+json`

#### [3.5.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_6)

- `application/vnd.kafka.v2+json`

#### [3.5.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_5)

- Consumers

#### [3.5.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_3)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_3)

```json
{
  "offsets" : [ {
    "topic" : "topic",
    "partition" : 0,
    "offset" : 15
  }, {
    "topic" : "topic",
    "partition" : 1,
    "offset" : 42
  } ]
}
```

#### [3.5.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_5)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_3)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.6. POST /consumers/{groupid}/instances/{name}/positions](https://strimzi.io/docs/bridge/0.19.0/#_seek)

#### [3.6.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_6)

Configures a subscribed consumer to fetch offsets from a particular offset the next time it fetches a set of records from a given topic partition. This overrides the default fetch behavior for consumers. You can specify one or more topic partitions.

#### [3.6.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_5)

| Type     | Name                   | Description                                                  | Schema                                                       |
| :------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the consumer belongs.      | string                                                       |
| **Path** | **name** *required*    | Name of the subscribed consumer.                             | string                                                       |
| **Body** | **body** *required*    | List of partition offsets from which the subscribed consumer will next fetch records. | [OffsetCommitSeekList](https://strimzi.io/docs/bridge/0.19.0/#_offsetcommitseeklist) |

#### [3.6.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_6)

| HTTP Code | Description                                                  | Schema                                                 |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------- |
| **204**   | Seek performed successfully.                                 | No Content                                             |
| **404**   | The specified consumer instance was not found, or the specified consumer instance did not have one of the specified partitions assigned. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.6.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_6)

- `application/vnd.kafka.v2+json`

#### [3.6.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_7)

- `application/vnd.kafka.v2+json`

#### [3.6.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_6)

- Consumers
- Seek

#### [3.6.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_4)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_4)

```json
{
  "offsets" : [ {
    "topic" : "topic",
    "partition" : 0,
    "offset" : 15
  }, {
    "topic" : "topic",
    "partition" : 1,
    "offset" : 42
  } ]
}
```

#### [3.6.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_6)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_4)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.7. POST /consumers/{groupid}/instances/{name}/positions/beginning](https://strimzi.io/docs/bridge/0.19.0/#_seektobeginning)

#### [3.7.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_7)

Configures a subscribed consumer to seek (and subsequently read from) the first offset in one or more given topic partitions.

#### [3.7.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_6)

| Type     | Name                   | Description                                                  | Schema                                                       |
| :------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the subscribed consumer belongs. | string                                                       |
| **Path** | **name** *required*    | Name of the subscribed consumer.                             | string                                                       |
| **Body** | **body** *required*    | List of topic partitions to which the consumer is subscribed. The consumer will seek the first offset in the specified partitions. | [Partitions](https://strimzi.io/docs/bridge/0.19.0/#_partitions) |

#### [3.7.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_7)

| HTTP Code | Description                                                  | Schema                                                 |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------- |
| **204**   | Seek to the beginning performed successfully.                | No Content                                             |
| **404**   | The specified consumer instance was not found, or the specified consumer instance did not have one of the specified partitions assigned. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.7.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_7)

- `application/vnd.kafka.v2+json`

#### [3.7.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_8)

- `application/vnd.kafka.v2+json`

#### [3.7.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_7)

- Consumers
- Seek

#### [3.7.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_5)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_5)

```json
{
  "partitions" : [ {
    "topic" : "topic",
    "partition" : 0
  }, {
    "topic" : "topic",
    "partition" : 1
  } ]
}
```

#### [3.7.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_7)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_5)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.8. POST /consumers/{groupid}/instances/{name}/positions/end](https://strimzi.io/docs/bridge/0.19.0/#_seektoend)

#### [3.8.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_8)

Configures a subscribed consumer to seek (and subsequently read from) the offset at the end of one or more of the given topic partitions.

#### [3.8.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_7)

| Type     | Name                   | Description                                                  | Schema                                                       |
| :------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the subscribed consumer belongs. | string                                                       |
| **Path** | **name** *required*    | Name of the subscribed consumer.                             | string                                                       |
| **Body** | **body** *optional*    | List of topic partitions to which the consumer is subscribed. The consumer will seek the last offset in the specified partitions. | [Partitions](https://strimzi.io/docs/bridge/0.19.0/#_partitions) |

#### [3.8.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_8)

| HTTP Code | Description                                                  | Schema                                                 |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------- |
| **204**   | Seek to the end performed successfully.                      | No Content                                             |
| **404**   | The specified consumer instance was not found, or the specified consumer instance did not have one of the specified partitions assigned. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.8.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_8)

- `application/vnd.kafka.v2+json`

#### [3.8.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_9)

- `application/vnd.kafka.v2+json`

#### [3.8.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_8)

- Consumers
- Seek

#### [3.8.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_6)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_6)

```json
{
  "partitions" : [ {
    "topic" : "topic",
    "partition" : 0
  }, {
    "topic" : "topic",
    "partition" : 1
  } ]
}
```

#### [3.8.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_8)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_6)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.9. GET /consumers/{groupid}/instances/{name}/records](https://strimzi.io/docs/bridge/0.19.0/#_poll)

#### [3.9.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_9)

Retrieves records for a subscribed consumer, including message values, topics, and partitions. The request for this operation MUST use the base URL (including the host and port) returned in the response from the `POST` request to `/consumers/{groupid}` that was used to create this consumer.

#### [3.9.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_8)

| Type      | Name                     | Description                                                  | Schema  |
| :-------- | :----------------------- | :----------------------------------------------------------- | :------ |
| **Path**  | **groupid** *required*   | ID of the consumer group to which the subscribed consumer belongs. | string  |
| **Path**  | **name** *required*      | Name of the subscribed consumer to retrieve records from.    | string  |
| **Query** | **max_bytes** *optional* | The maximum size, in bytes, of unencoded keys and values that can be included in the response. Otherwise, an error response with code 422 is returned. | integer |
| **Query** | **timeout** *optional*   | The maximum amount of time, in milliseconds, that the HTTP Bridge spends retrieving records before timing out the request. | integer |

#### [3.9.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_9)

| HTTP Code | Description                                                  | Schema                                                       |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **200**   | Poll request executed successfully.                          | [ConsumerRecordList](https://strimzi.io/docs/bridge/0.19.0/#_consumerrecordlist) |
| **404**   | The specified consumer instance was not found.               | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |
| **406**   | The `format` used in the consumer creation request does not match the embedded format in the Accept header of this request or the bridge got a message from the topic which is not JSON encoded. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |
| **422**   | Response exceeds the maximum number of bytes the consumer can receive | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.9.4. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_10)

- `application/vnd.kafka.json.v2+json`
- `application/vnd.kafka.binary.v2+json`
- `application/vnd.kafka.v2+json`

#### [3.9.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_9)

- Consumers

#### [3.9.6. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_9)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_3)

```json
{
  "application/vnd.kafka.json.v2+json" : [ {
    "topic" : "topic",
    "key" : "key1",
    "value" : {
      "foo" : "bar"
    },
    "partition" : 0,
    "offset" : 2
  }, {
    "topic" : "topic",
    "key" : "key2",
    "value" : [ "foo2", "bar2" ],
    "partition" : 1,
    "offset" : 3
  } ],
  "application/vnd.kafka.binary.v2+json" : "[\n  {\n    \"topic\": \"test\",\n    \"key\": \"a2V5\",\n    \"value\": \"Y29uZmx1ZW50\",\n    \"partition\": 1,\n    \"offset\": 100,\n  },\n  {\n    \"topic\": \"test\",\n    \"key\": \"a2V5\",\n    \"value\": \"a2Fma2E=\",\n    \"partition\": 2,\n    \"offset\": 101,\n  }\n]"
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_7)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

##### [Response 406](https://strimzi.io/docs/bridge/0.19.0/#response_406)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 406,
    "message" : "The `format` used in the consumer creation request does not match the embedded format in the Accept header of this request."
  }
}
```

##### [Response 422](https://strimzi.io/docs/bridge/0.19.0/#response_422_2)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 422,
    "message" : "Response exceeds the maximum number of bytes the consumer can receive"
  }
}
```

### [3.10. POST /consumers/{groupid}/instances/{name}/subscription](https://strimzi.io/docs/bridge/0.19.0/#_subscribe)

#### [3.10.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_10)

Subscribes a consumer to one or more topics. You can describe the topics to which the consumer will subscribe in a list (of `Topics` type) or as a `topic_pattern` field. Each call replaces the subscriptions for the subscriber.

#### [3.10.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_9)

| Type     | Name                   | Description                                                  | Schema                                                   |
| :------- | :--------------------- | :----------------------------------------------------------- | :------------------------------------------------------- |
| **Path** | **groupid** *required* | ID of the consumer group to which the subscribed consumer belongs. | string                                                   |
| **Path** | **name** *required*    | Name of the consumer to unsubscribe from topics.             | string                                                   |
| **Body** | **body** *required*    | List of topics to which the consumer will subscribe.         | [Topics](https://strimzi.io/docs/bridge/0.19.0/#_topics) |

#### [3.10.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_10)

| HTTP Code | Description                                                  | Schema                                                 |
| :-------- | :----------------------------------------------------------- | :----------------------------------------------------- |
| **204**   | Consumer subscribed successfully.                            | No Content                                             |
| **404**   | The specified consumer instance was not found.               | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |
| **409**   | Subscriptions to topics, partitions, and patterns are mutually exclusive. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |
| **422**   | A list (of `Topics` type) or a `topic_pattern` must be specified. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.10.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_9)

- `application/vnd.kafka.v2+json`

#### [3.10.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_11)

- `application/vnd.kafka.v2+json`

#### [3.10.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_10)

- Consumers

#### [3.10.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_7)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_7)

```json
{
  "topics" : [ "topic1", "topic2" ]
}
```

#### [3.10.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_10)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_8)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

##### [Response 409](https://strimzi.io/docs/bridge/0.19.0/#response_409_3)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 409,
    "message" : "Subscriptions to topics, partitions, and patterns are mutually exclusive."
  }
}
```

##### [Response 422](https://strimzi.io/docs/bridge/0.19.0/#response_422_3)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 422,
    "message" : "A list (of Topics type) or a topic_pattern must be specified."
  }
}
```

### [3.11. GET /consumers/{groupid}/instances/{name}/subscription](https://strimzi.io/docs/bridge/0.19.0/#_listsubscriptions)

#### [3.11.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_11)

Retrieves a list of the topics to which the consumer is subscribed.

#### [3.11.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_10)

| Type     | Name                   | Description                                                  | Schema |
| :------- | :--------------------- | :----------------------------------------------------------- | :----- |
| **Path** | **groupid** *required* | ID of the consumer group to which the subscribed consumer belongs. | string |
| **Path** | **name** *required*    | Name of the consumer to unsubscribe from topics.             | string |

#### [3.11.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_11)

| HTTP Code | Description                                    | Schema                                                       |
| :-------- | :--------------------------------------------- | :----------------------------------------------------------- |
| **200**   | List of subscribed topics and partitions.      | [SubscribedTopicList](https://strimzi.io/docs/bridge/0.19.0/#_subscribedtopiclist) |
| **404**   | The specified consumer instance was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.11.4. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_12)

- `application/vnd.kafka.v2+json`

#### [3.11.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_11)

- Consumers

#### [3.11.6. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_11)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_4)

```json
{
  "topics" : [ "my-topic1", "my-topic2" ],
  "partitions" : [ {
    "my-topic1" : [ 1, 2, 3 ]
  }, {
    "my-topic2" : [ 1 ]
  } ]
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_9)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified consumer instance was not found."
  }
}
```

### [3.12. DELETE /consumers/{groupid}/instances/{name}/subscription](https://strimzi.io/docs/bridge/0.19.0/#_unsubscribe)

#### [3.12.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_12)

Unsubscribes a consumer from all topics.

#### [3.12.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_11)

| Type     | Name                   | Description                                                  | Schema |
| :------- | :--------------------- | :----------------------------------------------------------- | :----- |
| **Path** | **groupid** *required* | ID of the consumer group to which the subscribed consumer belongs. | string |
| **Path** | **name** *required*    | Name of the consumer to unsubscribe from topics.             | string |

#### [3.12.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_12)

| HTTP Code | Description                                    | Schema                                                 |
| :-------- | :--------------------------------------------- | :----------------------------------------------------- |
| **204**   | Consumer unsubscribed successfully.            | No Content                                             |
| **404**   | The specified consumer instance was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error) |

#### [3.12.4. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_12)

- Consumers

#### [3.12.5. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_12)

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_10)

```json
{
  "error_code" : 404,
  "message" : "The specified consumer instance was not found."
}
```

### [3.13. GET /healthy](https://strimzi.io/docs/bridge/0.19.0/#_healthy)

#### [3.13.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_13)

Check if the bridge is running. This does not necessarily imply that it is ready to accept requests.

#### [3.13.2. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_13)

| HTTP Code | Description           | Schema     |
| :-------- | :-------------------- | :--------- |
| **200**   | The bridge is healthy | No Content |

### [3.14. GET /openapi](https://strimzi.io/docs/bridge/0.19.0/#_openapi)

#### [3.14.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_14)

Retrieves the OpenAPI v2 specification in JSON format.

#### [3.14.2. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_14)

| HTTP Code | Description                                                  | Schema |
| :-------- | :----------------------------------------------------------- | :----- |
| **200**   | OpenAPI v2 specification in JSON format retrieved successfully. | string |

#### [3.14.3. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_13)

- `application/json`

### [3.15. GET /ready](https://strimzi.io/docs/bridge/0.19.0/#_ready)

#### [3.15.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_15)

Check if the bridge is ready and can accept requests.

#### [3.15.2. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_15)

| HTTP Code | Description         | Schema     |
| :-------- | :------------------ | :--------- |
| **200**   | The bridge is ready | No Content |

### [3.16. GET /topics](https://strimzi.io/docs/bridge/0.19.0/#_listtopics)

#### [3.16.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_16)

Retrieves a list of all topics.

#### [3.16.2. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_16)

| HTTP Code | Description     | Schema           |
| :-------- | :-------------- | :--------------- |
| **200**   | List of topics. | < string > array |

#### [3.16.3. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_14)

- `application/vnd.kafka.v2+json`

#### [3.16.4. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_13)

- Topics

#### [3.16.5. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_13)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_5)

```json
{
  "application/vnd.kafka.v2+json" : [ "topic1", "topic2" ]
}
```

### [3.17. POST /topics/{topicname}](https://strimzi.io/docs/bridge/0.19.0/#_send)

#### [3.17.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_17)

Sends one or more records to a given topic, optionally specifying a partition, key, or both.

#### [3.17.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_12)

| Type     | Name                     | Description                                                  | Schema                                                       |
| :------- | :----------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **topicname** *required* | Name of the topic to send records to or retrieve metadata from. | string                                                       |
| **Body** | **body** *required*      |                                                              | [ProducerRecordList](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordlist) |

#### [3.17.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_17)

| HTTP Code | Description                        | Schema                                                       |
| :-------- | :--------------------------------- | :----------------------------------------------------------- |
| **200**   | Records sent successfully.         | [OffsetRecordSentList](https://strimzi.io/docs/bridge/0.19.0/#_offsetrecordsentlist) |
| **404**   | The specified topic was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |
| **422**   | The record list is not valid.      | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.17.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_10)

- `application/vnd.kafka.json.v2+json`
- `application/vnd.kafka.binary.v2+json`

#### [3.17.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_15)

- `application/vnd.kafka.v2+json`

#### [3.17.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_14)

- Producer
- Topics

#### [3.17.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_8)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_8)

```json
{
  "records" : [ {
    "key" : "key1",
    "value" : "value1"
  }, {
    "value" : "value2",
    "partition" : 1
  }, {
    "value" : "value3"
  } ]
}
```

#### [3.17.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_14)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_6)

```json
{
  "application/vnd.kafka.v2+json" : {
    "offsets" : [ {
      "partition" : 2,
      "offset" : 0
    }, {
      "partition" : 1,
      "offset" : 1
    }, {
      "partition" : 2,
      "offset" : 2
    } ]
  }
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_11)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified topic was not found."
  }
}
```

##### [Response 422](https://strimzi.io/docs/bridge/0.19.0/#response_422_4)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 422,
    "message" : "The record list contains invalid records."
  }
}
```

### [3.18. GET /topics/{topicname}](https://strimzi.io/docs/bridge/0.19.0/#_gettopic)

#### [3.18.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_18)

Retrieves the metadata about a given topic.

#### [3.18.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_13)

| Type     | Name                     | Description                                                  | Schema |
| :------- | :----------------------- | :----------------------------------------------------------- | :----- |
| **Path** | **topicname** *required* | Name of the topic to send records to or retrieve metadata from. | string |

#### [3.18.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_18)

| HTTP Code | Description    | Schema                                                       |
| :-------- | :------------- | :----------------------------------------------------------- |
| **200**   | Topic metadata | [TopicMetadata](https://strimzi.io/docs/bridge/0.19.0/#_topicmetadata) |

#### [3.18.4. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_16)

- `application/vnd.kafka.v2+json`

#### [3.18.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_15)

- Topics

#### [3.18.6. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_15)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_7)

```json
{
  "application/vnd.kafka.v2+json" : {
    "name" : "topic",
    "offset" : 2,
    "configs" : {
      "cleanup.policy" : "compact"
    },
    "partitions" : [ {
      "partition" : 1,
      "leader" : 1,
      "replicas" : [ {
        "broker" : 1,
        "leader" : true,
        "in_sync" : true
      }, {
        "broker" : 2,
        "leader" : false,
        "in_sync" : true
      } ]
    }, {
      "partition" : 2,
      "leader" : 2,
      "replicas" : [ {
        "broker" : 1,
        "leader" : false,
        "in_sync" : true
      }, {
        "broker" : 2,
        "leader" : true,
        "in_sync" : true
      } ]
    } ]
  }
}
```

### [3.19. GET /topics/{topicname}/partitions](https://strimzi.io/docs/bridge/0.19.0/#_listpartitions)

#### [3.19.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_19)

Retrieves a list of partitions for the topic.

#### [3.19.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_14)

| Type     | Name                     | Description                                                  | Schema |
| :------- | :----------------------- | :----------------------------------------------------------- | :----- |
| **Path** | **topicname** *required* | Name of the topic to send records to or retrieve metadata from. | string |

#### [3.19.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_19)

| HTTP Code | Description                        | Schema                                                       |
| :-------- | :--------------------------------- | :----------------------------------------------------------- |
| **200**   | List of partitions                 | < [PartitionMetadata](https://strimzi.io/docs/bridge/0.19.0/#_partitionmetadata) > array |
| **404**   | The specified topic was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.19.4. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_17)

- `application/vnd.kafka.v2+json`

#### [3.19.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_16)

- Topics

#### [3.19.6. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_16)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_8)

```json
{
  "application/vnd.kafka.v2+json" : [ {
    "partition" : 1,
    "leader" : 1,
    "replicas" : [ {
      "broker" : 1,
      "leader" : true,
      "in_sync" : true
    }, {
      "broker" : 2,
      "leader" : false,
      "in_sync" : true
    } ]
  }, {
    "partition" : 2,
    "leader" : 2,
    "replicas" : [ {
      "broker" : 1,
      "leader" : false,
      "in_sync" : true
    }, {
      "broker" : 2,
      "leader" : true,
      "in_sync" : true
    } ]
  } ]
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_12)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified topic was not found."
  }
}
```

### [3.20. POST /topics/{topicname}/partitions/{partitionid}](https://strimzi.io/docs/bridge/0.19.0/#_sendtopartition)

#### [3.20.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_20)

Sends one or more records to a given topic partition, optionally specifying a key.

#### [3.20.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_15)

| Type     | Name                       | Description                                                  | Schema                                                       |
| :------- | :------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Path** | **partitionid** *required* | ID of the partition to send records to or retrieve metadata from. | integer                                                      |
| **Path** | **topicname** *required*   | Name of the topic to send records to or retrieve metadata from. | string                                                       |
| **Body** | **body** *required*        | List of records to send to a given topic partition, including a value (required) and a key (optional). | [ProducerRecordToPartitionList](https://strimzi.io/docs/bridge/0.19.0/#_producerrecordtopartitionlist) |

#### [3.20.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_20)

| HTTP Code | Description                                  | Schema                                                       |
| :-------- | :------------------------------------------- | :----------------------------------------------------------- |
| **200**   | Records sent successfully.                   | [OffsetRecordSentList](https://strimzi.io/docs/bridge/0.19.0/#_offsetrecordsentlist) |
| **404**   | The specified topic partition was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |
| **422**   | The record is not valid.                     | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.20.4. Consumes](https://strimzi.io/docs/bridge/0.19.0/#consumes_11)

- `application/vnd.kafka.json.v2+json`
- `application/vnd.kafka.binary.v2+json`

#### [3.20.5. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_18)

- `application/vnd.kafka.v2+json`

#### [3.20.6. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_17)

- Producer
- Topics

#### [3.20.7. Example HTTP request](https://strimzi.io/docs/bridge/0.19.0/#example_http_request_9)

##### [Request body](https://strimzi.io/docs/bridge/0.19.0/#request_body_9)

```json
{
  "records" : [ {
    "key" : "key1",
    "value" : "value1"
  }, {
    "value" : "value2"
  } ]
}
```

#### [3.20.8. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_17)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_9)

```json
{
  "application/vnd.kafka.v2+json" : {
    "offsets" : [ {
      "partition" : 2,
      "offset" : 0
    }, {
      "partition" : 1,
      "offset" : 1
    }, {
      "partition" : 2,
      "offset" : 2
    } ]
  }
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_13)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified topic partition was not found."
  }
}
```

##### [Response 422](https://strimzi.io/docs/bridge/0.19.0/#response_422_5)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 422,
    "message" : "The record is not valid."
  }
}
```

### [3.21. GET /topics/{topicname}/partitions/{partitionid}](https://strimzi.io/docs/bridge/0.19.0/#_getpartition)

#### [3.21.1. Description](https://strimzi.io/docs/bridge/0.19.0/#description_21)

Retrieves partition metadata for the topic partition.

#### [3.21.2. Parameters](https://strimzi.io/docs/bridge/0.19.0/#parameters_16)

| Type     | Name                       | Description                                                  | Schema  |
| :------- | :------------------------- | :----------------------------------------------------------- | :------ |
| **Path** | **partitionid** *required* | ID of the partition to send records to or retrieve metadata from. | integer |
| **Path** | **topicname** *required*   | Name of the topic to send records to or retrieve metadata from. | string  |

#### [3.21.3. Responses](https://strimzi.io/docs/bridge/0.19.0/#responses_21)

| HTTP Code | Description                                  | Schema                                                       |
| :-------- | :------------------------------------------- | :----------------------------------------------------------- |
| **200**   | Partition metadata                           | [PartitionMetadata](https://strimzi.io/docs/bridge/0.19.0/#_partitionmetadata) |
| **404**   | The specified topic partition was not found. | [Error](https://strimzi.io/docs/bridge/0.19.0/#_error)       |

#### [3.21.4. Produces](https://strimzi.io/docs/bridge/0.19.0/#produces_19)

- `application/vnd.kafka.v2+json`

#### [3.21.5. Tags](https://strimzi.io/docs/bridge/0.19.0/#tags_18)

- Topics

#### [3.21.6. Example HTTP response](https://strimzi.io/docs/bridge/0.19.0/#example_http_response_18)

##### [Response 200](https://strimzi.io/docs/bridge/0.19.0/#response_200_10)

```json
{
  "application/vnd.kafka.v2+json" : {
    "partition" : 1,
    "leader" : 1,
    "replicas" : [ {
      "broker" : 1,
      "leader" : true,
      "in_sync" : true
    }, {
      "broker" : 2,
      "leader" : false,
      "in_sync" : true
    } ]
  }
}
```

##### [Response 404](https://strimzi.io/docs/bridge/0.19.0/#response_404_14)

```json
{
  "application/vnd.kafka.v2+json" : {
    "error_code" : 404,
    "message" : "The specified topic partition was not found."
  }
}
```

*Revised on 2020-10-06 12:15:22 +0200*