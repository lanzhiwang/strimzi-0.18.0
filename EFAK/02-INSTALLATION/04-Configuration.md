# Configuration

## Overview

EFAK has a number of configuration options that you can specify in a `.properties` configuration file or specified using environment variables.

> NOTE: You must restart EFAK for any configuration changes to take effect.

## Config file locations

Do not rename `system-config.properties`! EFAK defaults are stored in this file.

### Base Common

| Name | Default | Describe |
| ---- | ------- | -------- |
| efak.zk.cluster.alias | cluster1,cluster2 | Kafka multi cluster alias attribute. |
| cluster1.zk.list | ke01:2181,ke02:2181,ke03:2181/cluster1 | Kafka cluster1 zookeeper address. |
| cluster2.zk.list | ke01:2181,ke02:2181,ke03:2181/cluster2 | Kafka cluster2 zookeeper address. |
| kafka.zk.limit.size | 25 | EFAK maximum number of connections for the Zookeeper client. |
| cluster1.efak.broker.size | 10 | Kafka broker size online list. |
| cluster2.efak.broker.size | 20 | Kafka broker size online list. |
| efak.webui.port | 8048 | EFAK webui port. |
| cluster1.efak.offset.storage | kafka | Kafka offsets stored in kafka. |
| cluster1.efak.offset.storage | zk | Kafka offsets stored in zookeeper. |
| efak.metrics.charts | false | EFAK default disable metrics. |
| efak.metrics.retain | 30 | EFAK default retain metrics data. |
| efak.sql.fix.error | false | EFAK default disable fixed kafka sql query error. |
| efak.sql.topic.records.max | 5000 | EFAK SQL query topic max records. |
| efak.topic.token | keadmin | EFAK delete topic token. |

### Database Property

#### MySQL

| Name | Default | Describe |
| ---- | ------- | -------- |
| efak.driver | com.mysql.jdbc.Driver | EFAK store database driver. |
| efak.url | jdbc:mysql://127.0.0.1:3306/ke3?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull | EFAK store database url. |
| efak.username | root | EFAK store database username. |
| efak.password | 123456 | EFAK store database password. |

#### SQLite

| Name | Default | Describe |
| ---- | ------- | -------- |
| efak.driver | org.sqlite.JDBC | EFAK store database driver. |
| efak.url | jdbc:sqlite:/hadoop/kafka-eagle/db/ke.db | EFAK store database url. |
| efak.username | root | EFAK store database username. |
| efak.password | 123456 | EFAK store database password. |

