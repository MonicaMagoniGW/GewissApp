# Repository Guidelines

## Project Structure & Module Organization
This repository is the `gwapp` Helm chart for deploying generic applications (Deployment, Service, ConfigMap, HPA, PDB).
- `Chart.yaml`: chart metadata (`name: gwapp`, `version`, `appVersion`).
- `values.yaml`: default configuration values; all settings live under the `app` key.
- `values.schema.json`: JSON Schema for value validation.
- `examples/`: sample values files (`basic-values.yaml`, `autoscaling-values.yaml`).
- `templates/`: rendered Kubernetes manifests and helpers:
  - `deployment.yaml`, `service.yaml`, `configmap.yaml`, `hpa.yaml`, `pdb.yaml`, `serviceaccount.yaml`
  - `validate.yaml` for cross-field validation (`fail` rules).
  - `NOTES.txt` for post-install instructions.
  - `_helpers.tpl` for shared template functions and naming logic.

Keep new resources in `templates/` and expose all configurable fields via `values.yaml`.

## Build, Test, and Development Commands
Use Helm CLI from the repository root.
- `helm lint .` checks chart structure and template validity.
- `helm template my-release .` renders manifests locally for review.
- `helm template my-release . -f examples/basic-values.yaml` tests custom overrides.
- `helm install my-release . --dry-run --debug` simulates install with server-side validations.
- `helm upgrade --install my-release . -n <namespace> -f my-values.yaml` deploys/updates in a cluster.

## Coding Style & Naming Conventions
- YAML uses 2-space indentation; avoid tabs.
- Prefer lowercase, descriptive keys in `values.yaml` (for example `app.configMap.envFrom`).
- Template helper names follow `gwapp.*` convention in `_helpers.tpl` (e.g. `gwapp.fullname`, `gwapp.labels`, `gwapp.image`).
- Keep resource names deterministic and release-scoped via helper templates (`include "gwapp.fullname" .`).
- Add short `# --` comments for user-facing values.

## Testing Guidelines
There is no dedicated test framework in this repository; validation is chart-based.
- Run `helm lint .` before every commit.
- Render manifests with at least default values and one example values file from `examples/`.
- For changes to conditional logic (`if`, `with`, `range`), verify both enabled and disabled paths render cleanly.
- Check `validate.yaml` if adding new cross-field constraints.

## Commit & Pull Request Guidelines
Current history uses short, imperative commit subjects (for example: `Add HPA support`, `Add PDB`).
- Use `Add/Update/Fix <scope>` style, keep subject concise.
- In PRs, include:
  - purpose and impacted templates/values
  - sample `helm template` output snippets or command used
  - any breaking value changes and migration notes
  - linked issue/work item when available

## Security & Configuration Tips
- Never commit real credentials; reference Kubernetes Secrets via `envFrom` with `secretRef`.
- Prefer least-privilege defaults and explicit opt-in for optional features (e.g. `service.enabled`, `pdb.enabled`, `autoscaling.enabled`).
- Use `values.schema.json` to enforce required fields and valid types at install time.
