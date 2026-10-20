package prodgator.policy_test

import data.prodgator.policy

ci := "prodgator/prodgator-canary-promotion/.github/workflows/ci.yml@refs/pull/7/merge"

att(kind) := {"kind": kind, "name": kind, "status": "pass", "trusted": true, "workflowRef": ci}

all_three := [att("test-results"), att("coverage"), att("scan")]

pr(head, base, atts) := {
	"subject": "pull_request",
	"pullRequest": {"headRef": head, "baseRef": base},
	"attestations": atts,
}

evidence_row(inp) := row if {
	some row in policy.results with input as inp
	row.rule == "report_evidence"
}

direction_row(inp) := row if {
	some row in policy.results with input as inp
	row.rule == "promotion_direction"
}

test_all_three_trusted_pass if {
	row := evidence_row(pr("feature/x", "dev", all_three))
	row.status == "pass"
	row.blocking
	row.reason == "Test results, coverage and a scan from ci.yml were reported for this commit."
}

test_failing_status_still_counts if {
	failed := object.union(att("scan"), {"status": "fail"})
	row := evidence_row(pr("feature/x", "dev", [att("test-results"), att("coverage"), failed]))
	row.status == "pass"
}

test_untrusted_ignored if {
	untrusted := object.union(att("scan"), {"trusted": false})
	row := evidence_row(pr("feature/x", "dev", [att("test-results"), att("coverage"), untrusted]))
	row.status == "pending"
	row.reason == "Waiting for ci.yml to report: scan."
}

test_other_workflow_ignored if {
	other := object.union(att("coverage"), {"workflowRef": "prodgator/prodgator-canary-promotion/.github/workflows/deploy.yml@refs/heads/dev"})
	row := evidence_row(pr("feature/x", "dev", [att("test-results"), other, att("scan")]))
	row.status == "pending"
	row.reason == "Waiting for ci.yml to report: coverage."
}

test_other_repo_ignored if {
	other := object.union(att("coverage"), {"workflowRef": "someone/else/.github/workflows/ci.yml@refs/heads/dev"})
	row := evidence_row(pr("feature/x", "dev", [att("test-results"), other, att("scan")]))
	row.status == "pending"
}

test_missing_sorted if {
	row := evidence_row(pr("feature/x", "dev", [att("test-results")]))
	row.status == "pending"
	row.reason == "Waiting for ci.yml to report: coverage, scan."
}

test_no_attestations_lists_all if {
	row := evidence_row(pr("feature/x", "dev", []))
	row.status == "pending"
	row.reason == "Waiting for ci.yml to report: coverage, scan, test-results."
}

test_non_array_error if {
	inp := {"subject": "pull_request", "pullRequest": {"headRef": "a", "baseRef": "dev"}, "attestations": {"x": 1}}
	row := evidence_row(inp)
	row.status == "error"
	row.reason == "Prodgator could not read the attestations for this commit."
}

test_missing_attestations_error if {
	inp := {"subject": "pull_request", "pullRequest": {"headRef": "a", "baseRef": "dev"}}
	row := evidence_row(inp)
	row.status == "error"
}

test_release_subject_error if {
	inp := {"subject": "release", "attestations": all_three}
	row := evidence_row(inp)
	row.status == "error"
	row.reason == "This policy only evaluates pull requests."
}

test_dev_from_uat if {
	row := direction_row(pr("uat", "dev", all_three))
	row.status == "pass"
	row.reason == "Back-merge from uat."
	not row.blocking
}

test_dev_from_main if {
	row := direction_row(pr("main", "dev", all_three))
	row.status == "pass"
	row.reason == "Back-merge from main."
}

test_dev_from_feature if {
	row := direction_row(pr("feature/x", "dev", all_three))
	row.status == "pass"
	row.reason == "Change into dev."
}

test_uat_from_dev if {
	row := direction_row(pr("dev", "uat", all_three))
	row.status == "pass"
	row.reason == "Promotion from dev."
}

test_uat_from_main if {
	row := direction_row(pr("main", "uat", all_three))
	row.status == "pass"
	row.reason == "Back-merge from main."
}

test_uat_from_feature if {
	row := direction_row(pr("feature/x", "uat", all_three))
	row.status == "fail"
	not row.blocking
	row.reason == "Changes reach uat through dev. This pull request comes from feature/x."
}

test_main_from_uat if {
	row := direction_row(pr("uat", "main", all_three))
	row.status == "pass"
	row.reason == "Promotion from uat."
}

test_main_from_hotfix if {
	row := direction_row(pr("hotfix/urgent", "main", all_three))
	row.status == "fail"
	row.reason == "Hotfix straight to main. The release gate checks the promotion path."
}

test_main_from_dev if {
	row := direction_row(pr("dev", "main", all_three))
	row.status == "fail"
	row.reason == "This skips uat. The release gate checks the promotion path."
}

test_main_from_feature if {
	row := direction_row(pr("feature/x", "main", all_three))
	row.status == "fail"
	row.reason == "Changes reach main through uat. This pull request comes from feature/x."
}

test_other_base if {
	row := direction_row(pr("feature/x", "release/1", all_three))
	row.status == "pass"
	row.reason == "Not a promotion branch."
}

test_missing_refs_error if {
	inp := {"subject": "pull_request", "pullRequest": {"baseRef": "dev"}, "attestations": all_three}
	row := direction_row(inp)
	row.status == "error"
	not row.blocking
	row.reason == "Prodgator could not read the branches of this pull request."
}

test_release_subject_direction_error if {
	row := direction_row({"subject": "release"})
	row.status == "error"
}
