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


## 13. Generate Bundle Annotations and DockerFile

```bash
$ opm alpha bundle generate --directory ./deploy/olm-catalog/memcached-operator/manifests --package memcacheds-operator --channels stable,beta --default stable
INFO[0000] Building annotations.yaml
INFO[0000] Writing annotations.yaml in /Users/huzhi/go/src/github.com/example-inc/memcached-operator/deploy/olm-catalog/memcached-operator/metadata
INFO[0000] Building Dockerfile
INFO[0000] Writing bundle.Dockerfile in /Users/huzhi/go/src/github.com/example-inc/memcached-operator

$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	bundle.Dockerfile
	deploy/olm-catalog/memcached-operator/metadata/

nothing added to commit but untracked files present (use "git add" to track)

$ tree -a deploy/olm-catalog/memcached-operator/metadata
deploy/olm-catalog/memcached-operator/metadata
└── annotations.yaml

0 directories, 1 file

$ cat bundle.Dockerfile
FROM scratch

LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=memcacheds-operator
LABEL operators.operatorframework.io.bundle.channels.v1=stable,beta
LABEL operators.operatorframework.io.bundle.channel.default.v1=stable

COPY deploy/olm-catalog/memcached-operator/manifests /manifests/
COPY deploy/olm-catalog/memcached-operator/metadata /metadata/
$
$ cat deploy/olm-catalog/memcached-operator/metadata/annotations.yaml
annotations:
  operators.operatorframework.io.bundle.channel.default.v1: stable
  operators.operatorframework.io.bundle.channels.v1: stable,beta
  operators.operatorframework.io.bundle.manifests.v1: manifests/
  operators.operatorframework.io.bundle.mediatype.v1: registry+v1
  operators.operatorframework.io.bundle.metadata.v1: metadata/
  operators.operatorframework.io.bundle.package.v1: memcacheds-operator
$
$ tree -a deploy
deploy
├── crds
│   ├── cache.example.com_memcacheds_crd.yaml
│   └── cache.example.com_v1alpha1_memcached_cr.yaml
├── olm-catalog
│   └── memcached-operator
│       ├── manifests
│       │   ├── cache.example.com_memcacheds_crd.yaml
│       │   └── memcached-operator.clusterserviceversion.yaml
│       └── metadata
│           └── annotations.yaml
├── operator.yaml
├── role.yaml
├── role_binding.yaml
└── service_account.yaml

5 directories, 9 files

```


## 14. Build Bundle Image

```bash
$ opm alpha bundle build --directory ./deploy/olm-catalog/memcached-operator/manifests/ --tag lanzhiwang/memcached-operator.v0.1.0:latest --image-builder docker --package memcacheds-operator --channels stable,beta --default stable
INFO[0000] Building annotations.yaml
INFO[0000] An annotations.yaml already exists in the directory: metadata/
INFO[0000] Validating existing annotations.yaml
INFO[0000] Building Dockerfile
INFO[0000] A bundle.Dockerfile already exists in current working directory: /Users/huzhi/go/src/github.com/example-inc/memcached-operator
INFO[0000] Building bundle image
Sending build context to Docker daemon  371.2kB
Step 1/9 : FROM scratch
 --->
Step 2/9 : LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
 ---> Running in 0280d36f30e3
Removing intermediate container 0280d36f30e3
 ---> 7618aa9633c7
Step 3/9 : LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
 ---> Running in 012de34a67ac
Removing intermediate container 012de34a67ac
 ---> 404775fd529f
Step 4/9 : LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
 ---> Running in d5fb6fedfe39
Removing intermediate container d5fb6fedfe39
 ---> 5362e5c9f0ef
Step 5/9 : LABEL operators.operatorframework.io.bundle.package.v1=memcacheds-operator
 ---> Running in a93b6332c76c
Removing intermediate container a93b6332c76c
 ---> 85240f25509a
Step 6/9 : LABEL operators.operatorframework.io.bundle.channels.v1=stable,beta
 ---> Running in 47f13af10a37
Removing intermediate container 47f13af10a37
 ---> eab05a74dd14
Step 7/9 : LABEL operators.operatorframework.io.bundle.channel.default.v1=stable
 ---> Running in 661f9bb8b87a
Removing intermediate container 661f9bb8b87a
 ---> f6fdcb7e7d84
Step 8/9 : COPY deploy/olm-catalog/memcached-operator/manifests /manifests/
 ---> c7585519f2c9
Step 9/9 : COPY deploy/olm-catalog/memcached-operator/metadata /metadata/
 ---> d26a19ede670
Successfully built d26a19ede670
Successfully tagged lanzhiwang/memcached-operator.v0.1.0:latest

$ git status
On branch master
nothing to commit, working tree clean

$ docker images lanzhiwang/memcached-operator.v0.1.0:latest
REPOSITORY                             TAG                 IMAGE ID            CREATED              SIZE
lanzhiwang/memcached-operator.v0.1.0   latest              d26a19ede670        About a minute ago   6.66kB

```


## 15. Validate Bundle Image

```bash
# https://hub.docker.com/u/lanzhiwang
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: lanzhiwang
Password:
Login Succeeded

$ docker push lanzhiwang/memcached-operator.v0.1.0:latest
The push refers to repository [docker.io/lanzhiwang/memcached-operator.v0.1.0]
a2a8a462d9d5: Pushed
eafc8b33f233: Pushed
latest: digest: sha256:bc9efb42829a7aabd65f9fbfa4a45b02b31b8fedc9c65fcaa8b12cafae2abfac size: 732

$ opm alpha bundle validate --tag lanzhiwang/memcached-operator.v0.1.0:latest --image-builder docker
INFO[0000] Create a temp directory at /var/folders/4f/gy92m6hd2xj3c6_yz0dht6880000gn/T/bundle-450137853  container-tool=docker
DEBU[0000] Pulling and unpacking container image         container-tool=docker
INFO[0000] running /usr/local/bin/docker pull lanzhiwang/memcached-operator.v0.1.0:latest  container-tool=docker
INFO[0004] running docker create                         container-tool=docker
DEBU[0004] [docker create lanzhiwang/memcached-operator.v0.1.0:latest ]  container-tool=docker
INFO[0004] running docker cp                             container-tool=docker
DEBU[0004] [docker cp 075bd43cc5d886fcf752d4fa6f097ba7d8de41252cd09dbee45600653ad3b2a4:/. /var/folders/4f/gy92m6hd2xj3c6_yz0dht6880000gn/T/bundle-450137853]  container-tool=docker
INFO[0005] running docker rm                             container-tool=docker
DEBU[0005] [docker rm 075bd43cc5d886fcf752d4fa6f097ba7d8de41252cd09dbee45600653ad3b2a4]  container-tool=docker
INFO[0005] Unpacked image layers, validating bundle image format & contents  container-tool=docker
DEBU[0005] Found manifests directory                     container-tool=docker
DEBU[0005] Found metadata directory                      container-tool=docker
DEBU[0005] Getting mediaType info from manifests directory  container-tool=docker
INFO[0005] Found annotations file                        container-tool=docker
INFO[0005] Could not find optional dependencies file     container-tool=docker
DEBU[0005] Validating bundle contents                    container-tool=docker
DEBU[0005] Validating "apiextensions.k8s.io/v1beta1, Kind=CustomResourceDefinition" from file "cache.example.com_memcacheds_crd.yaml"  container-tool=docker
DEBU[0005] Validating "operators.coreos.com/v1alpha1, Kind=ClusterServiceVersion" from file "memcached-operator.clusterserviceversion.yaml"  container-tool=docker
INFO[0005] All validation tests have been completed successfully  container-tool=docker

```


## 16. add the given set of bundle images to an index image

```bash
$ opm index add --bundles lanzhiwang/memcached-operator.v0.1.0:latest --tag lanzhiwang/index:1.0.0 -p docker -u docker
INFO[0000] building the index                            bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0000] running /usr/local/bin/docker pull lanzhiwang/memcached-operator.v0.1.0:latest  bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] running docker create                         bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] running docker cp                             bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] running docker rm                             bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] Could not find optional dependencies file     dir=bundle_tmp119457501 file=bundle_tmp119457501/metadata load=annotations
INFO[0005] found csv, loading bundle                     dir=bundle_tmp119457501 file=bundle_tmp119457501/manifests load=bundle
INFO[0005] loading bundle file                           dir=bundle_tmp119457501/manifests file=cache.example.com_memcacheds_crd.yaml load=bundle
INFO[0005] loading bundle file                           dir=bundle_tmp119457501/manifests file=memcached-operator.clusterserviceversion.yaml load=bundle
INFO[0005] Generating dockerfile                         bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] writing dockerfile: index.Dockerfile470931507  bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] running docker build                          bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"
INFO[0005] [docker build -f index.Dockerfile470931507 -t lanzhiwang/index:1.0.0 .]  bundles="[lanzhiwang/memcached-operator.v0.1.0:latest]"

$ git status
On branch master
nothing to commit, working tree clean

$ docker images lanzhiwang/index:1.0.0
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
lanzhiwang/index    1.0.0               a0732b06c570        41 seconds ago      67.3MB

##########################################################################

$ docker push lanzhiwang/index:1.0.0
$ docker rmi lanzhiwang/memcached-operator.v0.1.0:latest
$ docker rmi lanzhiwang/index:1.0.0
$ opm index add --bundles lanzhiwang/memcached-operator.v0.1.0:latest --from-index lanzhiwang/index:1.0.0 --tag lanzhiwang/index:2.0.0 -p docker -u docker

```











```json



{
    "apiVersion": "operators.coreos.com/v1alpha1",
    "kind": "Subscription",
    "metadata": {
        "creationTimestamp": "2021-09-29T04:15:09Z",
        "generation": 1,
        "labels": {
            "catalog": "platform"
        },
        "managedFields": [
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                    "f:metadata": {
                        "f:labels": {
                            ".": {},
                            "f:catalog": {}
                        }
                    },
                    "f:spec": {
                        ".": {},
                        "f:channel": {},
                        "f:installPlanApproval": {},
                        "f:name": {},
                        "f:source": {},
                        "f:sourceNamespace": {},
                        "f:startingCSV": {}
                    }
                },
                "manager": "Mozilla",
                "operation": "Update",
                "time": "2021-09-29T04:15:09Z"
            }
        ],
        "name": "strimzi-kafka-operator",
        "namespace": "operators",
        "resourceVersion": "72079212",
        "selfLink": "/apis/operators.coreos.com/v1alpha1/namespaces/operators/subscriptions/strimzi-kafka-operator",
        "uid": "9b2364b0-5537-4676-ac8e-afbfbf29b438"
    },
    "spec": {
        "channel": "stable",
        "installPlanApproval": "Automatic",
        "name": "strimzi-kafka-operator",
        "source": "platform",
        "sourceNamespace": "cpaas-system",
        "startingCSV": "strimzi-kafka-operator.v3.6.1"
    }
}



{
    "apiVersion": "operators.coreos.com/v1alpha1",
    "kind": "InstallPlan",
    "metadata": {
        "creationTimestamp": "2021-09-29T04:24:50Z",
        "generateName": "install-",
        "generation": 2,
        "labels": {
            "operators.coreos.com/strimzi-kafka-operator.operators": ""
        },
        "managedFields": [
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                    "f:metadata": {
                        "f:generateName": {},
                        "f:ownerReferences": {
                            ".": {},
                            "k:{\"uid\":\"3bdbc1ef-a7b2-457a-9b24-c7c056545388\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            },
                            "k:{\"uid\":\"4163a69b-975b-4403-a8b5-043d2fcc6214\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            },
                            "k:{\"uid\":\"5f1c2227-de20-4bcc-bc5d-c8f71e46cc87\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            },
                            "k:{\"uid\":\"a5b1d1e9-6837-4a25-b649-bcaded73bf60\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            },
                            "k:{\"uid\":\"ae2c5942-bfef-4348-844d-70a0aae33d17\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            },
                            "k:{\"uid\":\"bf5b5faf-c539-4574-9085-6d5bc3c2d4b6\"}": {
                                ".": {},
                                "f:apiVersion": {},
                                "f:blockOwnerDeletion": {},
                                "f:controller": {},
                                "f:kind": {},
                                "f:name": {},
                                "f:uid": {}
                            }
                        }
                    },
                    "f:spec": {
                        ".": {},
                        "f:approval": {},
                        "f:clusterServiceVersionNames": {},
                        "f:generation": {}
                    },
                    "f:status": {
                        ".": {},
                        "f:catalogSources": {},
                        "f:phase": {},
                        "f:plan": {}
                    }
                },
                "manager": "catalog",
                "operation": "Update",
                "time": "2021-09-29T04:24:50Z"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                    "f:metadata": {
                        "f:labels": {
                            ".": {},
                            "f:operators.coreos.com/strimzi-kafka-operator.operators": {}
                        }
                    }
                },
                "manager": "olm",
                "operation": "Update",
                "time": "2021-09-29T04:24:51Z"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                    "f:spec": {
                        "f:approved": {}
                    }
                },
                "manager": "Mozilla",
                "operation": "Update",
                "time": "2021-09-29T04:25:10Z"
            }
        ],
        "name": "install-jw86h",
        "namespace": "operators",
        "ownerReferences": [
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "mysql-mgr-operator",
                "uid": "bf5b5faf-c539-4574-9085-6d5bc3c2d4b6"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "percona-xtradb-cluster-operator",
                "uid": "5f1c2227-de20-4bcc-bc5d-c8f71e46cc87"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "pmm-operator-alpha-platform-cpaas-system",
                "uid": "3bdbc1ef-a7b2-457a-9b24-c7c056545388"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "rds-operator",
                "uid": "a5b1d1e9-6837-4a25-b649-bcaded73bf60"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "redis-operator",
                "uid": "4163a69b-975b-4403-a8b5-043d2fcc6214"
            },
            {
                "apiVersion": "operators.coreos.com/v1alpha1",
                "blockOwnerDeletion": false,
                "controller": false,
                "kind": "Subscription",
                "name": "strimzi-kafka-operator",
                "uid": "ae2c5942-bfef-4348-844d-70a0aae33d17"
            }
        ],
        "resourceVersion": "72084609",
        "selfLink": "/apis/operators.coreos.com/v1alpha1/namespaces/operators/installplans/install-jw86h",
        "uid": "2cbe3ae7-6fb3-46fa-87ba-bfde5c75ff71"
    },
    "spec": {
        "approval": "Manual",
        "approved": true,
        "clusterServiceVersionNames": [
            "strimzi-kafka-operator.v3.6.1"
        ],
        "generation": 103
    }
}
```

