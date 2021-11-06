```bash



1、原生的 kafka 集群使用的是 9092 端口，目前 ACP 平台通过 cpaas-kafka:9092 这个 services 暴露 kafka 服务，也就是通过 cpaas-kafka:9092 连接 kafka, 如果 operator kafka 也存在的话，通过类似 operator-kafka:9092 services 暴露 kafka 服务，和 cpaas-kafka:9092 不冲突。
2、升级的场景应该理解有偏差，假如我们 acp3.4 支持 operator kafka，3.4 发版的时候默认的值就是 operator-kafka:9092，根本不存在cpaas-kafka:9092 这个服务，如果想使用 operator kafka 必须将平台升级到 3.4，比如将 3.3 升级 3.4，在 3.3 的代码中默认值是 cpaas-kafka:9092，在迁移的过程中会同时存在 cpaas-kafka:9092 和 operator-kafka:9092，迁移完成之后只有 operator-kafka:9092 了，平台也是 3.4 了，并不是在 3.3 中加上额外的补丁或者其他工具将原生的 kafka 换成 operator kafka，是需要和平台升级一起操作的













MySQL [(none)]> create user if not exists 'company_read_only'@'localhost' identified with mysql_native_password by 'company_pass';
Query OK, 0 rows affected (0.01 sec)

MySQL [(none)]>

MySQL [(none)]> select Host, User, plugin, authentication_string from mysql.user;
+-----------+-------------------+-----------------------+-------------------------------------------+
| Host      | User              | plugin                | authentication_string                     |
+-----------+-------------------+-----------------------+-------------------------------------------+
| localhost | root              | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| localhost | mysql.session     | mysql_native_password | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| localhost | mysql.sys         | mysql_native_password | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| %         | root              | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| %         | operator          | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| localhost | xtrabackup        | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| %         | monitor           | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| localhost | clustercheck      | mysql_native_password | *7AEB0CEFBC0276D489F688FBF7CCC22F916A0DEB |
| localhost | company_read_only | mysql_native_password | *EBD9E3BFD1489CA1EB0D2B4F29F6665F321E8C18 |
+-----------+-------------------+-----------------------+-------------------------------------------+
9 rows in set (0.01 sec)

MySQL [(none)]>
MySQL [(none)]> grant all on *.* to 'company_read_only'@'localhost';
Query OK, 0 rows affected (0.01 sec)

MySQL [(none)]>

MySQL [(none)]> show grants for 'company_read_only'@'localhost';
+----------------------------------------------------------------+
| Grants for company_read_only@localhost                         |
+----------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'company_read_only'@'localhost' |
+----------------------------------------------------------------+
1 row in set (0.00 sec)

MySQL [(none)]>

alter user 'company_read_only'@'localhost' identified with mysql_native_password by 'new_company_pass';


MySQL [(none)]>
MySQL [(none)]> alter user 'company_read_only'@'localhost' identified with mysql_native_password by 'new_company_pass';
Query OK, 0 rows affected (0.01 sec)

MySQL [(none)]> select Host, User, plugin, authentication_string from mysql.user;
+-----------+-------------------+-----------------------+-------------------------------------------+
| Host      | User              | plugin                | authentication_string                     |
+-----------+-------------------+-----------------------+-------------------------------------------+
| localhost | root              | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| localhost | mysql.session     | mysql_native_password | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| localhost | mysql.sys         | mysql_native_password | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| %         | root              | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| %         | operator          | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| localhost | xtrabackup        | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| %         | monitor           | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| localhost | clustercheck      | mysql_native_password | *965717B622C2264B6467BBC6591CD888D7269367 |
| localhost | company_read_only | mysql_native_password | *227DCB7FEB643A5B7D9D9DF3EF61CA2CD31BB218 |
+-----------+-------------------+-----------------------+-------------------------------------------+
9 rows in set (0.00 sec)

MySQL [(none)]>
MySQL [(none)]>







[root@ovn1 ~]# kubectl -n xxli logs -f strimzi-cluster-operator-v0.18.0-5bff985fd4-zf696
+ shift
+ export MALLOC_ARENA_MAX=2
+ MALLOC_ARENA_MAX=2
+ JAVA_OPTS=' -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom'
++ get_gc_opts
++ '[' '' == true ']'
++ echo ''
+ JAVA_OPTS=' -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom '
+ exec /usr/bin/tini -w -e 143 -- java -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom -classpath lib/io.strimzi.cluster-operator-0.18.0.jar:lib/io.prometheus.simpleclient_common-0.7.0.jar:lib/io.strimzi.kafka-oauth-client-0.5.0.jar:lib/io.netty.netty-handler-4.1.45.Final.jar:lib/io.netty.netty-codec-http-4.1.45.Final.jar:lib/org.quartz-scheduler.quartz-2.2.1.jar:lib/org.bouncycastle.bcprov-jdk15on-1.60.jar:lib/com.squareup.okio.okio-1.15.0.jar:lib/org.keycloak.keycloak-core-10.0.0.jar:lib/io.netty.netty-buffer-4.1.45.Final.jar:lib/org.yaml.snakeyaml-1.24.jar:lib/io.fabric8.openshift-client-4.6.4.jar:lib/io.netty.netty-common-4.1.45.Final.jar:lib/org.apache.logging.log4j.log4j-api-2.13.0.jar:lib/org.xerial.snappy.snappy-java-1.1.7.3.jar:lib/org.hdrhistogram.HdrHistogram-2.1.11.jar:lib/io.prometheus.simpleclient-0.7.0.jar:lib/com.sun.activation.jakarta.activation-1.2.1.jar:lib/org.apache.yetus.audience-annotations-0.5.0.jar:lib/com.fasterxml.jackson.dataformat.jackson-dataformat-yaml-2.10.2.jar:lib/io.micrometer.micrometer-core-1.3.1.jar:lib/io.netty.netty-codec-4.1.45.Final.jar:lib/org.keycloak.keycloak-common-10.0.0.jar:lib/jakarta.activation.jakarta.activation-api-1.2.1.jar:lib/io.vertx.vertx-core-3.8.5.jar:lib/io.strimzi.certificate-manager-0.18.0.jar:lib/io.strimzi.kafka-oauth-common-0.5.0.jar:lib/io.strimzi.kafka-oauth-server-0.5.0.jar:lib/io.netty.netty-codec-dns-4.1.45.Final.jar:lib/io.fabric8.kubernetes-model-4.6.4.jar:lib/io.netty.netty-codec-socks-4.1.45.Final.jar:lib/com.github.mifmif.generex-1.0.2.jar:lib/io.netty.netty-resolver-4.1.45.Final.jar:lib/com.github.luben.zstd-jni-1.4.4-7.jar:lib/io.netty.netty-handler-proxy-4.1.45.Final.jar:lib/com.squareup.okhttp3.logging-interceptor-3.12.6.jar:lib/io.strimzi.operator-common-0.18.0.jar:lib/org.bouncycastle.bcpkix-jdk15on-1.62.jar:lib/org.lz4.lz4-java-1.7.1.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final-linux-x86_64.jar:lib/io.netty.netty-transport-native-unix-common-4.1.45.Final.jar:lib/dk.brics.automaton.automaton-1.11-8.jar:lib/io.vertx.vertx-micrometer-metrics-3.8.5.jar:lib/org.apache.kafka.kafka-clients-2.5.0.jar:lib/com.fasterxml.jackson.core.jackson-core-2.10.2.jar:lib/org.apache.zookeeper.zookeeper-jute-3.5.7.jar:lib/io.netty.netty-transport-4.1.45.Final.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final.jar:lib/jakarta.xml.bind.jakarta.xml.bind-api-2.3.2.jar:lib/org.apache.logging.log4j.log4j-slf4j-impl-2.13.0.jar:lib/com.fasterxml.jackson.core.jackson-annotations-2.10.2.jar:lib/io.fabric8.zjsonpatch-0.3.0.jar:lib/org.apache.zookeeper.zookeeper-3.5.7.jar:lib/io.strimzi.api-0.18.0.jar:lib/io.fabric8.kubernetes-client-4.6.4.jar:lib/com.fasterxml.jackson.module.jackson-module-jaxb-annotations-2.10.2.jar:lib/com.squareup.okhttp3.okhttp-3.12.6.jar:lib/io.netty.netty-codec-http2-4.1.45.Final.jar:lib/io.strimzi.config-model-0.18.0.jar:lib/org.apache.logging.log4j.log4j-core-2.13.0.jar:lib/io.fabric8.kubernetes-model-common-4.6.4.jar:lib/com.fasterxml.jackson.core.jackson-databind-2.10.2.jar:lib/io.strimzi.crd-annotations-0.18.0.jar:lib/io.netty.netty-resolver-dns-4.1.45.Final.jar:lib/org.slf4j.slf4j-api-1.7.25.jar:lib/org.latencyutils.LatencyUtils-2.0.3.jar:lib/io.micrometer.micrometer-registry-prometheus-1.3.1.jar io.strimzi.operator.cluster.Main
2021-01-13 02:43:14 INFO  Main:60 - ClusterOperator 0.18.0 is starting
2021-01-13 02:43:57 ERROR PlatformFeaturesAvailability:124 - Detection of Kubernetes version failed.
io.fabric8.kubernetes.client.KubernetesClientException: An error has occurred.
	at io.fabric8.kubernetes.client.KubernetesClientException.launderThrowable(KubernetesClientException.java:64) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.KubernetesClientException.launderThrowable(KubernetesClientException.java:53) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.dsl.internal.ClusterOperationsImpl.fetchVersion(ClusterOperationsImpl.java:51) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.DefaultKubernetesClient.getVersion(DefaultKubernetesClient.java:293) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.strimzi.operator.PlatformFeaturesAvailability.lambda$getVersionInfoFromKubernetes$5(PlatformFeaturesAvailability.java:122) ~[io.strimzi.operator-common-0.18.0.jar:0.18.0]
	at io.vertx.core.impl.ContextImpl.lambda$executeBlocking$2(ContextImpl.java:316) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.TaskQueue.run(TaskQueue.java:76) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [?:1.8.0_275]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [?:1.8.0_275]
	at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_275]
Caused by: javax.net.ssl.SSLPeerUnverifiedException: Hostname fc00:1f00::1 not verified:
    certificate: sha256/1qAsz0h71m1mvzfdBS7uDhEDq9Cl0OXK8lTbzdL96qM=
    DN: CN=kube-apiserver
    subjectAltNames: [fc00:1f00:0:0:0:0:0:1, 192.168.31.150, 127.0.0.1, 192.168.31.150, fc00:1f00:0:0:0:0:0:1, 2102:db6:0:0:0:0:0:6, ovn1, kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local, localhost]
	at okhttp3.internal.connection.RealConnection.connectTls(RealConnection.java:334) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.RealConnection.establishProtocol(RealConnection.java:284) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.RealConnection.connect(RealConnection.java:169) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.findConnection(StreamAllocation.java:258) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.findHealthyConnection(StreamAllocation.java:135) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.newStream(StreamAllocation.java:114) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.ConnectInterceptor.intercept(ConnectInterceptor.java:42) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.cache.CacheInterceptor.intercept(CacheInterceptor.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.BridgeInterceptor.intercept(BridgeInterceptor.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RetryAndFollowUpInterceptor.intercept(RetryAndFollowUpInterceptor.java:127) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.BackwardsCompatibilityInterceptor.intercept(BackwardsCompatibilityInterceptor.java:119) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.ImpersonatorInterceptor.intercept(ImpersonatorInterceptor.java:68) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.HttpClientUtils.lambda$createHttpClient$3(HttpClientUtils.java:111) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.RealCall.getResponseWithInterceptorChain(RealCall.java:257) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.RealCall.execute(RealCall.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.dsl.internal.ClusterOperationsImpl.fetchVersion(ClusterOperationsImpl.java:46) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	... 8 more
2021-01-13 02:43:58 ERROR Main:94 - Failed to gather environment facts
io.fabric8.kubernetes.client.KubernetesClientException: An error has occurred.
	at io.fabric8.kubernetes.client.KubernetesClientException.launderThrowable(KubernetesClientException.java:64) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.KubernetesClientException.launderThrowable(KubernetesClientException.java:53) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.dsl.internal.ClusterOperationsImpl.fetchVersion(ClusterOperationsImpl.java:51) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.fabric8.kubernetes.client.DefaultKubernetesClient.getVersion(DefaultKubernetesClient.java:293) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at io.strimzi.operator.PlatformFeaturesAvailability.lambda$getVersionInfoFromKubernetes$5(PlatformFeaturesAvailability.java:122) ~[io.strimzi.operator-common-0.18.0.jar:0.18.0]
	at io.vertx.core.impl.ContextImpl.lambda$executeBlocking$2(ContextImpl.java:316) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.TaskQueue.run(TaskQueue.java:76) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) ~[?:1.8.0_275]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) ~[?:1.8.0_275]
	at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_275]
Caused by: javax.net.ssl.SSLPeerUnverifiedException: Hostname fc00:1f00::1 not verified:
    certificate: sha256/1qAsz0h71m1mvzfdBS7uDhEDq9Cl0OXK8lTbzdL96qM=
    DN: CN=kube-apiserver
    subjectAltNames: [fc00:1f00:0:0:0:0:0:1, 192.168.31.150, 127.0.0.1, 192.168.31.150, fc00:1f00:0:0:0:0:0:1, 2102:db6:0:0:0:0:0:6, ovn1, kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local, localhost]
	at okhttp3.internal.connection.RealConnection.connectTls(RealConnection.java:334) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.RealConnection.establishProtocol(RealConnection.java:284) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.RealConnection.connect(RealConnection.java:169) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.findConnection(StreamAllocation.java:258) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.findHealthyConnection(StreamAllocation.java:135) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.StreamAllocation.newStream(StreamAllocation.java:114) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.connection.ConnectInterceptor.intercept(ConnectInterceptor.java:42) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.cache.CacheInterceptor.intercept(CacheInterceptor.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.BridgeInterceptor.intercept(BridgeInterceptor.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RetryAndFollowUpInterceptor.intercept(RetryAndFollowUpInterceptor.java:127) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.BackwardsCompatibilityInterceptor.intercept(BackwardsCompatibilityInterceptor.java:119) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.ImpersonatorInterceptor.intercept(ImpersonatorInterceptor.java:68) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.utils.HttpClientUtils.lambda$createHttpClient$3(HttpClientUtils.java:111) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:147) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.internal.http.RealInterceptorChain.proceed(RealInterceptorChain.java:121) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.RealCall.getResponseWithInterceptorChain(RealCall.java:257) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at okhttp3.RealCall.execute(RealCall.java:93) ~[com.squareup.okhttp3.okhttp-3.12.6.jar:?]
	at io.fabric8.kubernetes.client.dsl.internal.ClusterOperationsImpl.fetchVersion(ClusterOperationsImpl.java:46) ~[io.fabric8.kubernetes-client-4.6.4.jar:?]
	... 8 more
[root@ovn1 ~]#

192.168.34.233:600/3rdparty/operators-index:v3.0.1-463.g6f95eba
harbor-b.alauda.cn/3rdparty/operators-index:v3.0.1-463.g6f95eba






[root@arm-region-0003 ~]# kubectl -n xxli logs strimzi-cluster-operator-v0.18.0-665744b74d-46cq8
+ shift
+ export MALLOC_ARENA_MAX=2
+ MALLOC_ARENA_MAX=2
+ JAVA_OPTS=' -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom'
++ get_gc_opts
++ '[' '' == true ']'
++ echo ''
+ JAVA_OPTS=' -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom '
+ exec /usr/bin/tini -w -e 143 -- java -Dvertx.cacheDirBase=/tmp -Djava.security.egd=file:/dev/./urandom -classpath lib/io.strimzi.cluster-operator-0.18.0.jar:lib/io.prometheus.simpleclient_common-0.7.0.jar:lib/io.strimzi.kafka-oauth-client-0.5.0.jar:lib/io.netty.netty-handler-4.1.45.Final.jar:lib/io.netty.netty-codec-http-4.1.45.Final.jar:lib/org.quartz-scheduler.quartz-2.2.1.jar:lib/org.bouncycastle.bcprov-jdk15on-1.60.jar:lib/com.squareup.okio.okio-1.15.0.jar:lib/org.keycloak.keycloak-core-10.0.0.jar:lib/io.netty.netty-buffer-4.1.45.Final.jar:lib/org.yaml.snakeyaml-1.24.jar:lib/io.fabric8.openshift-client-4.6.4.jar:lib/io.netty.netty-common-4.1.45.Final.jar:lib/org.apache.logging.log4j.log4j-api-2.13.0.jar:lib/org.xerial.snappy.snappy-java-1.1.7.3.jar:lib/org.hdrhistogram.HdrHistogram-2.1.11.jar:lib/io.prometheus.simpleclient-0.7.0.jar:lib/com.sun.activation.jakarta.activation-1.2.1.jar:lib/org.apache.yetus.audience-annotations-0.5.0.jar:lib/com.fasterxml.jackson.dataformat.jackson-dataformat-yaml-2.10.2.jar:lib/io.micrometer.micrometer-core-1.3.1.jar:lib/io.netty.netty-codec-4.1.45.Final.jar:lib/org.keycloak.keycloak-common-10.0.0.jar:lib/jakarta.activation.jakarta.activation-api-1.2.1.jar:lib/io.vertx.vertx-core-3.8.5.jar:lib/io.strimzi.certificate-manager-0.18.0.jar:lib/io.strimzi.kafka-oauth-common-0.5.0.jar:lib/io.strimzi.kafka-oauth-server-0.5.0.jar:lib/io.netty.netty-codec-dns-4.1.45.Final.jar:lib/io.fabric8.kubernetes-model-4.6.4.jar:lib/io.netty.netty-codec-socks-4.1.45.Final.jar:lib/com.github.mifmif.generex-1.0.2.jar:lib/io.netty.netty-resolver-4.1.45.Final.jar:lib/com.github.luben.zstd-jni-1.4.4-7.jar:lib/io.netty.netty-handler-proxy-4.1.45.Final.jar:lib/com.squareup.okhttp3.logging-interceptor-3.12.6.jar:lib/io.strimzi.operator-common-0.18.0.jar:lib/org.bouncycastle.bcpkix-jdk15on-1.62.jar:lib/org.lz4.lz4-java-1.7.1.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final-linux-x86_64.jar:lib/io.netty.netty-transport-native-unix-common-4.1.45.Final.jar:lib/dk.brics.automaton.automaton-1.11-8.jar:lib/io.vertx.vertx-micrometer-metrics-3.8.5.jar:lib/org.apache.kafka.kafka-clients-2.5.0.jar:lib/com.fasterxml.jackson.core.jackson-core-2.10.2.jar:lib/org.apache.zookeeper.zookeeper-jute-3.5.7.jar:lib/io.netty.netty-transport-4.1.45.Final.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final.jar:lib/jakarta.xml.bind.jakarta.xml.bind-api-2.3.2.jar:lib/org.apache.logging.log4j.log4j-slf4j-impl-2.13.0.jar:lib/com.fasterxml.jackson.core.jackson-annotations-2.10.2.jar:lib/io.fabric8.zjsonpatch-0.3.0.jar:lib/org.apache.zookeeper.zookeeper-3.5.7.jar:lib/io.strimzi.api-0.18.0.jar:lib/io.fabric8.kubernetes-client-4.6.4.jar:lib/com.fasterxml.jackson.module.jackson-module-jaxb-annotations-2.10.2.jar:lib/com.squareup.okhttp3.okhttp-3.12.6.jar:lib/io.netty.netty-codec-http2-4.1.45.Final.jar:lib/io.strimzi.config-model-0.18.0.jar:lib/org.apache.logging.log4j.log4j-core-2.13.0.jar:lib/io.fabric8.kubernetes-model-common-4.6.4.jar:lib/com.fasterxml.jackson.core.jackson-databind-2.10.2.jar:lib/io.strimzi.crd-annotations-0.18.0.jar:lib/io.netty.netty-resolver-dns-4.1.45.Final.jar:lib/org.slf4j.slf4j-api-1.7.25.jar:lib/org.latencyutils.LatencyUtils-2.0.3.jar:lib/io.micrometer.micrometer-registry-prometheus-1.3.1.jar io.strimzi.operator.cluster.Main
2021-01-13 10:09:49 INFO  Main:60 - ClusterOperator 0.18.0 is starting
2021-01-13 10:09:50 INFO  Main:85 - Environment facts gathered: ClusterOperatorConfig(KubernetesVersion=1.16,OpenShiftRoutes=false,OpenShiftBuilds=false,OpenShiftImageStreams=false,OpenShiftDeploymentConfigs=false)
2021-01-13 10:09:50 INFO  Util:262 - Using config:
	PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
	ACID_MINIMAL_CLUSTER_PORT_9187_TCP_ADDR: 10.4.116.211
	ACID_MINIMAL_CLUSTER_REPL_SERVICE_PORT_EXPORTER: 9187
	ACID_MINIMAL_CLUSTER_SERVICE_PORT_EXPORTER: 9187
	STRIMZI_DEFAULT_TOPIC_OPERATOR_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/operator:0.18.0
	ACID_MINIMAL_CLUSTER_PORT: tcp://10.4.116.211:5432
	ACID_MINIMAL_CLUSTER_PORT_9187_TCP_PORT: 9187
	ACID_MINIMAL_CLUSTER_REPL_SERVICE_HOST: 10.4.57.10
	ACID_MINIMAL_CLUSTER_REPL_SERVICE_PORT_POSTGRESQL: 5432
	ACID_MINIMAL_CLUSTER_REPL_PORT_9187_TCP_PROTO: tcp
	STRIMZI_DEFAULT_TLS_SIDECAR_KAFKA_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
	STRIMZI_HOME: /opt/strimzi
	PWD: /opt/strimzi
	KUBERNETES_PORT_443_TCP: tcp://10.4.0.1:443
	JAVA_MAIN: io.strimzi.operator.cluster.Main
	ACID_MINIMAL_CLUSTER_REPL_SERVICE_PORT: 5432
	ACID_MINIMAL_CLUSTER_REPL_PORT_5432_TCP_PORT: 5432
	ACID_MINIMAL_CLUSTER_PORT_5432_TCP_PORT: 5432
	STRIMZI_VERSION: 0.18.0
	STRIMZI_DEFAULT_JMXTRANS_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/jmxtrans:0.18.0
	STRIMZI_NAMESPACE: xxli
	ACID_MINIMAL_CLUSTER_PORT_5432_TCP_PROTO: tcp
	ACID_MINIMAL_CLUSTER_SERVICE_HOST: 10.4.116.211
	ACID_MINIMAL_CLUSTER_SERVICE_PORT: 5432
	STRIMZI_LOG_LEVEL: INFO
	KUBERNETES_SERVICE_PORT_HTTPS: 443
	SHLVL: 0
	STRIMZI_DEFAULT_KAFKA_BRIDGE_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.16.0/kafka-bridge:0.16.0
	STRIMZI_KAFKA_MIRROR_MAKER_IMAGES: 2.4.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.0
2.4.1=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.1
2.5.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0

	KUBERNETES_PORT: tcp://10.4.0.1:443
	ACID_MINIMAL_CLUSTER_REPL_PORT_9187_TCP_ADDR: 10.4.57.10
	STRIMZI_FULL_RECONCILIATION_INTERVAL_MS: 120000
	KUBERNETES_SERVICE_HOST: 10.4.0.1
	JAVA_CLASSPATH: lib/io.strimzi.cluster-operator-0.18.0.jar:lib/io.prometheus.simpleclient_common-0.7.0.jar:lib/io.strimzi.kafka-oauth-client-0.5.0.jar:lib/io.netty.netty-handler-4.1.45.Final.jar:lib/io.netty.netty-codec-http-4.1.45.Final.jar:lib/org.quartz-scheduler.quartz-2.2.1.jar:lib/org.bouncycastle.bcprov-jdk15on-1.60.jar:lib/com.squareup.okio.okio-1.15.0.jar:lib/org.keycloak.keycloak-core-10.0.0.jar:lib/io.netty.netty-buffer-4.1.45.Final.jar:lib/org.yaml.snakeyaml-1.24.jar:lib/io.fabric8.openshift-client-4.6.4.jar:lib/io.netty.netty-common-4.1.45.Final.jar:lib/org.apache.logging.log4j.log4j-api-2.13.0.jar:lib/org.xerial.snappy.snappy-java-1.1.7.3.jar:lib/org.hdrhistogram.HdrHistogram-2.1.11.jar:lib/io.prometheus.simpleclient-0.7.0.jar:lib/com.sun.activation.jakarta.activation-1.2.1.jar:lib/org.apache.yetus.audience-annotations-0.5.0.jar:lib/com.fasterxml.jackson.dataformat.jackson-dataformat-yaml-2.10.2.jar:lib/io.micrometer.micrometer-core-1.3.1.jar:lib/io.netty.netty-codec-4.1.45.Final.jar:lib/org.keycloak.keycloak-common-10.0.0.jar:lib/jakarta.activation.jakarta.activation-api-1.2.1.jar:lib/io.vertx.vertx-core-3.8.5.jar:lib/io.strimzi.certificate-manager-0.18.0.jar:lib/io.strimzi.kafka-oauth-common-0.5.0.jar:lib/io.strimzi.kafka-oauth-server-0.5.0.jar:lib/io.netty.netty-codec-dns-4.1.45.Final.jar:lib/io.fabric8.kubernetes-model-4.6.4.jar:lib/io.netty.netty-codec-socks-4.1.45.Final.jar:lib/com.github.mifmif.generex-1.0.2.jar:lib/io.netty.netty-resolver-4.1.45.Final.jar:lib/com.github.luben.zstd-jni-1.4.4-7.jar:lib/io.netty.netty-handler-proxy-4.1.45.Final.jar:lib/com.squareup.okhttp3.logging-interceptor-3.12.6.jar:lib/io.strimzi.operator-common-0.18.0.jar:lib/org.bouncycastle.bcpkix-jdk15on-1.62.jar:lib/org.lz4.lz4-java-1.7.1.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final-linux-x86_64.jar:lib/io.netty.netty-transport-native-unix-common-4.1.45.Final.jar:lib/dk.brics.automaton.automaton-1.11-8.jar:lib/io.vertx.vertx-micrometer-metrics-3.8.5.jar:lib/org.apache.kafka.kafka-clients-2.5.0.jar:lib/com.fasterxml.jackson.core.jackson-core-2.10.2.jar:lib/org.apache.zookeeper.zookeeper-jute-3.5.7.jar:lib/io.netty.netty-transport-4.1.45.Final.jar:lib/io.netty.netty-transport-native-epoll-4.1.45.Final.jar:lib/jakarta.xml.bind.jakarta.xml.bind-api-2.3.2.jar:lib/org.apache.logging.log4j.log4j-slf4j-impl-2.13.0.jar:lib/com.fasterxml.jackson.core.jackson-annotations-2.10.2.jar:lib/io.fabric8.zjsonpatch-0.3.0.jar:lib/org.apache.zookeeper.zookeeper-3.5.7.jar:lib/io.strimzi.api-0.18.0.jar:lib/io.fabric8.kubernetes-client-4.6.4.jar:lib/com.fasterxml.jackson.module.jackson-module-jaxb-annotations-2.10.2.jar:lib/com.squareup.okhttp3.okhttp-3.12.6.jar:lib/io.netty.netty-codec-http2-4.1.45.Final.jar:lib/io.strimzi.config-model-0.18.0.jar:lib/org.apache.logging.log4j.log4j-core-2.13.0.jar:lib/io.fabric8.kubernetes-model-common-4.6.4.jar:lib/com.fasterxml.jackson.core.jackson-databind-2.10.2.jar:lib/io.strimzi.crd-annotations-0.18.0.jar:lib/io.netty.netty-resolver-dns-4.1.45.Final.jar:lib/org.slf4j.slf4j-api-1.7.25.jar:lib/org.latencyutils.LatencyUtils-2.0.3.jar:lib/io.micrometer.micrometer-registry-prometheus-1.3.1.jar
	ACID_MINIMAL_CLUSTER_SERVICE_PORT_POSTGRESQL: 5432
	ACID_MINIMAL_CLUSTER_PORT_9187_TCP_PROTO: tcp
	STRIMZI_KAFKA_CONNECT_S2I_IMAGES: 2.4.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.0
2.4.1=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.1
2.5.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0

	ACID_MINIMAL_CLUSTER_REPL_PORT_5432_TCP_ADDR: 10.4.57.10
	TINI_VERSION: v0.18.0
	STRIMZI_DEFAULT_TLS_SIDECAR_CRUISE_CONTROL_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
	STRIMZI_DEFAULT_CRUISE_CONTROL_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
	ACID_MINIMAL_CLUSTER_REPL_PORT_9187_TCP_PORT: 9187
	ACID_MINIMAL_CLUSTER_REPL_PORT_5432_TCP_PROTO: tcp
	STRIMZI_OPERATION_TIMEOUT_MS: 300000
	KUBERNETES_PORT_443_TCP_ADDR: 10.4.0.1
	ACID_MINIMAL_CLUSTER_REPL_PORT_5432_TCP: tcp://10.4.57.10:5432
	ACID_MINIMAL_CLUSTER_PORT_9187_TCP: tcp://10.4.116.211:9187
	ACID_MINIMAL_CLUSTER_PORT_5432_TCP_ADDR: 10.4.116.211
	STRIMZI_KAFKA_MIRROR_MAKER_2_IMAGES: 2.4.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.0
2.4.1=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.1
2.5.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0

	KUBERNETES_PORT_443_TCP_PROTO: tcp
	STRIMZI_DEFAULT_USER_OPERATOR_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/operator:0.18.0
	ACID_MINIMAL_CLUSTER_PORT_5432_TCP: tcp://10.4.116.211:5432
	KUBERNETES_SERVICE_PORT: 443
	STRIMZI_DEFAULT_KAFKA_EXPORTER_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
	STRIMZI_DEFAULT_KAFKA_INIT_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/operator:0.18.0
	ACID_MINIMAL_CLUSTER_REPL_PORT_9187_TCP: tcp://10.4.57.10:9187
	HOSTNAME: strimzi-cluster-operator-v0.18.0-665744b74d-46cq8
	STRIMZI_KAFKA_CONNECT_IMAGES: 2.4.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.0
2.4.1=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.1
2.5.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0

	ACID_MINIMAL_CLUSTER_REPL_PORT: tcp://10.4.57.10:5432
	STRIMZI_KAFKA_IMAGES: 2.4.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.0
2.4.1=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.4.1
2.5.0=harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0

	KUBERNETES_PORT_443_TCP_PORT: 443
	STRIMZI_DEFAULT_TLS_SIDECAR_ENTITY_OPERATOR_IMAGE: harbor-b.alauda.cn/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
	HOME: /home/strimzi
	MALLOC_ARENA_MAX: 2

2021-01-13 10:09:50 INFO  Main:126 - The KafkaConnectS2I custom resource definition can only be used in environment which supports OpenShift build, image and apps APIs. These APIs do not seem to be supported in this environment.
2021-01-13 10:09:50 INFO  ClusterOperator:87 - Creating ClusterOperator for namespace xxli
2021-01-13 10:09:50 INFO  ClusterOperator:105 - Starting ClusterOperator for namespace xxli
2021-01-13 10:09:50 INFO  ClusterOperator:119 - Opened watch for Kafka operator
2021-01-13 10:09:50 INFO  ClusterOperator:119 - Opened watch for KafkaMirrorMaker operator
2021-01-13 10:09:50 INFO  ClusterOperator:119 - Opened watch for KafkaConnect operator
2021-01-13 10:09:50 INFO  ClusterOperator:119 - Opened watch for KafkaBridge operator
2021-01-13 10:09:51 INFO  ClusterOperator:119 - Opened watch for KafkaMirrorMaker2 operator
2021-01-13 10:09:51 INFO  ClusterOperator:130 - Setting up periodic reconciliation for namespace xxli
2021-01-13 10:09:51 INFO  ClusterOperator:192 - ClusterOperator is now ready (health server listening on 8080)
2021-01-13 10:09:51 INFO  Main:159 - Cluster Operator verticle started in namespace xxli
2021-01-13 10:10:54 INFO  OperatorWatcher:40 - Reconciliation #0(watch) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer in namespace xxli was ADDED
2021-01-13 10:10:54 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkas' with unstable version 'v1beta1'
2021-01-13 10:10:54 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:10:54 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:10:54 INFO  AbstractOperator:173 - Reconciliation #0(watch) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer should be created or updated
2021-01-13 10:10:54 INFO  OperatorWatcher:40 - Reconciliation #1(watch) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer in namespace xxli was MODIFIED
2021-01-13 10:10:56 WARN  VersionUsageUtils:60 - The client is using resource type 'poddisruptionbudgets' with unstable version 'v1beta1'
2021-01-13 10:11:04 WARN  AbstractOperator:247 - Reconciliation #1(watch) Kafka(xxli/my-cluster-consumer): Failed to acquire lock lock::xxli::Kafka::my-cluster-consumer within 10000ms.
2021-01-13 10:11:16 INFO  OperatorWatcher:40 - Reconciliation #2(watch) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer in namespace xxli was ADDED
2021-01-13 10:11:16 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:11:16 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:11:16 INFO  AbstractOperator:173 - Reconciliation #2(watch) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer should be created or updated
2021-01-13 10:11:16 INFO  OperatorWatcher:40 - Reconciliation #3(watch) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer in namespace xxli was MODIFIED
2021-01-13 10:11:26 WARN  AbstractOperator:247 - Reconciliation #3(watch) Kafka(xxli/my-cluster-producer): Failed to acquire lock lock::xxli::Kafka::my-cluster-producer within 10000ms.
2021-01-13 10:11:51 INFO  ClusterOperator:132 - Triggering periodic reconciliation for namespace xxli...
2021-01-13 10:11:51 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkamirrormakers' with unstable version 'v1beta1'
2021-01-13 10:11:51 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkaconnects' with unstable version 'v1beta1'
2021-01-13 10:11:51 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkamirrormaker2s' with unstable version 'v1alpha1'
2021-01-13 10:11:51 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkabridges' with unstable version 'v1alpha1'
2021-01-13 10:11:51 WARN  VersionUsageUtils:60 - The client is using resource type 'kafkarebalances' with unstable version 'v1alpha1'
2021-01-13 10:12:01 WARN  AbstractOperator:247 - Reconciliation #4(timer) Kafka(xxli/my-cluster-consumer): Failed to acquire lock lock::xxli::Kafka::my-cluster-consumer within 10000ms.
2021-01-13 10:12:01 WARN  AbstractOperator:247 - Reconciliation #5(timer) Kafka(xxli/my-cluster-producer): Failed to acquire lock lock::xxli::Kafka::my-cluster-producer within 10000ms.
2021-01-13 10:12:25 INFO  OperatorWatcher:40 - Reconciliation #6(watch) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer in namespace xxli was MODIFIED
2021-01-13 10:12:25 INFO  AbstractOperator:318 - Reconciliation #0(watch) Kafka(xxli/my-cluster-consumer): reconciled
2021-01-13 10:12:25 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:12:25 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:12:25 INFO  AbstractOperator:173 - Reconciliation #6(watch) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer should be created or updated
2021-01-13 10:12:27 INFO  AbstractOperator:318 - Reconciliation #6(watch) Kafka(xxli/my-cluster-consumer): reconciled
2021-01-13 10:12:32 INFO  AbstractOperator:318 - Reconciliation #2(watch) Kafka(xxli/my-cluster-producer): reconciled
2021-01-13 10:12:32 INFO  OperatorWatcher:40 - Reconciliation #7(watch) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer in namespace xxli was MODIFIED
2021-01-13 10:12:32 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:12:32 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:12:32 INFO  AbstractOperator:173 - Reconciliation #7(watch) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer should be created or updated
2021-01-13 10:12:34 INFO  AbstractOperator:318 - Reconciliation #7(watch) Kafka(xxli/my-cluster-producer): reconciled
2021-01-13 10:13:51 INFO  ClusterOperator:132 - Triggering periodic reconciliation for namespace xxli...
2021-01-13 10:13:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:13:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:13:51 INFO  AbstractOperator:173 - Reconciliation #8(timer) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer should be created or updated
2021-01-13 10:13:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:13:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:13:51 INFO  AbstractOperator:173 - Reconciliation #9(timer) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer should be created or updated
2021-01-13 10:13:53 INFO  AbstractOperator:318 - Reconciliation #8(timer) Kafka(xxli/my-cluster-consumer): reconciled
2021-01-13 10:13:53 INFO  AbstractOperator:318 - Reconciliation #9(timer) Kafka(xxli/my-cluster-producer): reconciled
2021-01-13 10:15:51 INFO  ClusterOperator:132 - Triggering periodic reconciliation for namespace xxli...
2021-01-13 10:15:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:15:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-consumer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:15:51 INFO  AbstractOperator:173 - Reconciliation #10(timer) Kafka(xxli/my-cluster-consumer): Kafka my-cluster-consumer should be created or updated
2021-01-13 10:15:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.kafka.jmxOptions with unknown properties: -Xms, -Xmx
2021-01-13 10:15:51 WARN  AbstractOperator:106 - Kafka resource my-cluster-producer in namespace xxli: Contains object at path spec.zookeeper with an unknown property: jmxOptions
2021-01-13 10:15:51 INFO  AbstractOperator:173 - Reconciliation #11(timer) Kafka(xxli/my-cluster-producer): Kafka my-cluster-producer should be created or updated
2021-01-13 10:15:53 INFO  AbstractOperator:318 - Reconciliation #10(timer) Kafka(xxli/my-cluster-consumer): reconciled
2021-01-13 10:15:53 INFO  AbstractOperator:318 - Reconciliation #11(timer) Kafka(xxli/my-cluster-producer): reconciled
[root@arm-region-0003 ~]#



```













KafkaMirrorMaker2







In order to test the function of KafkaMirrorMaker2, I created the simplest kafka and KafkaMirrorMaker2 in the same k8s cluster.

```
$ cat my-cluster-source.yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster-source
  namespace: xxli
spec:
  entityOperator:
    topicOperator: {}
    userOperator: {}
  kafka:
    config:
      log.message.format.version: '2.5'
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
    jmxOptions:
      '-Xms': 8192m
      '-Xmx': 8192m
    listeners:
      plain: {}
      tls: {}
    replicas: 3
    resources:
      limits:
        cpu: '1'
        memory: 1Gi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral
    version: 2.5.0
  zookeeper:
    jmxOptions:
      '-Xms': 4096m
      '-Xmx': 4096m
    replicas: 3
    resources:
      limits:
        cpu: '1'
        memory: 1000Mi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral


$ cat my-cluster-target.yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster-target
  namespace: xxli
spec:
  entityOperator:
    topicOperator: {}
    userOperator: {}
  kafka:
    config:
      log.message.format.version: '2.5'
      offsets.topic.replication.factor: 3
      transaction.state.log.min.isr: 2
      transaction.state.log.replication.factor: 3
    jmxOptions:
      '-Xms': 8192m
      '-Xmx': 8192m
    listeners:
      plain: {}
      tls: {}
    replicas: 3
    resources:
      limits:
        cpu: '1'
        memory: 1Gi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral
    version: 2.5.0
  zookeeper:
    jmxOptions:
      '-Xms': 4096m
      '-Xmx': 4096m
    replicas: 3
    resources:
      limits:
        cpu: '1'
        memory: 1000Mi
      requests:
        cpu: 500m
        memory: 500Mi
    storage:
      type: ephemeral


$ cat my-mm2-cluster.yaml
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaMirrorMaker2
metadata:
  name: my-mm2-cluster
spec:
  version: 2.5.0
  replicas: 1
  connectCluster: "my-cluster-target"
  clusters:
  - alias: "my-cluster-source"
    bootstrapServers: my-cluster-source-kafka-bootstrap:9092
  - alias: "my-cluster-target"
    bootstrapServers: my-cluster-target-kafka-bootstrap:9092
    config:
      config.storage.replication.factor: 1
      offset.storage.replication.factor: 1
      status.storage.replication.factor: 1
  mirrors:
  - sourceCluster: "my-cluster-source"
    targetCluster: "my-cluster-target"
    sourceConnector:
      config:
        replication.factor: 1
        offset-syncs.topic.replication.factor: 1
        sync.topic.acls.enabled: "false"
    heartbeatConnector:
      config:
        heartbeats.topic.replication.factor: 1
    checkpointConnector:
      config:
        checkpoints.topic.replication.factor: 1
    topicsPattern: ".*"
    groupsPattern: ".*"

```

The created pod is always in CrashLoopBackOff state, and the three topics of `heartbeats`, `mm2-offset-syncs.my-cluster-target.internal`, and `my-cluster-source.checkpoints.internal` cannot be successfully created automatically.

```bash
$ kubectl -n xxli get pods
NAME                                                 READY   STATUS             RESTARTS   AGE
my-cluster-source-entity-operator-7bd5b46dfc-5lt57   3/3     Running            0          14m
my-cluster-source-kafka-0                            2/2     Running            0          15m
my-cluster-source-kafka-1                            2/2     Running            0          14m
my-cluster-source-kafka-2                            2/2     Running            0          14m
my-cluster-source-zookeeper-0                        1/1     Running            0          15m
my-cluster-source-zookeeper-1                        1/1     Running            0          15m
my-cluster-source-zookeeper-2                        1/1     Running            0          15m
my-cluster-target-entity-operator-5bd6b89bd5-45z2m   3/3     Running            0          14m
my-cluster-target-kafka-0                            2/2     Running            0          14m
my-cluster-target-kafka-1                            2/2     Running            0          14m
my-cluster-target-kafka-2                            2/2     Running            0          14m
my-cluster-target-zookeeper-0                        1/1     Running            0          15m
my-cluster-target-zookeeper-1                        1/1     Running            0          15m
my-cluster-target-zookeeper-2                        1/1     Running            0          15m
my-mm2-cluster-mirrormaker2-7c7b6d5d54-qplsc         0/1     CrashLoopBackOff   6          13m
strimzi-cluster-operator-v0.18.0-665744b74d-2cwmg    1/1     Running            0          16m

$ kubectl -n xxli get kafkatopic
NAME                                                          PARTITIONS   REPLICATION FACTOR
consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a   50           3
mirrormaker2-cluster-configs                                  1            1
mirrormaker2-cluster-offsets                                  25           1
mirrormaker2-cluster-status                                   5            1
$

```

pod log:

```bash
$ kubectl -n xxli describe pods my-mm2-cluster-mirrormaker2-7c7b6d5d54-qplsc
Name:         my-mm2-cluster-mirrormaker2-7c7b6d5d54-qplsc
Namespace:    xxli
Priority:     0
Node:         192.168.34.154/192.168.34.154
Start Time:   Wed, 13 Jan 2021 21:17:06 +0800
Labels:       app.kubernetes.io/instance=my-mm2-cluster
              app.kubernetes.io/managed-by=strimzi-cluster-operator
              app.kubernetes.io/name=kafka-mirror-maker-2
              app.kubernetes.io/part-of=strimzi-my-mm2-cluster
              pod-template-hash=7c7b6d5d54
              strimzi.io/cluster=my-mm2-cluster
              strimzi.io/kind=KafkaMirrorMaker2
              strimzi.io/name=my-mm2-cluster-mirrormaker2
Annotations:  kubernetes.io/psp: 20-user-restricted
              ovn.kubernetes.io/allocated: true
              ovn.kubernetes.io/cidr: 10.3.0.0/16
              ovn.kubernetes.io/gateway: 10.3.0.1
              ovn.kubernetes.io/ip_address: 10.3.8.175
              ovn.kubernetes.io/logical_switch: ovn-default
              ovn.kubernetes.io/mac_address: 00:00:00:DA:B8:4B
              ovn.kubernetes.io/network_types: geneve
              ovn.kubernetes.io/routed: true
              strimzi.io/logging:
                # Do not change this generated file. Logging can be configured in the corresponding kubernetes/openshift resource.
                log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
                log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
                log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} %p %m (%c) [%t]%n
                connect.root.logger.level=INFO
                log4j.rootLogger=${connect.root.logger.level}, CONSOLE
                log4j.logger.org.apache.zookeeper=ERROR
                log4j.logger.org.I0Itec.zkclient=ERROR
                log4j.logger.org.reflections=ERROR
Status:       Running
IP:           10.3.8.175
IPs:
  IP:           10.3.8.175
Controlled By:  ReplicaSet/my-mm2-cluster-mirrormaker2-7c7b6d5d54
Containers:
  my-mm2-cluster-mirrormaker2:
    Container ID:  docker://2c66493c7d7521fc36c943684180f64b81ac6145cc6b55618f13344215701ebc
    Image:         192.168.34.233:60080/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0
    Image ID:      docker-pullable://192.168.34.233:60080/tdsql/kafka/release/0.18.0/kafka@sha256:58244d8b1922b8630d5fc1079bd0c5ace32dcd37e6004fd8dfff9814b3b96e6f
    Port:          8083/TCP
    Host Port:     0/TCP
    Command:
      /opt/kafka/kafka_mirror_maker_2_run.sh
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 13 Jan 2021 21:30:24 +0800
      Finished:     Wed, 13 Jan 2021 21:31:49 +0800
    Ready:          False
    Restart Count:  7
    Liveness:       http-get http://:rest-api/ delay=60s timeout=5s period=10s #success=1 #failure=3
    Readiness:      http-get http://:rest-api/ delay=60s timeout=5s period=10s #success=1 #failure=3
    Environment:
      KAFKA_CONNECT_CONFIGURATION:      config.storage.topic=mirrormaker2-cluster-configs
                                        group.id=mirrormaker2-cluster
                                        status.storage.topic=mirrormaker2-cluster-status
                                        config.providers.file.class=org.apache.kafka.common.config.provider.FileConfigProvider
                                        offset.storage.topic=mirrormaker2-cluster-offsets
                                        config.providers=file
                                        value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
                                        key.converter=org.apache.kafka.connect.converters.ByteArrayConverter
                                        config.storage.replication.factor=1
                                        offset.storage.replication.factor=1
                                        status.storage.replication.factor=1

      KAFKA_CONNECT_METRICS_ENABLED:    false
      KAFKA_CONNECT_BOOTSTRAP_SERVERS:  my-cluster-target-kafka-bootstrap:9092
      STRIMZI_KAFKA_GC_LOG_ENABLED:     false
      KAFKA_HEAP_OPTS:                  -Xms128M
      KAFKA_MIRRORMAKER_2_CLUSTERS:     my-cluster-source;my-cluster-target
    Mounts:
      /opt/kafka/custom-config/ from kafka-metrics-and-logging (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from my-mm2-cluster-mirrormaker2-token-fbr65 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kafka-metrics-and-logging:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      my-mm2-cluster-mirrormaker2-config
    Optional:  false
  my-mm2-cluster-mirrormaker2-token-fbr65:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  my-mm2-cluster-mirrormaker2-token-fbr65
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 30s
                 node.kubernetes.io/unreachable:NoExecute for 30s
Events:
  Type     Reason     Age                    From                     Message
  ----     ------     ----                   ----                     -------
  Normal   Scheduled  <unknown>              default-scheduler        Successfully assigned xxli/my-mm2-cluster-mirrormaker2-7c7b6d5d54-qplsc to 192.168.34.154
  Normal   Pulled     15m (x3 over 18m)      kubelet, 192.168.34.154  Container image "192.168.34.233:60080/tdsql/kafka/release/0.18.0/kafka:0.18.0-kafka-2.5.0" already present on machine
  Normal   Created    15m (x3 over 18m)      kubelet, 192.168.34.154  Created container my-mm2-cluster-mirrormaker2
  Normal   Started    15m (x3 over 18m)      kubelet, 192.168.34.154  Started container my-mm2-cluster-mirrormaker2
  Normal   Killing    15m (x2 over 16m)      kubelet, 192.168.34.154  Container my-mm2-cluster-mirrormaker2 failed liveness probe, will be restarted
  Warning  Unhealthy  13m (x6 over 17m)      kubelet, 192.168.34.154  Readiness probe failed: Get http://10.3.8.175:8083/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
  Warning  Unhealthy  8m6s (x19 over 17m)    kubelet, 192.168.34.154  Liveness probe failed: Get http://10.3.8.175:8083/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
  Warning  BackOff    3m9s (x18 over 7m46s)  kubelet, 192.168.34.154  Back-off restarting failed container
[root@arm-region-0003 ~]#


$ kubectl -n xxli describe  KafkaMirrorMaker2 my-mm2-cluster
Name:         my-mm2-cluster
Namespace:    xxli
Labels:       <none>
Annotations:  <none>
API Version:  kafka.strimzi.io/v1alpha1
Kind:         KafkaMirrorMaker2
Metadata:
  Creation Timestamp:  2021-01-13T13:17:06Z
  Generation:          1
  Resource Version:    444648
  Self Link:           /apis/kafka.strimzi.io/v1alpha1/namespaces/xxli/kafkamirrormaker2s/my-mm2-cluster
  UID:                 c4acf972-0c5d-4cdb-85d8-dbbc04c84968
Spec:
  Clusters:
    Alias:              my-cluster-source
    Bootstrap Servers:  my-cluster-source-kafka-bootstrap:9092
    Alias:              my-cluster-target
    Bootstrap Servers:  my-cluster-target-kafka-bootstrap:9092
    Config:
      config.storage.replication.factor:  1
      offset.storage.replication.factor:  1
      status.storage.replication.factor:  1
  Connect Cluster:                        my-cluster-target
  Mirrors:
    Checkpoint Connector:
      Config:
        checkpoints.topic.replication.factor:  1
    Groups Pattern:                            .*
    Heartbeat Connector:
      Config:
        heartbeats.topic.replication.factor:  1
    Source Cluster:                           my-cluster-source
    Source Connector:
      Config:
        offset-syncs.topic.replication.factor:  1
        replication.factor:                     1
        sync.topic.acls.enabled:                false
    Target Cluster:                             my-cluster-target
    Topics Pattern:                             .*
  Replicas:                                     1
  Version:                                      2.5.0
Status:
  Conditions:
    Last Transition Time:  2021-01-13T13:22:07.584Z
    Message:               Exceeded timeout of 300000ms while waiting for Deployment resource my-mm2-cluster-mirrormaker2 in namespace xxli to be ready
    Reason:                TimeoutException
    Status:                True
    Type:                  NotReady
  Observed Generation:     1
  URL:                     http://my-mm2-cluster-mirrormaker2-api.xxli.svc:8083
Events:                    <none>


$ kubectl -n xxli logs my-mm2-cluster-mirrormaker2-7c7b6d5d54-qplsc
Preparing MirrorMaker 2.0 cluster truststores and keystores
Preparing MirrorMaker 2.0 truststores and keystores for cluster my-cluster-source
  with trusted certs
  with tls auth certs
  with tls auth keys
Preparing MirrorMaker 2.0 truststores and keystores for cluster my-cluster-target
  with trusted certs
  with tls auth certs
  with tls auth keys
Preparing MirrorMaker 2.0 cluster truststores is complete
Creating connector configuration:








Preparing truststore
Preparing truststore is complete
Starting Kafka Connect with configuration:
# Bootstrap servers
bootstrap.servers=my-cluster-target-kafka-bootstrap:9092
# REST Listeners
rest.port=8083
rest.advertised.host.name=10.3.8.175
rest.advertised.port=8083
# Plugins
plugin.path=/opt/kafka/plugins
# Provided configuration
config.storage.topic=mirrormaker2-cluster-configs
group.id=mirrormaker2-cluster
status.storage.topic=mirrormaker2-cluster-status
config.providers.file.class=org.apache.kafka.common.config.provider.FileConfigProvider
offset.storage.topic=mirrormaker2-cluster-offsets
config.providers=file
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter
config.storage.replication.factor=1
offset.storage.replication.factor=1
status.storage.replication.factor=1


security.protocol=PLAINTEXT
producer.security.protocol=PLAINTEXT
consumer.security.protocol=PLAINTEXT
admin.security.protocol=PLAINTEXT




OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThre
ads=N
2021-01-13 13:20:10,941 INFO WorkerInfo values:
	jvm.args = -Xms128M, -XX:+UseG1GC, -XX:MaxGCPauseMillis=20, -XX:InitiatingHeapOccupancyPercent=35, -XX:+ExplicitGCInvokesConcurrent, -XX:MaxInlineLevel=15, -Djava.awt.headless=true, -Dco
m.sun.management.jmxremote, -Dcom.sun.management.jmxremote.authenticate=false, -Dcom.sun.management.jmxremote.ssl=false, -Dkafka.logs.dir=/opt/kafka, -Dlog4j.configuration=file:/opt/kafka/custom
-config/log4j.properties
	jvm.spec = Red Hat, Inc., OpenJDK 64-Bit Server VM, 1.8.0_275, 25.275-b01
	jvm.classpath = /opt/kafka/bin/../libs/activation-1.1.1.jar:/opt/kafka/bin/../libs/annotations-13.0.jar:/opt/kafka/bin/../libs/aopalliance-repackaged-2.5.0.jar:/opt/kafka/bin/../libs/arg
parse4j-0.7.0.jar:/opt/kafka/bin/../libs/audience-annotations-0.5.0.jar:/opt/kafka/bin/../libs/bcpkix-jdk15on-1.62.jar:/opt/kafka/bin/../libs/bcprov-jdk15on-1.60.jar:/opt/kafka/bin/../libs/commo
ns-cli-1.4.jar:/opt/kafka/bin/../libs/commons-lang-2.6.jar:/opt/kafka/bin/../libs/commons-lang3-3.8.1.jar:/opt/kafka/bin/../libs/connect-api-2.5.0.jar:/opt/kafka/bin/../libs/connect-basic-auth-e
xtension-2.5.0.jar:/opt/kafka/bin/../libs/connect-file-2.5.0.jar:/opt/kafka/bin/../libs/connect-json-2.5.0.jar:/opt/kafka/bin/../libs/connect-mirror-2.5.0.jar:/opt/kafka/bin/../libs/connect-mirr
or-client-2.5.0.jar:/opt/kafka/bin/../libs/connect-runtime-2.5.0.jar:/opt/kafka/bin/../libs/connect-transforms-2.5.0.jar:/opt/kafka/bin/../libs/cruise-control-metrics-reporter-2.0.103.jar:/opt/k
afka/bin/../libs/gson-2.8.6.jar:/opt/kafka/bin/../libs/hk2-api-2.5.0.jar:/opt/kafka/bin/../libs/hk2-locator-2.5.0.jar:/opt/kafka/bin/../libs/hk2-utils-2.5.0.jar:/opt/kafka/bin/../libs/jackson-an
notations-2.10.2.jar:/opt/kafka/bin/../libs/jackson-core-2.10.2.jar:/opt/kafka/bin/../libs/jackson-databind-2.10.2.jar:/opt/kafka/bin/../libs/jackson-dataformat-csv-2.10.2.jar:/opt/kafka/bin/../
libs/jackson-datatype-jdk8-2.10.2.jar:/opt/kafka/bin/../libs/jackson-jaxrs-base-2.10.2.jar:/opt/kafka/bin/../libs/jackson-jaxrs-json-provider-2.10.2.jar:/opt/kafka/bin/../libs/jackson-module-jax
b-annotations-2.10.2.jar:/opt/kafka/bin/../libs/jackson-module-paranamer-2.10.2.jar:/opt/kafka/bin/../libs/jackson-module-scala_2.12-2.10.2.jar:/opt/kafka/bin/../libs/jaeger-client-1.1.0.jar:/op
t/kafka/bin/../libs/jaeger-core-1.1.0.jar:/opt/kafka/bin/../libs/jaeger-thrift-1.1.0.jar:/opt/kafka/bin/../libs/jaeger-tracerresolver-1.1.0.jar:/opt/kafka/bin/../libs/jakarta.activation-api-1.2.
1.jar:/opt/kafka/bin/../libs/jakarta.annotation-api-1.3.4.jar:/opt/kafka/bin/../libs/jakarta.inject-2.5.0.jar:/opt/kafka/bin/../libs/jakarta.ws.rs-api-2.1.5.jar:/opt/kafka/bin/../libs/jakarta.xm
l.bind-api-2.3.2.jar:/opt/kafka/bin/../libs/javassist-3.22.0-CR2.jar:/opt/kafka/bin/../libs/javassist-3.26.0-GA.jar:/opt/kafka/bin/../libs/javax.servlet-api-3.1.0.jar:/opt/kafka/bin/../libs/java
x.ws.rs-api-2.1.1.jar:/opt/kafka/bin/../libs/jaxb-api-2.3.0.jar:/opt/kafka/bin/../libs/jersey-client-2.28.jar:/opt/kafka/bin/../libs/jersey-common-2.28.jar:/opt/kafka/bin/../libs/jersey-containe
r-servlet-2.28.jar:/opt/kafka/bin/../libs/jersey-container-servlet-core-2.28.jar:/opt/kafka/bin/../libs/jersey-hk2-2.28.jar:/opt/kafka/bin/../libs/jersey-media-jaxb-2.28.jar:/opt/kafka/bin/../li
bs/jersey-server-2.28.jar:/opt/kafka/bin/../libs/jetty-client-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-continuation-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-http-9.4.24.v201911
20.jar:/opt/kafka/bin/../libs/jetty-io-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-security-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-server-9.4.24.v20191120.jar:/opt/kafka/bin/../
libs/jetty-servlet-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-servlets-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jetty-util-9.4.24.v20191120.jar:/opt/kafka/bin/../libs/jmx_prometheus_ja
vaagent-0.12.0.jar:/opt/kafka/bin/../libs/jopt-simple-5.0.4.jar:/opt/kafka/bin/../libs/json-smart-1.1.1.jar:/opt/kafka/bin/../libs/jsonevent-layout-1.7.jar:/opt/kafka/bin/../libs/kafka-agent.jar
:/opt/kafka/bin/../libs/kafka-clients-2.5.0.jar:/opt/kafka/bin/../libs/kafka-log4j-appender-2.5.0.jar:/opt/kafka/bin/../libs/kafka-oauth-client-0.5.0.jar:/opt/kafka/bin/../libs/kafka-oauth-commo
n-0.5.0.jar:/opt/kafka/bin/../libs/kafka-oauth-keycloak-authorizer-0.5.0.jar:/opt/kafka/bin/../libs/kafka-oauth-server-0.5.0.jar:/opt/kafka/bin/../libs/kafka-streams-2.5.0.jar:/opt/kafka/bin/../
libs/kafka-streams-examples-2.5.0.jar:/opt/kafka/bin/../libs/kafka-streams-scala_2.12-2.5.0.jar:/opt/kafka/bin/../libs/kafka-streams-test-utils-2.5.0.jar:/opt/kafka/bin/../libs/kafka-tools-2.5.0
.jar:/opt/kafka/bin/../libs/kafka_2.12-2.5.0-sources.jar:/opt/kafka/bin/../libs/kafka_2.12-2.5.0.jar:/opt/kafka/bin/../libs/keycloak-common-10.0.0.jar:/opt/kafka/bin/../libs/keycloak-core-10.0.0
.jar:/opt/kafka/bin/../libs/kotlin-stdlib-1.3.50.jar:/opt/kafka/bin/../libs/kotlin-stdlib-common-1.3.50.jar:/opt/kafka/bin/../libs/libthrift-0.13.0.jar:/opt/kafka/bin/../libs/log4j-1.2.17.jar:/o
pt/kafka/bin/../libs/lz4-java-1.7.1.jar:/opt/kafka/bin/../libs/maven-artifact-3.6.3.jar:/opt/kafka/bin/../libs/metrics-core-2.2.0.jar:/opt/kafka/bin/../libs/mirror-maker-agent.jar:/opt/kafka/bin
/../libs/netty-buffer-4.1.45.Final.jar:/opt/kafka/bin/../libs/netty-codec-4.1.45.Final.jar:/opt/kafka/bin/../libs/netty-common-4.1.45.Final.jar:/opt/kafka/bin/../libs/netty-handler-4.1.45.Final.
jar:/opt/kafka/bin/../libs/netty-resolver-4.1.45.Final.jar:/opt/kafka/bin/../libs/netty-transport-4.1.45.Final.jar:/opt/kafka/bin/../libs/netty-transport-native-epoll-4.1.45.Final.jar:/opt/kafka
/bin/../libs/netty-transport-native-unix-common-4.1.45.Final.jar:/opt/kafka/bin/../libs/okhttp-4.2.2.jar:/opt/kafka/bin/../libs/okio-2.2.2.jar:/opt/kafka/bin/../libs/opentracing-api-0.33.0.jar:/
opt/kafka/bin/../libs/opentracing-kafka-client-0.1.12.jar:/opt/kafka/bin/../libs/opentracing-noop-0.33.0.jar:/opt/kafka/bin/../libs/opentracing-tracerresolver-0.1.8.jar:/opt/kafka/bin/../libs/op
entracing-util-0.33.0.jar:/opt/kafka/bin/../libs/osgi-resource-locator-1.0.1.jar:/opt/kafka/bin/../libs/paranamer-2.8.jar:/opt/kafka/bin/../libs/plexus-utils-3.2.1.jar:/opt/kafka/bin/../libs/ref
lections-0.9.12.jar:/opt/kafka/bin/../libs/rocksdbjni-5.18.3.jar:/opt/kafka/bin/../libs/scala-collection-compat_2.12-2.1.3.jar:/opt/kafka/bin/../libs/scala-java8-compat_2.12-0.9.0.jar:/opt/kafka
/bin/../libs/scala-library-2.12.10.jar:/opt/kafka/bin/../libs/scala-logging_2.12-3.9.2.jar:/opt/kafka/bin/../libs/scala-reflect-2.12.10.jar:/opt/kafka/bin/../libs/slf4j-api-1.7.30.jar:/opt/kafka
/bin/../libs/slf4j-log4j12-1.7.30.jar:/opt/kafka/bin/../libs/snappy-java-1.1.7.3.jar:/opt/kafka/bin/../libs/tracing-agent.jar:/opt/kafka/bin/../libs/validation-api-2.0.1.Final.jar:/opt/kafka/bin
/../libs/zookeeper-3.5.7.jar:/opt/kafka/bin/../libs/zookeeper-jute-3.5.7.jar:/opt/kafka/bin/../libs/zstd-jni-1.4.4-7.jar
	os.spec = Linux, aarch64, 4.19.36-vhulk1905.1.0.h273.eulerosv2r8.aarch64
	os.vcpus = 1
 (org.apache.kafka.connect.runtime.WorkerInfo) [main]
2021-01-13 13:20:10,945 INFO Scanning for plugin classes. This might take a moment ... (org.apache.kafka.connect.cli.ConnectDistributed) [main]
2021-01-13 13:20:15,416 INFO Registered loader: sun.misc.Launcher$AppClassLoader@764c12b6 (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,416 INFO Added plugin 'org.apache.kafka.connect.mirror.MirrorSourceConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,416 INFO Added plugin 'org.apache.kafka.connect.file.FileStreamSinkConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,416 INFO Added plugin 'org.apache.kafka.connect.tools.SchemaSourceConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.tools.MockSourceConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.file.FileStreamSourceConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.mirror.MirrorCheckpointConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.tools.VerifiableSinkConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.tools.VerifiableSourceConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.tools.MockSinkConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.mirror.MirrorHeartbeatConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.tools.MockConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,417 INFO Added plugin 'org.apache.kafka.connect.converters.FloatConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.converters.DoubleConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.converters.ByteArrayConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.converters.LongConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.converters.IntegerConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.json.JsonConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.storage.StringConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.converters.ShortConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.storage.SimpleHeaderConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.ReplaceField$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.SetSchemaMetadata$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.ReplaceField$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.InsertField$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.TimestampConverter$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.MaskField$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.TimestampRouter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.RegexRouter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.HoistField$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.ValueToKey' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.MaskField$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.Cast$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.Cast$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.ExtractField$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.Flatten$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.InsertField$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.Flatten$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.SetSchemaMetadata$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.ExtractField$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.TimestampConverter$Value' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.transforms.HoistField$Key' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.common.config.provider.FileConfigProvider' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,418 INFO Added plugin 'org.apache.kafka.connect.rest.basic.auth.extension.BasicAuthSecurityRestExtension' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [
main]
2021-01-13 13:20:15,419 INFO Added plugin 'org.apache.kafka.connect.connector.policy.AllConnectorClientConfigOverridePolicy' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [m
ain]
2021-01-13 13:20:15,419 INFO Added plugin 'org.apache.kafka.connect.connector.policy.PrincipalConnectorClientConfigOverridePolicy' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoad
er) [main]
2021-01-13 13:20:15,419 INFO Added plugin 'org.apache.kafka.connect.connector.policy.NoneConnectorClientConfigOverridePolicy' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [
main]
2021-01-13 13:20:15,420 INFO Added aliases 'FileStreamSinkConnector' and 'FileStreamSink' to plugin 'org.apache.kafka.connect.file.FileStreamSinkConnector' (org.apache.kafka.connect.runtime.isol
ation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,420 INFO Added aliases 'FileStreamSourceConnector' and 'FileStreamSource' to plugin 'org.apache.kafka.connect.file.FileStreamSourceConnector' (org.apache.kafka.connect.runtim
e.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,420 INFO Added aliases 'MirrorCheckpointConnector' and 'MirrorCheckpoint' to plugin 'org.apache.kafka.connect.mirror.MirrorCheckpointConnector' (org.apache.kafka.connect.runt
ime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,420 INFO Added aliases 'MirrorHeartbeatConnector' and 'MirrorHeartbeat' to plugin 'org.apache.kafka.connect.mirror.MirrorHeartbeatConnector' (org.apache.kafka.connect.runtime
.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,420 INFO Added aliases 'MirrorSourceConnector' and 'MirrorSource' to plugin 'org.apache.kafka.connect.mirror.MirrorSourceConnector' (org.apache.kafka.connect.runtime.isolatio
n.DelegatingClassLoader) [main]
2021-01-13 13:20:15,420 INFO Added aliases 'MockConnector' and 'Mock' to plugin 'org.apache.kafka.connect.tools.MockConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader)
[main]
2021-01-13 13:20:15,422 INFO Added aliases 'MockSinkConnector' and 'MockSink' to plugin 'org.apache.kafka.connect.tools.MockSinkConnector' (org.apache.kafka.connect.runtime.isolation.DelegatingC
lassLoader) [main]
2021-01-13 13:20:15,422 INFO Added aliases 'MockSourceConnector' and 'MockSource' to plugin 'org.apache.kafka.connect.tools.MockSourceConnector' (org.apache.kafka.connect.runtime.isolation.Deleg
atingClassLoader) [main]
2021-01-13 13:20:15,422 INFO Added aliases 'SchemaSourceConnector' and 'SchemaSource' to plugin 'org.apache.kafka.connect.tools.SchemaSourceConnector' (org.apache.kafka.connect.runtime.isolation
.DelegatingClassLoader) [main]
2021-01-13 13:20:15,422 INFO Added aliases 'VerifiableSinkConnector' and 'VerifiableSink' to plugin 'org.apache.kafka.connect.tools.VerifiableSinkConnector' (org.apache.kafka.connect.runtime.iso
lation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,422 INFO Added aliases 'VerifiableSourceConnector' and 'VerifiableSource' to plugin 'org.apache.kafka.connect.tools.VerifiableSourceConnector' (org.apache.kafka.connect.runti
me.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'ByteArrayConverter' and 'ByteArray' to plugin 'org.apache.kafka.connect.converters.ByteArrayConverter' (org.apache.kafka.connect.runtime.isolation.Del
egatingClassLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'DoubleConverter' and 'Double' to plugin 'org.apache.kafka.connect.converters.DoubleConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingCl
assLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'FloatConverter' and 'Float' to plugin 'org.apache.kafka.connect.converters.FloatConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'IntegerConverter' and 'Integer' to plugin 'org.apache.kafka.connect.converters.IntegerConverter' (org.apache.kafka.connect.runtime.isolation.Delegatin
gClassLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'LongConverter' and 'Long' to plugin 'org.apache.kafka.connect.converters.LongConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoa
der) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'ShortConverter' and 'Short' to plugin 'org.apache.kafka.connect.converters.ShortConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'JsonConverter' and 'Json' to plugin 'org.apache.kafka.connect.json.JsonConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [
main]
2021-01-13 13:20:15,423 INFO Added aliases 'StringConverter' and 'String' to plugin 'org.apache.kafka.connect.storage.StringConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'ByteArrayConverter' and 'ByteArray' to plugin 'org.apache.kafka.connect.converters.ByteArrayConverter' (org.apache.kafka.connect.runtime.isolation.Del
egatingClassLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'DoubleConverter' and 'Double' to plugin 'org.apache.kafka.connect.converters.DoubleConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingCl
assLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'FloatConverter' and 'Float' to plugin 'org.apache.kafka.connect.converters.FloatConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'IntegerConverter' and 'Integer' to plugin 'org.apache.kafka.connect.converters.IntegerConverter' (org.apache.kafka.connect.runtime.isolation.Delegatin
gClassLoader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'LongConverter' and 'Long' to plugin 'org.apache.kafka.connect.converters.LongConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoa
der) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'ShortConverter' and 'Short' to plugin 'org.apache.kafka.connect.converters.ShortConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,423 INFO Added aliases 'JsonConverter' and 'Json' to plugin 'org.apache.kafka.connect.json.JsonConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [
main]
2021-01-13 13:20:15,423 INFO Added alias 'SimpleHeaderConverter' to plugin 'org.apache.kafka.connect.storage.SimpleHeaderConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoa
der) [main]
2021-01-13 13:20:15,424 INFO Added aliases 'StringConverter' and 'String' to plugin 'org.apache.kafka.connect.storage.StringConverter' (org.apache.kafka.connect.runtime.isolation.DelegatingClass
Loader) [main]
2021-01-13 13:20:15,424 INFO Added alias 'RegexRouter' to plugin 'org.apache.kafka.connect.transforms.RegexRouter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,424 INFO Added alias 'TimestampRouter' to plugin 'org.apache.kafka.connect.transforms.TimestampRouter' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [mai
n]
2021-01-13 13:20:15,424 INFO Added alias 'ValueToKey' to plugin 'org.apache.kafka.connect.transforms.ValueToKey' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,424 INFO Added alias 'BasicAuthSecurityRestExtension' to plugin 'org.apache.kafka.connect.rest.basic.auth.extension.BasicAuthSecurityRestExtension' (org.apache.kafka.connect.
runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,424 INFO Added aliases 'AllConnectorClientConfigOverridePolicy' and 'All' to plugin 'org.apache.kafka.connect.connector.policy.AllConnectorClientConfigOverridePolicy' (org.ap
ache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,424 INFO Added aliases 'NoneConnectorClientConfigOverridePolicy' and 'None' to plugin 'org.apache.kafka.connect.connector.policy.NoneConnectorClientConfigOverridePolicy' (org
.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,424 INFO Added aliases 'PrincipalConnectorClientConfigOverridePolicy' and 'Principal' to plugin 'org.apache.kafka.connect.connector.policy.PrincipalConnectorClientConfigOverr
idePolicy' (org.apache.kafka.connect.runtime.isolation.DelegatingClassLoader) [main]
2021-01-13 13:20:15,505 INFO DistributedConfig values:
	access.control.allow.methods =
	access.control.allow.origin =
	admin.listeners = null
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	client.dns.lookup = default
	client.id =
	config.providers = [file]
	config.storage.replication.factor = 1
	config.storage.topic = mirrormaker2-cluster-configs
	connect.protocol = sessioned
	connections.max.idle.ms = 540000
	connector.client.config.override.policy = None
	group.id = mirrormaker2-cluster
	header.converter = class org.apache.kafka.connect.storage.SimpleHeaderConverter
	heartbeat.interval.ms = 3000
	inter.worker.key.generation.algorithm = HmacSHA256
	inter.worker.key.size = null
	inter.worker.key.ttl.ms = 3600000
	inter.worker.signature.algorithm = HmacSHA256
	inter.worker.verification.algorithms = [HmacSHA256]
	internal.key.converter = class org.apache.kafka.connect.json.JsonConverter
	internal.value.converter = class org.apache.kafka.connect.json.JsonConverter
	key.converter = class org.apache.kafka.connect.converters.ByteArrayConverter
	listeners = null
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	offset.flush.interval.ms = 60000
	offset.flush.timeout.ms = 5000
	offset.storage.partitions = 25
	offset.storage.replication.factor = 1
	offset.storage.topic = mirrormaker2-cluster-offsets
	plugin.path = [/opt/kafka/plugins]
	rebalance.timeout.ms = 60000
	receive.buffer.bytes = 32768
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 40000
	rest.advertised.host.name = 10.3.8.175
	rest.advertised.listener = null
	rest.advertised.port = 8083
	rest.extension.classes = []
	rest.host.name = null
	rest.port = 8083
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	scheduled.rebalance.max.delay.ms = 300000
	security.protocol = PLAINTEXT
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.client.auth = none
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	status.storage.partitions = 5
	status.storage.replication.factor = 1
	status.storage.topic = mirrormaker2-cluster-status
	task.shutdown.graceful.timeout.ms = 5000
	topic.tracking.allow.reset = true
	topic.tracking.enable = true
	value.converter = class org.apache.kafka.connect.converters.ByteArrayConverter
	worker.sync.timeout.ms = 3000
	worker.unsync.backoff.ms = 300000
 (org.apache.kafka.connect.runtime.distributed.DistributedConfig) [main]
2021-01-13 13:20:15,507 INFO Creating Kafka admin client (org.apache.kafka.connect.util.ConnectUtils) [main]
2021-01-13 13:20:15,526 INFO AdminClientConfig values:
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	client.dns.lookup = default
	client.id =
	connections.max.idle.ms = 300000
	default.api.timeout.ms = 60000
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
 (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,597 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [main]
2021-01-13 13:20:15,598 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:15,598 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:15,598 INFO Kafka startTimeMs: 1610544015597 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:15,955 INFO Kafka cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.connect.util.ConnectUtils) [main]
2021-01-13 13:20:15,976 INFO Logging initialized @5542ms to org.eclipse.jetty.util.log.Slf4jLog (org.eclipse.jetty.util.log) [main]
2021-01-13 13:20:16,078 INFO Added connector for http://:8083 (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,078 INFO Initializing REST server (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,096 INFO jetty-9.4.24.v20191120; built: 2019-11-20T21:37:49.771Z; git: 363d5f2df3a8a28de40604320230664b9c793c16; jvm 1.8.0_275-b01 (org.eclipse.jetty.server.Server) [main]
2021-01-13 13:20:16,130 INFO Started http_8083@6fa590ba{HTTP/1.1,[http/1.1]}{0.0.0.0:8083} (org.eclipse.jetty.server.AbstractConnector) [main]
2021-01-13 13:20:16,130 INFO Started @5696ms (org.eclipse.jetty.server.Server) [main]
2021-01-13 13:20:16,155 INFO Advertised URI: http://10.3.8.175:8083/ (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,155 INFO REST server listening at http://10.3.8.175:8083/, advertising URL http://10.3.8.175:8083/ (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,156 INFO Advertised URI: http://10.3.8.175:8083/ (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,156 INFO REST admin endpoints at http://10.3.8.175:8083/ (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,156 INFO Advertised URI: http://10.3.8.175:8083/ (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,162 INFO Setting up None Policy for ConnectorClientConfigOverride. This will disallow any client configuration to be overridden (org.apache.kafka.connect.connector.policy.Non
eConnectorClientConfigOverridePolicy) [main]
2021-01-13 13:20:16,179 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,179 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,179 INFO Kafka startTimeMs: 1610544016179 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,335 INFO JsonConverterConfig values:
	converter.type = key
	decimal.format = BASE64
	schemas.cache.size = 1000
	schemas.enable = false
 (org.apache.kafka.connect.json.JsonConverterConfig) [main]
2021-01-13 13:20:16,337 INFO JsonConverterConfig values:
	converter.type = value
	decimal.format = BASE64
	schemas.cache.size = 1000
	schemas.enable = false
 (org.apache.kafka.connect.json.JsonConverterConfig) [main]
2021-01-13 13:20:16,388 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,388 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,388 INFO Kafka startTimeMs: 1610544016388 (org.apache.kafka.common.utils.AppInfoParser) [main]
2021-01-13 13:20:16,391 INFO Kafka Connect distributed worker initialization took 5447ms (org.apache.kafka.connect.cli.ConnectDistributed) [main]
2021-01-13 13:20:16,392 INFO Kafka Connect starting (org.apache.kafka.connect.runtime.Connect) [main]
2021-01-13 13:20:16,394 INFO Initializing REST resources (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,394 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Herder starting (org.apache.kafka.connect.runtime.distributed.DistributedHerder) [DistributedHerder-connect
-1-1]
2021-01-13 13:20:16,400 INFO Worker starting (org.apache.kafka.connect.runtime.Worker) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,400 INFO Starting KafkaOffsetBackingStore (org.apache.kafka.connect.storage.KafkaOffsetBackingStore) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,400 INFO Starting KafkaBasedLog with topic mirrormaker2-cluster-offsets (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,401 INFO AdminClientConfig values:
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	client.dns.lookup = default
	client.id =
	connections.max.idle.ms = 300000
	default.api.timeout.ms = 60000
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
 (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,418 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,418 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,418 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,418 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,418 INFO Kafka startTimeMs: 1610544016418 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,455 INFO Adding admin resources to main listener (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:16,472 INFO ProducerConfig values:
	acks = -1
	batch.size = 16384
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	buffer.memory = 33554432
	client.dns.lookup = default
	client.id = producer-1
	compression.type = none
	connections.max.idle.ms = 540000
	delivery.timeout.ms = 2147483647
	enable.idempotence = false
	interceptor.classes = []
	key.serializer = class org.apache.kafka.common.serialization.ByteArraySerializer
	linger.ms = 0
	max.block.ms = 60000
	max.in.flight.requests.per.connection = 1
	max.request.size = 1048576
	metadata.max.age.ms = 300000
	metadata.max.idle.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partitioner.class = class org.apache.kafka.clients.producer.internals.DefaultPartitioner
	receive.buffer.bytes = 32768
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	transaction.timeout.ms = 60000
	transactional.id = null
	value.serializer = class org.apache.kafka.common.serialization.ByteArraySerializer
 (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,510 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,510 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,511 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,511 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,511 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,511 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,511 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,511 INFO Kafka startTimeMs: 1610544016511 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,521 INFO ConsumerConfig values:
	allow.auto.create.topics = true
	auto.commit.interval.ms = 5000
	auto.offset.reset = earliest
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	check.crcs = true
	client.dns.lookup = default
	client.id =
	client.rack =
	connections.max.idle.ms = 540000
	default.api.timeout.ms = 60000
	enable.auto.commit = false
	exclude.internal.topics = true
	fetch.max.bytes = 52428800
	fetch.max.wait.ms = 500
	fetch.min.bytes = 1
	group.id = mirrormaker2-cluster
	group.instance.id = null
	heartbeat.interval.ms = 3000
	interceptor.classes = []
	internal.leave.group.on.close = true
	isolation.level = read_uncommitted
	key.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
	max.partition.fetch.bytes = 1048576
	max.poll.interval.ms = 300000
	max.poll.records = 500
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
 (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,526 INFO [Producer clientId=producer-1] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [kafka-producer-network-thread | producer-1]
2021-01-13 13:20:16,552 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,552 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,552 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,552 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,552 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,552 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,552 INFO Kafka startTimeMs: 1610544016552 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,561 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [Distributed
Herder-connect-1-1]
2021-01-13 13:20:16,573 INFO DefaultSessionIdManager workerName=node0 (org.eclipse.jetty.server.session) [main]
2021-01-13 13:20:16,573 INFO No SessionScavenger set, using defaults (org.eclipse.jetty.server.session) [main]
2021-01-13 13:20:16,575 INFO node0 Scavenging every 660000ms (org.eclipse.jetty.server.session) [main]
2021-01-13 13:20:16,588 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Subscribed to partition(s): mirrormaker2-cluster-offsets-0, mirrormaker2-cluster-of
fsets-5, mirrormaker2-cluster-offsets-10, mirrormaker2-cluster-offsets-20, mirrormaker2-cluster-offsets-15, mirrormaker2-cluster-offsets-9, mirrormaker2-cluster-offsets-11, mirrormaker2-cluster-
offsets-4, mirrormaker2-cluster-offsets-16, mirrormaker2-cluster-offsets-17, mirrormaker2-cluster-offsets-3, mirrormaker2-cluster-offsets-24, mirrormaker2-cluster-offsets-23, mirrormaker2-cluste
r-offsets-13, mirrormaker2-cluster-offsets-18, mirrormaker2-cluster-offsets-22, mirrormaker2-cluster-offsets-8, mirrormaker2-cluster-offsets-2, mirrormaker2-cluster-offsets-12, mirrormaker2-clus
ter-offsets-19, mirrormaker2-cluster-offsets-14, mirrormaker2-cluster-offsets-1, mirrormaker2-cluster-offsets-6, mirrormaker2-cluster-offsets-7, mirrormaker2-cluster-offsets-21 (org.apache.kafka
.clients.consumer.KafkaConsumer) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-0 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-5 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-10 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-20 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-15 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-9 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-11 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-4 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-16 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-17 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-3 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,593 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-24 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-23 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-13 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-18 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-22 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-8 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-2 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-12 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-19 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-14 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-1 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-6 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-7 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,594 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-offsets-21 (org.apache
.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,655 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-15 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-0 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-18 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-3 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-21 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-6 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,656 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-24 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,657 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-9 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,657 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-12 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-16 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-1 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-19 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-4 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-22 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-7 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-10 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-13 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-17 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-2 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-20 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-5 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-23 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-8 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-11 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,658 INFO [Consumer clientId=consumer-mirrormaker2-cluster-1, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-offsets-14 to offset 0. (org.ap
ache.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,659 INFO Finished reading KafkaBasedLog for topic mirrormaker2-cluster-offsets (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,659 INFO Started KafkaBasedLog for topic mirrormaker2-cluster-offsets (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,659 INFO Finished reading offsets topic and starting KafkaOffsetBackingStore (org.apache.kafka.connect.storage.KafkaOffsetBackingStore) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,680 INFO Worker started (org.apache.kafka.connect.runtime.Worker) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,680 INFO Starting KafkaBasedLog with topic mirrormaker2-cluster-status (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,681 INFO AdminClientConfig values:
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	client.dns.lookup = default
	client.id =
	connections.max.idle.ms = 300000
	default.api.timeout.ms = 60000
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
 (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,686 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,687 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,687 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,687 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,687 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,687 INFO Kafka startTimeMs: 1610544016687 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,716 INFO ProducerConfig values:
	acks = -1
	batch.size = 16384
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	buffer.memory = 33554432
	client.dns.lookup = default
	client.id = producer-2
	compression.type = none
	connections.max.idle.ms = 540000
	delivery.timeout.ms = 120000
	enable.idempotence = false
	interceptor.classes = []
	key.serializer = class org.apache.kafka.common.serialization.StringSerializer
	linger.ms = 0
	max.block.ms = 60000
	max.in.flight.requests.per.connection = 1
	max.request.size = 1048576
	metadata.max.age.ms = 300000
	metadata.max.idle.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partitioner.class = class org.apache.kafka.clients.producer.internals.DefaultPartitioner
	receive.buffer.bytes = 32768
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 0
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	transaction.timeout.ms = 60000
	transactional.id = null
	value.serializer = class org.apache.kafka.common.serialization.ByteArraySerializer
 (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,720 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,720 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,720 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,720 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,720 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,721 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,721 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,721 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,721 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,721 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,721 INFO Kafka startTimeMs: 1610544016721 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,722 INFO ConsumerConfig values:
	allow.auto.create.topics = true
	auto.commit.interval.ms = 5000
	auto.offset.reset = earliest
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	check.crcs = true
	client.dns.lookup = default
	client.id =
	client.rack =
	connections.max.idle.ms = 540000
	default.api.timeout.ms = 60000
	enable.auto.commit = false
	exclude.internal.topics = true
	fetch.max.bytes = 52428800
	fetch.max.wait.ms = 500
	fetch.min.bytes = 1
	group.id = mirrormaker2-cluster
	group.instance.id = null
	heartbeat.interval.ms = 3000
	interceptor.classes = []
	internal.leave.group.on.close = true
	isolation.level = read_uncommitted
	key.deserializer = class org.apache.kafka.common.serialization.StringDeserializer
	max.partition.fetch.bytes = 1048576
	max.poll.interval.ms = 300000
	max.poll.records = 500
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
 (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,726 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 INFO [Producer clientId=producer-2] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [kafka-producer-network-thread | producer-2]
2021-01-13 13:20:16,726 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,726 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,726 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,727 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,727 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,727 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,727 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,727 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,727 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,727 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,727 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,727 INFO Kafka startTimeMs: 1610544016727 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,731 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [Distributed
Herder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Subscribed to partition(s): mirrormaker2-cluster-status-0, mirrormaker2-cluster-sta
tus-4, mirrormaker2-cluster-status-1, mirrormaker2-cluster-status-2, mirrormaker2-cluster-status-3 (org.apache.kafka.clients.consumer.KafkaConsumer) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-status-0 (org.apache.k
afka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-status-4 (org.apache.k
afka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-status-1 (org.apache.k
afka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-status-2 (org.apache.k
afka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,737 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-status-3 (org.apache.k
afka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,757 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-status-3 to offset 0. (org.apac
he.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,757 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-status-0 to offset 0. (org.apac
he.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,757 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-status-2 to offset 0. (org.apac
he.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,757 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-status-4 to offset 0. (org.apac
he.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,757 INFO [Consumer clientId=consumer-mirrormaker2-cluster-2, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-status-1 to offset 0. (org.apac
he.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,758 INFO Finished reading KafkaBasedLog for topic mirrormaker2-cluster-status (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,758 INFO Started KafkaBasedLog for topic mirrormaker2-cluster-status (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,759 INFO Starting KafkaConfigBackingStore (org.apache.kafka.connect.storage.KafkaConfigBackingStore) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,759 INFO Starting KafkaBasedLog with topic mirrormaker2-cluster-configs (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,759 INFO AdminClientConfig values:
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	client.dns.lookup = default
	client.id =
	connections.max.idle.ms = 300000
	default.api.timeout.ms = 60000
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
 (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,762 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,762 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,762 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,762 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,763 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,763 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,763 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,763 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,764 INFO Kafka startTimeMs: 1610544016763 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,807 INFO ProducerConfig values:
	acks = -1
	batch.size = 16384
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	buffer.memory = 33554432
	client.dns.lookup = default
	client.id = producer-3
	compression.type = none
	connections.max.idle.ms = 540000
	delivery.timeout.ms = 2147483647
	enable.idempotence = false
	interceptor.classes = []
	key.serializer = class org.apache.kafka.common.serialization.StringSerializer
	linger.ms = 0
	max.block.ms = 60000
	max.in.flight.requests.per.connection = 1
	max.request.size = 1048576
	metadata.max.age.ms = 300000
	metadata.max.idle.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partitioner.class = class org.apache.kafka.clients.producer.internals.DefaultPartitioner
	receive.buffer.bytes = 32768
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retries = 2147483647
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	transaction.timeout.ms = 60000
	transactional.id = null
	value.serializer = class org.apache.kafka.common.serialization.ByteArraySerializer
 (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'group.id' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,811 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,811 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,811 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,811 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.producer.ProducerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,811 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,811 INFO Kafka startTimeMs: 1610544016811 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,814 INFO ConsumerConfig values:
	allow.auto.create.topics = true
	auto.commit.interval.ms = 5000
	auto.offset.reset = earliest
	bootstrap.servers = [my-cluster-target-kafka-bootstrap:9092]
	check.crcs = true
	client.dns.lookup = default
	client.id =
	client.rack =
	connections.max.idle.ms = 540000
	default.api.timeout.ms = 60000
	enable.auto.commit = false
	exclude.internal.topics = true
	fetch.max.bytes = 52428800
	fetch.max.wait.ms = 500
	fetch.min.bytes = 1
	group.id = mirrormaker2-cluster
	group.instance.id = null
	heartbeat.interval.ms = 3000
	interceptor.classes = []
	internal.leave.group.on.close = true
	isolation.level = read_uncommitted
	key.deserializer = class org.apache.kafka.common.serialization.StringDeserializer
	max.partition.fetch.bytes = 1048576
	max.poll.interval.ms = 300000
	max.poll.records = 500
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.recording.level = INFO
	metrics.sample.window.ms = 30000
	partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
	receive.buffer.bytes = 65536
	reconnect.backoff.max.ms = 1000
	reconnect.backoff.ms = 50
	request.timeout.ms = 30000
	retry.backoff.ms = 100
	sasl.client.callback.handler.class = null
	sasl.jaas.config = null
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.login.callback.handler.class = null
	sasl.login.class = null
	sasl.login.refresh.buffer.seconds = 300
	sasl.login.refresh.min.period.seconds = 60
	sasl.login.refresh.window.factor = 0.8
	sasl.login.refresh.window.jitter = 0.05
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	security.providers = null
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2]
	ssl.endpoint.identification.algorithm = https
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLSv1.2
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
 (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,819 WARN The configuration 'rest.advertised.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'plugin.path' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'config.providers' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'admin.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'status.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'config.providers.file.class' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,820 WARN The configuration 'offset.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'consumer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,820 WARN The configuration 'value.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'key.converter' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'config.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'producer.security.protocol' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1
-1]
2021-01-13 13:20:16,820 WARN The configuration 'rest.advertised.host.name' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-
1]
2021-01-13 13:20:16,820 WARN The configuration 'status.storage.topic' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'config.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'rest.port' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 WARN The configuration 'offset.storage.replication.factor' was supplied but isn't a known config. (org.apache.kafka.clients.consumer.ConsumerConfig) [DistributedHerder-co
nnect-1-1]
2021-01-13 13:20:16,820 INFO Kafka version: 2.5.0 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 INFO Kafka commitId: 66563e712b0b9f84 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,820 INFO Kafka startTimeMs: 1610544016820 (org.apache.kafka.common.utils.AppInfoParser) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,821 INFO [Producer clientId=producer-3] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [kafka-producer-network-thread | producer-3]
2021-01-13 13:20:16,825 INFO [Consumer clientId=consumer-mirrormaker2-cluster-3, groupId=mirrormaker2-cluster] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [Distributed
Herder-connect-1-1]
2021-01-13 13:20:16,832 INFO [Consumer clientId=consumer-mirrormaker2-cluster-3, groupId=mirrormaker2-cluster] Subscribed to partition(s): mirrormaker2-cluster-configs-0 (org.apache.kafka.client
s.consumer.KafkaConsumer) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,832 INFO [Consumer clientId=consumer-mirrormaker2-cluster-3, groupId=mirrormaker2-cluster] Seeking to EARLIEST offset of partition mirrormaker2-cluster-configs-0 (org.apache.
kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,844 INFO [Consumer clientId=consumer-mirrormaker2-cluster-3, groupId=mirrormaker2-cluster] Resetting offset for partition mirrormaker2-cluster-configs-0 to offset 0. (org.apa
che.kafka.clients.consumer.internals.SubscriptionState) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,906 INFO Finished reading KafkaBasedLog for topic mirrormaker2-cluster-configs (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,906 INFO Started KafkaBasedLog for topic mirrormaker2-cluster-configs (org.apache.kafka.connect.util.KafkaBasedLog) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,906 INFO Started KafkaConfigBackingStore (org.apache.kafka.connect.storage.KafkaConfigBackingStore) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,906 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Herder started (org.apache.kafka.connect.runtime.distributed.DistributedHerder) [DistributedHerder-connect-
1-1]
2021-01-13 13:20:16,935 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Cluster ID: Y3aTMPXhRJ-MIgICvnGJoA (org.apache.kafka.clients.Metadata) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,937 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Discovered group coordinator my-cluster-target-kafka-2.my-cluster-target-kafka-brokers.xxli.svc:9092 (id: 2
147483645 rack: null) (org.apache.kafka.clients.consumer.internals.AbstractCoordinator) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,939 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Rebalance started (org.apache.kafka.connect.runtime.distributed.WorkerCoordinator) [DistributedHerder-conne
ct-1-1]
2021-01-13 13:20:16,939 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] (Re-)joining group (org.apache.kafka.clients.consumer.internals.AbstractCoordinator) [DistributedHerder-con
nect-1-1]
2021-01-13 13:20:16,950 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Join group failed with org.apache.kafka.common.errors.MemberIdRequiredException: The group member needs to
have a valid member id before actually entering a consumer group (org.apache.kafka.clients.consumer.internals.AbstractCoordinator) [DistributedHerder-connect-1-1]
2021-01-13 13:20:16,950 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] (Re-)joining group (org.apache.kafka.clients.consumer.internals.AbstractCoordinator) [DistributedHerder-con
nect-1-1]
Jan 13, 2021 1:20:17 PM org.glassfish.jersey.internal.inject.Providers checkProviderRuntime
WARNING: A provider org.apache.kafka.connect.runtime.rest.resources.ConnectorPluginsResource registered in SERVER runtime does not implement any provider interfaces applicable in the SERVER runt
ime. Due to constraint configuration problems the provider org.apache.kafka.connect.runtime.rest.resources.ConnectorPluginsResource will be ignored.
Jan 13, 2021 1:20:17 PM org.glassfish.jersey.internal.inject.Providers checkProviderRuntime
WARNING: A provider org.apache.kafka.connect.runtime.rest.resources.ConnectorsResource registered in SERVER runtime does not implement any provider interfaces applicable in the SERVER runtime. D
ue to constraint configuration problems the provider org.apache.kafka.connect.runtime.rest.resources.ConnectorsResource will be ignored.
Jan 13, 2021 1:20:17 PM org.glassfish.jersey.internal.inject.Providers checkProviderRuntime
WARNING: A provider org.apache.kafka.connect.runtime.rest.resources.RootResource registered in SERVER runtime does not implement any provider interfaces applicable in the SERVER runtime. Due to
constraint configuration problems the provider org.apache.kafka.connect.runtime.rest.resources.RootResource will be ignored.
Jan 13, 2021 1:20:17 PM org.glassfish.jersey.internal.inject.Providers checkProviderRuntime
WARNING: A provider org.apache.kafka.connect.runtime.rest.resources.LoggingResource registered in SERVER runtime does not implement any provider interfaces applicable in the SERVER runtime. Due
to constraint configuration problems the provider org.apache.kafka.connect.runtime.rest.resources.LoggingResource will be ignored.
Jan 13, 2021 1:20:17 PM org.glassfish.jersey.internal.Errors logErrors
WARNING: The following warnings have been detected: WARNING: The (sub)resource method listLoggers in org.apache.kafka.connect.runtime.rest.resources.LoggingResource contains empty path annotatio
n.
WARNING: The (sub)resource method listConnectors in org.apache.kafka.connect.runtime.rest.resources.ConnectorsResource contains empty path annotation.
WARNING: The (sub)resource method createConnector in org.apache.kafka.connect.runtime.rest.resources.ConnectorsResource contains empty path annotation.
WARNING: The (sub)resource method listConnectorPlugins in org.apache.kafka.connect.runtime.rest.resources.ConnectorPluginsResource contains empty path annotation.
WARNING: The (sub)resource method serverInfo in org.apache.kafka.connect.runtime.rest.resources.RootResource contains empty path annotation.

2021-01-13 13:20:17,267 INFO Started o.e.j.s.ServletContextHandler@9f6e406{/,null,AVAILABLE} (org.eclipse.jetty.server.handler.ContextHandler) [main]
2021-01-13 13:20:17,267 INFO REST resources initialized; server is started and ready to handle requests (org.apache.kafka.connect.runtime.rest.RestServer) [main]
2021-01-13 13:20:17,267 INFO Kafka Connect started (org.apache.kafka.connect.runtime.Connect) [main]
2021-01-13 13:20:20,003 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Successfully joined group with generation 5 (org.apache.kafka.clients.consumer.internals.AbstractCoordinato
r) [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,004 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Joined group at generation 5 with protocol version 2 and got assignment: Assignment{error=0, leader='connec
t-1-90541f37-0a76-408f-886c-73e8229934b2', leaderUrl='http://10.3.8.175:8083/', offset=2, connectorIds=[], taskIds=[], revokedConnectorIds=[], revokedTaskIds=[], delay=0} with rebalance delay: 0
 (org.apache.kafka.connect.runtime.distributed.DistributedHerder) [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,005 WARN [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Catching up to assignment's config offset. (org.apache.kafka.connect.runtime.distributed.DistributedHerder)
 [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,005 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Current config state offset -1 is behind group assignment 2, reading to end of config log (org.apache.kafka
.connect.runtime.distributed.DistributedHerder) [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,384 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Finished reading to end of log and updated config snapshot, new config log offset: 2 (org.apache.kafka.conn
ect.runtime.distributed.DistributedHerder) [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,385 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Starting connectors and tasks using config offset 2 (org.apache.kafka.connect.runtime.distributed.Distribut
edHerder) [DistributedHerder-connect-1-1]
2021-01-13 13:20:20,385 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Finished starting connectors and tasks (org.apache.kafka.connect.runtime.distributed.DistributedHerder) [Di
stributedHerder-connect-1-1]
2021-01-13 13:20:20,443 INFO [Worker clientId=connect-1, groupId=mirrormaker2-cluster] Session key updated (org.apache.kafka.connect.runtime.distributed.DistributedHerder) [KafkaBasedLog Work Th
read - mirrormaker2-cluster-configs]


# operator log 

$ kubectl -n xxli logs strimzi-cluster-operator-v0.18.0-665744b74d-2cwmg

2021-01-13 13:38:49 ERROR AbstractOperator:175 - Reconciliation #36(timer) KafkaMirrorMaker2(xxli/my-mm2-cluster): createOrUpdate failed
io.strimzi.operator.common.operator.resource.TimeoutException: Exceeded timeout of 300000ms while waiting for Deployment resource my-mm2-cluster-mirrormaker2 in namespace xxli to be ready
	at io.strimzi.operator.common.Util$1.lambda$handle$1(Util.java:115) ~[io.strimzi.operator-common-0.18.0.jar:0.18.0]
	at io.vertx.core.impl.ContextImpl.lambda$null$0(ContextImpl.java:330) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.ContextImpl.executeTask(ContextImpl.java:369) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.EventLoopContext.lambda$executeAsync$0(EventLoopContext.java:38) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.netty.util.concurrent.AbstractEventExecutor.safeExecute(AbstractEventExecutor.java:164) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.SingleThreadEventExecutor.runAllTasks(SingleThreadEventExecutor.java:472) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:500) [io.netty.netty-transport-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.SingleThreadEventExecutor$4.run(SingleThreadEventExecutor.java:989) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_275]
2021-01-13 13:38:49 WARN  AbstractOperator:330 - Reconciliation #36(timer) KafkaMirrorMaker2(xxli/my-mm2-cluster): Failed to reconcile
io.strimzi.operator.common.operator.resource.TimeoutException: Exceeded timeout of 300000ms while waiting for Deployment resource my-mm2-cluster-mirrormaker2 in namespace xxli to be ready
	at io.strimzi.operator.common.Util$1.lambda$handle$1(Util.java:115) ~[io.strimzi.operator-common-0.18.0.jar:0.18.0]
	at io.vertx.core.impl.ContextImpl.lambda$null$0(ContextImpl.java:330) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.ContextImpl.executeTask(ContextImpl.java:369) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.vertx.core.impl.EventLoopContext.lambda$executeAsync$0(EventLoopContext.java:38) ~[io.vertx.vertx-core-3.8.5.jar:3.8.5]
	at io.netty.util.concurrent.AbstractEventExecutor.safeExecute(AbstractEventExecutor.java:164) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.SingleThreadEventExecutor.runAllTasks(SingleThreadEventExecutor.java:472) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:500) [io.netty.netty-transport-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.SingleThreadEventExecutor$4.run(SingleThreadEventExecutor.java:989) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30) [io.netty.netty-common-4.1.45.Final.jar:4.1.45.Final]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_275]

```

May I ask what is the reason for this and how should I debug






