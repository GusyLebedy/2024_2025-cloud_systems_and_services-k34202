{{- define "hello-world.name" -}}
hello-world
{{- end -}}

{{- define "hello-world.fullname" -}}
{{ .Release.Name }}-hello-world
{{- end -}}
