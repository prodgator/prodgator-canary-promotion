# prodgator-canary-promotion

A small app that walks a change through `dev`, `uat` and `main` (production) so Prodgator can show its promotion lineage. Nothing here is a real service: deploys are mocked, and the scan results in `fixtures/` are synthetic.

- `ci.yml`: tests with coverage and a SARIF scan report, sent to Prodgator by the report action (GitHub OIDC, no stored secret).
- `deploy.yml`: a mocked deploy on each push to `dev`, `uat` and `main`, into the GitHub environments `dev`, `uat` and `production`. A commit message with `[skip deploy]` skips it.
- `release.yml`: run by hand on `main` to tag a version and publish a release.

Walk-through: see `docs/runbooks/promotion-canary.md` in prodgator/prodgator.
