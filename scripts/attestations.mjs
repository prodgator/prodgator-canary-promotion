// Writes attestations.json for the Prodgator report action: line coverage from
// c8's json-summary and a SARIF scan. Set SCAN_FILE to try the high finding.
import { readFileSync, writeFileSync } from 'node:fs';

const summary = JSON.parse(readFileSync('coverage/coverage-summary.json', 'utf8'));
const lines = summary.total.lines.pct;
const file = process.env.SCAN_FILE || 'fixtures/scan.sarif';

const attestations = [
  { kind: 'coverage', name: 'coverage', data: { lines, threshold: 80 } },
  { kind: 'scan', name: 'promotion-canary-sarif', file, format: 'sarif', data: { tool: 'fixture', failOn: 'high' } },
];

writeFileSync('attestations.json', JSON.stringify(attestations, null, 2) + '\n');
console.log(`coverage ${lines}%, scan ${file}`);
