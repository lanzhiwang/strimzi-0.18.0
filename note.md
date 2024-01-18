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

kubectl artifact createVersion --artifact operatorhub-kafka-operator  --tag="merge-github-3982.2309012144" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-kafka-operator | grep -v operatorhub-kafka-operator.merge-github-3982.2309012144`

kubectl delete pods -n cpaas-system -l app=catalog-operator


kubectl artifact createVersion --artifact operatorhub-rocketmq-operator --tag="v3.14.5-hotfix.79.1.g0cc705f8-fix-middleware-19173" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rocketmq-operator | grep -v operatorhub-rocketmq-operator.v3.14.5-hotfix.79.1.g0cc705f8-fix-middleware-19173`

kubectl delete pods -n cpaas-system -l app=catalog-operator


kubectl artifact createVersion --artifact operatorhub-rabbitmq-operator --tag="v3.14.0-fix.96.5.g454e6d98-middleware-18441" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rabbitmq-operator | grep -v operatorhub-rabbitmq-operator.v3.14.0-fix.96.5.g454e6d98-middleware-18441`

kubectl delete pods -n cpaas-system -l app=catalog-operator

kubectl get csv -A | grep rabbitmq-cluster-operator | awk -F ' ' '{printf("kubectl -n %s delete csv %s\n", $1, $2)}' | xargs -t -I {} bash -c "{}"

df -h
du -h --max-depth=1 /


kubectl artifact createVersion --artifact operatorhub-rds-operator --tag="v3.14.0-fix.533.1.gf89a9e7f-middleware-17386-other" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-rds-operator | grep -v operatorhub-rds-operator.v3.14.0-fix.533.1.gf89a9e7f-middleware-17386-other`

kubectl delete pods -n cpaas-system -l app=catalog-operator



kubectl artifact createVersion --artifact operatorhub-redis-operator --tag="v3.8.31" --namespace cpaas-system

kubectl delete artifactversions -n cpaas-system `kubectl get artifactversions -A | awk -F ' ' '{print($2)}' | grep operatorhub-redis-operator | grep -v operatorhub-redis-operator.v3.8.31`

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


git config user.email "hzhilamp@163.com" && git config user.name "lanzhiwang"

git config user.name "胡志" && git config user.email "zhihu@alauda.io"



tc qdisc add dev eth0 root netem delay 1ms 1000ms 90%
该命令将 eth0 网卡的传输设置为 1ms ，同时，大约有 90% 的包会延迟 ± 1000ms 发送。

tc qdisc del dev eth0 root netem delay 1ms 1000ms 90%

tc qdisc list dev eth0






$ wget https://github.com/chartmuseum/helm-push/releases/download/v0.10.2/helm-push_0.10.2_linux_amd64.tar.gz

$helm env | grep HELM_PLUGINS
HELM_PLUGINS="/root/.local/share/helm/plugins"

$ helm env | grep HELM_PLUGINS | awk -F= '{print $2}' | sed 's/"//g'
/root/.local/share/helm/plugins

$ mkdir -p $(helm env | grep HELM_PLUGINS | awk -F= '{print $2}' | sed 's/"//g')/helm-push

$ tar xf helm-push_0.10.2_linux_amd64.tar.gz -C $(helm env | grep HELM_PLUGINS | awk -F= '{print $2}' | sed 's/"//g')/helm-push

$ ll $(helm env | grep HELM_PLUGINS | awk -F= '{print $2}' | sed 's/"//g')/helm-push
总用量 16
drwxr-xr-x 2 root root    26 8月   9 11:00 bin
-rw-r--r-- 1 1001  123 11357 6月   5 03:22 LICENSE
-rw-r--r-- 1 1001  123   407 6月   5 03:22 plugin.yaml

$ ll $(helm env | grep HELM_PLUGINS | awk -F= '{print $2}' | sed 's/"//g')/helm-push/bin
总用量 36624
-rwxr-xr-x 1 1001 123 37502976 6月   5 03:26 helm-cm-push

$ helm plugin list
NAME    VERSION DESCRIPTION
cm-push 0.10.1  Push chart package to ChartMuseum

$ helm repo add --username admin --password Harbor12345 --ca-file /etc/docker/certs.d/core.harbor.domain/ca.crt harbor https://core.harbor.domain/chartrepo/library

$ helm cm-push --ca-file /etc/docker/certs.d/core.harbor.domain/ca.crt acserver-0.1.0.tgz harbor



$ helm pull oci://build-harbor.alauda.cn/middleware/mlops/gpu-operator-chart --version v0.0.0-default.31.ga63f98d0-learn-v23.3.2 --untar --username Zhi_Hu --password sjEwslurNujZWTFzhf3VVsXhIKHMwxrp --insecure-skip-tls-verify
Warning: chart media type application/tar+gzip is deprecated
Pulled: build-harbor.alauda.cn/middleware/mlops/gpu-operator-chart:v0.0.0-default.31.ga63f98d0-learn-v23.3.2
Digest: sha256:cdc9d9f6d576410be0e68d8d5772baa913c3d7c1c1ba9ef7c1944385d1b07e40

$ ll
总用量 0
drwxr-xr-x 5 root root 174 8月  11 03:24 gpu-operator
drwxr-xr-x 2 root root   6 8月  11 03:24 gpu-operator-chart







```







