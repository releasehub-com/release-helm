{{/*
Expand the name of the chart.
*/}}
{{- define "temporal.name" -}}
{{- default .Chart.Name .Values.temporal.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "temporal.fullname" -}}
{{- printf "%s-temporalio" (include "release.fullname" .) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "temporal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "temporal.serviceAccountName" -}}
{{ default (include "temporal.fullname" .) .Values.temporal.serviceAccount.name }}
{{- end -}}

{{/*
Define the service account as needed
*/}}
{{- define "temporal.serviceAccount" -}}
{{- if .Values.temporal.serviceAccount.create -}}
serviceAccountName: {{ include "temporal.serviceAccountName" . }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified component name from the full app name and a component name.
We truncate the full name at 63 - 1 (last dash) - len(component name) chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
and we want to make sure that the component is included in the name.
*/}}
{{- define "temporal.componentname" -}}
{{- $global := index . 0 -}}
{{- $component := index . 1 | trimPrefix "-" -}}
{{- printf "%s-%s" (include "temporal.fullname" $global | trunc (sub 62 (len $component) | int) | trimSuffix "-" ) $component | trimSuffix "-" -}}
{{- end -}}

{{/*
Call nested templates.
Source: https://stackoverflow.com/a/52024583/3027614
*/}}
{{- define "call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 }}
{{- $template := index . 2 }}
{{- include $template (dict "Chart" (dict "Name" $subchart) "Values" (index $dot.Values $subchart) "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{- define "temporal.frontend.grpcPort" -}}
{{- if $.Values.temporal.server.frontend.service.port -}}
{{- $.Values.temporal.server.frontend.service.port -}}
{{- else -}}
{{- 7233 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.frontend.membershipPort" -}}
{{- if $.Values.temporal.server.frontend.service.membershipPort -}}
{{- $.Values.temporal.server.frontend.service.membershipPort -}}
{{- else -}}
{{- 6933 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.history.grpcPort" -}}
{{- if $.Values.temporal.server.history.service.port -}}
{{- $.Values.temporal.server.history.service.port -}}
{{- else -}}
{{- 7234 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.history.membershipPort" -}}
{{- if $.Values.temporal.server.history.service.membershipPort -}}
{{- $.Values.temporal.server.history.service.membershipPort -}}
{{- else -}}
{{- 6934 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.matching.grpcPort" -}}
{{- if $.Values.temporal.server.matching.service.port -}}
{{- $.Values.temporal.server.matching.service.port -}}
{{- else -}}
{{- 7235 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.matching.membershipPort" -}}
{{- if $.Values.temporal.server.matching.service.membershipPort -}}
{{- $.Values.temporal.server.matching.service.membershipPort -}}
{{- else -}}
{{- 6935 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.worker.grpcPort" -}}
{{- if $.Values.temporal.server.worker.service.port -}}
{{- $.Values.temporal.server.worker.service.port -}}
{{- else -}}
{{- 7239 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.worker.membershipPort" -}}
{{- if $.Values.temporal.server.worker.service.membershipPort -}}
{{- $.Values.temporal.server.worker.service.membershipPort -}}
{{- else -}}
{{- 6939 -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.schema" -}}
{{- if eq . "default" -}}
{{- print "temporal" -}}
{{- else -}}
{{- print . -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.driver" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.driver -}}
{{- $storeConfig.driver -}}
{{- else if $global.Values.temporal.cassandra.enabled -}}
{{- print "cassandra" -}}
{{- else if $global.Values.temporal.mysql.enabled -}}
{{- print "sql" -}}
{{- else if $global.Values.temporal.postgresql.enabled -}}
{{- print "sql" -}}
{{- else -}}
{{- required (printf "Please specify persistence driver for %s store" $store) $storeConfig.driver -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.cassandra.hosts" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.cassandra.hosts -}}
{{- $storeConfig.cassandra.hosts | join "," -}}
{{- else if and $global.Values.temporal.cassandra.enabled (eq (include "temporal.persistence.driver" (list $global $store)) "cassandra") -}}
{{- include "cassandra.hosts" $global -}}
{{- else -}}
{{- required (printf "Please specify cassandra hosts for %s store" $store) $storeConfig.cassandra.hosts -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.cassandra.port" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.cassandra.port -}}
{{- $storeConfig.cassandra.port -}}
{{- else if and $global.Values.temporal.cassandra.enabled (eq (include "temporal.persistence.driver" (list $global $store)) "cassandra") -}}
{{- $global.Values.temporal.cassandra.config.ports.cql -}}
{{- else -}}
{{- required (printf "Please specify cassandra port for %s store" $store) $storeConfig.cassandra.port -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.cassandra.secretName" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.cassandra.existingSecret -}}
{{- $storeConfig.cassandra.existingSecret -}}
{{- else if $storeConfig.cassandra.password -}}
{{- include "temporal.componentname" (list $global (printf "%s-store" $store)) -}}
{{- else -}}
{{/* Cassandra password is optional, but we will create an empty secret for it */}}
{{- include "temporal.componentname" (list $global (printf "%s-store" $store)) -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.cassandra.secretKey" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{/* Cassandra password is optional, but we will create an empty secret for it */}}
{{- print "password" -}}
{{- end -}}

{{- define "temporal.persistence.sql.driver" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.driver -}}
{{- $storeConfig.sql.driver -}}
{{- else if $global.Values.temporal.mysql.enabled -}}
{{- print "mysql" -}}
{{- else if $global.Values.temporal.postgresql.enabled -}}
{{- print "postgres" -}}
{{- else -}}
{{- required (printf "Please specify sql driver for %s store" $store) $storeConfig.sql.host -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.host" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.host -}}
{{- $storeConfig.sql.host -}}
{{- else if $global.Values.config.databaseHost -}}
{{- $global.Values.config.databaseHost -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- include "mysql.host" $global -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- include "postgresql.host" $global -}}
{{- else -}}
{{- required (printf "Please specify sql host for %s store" $store) $storeConfig.sql.host -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.port" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.port -}}
{{- $storeConfig.sql.port -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- $global.Values.temporal.mysql.service.port -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- $global.Values.temporal.postgresql.service.port -}}
{{- else -}}
{{- required (printf "Please specify sql port for %s store" $store) $storeConfig.sql.port -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.user" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.user -}}
{{- $storeConfig.sql.user -}}
{{- else if $global.Values.config.databaseUser -}}
{{- $global.Values.config.databaseUser -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- $global.Values.temporal.mysql.mysqlUser -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- $global.Values.temporal.postgresql.postgresqlUser -}}
{{- else -}}
{{- required (printf "Please specify sql user for %s store" $store) $storeConfig.sql.user -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.password" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.password -}}
{{- $storeConfig.sql.password -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- if or $global.Values.temporal.schema.setup.enabled $global.Values.temporal.schema.update.enabled -}}
{{- required "Please specify password for MySQL chart" $global.Values.temporal.mysql.mysqlPassword -}}
{{- else -}}
{{- $global.Values.temporal.mysql.mysqlPassword -}}
{{- end -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- if or $global.Values.temporal.schema.setup.enabled $global.Values.temporal.schema.update.enabled -}}
{{- required "Please specify password for PostgreSQL chart" $global.Values.temporal.postgresql.postgresqlPassword -}}
{{- else -}}
{{- $global.Values.temporal.postgresql.postgresqlPassword -}}
{{- end -}}
{{- else -}}
{{- required (printf "Please specify sql password for %s store" $store) $storeConfig.sql.password -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.secretName" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if $storeConfig.sql.existingSecret -}}
{{- $storeConfig.sql.existingSecret -}}
{{- else if $storeConfig.sql.password -}}
{{- include "temporal.componentname" (list $global (printf "%s-store" $store)) -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- include "call-nested" (list $global "mysql" "mysql.secretName") -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- include "call-nested" (list $global "postgresql" "postgresql.secretName") -}}
{{- else -}}
{{- required (printf "Please specify sql password or existing secret for %s store" $store) $storeConfig.sql.existingSecret -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.sql.secretKey" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.temporal.server.config.persistence $store -}}
{{- if or $storeConfig.sql.existingSecret $storeConfig.sql.password -}}
{{- print "password" -}}
{{- else if and $global.Values.temporal.mysql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "mysql")) -}}
{{- print "mysql-password" -}}
{{- else if and $global.Values.temporal.postgresql.enabled (and (eq (include "temporal.persistence.driver" (list $global $store)) "sql") (eq (include "temporal.persistence.sql.driver" (list $global $store)) "postgres")) -}}
{{- print "postgresql-password" -}}
{{- else -}}
{{- fail (printf "Please specify sql password or existing secret for %s store" $store) -}}
{{- end -}}
{{- end -}}

{{- define "temporal.persistence.secretName" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- include (printf "temporal.persistence.%s.secretName" (include "temporal.persistence.driver" (list $global $store))) (list $global $store) -}}
{{- end -}}

{{- define "temporal.persistence.secretKey" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- include (printf "temporal.persistence.%s.secretKey" (include "temporal.persistence.driver" (list $global $store))) (list $global $store) -}}
{{- end -}}

{{/*
Based on Bitnami charts method
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.temporal.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
