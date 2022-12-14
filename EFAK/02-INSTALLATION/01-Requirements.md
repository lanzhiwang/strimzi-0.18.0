# EFAK Requirements

## Overview  概述

This page lists the minimum hardware and software requirements to install EFAK.  此页面列出了安装 EFAK 的最低硬件和软件要求。

To run EFAK, you must have a supported operating system, hardware that meets or exceeds minimum requirements, a supported database, and a supported browser.  要运行 EFAK，您必须拥有受支持的操作系统、满足或超过最低要求的硬件、受支持的数据库和受支持的浏览器。

## Supported operating systems  支持的操作系统

The following operating systems are supported for EFAK installation:  EFAK 安装支持以下操作系统：

- [Linux](https://www.kafka-eagle.org/articles/docs/installation/linux-macos.html)

- [macOS](https://www.kafka-eagle.org/articles/docs/installation/linux-macos.html)

- [Windows](https://www.kafka-eagle.org/articles/docs/installation/windows.html)

> NOTE: We recommend that you install EFAK on the Linux operating system.  我们建议您在 Linux 操作系统上安装 EFAK。

## Hardware recommendations  硬件建议

EFAK does not use a lot of resources and is very lightweight in use of memory and CPU.  EFAK 不占用大量资源，在内存和 CPU 的使用上非常轻量级。

Minimum recommended memory: 2048 MB  最小推荐内存：2048 MB

Minimum recommended CPU: 1  最低推荐 CPU：1

Some features might require more memory or CPUs. Features require more resources include:  某些功能可能需要更多内存或 CPU。需要更多资源的功能包括：

- [Server side rendering of images](https://www.kafka-eagle.org/articles/docs/quickstart/metrics.html)

- [Alerting](https://www.kafka-eagle.org/articles/docs/quickstart/alarm.html)

- Scheduler

## Supported databases

EFAK requires a database to store its configuration data, such as users, data sources, and dashboards. The exact requirements depend on the size of the EFAK installation and features used.  EFAK 需要一个数据库来存储其配置数据，例如用户、数据源和仪表板。具体要求取决于 EFAK 安装的大小和使用的功能。

EFAK supports the following databases:

- MySQL

- SQLite

By default, EFAK installs with and uses SQLite, which is an embedded database stored in the EFAK installation location.  默认情况下，EFAK 安装并使用 SQLite，这是一个存储在 EFAK 安装位置的嵌入式数据库。

### Supported web browsers

EFAK is supported in the current version of the following browsers. Older versions of these browsers might not be supported, so you should always upgrade to the latest version when using EFAK:  以下浏览器的当前版本支持 EFAK。这些浏览器的旧版本可能不受支持，因此在使用 EFAK 时应始终升级到最新版本：

- Chrome/Chromium

- Firefox

- Safari

- Microsoft Edge

- Internet Explorer 11

> NOTE: Always enable JavaScript in your browser. Running EFAK without JavaScript enabled in the browser is not supported.  始终在浏览器中启用 JavaScript。不支持在浏览器中未启用 JavaScript 的情况下运行 EFAK。




