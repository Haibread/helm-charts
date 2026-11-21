# Security policy

## Reporting a vulnerability

Report it privately through
[GitHub's private vulnerability reporting](https://github.com/Haibread/helm-charts/security/advisories/new).
Only the maintainers and you see the draft advisory, where the fix is
discussed and prepared.

Do not open a public issue, pull request or discussion for a vulnerability:
describing it in public discloses it before it is fixed.

A useful report holds:

- the affected chart and chart version
- the values and steps that reproduce the problem
- the impact as you see it

## Supported versions

Fixes ship in a new chart release; only the latest release of each chart is
supported.

## Scope

In scope is what the charts in [`charts/`](charts) render and ship:

- insecure defaults in `values.yaml`, such as a weakened pod or container
  security context
- templates that expose a workload or leak a credential
- over-broad RBAC or network exposure produced by the chart

Out of scope:

- a vulnerability in an application image or another upstream dependency that
  is already public upstream: report it there
- a finding that needs an already-compromised cluster or account
- scanner output with no path to exploitation

## What happens next

1. The report is acknowledged.
2. The maintainers assess it and confirm or decline it.
3. A fix is prepared in the advisory's private fork.
4. The fix is released.
5. The advisory is published, with a CVE requested through GitHub when the
   impact warrants one, and you are credited unless you prefer otherwise.

Reports are handled on a best-effort basis.
