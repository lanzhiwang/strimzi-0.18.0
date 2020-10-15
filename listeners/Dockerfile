FROM 10.0.129.0:60080/3rdparty/strimzi/kafka:latest

MAINTAINER zhihu

COPY ./client-ssl.properties /opt/kafka/bin/
COPY ./user-truststore.jks /opt/kafka/bin/
COPY ./user-keystore.jks /opt/kafka/bin/
