# radarr

Helm chart for [Radarr](https://github.com/Radarr/Radarr) using the [linuxserver image](https://github.com/linuxserver/docker-radarr).

## Install

```sh
helm install radarr ./charts/radarr
```

## Values

| Key | Default | Notes |
| --- | --- | --- |
| `image.repository` | `lscr.io/linuxserver/radarr` | |
| `image.tag` | `latest` | linuxserver tags don't track Radarr `appVersion` 1:1; pin a digest in production. |
| `service.port` | `7878` | Web UI port. |
| `env.PUID` / `env.PGID` | `"1000"` | Must be quoted strings — the linuxserver entrypoint reads them as text. |
| `env.TZ` | `Etc/UTC` | |
| `env.UMASK` | `"022"` | |
| `persistence.config.enabled` | `true` | 2Gi PVC mounted at `/config`. |
| `persistence.movies.enabled` | `true` | 100Gi PVC mounted at `/movies` (RWO by default — switch to RWX if shared). |
| `persistence.downloads.enabled` | `true` | 50Gi PVC mounted at `/downloads`. |
| `persistence.<vol>.existingClaim` | `""` | Reuse an existing PVC; the chart skips PVC creation. |
| `ingress.enabled` | `false` | |
| `httpRoute.enabled` | `false` | Gateway API `HTTPRoute`. |
| `networkPolicy.enabled` | `false` | |

See [`values.yaml`](values.yaml) for the full list.

## Important: securityContext

The linuxserver image must start as root in order to drop privileges via `PUID`/`PGID`. **Do not set `securityContext.runAsNonRoot: true`** — it will break the container. The defaults leave `securityContext` empty for this reason.

## Sharing volumes with Sonarr/Prowlarr/etc.

If you run other *arr apps that need the same `/movies` and `/downloads` paths, point them at the same PVCs via `persistence.movies.existingClaim` (and ensure the underlying storage class supports `ReadWriteMany`).
