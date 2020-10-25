### 1. 初始化

```bash
$ mkdir -p $GOPATH/src/github.com/example-inc/
$ cd $GOPATH/src/github.com/example-inc/
$ operator-sdk new memcached-operator
$ tree -a .
.
└── memcached-operator
    ├── .gitignore
    ├── build
    │   ├── Dockerfile
    │   └── bin
    │       ├── entrypoint
    │       └── user_setup
    ├── cmd
    │   └── manager
    │       └── main.go
    ├── deploy
    │   ├── operator.yaml
    │   ├── role.yaml
    │   ├── role_binding.yaml
    │   └── service_account.yaml
    ├── go.mod
    ├── go.sum
    ├── pkg
    │   ├── apis
    │   │   └── apis.go
    │   └── controller
    │       └── controller.go
    ├── tools.go
    └── version
        └── version.go

10 directories, 15 files
$
$ cd memcached-operator
$ pwd
/Users/huzhi/go/src/github.com/example-inc/memcached-operator

# 使用 git 跟踪文件变化
$ git init .
$ git status
$ git add .
$ git config user.email "hzhilamp@163.com"
$ git config user.name "lanzhiwang"
$ git commit -m 'first commit'
$ git status

```


### 2. Use the CLI to add a new CRD API 

```bash
$ operator-sdk add api --api-version=cache.example.com/v1alpha1 --kind=Memcached
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   deploy/role.yaml

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	deploy/crds/
	pkg/apis/addtoscheme_cache_v1alpha1.go
	pkg/apis/cache/

no changes added to commit (use "git add" and/or "git commit -a")
$
$ tree -a deploy/crds
deploy/crds
├── cache.example.com_memcacheds_crd.yaml
└── cache.example.com_v1alpha1_memcached_cr.yaml

0 directories, 2 files
$
$ tree -a pkg/apis/cache
pkg/apis/cache
├── group.go
└── v1alpha1
    ├── doc.go
    ├── memcached_types.go
    ├── register.go
    └── zz_generated.deepcopy.go

1 directory, 5 files
$

```


### 3. Modify the spec and status of the Memcached Custom Resource

```go
# pkg/apis/cache/v1alpha1/memcached_types.go

type MemcachedSpec struct {
	// Size is the size of the memcached deployment
	Size int32 `json:"size"`
}
type MemcachedStatus struct {
	// Nodes are the names of the memcached pods
	Nodes []string `json:"nodes"`
}

```


### 4. operator-sdk generate k8s

```bash
$ operator-sdk generate k8s
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   pkg/apis/cache/v1alpha1/zz_generated.deepcopy.go

no changes added to commit (use "git add" and/or "git commit -a")
$ git commit -am 'operator-sdk generate k8s'
$ git status
On branch master
nothing to commit, working tree clean

```


### 5. operator-sdk generate crds

```bash
$ operator-sdk generate crds
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   deploy/crds/cache.example.com_memcacheds_crd.yaml

no changes added to commit (use "git add" and/or "git commit -a")
$ git diff deploy/crds/cache.example.com_memcacheds_crd.yaml
diff --git a/deploy/crds/cache.example.com_memcacheds_crd.yaml b/deploy/crds/cache.example.com_memcacheds_crd.yaml
index 411e4a0..d146cf6 100644
--- a/deploy/crds/cache.example.com_memcacheds_crd.yaml
+++ b/deploy/crds/cache.example.com_memcacheds_crd.yaml
@@ -30,9 +30,30 @@ spec:
           type: object
         spec:
           description: MemcachedSpec defines the desired state of Memcached
+          properties:
+            size:
+              description: 'INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
+                Important: Run "operator-sdk generate k8s" to regenerate code after
+                modifying this file Add custom validation using kubebuilder tags:
+                https://book-v1.book.kubebuilder.io/beyond_basics/generating_crd.html'
+              format: int32
+              type: integer
+          required:
+          - size
           type: object
         status:
           description: MemcachedStatus defines the observed state of Memcached
+          properties:
+            nodes:
+              description: 'INSERT ADDITIONAL STATUS FIELD - define observed state
+                of cluster Important: Run "operator-sdk generate k8s" to regenerate
+                code after modifying this file Add custom validation using kubebuilder
+                tags: https://book-v1.book.kubebuilder.io/beyond_basics/generating_crd.html'
+              items:
+                type: string
+              type: array
+          required:
+          - nodes
           type: object
       type: object
   version: v1alpha1
$
$ git commit -am 'operator-sdk generate crds'
$ git status
On branch master
nothing to commit, working tree clean

```


### 6. Add a new Controller 

```bash
$ operator-sdk add controller --api-version=cache.example.com/v1alpha1 --kind=Memcached
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	pkg/controller/add_memcached.go
	pkg/controller/memcached/

nothing added to commit but untracked files present (use "git add" to track)
$ tree -a pkg/controller/memcached
pkg/controller/memcached
└── memcached_controller.go

0 directories, 1 file
$ git add .
$ git commit -m 'add controller'
$ git status
On branch master
nothing to commit, working tree clean

```


### 7. Build and run the Operator

```bash
$ oc create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml

$ operator-sdk build quay.io/example/memcached-operator:v0.0.1

$ sed -i 's|REPLACE_IMAGE|quay.io/example/memcached-operator:v0.0.1|g' deploy/operator.yaml

$ podman push quay.io/example/memcached-operator:v0.0.1

$ oc create -f deploy/role.yaml

$ oc create -f deploy/role_binding.yaml

$ oc create -f deploy/service_account.yaml

$ oc create -f deploy/operator.yaml


```

### 8. Verify that the Operator can deploy a Memcached application

```bash
$ cat deploy/crds/cache_v1alpha1_memcached_cr.yaml
apiVersion: "cache.example.com/v1alpha1"
kind: "Memcached"
metadata:
  name: "example-memcached"
spec:
  size: 3

$ oc apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml

```

### 9. Generate an Operator manifest

```bash
$ operator-sdk generate csv --csv-version 0.0.1
INFO[0000] Generating CSV manifest version 0.0.1
INFO[0006] Fill in the following required fields in file memcached-operator.clusterserviceversion.yaml:
	spec.description
	spec.keywords
	spec.provider
INFO[0006] CSV manifest generated successfully
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	deploy/olm-catalog/

nothing added to commit but untracked files present (use "git add" to track)

$ tree -a deploy/olm-catalog
deploy/olm-catalog
└── memcached-operator
    └── manifests
        ├── cache.example.com_memcacheds_crd.yaml
        └── memcached-operator.clusterserviceversion.yaml

2 directories, 2 files
$
$ git add .
$ git commit -m 'Generate an Operator manifest'
$ git status
On branch master
nothing to commit, working tree clean
$

```


### 10. Create an OperatorGroup

```bash
$ cat << EOF > deploy/olm-catalog/memcached-operator/manifests/memcached-operator.operatorgroup.yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: memcached-operator-group
  namespace: default
spec:
  targetNamespaces:
  - default

EOF
$
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	deploy/olm-catalog/memcached-operator/manifests/memcached-operator.operatorgroup.yaml

nothing added to commit but untracked files present (use "git add" to track)
$ git add .
$ git commit -m 'Create an OperatorGroup'
$ git status
On branch master
nothing to commit, working tree clean

```


### 11. Deploy the Operator

```bash
$ oc apply -f deploy/olm-catalog/memcached-operator/0.0.1/memcached-operator.v0.0.1.clusterserviceversion.yaml

$ oc create -f deploy/crds/cache.example.com_memcacheds_crd.yaml

$ oc create -f deploy/service_account.yaml

$ oc create -f deploy/role.yaml

$ oc create -f deploy/role_binding.yaml

```


### 12. yaml manifests

```bash
$ tree -a deploy
deploy
├── crds
│   ├── cache.example.com_memcacheds_crd.yaml
│   └── cache.example.com_v1alpha1_memcached_cr.yaml
├── olm-catalog
│   └── memcached-operator
│       └── manifests
│           ├── cache.example.com_memcacheds_crd.yaml
│           ├── memcached-operator.clusterserviceversion.yaml
│           └── memcached-operator.operatorgroup.yaml
├── operator.yaml
├── role.yaml
├── role_binding.yaml
└── service_account.yaml

4 directories, 9 files

```


