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
