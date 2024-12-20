{{/*
Expand the name of the chart.
*/}}
{{- define "alert-remediation.name" -}}
{{- default $.Chart.Name $.Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "alert-remediation.fullname" -}}
{{- if $.Values.fullnameOverride }}
{{- $.Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $.Chart.Name $.Values.nameOverride }}
{{- if contains $name $.Release.Name }}
{{- $.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "alert-remediation.chart" -}}
{{- printf "%s-%s" $.Chart.Name $.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "alert-remediation.labels" -}}
helm.sh/chart: {{ include "alert-remediation.chart" . }}
{{ include "alert-remediation.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "alert-remediation.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alert-remediation.name" . }}
app.kubernetes.io/instance: {{ $.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "alert-remediation.serviceAccountName" -}}
{{- if $.Values.serviceAccount.create }}
{{- default (include "alert-remediation.fullname" .) $.Values.serviceAccount.name }}
{{- else }}
{{- default "default" $.Values.serviceAccount.name }}
{{- end }}
{{- end }}
