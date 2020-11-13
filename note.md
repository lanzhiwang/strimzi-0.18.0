基础架构的开发环境

* 192.168.16.52
* 192.168.16.53
* 192.168.16.54
* 192.168.16.55

alias sshint="ssh root@118.24.205.100"

sshpass -p 'e!PM@M9sU2086)y' ssh root@192.168.16.52


北京 WiFi

7E78P0AA


邮箱

jira

wiki http://confluence.alauda.cn/pages/viewpage.action?pageId=67561893

gitlab

devops https://acp-hk-build.alauda.cn/console-devops/workspace/tdsql/pipelines/all/tdsql-installer-chart-freeze


## 相关账号

邮箱账号：zhihu@alauda.io
密码：jiXJO567233

confluence 和 jira 账号：zhihu
confluence 和 jira 密码：jixjo567233

腾讯云
https://acp-hk-build.alauda.cn/console-platform/home/personal-info
账号：zhihu@alauda.io
密码：jiXJO567233



Gitlab 账号
zhihu
jixjo567233

gitlab api 访问账号
zhihu
rcvEkumeJLEk1NF8kkCK

SwitchyOmega
alauda/Tnriw2z267geivn5aLvk

139.186.17.154:52975










使用 http 协议

```
$ git config --system --list
fatal: unable to read config file '/etc/gitconfig': No such file or directory


$ git config --global --list
fatal: unable to read config file '/Users/huzhi/.gitconfig': No such file or directory


$ git config --local --list
fatal: --local can only be used inside a git repository


$ git config --local --list
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
core.ignorecase=true
core.precomposeunicode=true
user.email=hzhilamp@163.com
user.name=lanzhiwang
remote.origin.url=git@github.com:lanzhiwang/strimzi-0.18.0.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.main.remote=origin
branch.main.merge=refs/heads/main

$ git config --global http.proxy http://alauda:Tnriw2z267geivn5aLvk@139.186.17.154:52975
$ git config --global --list
http.proxy=http://alauda:Tnriw2z267geivn5aLvk@139.186.17.154:52975

$ cat /Users/huzhi/.gitconfig
[http]
    proxy = http://alauda:Tnriw2z267geivn5aLvk@139.186.17.154:52975

$ export GIT_SSL_NO_VERIFY=true

$ git config --global --unset http.proxy
$ git config --global --list
$ cat /Users/huzhi/.gitconfig


git config user.email "hzhilamp@163.com"
git config user.name "lanzhiwang"

git config user.name "胡志"
git config user.email "zhihu@alauda.io"
  
```




## 产品的历史

* 2017年5月 **Alauda EE 1.X（ACE 1.X）**
* 2018年10月 **ACE 2.X**
* 2018年11月开始开发 **ACP 1.0**，基于ACP 1.X，增加了三个新的产品：**DevOps**、**ASM(service mesh)**、**AML(machine learning)**。
* 2019年6月结合 ACE 2.X 和 ACP 1.X 的优势，发布了 **ACP 2.0** 产品。平台采用同 ACP 1.X 一样的 k8s 扩展机制实现，并支持多集群多租户的能力。容器和 DevOps 功能上和 ACE 2.X 对齐，同时还将 ASM、AML 迁移到ACP 2.X 上。在 ACP 2.X 的开发过程中，同时开始了和腾讯TKE团队开发的 **TKE 3.0** 产品的融合。
* 2019年9月发布 ACP 2.x 和 TKE 3.0 的融合产品 **TKE for Alauda 2.3（即ACP 2.3）**。该产品的集群管理、集群插件管理采用了 TKE 3.0 的模块，其它模块仍然使用 ACP 2.X。后来 TKE for Alauda 改名为 **TKE企业版**，内部还习惯称 ACP。
* 2019年底 TKE企业版 和 **TSF、TDSQL、CSP** 等腾讯产品开始进行对接。同时开始 **TKE PaaS** 的开发，TKE PaaS 是以 TKE 企业版为底座，再加上若干腾讯产品（操作系统、数据库、存储、微服务等）后形成的较完整的 PaaS 平台。TKE PaaS 内部有时会习惯称为 **ACE 3.0**。
* 2020年3月发布 **TKE企业版2.9（即ACP 2.12）** 以及 **TKE PaaS beta版**，包含 TSF、TDSQL、CSP、Ti-Matrix等腾讯产品的集成。
* 2020年6月发布 **TKE企业版2.12（即ACP 2.12）** 以及 **TKE PaaS 正式版**，包含 TSF、TDSQL、CSP、Redis、CMQ、Coding、Ti-Matrix 等腾讯产品的集成。



## 腾讯跳板机

```
跳板机登陆方法：http://confluence.alauda.cn/pages/viewpage.action?pageId=27172708
# Tencent Yun Chongqing springboard
# jumpserver IP:118.24.213.153
# jumpserver login user: zhihu
# jumpserver port:52022
# jumpserver login key
#####################################
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA2mSPIBBvCu7TgdHeB0LOWxynbocQ5GEzczKh2N0Egft4ICnH
8D9yccSJwFDhloXCxlR0x48tAbNXmnfwox7bLCL9IHBUVDrGcNIRKTKAzFlGxSsm
gdIzc3P85W9/VwQCPeos062chffDZbCAO0608K+0TI2ULJDJ7efnw8Hc+5qTmpk/
JYfmoTNYWlgF52X+sTWvxH2b5ZKXBEDGDSRGWK+ztazwj2HbLeyULijxHq/TF9jf
48ebCamn9Vj1/7ZcyG24jj383+0V+l3im+P0QTQQqeGsAiXLNRtckOdo3G7v1X06
4m7CQ8VJWWwKkDbYob7CZeaePAT1iH+JK3y5/wIDAQABAoIBAQC+yZyzkUfA0FVc
EyCZTUaDGCw5Bau/KB9PYws7LhIzD6Goz3dIrdToCJ+ir8XzvpUiuENw1uallqxQ
WLmTd3BXRZXG0fsJvnL/urSdPe6BFvkZZJH2VdD26nwjX91qAimHN13D6uZTrtg3
rRLJPQAbSBQF0KWCrVaLDM5PGLxZ29n3AidWkjGR+mQiR6l23uCHNwj4GEF+CXrj
GKhsHsj687j8M9klycNsNDSvtDwWOtp+M6BPSaXlnrY+ycLhDJ5LS+2uL9j8tvev
eWXxlFfLL0fKHcs4yZkfpJWOzj8P1MKvNzbAYWUYgIaK0LSJNEIfwpp6nC1t4foe
yD0YJ2bZAoGBAPTaOuYI797U6CMnLO0jue0Qp9uMi9zsYCyxrdAPowbk+9mgO8XI
xEQ/u42bXQB0U1Q7lQOgWZfu6Ue3fp+CNFhlgFkcP/eenTB5iNOb/VsFVuDphkKH
QLbYJbSWuYdDlNOoPxLKgjS1T5l6yo0Ck7XtxG0jGj5/uDSQrpfHbdUbAoGBAORV
8LC9FAxN7aFXehSSgNjBWDiD+F/aOCXhiiHPj30fV6JoDTQNFb+A/2A+L18DOvPW
AlNXVQC7xIWCIqQ+dGebVS0R94y2jm+YbWfXcmh2Tfx2fwZrISqW2zmU4qsxhOfU
k2ULb0/Y784AMkWvCzpUaYkFS8gFdEtQS1WKAlDtAoGAXzye2iixvDeNz1aGh/p0
b/whfijtodGjGt9FXv8mByF7wEst1KFhjbZIaiz7AJk+bC38qPtuvcTkocuCieJo
H9XjFUYCr3rXYypyiPRMmGG8SCEs4qWfCz+JcvOJWE52DdmMJu/zszKusmDrdeuB
rqq700NrCtI8wN1hu5GLa+8CgYEA2ZHmIZJY+wx6RIVlBxs9+MvqcxeU4Ei/vaC2
DVeIozHtQAwjoJhjQ7H4JM28N62NS/B9EMqjbWp9bLW+qn/0TRDezW5UUllVSZKV
lR/enRk1YD3M9eG4natXQvvSLEuoF3sf42VM8GmGvuTDAlEzwqXSVcSdG//Oe0EM
N3qkkFUCgYBbcj7y9X9qZIDHsDeYBWH2Xp0kNZPeOOwAbHoZV3HYYIc2zpeB2GSJ
8DUTwG7OpA8y0aPJRRUdVSi3xBRZtd1LyzX+DD03tPxKZ8AU2Ydh4fetuD4LzxQC
OYhd0IksT1TU6a9l8WVDRBSS+eQFQmuEetFD0p7J0xE2Qtg9ZSet/Q==
-----END RSA PRIVATE KEY-----

# login: ssh root@public_ip

# 登录跳板机
ssh -i ~/.ssh/lqy_tencent_jumpserver.pem zhihu@118.24.213.153 -p 52022


[zhihu@jumpserver ~]$
[zhihu@jumpserver ~]$ ssh root@139.186.122.125
Warning: Permanently added '139.186.122.125' (ECDSA) to the list of known hosts.
Last login: Mon Sep 21 14:53:24 2020 from 61.148.199.18
[root@mw-init ~]#


Host *
    ServerAliveInterval 10
    TCPKeepAlive yes
    ControlPersist yes
    ControlMaster auto
    ControlPath ~/.ssh/master_%r_%h_%p

ssh -i ~/.ssh/lqy_tencent_jumpserver.pem zhihu@118.24.213.153 -p 52022
Host tencent_jumper
    HostName 118.24.213.153
    User zhihu
    Port 52022
    IdentityFile ~/.ssh/lqy_tencent_jumpserver.pem
Host global-init
    HostName 139.186.122.125
    User root
    IdentityFile ~/.ssh/lqy
    ProxyJump tencent_jumper
    
    
```

上手项目描述：编写一个Operator，实现对于指定环境变量内的资源监控，具体要求如下：
1. 基于Operator-SDK来实现operator
2. 每隔1分钟执行一次刷新操作
3. 每次刷新的时候，在stdout打印下列资源的信息：
    deployment, statefulset, secret, configmap, pod, service, endpoint
每种信息需要打印name, namespace, kind, status以及其他你认为适合的信息
4. 编写chart来部署这个operator
5. 设置流水线来支持这个项目的CI

疑问：
1. 如何指定环境变量，也就是如何输入？

CRD
CR









kafka 官方 operator 提交历史

https://github.com/banzaicloud/kafka-operator/commits/master?after=5a7218622140ee10e9872213316d3056b8f2c2e3+629&branch=master







* dlv
* go-outline
* gocode
* godef
* goimports
* gomodifytags
* goplay
* gorename
* gotests
* impl
* fillstruct
* go-symbols
* gocode-gomod
* godoctor
* golint
* gopkgs
* gopls
* goreturns
* guru











global.images.imoocpodOperator.tag=origin_master-b18-7018120.0





blob:https://harbor-b.alauda.cn/9b6965d5-d5ea-43d4-bce3-c0e7984c1cd9







```
---
# Source: mychart/templates/service_account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: imooc-operator
---
# Source: mychart/templates/k8s.imooc.com_imoocpods_crd.yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: imoocpods.k8s.imooc.com
spec:
  group: k8s.imooc.com
  names:
    kind: ImoocPod
    listKind: ImoocPodList
    plural: imoocpods
    singular: imoocpod
  scope: Namespaced
  subresources:
    status: {}
  validation:
    openAPIV3Schema:
      description: ImoocPod is the Schema for the imoocpods API
      properties:
        apiVersion:
          description: 'APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
          type: string
        kind:
          description: 'Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the client
            submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
          type: string
        metadata:
          type: object
        spec:
          description: ImoocPodSpec defines the desired state of ImoocPod
          properties:
            replicas:
              description: 'INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
                Important: Run "operator-sdk generate k8s" to regenerate code after
                modifying this file Add custom validation using kubebuilder tags:
                https://book-v1.book.kubebuilder.io/beyond_basics/generating_crd.html'
              type: integer
            size:
              type: integer
            watched_namespace:
              type: string
          required:
          - replicas
          - size
          - watched_namespace
          type: object
        status:
          description: ImoocPodStatus defines the observed state of ImoocPod
          properties:
            podNames:
              items:
                type: string
              type: array
            replicas:
              description: 'INSERT ADDITIONAL STATUS FIELD - define observed state
                of cluster Important: Run "operator-sdk generate k8s" to regenerate
                code after modifying this file Add custom validation using kubebuilder
                tags: https://book-v1.book.kubebuilder.io/beyond_basics/generating_crd.html'
              type: integer
            size:
              type: integer
            watched_namespace:
              type: string
          required:
          - podNames
          - replicas
          - size
          - watched_namespace
          type: object
      type: object
  version: v1alpha1
  versions:
  - name: v1alpha1
    served: true
    storage: true
---
# Source: mychart/templates/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: imooc-operator
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - services/finalizers
  - endpoints
  - persistentvolumeclaims
  - events
  - configmaps
  - secrets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - replicasets
  - statefulsets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  verbs:
  - get
  - create
- apiGroups:
  - apps
  resourceNames:
  - imooc-operator
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - apps
  resources:
  - replicasets
  - deployments
  verbs:
  - get
- apiGroups:
  - k8s.imooc.com
  resources:
  - '*'
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
---
# Source: mychart/templates/role_binding.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: imooc-operator
subjects:
- kind: ServiceAccount
  name: imooc-operator
roleRef:
  kind: Role
  name: imooc-operator
  apiGroup: rbac.authorization.k8s.io
---
# Source: mychart/templates/operator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: imooc-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      name: imooc-operator
  template:
    metadata:
      labels:
        name: imooc-operator
    spec:
      serviceAccountName: imooc-operator
      containers:
        - name: imooc-operator
          # Replace this with the built image name
          # todo 替换为生成的镜像
          # kind load docker-image rubinus/imoocpod-operator
          # image: REPLACE_IMAGE
          # image: docker.io/rubinus/imoocpod-operator:v0.1
          # image: harbor-b.alauda.cn/tdsql/imoocpod-operator:origin_master-b18-7018120.0
          image: harbor-b.alauda.cn/imoocpod-operator:origin_master-b18-7018120.0
          command:
          - imooc-operator
          # 由于使用 kind 的缘故，imagePullPolicy 需要修改为 Never
          # imagePullPolicy: Always
          imagePullPolicy: Always
          env:
            - name: WATCH_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: OPERATOR_NAME
              value: "imooc-operator"



```