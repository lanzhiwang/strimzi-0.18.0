## [7. SECURITY](http://kafka.apache.org/25/documentation.html#security)

### [7.1 Security Overview](http://kafka.apache.org/25/documentation.html#security_overview)

In release 0.9.0.0, the Kafka community added a number of features that, used either separately or together, increases security in a Kafka cluster. The following security measures are currently supported:  在0.9.0.0版中，Kafka社区添加了一些功能，这些功能可以单独使用或一起使用，从而提高了Kafka集群的安全性。 当前支持以下安全措施：

1. Authentication of connections to brokers from clients (producers and consumers), other brokers and tools, using either SSL or SASL. Kafka supports the following SASL mechanisms:
   - SASL/GSSAPI (Kerberos) - starting at version 0.9.0.0
   - SASL/PLAIN - starting at version 0.10.0.0
   - SASL/SCRAM-SHA-256 and SASL/SCRAM-SHA-512 - starting at version 0.10.2.0
   - SASL/OAUTHBEARER - starting at version 2.0
2. Authentication of connections from brokers to ZooKeeper
3. Encryption of data transferred between brokers and clients, between brokers, or between brokers and tools using SSL (Note that there is a performance degradation when SSL is enabled, the magnitude of which depends on the CPU type and the JVM implementation.)
4. Authorization of read / write operations by clients
5. Authorization is pluggable and integration with external authorization services is supported

It's worth noting that security is optional - non-secured clusters are supported, as well as a mix of authenticated, unauthenticated, encrypted and non-encrypted clients. The guides below explain how to configure and use the security features in both clients and brokers.  值得注意的是，安全性是可选的-支持不安全的群集，以及经过身份验证，未经身份验证，加密和未加密的客户端的混合。 以下指南说明了如何在客户端和代理中配置和使用安全功能。

### [7.2 Encryption and Authentication using SSL](http://kafka.apache.org/25/documentation.html#security_ssl)

Apache Kafka allows clients to connect over SSL. By default, SSL is disabled but can be turned on as needed.

1. #### [Generate SSL key and certificate for each Kafka broker](http://kafka.apache.org/25/documentation.html#security_ssl_key)

   The first step of deploying one or more brokers with the SSL support is to generate the key and the certificate for each machine in the cluster. You can use Java's keytool utility to accomplish this task. We will generate the key into a temporary keystore initially so that we can export and sign it later with CA.

   ```bash
   keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA
   ```

   You need to specify two parameters in the above command:

   1. keystore: the keystore file that stores the certificate. The keystore file contains the private key of the certificate; therefore, it needs to be kept safely.
   2. validity: the valid time of the certificate in days.

   ##### [Configuring Host Name Verification](http://kafka.apache.org/25/documentation.html#security_confighostname)

   From Kafka version 2.0.0 onwards, host name verification of servers is enabled by default for client connections as well as inter-broker connections to prevent man-in-the-middle attacks. Server host name verification may be disabled by setting `ssl.endpoint.identification.algorithm` to an empty string. For example,  从Kafka 2.0.0版开始，默认情况下会为客户端连接以及代理间连接启用服务器的主机名验证，以防止中间人攻击。 可以通过将ssl.endpoint.identification.algorithm设置为空字符串来禁用服务器主机名验证。 例如，
   ```text
   ssl.endpoint.identification.algorithm=
   ```
   
   For dynamically configured broker listeners, hostname verification may be disabled using `kafka-configs.sh`. For example,
   ```text
   bin/kafka-configs.sh --bootstrap-server localhost:9093 --entity-type brokers --entity-name 0 --alter --add-config "listener.name.internal.ssl.endpoint.identification.algorithm="
   ```
   
   For older versions of Kafka, `ssl.endpoint.identification.algorithm` is not defined by default, so host name verification is not performed. The property should be set to `HTTPS` to enable host name verification.
   ```text
   ssl.endpoint.identification.algorithm=HTTPS 
   ```

   Host name verification must be enabled to prevent man-in-the-middle attacks if server endpoints are not validated externally. 如果未对服务器端点进行外部验证，则必须启用主机名验证，以防止中间人攻击。

   ##### [Configuring Host Name In Certificates](http://kafka.apache.org/25/documentation.html#security_configcerthstname)

   If host name verification is enabled, clients will verify the server's fully qualified domain name (FQDN) against one of the following two fields:  如果启用了主机名验证，则客户端将根据以下两个字段之一验证服务器的标准域名（FQDN）：

   1. Common Name (CN)
   2. Subject Alternative Name (SAN)

   Both fields are valid, RFC-2818 recommends the use of SAN however. SAN is also more flexible, allowing for multiple DNS entries to be declared. Another advantage is that the CN can be set to a more meaningful value for authorization purposes. To add a SAN field append the following argument `-ext SAN=DNS:{FQDN}` to the keytool command:  这两个字段均有效，但是RFC-2818建议使用SAN。 SAN也更加灵活，允许声明多个DNS条目。 另一个优点是可以出于授权目的将CN设置为更有意义的值。 要添加SAN字段，请将以下参数`-ext SAN = DNS：{FQDN}`附加到keytool命令：

   ```bash
   keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA -ext SAN=DNS:{FQDN}
   ```

   The following command can be run afterwards to verify the contents of the generated certificate:

   ```bash
   keytool -list -v -keystore server.keystore.jks
   ```

2. #### [Creating your own CA](http://kafka.apache.org/25/documentation.html#security_ssl_ca)

   After the first step, each machine in the cluster has a public-private key pair, and a certificate to identify the machine. The certificate, however, is unsigned, which means that an attacker can create such a certificate to pretend to be any machine.

   Therefore, it is important to prevent forged certificates by signing them for each machine in the cluster. A certificate authority (CA) is responsible for signing certificates. CA works likes a government that issues passports—the government stamps (signs) each passport so that the passport becomes difficult to forge. Other governments verify the stamps to ensure the passport is authentic. Similarly, the CA signs the certificates, and the cryptography guarantees that a signed certificate is computationally difficult to forge. Thus, as long as the CA is a genuine and trusted authority, the clients have high assurance that they are connecting to the authentic machines.  因此，对群集中的每台计算机进行签名以防止伪造证书很重要。 证书颁发机构（CA）负责签署证书。 CA的工作就像是颁发护照的政府一样，政府会在每本护照上盖章（签名），从而使护照难以伪造。 其他政府则对邮票进行核实，以确保护照是真实的。 同样，CA对证书进行签名，而加密技术则保证了签名的证书在计算上难以伪造。 因此，只要CA是真实可信的授权机构，客户端就可以高度保证他们正在连接到真实计算机。

   ```bash
   openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
   ```

   The generated CA is simply a public-private key pair and certificate, and it is intended to sign other certificates.

   The next step is to add the generated CA to the **clients' truststore** so that the clients can trust this CA:

   ```bash
   keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert
   ```

   Note: If you configure the Kafka brokers to require client authentication by setting ssl.client.auth to be "requested" or "required" on the Kafka brokers config then you must provide a truststore for the Kafka brokers as well and it should have all the CA certificates that clients' keys were signed by.  如果通过在Kafka经纪人配置上将ssl.client.auth设置为“ requested”或“ required”，将Kafka经纪人配置为需要客户端身份验证，则您还必须为Kafka经纪人提供一个信任库，并且它应该具有所有CA 客户密钥签名的证书。

   ```bash
keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert
   ```

   In contrast to the keystore in step 1 that stores each machine's own identity, the truststore of a client stores all the certificates that the client should trust. Importing a certificate into one's truststore also means trusting all certificates that are signed by that certificate. As the analogy above, trusting the government (CA) also means trusting all passports (certificates) that it has issued. This attribute is called the chain of trust, and it is particularly useful when deploying SSL on a large Kafka cluster. You can sign all certificates in the cluster with a single CA, and have all machines share the same truststore that trusts the CA. That way all machines can authenticate all other machines.  与步骤1中存储每台计算机自己的身份的密钥库不同，客户端的信任库存储客户端应信任的所有证书。 将证书导入一个人的信任库还意味着信任该证书签名的所有证书。 与上面的类推类似，信任政府（CA）也意味着信任它已颁发的所有护照（证书）。 此属性称为信任链，在大型Kafka群集上部署SSL时特别有用。 您可以使用单个CA对群集中的所有证书进行签名，并使所有计算机共享信任该CA的同一信任库。 这样，所有计算机都可以对所有其他计算机进行身份验证。

3. #### [Signing the certificate](http://kafka.apache.org/25/documentation.html#security_ssl_signing)

   The next step is to sign all certificates generated by step 1 with the CA generated in step 2. First, you need to export the certificate from the keystore:

   ```bash
   keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file
   ```

   Then sign it with the CA:

   ```bash
   openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days {validity} -CAcreateserial -passin pass:{ca-password}
   ```

   Finally, you need to import both the certificate of the CA and the signed certificate into the keystore:

   ```bash
   keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert
   keytool -keystore server.keystore.jks -alias localhost -import -file cert-signed
   ```

   The definitions of the parameters are the following:

   1. keystore: the location of the keystore
   2. ca-cert: the certificate of the CA
   3. ca-key: the private key of the CA
   4. ca-password: the passphrase of the CA
   5. cert-file: the exported, unsigned certificate of the server
   6. cert-signed: the signed certificate of the server

   Here is an example of a bash script with all above steps. Note that one of the commands assumes a password of `test1234`, so either use that password or edit the command before running it.

   ```bash
   #!/bin/bash
   
   #Step 1
   keytool -keystore server.keystore.jks -alias localhost -validity 365 -keyalg RSA -genkey
   
   #Step 2
   openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
   keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert
   keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert
   
   #Step 3
   keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file
   openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:test1234
   keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert
   keytool -keystore server.keystore.jks -alias localhost -import -file cert-signed
   ```

4. #### [Configuring Kafka Brokers](http://kafka.apache.org/25/documentation.html#security_configbroker)

   Kafka Brokers support listening for connections on multiple ports. We need to configure the following property in server.properties, which must have one or more comma-separated values:

   ```
   listeners
   ```

   If SSL is not enabled for inter-broker communication (see below for how to enable it), both PLAINTEXT and SSL ports will be necessary.  如果未为经纪人之间的通信启用SSL（请参见下面的启用方法），则PLAINTEXT和SSL端口都是必需的。

   ```text
   listeners=PLAINTEXT://host.name:port,SSL://host.name:port
   ```

   Following SSL configs are needed on the broker side

   ```text
   ssl.keystore.location=/var/private/ssl/server.keystore.jks
   ssl.keystore.password=test1234
   ssl.key.password=test1234
   ssl.truststore.location=/var/private/ssl/server.truststore.jks
   ssl.truststore.password=test1234
   ```

   Note: ssl.truststore.password is technically optional but highly recommended. If a password is not set access to the truststore is still available, but integrity checking is disabled. Optional settings that are worth considering:  ssl.truststore.password在技术上是可选的，但强烈建议使用。 如果未设置密码，则仍然可以访问信任库，但是将禁用完整性检查。 值得考虑的可选设置：

   1. ssl.client.auth=none ("required" => client authentication is required, "requested" => client authentication is requested and client without certs can still connect. The usage of "requested" is discouraged as it provides a false sense of security and misconfigured clients will still connect successfully.)  “必需” =>需要客户端身份验证，“已请求” =>已请求客户端身份验证，并且没有证书的客户端仍可以连接。不鼓励使用“请求的”，因为它提供了错误的安全感，并且配置错误的客户端仍将成功连接。
   2. ssl.cipher.suites (Optional). A cipher suite is a named combination of authentication, encryption, MAC and key exchange algorithm used to negotiate the security settings for a network connection using TLS or SSL network protocol. (Default is an empty list)
   3. ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1 (list out the SSL protocols that you are going to accept from clients. Do note that SSL is deprecated in favor of TLS and using SSL in production is not recommended)
   4. ssl.keystore.type=JKS
   5. ssl.truststore.type=JKS
   6. ssl.secure.random.implementation=SHA1PRNG

   If you want to enable SSL for inter-broker communication, add the following to the server.properties file (it defaults to PLAINTEXT)

   ```
   security.inter.broker.protocol=SSL
   ```

   Due to import regulations in some countries, the Oracle implementation limits the strength of cryptographic algorithms available by default. If stronger algorithms are needed (for example, AES with 256-bit keys), the [JCE Unlimited Strength Jurisdiction Policy Files](http://www.oracle.com/technetwork/java/javase/downloads/index.html) must be obtained and installed in the JDK/JRE. See the [JCA Providers Documentation](https://docs.oracle.com/javase/8/docs/technotes/guides/security/SunProviders.html) for more information.  由于某些国家/地区的进口法规，Oracle实施限制了默认情况下可用的加密算法的强度。 如果需要更强大的算法（例如，具有256位密钥的AES），则必须获取JCE无限强度管辖权策略文件并将其安装在JDK / JRE中。 有关更多信息，请参见JCA提供者文档。

   The JRE/JDK will have a default pseudo-random number generator (PRNG) that is used for cryptography operations, so it is not required to configure the implementation used with the  JRE / JDK将具有用于加密操作的默认伪随机数生成器（PRNG），因此不需要配置与 `ssl.secure.random.implementation`. 

   However, there are performance issues with some implementations (notably, the default chosen on Linux systems, `NativePRNG`, utilizes a global lock). In cases where performance of SSL connections becomes an issue, consider explicitly setting the implementation to be used. The `SHA1PRNG` implementation is non-blocking, and has shown very good performance characteristics under heavy load (50 MB/sec of produced messages, plus replication traffic, per-broker).

   Once you start the broker you should be able to see in the server.log

   ```
   with addresses: PLAINTEXT -> EndPoint(192.168.64.1,9092,PLAINTEXT),SSL -> EndPoint(192.168.64.1,9093,SSL)
   ```

   To check quickly if the server keystore and truststore are setup properly you can run the following command  要快速检查服务器密钥库和信任库是否正确设置，可以运行以下命令

   ```
   openssl s_client -debug -connect localhost:9093 -tls1
   ```

   (Note: TLSv1 should be listed under ssl.enabled.protocols)

   In the output of this command you should see server's certificate:

   ```
   -----BEGIN CERTIFICATE-----
   {variable sized random bytes}
   -----END CERTIFICATE-----
   subject=/C=US/ST=CA/L=Santa Clara/O=org/OU=org/CN=Sriharsha Chintalapani
   issuer=/C=US/ST=CA/L=Santa Clara/O=org/OU=org/CN=kafka/emailAddress=test@test.com
   ```

   If the certificate does not show up or if there are any other error messages then your keystore is not setup properly.

5. #### [Configuring Kafka Clients](http://kafka.apache.org/25/documentation.html#security_configclients)

   SSL is supported only for the new Kafka Producer and Consumer, the older API is not supported. The configs for SSL will be the same for both producer and consumer.

   If client authentication is not required in the broker, then the following is a minimal configuration example:

   ```text
   security.protocol=SSL
   ssl.truststore.location=/var/private/ssl/client.truststore.jks
   ssl.truststore.password=test1234
   ```

   Note: ssl.truststore.password is technically optional but highly recommended. If a password is not set access to the truststore is still available, but integrity checking is disabled. If client authentication is required, then a keystore must be created like in step 1 and the following must also be configured:

   ```text
   ssl.keystore.location=/var/private/ssl/client.keystore.jks
   ssl.keystore.password=test1234
   ssl.key.password=test1234
   ```

   Other configuration settings that may also be needed depending on our requirements and the broker configuration:

   1. ssl.provider (Optional). The name of the security provider used for SSL connections. Default value is the default security provider of the JVM.
   2. ssl.cipher.suites (Optional). A cipher suite is a named combination of authentication, encryption, MAC and key exchange algorithm used to negotiate the security settings for a network connection using TLS or SSL network protocol.
   3. ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1. It should list at least one of the protocols configured on the broker side
   4. ssl.truststore.type=JKS
   5. ssl.keystore.type=JKS

   Examples using console-producer and console-consumer:

   ```bash
   kafka-console-producer.sh --bootstrap-server localhost:9093 --topic test --producer.config client-ssl.properties
   
   kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic test --consumer.config client-ssl.properties
   ```


## Authentication using SASL/SCRAM

Salted Challenge Response Authentication Mechanism (SCRAM) is a family of SASL mechanisms that addresses the security concerns with traditional mechanisms that perform username/password authentication like PLAIN and DIGEST-MD5. The mechanism is defined in RFC 5802. Kafka supports SCRAM-SHA-256 and SCRAM-SHA-512 which can be used with TLS to perform secure authentication. The username is used as the authenticated Principal for configuration of ACLs etc. The default SCRAM implementation in Kafka stores SCRAM credentials in Zookeeper and is suitable for use in Kafka installations where Zookeeper is on a private network. Refer to Security Considerations for more details.  盐化挑战响应身份验证机制（SCRAM）是一系列SASL机制，可通过执行用户名/密码身份验证的传统机制（如PLAIN和DIGEST-MD5）解决安全问题。 该机制在RFC 5802中定义。Kafka支持可与TLS一起使用的SCRAM-SHA-256和SCRAM-SHA-512，以执行安全身份验证。 用户名用作配置ACL等的经过验证的主体。Kafka中的默认SCRAM实现在Zookeeper中存储了SCRAM凭据，适用于Zookeeper在专用网络上的Kafka安装。 有关更多详细信息，请参阅安全注意事项。

### 1、Creating SCRAM Credentials

The SCRAM implementation in Kafka uses Zookeeper as credential store. Credentials can be created in Zookeeper using kafka-configs.sh. For each SCRAM mechanism enabled, credentials must be created by adding a config with the mechanism name. Credentials for inter-broker communication must be created before Kafka brokers are started. Client credentials may be created and updated dynamically and updated credentials will be used to authenticate new connections.  Kafka中的SCRAM实现使用Zookeeper作为凭证存储。 可以使用kafka-configs.sh在Zookeeper中创建凭据。 对于启用的每个SCRAM机制，必须通过添加带有机制名称的配置来创建凭据。 在启动Kafka经纪人之前，必须创建经纪人之间的通信凭证。 可以动态创建和更新客户端凭据，更新的凭据将用于验证新连接。

Create SCRAM credentials for user alice with password alice-secret:

```bash
$ bin/kafka-configs.sh --zookeeper localhost:2181 --alter --add-config 'SCRAM-SHA-256=[iterations=8192,password=alice-secret],SCRAM-SHA-512=[password=alice-secret]' --entity-type users --entity-name alice

```

The default iteration count of 4096 is used if iterations are not specified. A random salt is created and the SCRAM identity consisting of salt, iterations, StoredKey and ServerKey are stored in Zookeeper. See RFC 5802 for details on SCRAM identity and the individual fields.  如果未指定迭代，则使用默认的迭代计数4096。 创建一个随机盐，由盐，迭代，StoredKey和ServerKey组成的SCRAM身份存储在Zookeeper中。 有关SCRAM标识和各个字段的详细信息，请参阅RFC 5802。

The following examples also require a user admin for inter-broker communication which can be created using:

```bash
$ bin/kafka-configs.sh --zookeeper localhost:2181 --alter --add-config 'SCRAM-SHA-256=[password=admin-secret],SCRAM-SHA-512=[password=admin-secret]' --entity-type users --entity-name admin

```

Existing credentials may be listed using the --describe option:

```bash
$  bin/kafka-configs.sh --zookeeper localhost:2181 --describe --entity-type users --entity-name alice

```

Credentials may be deleted for one or more SCRAM mechanisms using the --delete option:

```bash
$ bin/kafka-configs.sh --zookeeper localhost:2181 --alter --delete-config 'SCRAM-SHA-512' --entity-type users --entity-name alice

```

### 2、Configuring Kafka Brokers

1. Add a suitably modified JAAS file similar to the one below to each Kafka broker's config directory, let's call it kafka_server_jaas.conf for this example:  在每个Kafka代理的config目录中添加一个经过适当修改的JAAS文件，类似于下面的文件，在此示例中，我们将其称为kafka_server_jaas.conf：

```
KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};

```

The properties username and password in the KafkaServer section are used by the broker to initiate connections to other brokers. In this example, admin is the user for inter-broker communication.

2. Pass the JAAS config file location as JVM parameter to each Kafka broker:

```
-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
```

3. Configure SASL port and SASL mechanisms in server.properties as described here. For example:

```
listeners=SASL_SSL://host.name:port
security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256 (or SCRAM-SHA-512)
sasl.enabled.mechanisms=SCRAM-SHA-256 (or SCRAM-SHA-512)

```

### 3、 Configuring Kafka Clients

To configure SASL authentication on the clients:

1. Configure the JAAS configuration property for each client in producer.properties or consumer.properties. The login module describes how the clients like producer and consumer can connect to the Kafka Broker. The following is an example configuration for a client for the SCRAM mechanisms:  在producer.properties或Consumer.properties中为每个客户端配置JAAS配置属性。 登录模块描述了生产者和消费者等客户如何连接到Kafka Broker。 以下是用于SCRAM机制的客户端的示例配置：

```
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="alice" \
    password="alice-secret";

```

The options username and password are used by clients to configure the user for client connections. In this example, clients connect to the broker as user alice. Different clients within a JVM may connect as different users by specifying different user names and passwords in sasl.jaas.config.

JAAS configuration for clients may alternatively be specified as a JVM parameter similar to brokers as described here. Clients use the login section named KafkaClient. This option allows only one user for all client connections from a JVM.  可以将客户端的JAAS配置指定为类似于此处所述的代理的JVM参数。 客户端使用名为KafkaClient的登录部分。 此选项仅允许一个用户进行来自JVM的所有客户端连接。

2. Configure the following properties in producer.properties or consumer.properties:

```
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-256 (or SCRAM-SHA-512)

```

### 4、Security Considerations for SASL/SCRAM

* The default implementation of SASL/SCRAM in Kafka stores SCRAM credentials in Zookeeper. This is suitable for production use in installations where Zookeeper is secure and on a private network.  Kafka中SASL/SCRAM的默认实现在Zookeeper中存储SCRAM凭据。 这适用于Zookeeper安全且在专用网络上的安装中的生产使用。

* Kafka supports only the strong hash functions SHA-256 and SHA-512 with a minimum iteration count of 4096. Strong hash functions combined with strong passwords and high iteration counts protect against brute force attacks if Zookeeper security is compromised.  Kafka仅支持最小迭代次数为4096的强哈希函数SHA-256和SHA-512。强哈希函数与强密码和高迭代次数结合在一起，可以在Zookeeper安全性受到威胁时抵御暴力攻击。

* SCRAM should be used only with TLS-encryption to prevent interception of SCRAM exchanges. This protects against dictionary or brute force attacks and against impersonation if Zookeeper is compromised.  SCRAM仅应与TLS加密一起使用，以防止侦听SCRAM交换。 如果Zookeeper受到威胁，这可以防止字典或暴力攻击以及冒充他人。

* From Kafka version 2.0 onwards, the default SASL/SCRAM credential store may be overridden using custom callback handlers by configuring `sasl.server.callback.handler.class` in installations where Zookeeper is not secure.

* For more details on security considerations, refer to RFC 5802.


