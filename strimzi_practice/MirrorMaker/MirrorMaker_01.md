



源 kafka 集群

```yaml
# 创建 Kafka 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    jmxOptions: {}
    listeners:
      tls:
        authentication:
          type: tls
    authorization:
      type: simple
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}

---

# 创建 KafkaUser 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: tls
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'

---

# 创建 KafkaTopic 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824



```



目标 kafka 集群

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.5.0
    replicas: 3
    jmxOptions: {}
    listeners:
      external:
        type: nodeport
        tls: true
        authentication:
          type: tls
    authorization:
      type: simple
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.5'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}

---

# 创建 KafkaUser 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaUser
metadata:
  name: my-user
  labels:
    strimzi.io/cluster: my-cluster
spec:
  authentication:
    type: tls
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'
      - resource:
          type: group
          name: my-group
          patternType: literal
        operation: Read
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Write
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Create
        host: '*'
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operation: Describe
        host: '*'

---

# 创建 KafkaTopic 集群的 yaml 文件
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824


```











```yaml
apiVersion: v1
data:
  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURMVENDQWhXZ0F3SUJBZ0lKQUtCY1BqUkoyb2E2TUEwR0NTcUdTSWIzRFFFQkN3VUFNQzB4RXpBUkJnTlYKQkFvTUNtbHZMbk4wY21sdGVta3hGakFVQmdOVkJBTU1EV05zZFhOMFpYSXRZMkVnZGpBd0hoY05NakF4TURJNApNVE14TmpRMFdoY05NakV4TURJNE1UTXhOalEwV2pBdE1STXdFUVlEVlFRS0RBcHBieTV6ZEhKcGJYcHBNUll3CkZBWURWUVFEREExamJIVnpkR1Z5TFdOaElIWXdNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUIKQ2dLQ0FRRUEwMHBxTXFPMEFqOG92UHo3Sys3SGQxSWFwRk5lY2JLUjJMRWM4cFNGVFBTdDl3YnJWZlVsUWhtRApzNkFRZHpuNm5wWFB0UDUyRmpqQVR4R283N29HNi9DbzkrcWpIRWFKRyt5RS9nZzY1WnNjV3d6WmwyQXliNk9tCjgwS0o2TVRIMW9kR3I3bUVVY1Z0RUlzT05GT2lzNWw2b1ltTXVRWXFGem03ZTVWQnJIN0NZbkQ0WURGRitYYTIKWVlFdGpobStkWHBSaXNmd1Z6Yng5WkRHUEhGeHRTUTVDcHBGenAvaytLSVJocVJrT29iYjh3WHRXa3QyZjVkUwpGZ1dXVWoxejRjTGtJYnByRVMxM2xHRlR5a3JPQlVtd3U0dVFnSjdHRXVNcThhNXh5UHVYcDMyU1hVTHdpNGovClVsTnY0OWMxcEFDNURlM0QzVDhZV3p4MWpaczEzUUlEQVFBQm8xQXdUakFkQmdOVkhRNEVGZ1FVOEVPTk0vaU0KT3dMZkV5YzhBVFBCM1NoaC9Db3dId1lEVlIwakJCZ3dGb0FVOEVPTk0vaU1Pd0xmRXljOEFUUEIzU2hoL0NvdwpEQVlEVlIwVEJBVXdBd0VCL3pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQXUvbnJ0SEdrYnd2dWFXSVZrdHRyCjJ6eDdIZ1VqTDduaklsUFB5YVZ3U2VMN3FJL1Nqd0cvbWxqYWFtTlhCa2E4UXIvWjdHeUJNY0szYk5YVnJmUk4KNlBSTU5LOUR6UEY3NnZ2ZjJlQktINjdDUWVyUUNJYVBoY2dkUEgvL0NzQmhxRWVzVFgwb1UrMk1UL1N5aEFHRQovMExkamxKUjlBdUFRK2VoTmpXK1F3UVRuSTZTcFNGbm4zTEkrRzZGZXhjVkp1cUZxNVJtdG05R1BSS3MrNzBLClFBZ1NYVVhmQlBJdTg2RUhYY0ppNzJkVnlzVmlpbEJKVVNucVhMQ1QyMEcrMEFsNVdHVmxhQ3VXWkowQ1IyU0wKZGtSbEhCdUlKR25heFBRTVFCQVA5dWZRQ3NRdm1xcWN6bEdhY2U5aGN1TjYzL3NidnowNi92SnkyeTlYWXFjWgpaQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  ca.p12: MIIEVgIBAzCCBA8GCSqGSIb3DQEHAaCCBAAEggP8MIID+DCCA/QGCSqGSIb3DQEHBqCCA+UwggPhAgEAMIID2gYJKoZIhvcNAQcBMCkGCiqGSIb3DQEMAQYwGwQUEMlSBtnYKO77ItvPLu9dcl0Fc60CAwDDUICCA6Cw9EvOQeiIvcybLGx/PNp5mY20WeXUR/vRxmniNBUvnO1ulzNOkhLzAiL0cfLar2lzK9WhhLCOVNOddiTkquDCnI+54454ERkLSvwq9MPNxA2GFODVW/rHdXT4HJFYKSnKWSjx6VwDjdJobGZ/V+Q9ym3lvCNc26lKFYDALdVePJ99FUeusoOOjJyImDyitpSDcdyd7uPB4LAbulQaxflNk1R+zMTa9J4ElEin1DDd+CSVAXxILGlxWv7/qIJmUpu+074qvkM+00X+l4fGdz3KJxUnHx/BoSi53h3UWH4kp0O0QkPtpZ1Of4/hyELJGHw3M232WixVvXd6mYaBlePqctkDjTeBV45Mj3MLsjcLdd4poIEY2WdrRoS1sSKE2B7mD0YPcGuHWM8L7UuRyj2dDyLY1xnBHmMNMHBwMaxNoWAT38VTelG+jW3t8x9Dmapq51D/nJmuqDFSVtL2AGfxgeBgMR96BeNvSnOwDo8CfbDDj3OTZd8nNL2lhl+8+HICpWGHvDQ/id14fZHJvuYwI99p44bOrOD9RYzkFZ3HDjyriSO4Xg/AsM96HI7a8qtuRU6vXRV+f/Sqc5DRbSh4Y8KbNOdWaSJJBh7EAuwuYjEu4h5BLoszY25NMUuBwIEcjMCz3JUsJU3zq8FT6fdHCfa6Lwzn57yViuaqLem4kqUfOYMBfJ+bHWKq5cpRY/p9KCGSQ5YLYRQJ5Ls/ddMzkVJXAunyZwdSqGODip36c5Gj0tlQTH0uAJxRUmCA7rgDIBnpCQO3snIoJVHXZB20WkVdroTgtKBmyqd030hMo0FnZY5BycPt8rtBFEyhge9YAqN+C978DFLO1zZ0Etbv0fzbDSXcRZHWIMZku18ZWpE9idhbZG9TyaWoTinJt9OzLKzJk6HYKQK1wUhVaaLSG8nXTKuzx3gYIf89tyYJwdHf3wYvWnDUvcpsEjfMIZ8QIszKzHJD0WuC+bZ/aj4cDegFuyHfvwcDqGdr6lv40Yq2xe3RDIUiHp4pc76WTn04fPHvMVGbcrzIMqZB1NFVItsmFqlN4wj5y6pJDGgdVOumK891fyPs6ynGY5vTs0lOUFe11ImXFUQADd1NLf5mDSmodr3PREOLwq35Kq/fprJKZ4X0nT+/wp/CSyHNX6/jLqhGaFMijv/tdDhPi+a87gKvvAjSqZDSIIxzTm5V8mx4RSMoA0222IYsyZWkzvmyfeKGR3o6ramKRJNN522XMD4wITAJBgUrDgMCGgUABBR4jasFgd9o/AfJbMQFXEeRdz0DGQQUGPZ2PBM5+CC8LpYXu+CCRsSZHj4CAwGGoA==
  ca.password: Z2wxejhNRVNJdWZi
kind: Secret
metadata:
  name: destination-my-cluster-cluster-ca-cert
  namespace: kafka

---

apiVersion: v1
data:
  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURMVENDQWhXZ0F3SUJBZ0lKQUlhS2hscytuUmZJTUEwR0NTcUdTSWIzRFFFQkN3VUFNQzB4RXpBUkJnTlYKQkFvTUNtbHZMbk4wY21sdGVta3hGakFVQmdOVkJBTU1EV05zYVdWdWRITXRZMkVnZGpBd0hoY05NakF4TURJNApNVE14TmpRMFdoY05NakV4TURJNE1UTXhOalEwV2pBdE1STXdFUVlEVlFRS0RBcHBieTV6ZEhKcGJYcHBNUll3CkZBWURWUVFEREExamJHbGxiblJ6TFdOaElIWXdNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUIKQ2dLQ0FRRUF5TXIrVEdjYkIrUWJyQkovMmxyVGFqQVB6K09iajhiQmROeXh2LzEzU2g3ODBCeEJDckJockNKTQppRWVLT0JnVVErK2tTdHFxTzRCeFNTYUo3N0Q3TlV5RkxTaE5URmtIanA3R0RUeWlMRGs4OFZlczJ0U1JMdnFJCnpzYnVycWFnOFgwanVJUCt6K0gyTDlqb3A0VzVQZk5CVDRPb2ZPaHhZRVVFbXZtV0hGODMvQ3JMUThzOTNHWUgKVnpxRWNxNG9ON1ZjUHJ0eG1wd2c4dloyVTdPZmhtOTZjbWJMV2RlZXJzWHovWUx5VU9Ec2xrR2xUc2tYWXNtRwpyZ0ZGaDBjcHNHVUhMOGdra0lzUUE5VVVUU1VBNWZaeHN3Ykc1MFNmYmlDS1JPdmNvdlBJeXNob3ZNcW53UFMxCmlKbUNRNFg1SER0eDFaRFBGU2RGTXhtZmVmRFRqd0lEQVFBQm8xQXdUakFkQmdOVkhRNEVGZ1FVODRrV3kzUGYKSzlKMlBuemxFTlQ4NGgzNnhGTXdId1lEVlIwakJCZ3dGb0FVODRrV3kzUGZLOUoyUG56bEVOVDg0aDM2eEZNdwpEQVlEVlIwVEJBVXdBd0VCL3pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQXlEYU5VVHhGZFdsOFZDbElheUVSCkdlY2MveE8rUFk2aVNuUHBsVEdNQlpDVU04QURuMS9vL0wyc3lQLzE1SzVBVkZ2ektDd29EcXZ0Znk4YU9idmMKQjhrRmloSW16MWI4QUlkR25tQ0Zoa0JhdUYwUlh0Y1Q0b1dZa3UzZnJuTC9GU2pvL0R5SXV4U0FiOXRyS3lzZgpXclMzNFJnWDhmR3FEZ1B4T2VGWUd0eEdqQzFFbkswa1ZIaUM3R0J3cjJDMWIvK01rU3hqN01sdmtBM1FkRmYwCjljL2pNY0ZqRGRqTUtGbk1IcWg4eUI0aUxObWR6WTByR2dtaUJQR2g3UXN4UHF4bUM0aTlWa1FJSjA4VEwxcDQKQXg4aE9UeEZvdDczKzZINVZla2Q5U3ZVL3U5Smd2S00yeWUvNFAxdU0rTnQ1c295OS9SNk11VW5BUEZIWGRtNgpFZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  user.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN1ekNDQWFNQ0NRQ2VkSVJucGhYbldEQU5CZ2txaGtpRzl3MEJBUXNGQURBdE1STXdFUVlEVlFRS0RBcHAKYnk1emRISnBiWHBwTVJZd0ZBWURWUVFEREExamJHbGxiblJ6TFdOaElIWXdNQjRYRFRJd01UQXlPREV6TVRjMQpPRm9YRFRJeE1UQXlPREV6TVRjMU9Gb3dFakVRTUE0R0ExVUVBd3dIYlhrdGRYTmxjakNDQVNJd0RRWUpLb1pJCmh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT2F6TGxWVHVOY3p2eHFYNnROWUZPZDVWSFVQSU90RXN2clYKU3FOUzdXNUtYb1FGclEvYnJsU2lTNVJzL0R4cTROSCsxMlRlWVB6N0pVSjdjalozdmxXeUVHVHowZHRQampBRwpsaGVKSWJ5M2J5dXhFcjU2SCtyWkdCVzRPdE9XYXRPWmlhN3FuaElaR1BNZFQzaG5HQXA1QURjakRpeitKczMxClhwRnF4MkxQVm1YM00wTHl4eGg3ZGhHNnM0cy8vcVJaN0dtSGtpMTNJb3ExL2o1Nys2T0F6TERIRytsbzkycTYKaUZva0tHbHljTnlUVm01OG10S1JsYXcySDZjelV2NlVvRGpBSjNzM2tsamRGOXI0ZmNUSXJyZDY2d3NoUGt3ZQpRTEJDOE9RSGsvdGlnRytKT3BjRnBtZmdJTEpFNGdzRTMrSWtVb1piRDJYTDNwUzRMQTBDQXdFQUFUQU5CZ2txCmhraUc5dzBCQVFzRkFBT0NBUUVBREdKOG9vS2dxZitZeWxpaEJQUmdNQ3JmeTAwS3NYR0NqRERwc3NtenFZSDQKYnlMUHlLbmtseG5PNUQ2WGNpd2FPaG5QaFpWbUdDNyt2b0dJWUZIblE4K2VwUk1JcU9wMkRQV3JTbW9qVTV4cwpDbjNQUXJTSTlFVml1emd3aHN6c1FIRjNrOWJHR2lJdFh2QmVaWFpoNER5SVZxRFo2enpLTTBHK2pnWms4RXdXCjZYcUVlTG85K0tETnZvM21NeUI0b0ZRcHBmWEdOWjllbWlFVmwzMDFJR2tnbXNPRTNiaXhwRlZCVW52UXc5QXcKSlQvbEVZbjBJditOSlIvMDQrNzkxbFZ0VEF6K0plQ1pTLzBiQ0lCRW0zZzR3QWwwbFIvSjFQdGFqOHR0TEZhagpGRjZ0czN4QUY1UXp3Zml0NmdsT2V2MUROSmRhaCtKVFVzV1lVcDNYUVE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  user.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRRG1zeTVWVTdqWE03OGEKbCtyVFdCVG5lVlIxRHlEclJMTDYxVXFqVXUxdVNsNkVCYTBQMjY1VW9rdVViUHc4YXVEUi90ZGszbUQ4K3lWQwplM0kyZDc1VnNoQms4OUhiVDQ0d0JwWVhpU0c4dDI4cnNSSytlaC9xMlJnVnVEclRsbXJUbVltdTZwNFNHUmp6CkhVOTRaeGdLZVFBM0l3NHMvaWJOOVY2UmFzZGl6MVpsOXpOQzhzY1llM1lSdXJPTFAvNmtXZXhwaDVJdGR5S0sKdGY0K2UvdWpnTXl3eHh2cGFQZHF1b2hhSkNocGNuRGNrMVp1ZkpyU2taV3NOaCtuTTFMK2xLQTR3Q2Q3TjVKWQozUmZhK0gzRXlLNjNldXNMSVQ1TUhrQ3dRdkRrQjVQN1lvQnZpVHFYQmFabjRDQ3lST0lMQk4vaUpGS0dXdzlsCnk5NlV1Q3dOQWdNQkFBRUNnZ0VBVTVwL29nQnpMZG5jMllCUVkwSzZZS0JCa1NKb1pacEIybEROZVo2bDJLQXUKM0YxS09FTCtURUY4YmsrSW9VU0NNTmZQcXdoRDBhb1orSnZQNmhrKzZzTmEyWnJhWkVYU1cya25uMlBjekEwVgp4cG1uRjB3ZW9QY0htV2RvT2lGNm1UQTlDeHlQS0RQY0xNNWtiRmZBQ0p1TkRtNHZ4dkpia2F2b0YzN0F2dmVBCklqOTY0Qk1OdWd2a1ZoQ080QnRzSDZBdTZHM1ZRejB0ajNkeldpQWxtcFl6Qy9oam9yYnVmOHY2Vi9lUDA1azYKL0dxWDYrTFV0aFNNa3I1dlF4cWdidFlBNCtBa2ZOVXgyK2V1dy9hdnY2VnlCbnBhaVAwYlhKMS95ekdlSTNhcQpLOXk3cUFUY0ZwWHJUSmxWYjI1bHNSdmc3K0l6LzlUenJQM2xmdG8yNlFLQmdRRDkvVGJKZUo5dE10RU1EcVV1CjBEVXFZRHhEbDBDdjREWXRNbGhvL09Vc3FGeDlZalBJOWlWT2RxeDNZb1NOMGNzTmRSMGFJOC9JaVlCdFlGWEUKV0V3S1Y1aUYwVjdweTlLMmZpMzk5U05xUWp0VUJuOVNVZVNRcy9ZQWNmZFV6N042S1cxWDhHeWJ2L1FUdEhnOQpZRXhtVWtxT0Q2Ujl2TWhENzJmb1RJZUNkd0tCZ1FEb2hzT3RqVFd3akVwdktqTzJBVHRKOEhmSmlpaGlCVTl2CnlYMlE3WG5BVzF0WjNsUmhGSkNzV2dURjk4d0Q3dTR0bVhXS3dkeE9tWmYrdUFXQU9HWHhBUER3YVF6Y0JIRjcKK1hPNU51VmJBNUEwRlB4Y213OVJCeHMvUkFrOWVNSVNWWGo5YW02bHFJdnYyTTFMd293Nm4wQkNJWFFnWS90OApOMXdjRmlMQ213S0JnUURpUVlobHIwTnVGbCtzK3ZyaEdlN1NnZ29OT0JjUzFZdk5kVlRXcWJwSnJ1MDljSmFyCkJjSzBBL21kSEREeTJSbW1NbGFyYTQxMG1qREN2cGVJb2hPUy92ZEs5ZmswRWpMeUNMTlYwT01zakRXbm8yWVcKWWdkWGRFakhtcjUyV2RRTEZnNW0wVEVmQ2I4WE1xUU9JTlBPTHE1bG9MK3FsdHBiMGsvZzJ4TzMvd0tCZ0ErTApPcmQyVWhsOE4xbVpDNTNtRlMyTEtxYkpXb3U2NlNXQzVhYnppUWtIMG1KK2owdHlFWDNFQXIrdElmRTlYcVNqCnRvelJDc1lpVkZ2TnQyaHIzTHl3b0dxaHl4OUdHTVA5MS9PUXJPSlpxYUVocWdFU3lJSlZKRWdsWnl5NXp0ZGsKNlZLZmM4Z1ZMVTJhUTVjRjZWUGQ0M0RJUmJnSWx2NGx3VDJMYVVWekFvR0FGK2FGU1lDb1NCTml6b3o5RXVtRwpmREdrSHptcTRVWi9rbCtvTGJ0T1hTaGVkUzducjYzR1RLRkJzaE52OUV1VCtYZUdhNE1xbnUrVk1XdXNNNGZkCmVSa0xTU2thdEFTRllUbElDWGMyUWx4bnNWQVlqcGhEZkRQcFY4NlpUb1RNMlY5ZE5oWUlKc1VwekpQdXlIZDgKdHBwQVJsck42WUE4T2xqUk0xQUw0c3M9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
  user.p12: MIIJOAIBAzCCCP4GCSqGSIb3DQEHAaCCCO8EggjrMIII5zCCA38GCSqGSIb3DQEHBqCCA3AwggNsAgEAMIIDZQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQIm1WhLXj4Z7sCAggAgIIDOPIClu8tfEtTPYM1ULwmpCZnjqM4Hblpcul/21QI7ENDqtLHXrRRSwtLOUmy1MKrUmXMoUpcmrXBJvyu7L5WJftC9LZB+XvKE/S9D2rzWKmg3Og1c9j619pRmqRjJzO69PEGNzq2LfspNOYf+GHmIfGuZoi1+uTZjgCyLR+xdDmKx8ooGaAUl1Wnml1BAcTuKgQjV9Qk2DoWqBc5b4rlMADwV8/8E56AA43W+wT+XwLFWaK/CWD1wvVilkmhPvnbmS+RmHJsSHjGNgJ5jm5Tq7hlmrhetBOSKeBnuIcExCeKgPtuq+eRjVCeDQkVGahpIfE7YSsM0bMk5GSoR3zNT5cr5DxOIXbePhwYVTK9qD6rpiu39OkrPt0LJa+fcX5X9Hqu5LNIaQaOsK3qH25MGEi9i3tJDktpqJc2kDraOKBhRH2UYTLR4LYKPtnxkfNYjq7O5bRqW/HCNMCQ+UrlWPweaefdXGbQOO9qBzKOp3zjkaf0j1MP6vDLMP0tQbah0Zze+lmHJu7HyxFLOBZ3rlmt16hY8efKCL9GnDRKzZC+XMFi8bF3oSXiHv09wUsYULHd7Up7adD2HLKtcSgQt9dZr3mmEb0O6Z5MIblw4iYYIXpJAtU+5MaW9ldxwrHMCh6K9qopiJkUWYkfD1i4weKlfa/FA4DnjRSuNqo16yFPTGHkhWu94/qvJnhjnUkn5bxJKz8cB6bWTkfJZRQzrTA/qIsm8Wuh7LMURna9kwsHbmd7TN5XX5yUznBVExPPZkFZMUY7xO82kqB++lBbmq2kmpNVHqsZxWxVdi7UkhxusTz+BOtX40wHRkaH1TRfgRs4Rj324pozWxTaiU3NyXrxj1QMl4kfWtxHUEeXmBNpCnu2kxRDbi8jR6tFanftbU9xYlBIHGzgqg7MIUhF4h4k55BPlzwovcwszxR96LuJUwN2lgoeUXB1rtAV9TjHKS0nu3oaGsvtSpsx4IezecnFm5MXEZugFnx+YHzdqRtovqVo/8jVS+5eeXcYJFXnoJKgcHEsF3lqCGDLmfhQzaVWHcWmb1hO0qiGIJVy8/8LpD2PID2fu/+GIU1wPpcsRqEryKGPoL2jMIIFYAYJKoZIhvcNAQcBoIIFUQSCBU0wggVJMIIFRQYLKoZIhvcNAQwKAQKgggTuMIIE6jAcBgoqhkiG9w0BDAEDMA4ECJOoG8StYTwXAgIIAASCBMiEEvb9FNDMDv8hBLDl98zuuvFpC+nPJIm1cfD/ka0sr6q9m3Tx3IiHy2+N/XJ7d0HH5URB4kz5KPysOiG//lYHS9lOmMdHfhNYH+ZWfyW8X00Vf3a3k6GQ9/R/RSLOg7PHAlLnDIGIcpejbZbr1gP0JnrEIqbKmsiDM17Lo/f2gfUaN3W73Ou3yr6cPGmZ5I9y/y+63HconyVootthpwhK1rsDogIyj+ybhEEJvkUADwjyYkwni2ADp/wwUzF/h7culNfJ84zAo7hI6g4Ue3Ogdml605ULEhp0UNBpK9mD09isWN2zScMgG4AHIV1NI80qDDJFnaDRK3QlnZpNqeSdC7j39yeJ4JHC2eLvxd22fIUo67/jPQcCYS57T9RtSoFIzBwiflVdruyA7ZYM5FUyNTvsLuV4EJ9tAjvnwX1my7dJ6TXZDOjUO8ep8vemngWt/rfAtHpHjcdOpNtuy7+BOE7XIrH/gqD0yFcob0HzAzsYF05vWQH++hxTB/+WGo7zwZm2NDRfzsd0fQhHBhERfKYRYWPQZdkhCrokbvDcs6oWSTwxYb2+e743LqfSLeZmKaFn6QpcLNhKHxz04gbbS4QbnUdqMe5et2CWfaxMdXNUKhFsfCNvBPEK/aXKku+er3vtueuO4068BqourrXXBavKl1RNWWhZTofUAG0g1RBnXbMKisVQZ4hI9E975kLqYielSP6yaAxghGKWv6ujbdCDxH+lHAVVVZxzLWE0X0HoqoXuto7wgqauKdgKqL1EgJJsqVsaiOJCyRtosYRwXLmlnLeGhDpQsWNXPTJuuYJvy/stzz2cd+gjJNW/tu1jYwaoafLgG4o6uqiDkIeHIbt6BiUkgBJxqArVF6z8pn28+p7Xgbv7cJsrAQAHvrcpDoSMmmqHOf6LqPzFzi3WoZN8Gwh5HwnlxAZv1H7gVEbuEcZ0rS9b/Qq30SKb/bbzLfAmx4Fk4jDZfHHEoXNkebR1szsLWoARDk7XauoOYUmXbc/WkfxrU5SBgrxijv/rl2S73+l1kGXw7n9ThdSF0gVjr+31Sn4HrEzv8c4VspxhKl6P+DXi0Z05JPHmZ55Zvglzn1l28rah0vWQZEPyZvzbj+wmjuEHDd/hB/Om1FiZHMXJ77kuJG4cbgRamzN5TXduBu3zYlQQLdF7tSJXgRHFnEMceV1ges5zEiCuuQRzU8oOXsEZGxVzn2Eg5F74lhuQ7XTjUS/2dzlDOzaUOScHxKMShWeiKQLYGms8+ZzwTUAhua7VWGME/FrjygPZCh8w66MPuLJwkqJbfsOnzeSZAWjd3SrTIPKbTEL3JpOzpJ01Tqwg0Lp10UIBB5xvl/r/l9ADdMd/QmmqK5fP/vq4Sq2AcrHXiftfkrDo9b8xN6t+JkwycabAleQeOALJ2RiMT7t4UCDD6AZpFlYhiMVwQ7JGB/cOpJPLU9Ytk1OwMIRZiomFRqt6yUkMDPnh/ic8Qz/wRat7oqsBNlhs56cI8atYiNWosOybgt1uwmfkFdBBhybPnsb/I6R93Oms5oq+/3JSIowwFO/NJyMTECBdXdF6u2S2lfx6igYJYIh781rekeNiDwaZ7XUpJndlkcgfCBtIY35BVLbCj12FxV+zxFIpCPMxRDAdBgkqhkiG9w0BCRQxEB4OAG0AeQAtAHUAcwBlAHIwIwYJKoZIhvcNAQkVMRYEFPx/lZ/4ngNrumDgXDDc5FksQLZEMDEwITAJBgUrDgMCGgUABBR5HL2ji0Bj9IQKwMrZJdA3accSmAQIRKcUq2n7FgkCAggA
  user.password: U2lBNHpwNzVsSzUx
kind: Secret
metadata:
  name: destination-my-user
  namespace: kafka




# 获取 CA 证书
$ kubectl -n kafka get secret destination-my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret destination-my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
gl1z8MESIufb

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令: CA 证书密码 gl1z8MESIufb
再次输入新口令: CA 证书密码 gl1z8MESIufb
是否信任此证书? [否]:  y
证书已添加到密钥库中


# 获取用户证书
$ kubectl -n kafka get secret destination-my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

# 获取用户证书密码
$ kubectl -n kafka get secret destination-my-user -o jsonpath='{.data.user\.password}' | base64 -d
SiA4zp75lK51

# 将用户证书导入 user-keystore.jks 文件中
$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令: 用户证书密码 SiA4zp75lK51
再次输入新口令: 用户证书密码 SiA4zp75lK51
输入源密钥库口令: 用户证书密码 SiA4zp75lK51
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消

# 创建生产者和消费者客户端连接配置文件，注意用户密码，CA 证书密码
$ cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/root/ssl/user-truststore.jks
ssl.truststore.password=gl1z8MESIufb
ssl.endpoint.identification.algorithm=

ssl.keystore.location=/root/ssl/user-keystore.jks
ssl.keystore.password=SiA4zp75lK51
ssl.key.password=SiA4zp75lK51
EOF

$ kafka-topics.sh --bootstrap-server 10.0.128.237:31818 --command-config ./client-ssl.properties --list
my-topic
[root@init-int ssl]#

########################################################

apiVersion: v1
kind: Service
metadata:
  name: destination-service
spec:
  ports:
  - port: 31818

---

apiVersion: v1
kind: Endpoints
metadata:
  name: destination-service
subsets:
  - addresses:
    - ip: 10.0.128.237
    ports:
    - port: 31818

$ cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=gl1z8MESIufb
ssl.endpoint.identification.algorithm=

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=SiA4zp75lK51
ssl.key.password=SiA4zp75lK51
EOF


[kafka@kafka-test ~]$ /opt/kafka/bin/kafka-topics.sh --bootstrap-server destination-service:31818 --command-config ./client-ssl.properties --list
my-topic


```

















```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaMirrorMaker
metadata:
  name: my-mirror-maker
spec:
  replicas: 3
  version: 2.5.0
  consumer:
    bootstrapServers: my-cluster-kafka-bootstrap:9093
    groupId: my-group
    numStreams: 2
    offsetCommitInterval: 120000
    tls:
      trustedCertificates:
      - secretName: my-cluster-cluster-ca-cert
        certificate: ca.crt
    authentication:
      type: tls
      certificateAndKey:
        secretName: my-user
        certificate: user.crt
        key: user.key
    config:
      max.poll.records: 100
      receive.buffer.bytes: 32768
  producer:
    bootstrapServers: destination-service:31818
    abortOnSendFailure: false
    tls:
      trustedCertificates:
      - secretName: destination-my-cluster-cluster-ca-cert
        certificate: ca.crt
    authentication:
      type: tls
      certificateAndKey:
        secretName: destination-my-user
        certificate: user.crt
        key: user.key
    config:
      compression.type: gzip
      batch.size: 8192
      ssl.endpoint.identification.algorithm: ''
  whitelist: my-topic
  resources:
    requests:
      cpu: "1"
      memory: 2Gi
    limits:
      cpu: "2"
      memory: 2Gi

```









```bash


# 获取 CA 证书
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# 获取 CA 证书密码
$ kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
jTFJF5r3ggpu

# 将 CA 证书导入 user-truststore.jks 文件中
$ keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt

# 获取用户证书
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12

# 获取用户证书密码
$ kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
Mavjzrov3xVi

# 将用户证书导入 user-keystore.jks 文件中
$ keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令: 用户证书密码 iq4b1jjmaFUy
再次输入新口令: 用户证书密码 iq4b1jjmaFUy
输入源密钥库口令: 用户证书密码 iq4b1jjmaFUy
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消


# 创建生产者和消费者客户端连接配置文件，注意用户证书密码，CA 证书密码
cat << EOF > client-ssl.properties
security.protocol=SSL
ssl.truststore.location=/home/kafka/user-truststore.jks
ssl.truststore.password=jTFJF5r3ggpu

ssl.keystore.location=/home/kafka/user-keystore.jks
ssl.keystore.password=Mavjzrov3xVi
ssl.key.password=Mavjzrov3xVi
EOF


# 创建 pod 作为生产者和消费者客户端
$ kubectl -n kafka run kafka-test -ti --image=10.0.129.0:60080/3rdparty/strimzi/kafka:latest --rm=true --restart=Never bash

# 将相关文件复制到 pod 中
$ kubectl -n kafka cp client-ssl.properties kafka-test:/home/kafka/
$ kubectl -n kafka cp user-keystore.jks kafka-test:/home/kafka/
$ kubectl -n kafka cp user-truststore.jks kafka-test:/home/kafka/


# 进入 pod 运行生产者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/

/opt/kafka/bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --command-config ./client-ssl.properties --list



$ /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --producer.config ./client.properties
>hello1
>hello2
>hello3
>hello4
>

# 进入 pod 运行消费者
$ kubeclt -n kafka exec -ti kafka-test bash
$ cd /home/kafka/
$ /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9093 --topic my-topic --consumer.config ./client.properties --from-beginning --group my-group
hello1
hello2
hello3
hello4











==========================

[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
[root@mw-init ssl]# kubectl -n kafka get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d
gl1z8MESIufb[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# keytool -keystore user-truststore.jks -alias CARoot -import -file ca.crt
输入密钥库口令:
再次输入新口令:
所有者: CN=cluster-ca v0, O=io.strimzi
发布者: CN=cluster-ca v0, O=io.strimzi
序列号: a05c3e3449da86ba
有效期为 Wed Oct 28 21:16:44 CST 2020 至 Thu Oct 28 21:16:44 CST 2021
证书指纹:
	 MD5:  3D:99:FA:05:1C:02:A4:42:5C:12:BB:9C:F2:95:FE:72
	 SHA1: 31:01:F9:33:E6:14:9A:5F:CE:37:81:9D:E5:25:19:52:7D:CC:7E:EE
	 SHA256: BB:D2:C5:43:E0:35:A9:55:8D:5E:00:FD:8A:B3:76:27:C7:B9:76:52:E1:3C:16:24:18:A7:F3:53:D9:CC:1D:4F
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.35 Criticality=false
AuthorityKeyIdentifier [
KeyIdentifier [
0000: F0 43 8D 33 F8 8C 3B 02   DF 13 27 3C 01 33 C1 DD  .C.3..;...'<.3..
0010: 28 61 FC 2A                                        (a.*
]
]

#2: ObjectId: 2.5.29.19 Criticality=false
BasicConstraints:[
  CA:true
  PathLen:2147483647
]

#3: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: F0 43 8D 33 F8 8C 3B 02   DF 13 27 3C 01 33 C1 DD  .C.3..;...'<.3..
0010: 28 61 FC 2A                                        (a.*
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get secret my-user -o jsonpath='{.data.user\.password}' | base64 -d
SiA4zp75lK51[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# keytool -importkeystore -srckeystore user.p12 -destkeystore user-keystore.jks -deststoretype pkcs12
正在将密钥库 user.p12 导入到 user-keystore.jks...
输入目标密钥库口令:
再次输入新口令:
输入源密钥库口令:
已成功导入别名 my-user 的条目。
已完成导入命令: 1 个条目成功导入, 0 个条目失败或取消
[root@mw-init ssl]#
[root@mw-init ssl]# cat << EOF > client-ssl.properties
> security.protocol=SSL
> ssl.truststore.location=/root/ssl/user-truststore.jks
> ssl.truststore.password=gl1z8MESIufb
> ssl.endpoint.identification.algorithm=
>
> ssl.keystore.location=/root/ssl/user-keystore.jks
> ssl.keystore.password=SiA4zp75lK51
> ssl.key.password=SiA4zp75lK51
> EOF
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get services
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
my-cluster-kafka-0                    NodePort    10.103.132.152   <none>        9094:32527/TCP               12h
my-cluster-kafka-1                    NodePort    10.107.51.9      <none>        9094:31042/TCP               12h
my-cluster-kafka-2                    NodePort    10.111.205.216   <none>        9094:31444/TCP               12h
my-cluster-kafka-bootstrap            ClusterIP   10.96.234.68     <none>        9091/TCP                     12h
my-cluster-kafka-brokers              ClusterIP   None             <none>        9091/TCP,9999/TCP            12h
my-cluster-kafka-external-bootstrap   NodePort    10.99.14.207     <none>        9094:31818/TCP               12h
my-cluster-zookeeper-client           ClusterIP   10.109.3.39      <none>        2181/TCP                     12h
my-cluster-zookeeper-nodes            ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   12h
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# kubectl -n kafka get node
NAME           STATUS   ROLES    AGE   VERSION
10.0.128.237   Ready    master   64d   v1.16.9
10.0.128.64    Ready    master   64d   v1.16.9
10.0.129.171   Ready    master   64d   v1.16.9
[root@mw-init ssl]#
[root@mw-init ssl]#
[root@mw-init ssl]# kafka-console-consumer.sh --bootstrap-server 10.0.128.237:31818 --topic my-topic --consumer.config ./client-ssl.properties --from-beginning --group my-group
hello2
hello1
hello5
hello3
hello4




```





https://github.com/strimzi/strimzi-kafka-operator/issues/3887





