# Gewiss Generic App Helm Chart (`gwapp`)

`gwapp` is a generic Helm chart for standard application workloads.

Included resources:
- `Deployment`
- `Service`
- optional `ConfigMap`
- optional `HorizontalPodAutoscaler`
- optional `PodDisruptionBudget`
- optional `ServiceAccount`

Not included for now:
- `Ingress`

## Quick Start

```bash
helm lint gwapp
helm template my-app gwapp
helm template my-app gwapp -f gwapp/examples/basic-values.yaml
```

## Common Use Cases

### Application with ConfigMap and existing Secret

```yaml
app:
  image:
    repository: ghcr.io/your-org/orders-api
    tag: "1.4.2"
  containerPort: 8080
  envFrom:
    - secretRef:
        name: orders-api-secrets
  configMap:
    enabled: true
    envFrom: true
    data:
      APP_ENV: production
      LOG_LEVEL: info
  service:
    port: 80
  pdb:
    enabled: true
    minAvailable: 1
```

### Enable HPA

```yaml
app:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 6
    targetCPUUtilizationPercentage: 75
    targetMemoryUtilizationPercentage: 80
```

## Notes

- If `app.autoscaling.enabled=true`, the chart does not render `spec.replicas` in the `Deployment`.
- `app.configMap.enabled=true` can be used with `envFrom=true`, `mount.enabled=true`, or both.
- `app.pdb` supports `minAvailable` or `maxUnavailable`, not both.

## Configuration Reference

### Root Values

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `nameOverride` | `string` | `""` | Override chart name. |
| `fullnameOverride` | `string` | `""` | Override full release resource name. |

### Core Application Values

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.replicaCount` | `integer` | `1` | Number of pod replicas (ignored when autoscaling is enabled). |
| `app.revisionHistoryLimit` | `integer` | `3` | Number of old ReplicaSets to retain. |
| `app.containerPort` | `integer` | `8080` | Container port exposed by the application. |
| `app.command` | `array` | `[]` | Override container entrypoint. |
| `app.args` | `array` | `[]` | Override container arguments. |
| `app.env` | `array` | `[]` | Extra environment variables (Kubernetes `env` syntax). |
| `app.envFrom` | `array` | `[]` | Extra `envFrom` sources (e.g. `secretRef`, `configMapRef`). |

### Image

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.image.repository` | `string` | `nginx` | Container image repository. |
| `app.image.tag` | `string` | `""` | Image tag; defaults to chart `appVersion` when empty. |
| `app.image.pullPolicy` | `string` | `IfNotPresent` | Image pull policy (`Always`, `IfNotPresent`, `Never`). |
| `app.image.pullSecrets` | `array` | `[]` | List of image pull secret names. |

### ServiceAccount

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.serviceAccount.create` | `bool` | `true` | Create a dedicated ServiceAccount. |
| `app.serviceAccount.name` | `string` | `""` | ServiceAccount name; defaults to fullname if empty. |
| `app.serviceAccount.annotations` | `object` | `{}` | Annotations added to the ServiceAccount. |

### Service

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.service.enabled` | `bool` | `true` | Create a Service resource. |
| `app.service.type` | `string` | `ClusterIP` | Service type (`ClusterIP`, `NodePort`, `LoadBalancer`). |
| `app.service.port` | `integer` | `80` | Service port. |
| `app.service.targetPort` | `integer\|string` | `http` | Target port name or number on the container. |
| `app.service.annotations` | `object` | `{}` | Annotations added to the Service. |

### ConfigMap

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.configMap.enabled` | `bool` | `false` | Create a ConfigMap resource. |
| `app.configMap.annotations` | `object` | `{}` | Annotations added to the ConfigMap. |
| `app.configMap.data` | `object` | `{}` | Key-value pairs stored as text data. |
| `app.configMap.binaryData` | `object` | `{}` | Key-value pairs stored as base64-encoded binary data. |
| `app.configMap.envFrom` | `bool` | `false` | Inject ConfigMap keys as environment variables via `envFrom`. |
| `app.configMap.mount.enabled` | `bool` | `false` | Mount the ConfigMap as a volume. |
| `app.configMap.mount.path` | `string` | `"/config"` | Mount path inside the container. |
| `app.configMap.mount.readOnly` | `bool` | `true` | Mount the volume as read-only. |

### Autoscaling (HPA)

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.autoscaling.enabled` | `bool` | `false` | Create a HorizontalPodAutoscaler. |
| `app.autoscaling.minReplicas` | `integer` | `2` | Minimum number of replicas. |
| `app.autoscaling.maxReplicas` | `integer` | `6` | Maximum number of replicas. |
| `app.autoscaling.targetCPUUtilizationPercentage` | `integer` | `75` | Target average CPU utilization (%). |
| `app.autoscaling.targetMemoryUtilizationPercentage` | `integer\|null` | `null` | Target average memory utilization (%); omitted when `null`. |

### PodDisruptionBudget

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.pdb.enabled` | `bool` | `false` | Create a PodDisruptionBudget. |
| `app.pdb.minAvailable` | `integer\|string\|null` | `null` | Minimum available pods (mutually exclusive with `maxUnavailable`). |
| `app.pdb.maxUnavailable` | `integer\|string\|null` | `null` | Maximum unavailable pods (mutually exclusive with `minAvailable`). |

### Probes

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.probes.liveness` | `object` | `{}` | Liveness probe configuration (Kubernetes probe syntax). |
| `app.probes.readiness` | `object` | `{}` | Readiness probe configuration. |
| `app.probes.startup` | `object` | `{}` | Startup probe configuration. |

### Security Contexts

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.podSecurityContext` | `object` | `{}` | Pod-level security context. |
| `app.securityContext` | `object` | `{}` | Container-level security context. |

### Resources & Scheduling

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.resources` | `object` | `{}` | Container resource requests and limits. |
| `app.volumes` | `array` | `[]` | Additional pod volumes. |
| `app.volumeMounts` | `array` | `[]` | Additional container volume mounts. |
| `app.nodeSelector` | `object` | `{}` | Node selector constraints. |
| `app.tolerations` | `array` | `[]` | Pod tolerations. |
| `app.affinity` | `object` | `{}` | Pod affinity/anti-affinity rules. |
| `app.topologySpreadConstraints.maxSkew` | `integer` | `1` | Maximum spread skew. |
| `app.topologySpreadConstraints.topologyKey` | `string` | `kubernetes.io/hostname` | Topology key for spread. |
| `app.topologySpreadConstraints.whenUnsatisfiable` | `string` | `ScheduleAnyway` | Policy when constraints can't be satisfied (`DoNotSchedule`, `ScheduleAnyway`). |

### Metadata

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `app.deploymentAnnotations` | `object` | `{}` | Annotations added to the Deployment. |
| `app.podAnnotations` | `object` | `{}` | Annotations added to pods. |
| `app.podLabels` | `object` | `{}` | Extra labels added to pods. |
