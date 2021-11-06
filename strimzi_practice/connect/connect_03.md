# strimzi KafkaConnect 与 ßKafkaConnectS2I 区别



# Kafka Connect Build

This proposal improves our Kafka Connect deployment with support for _build_ for adding additional connector plugins to the Connect deployment.  该提议通过支持将附加的连接器插件添加到Connect部署的构建，改进了我们的Kafka Connect部署。

## Current situation

Currently, Strimzi has two Kafka Connect deployments: `KafkaConnect` and `KafkaConnectS2I`. 

`KafkaConnect` currently requires that the user to manually prepare their own container image with any additional connector plugins they want to use. They have to write their own `Dockerfile` which uses the Strimzi image as a base image and adds the additional connectors. Then they have to build it and push into some container registry and configure the Kafka Connect deployment to use it.  KafkaConnect当前要求用户使用他们要使用的任何其他连接器插件来手动准备自己的容器映像。他们必须编写自己的Dockerfile，该文件使用Strimzi映像作为基础映像并添加其他连接器。然后，他们必须构建它并推送到某些容器注册表中，并配置Kafka Connect部署以使用它。

The `KafkaConnectS2I` is supported only on OKD/OpenShift and uses the S2I build to build the new container image with additional connector plugins. It is not support on Kubernetes since pure Kubernetes do not have any support for S2I builds. It makes it a bit easier to prepare the new image, but only slightly. User has to prepare a local directory with the desired connector plugins and pass it to the S2I build. The S2I build adds it to the image and uses it automatically in the Connect deployment. In order to add more connector plugins later, user needs to have the old connectors as well as the new connectors - it is not possible to just add the new connectors.  KafkaConnect当前要求用户使用他们要使用的任何其他连接器插件来手动准备自己的容器映像。他们必须编写自己的Dockerfile，该文件使用Strimzi映像作为基础映像并添加其他连接器。然后，他们必须构建它并推送到某些容器注册表中，并配置Kafka Connect部署以使用它。

Unlike other Strimzi components, none of these works in a declarative way.  与其他Strimzi组件不同，这些组件都不是声明式的。

## Motivation  动机

One of the aims of Strimzi is to make using Kafka on Kubernetes as native as possible. A big part of that is being able to configure things in a declarative way. That is currently missing for adding connector plugins to the Connect deployments.  Strimzi的目标之一是尽可能在Kubernetes上使用Kafka。 其中很大一部分是能够以声明的方式配置事物。 当前没有将连接器插件添加到Connect部署中。

Being able to configure the connector plugins in the `KafkaConnect` CR will make it easier to use for our users since they will not need to build the container images manually. It will also make it easier to have a connector catalog on the website since we will be able to just share the KafkaConnect CR including the build section to add the connector.  能够在KafkaConnect CR中配置连接器插件将使我们的用户更容易使用，因为他们不需要手动构建容器映像。 这也将使在网站上建立连接器目录更加容易，因为我们将能够仅共享KafkaConnect CR（包括构建部分）来添加连接器。

## Proposal

A new section named `build` would be added to the `KafkaConnect` custom resource. This section will allow users to configure:

* connector plugins

* build output

The connector plugins section will be a list where one or more connectors can be defined. 
Each connector consists of a name and list of artifacts which should be downloaded. The artifacts can be of different types. For example:

* `jar` for a directly download of Java JARs. 

* `tgz` or `zip` to _download and unpack_ the artifacts. The archives will be unpacked and checked for any possibly malicious content (e.g. symlinks).

* `maven` to download JARs from Maven based on Maven coordinates. User will provide `groupId`, `artifactId` and `version` and we will try to download the JAR as well as all its runtime dependencies. This might be also enhanced to support different Maven repositories etc.

* and possibly others if required

The second part - `output` - will configure how the newly built image will be handled. It will support two types:

* `docker` to push the image to any Docker compatible container repository.

* `imagestream` to push the image to OpenShift ImageStream (supported only on OpenShift)

Strimzi will not run its own container repository. So users of the `docker` type build will need to provide Kubernetes secret with credentials to their own Docker compatible container registry. This does not have to run within the same Kubernetes cluster - it can be also SaaS registry such as Docker Hub or Quay.io.

Following is an example of the KafkaConnect CR:

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaConnect
metadata:
  name: my-connect-cluster
  annotations:
    strimzi.io/use-connector-resources: "true"
spec:
  version: 2.6.0
  replicas: 1
  bootstrapServers: my-cluster-kafka-bootstrap:9093
  build:
    output:
      type: docker
      image: docker.io/user/image:tag
      pushSecret: dockerhub-credentaials
    # ImageStream output example
    # output:
    #   type: imagestream
    #   imageStream: image-stream-name
    plugins:
      - name: my-connector
        artifacts:
          - type: jar
            url: https://some.url/artifact.jar
            sha512sum: abc123
          - type: jar
            url: https://some.url/artifact2.jar
            sha512sum: def456
      - name: my-connector2
        # ...
  tls:
    trustedCertificates:
      - secretName: my-cluster-cluster-ca-cert
        certificate: ca.crt
  config:
    group.id: connect-cluster
    offset.storage.topic: connect-cluster-offsets
    config.storage.topic: connect-cluster-configs
    status.storage.topic: connect-cluster-status
```

When the `build` section is specified in the `KafkaConnect` resource, Strimzi will generate  `Dockerfile` which will correspond to the configured connectors and their artifacts. It will build the container image from this `Dockerfile` in a separate pod and push it to the configured output (Docker registry / ImageStream). It will take the digest of this image and configure the Kafka Connect cluster to use this image.

The build will use two different technologies:

* [Kaniko](https://github.com/GoogleContainerTools/kaniko) will be used on Kubernetes

* OpenShift Builds will be used on OKD / OpenShift 

Kaniko is a daemon-less container builder which does not require any special privileges and runs in user-space. Kaniko is just a container to which we pass the generated `Dockerfile` and let it build the container and push it to the registry. It does not require any special installation - neither from the user nor from Strimzi it self. We just use the container.

OpenShift Builds are part of the OKD / OpenShift Kubernetes platform and also do not require any special privileges. So it should work for most users across wide variety of environments.

## Affected/not affected projects  受影响/不受影响的项目

The existing `KafkaConnectS2I` resource is not directly affected by this improvement and remains unchanged. However, the declarative approach is superior. So after it is implemented, the `KafkaConnectS2I` will be deprecated and removed. 现有的KafkaConnectS2I资源不受此改进的直接影响，并且保持不变。 但是，声明式方法更好。 因此，在实施之后，将不推荐使用KafkaConnectS2I并将其删除。

`KafkaMirrorMaker2` is also based on Kafka Connect. But the build will not be available for `KafkaMirrorMaker2`.  KafkaMirrorMaker2也基于Kafka Connect。 但是该构建将无法用于KafkaMirrorMaker2。

## Compatibility  兼容性

This proposal is fully backwards-compatible. When users don't specify the `build` section inside the `KafkaConnect` CR, the build will be never activated and used. So existing users who do not the new build will not be affected in any way. They will be also still able to use the old manually built container images without any change.  该提议是完全向后兼容的。 如果用户未在KafkaConnect CR中指定构建部分，则将永远不会激活和使用该构建。 因此，不是新版本的现有用户将不会受到任何影响。 他们仍然可以使用旧的手动构建的容器映像，而无需进行任何更改。

## Rejected alternatives  拒绝的替代品

There are several ways how to build container images. In addition to Kaniko and OpenShift Builds, I also looked at Buildah. But Kaniko and OpenShift Builds worked better (read as: _I didn't got Buildah to work_).

The current interface between Strimzi and the builder is based on a `Dockerfile`. If needed, any other alternative technology which supports building containers from `Dockerfile` should be relatively easy to plugin as a replacement for the current ones.
