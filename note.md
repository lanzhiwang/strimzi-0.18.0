## 相关账号


邮箱账号：zhihu@alauda.io
密码：jiXJO567233


confluence 和 jira 账号：zhihu
confluence 和 jira 密码：jixjo567233


腾讯云：https://acp-hk-build.alauda.cn/console-platform/home/personal-info
账号：zhihu@alauda.io
密码：jiXJO567233


Gitlab 账号：zhihu
jixjo567233


gitlab api 访问账号：zhihu
rcvEkumeJLEk1NF8kkCK

push 镜像
ip：192.168.152.231
用户名：root
密码：cf218m4Bw5lNa3KSXB1w



kubeflow
https://192.168.140.157:30665
账户：admin@cpaas.io
密码：Qwe@1245
https://192.168.140.157:30665/_/jupyter/zh-CN/new?ns=kubeflow-admin-cpaas-io


海鑫环境：
Kubeflow 访问地址：https://111.207.117.58:30665/
ACP 访问地址：https://111.207.117.57:10443/
Chrome访问如果提示链接不安全，页面上键盘敲击：thisisunsafe 即可访问
账户：admin@cpaas.io
密码：Qwe@1245


http://testlink.alauda.cn
开发自测统一用一个账号。账号：guest 密码：1qaz2wsx#EDC
http://confluence.alauda.cn/display/~xxli/testlink

翻墙
wget -e "https_proxy=192.168.156.66:7890" https://github.com/alauda/jenkins-docker


/Users/zhh/.minikube/machines/minikube/config.json
 HostOptions --> EngineOptions -->
  InsecureRegistry: [
            "10.96.0.0/12",
            "192.168.99.0/24"
        ],
        "RegistryMirror": [
            "https://c8it25aj.mirror.aliyuncs.com/",
            "https://9o1kmxjk.mirror.aliyuncs.com"
        ],


```

kubectl get artifact -A

kubectl artifact createVersion --artifact operatorhub-kafka-operator  --tag="middleware-8575.2209052112" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-kafka-operator | grep -v operatorhub-kafka-operator.middleware-8575.2209052112`

kubectl delete pods -n cpaas-system -l app=catalog-operator


kubectl artifact createVersion --artifact operatorhub-rocketmq-operator --tag="middleware-11624.2212131938" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rocketmq-operator | grep -v operatorhub-rocketmq-operator.middleware-11624.2212131938`

kubectl delete pods -n cpaas-system -l app=catalog-operator


kubectl artifact createVersion --artifact operatorhub-rabbitmq-operator --tag="middleware-11140.2212062026" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rabbitmq-operator | grep -v operatorhub-rabbitmq-operator.middleware-11140.2212062026`

kubectl delete pods -n cpaas-system -l app=catalog-operator

kubectl get csv -A | grep rabbitmq-cluster-operator | awk -F ' ' '{printf("kubectl -n %s delete csv %s\n", $1, $2)}' | xargs -t -I {} bash -c "{}"





kubectl artifact createVersion --artifact operatorhub-rocketmq-operator --tag="v3.11-19-g3d9369a" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rocketmq-operator | grep -v operatorhub-rocketmq-operator.v3.11-19-g3d9369a`

kubectl delete pods -n cpaas-system -l app=catalog-operator








kubectl -n cpaas-system get pods | grep -E "olm|package|catalog" | awk -F ' ' '{printf("kubectl -n cpaas-system delete pods %s\n", $1)}' | xargs -t -I {} bash -c "{}"


$ curl -k -s -X PATCH -H "Accept: application/json, */*" -H "Content-Type: application/merge-patch+json" 127.0.0.1:8001/apis/app.alauda.io/v1alpha1/namespaces/cpaas-system/artifacts/operatorhub-rabbitmq-operator/status --data '{"status":{"synced":false}}'

kubectl get csv -A | grep rds-operator | awk -F ' ' '{printf("kubectl -n %s delete csv %s\n", $1, $2)}' | xargs -t -I {} bash -c "{}"


$ cce login
$ kubectl config get-contexts
$ kubectl config use-context cce-context-x86oula



export GOPROXY=https://athens.alauda.cn,direct

export GONOSUMDB=bitbucket.org/mathildetech/*,gomod.alauda.cn/*

GOPROXY=https://build-nexus.alauda.cn/repository/golang/,https://goproxy.cn,direct go mod tidy

GOPROXY=https://athens.alauda.cn,direct,https://goproxy.cn,direct go mod tidy

export GOPROXY=https://build-nexus.alauda.cn/repository/golang/,https://goproxy.cn,direct


export DOCKER_BUILDX=buildx
export DOCKER_BUILD_ARGS="--platform linux/arm64"
MVN_ARGS="-Dmaven.javadoc.skip=true -DskipITs -DskipTests" make all

helm install mystrimzi ./ --debug --dry-run
helm install --set Cluster=my-kafka mystrimzi ./ --debug --dry-run
helm install --set REGISTRY=192.168.134.214:60080 mystrimzi ./ --debug --dry-run


helm --set image.repository=192.168.34.233:60080/tdsql --set zookeeper.image.repository=192.168.34.233:60080/tdsql --set kafka.image.repository=192.168.34.233:60080/tdsql --set kafkaConnect.image.repository=192.168.34.233:60080/tdsql --set kafkaConnects2i.image.repository=192.168.34.233:60080/tdsql --set topicOperator.image.repository=192.168.34.233:60080/tdsql --set userOperator.image.repository=192.168.34.233:60080/tdsql --set kafkaInit.image.repository=192.168.34.233:60080/tdsql --set tlsSidecarKafka.image.repository=192.168.34.233:60080/tdsql --set tlsSidecarEntityOperator.image.repository=192.168.34.233:60080/tdsql --set kafkaMirrorMaker.image.repository=192.168.34.233:60080/tdsql --set kafkaBridge.image.repository=192.168.34.233:60080/tdsql --set kafkaExporter.image.repository=192.168.34.233:60080/tdsql --set jmxTrans.image.repository=192.168.34.233:60080/tdsql --set kafkaMirrorMaker2.image.repository=192.168.34.233:60080/tdsql --set cruiseControl.image.repository=192.168.34.233:60080/tdsql --set tlsSidecarCruiseControl.image.repository=192.168.34.233:60080/tdsql install mystrimzi ./ --debug --dry-run

tar -zcvf pass.tar.gz `git diff 198d68e712fa5913326055915c9fb3843bf84393 21625f5a06c7bef449a6d984ece184bcd6f27670 --name-only`


sshpass -p 'e!PM@M9sU2086)y' ssh root@192.168.16.52

$ git config --system --list
$ git config --local --list

git config --global http.proxy http://127.0.0.1:1087
git config --global https.proxy https://127.0.0.1:1087

$ git config --global http.proxy http://alauda:Lcyxw2z2y0gbbvn7mLvM@139.186.17.154:52975

$ cat /Users/huzhi/.gitconfig
[http]
    proxy = http://alauda:Tnriw2z267geivn5aLvk@139.186.17.154:52975

$ export GIT_SSL_NO_VERIFY=true

$ git config --global --unset http.proxy
$ git config --global --list
$ cat /Users/huzhi/.gitconfig


git config user.email "hzhilamp@163.com"
git config user.name "lanzhiwang"

git config user.name "胡志" && git config user.email "zhihu@alauda.io"



tc qdisc add dev eth0 root netem delay 1ms 1000ms 90%
该命令将 eth0 网卡的传输设置为 1ms ，同时，大约有 90% 的包会延迟 ± 1000ms 发送。

tc qdisc del dev eth0 root netem delay 1ms 1000ms 90%

tc qdisc list dev eth0



```







