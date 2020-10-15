#!/bin/bash

set -x

# ssl 各种文件生成的基本路径
BASE_DIR=/root/ssl  # BASE_DIR=/root/ssl
# 证书文件生成路径
CERT_OUTPUT_PATH="${BASE_DIR}/certificates"  # CERT_OUTPUT_PATH=/root/ssl/certificates
PASSWORD=kafka123456  # 基础密码

# keystore 相关
# keystore 文件路径
KEY_STORE="${CERT_OUTPUT_PATH}/kafka.keystore"  # KEY_STORE=/root/ssl/certificates/kafka.keystore
# keystore key 密码
KEY_PASSWORD=${PASSWORD}  # KEY_PASSWORD=kafka123456
# keystore store 密码
STORE_PASSWORD=${PASSWORD}  # STORE_PASSWORD=kafka123456

# truststore 相关
# truststore 文件路径
TRUST_STORE="${CERT_OUTPUT_PATH}/kafka.truststore"  # TRUST_STORE=/root/ssl/certificates/kafka.truststore
# truststore key 密码
TRUST_KEY_PASSWORD=${PASSWORD}  # TRUST_KEY_PASSWORD=kafka123456
# truststore store 密码
TRUST_STORE_PASSWORD=${PASSWORD}  # TRUST_STORE_PASSWORD=kafka123456


CLUSTER_NAME=test-cluster  # 集群名称
# CA 证书文件路径
CERT_AUTH_FILE="${CERT_OUTPUT_PATH}/ca-cert"  # CERT_AUTH_FILE=/root/ssl/certificates/ca-cert
# 集群证书文件路径
CLUSTER_CERT_FILE="${CERT_OUTPUT_PATH}/${CLUSTER_NAME}-cert"  # CLUSTER_CERT_FILE=/root/ssl/certificates/test-cluster-cert
DAYS_VALID=365  # 证书有效期
D_NAME="CN=name, OU=dept, O=company, L=city, ST=province, C=CN"  # 证书认证信息

mkdir -p ${CERT_OUTPUT_PATH}

# 创建集群证书到 keystore
# keytool -genkeypair
# -keystore /root/ssl/certificates/kafka.keystore
# -alias test-cluster
# -validity 365
# -keyalg RSA
# -dname 'CN=name, OU=dept, O=company, L=city, ST=province, C=CN'
# -keypass kafka123456
# -storepass kafka123456
keytool -genkeypair -keystore ${KEY_STORE} -alias ${CLUSTER_NAME} -validity ${DAYS_VALID} -keyalg RSA -dname "${D_NAME}" -keypass ${KEY_PASSWORD} -storepass ${STORE_PASSWORD}
# [root@mw-init ssl]# pwd
# /root/ssl
# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   └── kafka.keystore
# └── ssl.sh

# 1 directory, 2 files

# 生成 CA 私钥和证书
openssl req -new -x509 -keyout ${CERT_OUTPUT_PATH}/ca-key -out ${CERT_AUTH_FILE} -days ${DAYS_VALID} -passin pass:"${PASSWORD}" -subj "/C=CN/ST=province/L=city/O=company/CN=name"
# openssl req -new -x509
# -keyout /root/ssl/certificates/ca-key
# -out /root/ssl/certificates/ca-cert
# -days 365
# -passin pass:kafka123456
# -subj /C=CN/ST=province/L=city/O=company/CN=name

# [root@mw-init ssl]# pwd
# /root/ssl
# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   ├── ca-cert
# │   ├── ca-key
# │   └── kafka.keystore
# └── ssl.sh

# 1 directory, 4 files
# [root@mw-init ssl]#

# 将 CA 证书导入 trust
keytool -importcert -keystore ${TRUST_STORE} -alias CARoot -file ${CERT_AUTH_FILE} -keypass ${TRUST_KEY_PASSWORD} -storepass ${TRUST_STORE_PASSWORD}
# keytool -importcert
# -keystore /root/ssl/certificates/kafka.truststore
# -alias CARoot
# -file /root/ssl/certificates/ca-cert
# -keypass kafka123456
# -storepass kafka123456

# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   ├── ca-cert
# │   ├── ca-key
# │   ├── kafka.keystore
# │   └── kafka.truststore
# └── ssl.sh

# 1 directory, 5 files
# [root@mw-init ssl]#


# 生成证书请求
keytool -certreq -alias ${CLUSTER_NAME} -file ${CLUSTER_CERT_FILE} -keypass ${KEY_PASSWORD} -keystore ${KEY_STORE} -storepass ${STORE_PASSWORD}
# keytool -certreq -alias test-cluster -file /root/ssl/certificates/test-cluster-cert -keypass kafka123456 -keystore /root/ssl/certificates/kafka.keystore -storepass kafka123456

# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   ├── ca-cert
# │   ├── ca-key
# │   ├── kafka.keystore
# │   ├── kafka.truststore
# │   └── test-cluster-cert
# └── ssl.sh

# 1 directory, 6 files
# [root@mw-init ssl]#


# 签发证书
openssl x509 -req -CA ${CERT_AUTH_FILE} -CAkey ${CERT_OUTPUT_PATH}/ca-key -in ${CLUSTER_CERT_FILE} -out "${CLUSTER_CERT_FILE}-signed" -days ${DAYS_VALID} -CAcreateserial -passin pass:"${PASSWORD}"
# openssl x509 -req -CA /root/ssl/certificates/ca-cert -CAkey /root/ssl/certificates/ca-key -in /root/ssl/certificates/test-cluster-cert -out /root/ssl/certificates/test-cluster-cert-signed -days 365 -CAcreateserial -passin pass:kafka123456

# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   ├── ca-cert
# │   ├── ca-cert.srl
# │   ├── ca-key
# │   ├── kafka.keystore
# │   ├── kafka.truststore
# │   ├── test-cluster-cert
# │   └── test-cluster-cert-signed
# └── ssl.sh

# 1 directory, 8 files
# [root@mw-init ssl]#


keytool -importcert -keystore ${KEY_STORE} -alias CARoot -file ${CERT_AUTH_FILE} -keypass ${KEY_PASSWORD} -storepass ${STORE_PASSWORD}
# keytool -importcert -keystore /root/ssl/certificates/kafka.keystore -alias CARoot -file /root/ssl/certificates/ca-cert -keypass kafka123456 -storepass kafka123456

keytool -importcert -keystore ${KEY_STORE} -alias ${CLUSTER_NAME} -file "${CLUSTER_CERT_FILE}-signed" -keypass ${KEY_PASSWORD} -storepass ${STORE_PASSWORD}
# keytool -importcert -keystore /root/ssl/certificates/kafka.keystore -alias test-cluster -file /root/ssl/certificates/test-cluster-cert-signed -keypass kafka123456 -storepass kafka123456

# [root@mw-init ssl]# tree -a .
# .
# ├── certificates
# │   ├── ca-cert  # CA 证书
# │   ├── ca-cert.srl
# │   ├── ca-key  # CA 私钥
# │   ├── kafka.keystore
# │   ├── kafka.truststore
# │   ├── test-cluster-cert  # 集群公钥和私钥
# │   └── test-cluster-cert-signed  # 集群证书文件
# └── ssl.sh

# 1 directory, 8 files
# [root@mw-init ssl]#

