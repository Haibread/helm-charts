# suggestarr

Helm chart for [SuggestArr](https://github.com/giuseppe99barchetta/SuggestArr) — a media-recommendation engine that suggests content for Jellyfin/Plex/Emby via Jellyseerr/Overseerr.

## Install

```sh
helm install suggestarr ./charts/suggestarr
```

## Values

| Key | Default | Notes |
| --- | --- | --- |
| `image.repository` | `ciuse99/suggestarr` | |
| `image.tag` | `""` | Falls back to `Chart.AppVersion` (`2.6.0`). |
| `service.port` | `5000` | Must match `env.SUGGESTARR_PORT`. |
| `env.SUGGESTARR_PORT` | `"5000"` | Container listen port. |
| `env.LOG_LEVEL` | `info` | |
| `persistence.enabled` | `true` | Creates a 1Gi PVC mounted at `/app/config/config_files`. |
| `persistence.existingClaim` | `""` | Reuse an existing PVC instead. |
| `persistence.size` | `1Gi` | |
| `ingress.enabled` | `false` | |
| `httpRoute.enabled` | `false` | Gateway API `HTTPRoute`. |
| `networkPolicy.enabled` | `false` | When enabled with empty rules, deny-all. |

See [`values.yaml`](values.yaml) for the full list.

## Notes

- The container listen port is set by `SUGGESTARR_PORT`. If you change it, also change `service.port` — both are derived from the same value, so override them together.
- After install, port-forward to reach the UI:

  ```sh
  kubectl port-forward svc/suggestarr 5000:5000
  ```
