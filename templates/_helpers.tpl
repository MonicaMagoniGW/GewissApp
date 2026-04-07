{{/* Chart name */}}
{{- define "gwapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Full resource name */}}
{{- define "gwapp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Namespace */}}
{{- define "gwapp.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/* Common labels */}}
{{- define "gwapp.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "gwapp.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels */}}
{{- define "gwapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gwapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Application image */}}
{{- define "gwapp.image" -}}
{{- printf "%s:%s" .Values.app.image.repository (.Values.app.image.tag | default .Chart.AppVersion) -}}
{{- end -}}

{{/* ServiceAccount name */}}
{{- define "gwapp.serviceAccountName" -}}
{{- if .Values.app.serviceAccount.create -}}
{{- default (include "gwapp.fullname" .) .Values.app.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.app.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* ConfigMap name */}}
{{- define "gwapp.configMapName" -}}
{{- printf "%s-config" (include "gwapp.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
