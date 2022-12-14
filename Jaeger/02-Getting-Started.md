# Getting Started

Get up and running with Jaeger in your local environment  在您的本地环境中启动并运行 Jaeger

Version **1.32**Latest

------

If you are new to distributed tracing, please check the [Introduction](https://www.jaegertracing.io/docs/1.32/) page.  如果您不熟悉分布式跟踪，请查看简介页面。

## Instrumentation

Your applications must be instrumented before they can send tracing data to Jaeger backend. Check the [Client Libraries](https://www.jaegertracing.io/docs/1.32/client-libraries) section for information about how to use the OpenTracing API and how to initialize and configure Jaeger tracers.  您的应用程序必须先进行检测，然后才能将跟踪数据发送到 Jaeger 后端。 查看客户端库部分以获取有关如何使用 OpenTracing API 以及如何初始化和配置 Jaeger 跟踪器的信息。

## All in One

All-in-one is an executable designed for quick local testing, launches the Jaeger UI, collector, query, and agent, with an in memory storage component.  All-in-one 是专为快速本地测试而设计的可执行文件，可启动 Jaeger UI、收集器、查询和代理，并带有内存存储组件。

The simplest way to start the all-in-one is to use the pre-built image published to DockerHub (a single command line).  启动一体机的最简单方法是使用发布到 DockerHub 的预构建镜像（单个命令行）。

```bash
docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14250:14250 \
  -p 14268:14268 \
  -p 14269:14269 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.32
```

Or run the `jaeger-all-in-one(.exe)` executable from the [binary distribution archives](https://www.jaegertracing.io/download/):

```bash
jaeger-all-in-one --collector.zipkin.host-port=:9411
```

You can then navigate to `http://localhost:16686` to access the Jaeger UI.

The container exposes the following ports:

| Port | Protocol | Component | Function |
| ---- | -------- | --------- | -------- |
| 5775 | UDP | agent | accept `zipkin.thrift` over compact thrift protocol (deprecated, used by legacy clients only) |
| 6831 | UDP | agent | accept `jaeger.thrift` over compact thrift protocol |
| 6832 | UDP | agent | accept `jaeger.thrift` over binary thrift protocol |
| 5778 | HTTP | agent | serve configs |
| 16686 | HTTP | query | serve frontend |
| 14268 | HTTP | collector | accept `jaeger.thrift` directly from clients |
| 14250 | HTTP | collector | accept `model.proto` |
| 9411  | HTTP | collector | Zipkin compatible endpoint (optional) |

## Kubernetes and OpenShift

- Kubernetes templates: https://github.com/jaegertracing/jaeger-kubernetes

- Kubernetes Operator: https://github.com/jaegertracing/jaeger-operator

- OpenShift templates: https://github.com/jaegertracing/jaeger-openshift

## Sample App: HotROD

HotROD (Rides on Demand) is a demo application that consists of several microservices and illustrates the use of the [OpenTracing API](http://opentracing.io/). A tutorial / walkthrough is available in the blog post: [Take OpenTracing for a HotROD ride](https://medium.com/@YuriShkuro/take-opentracing-for-a-hotrod-ride-f6e3141f7941).  HotROD (Rides on Demand) 是一个演示应用程序，由多个微服务组成，并说明了 OpenTracing API 的使用。 博客文章中提供了教程/演练：以 OpenTracing 进行 HotROD 之旅。

It can be run standalone, but requires Jaeger backend to view the traces.  它可以独立运行，但需要 Jaeger 后端来查看跟踪。

### Features

- Discover architecture of the whole system via data-driven dependency diagram.  通过数据驱动的依赖图发现整个系统的架构。

- View request timeline and errors; understand how the app works.  查看请求时间表和错误； 了解应用程序的工作原理。

- Find sources of latency and lack of concurrency.  查找延迟和缺乏并发性的来源。

- Highly contextualized logging.  高度上下文化的日志记录。

- Use baggage propagation to:  使用行李传播：

  - Diagnose inter-request contention (queueing).  诊断请求间争用（排队）。

  - Attribute time spent in a service.  在服务中花费的属性时间。

- Use open source libraries with OpenTracing integration to get vendor-neutral instrumentation for free.  使用具有 OpenTracing 集成的开源库免费获得供应商中立的仪器。

### Prerequisites

- You need [Go toolchain](https://golang.org/doc/install) installed on your machine to run from source (see [go.mod](https://github.com/jaegertracing/jaeger/blob/master/go.mod) file for required Go version).

- Requires a [running Jaeger backend](https://www.jaegertracing.io/docs/1.32/getting-started/#all-in-one) to view the traces.

### Running

#### From Source

```bash
mkdir -p $GOPATH/src/github.com/jaegertracing
cd $GOPATH/src/github.com/jaegertracing
git clone git@github.com:jaegertracing/jaeger.git jaeger
cd jaeger
go run ./examples/hotrod/main.go all
```

#### From docker

```bash
docker run --rm -it \
  --link jaeger \
  -p8080-8083:8080-8083 \
  -e JAEGER_AGENT_HOST="jaeger" \
  jaegertracing/example-hotrod:1.32 \
  all
```

#### From binary distribution

Run `example-hotrod(.exe)` executable from the [binary distribution archives](https://www.jaegertracing.io/download/):

```bash
example-hotrod all
```

Then navigate to `http://localhost:8080`.

## Migrating from Zipkin

Collector service exposes Zipkin compatible REST API `/api/v1/spans` which accepts both Thrift and JSON. Also there is `/api/v2/spans` for JSON and Proto. By default it’s disabled. It can be enabled with `--collector.zipkin.host-port=:9411`.

Zipkin [Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/zipkincore.thrift) IDL and Zipkin [Proto](https://github.com/jaegertracing/jaeger-idl/blob/master/proto/zipkin.proto) IDL files can be found in [jaegertracing/jaeger-idl](https://github.com/jaegertracing/jaeger-idl) repository. They’re compatible with [openzipkin/zipkin-api](https://github.com/openzipkin/zipkin-api) [Thrift](https://github.com/openzipkin/zipkin-api/blob/master/thrift/zipkinCore.thrift) and [Proto](https://github.com/openzipkin/zipkin-api/blob/master/zipkin.proto).

