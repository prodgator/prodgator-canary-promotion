# prodgator-canary-promotion

A small app that walks a change through `dev`, `uat` and `main` (production) so Prodgator can show its promotion lineage. Nothing here is a real service: deploys are mocked, and the scan results in `fixtures/` are synthetic.

- `ci.yml`: tests with coverage and a SARIF scan report, sent to Prodgator by the report action (GitHub OIDC, no stored secret).
- `deploy.yml`: a mocked deploy on each push to `dev`, `uat` and `main`, into the GitHub environments `dev`, `uat` and `production`. A commit message with `[skip deploy]` skips it.
- `release.yml`: run by hand on `main` to tag a version and publish a release.

Walk-through: see `docs/runbooks/promotion-canary.md` in prodgator/prodgator.

## Demo automation

Two workflows run the dev to uat to main walk on their own.

- `demo-change.yml`: at 14:23 UTC, Monday to Friday, opens a small change pull request into `dev` and turns on auto-merge (squash). It skips the run when an automated change (a branch starting with `feat/auto-`) is already open. To run it by hand, go to Actions > demo-change > Run workflow and add a note if you want one.
- `promote.yml`: after a successful `deploy` run on `dev` or `uat`, opens or refreshes a pull request to the next branch (`dev` to `uat`, `uat` to `main`) and turns on auto-merge with a merge commit. It does nothing when the two branches already have the same content. Put `[skip promote]` in the head commit message of the source branch to stop a promotion. A change deployed with `[skip deploy]` is not promoted automatically, because its deploy run is skipped and there is no deployment to promote from. Promote it by hand with Actions > promote > Run workflow (from: `dev` or `uat`).

Both use a GitHub App token, because pull requests opened or merged with the default token do not start other workflows. Set the repository variable `CANARY_APP_CLIENT_ID` and the repository secret `CANARY_APP_PRIVATE_KEY` to turn them on. Until both exist, each run prints one notice and does nothing.

The schedule and the `deploy` trigger only use the copies of these workflows on `main`, so they start working once the workflows have been promoted to `main`.
