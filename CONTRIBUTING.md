# Contributing

Open an issue or a pull request on
[Haibread/helm-charts](https://github.com/Haibread/helm-charts). Install
[pre-commit](https://pre-commit.com), make the hooks and the tests pass, and
open a pull request. For a vulnerability, follow [SECURITY.md](SECURITY.md)
instead.

## Development setup

Tools the hooks, the tests and CI shell out to:

| Tool | Needed for | Install |
| ---- | ---------- | ------- |
| [`helm`](https://helm.sh/docs/intro/install/) 3.x | lint, template, tests | `brew install helm` (macOS), the install script or your package manager (Linux) |
| [`pre-commit`](https://pre-commit.com/#install) | the commit gate | `brew install pre-commit` (macOS), `pipx install pre-commit` (Linux) |
| [`chart-testing`](https://github.com/helm/chart-testing#installation) (`ct`) | `ct lint`, `ct install` | `brew install chart-testing` (macOS), release archive (Linux) |
| [`helm-docs`](https://github.com/norwoodj/helm-docs#installation) | regenerating each chart's `VALUES.md` | `brew install norwoodj/tap/helm-docs` (macOS), release archive (Linux) |
| [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) and `kubectl` | `ct install` only | `brew install kind kubectl` (macOS), release binaries (Linux) |

The `helm-docs` and `ct lint` hooks skip themselves when their binary is
missing; CI runs both unconditionally, so install them.

Install the hooks from a fresh clone:

```bash
pre-commit install
```

The setup works when this passes:

```bash
pre-commit run --all-files
```

See [README.md](README.md) for installing a chart.

## Running the tests

The whole local suite, which mirrors the CI lint and template jobs (`helm lint`,
`helm template` with the gated resources on, every `ci/*-values.yaml`, `ct lint`):

```bash
bash scripts/test-local.sh
```

A single chart:

```bash
helm lint charts/<chart>
```

```bash
helm template t charts/<chart> -f charts/<chart>/ci/<scenario>-values.yaml
```

Each `ci/*-values.yaml` file of a chart is one scenario that `ct install` also
installs. Add a scenario there when a change introduces a value combination
worth installing.

The install tests need a Docker-backed cluster. Create one and run them
against the charts that changed since `main`:

```bash
kind create cluster
```

```bash
ct install --config ct.yaml
```

Add `--all` to install every chart. A change to a chart brings its tests: a
new `ci/` scenario for new behaviour, a regression scenario for a fix.

## Pre-commit hooks

Hooks must pass before a commit is pushed. The hook list is in
[`.pre-commit-config.yaml`](.pre-commit-config.yaml).

```bash
pre-commit run --all-files
```

```bash
pre-commit run <hook-id> --all-files
```

| Hook | Checks | Fix |
| ---- | ------ | --- |
| `helm-docs` | each chart's `VALUES.md` matches its `values.yaml` | run the hook, commit the regenerated file |
| `yamllint` | YAML style, per [`.yamllint.yaml`](.github/linters/.yamllint.yaml) | edit the file by hand |
| `markdownlint-cli2` | Markdown style, per [`.markdownlint.yaml`](.github/linters/.markdownlint.yaml) | edit the file by hand |

`--no-verify` and `SKIP=` are not the fix: a red hook is a real finding. Fix the
change, or change the configuration in the same pull request and say why. The
same hooks run in CI, so skipping locally only moves the failure somewhere
slower.

## Continuous integration

| Workflow | Purpose | Reproduce locally |
| -------- | ------- | ----------------- |
| [`lint.yaml`](.github/workflows/lint.yaml) | `ct lint`, yamllint, markdownlint, `VALUES.md` drift | `pre-commit run --all-files` |
| [`lint-test.yaml`](.github/workflows/lint-test.yaml) | template rendering, kubeconform schema validation, `ct install` on a kind cluster | `bash scripts/test-local.sh`, then `ct install --config ct.yaml` |

Both run only when a pull request touches `charts/`, `ct.yaml` or the workflow
itself, so a documentation-only change skips them. They need no secrets.

`ct lint` fails a pull request that changes a chart without raising its
`version` in `Chart.yaml` (`check-version-increment` in [`ct.yaml`](ct.yaml)):
chart consumers rely on the version to see that a chart changed. The
maintainers decide the new version, so mention in the pull request that a
chart changed and let them raise it.

## Submitting a change

- Branch from `main`, named for the change in short kebab-case.
- Commit subjects are imperative and lowercase; follow `git log --oneline`.
- Update the chart's documentation in the same pull request.
- Open the pull request against `main` with CI green.
