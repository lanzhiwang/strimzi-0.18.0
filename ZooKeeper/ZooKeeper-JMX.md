# ZooKeeper JMX

- JMX
- Starting ZooKeeper with JMX enabled
- Run a JMX console
- ZooKeeper MBean Reference

## JMX

Apache ZooKeeper has extensive support for JMX, allowing you to view and manage a ZooKeeper serving ensemble.  Apache ZooKeeper 对 JMX 有广泛的支持，允许您查看和管理 ZooKeeper 服务集合。

This document assumes that you have basic knowledge of JMX. See [Sun JMX Technology](http://java.sun.com/javase/technologies/core/mntr-mgmt/javamanagement/) page to get started with JMX.  本文档假设您具有 JMX 的基本知识。 请参阅 Sun JMX 技术页面以开始使用 JMX。

See the [JMX Management Guide](http://java.sun.com/javase/6/docs/technotes/guides/management/agent.html) for details on setting up local and remote management of VM instances. By default the included **zkServer.sh** supports only local management - review the linked document to enable support for remote management (beyond the scope of this document).  有关设置 VM 实例的本地和远程管理的详细信息，请参阅 JMX 管理指南。 默认情况下，包含的 zkServer.sh 仅支持本地管理 - 查看链接文档以启用对远程管理的支持（超出本文档的范围）。


## Starting ZooKeeper with JMX enabled

The class **org.apache.zookeeper.server.quorum.QuorumPeerMain** will start a JMX manageable ZooKeeper server. This class registers the proper MBeans during initialization to support JMX monitoring and management of the instance. See **bin/zkServer.sh** for one example of starting ZooKeeper using QuorumPeerMain.  org.apache.zookeeper.server.quorum.QuorumPeerMain 类将启动一个 JMX 可管理的 ZooKeeper 服务器。 此类在初始化期间注册正确的 MBean 以支持 JMX 监视和实例管理。 有关使用 QuorumPeerMain 启动 ZooKeeper 的一个示例，请参见 bin/zkServer.sh。


## Run a JMX console

There are a number of JMX consoles available which can connect to the running server. For this example we will use Sun's **jconsole**.  有许多 JMX 控制台可以连接到正在运行的服务器。对于本示例，我们将使用 Sun 的 jconsole。

The Java JDK ships with a simple JMX console named [jconsole](http://java.sun.com/developer/technicalArticles/J2SE/jconsole.html) which can be used to connect to ZooKeeper and inspect a running server. Once you've started ZooKeeper using QuorumPeerMain start **jconsole**, which typically resides in **JDK_HOME/bin/jconsole**  Java JDK 附带一个名为 jconsole 的简单 JMX 控制台，可用于连接到 ZooKeeper 并检查正在运行的服务器。使用 QuorumPeerMain 启动 ZooKeeper 后，启动 jconsole，它通常位于 JDK_HOME/bin/jconsole

When the "new connection" window is displayed either connect to local process (if jconsole started on the same host as Server) or use the remote process connection.  当“新连接”窗口显示时，要么连接到本地进程（如果 jconsole 在与服务器相同的主机上启动）或使用远程进程连接。

By default the "overview" tab for the VM is displayed (this is a great way to get insight into the VM btw). Select the "MBeans" tab.  默认情况下，会显示 VM 的“概览”选项卡（顺便说一句，这是深入了解 VM 的好方法）。选择“MBeans”选项卡。

You should now see **org.apache.ZooKeeperService** on the left hand side. Expand this item and depending on how you've started the server you will be able to monitor and manage various service related features.  您现在应该在左侧看到 org.apache.ZooKeeperService。展开此项目，根据您启动服务器的方式，您将能够监控和管理各种与服务相关的功能。

Also note that ZooKeeper will register log4j MBeans as well. In the same section along the left hand side you will see "log4j". Expand that to manage log4j through JMX. Of particular interest is the ability to dynamically change the logging levels used by editing the appender and root thresholds. Log4j MBean registration can be disabled by passing **-Dzookeeper.jmx.log4j.disable=true** to the JVM when starting ZooKeeper. In addition, we can specify the name of the MBean with the **-Dzookeeper.jmx.log4j.mbean=log4j:hierarchy=default** option, in case we need to upgrade an integrated system using the old MBean name (`log4j:hierarchy = default`).  另请注意，ZooKeeper 也会注册 log4j MBean。在左侧的同一部分中，您将看到“log4j”。将其扩展为通过 JMX 管理 log4j。特别令人感兴趣的是通过编辑 appender 和 root 阈值来动态更改日志记录级别的能力。可以通过在启动 ZooKeeper 时将 -Dzookeeper.jmx.log4j.disable=true 传递给 JVM 来禁用 Log4j MBean 注册。此外，我们可以使用 -Dzookeeper.jmx.log4j.mbean=log4j:hierarchy=default 选项指定 MBean 的名称，以防我们需要使用旧的 MBean 名称（log4j:hierarchy = default）升级集成系统.


## ZooKeeper MBean Reference

This table details JMX for a server participating in a replicated ZooKeeper ensemble (ie not standalone). This is the typical case for a production environment.  该表详细说明了参与复制的 ZooKeeper 集合（即不是独立的）的服务器的 JMX。 这是生产环境的典型案例。

### MBeans, their names and description

| MBean | MBean Object Name | Description |
| ----- | ----------------- | ----------- |
| Quorum | ReplicatedServer_id<#> | Represents the Quorum, or Ensemble - parent of all cluster members. Note that the object name includes the "myid" of the server (name suffix) that your JMX agent has connected to.  代表 Quorum 或 Ensemble - 所有集群成员的父级。 请注意，对象名称包括 JMX 代理已连接到的服务器的“myid”（名称后缀）。 |
| LocalPeer/RemotePeer | replica.<#> | Represents a local or remote peer (ie server participating in the ensemble). Note that the object name includes the "myid" of the server (name suffix).  代表本地或远程对等方（即参与整体的服务器）。 请注意，对象名称包括服务器的“myid”（名称后缀）。 |
| LeaderElection | LeaderElection | Represents a ZooKeeper cluster leader election which is in progress. Provides information about the election, such as when it started.  表示正在进行的 ZooKeeper 集群领导者选举。 提供有关选举的信息，例如选举开始的时间。 |
| Leader | Leader | Indicates that the parent replica is the leader and provides attributes/operations for that server. Note that Leader is a subclass of ZooKeeperServer, so it provides all of the information normally associated with a ZooKeeperServer node.  指示父副本是领导者并为该服务器提供属性/操作。 请注意，Leader 是 ZooKeeperServer 的子类，因此它提供通常与 ZooKeeperServer 节点关联的所有信息。 |
| Follower | Follower | Indicates that the parent replica is a follower and provides attributes/operations for that server. Note that Follower is a subclass of ZooKeeperServer, so it provides all of the information normally associated with a ZooKeeperServer node.  指示父副本是跟随者并为该服务器提供属性/操作。 请注意，Follower 是 ZooKeeperServer 的子类，因此它提供通常与 ZooKeeperServer 节点关联的所有信息。 |
| DataTree | InMemoryDataTree | Statistics on the in memory znode database, also operations to access finer (and more computationally intensive) statistics on the data (such as ephemeral count). InMemoryDataTrees are children of ZooKeeperServer nodes.  内存中 znode 数据库的统计信息，以及访问更精细（计算量更大）的数据统计信息（例如临时计数）的操作。 InMemoryDataTrees 是 ZooKeeperServer 节点的子节点。 |
| ServerCnxn | `<session_id>` | Statistics on each client connection, also operations on those connections (such as termination). Note the object name is the session id of the connection in hex form.  每个客户端连接的统计信息，以及对这些连接的操作（例如终止）。 请注意，对象名称是十六进制形式的连接的会话 ID。 |

This table details JMX for a standalone server. Typically standalone is only used in development situations.

### MBeans, their names and description

| MBean | MBean Object Name | Description |
| ----- | ----------------- | ----------- |
| ZooKeeperServer | StandaloneServer_port<#> | Statistics on the running server, also operations to reset these attributes. Note that the object name includes the client port of the server (name suffix).  正在运行的服务器上的统计信息，以及重置这些属性的操作。 请注意，对象名称包括服务器的客户端端口（名称后缀）。 |
| DataTree | InMemoryDataTree | Statistics on the in memory znode database, also operations to access finer (and more computationally intensive) statistics on the data (such as ephemeral count).  内存中 znode 数据库的统计信息，以及访问更精细（计算量更大）的数据统计信息（例如临时计数）的操作。 |
| ServerCnxn | `<session_id>` | Statistics on each client connection, also operations on those connections (such as termination). Note the object name is the session id of the connection in hex form.  每个客户端连接的统计信息，以及对这些连接的操作（例如终止）。 请注意，对象名称是十六进制形式的连接的会话 ID。 |




