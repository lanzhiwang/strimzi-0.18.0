


```bash
$ kubectl debug --help
Debug cluster resources using interactive debugging containers.  使用交互式调试容器调试集群资源。

'debug' provides automation for common debugging tasks for cluster objects identified by resource and name. Pods will be used by default if no resource is specified.  “调试”为由资源和名称标识的集群对象的常见调试任务提供自动化。pod 将如果没有指定资源，则默认使用。

The action taken by 'debug' varies depending on what resource is specified. Supported actions include:  'debug' 采取的行动取决于指定的资源。 支持的操作包括：

*  Workload: Create a copy of an existing pod with certain attributes changed, for example changing the image tag to a new version.  工作负载：创建更改某些属性的现有 pod 的副本，例如将图像标签更改为新版本。

*  Workload: Add an ephemeral container to an already running pod, for example to add debugging utilities without restarting the pod.

*  Node: Create a new pod that runs in the node's host namespaces and can access the node's filesystem.

Examples:
# Create an interactive debugging session in pod mypod and immediately attach to it.  在 pod mypod 中创建一个交互式调试会话并立即附加到它。
# (requires the EphemeralContainers feature to be enabled in the cluster)
kubectl debug mypod -it --image=busybox

# Create a debug container named debugger using a custom automated debugging image.
# (requires the EphemeralContainers feature to be enabled in the cluster)
kubectl debug --image=myproj/debug-tools -c debugger mypod

# Create a copy of mypod adding a debug container and attach to it
kubectl debug mypod -it --image=busybox --copy-to=my-debugger

# Create a copy of mypod changing the command of mycontainer
kubectl debug mypod -it --copy-to=my-debugger --container=mycontainer -- sh

# Create a copy of mypod changing all container images to busybox
kubectl debug mypod --copy-to=my-debugger --set-image=*=busybox

# Create a copy of mypod adding a debug container and changing container images
kubectl debug mypod -it --copy-to=my-debugger --image=debian --set-image=app=app:debug,sidecar=sidecar:debug

# Create an interactive debugging session on a node and immediately attach to it.
# The container will run in the host namespaces and the host's filesystem will be mounted at /host
kubectl debug node/mynode -it --image=busybox

Options:

--arguments-only=false
If specified, everything after -- will be passed to the new container as Args instead of Command.

--attach=false
If true, wait for the container to start running, and then attach as if 'kubectl attach ...' were called.  Default false, unless '-i/--stdin' is set, in which case the default is true.

-c, --container=''
Container name to use for debug container.

--copy-to=''
Create a copy of the target Pod with this name.

--env=[]
Environment variables to set in the container.

--image=''
Container image to use for debug container.

--image-pull-policy=''
The image pull policy for the container. If left empty, this value will not be specified by the client and defaulted by the server.

-q, --quiet=false
If true, suppress informational messages.

--replace=false
When used with '--copy-to', delete the original Pod.

--same-node=false
When used with '--copy-to', schedule the copy of target Pod on the same node.

--set-image=[]
When used with '--copy-to', a list of name=image pairs for changing container images, similar to how 'kubectl set image' works.

--share-processes=true
When used with '--copy-to', enable process namespace sharing in the copy.

-i, --stdin=false
Keep stdin open on the container(s) in the pod, even if nothing is attached.

--target=''
When using an ephemeral container, target processes in this container name.

-t, --tty=false
Allocate a TTY for the debugging container.

Usage:

kubectl debug (POD | TYPE[[.VERSION].GROUP]/NAME) [ -- COMMAND [args...] ] [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).

$

nicolaka/netshoot

kubectl debug -n hz-kafka -it pods/my-cluster-zookeeper-0 --image=busybox -- bash


kubectl debug -n hz-kafka -it pods/my-cluster-zookeeper-0 --image=busybox --share-processes --copy-to=debug-pod -- bash





```

