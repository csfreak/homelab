{{/*
Expand the name of the chart.
*/}}
{{- define "synology-haproxy.name" -}}
{{- print .Chart.Name "-" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "synology-haproxy.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- print .Chart.Name "-" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "synology-haproxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "synology-haproxy.labels" -}}
helm.sh/chart: {{ include "synology-haproxy.chart" . }}
{{ include "synology-haproxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "synology-haproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "synology-haproxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Port Functions
*/}}
{{- define "synology-haproxy.httpProxyPorts.tpl" }}
{{- range .Values.proxyPorts }}
{{- if .appProtocol }}
{{- if eq (.appProtocol | trim | lower) "http" }}
{{- printf ":%s," (cat .containerPort) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{-  define "synology-haproxy.httpProxyCheckPort.tpl" }}
{{- regexSplit "," (include "synology-haproxy.httpProxyPorts.tpl" .) 2 | first }}
{{- end }}

{{- define "synology-haproxy.otherProxyPorts.tpl" -}}
{{- range .Values.proxyPorts }}
{{- if or (not .appProtocol) (ne (.appProtocol | trim | lower) "http") }}
{{- printf ":%s," (cat .containerPort) }}
{{- end }}
{{- end }}
{{- end }}