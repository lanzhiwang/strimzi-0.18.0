### 1. 初始化

```bash
$ mkdir -p $GOPATH/src/github.com/example-inc/
$ cd $GOPATH/src/github.com/example-inc/
$ operator-sdk new nginx-operator --api-version=example.com/v1alpha1 --kind=Nginx --type=helm
$ tree -a .
.
└── nginx-operator
    ├── build
    │   └── Dockerfile
    ├── deploy
    │   ├── crds
    │   │   ├── example.com_nginxes_crd.yaml
    │   │   └── example.com_v1alpha1_nginx_cr.yaml
    │   ├── operator.yaml
    │   ├── role.yaml
    │   ├── role_binding.yaml
    │   └── service_account.yaml
    ├── helm-charts
    │   └── nginx
    │       ├── .helmignore
    │       ├── Chart.yaml
    │       ├── charts
    │       ├── templates
    │       │   ├── NOTES.txt
    │       │   ├── _helpers.tpl
    │       │   ├── deployment.yaml
    │       │   ├── ingress.yaml
    │       │   ├── service.yaml
    │       │   ├── serviceaccount.yaml
    │       │   └── tests
    │       │       └── test-connection.yaml
    │       └── values.yaml
    └── watches.yaml

9 directories, 18 files
$
$ cd nginx-operator
$ pwd
/Users/huzhi/go/src/github.com/example-inc/nginx-operator

# 使用 git 跟踪文件变化
$ git init .
$ git status
$ git add .
$ git config user.email "hzhilamp@163.com"
$ git config user.name "lanzhiwang"
$ git commit -m 'first commit'
$ git status

```





