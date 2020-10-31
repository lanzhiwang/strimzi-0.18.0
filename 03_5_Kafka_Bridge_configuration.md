### [3.5. Kafka Bridge configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-deployment-configuration-kafka-bridge-str)

The full schema of the `KafkaBridge` resource is described in the [`KafkaBridge` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaBridge-reference). All labels that are applied to the desired `KafkaBridge` resource will also be applied to the Kubernetes resources making up the Kafka Bridge cluster. This provides a convenient mechanism for resources to be labeled as required.

#### [3.5.1. Replicas](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-replicas-deployment-configuration-kafka-bridge)

Kafka Bridge can run multiple nodes. The number of nodes is defined in the `KafkaBridge` resource. Running a Kafka Bridge with multiple nodes can provide better availability and scalability. However, when running Kafka Bridge on Kubernetes it is not absolutely necessary to run multiple nodes of Kafka Bridge for high availability.

> IMPORTANT：If a node where Kafka Bridge is deployed to crashes, Kubernetes will automatically reschedule the Kafka Bridge pod to a different node. In order to prevent issues arising when client consumer requests are processed by different Kafka Bridge instances, addressed-based routing must be employed to ensure that requests are routed to the right Kafka Bridge instance. Additionally, each independent Kafka Bridge instance must have a replica. A Kafka Bridge instance has its own state which is not shared with another instances.  如果将部署Kafka Bridge的节点崩溃，Kubernetes将自动将Kafka Bridge pod的时间表重新安排到其他节点。 为了防止在不同的Kafka Bridge实例处理客户端使用者请求时出现问题，必须使用基于寻址的路由来确保将请求路由到正确的Kafka Bridge实例。 此外，每个独立的Kafka Bridge实例必须具有一个副本。 Kafka Bridge实例具有自己的状态，不会与其他实例共享。

##### [Configuring the number of nodes](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-bridge-replicas-deployment-configuration-kafka-bridge)

The number of Kafka Bridge nodes is configured using the `replicas` property in `KafkaBridge.spec`.

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `replicas` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     replicas: 3
     # ...
   ```

2. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.2. Bootstrap servers](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-bootstrap-servers-deployment-configuration-kafka-bridge)

A Kafka Bridge always works in combination with a Kafka cluster. A Kafka cluster is specified as a list of bootstrap servers. On Kubernetes, the list must ideally contain the Kafka cluster bootstrap service named `*cluster-name*-kafka-bootstrap`, and a port of 9092 for plain traffic or 9093 for encrypted traffic.

The list of bootstrap servers is configured in the `bootstrapServers` property in `KafkaBridge.kafka.spec`. The servers must be defined as a comma-separated list specifying one or more Kafka brokers, or a service pointing to Kafka brokers specified as a `*hostname*:_port_` pairs.

When using Kafka Bridge with a Kafka cluster not managed by Strimzi, you can specify the bootstrap servers list according to the configuration of the cluster.

##### [Configuring bootstrap servers](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-beridge-bootstrap-servers-deployment-configuration-kafka-bridge)

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `bootstrapServers` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     bootstrapServers: my-cluster-kafka-bootstrap:9092
     # ...
   ```

2. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.3. Connecting to Kafka brokers using TLS](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-tls-deployment-configuration-kafka-bridge)

By default, Kafka Bridge tries to connect to Kafka brokers using a plain text connection. If you prefer to use TLS, additional configuration is required.

##### [TLS support for Kafka connection to the Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-bridge-tls-deployment-configuration-kafka-bridge)

TLS support for Kafka connection is configured in the `tls` property in `KafkaBridge.spec`. The `tls` property contains a list of secrets with key names under which the certificates are stored. The certificates must be stored in X509 format.

An example showing TLS configuration with multiple certificates

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  tls:
    trustedCertificates:
    - secretName: my-secret
      certificate: ca.crt
    - secretName: my-other-secret
      certificate: certificate.crt
  # ...
```

When multiple certificates are stored in the same secret, it can be listed multiple times.

An example showing TLS configuration with multiple certificates from the same secret

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  tls:
    trustedCertificates:
    - secretName: my-secret
      certificate: ca.crt
    - secretName: my-secret
      certificate: ca2.crt
  # ...
```

##### [Configuring TLS in Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-bridge-tls-deployment-configuration-kafka-bridge)

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator
- If they exist, the name of the `Secret` for the certificate used for TLS Server Authentication, and the key under which the certificate is stored in the `Secret`

Procedure

1. (Optional) If they do not already exist, prepare the TLS certificate used in authentication in a file and create a `Secret`.

   > NOTE：The secrets created by the Cluster Operator for Kafka cluster may be used directly.

   ```shell
   kubectl create secret generic my-secret --from-file=my-file.crt
   ```

2. Edit the `tls` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     tls:
   	  trustedCertificates:
   	  - secretName: my-cluster-cluster-cert
   	    certificate: ca.crt
     # ...
   ```

3. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.4. Connecting to Kafka brokers with Authentication](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-authentication-deployment-configuration-kafka-bridge)

By default, Kafka Bridge will try to connect to Kafka brokers without authentication. Authentication is enabled through the `KafkaBridge` resources.

##### [Authentication support in Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-bridge-authentication-deployment-configuration-kafka-bridge)

Authentication is configured through the `authentication` property in `KafkaBridge.spec`. The `authentication` property specifies the type of the authentication mechanisms which should be used and additional configuration details depending on the mechanism. The currently supported authentication types are:

- TLS client authentication
- SASL-based authentication using the SCRAM-SHA-512 mechanism
- SASL-based authentication using the PLAIN mechanism
- [OAuth 2.0 token based authentication](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-oauth-authentication_str)

###### [TLS Client Authentication](https://strimzi.io/docs/operators/0.18.0/using.html#tls_client_authentication_4)

To use TLS client authentication, set the `type` property to the value `tls`. TLS client authentication uses a TLS certificate to authenticate. The certificate is specified in the `certificateAndKey` property and is always loaded from an Kubernetes secret. In the secret, the certificate must be stored in X509 format under two different keys: public and private.

> NOTE：TLS client authentication can be used only with TLS connections. For more details about TLS configuration in Kafka Bridge see [Connecting to Kafka brokers using TLS](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-tls-deployment-configuration-kafka-bridge).

An example TLS client authentication configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  authentication:
    type: tls
    certificateAndKey:
      secretName: my-secret
      certificate: public.crt
      key: private.key
  # ...
```

###### [SCRAM-SHA-512 authentication](https://strimzi.io/docs/operators/0.18.0/using.html#scram_sha_512_authentication)

To configure Kafka Bridge to use SASL-based SCRAM-SHA-512 authentication, set the `type` property to `scram-sha-512`. This authentication mechanism requires a username and password.

- Specify the username in the `username` property.
- In the `passwordSecret` property, specify a link to a `Secret` containing the password. The `secretName` property contains the name of the `Secret` and the `password` property contains the name of the key under which the password is stored inside the `Secret`.

> IMPORTANT：Do not specify the actual password in the `password` field.

An example SASL based SCRAM-SHA-512 client authentication configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  authentication:
    type: scram-sha-512
    username: my-bridge-user
    passwordSecret:
      secretName: my-bridge-user
      password: my-bridge-password-key
  # ...
```

###### [SASL-based PLAIN authentication](https://strimzi.io/docs/operators/0.18.0/using.html#sasl_based_plain_authentication_3)

To configure Kafka Bridge to use SASL-based PLAIN authentication, set the `type` property to `plain`. This authentication mechanism requires a username and password.

> WARNING：The SASL PLAIN mechanism will transfer the username and password across the network in cleartext. Only use SASL PLAIN authentication if TLS encryption is enabled.

- Specify the username in the `username` property.
- In the `passwordSecret` property, specify a link to a `Secret` containing the password. The `secretName` property contains the name the `Secret` and the `password` property contains the name of the key under which the password is stored inside the `Secret`.

> IMPORTANT：Do not specify the actual password in the `password` field.

An example showing SASL based PLAIN client authentication configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  authentication:
    type: plain
    username: my-bridge-user
    passwordSecret:
      secretName: my-bridge-user
      password: my-bridge-password-key
  # ...
```

##### [Configuring TLS client authentication in Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-bridge-authentication-tls-deployment-configuration-kafka-bridge)

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator
- If they exist, the name of the `Secret` with the public and private keys used for TLS Client Authentication, and the keys under which they are stored in the `Secret`

Procedure

1. (Optional) If they do not already exist, prepare the keys used for authentication in a file and create the `Secret`.

   > NOTE：Secrets created by the User Operator may be used.

   ```shell
   kubectl create secret generic my-secret --from-file=my-public.crt --from-file=my-private.key
   ```

2. Edit the `authentication` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     authentication:
     type: tls
     certificateAndKey:
       secretName: my-secret
       certificate: my-public.crt
       key: my-private.key
     # ...
   ```

3. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

##### [Configuring SCRAM-SHA-512 authentication in Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-bridge-authentication-scram-sha-512-deployment-configuration-kafka-bridge)

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator
- Username of the user which should be used for authentication
- If they exist, the name of the `Secret` with the password used for authentication and the key under which the password is stored in the `Secret`

Procedure

1. (Optional) If they do not already exist, prepare a file with the password used in authentication and create the `Secret`.

   > NOTE：Secrets created by the User Operator may be used.

   ```shell
   echo -n '<password>' > <my-password.txt>
   kubectl create secret generic <my-secret> --from-file=<my-password.txt>
   ```

2. Edit the `authentication` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     authentication:
       type: scram-sha-512
       username: _<my-username>_
       passwordSecret:
         secretName: _<my-secret>_
         password: _<my-password.txt>_
     # ...
   ```

3. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.5. Kafka Bridge configuration](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-bridge-configuration-deployment-configuration-kafka-bridge)

Strimzi allows you to customize the configuration of Apache Kafka Bridge nodes by editing certain options listed in [Apache Kafka configuration documentation for consumers](http://kafka.apache.org/20/documentation.html#newconsumerconfigs) and [Apache Kafka configuration documentation for producers](http://kafka.apache.org/20/documentation.html#producerconfigs).

Configuration options that can be configured relate to:

- Kafka cluster bootstrap address
- Security (Encryption, Authentication, and Authorization)
- Consumer configuration
- Producer configuration
- HTTP configuration

##### [Kafka Bridge Consumer configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-bridge-consumer-configuration-deployment-configuration-kafka-bridge)

Kafka Bridge consumer is configured using the properties in `KafkaBridge.spec.consumer`. This property contains the Kafka Bridge consumer configuration options as keys. The values can be one of the following JSON types:

- String
- Number
- Boolean

Users can specify and configure the options listed in the [Apache Kafka configuration documentation for consumers](http://kafka.apache.org/20/documentation.html#newconsumerconfigs) with the exception of those options which are managed directly by Strimzi. Specifically, all configuration options with keys equal to or starting with one of the following strings are forbidden:

- `ssl.`
- `sasl.`
- `security.`
- `bootstrap.servers`
- `group.id`

When one of the forbidden options is present in the `config` property, it will be ignored and a warning message will be printed to the Custer Operator log file. All other options will be passed to Kafka

> IMPORTANT：The Cluster Operator does not validate keys or values in the `config` object provided. When an invalid configuration is provided, the Kafka Bridge cluster might not start or might become unstable. In this circumstance, fix the configuration in the `KafkaBridge.spec.consumer.config` object, then the Cluster Operator can roll out the new configuration to all Kafka Bridge nodes.

Example Kafka Bridge consumer configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  consumer:
    config:
      auto.offset.reset: earliest
      enable.auto.commit: true
  # ...
```

##### [Kafka Bridge Producer configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-bridge-producer-configuration-deployment-configuration-kafka-bridge)

Kafka Bridge producer is configured using the properties in `KafkaBridge.spec.producer`. This property contains the Kafka Bridge producer configuration options as keys. The values can be one of the following JSON types:

- String
- Number
- Boolean

Users can specify and configure the options listed in the [Apache Kafka configuration documentation for producers](http://kafka.apache.org/20/documentation.html#producerconfigs) with the exception of those options which are managed directly by Strimzi. Specifically, all configuration options with keys equal to or starting with one of the following strings are forbidden:

- `ssl.`
- `sasl.`
- `security.`
- `bootstrap.servers`

> IMPORTANT：The Cluster Operator does not validate keys or values in the `config` object provided. When an invalid configuration is provided, the Kafka Bridge cluster might not start or might become unstable. In this circumstance, fix the configuration in the `KafkaBridge.spec.producer.config` object, then the Cluster Operator can roll out the new configuration to all Kafka Bridge nodes.

Example Kafka Bridge producer configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  producer:
    config:
      acks: 1
      delivery.timeout.ms: 300000
  # ...
```

##### [Kafka Bridge HTTP configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-bridge-http-configuration-deployment-configuration-kafka-bridge)

Kafka Bridge HTTP configuration is set using the properties in `KafkaBridge.spec.http`. This property contains the Kafka Bridge HTTP configuration options.

- `port`

Example Kafka Bridge HTTP configuration

```yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaBridge
metadata:
  name: my-bridge
spec:
  # ...
  http:
    port: 8080
  # ...
```

##### [Configuring Kafka Bridge](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-bridge-deployment-configuration-kafka-bridge)

Prerequisites

- An Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `kafka`, `http`, `consumer` or `producer` property in the `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1alpha1
   kind: KafkaBridge
   metadata:
     name: my-bridge
   spec:
     # ...
     bootstrapServers: my-cluster-kafka:9092
     http:
       port: 8080
     consumer:
       config:
         auto.offset.reset: earliest
     producer:
       config:
         delivery.timeout.ms: 300000
     # ...
   ```

2. Create or update the resource.

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.6. CPU and memory resources](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka-bridge)

For every deployed container, Strimzi allows you to request specific resources and define the maximum consumption of those resources.

Strimzi supports two types of resources:

- CPU
- Memory

Strimzi uses the Kubernetes syntax for specifying CPU and memory resources.

##### [Resource limits and requests](https://strimzi.io/docs/operators/0.18.0/using.html#ref-resource-limits-and-requests-deployment-configuration-kafka-bridge)

Resource limits and requests are configured using the `resources` property in the following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.KafkaExporter`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaBridge.spec`

Additional resources

- For more information about managing computing resources on Kubernetes, see [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/).

###### [Resource requests](https://strimzi.io/docs/operators/0.18.0/using.html#resource_requests_4)

Requests specify the resources to reserve for a given container. Reserving the resources ensures that they are always available.

> IMPORTANT：If the resource request is for more than the available free resources in the Kubernetes cluster, the pod is not scheduled.

Resources requests are specified in the `requests` property. Resources requests currently supported by Strimzi:

- `cpu`
- `memory`

A request may be configured for one or more supported resources.

Example resource request configuration with all resources

```yaml
# ...
resources:
  requests:
    cpu: 12
    memory: 64Gi
# ...
```

###### [Resource limits](https://strimzi.io/docs/operators/0.18.0/using.html#resource_limits_4)

Limits specify the maximum resources that can be consumed by a given container. The limit is not reserved and might not always be available. A container can use the resources up to the limit only when they are available. Resource limits should be always higher than the resource requests.

Resource limits are specified in the `limits` property. Resource limits currently supported by Strimzi:

- `cpu`
- `memory`

A resource may be configured for one or more supported limits.

Example resource limits configuration

```yaml
# ...
resources:
  limits:
    cpu: 12
    memory: 64Gi
# ...
```

###### [Supported CPU formats](https://strimzi.io/docs/operators/0.18.0/using.html#supported_cpu_formats_4)

CPU requests and limits are supported in the following formats:

- Number of CPU cores as integer (`5` CPU core) or decimal (`2.5` CPU core).
- Number or *millicpus* / *millicores* (`100m`) where 1000 *millicores* is the same `1` CPU core.

Example CPU units

```yaml
# ...
resources:
  requests:
    cpu: 500m
  limits:
    cpu: 2.5
# ...
```

> NOTE：The computing power of 1 CPU core may differ depending on the platform where Kubernetes is deployed.

Additional resources

- For more information on CPU specification, see the [Meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

###### [Supported memory formats](https://strimzi.io/docs/operators/0.18.0/using.html#supported_memory_formats_4)

Memory requests and limits are specified in megabytes, gigabytes, mebibytes, and gibibytes.

- To specify memory in megabytes, use the `M` suffix. For example `1000M`.
- To specify memory in gigabytes, use the `G` suffix. For example `1G`.
- To specify memory in mebibytes, use the `Mi` suffix. For example `1000Mi`.
- To specify memory in gibibytes, use the `Gi` suffix. For example `1Gi`.

An example of using different memory units

```yaml
# ...
resources:
  requests:
    memory: 512Mi
  limits:
    memory: 2Gi
# ...
```

Additional resources

- For more details about memory specification and additional supported units, see [Meaning of memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).

##### [Configuring resource requests and limits](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-resource-limits-and-requests-deployment-configuration-kafka-bridge)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `resources` property in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       resources:
         requests:
           cpu: "8"
           memory: 64Gi
         limits:
           cpu: "12"
           memory: 128Gi
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

Additional resources

- For more information about the schema, see [`Resources` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-ResourceRequirements-reference).

#### [3.5.7. Kafka Bridge loggers](https://strimzi.io/docs/operators/0.18.0/using.html#con-kafka-bridge-logging-deployment-configuration-kafka-bridge)

Kafka Bridge has its own configurable loggers:

- `log4j.logger.io.strimzi.kafka.bridge`
- `log4j.logger.http.openapi.operation.**`

You can replace `**` in the `log4j.logger.http.openapi.operation.**` logger to set log levels for specific operations:

- `createConsumer`
- `deleteConsumer`
- `subscribe`
- `unsubscribe`
- `poll`
- `assign`
- `commit`
- `send`
- `sendToPartition`
- `seekToBeginning`
- `seekToEnd`
- `seek`
- `healthy`
- `ready`
- `openapi`

Each operation is defined according OpenAPI specification, and has a corresponding API endpoint through which the bridge receives requests from HTTP clients. You can change the log level on each endpoint to create fine-grained logging information about the incoming and outgoing HTTP requests.

Kafka Bridge uses the Apache `log4j` logger implementation. Loggers are defined in the `log4j.properties` file, which has the following default configuration for `healthy` and `ready` endpoints:

```none
log4j.logger.http.openapi.operation.healthy=WARN, out
log4j.additivity.http.openapi.operation.healthy=false
log4j.logger.http.openapi.operation.ready=WARN, out
log4j.additivity.http.openapi.operation.ready=false
```

The log level of all other operations is set to `INFO` by default.

Use the `logging` property to configure loggers and logger levels.

You can set the log levels by specifying the logger and level directly (inline) or use a custom (external) ConfigMap. If a ConfigMap is used, you set `logging.name` property to the name of the ConfigMap containing the external logging configuration. Inside the ConfigMap, the logging configuration is described using `log4j.properties`.

Here we see examples of `inline` and `external` logging.

Inline logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaBridge
spec:
  # ...
  logging:
    type: inline
    loggers:
      log4j.logger.io.strimzi.kafka.bridge: "INFO"
  # ...
```

External logging

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaBridge
spec:
  # ...
  logging:
    type: external
    name: customConfigMap
  # ...
```

Additional resources

- Garbage collector (GC) logging can also be enabled (or disabled). For more information about GC logging, see [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka)
- For more information about log levels, see [Apache logging services](https://logging.apache.org/).

#### [3.5.8. JVM Options](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-jvm-options-deployment-configuration-kafka-bridge)

The following components of Strimzi run inside a Virtual Machine (VM):

- Apache Kafka
- Apache ZooKeeper
- Apache Kafka Connect
- Apache Kafka MirrorMaker
- Strimzi Kafka Bridge

JVM configuration options optimize the performance for different platforms and architectures. Strimzi allows you to configure some of these options.

##### [JVM configuration](https://strimzi.io/docs/operators/0.18.0/using.html#ref-jvm-options-deployment-configuration-kafka-bridge)

JVM options can be configured using the `jvmOptions` property in following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.zookeeper`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaMirrorMaker.spec`
- `KafkaBridge.spec`

Only a selected subset of available JVM options can be configured. The following options are supported:

-Xms and -Xmx

`-Xms` configures the minimum initial allocation heap size when the JVM starts. `-Xmx` configures the maximum heap size.

> NOTE：The units accepted by JVM settings such as `-Xmx` and `-Xms` are those accepted by the JDK `java` binary in the corresponding image. Accordingly, `1g` or `1G` means 1,073,741,824 bytes, and `Gi` is not a valid unit suffix. This is in contrast to the units used for [memory requests and limits](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka-bridge), which follow the Kubernetes convention where `1G` means 1,000,000,000 bytes, and `1Gi` means 1,073,741,824 bytes

The default values used for `-Xms` and `-Xmx` depends on whether there is a [memory request](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-resource-limits-and-requests-deployment-configuration-kafka-bridge) limit configured for the container:

- If there is a memory limit then the JVM’s minimum and maximum memory will be set to a value corresponding to the limit.
- If there is no memory limit then the JVM’s minimum memory will be set to `128M` and the JVM’s maximum memory will not be defined. This allows for the JVM’s memory to grow as-needed, which is ideal for single node environments in test and development.

> IMPORTANT：Setting `-Xmx` explicitly requires some care:The JVM’s overall memory usage will be approximately 4 × the maximum heap, as configured by `-Xmx`.If `-Xmx` is set without also setting an appropriate Kubernetes memory limit, it is possible that the container will be killed should the Kubernetes node experience memory pressure (from other Pods running on it).If `-Xmx` is set without also setting an appropriate Kubernetes memory request, it is possible that the container will be scheduled to a node with insufficient memory. In this case, the container will not start but crash (immediately if `-Xms` is set to `-Xmx`, or some later time if not).

When setting `-Xmx` explicitly, it is recommended to:

- set the memory request and the memory limit to the same value,
- use a memory request that is at least 4.5 × the `-Xmx`,
- consider setting `-Xms` to the same value as `-Xmx`.

> IMPORTANT：Containers doing lots of disk I/O (such as Kafka broker containers) will need to leave some memory available for use as operating system page cache. On such containers, the requested memory should be significantly higher than the memory used by the JVM.

Example fragment configuring `-Xmx` and `-Xms`

```yaml
# ...
jvmOptions:
  "-Xmx": "2g"
  "-Xms": "2g"
# ...
```

In the above example, the JVM will use 2 GiB (=2,147,483,648 bytes) for its heap. Its total memory usage will be approximately 8GiB.

Setting the same value for initial (`-Xms`) and maximum (`-Xmx`) heap sizes avoids the JVM having to allocate memory after startup, at the cost of possibly allocating more heap than is really needed. For Kafka and ZooKeeper pods such allocation could cause unwanted latency. For Kafka Connect avoiding over allocation may be the most important concern, especially in distributed mode where the effects of over-allocation will be multiplied by the number of consumers.

-server

`-server` enables the server JVM. This option can be set to true or false.

Example fragment configuring `-server`

```yaml
# ...
jvmOptions:
  "-server": true
# ...
```

> NOTE：When neither of the two options (`-server` and `-XX`) is specified, the default Apache Kafka configuration of `KAFKA_JVM_PERFORMANCE_OPTS` will be used.

-XX

`-XX` object can be used for configuring advanced runtime options of a JVM. The `-server` and `-XX` options are used to configure the `KAFKA_JVM_PERFORMANCE_OPTS` option of Apache Kafka.

Example showing the use of the `-XX` object

```yaml
jvmOptions:
  "-XX":
    "UseG1GC": true
    "MaxGCPauseMillis": 20
    "InitiatingHeapOccupancyPercent": 35
    "ExplicitGCInvokesConcurrent": true
    "UseParNewGC": false
```

The example configuration above will result in the following JVM options:

```none
-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -XX:-UseParNewGC
```

> NOTE：When neither of the two options (`-server` and `-XX`) is specified, the default Apache Kafka configuration of `KAFKA_JVM_PERFORMANCE_OPTS` will be used.

###### [Garbage collector logging](https://strimzi.io/docs/operators/0.18.0/using.html#garbage_collector_logging_4)

The `jvmOptions` section also allows you to enable and disable garbage collector (GC) logging. GC logging is disabled by default. To enable it, set the `gcLoggingEnabled` property as follows:

Example of enabling GC logging

```yaml
# ...
jvmOptions:
  gcLoggingEnabled: true
# ...
```

##### [Configuring JVM options](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-jvm-options-deployment-configuration-kafka-bridge)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `jvmOptions` property in the `Kafka`, `KafkaConnect`, `KafkaConnectS2I`, `KafkaMirrorMaker`, or `KafkaBridge` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       jvmOptions:
         "-Xmx": "8g"
         "-Xms": "8g"
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.9. Healthchecks](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-healthchecks-deployment-configuration-kafka-bridge)

Healthchecks are periodical tests which verify the health of an application. When a Healthcheck probe fails, Kubernetes assumes that the application is not healthy and attempts to fix it.

Kubernetes supports two types of Healthcheck probes:

- Liveness probes
- Readiness probes

For more details about the probes, see [Configure Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/). Both types of probes are used in Strimzi components.

Users can configure selected options for liveness and readiness probes.

##### [Healthcheck configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-healthchecks-deployment-configuration-kafka-bridge)

Liveness and readiness probes can be configured using the `livenessProbe` and `readinessProbe` properties in following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.KafkaExporter`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaMirrorMaker.spec`
- `KafkaBridge.spec`

Both `livenessProbe` and `readinessProbe` support the following options:

- `initialDelaySeconds`
- `timeoutSeconds`
- `periodSeconds`
- `successThreshold`
- `failureThreshold`

For more information about the `livenessProbe` and `readinessProbe` options, see [`Probe` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-Probe-reference).

An example of liveness and readiness probe configuration

```yaml
# ...
readinessProbe:
  initialDelaySeconds: 15
  timeoutSeconds: 5
livenessProbe:
  initialDelaySeconds: 15
  timeoutSeconds: 5
# ...
```

##### [Configuring healthchecks](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-healthchecks-deployment-configuration-kafka-bridge)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `livenessProbe` or `readinessProbe` property in the `Kafka`, `KafkaConnect` or `KafkaConnectS2I` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       readinessProbe:
         initialDelaySeconds: 15
         timeoutSeconds: 5
       livenessProbe:
         initialDelaySeconds: 15
         timeoutSeconds: 5
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.10. Container images](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-configuring-container-images-deployment-configuration-kafka-bridge)

Strimzi allows you to configure container images which will be used for its components. Overriding container images is recommended only in special situations, where you need to use a different container registry. For example, because your network does not allow access to the container repository used by Strimzi. In such a case, you should either copy the Strimzi images or build them from the source. If the configured image is not compatible with Strimzi images, it might not work properly.

##### [Container image configurations](https://strimzi.io/docs/operators/0.18.0/using.html#ref-configuring-container-images-deployment-configuration-kafka-bridge)

You can specify which container image to use for each component using the `image` property in the following resources:

- `Kafka.spec.kafka`
- `Kafka.spec.kafka.tlsSidecar`
- `Kafka.spec.zookeeper`
- `Kafka.spec.entityOperator.topicOperator`
- `Kafka.spec.entityOperator.userOperator`
- `Kafka.spec.entityOperator.tlsSidecar`
- `Kafka.spec.jmxTrans`
- `KafkaConnect.spec`
- `KafkaConnectS2I.spec`
- `KafkaBridge.spec`

###### [Configuring the `image` property for Kafka, Kafka Connect, and Kafka MirrorMaker](https://strimzi.io/docs/operators/0.18.0/using.html#configuring_the_image_property_for_kafka_kafka_connect_and_kafka_mirrormaker_4)

Kafka, Kafka Connect (including Kafka Connect with S2I support), and Kafka MirrorMaker support multiple versions of Kafka. Each component requires its own image. The default images for the different Kafka versions are configured in the following environment variables:

- `STRIMZI_KAFKA_IMAGES`
- `STRIMZI_KAFKA_CONNECT_IMAGES`
- `STRIMZI_KAFKA_CONNECT_S2I_IMAGES`
- `STRIMZI_KAFKA_MIRROR_MAKER_IMAGES`

These environment variables contain mappings between the Kafka versions and their corresponding images. The mappings are used together with the `image` and `version` properties:

- If neither `image` nor `version` are given in the custom resource then the `version` will default to the Cluster Operator’s default Kafka version, and the image will be the one corresponding to this version in the environment variable.
- If `image` is given but `version` is not, then the given image is used and the `version` is assumed to be the Cluster Operator’s default Kafka version.
- If `version` is given but `image` is not, then the image that corresponds to the given version in the environment variable is used.
- If both `version` and `image` are given, then the given image is used. The image is assumed to contain a Kafka image with the given version.

The `image` and `version` for the different components can be configured in the following properties:

- For Kafka in `spec.kafka.image` and `spec.kafka.version`.
- For Kafka Connect, Kafka Connect S2I, and Kafka MirrorMaker in `spec.image` and `spec.version`.

> WARNING：It is recommended to provide only the `version` and leave the `image` property unspecified. This reduces the chance of making a mistake when configuring the custom resource. If you need to change the images used for different versions of Kafka, it is preferable to configure the Cluster Operator’s environment variables.

###### [Configuring the `image` property in other resources](https://strimzi.io/docs/operators/0.18.0/using.html#configuring_the_image_property_in_other_resources_4)

For the `image` property in the other custom resources, the given value will be used during deployment. If the `image` property is missing, the `image` specified in the Cluster Operator configuration will be used. If the `image` name is not defined in the Cluster Operator configuration, then the default value will be used.

- For Kafka broker TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_KAFKA_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For ZooKeeper nodes:
- For ZooKeeper node TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_ZOOKEEPER_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Topic Operator:
  1. Container image specified in the `STRIMZI_DEFAULT_TOPIC_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For User Operator:
  1. Container image specified in the `STRIMZI_DEFAULT_USER_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For Entity Operator TLS sidecar:
  1. Container image specified in the `STRIMZI_DEFAULT_TLS_SIDECAR_ENTITY_OPERATOR_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Kafka Exporter:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_EXPORTER_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka:0.18.0-kafka-2.5.0` container image.
- For Kafka Bridge:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_BRIDGE_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/kafka-bridge:0.16.0` container image.
- For Kafka broker initializer:
  1. Container image specified in the `STRIMZI_DEFAULT_KAFKA_INIT_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.
- For Kafka broker initializer:
  1. Container image specified in the `STRIMZI_DEFAULT_JMXTRANS_IMAGE` environment variable from the Cluster Operator configuration.
  2. `strimzi/operator:0.18.0` container image.

> WARNING：Overriding container images is recommended only in special situations, where you need to use a different container registry. For example, because your network does not allow access to the container repository used by Strimzi. In such case, you should either copy the Strimzi images or build them from source. In case the configured image is not compatible with Strimzi images, it might not work properly.

Example of container image configuration

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    # ...
    image: my-org/my-image:latest
    # ...
  zookeeper:
    # ...
```

##### [Configuring container images](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-container-images-deployment-configuration-kafka-bridge)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `image` property in the `Kafka`, `KafkaConnect` or `KafkaConnectS2I` resource. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       # ...
       image: my-org/my-image:latest
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.11. Configuring pod scheduling](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-scheduling-deployment-configuration-kafka-bridge)

> IMPORTANT：When two applications are scheduled to the same Kubernetes node, both applications might use the same resources like disk I/O and impact performance. That can lead to performance degradation. Scheduling Kafka pods in a way that avoids sharing nodes with other critical workloads, using the right nodes or dedicated a set of nodes only for Kafka are the best ways how to avoid such problems.

##### [Scheduling pods based on other applications](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-scheduling-pods-based-on-other-applications-deployment-configuration-kafka-bridge-scheduling-based-on-pods)

###### [Avoid critical applications to share the node](https://strimzi.io/docs/operators/0.18.0/using.html#con-scheduling-based-on-other-pods-deployment-configuration-kafka-bridge-scheduling-based-on-pods)

Pod anti-affinity can be used to ensure that critical applications are never scheduled on the same disk. When running Kafka cluster, it is recommended to use pod anti-affinity to ensure that the Kafka brokers do not share the nodes with other workloads like databases.

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-bridge-scheduling-based-on-pods)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Configuring pod anti-affinity in Kafka components](https://strimzi.io/docs/operators/0.18.0/using.html#configuring-pod-anti-affinity-in-kafka-components-deployment-configuration-kafka-bridge-scheduling-based-on-pods)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Edit the `affinity` property in the resource specifying the cluster deployment. Use labels to specify the pods which should not be scheduled on the same nodes. The `topologyKey` should be set to `kubernetes.io/hostname` to specify that the selected pods should not be scheduled on nodes with the same hostname. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           affinity:
             podAntiAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 - labelSelector:
                     matchExpressions:
                       - key: application
                         operator: In
                         values:
                           - postgresql
                           - mongodb
                   topologyKey: "kubernetes.io/hostname"
       # ...
     zookeeper:
       # ...
   ```

2. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

##### [Scheduling pods to specific nodes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-node-scheduling-deployment-configuration-kafka-bridge-node-scheduling)

###### [Node scheduling](https://strimzi.io/docs/operators/0.18.0/using.html#con-scheduling-to-specific-nodes-deployment-configuration-kafka-bridge-node-scheduling)

The Kubernetes cluster usually consists of many different types of worker nodes. Some are optimized for CPU heavy workloads, some for memory, while other might be optimized for storage (fast local SSDs) or network. Using different nodes helps to optimize both costs and performance. To achieve the best possible performance, it is important to allow scheduling of Strimzi components to use the right nodes.

Kubernetes uses node affinity to schedule workloads onto specific nodes. Node affinity allows you to create a scheduling constraint for the node on which the pod will be scheduled. The constraint is specified as a label selector. You can specify the label using either the built-in node label like `beta.kubernetes.io/instance-type` or custom labels to select the right node.

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-bridge-node-scheduling)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Configuring node affinity in Kafka components](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-node-affinity-deployment-configuration-kafka-bridge-node-scheduling)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Label the nodes where Strimzi components should be scheduled.

   This can be done using `kubectl label`:

   ```shell
   kubectl label node your-node node-type=fast-network
   ```

   Alternatively, some of the existing labels might be reused.

2. Edit the `affinity` property in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           affinity:
             nodeAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 nodeSelectorTerms:
                   - matchExpressions:
                     - key: node-type
                       operator: In
                       values:
                       - fast-network
       # ...
     zookeeper:
       # ...
   ```

3. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

##### [Using dedicated nodes](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-dedidcated-nodes-deployment-configuration-kafka-bridge-dedicated-nodes)

###### [Dedicated nodes](https://strimzi.io/docs/operators/0.18.0/using.html#con-dedicated-nodes-deployment-configuration-kafka-bridge-dedicated-nodes)

Cluster administrators can mark selected Kubernetes nodes as tainted. Nodes with taints are excluded from regular scheduling and normal pods will not be scheduled to run on them. Only services which can tolerate the taint set on the node can be scheduled on it. The only other services running on such nodes will be system services such as log collectors or software defined networks.

Taints can be used to create dedicated nodes. Running Kafka and its components on dedicated nodes can have many advantages. There will be no other applications running on the same nodes which could cause disturbance or consume the resources needed for Kafka. That can lead to improved performance and stability.

To schedule Kafka pods on the dedicated nodes, configure [node affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-bridge-dedicated-nodes) and [tolerations](https://strimzi.io/docs/operators/0.18.0/using.html#tolerations-deployment-configuration-kafka-bridge-dedicated-nodes).

###### [Affinity](https://strimzi.io/docs/operators/0.18.0/using.html#affinity-deployment-configuration-kafka-bridge-dedicated-nodes)

Affinity can be configured using the `affinity` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The affinity configuration can include different types of affinity:

- Pod affinity and anti-affinity
- Node affinity

The format of the `affinity` property follows the Kubernetes specification. For more details, see the [Kubernetes node and pod affinity documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

###### [Tolerations](https://strimzi.io/docs/operators/0.18.0/using.html#tolerations-deployment-configuration-kafka-bridge-dedicated-nodes)

Tolerations can be configured using the `tolerations` property in following resources:

- `Kafka.spec.kafka.template.pod`
- `Kafka.spec.zookeeper.template.pod`
- `Kafka.spec.entityOperator.template.pod`
- `KafkaConnect.spec.template.pod`
- `KafkaConnectS2I.spec.template.pod`
- `KafkaBridge.spec.template.pod`

The format of the `tolerations` property follows the Kubernetes specification. For more details, see the [Kubernetes taints and tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/).

###### [Setting up dedicated nodes and scheduling pods on them](https://strimzi.io/docs/operators/0.18.0/using.html#proc-dedicated-nodes-deployment-configuration-kafka-bridge-dedicated-nodes)

Prerequisites

- A Kubernetes cluster
- A running Cluster Operator

Procedure

1. Select the nodes which should be used as dedicated.

2. Make sure there are no workloads scheduled on these nodes.

3. Set the taints on the selected nodes:

   This can be done using `kubectl taint`:

   ```shell
   kubectl taint node your-node dedicated=Kafka:NoSchedule
   ```

4. Additionally, add a label to the selected nodes as well.

   This can be done using `kubectl label`:

   ```shell
   kubectl label node your-node dedicated=Kafka
   ```

5. Edit the `affinity` and `tolerations` properties in the resource specifying the cluster deployment. For example:

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   spec:
     kafka:
       # ...
       template:
         pod:
           tolerations:
             - key: "dedicated"
               operator: "Equal"
               value: "Kafka"
               effect: "NoSchedule"
           affinity:
             nodeAffinity:
               requiredDuringSchedulingIgnoredDuringExecution:
                 nodeSelectorTerms:
                 - matchExpressions:
                   - key: dedicated
                     operator: In
                     values:
                     - Kafka
       # ...
     zookeeper:
       # ...
   ```

6. Create or update the resource.

   This can be done using `kubectl apply`:

   ```shell
   kubectl apply -f your-file
   ```

#### [3.5.12. List of resources created as part of Kafka Bridge cluster](https://strimzi.io/docs/operators/0.18.0/using.html#ref-list-of-kafka-bridge-resources-deployment-configuration-kafka-bridge)

The following resources are created by the Cluster Operator in the Kubernetes cluster:

- *bridge-cluster-name*-bridge

  Deployment which is in charge to create the Kafka Bridge worker node pods.

- *bridge-cluster-name*-bridge-service

  Service which exposes the REST interface of the Kafka Bridge cluster.

- *bridge-cluster-name*-bridge-config

  ConfigMap which contains the Kafka Bridge ancillary configuration and is mounted as a volume by the Kafka broker pods.

- *bridge-cluster-name*-bridge

  Pod Disruption Budget configured for the Kafka Bridge worker nodes.


