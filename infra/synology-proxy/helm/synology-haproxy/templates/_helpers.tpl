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
{{- range .Values.proxy.ports }}
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
{{- range .Values.proxy.ports }}
{{- if or (not .appProtocol) (ne (.appProtocol | trim | lower) "http") }}
{{- printf ":%s," (cat .containerPort) }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Config Functions
*/}}
{{- define "synology-haproxy.config.tpl" -}}
global
    log stdout format raw daemon debug

defaults http
    timeout connect 5s
    timeout client 1m
    timeout server 1m
    mode http

frontend prometheus from http
    bind :8405
    monitor-uri /healthz
{{-  if (include "synology-haproxy.httpProxyPorts.tpl" .) }}  
    monitor fail if { nbsrv(synology-http) eq 0 }
{{- end }}
{{-  if (include "synology-haproxy.otherProxyPorts.tpl" .) }}  
    monitor fail if { nbsrv(synology-other) eq 0 }
{{- end }}
    http-request use-service prometheus-exporter if { path /metrics }
    no log

defaults synology from http
    log stdout format raw daemon
    option httplog
{{ if (include "synology-haproxy.httpProxyPorts.tpl" .) }}
frontend synology-http
{{- cat "bind" (include "synology-haproxy.httpProxyPorts.tpl" . | trimSuffix ",") | nindent 4 }}
    default_backend synology-http
    capture request header Forwarded len 64
{{- if .Values.proxy.frontend.http }}
{{- .Values.proxy.frontend.http | nindent 12}}
{{- end }}
{{- end }}
{{ if (include "synology-haproxy.otherProxyPorts.tpl" .) }}
frontend synology-other
{{- cat "bind" (include "synology-haproxy.otherProxyPorts.tpl" . | trimSuffix ",") | nindent 4 }}
    default_backend synology-other
    capture request header Forwarded len 64
{{- if .Values.proxy.frontend.other }}
{{- .Values.proxy.frontend.other | nindent 12}}
{{- end }}
{{- end }}

resolvers router
    accepted_payload_size 4096
    nameserver router_udp 192.168.255.1:53
    nameserver router_tcp tcp@192.168.255.1:53
{{ if (include "synology-haproxy.httpProxyPorts.tpl" .) }}
backend synology-http
    server-template synology-http- 3 HomeLabSAN.homelab.csfreak.com.{{ include "synology-haproxy.httpProxyCheckPort.tpl" . }} resolvers router check 
{{- if .Values.proxy.backend.http }}
{{- .Values.proxy.backend.http | nindent 4 }}
{{- end }}
{{- end }}
{{ if (include "synology-haproxy.otherProxyPorts.tpl" .) }}
backend synology-other
    server-template storage-other- 3 HomeLabSAN.homelab.csfreak.com. resolvers router
{{- if .Values.proxy.backend.other }}
{{- .Values.proxy.backend.other | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
