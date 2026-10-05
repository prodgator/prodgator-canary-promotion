# Release policy for the dev and uat gates: passes every deployment, so the
# deployment record and its lineage are the point of those two environments.

# METADATA
# title: "Promotion canary lower environments auto-pass"
# description: "Approves every deployment to dev and uat."
# custom:
#   spindle:
#     format: 1
#     mode: "enforce"
#     bindings:
#       - environment: "dev"
#         workflow: "deploy.yml"
#       - environment: "uat"
#         workflow: "deploy.yml"
package spindle.policy

results := [{
	"rule": "lower_envs_auto_pass",
	"status": "pass",
	"blocking": true,
	"reason": "Lower environments always pass.",
	"evidence": {},
}]
