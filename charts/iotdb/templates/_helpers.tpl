{{/*
Expand the name of the chart.
*/}}
{{- define "iotdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "iotdb-grafana.name" -}}
{{- printf "%s-%s" (default .Chart.Name .Values.nameOverride) "grafana" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "iotdb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "iotdb-grafana.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- print .Values.fullnameOverride "-grafana" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- print .Release.Name "-grafana" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-%s" .Release.Name $name "grafana" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "iotdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "iotdb.labels" -}}
helm.sh/chart: {{ include "iotdb.chart" . }}
{{ include "iotdb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "iotdb-grafana.labels" -}}
helm.sh/chart: {{ include "iotdb.chart" . }}
{{ include "iotdb-grafana.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iotdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iotdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "iotdb-grafana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iotdb-grafana.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "iotdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "iotdb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper JMX exporter image name
*/}}
{{- define "iotdb.metrics.jmx.image" -}}
{{- $registryName := .Values.metrics.jmx.image.registry -}}
{{- $repositoryName := .Values.metrics.jmx.image.repository -}}
{{- $tag := .Values.metrics.jmx.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the Iotdb configuration configmap
*/}}
{{- define "iotdb.metrics.jmx.configmapName" -}}
{{- if .Values.metrics.jmx.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.metrics.jmx.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-jmx-configuration" (include "iotdb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "inotdb.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "iotdb.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "iotdb.metrics.jmx.createConfigmap" -}}
{{- if and .Values.metrics.jmx.enabled .Values.metrics.jmx.config (not .Values.metrics.jmx.existingConfigmap) }}
    {{- true -}}
{{- end -}}
{{- end -}}
