假设我们这个功能在acp 3.4 的时候上线，那么场景有两个，一是全新安装acp3.4 , 在部署的时候就直接部署 kafka operator 以及相应的 cr，不在部署之前的 kafka deployment，二是升级场景，比如从acp3.3升级到 acp 3.4 这时我写了一个升级的shell 脚本，执行shell 脚本就可以卸载原来的kafka，安装 operator 和相应的 cr


有关于 平台部署 和 平台升级 的问题想请教一下，
1、平台部署

在部署一个平台的时候，比如部署 acp 3.5 ，在安装包中执行 install.sh 脚本会做一些事情，比如安装 docker , 部署私有镜像仓库，导入需要的镜像，然后就可以通过页面配置相关信息，开始部署 k8s 本身的组件和平台的一些组件
这里面有一些问题，是什么功能提供了页面可以通过页面添加配置，是 base-operator 吗？我看 tonggbase-operator里面有crd 和 deploy config 等，这时 k8s 基本组件都没有部署，是怎么安装 这些 k8s 资源的了




install.sh 会安装 cpaas-installer
一开始的 acp 安装页面是 cpaas-installer
[cpaass-installer](https://gitlab-ce.alauda.cn/ait/cpaas-installer) 调 [tke-installer](http://confluence.alauda.cn/pages/viewpage.action?pageId=61906646) 部署的 k8s。k8s 部署好了，cpaas-installer 部署 [sentry](https://gitlab-ce.alauda.cn/ait/sentry) 和 [base-operator](https://gitlab-ce.alauda.cn/ait/chart-base-operator)。base-operator部署的其它


install.sh 会安装 cpaas-installer，cpaas-installer 安装完成就可以提供页面了，这时 cpaas-install 拿到页面的配置参数后，会用这些参数去调用 tke-installer 安装 k8s，k8s 部署好了，cpaas-installer 使用 chart 包的形式部署sentry 和 base-operator。base-operator 部署好了，会解析其中的 configmap，在 configmap 中定义了要安装哪些 chart 包，因此 base-operator 会去创建 AppRelease cr，sentry 就会根据 AppRelease cr 安装相应的 chart 包，也就是部署其他的一些组件

在部署相关组件时会有一些参数配置，比如 kafka，zookeeper，prometheus，他们会部署在特定节点，也会生成一些账号和密码，这些都是没有办法预先写到 configmap 中的
对于这方面，我也有疑惑，这些参数是在哪里指定的，也是通过页面吗？如果通过页面，是不是可以理解为 cpaas-install 拿到这些参数后，会去创建或者修改 ProductBase 这个 cr，base-operator 通过这个cr 的信息去 创建特定的 AppRelease，AppRelease 带有的参数会覆盖相应的 chart 包中 values 的值，然后就可以使用特定参数部署了，并且 base-operator 在生成 AppRelease 时也会生成一些 configmap 和 secret 供组件使用，比如将 kafka 账号密码写入 secret 供 lanaya 使用



kafka.auth, kafka.nodes这些要么是前端页面传进来的，要么是cpaas-installer初始化时填的。base-operator把他们翻译成AppRelease的values。






2、平台升级



