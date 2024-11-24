{{/*
Return the fully qualified name of the resource.
*/}}
{{- define "currency-services.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the name of the chart.
*/}}
{{- define "currency-services.name" -}}
{{- printf "%s" .Chart.Name -}}
{{- end -}}