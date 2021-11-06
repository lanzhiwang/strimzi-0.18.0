# ZooKeeper Monitor Guide

- New Metrics System
    - Metrics
    - Prometheus
    - Grafana
- JMX
- Four letter words

## New Metrics System

The feature: `New Metrics System` has been available since 3.6.0 which provides the abundant metrics to help users monitor the ZooKeeper on the topic:  特性：New Metrics System 从 3.6.0 开始提供了丰富的指标来帮助用户监控 ZooKeeper 的主题：

* znode
* network
* disk
* quorum  仲裁
* leader election
* client
* security
* failures
* watch/session  观察/会话
* requestProcessor  请求处理器
* and so forth

### Metrics

All the metrics are included in the **[ServerMetrics.java](https://github.com/apache/zookeeper/blob/master/zookeeper-server/src/main/java/org/apache/zookeeper/server/ServerMetrics.java)**.

### Prometheus

- Running a [Prometheus](https://prometheus.io/) monitoring service is the easiest way to ingest and record ZooKeeper's metrics.  运行 Prometheus 监控服务是摄取和记录 ZooKeeper 指标的最简单方法。

- Pre-requisites:  先决条件：

- enable the **Prometheus MetricsProvider** by setting **metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider** in the **zoo.cfg**.  通过在 zoo.cfg 中设置 metricsProvider.className 来启用 Prometheus MetricsProvider。

- the Port is also configurable by setting **metricsProvider.httpPort**（the default value:7000）  Port也可以通过设置metricsProvider.httpPort来配置（默认值：7000）

- Install Prometheus: Go to the official website download [page](https://prometheus.io/download/), download the latest release.

- Set Prometheus's scraper to target the ZooKeeper cluster endpoints:

```bash
bash cat > /tmp/test-zk.yaml <<EOF global: scrape_interval: 10s scrape_configs: - job_name: test-zk static_configs: - targets: ['192.168.10.32:7000','192.168.10.33:7000','192.168.10.34:7000'] EOF cat /tmp/test-zk.yaml

global:
  scrape_interval: 10s
scrape_configs:
  - job_name: test-zk
static_configs: 
  - targets: ['192.168.10.32:7000','192.168.10.33:7000','192.168.10.34:7000']

```

- Set up the Prometheus handler:

```bash
bash nohup /tmp/prometheus -config.file /tmp/test-zk.yaml -web.listen-address ":9090" -storage.local.path "test-zk.data" >> /tmp/test-zk.log 2>&1 &
```

- Now Prometheus will scrape zk metrics every 10 seconds.  现在 Prometheus 将每 10 秒抓取一次 zk 指标。


### Grafana

- Grafana has built-in Prometheus support; just add a Prometheus data source:

```bash
bash Name: test-zk Type: Prometheus Url: http://localhost:9090 Access: proxy`
```

- Then download and import the default ZooKeeper dashboard [template](https://grafana.com/dashboards/10465) and customize.

- Users can ask for Grafana dashboard account if having any good improvements by writing a email to **dev@zookeeper.apache.org**.


## JMX

More details can be found in [here](http://zookeeper.apache.org/doc/current/zookeeperJMX.html)

## Four letter words

More details can be found in [here](http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_zkCommands)
