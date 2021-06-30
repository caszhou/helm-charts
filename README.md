# Helm charts
helm charts for iotdb

# Single mode values
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

# Single mode with iotdb grafana
```yaml
grafana:
  enable: true
  config:
    url: jdbc:iotdb://iotdb-0.iotdb-headless.middleware.svc.cluster.local:6667/
    username: root
    password: root
  image:
    # replace your iotdb-grafana docker image
    # application path: /iotdb-grafana
    repository: registry-vpc.cn-hangzhou.aliyuncs.com/ivehcore-base/iotdb-grafana
    pullPolicy: IfNotPresent
    tag: 0.12.1
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

# Single mode with iotdb metric service node port
```yaml
metricService:
  type: NodePort
  nodePort: 38181
```

# Config your self jmv options
```yaml
env:
  - name: ENABLE_CALCULATE_HEAP_SIZES
    value: "false"
  - name: MAX_HEAP_SIZE
    value: "16G"
  - name: HEAP_NEWSIZE
    value: "4G"
  - name: MAX_DIRECT_MEMORY_SIZE
    value: "10G"
```

# Cluster mode
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
after one pod restarted, the cluster cannot be used, so now iotdb cluster on k8s is not ready for prod.
