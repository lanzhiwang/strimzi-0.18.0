## ServiceAccount

| namespaces         | serviceaccount                         | secrets |
| ------------------ | -------------------------------------- | ------- |
| default            | default                                |         |
| kube-node-lease    | default                                |         |
| kube-public        | default                                |         |
| kube-system        | attachdetach-controller                |         |
|                    | bootstrap-signer                       |         |
|                    | certificate-controller                 |         |
|                    | clusterrole-aggregation-controller     |         |
|                    | coredns                                |         |
|                    | cronjob-controller                     |         |
|                    | daemon-set-controller                  |         |
|                    | default                                |         |
|                    | deployment-controller                  |         |
|                    | disruption-controller                  |         |
|                    | endpoint-controller                    |         |
|                    | endpointslice-controller               |         |
|                    | endpointslicemirroring-controller      |         |
|                    | expand-controller                      |         |
|                    | generic-garbage-collector              |         |
|                    | horizontal-pod-autoscaler              |         |
|                    | job-controller                         |         |
|                    | kindnet                                |         |
|                    | kube-proxy                             |         |
|                    | namespace-controller                   |         |
|                    | node-controller                        |         |
|                    | persistent-volume-binder               |         |
|                    | pod-garbage-collector                  |         |
|                    | pv-protection-controller               |         |
|                    | pvc-protection-controller              |         |
|                    | replicaset-controller                  |         |
|                    | replication-controller                 |         |
|                    | resourcequota-controller               |         |
|                    | service-account-controller             |         |
|                    | service-controller                     |         |
|                    | statefulset-controller                 |         |
|                    | token-cleaner                          |         |
|                    | ttl-controller                         |         |
| local-path-storage | default                                |         |
|                    | local-path-provisioner-service-account |         |



## ClusterRole









| clusterrole                                                  |                             |      |
| ------------------------------------------------------------ | --------------------------- | ---- |
| admin                                                        | apiGroups、resources、verbs |      |
| cluster-admin                                                |                             |      |
| edit                                                         |                             |      |
| kindnet                                                      |                             |      |
| kubeadm:get-nodes                                            |                             |      |
| local-path-provisioner-role                                  |                             |      |
| system:aggregate-to-admin                                    |                             |      |
| system:aggregate-to-edit                                     |                             |      |
| system:aggregate-to-view                                     |                             |      |
| system:auth-delegator                                        |                             |      |
| system:basic-user                                            |                             |      |
| system:certificates.k8s.io:certificatesigningrequests:nodeclient |                             |      |
| system:certificates.k8s.io:certificatesigningrequests:selfnodeclient |                             |      |
| system:certificates.k8s.io:kube-apiserver-client-approver    |                             |      |
| system:certificates.k8s.io:kube-apiserver-client-kubelet-approver |                             |      |
| system:certificates.k8s.io:kubelet-serving-approver          |                             |      |
| system:certificates.k8s.io:legacy-unknown-approver           |                             |      |
| system:controller:attachdetach-controller                    |                             |      |
| system:controller:certificate-controller                     |                             |      |
| system:controller:clusterrole-aggregation-controller         |                             |      |
| system:controller:cronjob-controller                         |                             |      |
| system:controller:daemon-set-controller                      |                             |      |
| system:controller:deployment-controller                      |                             |      |
| system:controller:disruption-controller                      |                             |      |
| system:controller:endpoint-controller                        |                             |      |
| system:controller:endpointslice-controller                   |                             |      |
| system:controller:endpointslicemirroring-controller          |                             |      |
| system:controller:expand-controller                          |                             |      |
| system:controller:generic-garbage-collector                  |                             |      |
| system:controller:horizontal-pod-autoscaler                  |                             |      |
| system:controller:job-controller                             |                             |      |
| system:controller:namespace-controller                       |                             |      |
| system:controller:node-controller                            |                             |      |
| system:controller:persistent-volume-binder                   |                             |      |
| system:controller:pod-garbage-collector                      |                             |      |
| system:controller:pv-protection-controller                   |                             |      |
| system:controller:pvc-protection-controller                  |                             |      |
| system:controller:replicaset-controller                      |                             |      |
| system:controller:replication-controller                     |                             |      |
| system:controller:resourcequota-controller                   |                             |      |
| system:controller:route-controller                           |                             |      |
| system:controller:service-account-controller                 |                             |      |
| system:controller:service-controller                         |                             |      |
| system:controller:statefulset-controller                     |                             |      |
| system:controller:ttl-controller                             |                             |      |
| system:coredns                                               |                             |      |
| system:discovery                                             |                             |      |
| system:heapster                                              |                             |      |
| system:kube-aggregator                                       |                             |      |
| system:kube-controller-manager                               |                             |      |
| system:kube-dns                                              |                             |      |
| system:kube-scheduler                                        |                             |      |
| system:kubelet-api-admin                                     |                             |      |
| system:node                                                  |                             |      |
| system:node-bootstrapper                                     |                             |      |
| system:node-problem-detector                                 |                             |      |
| system:node-proxier                                          |                             |      |
| system:persistent-volume-provisioner                         |                             |      |
| system:public-info-viewer                                    |                             |      |
| system:volume-scheduler                                      |                             |      |
| view                                                         |                             |      |
|                                                              |                             |      |
|                                                              |                             |      |
|                                                              |                             |      |
|                                                              |                             |      |



## ClusterRoleBinding







| clusterrolebinding                            | clusterrole                                                  | subjects |
| --------------------------------------------- | ------------------------------------------------------------ | -------- |
| cluster-admin                                 | ClusterRole/cluster-admin                                    |          |
| kindnet                                       | ClusterRole/kindnet                                          |          |
| kubeadm:get-nodes                             | ClusterRole/kubeadm:get-nodes                                |          |
| kubeadm:kubelet-bootstrap                     | ClusterRole/system:node-bootstrapper                         |          |
| kubeadm:node-autoapprove-bootstrap            | ClusterRole/system:certificates.k8s.io:certificatesigningrequests:nodeclient |          |
| kubeadm:node-autoapprove-certificate-rotation | ClusterRole/system:certificates.k8s.io:certificatesigningrequests:selfnodeclient |          |
| kubeadm:node-proxier                          | ClusterRole/system:node-proxier                              |          |
| local-path-provisioner-bind                   | ClusterRole/local-path-provisioner-role                      |          |
| system:basic-user                             | ClusterRole/system:basic-user                                |          |
| system:controller:attachdetach-controller     | ClusterRole/system:controller:attachdetach-controller        |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |
|                                               |                                                              |          |













```yaml

huzhi@huzhideMacBook-Pro ~ % kubectl get clusterrolebinding -o wide
NAME                                                   ROLE                                                                               AGE   USERS                            GROUPS                                            SERVICEACCOUNTS
cluster-admin                                          ClusterRole/cluster-admin                                                          71m                                    system:masters
kindnet                                                ClusterRole/kindnet                                                                71m                                                                                      kube-system/kindnet
kubeadm:get-nodes                                      ClusterRole/kubeadm:get-nodes                                                      71m                                    system:bootstrappers:kubeadm:default-node-token
kubeadm:kubelet-bootstrap                              ClusterRole/system:node-bootstrapper                                               71m                                    system:bootstrappers:kubeadm:default-node-token
kubeadm:node-autoapprove-bootstrap                     ClusterRole/system:certificates.k8s.io:certificatesigningrequests:nodeclient       71m                                    system:bootstrappers:kubeadm:default-node-token
kubeadm:node-autoapprove-certificate-rotation          ClusterRole/system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   71m                                    system:nodes
kubeadm:node-proxier                                   ClusterRole/system:node-proxier                                                    71m                                                                                      kube-system/kube-proxy
local-path-provisioner-bind                            ClusterRole/local-path-provisioner-role                                            71m                                                                                      local-path-storage/local-path-provisioner-service-account
system:basic-user                                      ClusterRole/system:basic-user                                                      71m                                    system:authenticated
system:controller:attachdetach-controller              ClusterRole/system:controller:attachdetach-controller                              71m                                                                                      kube-system/attachdetach-controller
system:controller:certificate-controller               ClusterRole/system:controller:certificate-controller                               71m                                                                                      kube-system/certificate-controller
system:controller:clusterrole-aggregation-controller   ClusterRole/system:controller:clusterrole-aggregation-controller                   71m                                                                                      kube-system/clusterrole-aggregation-controller
system:controller:cronjob-controller                   ClusterRole/system:controller:cronjob-controller                                   71m                                                                                      kube-system/cronjob-controller
system:controller:daemon-set-controller                ClusterRole/system:controller:daemon-set-controller                                71m                                                                                      kube-system/daemon-set-controller
system:controller:deployment-controller                ClusterRole/system:controller:deployment-controller                                71m                                                                                      kube-system/deployment-controller
system:controller:disruption-controller                ClusterRole/system:controller:disruption-controller                                71m                                                                                      kube-system/disruption-controller
system:controller:endpoint-controller                  ClusterRole/system:controller:endpoint-controller                                  71m                                                                                      kube-system/endpoint-controller
system:controller:endpointslice-controller             ClusterRole/system:controller:endpointslice-controller                             71m                                                                                      kube-system/endpointslice-controller
system:controller:endpointslicemirroring-controller    ClusterRole/system:controller:endpointslicemirroring-controller                    71m                                                                                      kube-system/endpointslicemirroring-controller
system:controller:expand-controller                    ClusterRole/system:controller:expand-controller                                    71m                                                                                      kube-system/expand-controller
system:controller:generic-garbage-collector            ClusterRole/system:controller:generic-garbage-collector                            71m                                                                                      kube-system/generic-garbage-collector
system:controller:horizontal-pod-autoscaler            ClusterRole/system:controller:horizontal-pod-autoscaler                            71m                                                                                      kube-system/horizontal-pod-autoscaler
system:controller:job-controller                       ClusterRole/system:controller:job-controller                                       71m                                                                                      kube-system/job-controller
system:controller:namespace-controller                 ClusterRole/system:controller:namespace-controller                                 71m                                                                                      kube-system/namespace-controller
system:controller:node-controller                      ClusterRole/system:controller:node-controller                                      71m                                                                                      kube-system/node-controller
system:controller:persistent-volume-binder             ClusterRole/system:controller:persistent-volume-binder                             71m                                                                                      kube-system/persistent-volume-binder
system:controller:pod-garbage-collector                ClusterRole/system:controller:pod-garbage-collector                                71m                                                                                      kube-system/pod-garbage-collector
system:controller:pv-protection-controller             ClusterRole/system:controller:pv-protection-controller                             71m                                                                                      kube-system/pv-protection-controller
system:controller:pvc-protection-controller            ClusterRole/system:controller:pvc-protection-controller                            71m                                                                                      kube-system/pvc-protection-controller
system:controller:replicaset-controller                ClusterRole/system:controller:replicaset-controller                                71m                                                                                      kube-system/replicaset-controller
system:controller:replication-controller               ClusterRole/system:controller:replication-controller                               71m                                                                                      kube-system/replication-controller
system:controller:resourcequota-controller             ClusterRole/system:controller:resourcequota-controller                             71m                                                                                      kube-system/resourcequota-controller
system:controller:route-controller                     ClusterRole/system:controller:route-controller                                     71m                                                                                      kube-system/route-controller
system:controller:service-account-controller           ClusterRole/system:controller:service-account-controller                           71m                                                                                      kube-system/service-account-controller
system:controller:service-controller                   ClusterRole/system:controller:service-controller                                   71m                                                                                      kube-system/service-controller
system:controller:statefulset-controller               ClusterRole/system:controller:statefulset-controller                               71m                                                                                      kube-system/statefulset-controller
system:controller:ttl-controller                       ClusterRole/system:controller:ttl-controller                                       71m                                                                                      kube-system/ttl-controller
system:coredns                                         ClusterRole/system:coredns                                                         71m                                                                                      kube-system/coredns
system:discovery                                       ClusterRole/system:discovery                                                       71m                                    system:authenticated
system:kube-controller-manager                         ClusterRole/system:kube-controller-manager                                         71m   system:kube-controller-manager
system:kube-dns                                        ClusterRole/system:kube-dns                                                        71m                                                                                      kube-system/kube-dns
system:kube-scheduler                                  ClusterRole/system:kube-scheduler                                                  71m   system:kube-scheduler
system:node                                            ClusterRole/system:node                                                            71m
system:node-proxier                                    ClusterRole/system:node-proxier                                                    71m   system:kube-proxy
system:public-info-viewer                              ClusterRole/system:public-info-viewer                                              71m                                    system:authenticated, system:unauthenticated
system:volume-scheduler                                ClusterRole/system:volume-scheduler                                                71m   system:kube-scheduler
huzhi@huzhideMacBook-Pro ~ %

```



















