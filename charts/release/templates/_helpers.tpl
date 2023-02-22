{{/*
Expand the name of the chart.
*/}}
{{- define "release.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "release.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "release.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "release.labels" -}}
helm.sh/chart: {{ include "release.chart" . }}
{{ include "release.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "release.selectorLabels" -}}
app.kubernetes.io/name: {{ include "release.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "release.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "release.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "imagePullSecret" }}
{{- with .Values.containerRegistry }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .host .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{/*
Generate a checksum of the given templates
*/}}
{{- define "checksumTemplates" -}}
{{- $global := first . -}}
{{- $configTemplates := rest . -}}
{{- $configContents := "" -}}
{{- range $key, $name := $configTemplates }}
{{- $configContents = cat $configContents (include (printf "%s/%s.yaml" $global.Template.BasePath $name) $global) -}}
{{- end }}
{{- sha256sum $configContents -}}
{{- end }}

{{- define "railsMasterKeySecretEncoded" -}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (print (include "release.fullname" .) "-backend-secret") | default dict) }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- print ((get $secretData "RAILS_MASTER_KEY") | default (randAlphaNum 32 | b64enc)) }}
{{- end }}
