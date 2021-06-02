# helm-charts
helm charts for iotdb

# single values
```yaml
nameOverride: "iotdb"
fullnameOverride: "iotdb"

persistence:
  enabled: true

volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 30Gi
  storageClassName: iotdb-single

service:
  type: NodePort
  nodePort: 36667
```

# iotdb-grafana with single iotdb
```yaml
grafana:
  enable: true
  config:
    url: jdbc:iotdb://iotdb-0.iotdb-headless.middleware.svc.cluster.local:6667/
    username: root
    password: iotdb@IVC
  image:
    # replace your iotdb-grafana docker image
    # application path: /iotdb-grafana
    repository: registry-vpc.cn-hangzhou.aliyuncs.com/ivehcore-base/iotdb-grafana
    pullPolicy: IfNotPresent
    tag: 0.12.0-v2
  imagePullSecrets:
    - name: docker-vpc
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: dedicated
              operator: In
              values:
                - time_series_dbms
  tolerations:
    - key: dedicated
      operator: Equal
      value: time_series_dbms
      effect: NoExecute
```

# cluster
```yaml
replicaCount: 3

persistence:
  enabled: true

volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 30Gi
  storageClassName: iotdb-cluster

service:
  type: NodePort
  nodePort: 30667
```

# Storage
you can use static pv or dynamic pv, more details please see https://kubernetes.io/docs/concepts/storage/persistent-volumes/

# About cluster chart
after one pod is restarted, the cluster cannot be used.
