## [6. Using the User Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-using-the-user-operator-str)

When you create, modify or delete a user using the `KafkaUser` resource, the User Operator ensures those changes are reflected in the Kafka cluster.

### [6.1. Kafka user resource](https://strimzi.io/docs/operators/0.18.0/using.html#ref-kafka-user-str)

The `KafkaUser` resource is used to configure the authentication mechanism, authorization mechanism, and access rights for a user.

The full schema for `KafkaUser` is described in [`KafkaUser` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaUser-reference).

#### [6.1.1. User authentication](https://strimzi.io/docs/operators/0.18.0/using.html#user_authentication)

Authentication is configured using the `authentication` property in `KafkaUser.spec`. The authentication mechanism enabled for the user is specified using the `type` field.

Supported authentication mechanisms:

- TLS client authentication
- SCRAM-SHA-512 authentication

When no authentication mechanism is specified, the User Operator does not create the user or its credentials.

Additional resources

- [When to use mutual TLS authentication for clients](https://strimzi.io/docs/operators/0.18.0/using.html#con-mutual-tls-authentication-deployment-configuration-kafka)
- [When to use SCRAM-SHA Authentication authentication for clients](https://strimzi.io/docs/operators/0.18.0/using.html#con-scram-sha-authentication-deployment-configuration-kafka)

##### [TLS Client Authentication](https://strimzi.io/docs/operators/0.18.0/using.html#tls_client_authentication_5)

To use TLS client authentication, you set the `type` field to `tls`.

An example `KafkaUser` with TLS client authentication enabled

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: tls
  # ...
```

When the user is created by the User Operator, it creates a new Secret with the same name as the `KafkaUser` resource. The Secret contains a private and public key for TLS client authentication. The public key is contained in a user certificate, which is signed by the client Certificate Authority (CA).

All keys are in X.509 format.

Secrets provide private keys and certificates in PEM and PKCS #12 formats. For more information on securing Kafka communication with Secrets, see [Security](https://strimzi.io/docs/operators/0.18.0/using.html#security-str).

An example `Secret` with user credentials

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-user
  labels:
    strimzi.io/kind: KafkaUser
    strimzi.io/cluster: my-cluster
type: Opaque
data:
  ca.crt: # Public key of the client CA
  user.crt: # User certificate that contains the public key of the user
  user.key: # Private key of the user
  user.p12: # PKCS #12 archive file for storing certificates and keys
  user.password: # Password for protecting the PKCS #12 archive file
```

##### [SCRAM-SHA-512 Authentication](https://strimzi.io/docs/operators/0.18.0/using.html#scram_sha_512_authentication_2)

To use SCRAM-SHA-512 authentication mechanism, you set the `type` field to `scram-sha-512`.

An example `KafkaUser` with SCRAM-SHA-512 authentication enabled

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: scram-sha-512
  # ...
```

When the user is created by the User Operator, it creates a new secret with the same name as the `KafkaUser` resource. The secret contains the generated password in the `password` key, which is encoded with base64. In order to use the password, it must be decoded.

An example `Secret` with user credentials

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-user
  labels:
    strimzi.io/kind: KafkaUser
    strimzi.io/cluster: my-cluster
type: Opaque
data:
  password: Z2VuZXJhdGVkcGFzc3dvcmQ= # Generated password
```

Decoding the generated password:

```
echo "Z2VuZXJhdGVkcGFzc3dvcmQ=" | base64 --decode
```

#### [6.1.2. User authorization](https://strimzi.io/docs/operators/0.18.0/using.html#simple-acl-str)

User authorization is configured using the `authorization` property in `KafkaUser.spec`. The authorization type enabled for a user is specified using the `type` field.

If no authorization is specified, the User Operator does not provision any access rights for the user.

To use simple authorization, you set the `type` property to `simple` in `KafkaUser.spec`. Simple authorization uses the default Kafka authorization plugin, `SimpleAclAuthorizer`.

Alternatively, if you are using OAuth 2.0 token based authentication, you can also [configure OAuth 2.0 authorization](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-oauth-authorization_str).

##### ACL rules

`SimpleAclAuthorizer` uses ACL rules to manage access to Kafka brokers.

ACL rules grant access rights to the user, which you specify in the `acls` property.

An `AclRule` is specified as a set of properties:

- `resource`

  The `resource` property specifies the resource that the rule applies to.Simple authorization supports four resource types, which are specified in the `type` property:

  * Topics (`topic`)
  * Consumer Groups (`group`)
  * Clusters (`cluster`)
  * Transactional IDs (`transactionalId`)

  For Topic, Group, and Transactional ID resources you can specify the name of the resource the rule applies to in the `name` property.

  Cluster type resources have no name.

  A name is specified as a `literal` or a `prefix` using the `patternType` property.

  * Literal names are taken exactly as they are specified in the `name` field.
  * Prefix names use the value from the `name` as a prefix, and will apply the rule to all resources with names starting with the value.  

- `type`

  The `type` property specifies the type of ACL rule, `allow` or `deny`.

  The `type` field is optional. If `type` is unspecified, the ACL rule is treated as an `allow` rule.

- `operation`

  The `operation` specifies the operation to allow or deny.

  The following operations are supported:

  * Read
  * Write
  * Delete
  * Alter
  * Describe
  * All
  * IdempotentWrite
  * ClusterAction
  * Create
  * AlterConfigs
  * DescribeConfigs

  Only certain operations work with each resource.

  For more details about `SimpleAclAuthorizer`, ACLs and supported combinations of resources and operations, see [Authorization and ACLs](http://kafka.apache.org/documentation/#security_authz).

- `host`

  The `host` property specifies a remote host from which the rule is allowed or denied.
  
  Use an asterisk (`*`) to allow or deny the operation from all hosts. The `host` field is optional. If `host` is unspecified, the `*` value is used by default.

For more information about the `AclRule` object, see [`AclRule` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-AclRule-reference).

An example `KafkaUser` with authorization

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  # ...
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Read
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
      - resource:
          type: group
          name: my-group
          patternType: prefix
        operation: Read
```

##### [Super user access to Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#super_user_access_to_kafka_brokers)

If a user is added to a list of super users in a Kafka broker configuration, the user is allowed unlimited access to the cluster regardless of any authorization constraints defined in ACLs.  如果将用户添加到Kafka代理配置中的超级用户列表中，则无论ACL中定义的任何授权约束如何，都将允许该用户无限制地访问群集。

For more information on configuring super users, see [authentication and authorization of Kafka brokers](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-authentication-and-authorization-deployment-configuration-kafka).

#### [6.1.3. User quotas](https://strimzi.io/docs/operators/0.18.0/using.html#user_quotas)

You can configure the `spec` for the `KafkaUser` resource to enforce quotas so that a user does not exceed access to Kafka brokers based on a byte threshold or a time limit of CPU utilization.  您可以为KafkaUser资源配置spec以实施配额，以使用户不会超出基于字节阈值或CPU利用率时间限制的对Kafka代理的访问权限。

An example `KafkaUser` with user quotas

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  # ...
  quotas:
    producerByteRate: 1048576 (1)
    consumerByteRate: 2097152 (2)
    requestPercentage: 55 (3)
```

1. Byte-per-second quota on the amount of data the user can push to a Kafka broker
2. Byte-per-second quota on the amount of data the user can fetch from a Kafka broker
3. CPU utilization limit as a percentage of time for a client group

For more information on these properties, see the [`KafkaUserQuotas` schema reference](https://strimzi.io/docs/operators/0.18.0/using.html#type-KafkaUserQuotas-reference)

### [6.2. Configuring a Kafka user](https://strimzi.io/docs/operators/0.18.0/using.html#proc-configuring-kafka-user-str)

Use the properties of the `KafkaUser` resource to configure a Kafka user.

You can use `kubectl apply` to create or modify users, and `kubectl delete` to delete existing users.

For example:

* kubectl apply -f \<user-config-file\>

* kubectl delete KafkaUser \<user-name\>

When you configure the `KafkaUser` authentication and authorization mechanisms, ensure they match the equivalent `Kafka` configuration:

- `KafkaUser.spec.authentication` matches `Kafka.spec.kafka.listeners.*.authentication`
- `KafkaUser.spec.authorization` matches `Kafka.spec.kafka.authorization`

This procedure shows how a user is created with TLS authentication. You can also create a user with SCRAM-SHA authentication.

The authentication required depends on the [type of authentication configured for the Kafka broker listener](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-broker-listener-authentication-deployment-configuration-kafka).

> NOTE Authentication between Kafka users and Kafka brokers depends on the authentication settings for each. For example, it is not possible to authenticate a user with TLS if it is not also enabled in the Kafka configuration. 

Prerequisites

- A running Kafka cluster [configured with a Kafka broker listener using TLS authentication and encryption](https://strimzi.io/docs/operators/0.18.0/using.html#con-mutual-tls-authentication-deployment-configuration-kafka).
- A running User Operator (typically [deployed with the Entity Operator](https://strimzi.io/docs/operators/0.18.0/using.html#assembly-kafka-entity-operator-deployment-configuration-kafka)).

If you are using SCRAM-SHA authentication, you need a running Kafka cluster [configured with a Kafka broker listener using SCRAM-SHA authentication](https://strimzi.io/docs/operators/0.18.0/using.html#con-scram-sha-authentication-deployment-configuration-kafka).

Procedure

1. Prepare a YAML file containing the `KafkaUser` to be created.

   An example `KafkaUser`

   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: KafkaUser
   metadata:
     name: my-user
     labels:
       strimzi.io/cluster: my-cluster
   spec:
     authentication: (1)
       type: tls
     authorization:
       type: simple (2)
       acls:
         - resource:
             type: topic
             name: my-topic
             patternType: literal
           operation: Read
         - resource:
             type: topic
             name: my-topic
             patternType: literal
           operation: Describe
         - resource:
             type: group
             name: my-group
             patternType: literal
           operation: Read
   ```

   1. User authentication mechanism, defined as mutual `tls` or `scram-sha-512`.
   2. Simple authorization, which requires an accompanying list of ACL rules.

2. Create the `KafkaUser` resource in Kubernetes.

   ```shell
   kubectl apply -f <user-config-file>
   ```

3. Use the credentials from the `my-user` secret in your client application.



















```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  labels:
    strimzi.io/cluster: my-cluster
  name: my-user
  namespace: kafka
spec:
  authentication:
    type: scram-sha-512
  authorization:
    acls:
      - host: '*'
        operation: Read
        resource:
          name: my-topic
          patternType: literal
          type: topic
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
      - host: '*'
        operation: Read
        resource:
          name: my-group
          patternType: literal
          type: group
      - host: '*'
        operation: Write
        resource:
          name: my-topic
          patternType: literal
          type: topic
      - host: '*'
        operation: Create
        resource:
          name: my-topic
          patternType: literal
          type: topic
      - host: '*'
        operation: Describe
        resource:
          name: my-topic
          patternType: literal
          type: topic
    type: simple

```

