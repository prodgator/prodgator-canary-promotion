# Pull request policy for the promotion canary.
#
# Checks provenance only. A pull request waits until ci.yml has reported test
# results, coverage and a scan for its commit. The status of those reports is
# not judged here, so a change with a high finding can still merge and the
# release gate rejects it later. The promotion direction is informational
# (not blocking) so hotfix and skipped-uat changes can still merge and the
# release gate shows the concern.

# METADATA
# title: "Promotion canary pull requests"
# description: "Pull requests wait for test results, coverage and a scan from ci.yml. Branch direction is shown for information."
# custom:
#   prodgator:
#     format: 1
#     subjects: [pull_request]
#     mode: "enforce"
#     bindings:
#       - base: "dev"
#       - base: "uat"
#       - base: "main"
package prodgator.policy

ci_prefix := "prodgator/prodgator-canary-promotion/.github/workflows/ci.yml@"

required_kinds := {"test-results", "coverage", "scan"}

attestations_readable if is_array(input.attestations)

reported_kinds := {a.kind |
	some a in input.attestations
	a.trusted == true
	startswith(a.workflowRef, ci_prefix)
}

missing_kinds := required_kinds - reported_kinds

evidence := {"status": "error", "reason": "This policy only evaluates pull requests."} if {
	input.subject != "pull_request"
} else := {"status": "error", "reason": "Prodgator could not read the attestations for this commit."} if {
	not attestations_readable
} else := {"status": "pass", "reason": "Test results, coverage and a scan from ci.yml were reported for this commit."} if {
	count(missing_kinds) == 0
} else := {
	"status": "pending",
	"reason": sprintf("Waiting for ci.yml to report: %s.", [concat(", ", sort(missing_kinds))]),
}

refs_readable if {
	is_string(input.pullRequest.headRef)
	is_string(input.pullRequest.baseRef)
}

head := input.pullRequest.headRef

base := input.pullRequest.baseRef

direction := {"status": "error", "reason": "This policy only evaluates pull requests."} if {
	input.subject != "pull_request"
} else := {"status": "error", "reason": "Prodgator could not read the branches of this pull request."} if {
	not refs_readable
} else := {"status": "pass", "reason": "Back-merge from uat."} if {
	base == "dev"
	head == "uat"
} else := {"status": "pass", "reason": "Back-merge from main."} if {
	base == "dev"
	head == "main"
} else := {"status": "pass", "reason": "Change into dev."} if {
	base == "dev"
} else := {"status": "pass", "reason": "Promotion from dev."} if {
	base == "uat"
	head == "dev"
} else := {"status": "pass", "reason": "Back-merge from main."} if {
	base == "uat"
	head == "main"
} else := {"status": "fail", "reason": sprintf("Changes reach uat through dev. This pull request comes from %s.", [head])} if {
	base == "uat"
} else := {"status": "pass", "reason": "Promotion from uat."} if {
	base == "main"
	head == "uat"
} else := {"status": "fail", "reason": "Hotfix straight to main. The release gate checks the promotion path."} if {
	base == "main"
	startswith(head, "hotfix/")
} else := {"status": "fail", "reason": "This skips uat. The release gate checks the promotion path."} if {
	base == "main"
	head == "dev"
} else := {"status": "fail", "reason": sprintf("Changes reach main through uat. This pull request comes from %s.", [head])} if {
	base == "main"
} else := {"status": "pass", "reason": "Not a promotion branch."}

results := [
	{
		"rule": "report_evidence",
		"status": evidence.status,
		"blocking": true,
		"reason": evidence.reason,
	},
	{
		"rule": "promotion_direction",
		"status": direction.status,
		"blocking": false,
		"reason": direction.reason,
	},
]
