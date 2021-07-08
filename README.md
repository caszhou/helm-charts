# Helm charts
helm charts for iotdb

# Single mode values
```yaml
persistence:
  enabled: true

dataVolumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 30Gi
  storageClassName: iotdb-single-data

logsVolumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 30Gi
  storageClassName: iotdb-single-logs

rpcService:
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

# Single mode with iotdb jmx node port
```yaml
metricService:
  type: NodePort
  nodePort: 31999
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

# Config jmx exporter and service monitor for prometheus operator
```yaml
metrics:
  enabled: true

  serviceMonitor:
    enabled: true
```

# Config alerting for prometheus operator
```yaml
metrics:
  enabled: true

  serviceMonitor:
    enabled: true

    alerting:
      enabled: true

      rules:
        - alert: IotdbServerOOMRisk
          annotations:
            description: Iotdb server oom risk.
            summary: Iotdb server maybe occur oom, this requires your attention.
          expr: |
            100 -
            (
              node_memory_MemAvailable_bytes{job="node-exporter", instance="ivc010000000027worker"}
            /
              node_memory_MemTotal_bytes{job="node-exporter", instance="ivc010000000027worker"}
            * 100
            )
            > 50
          for: 1m
          labels:
            severity: warning
        - alert: IotdbTooManyFailRequest
          annotations:
            description: Too many fail request.
            summary: Too many fail request, this requires your attention.
          expr: |
            irate(org_apache_iotdb_service_monitor_globalreqfailnum[2m]) > 100
          for: 1m
          labels:
            severity: warning

      additionalLabels:
        prometheus: k8s
        role: alert-rules
```

# Config backup function

## values

```yaml
backup:
  enabled: true

  fromClaimName: "iotdb-backup-from"

  toClaimName: "iotdb-backup-to"

  script: |-
    #!/bin/bash -ex

    /iotdb/sbin/start-cli.sh -h ${host} -p ${port} -u ${user} -pw ${password} -e "REVOKE ivc-pdc FROM ivc-pdc; REVOKE ivc-iov FROM ivc-iov; REVOKE ivc-pems FROM ivc-pems; FLUSH; FULL MERGE;";
    sleep 30;

    folder=`date '+%Y-%m-%d_%H:%M:%S'`;
    mkdir "/iotdb/backup/$folder";

    from=/iotdb/data/*
    to="/iotdb/backup/$folder/"
    cp -r $from $to;

    find /iotdb/backup -mindepth 1 ! -regex "^/iotdb/backup/$folder\(/.*\)?" -delete;

    /iotdb/sbin/start-cli.sh -h ${host} -p ${port} -u ${user} -pw ${password} -e "GRANT ivc-pdc TO ivc-pdc; GRANT ivc-iov TO ivc-iov; GRANT ivc-pems TO ivc-pems;";
```

## pvc
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: iotdb-backup-from
spec:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 30Gi
  flexVolume:
    driver: alicloud/nas
    options:
      modeType: non-recursive
      path: /middleware/middleware-data-iotdb-new-0-pvc-da9c7ec9-45a6-4c46-af79-56ac1d628676
      server: aliyun-nas-server
      vers: '4.0'
  persistentVolumeReclaimPolicy: Retain
  storageClassName: iotdb-backup-from
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: iotdb-backup-from
  namespace: middleware
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 30Gi
  storageClassName: "iotdb-backup-from"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: iotdb-backup-to
spec:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 30Gi
  flexVolume:
    driver: alicloud/nas
    options:
      modeType: non-recursive
      path: /mnt/backup/iotdb/prod-new
      server: aliyun-nas-server
      vers: '4.0'
  persistentVolumeReclaimPolicy: Retain
  storageClassName: iotdb-backup-to
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: iotdb-backup-to
  namespace: middleware
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 30Gi
  storageClassName: "iotdb-backup-to"

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
