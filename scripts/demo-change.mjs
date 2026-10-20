// Rewrites the lastChange line in src/greeting.js and the test that checks it.
// Used by the demo-change workflow. Reads NOTE and DATE (default: today, UTC).
import { readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const GREETING = 'src/greeting.js';
const CHANGE_TEST = 'test/last-change.test.js';
const LINE = /^export const lastChange = .*;$/gm;

export function cleanNote(raw, fallback) {
  const kept = String(raw ?? '')
    .replace(/[^A-Za-z0-9 .,:;!?()#/_'-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 80)
    .trim();
  return kept || fallback;
}

export function applyChange(source, { date, note }) {
  const matches = source.match(LINE) ?? [];
  if (matches.length !== 1) {
    throw new Error(`Expected exactly one lastChange line in ${GREETING}, found ${matches.length}.`);
  }
  const line = `export const lastChange = { date: ${JSON.stringify(date)}, note: ${JSON.stringify(note)} };`;
  return source.replace(LINE, () => line);
}

export function changeTestSource({ date, note }) {
  return `import { test } from 'node:test';
import assert from 'node:assert/strict';
import { lastChange } from '../src/greeting.js';

test('records the last automated change', () => {
  assert.deepEqual(lastChange, { date: ${JSON.stringify(date)}, note: ${JSON.stringify(note)} });
});
`;
}

/* c8 ignore start */
function main() {
  const date = process.env.DATE || new Date().toISOString().slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) throw new Error(`DATE must be YYYY-MM-DD, got "${date}".`);
  const note = cleanNote(process.env.NOTE, 'Demo change');
  writeFileSync(GREETING, applyChange(readFileSync(GREETING, 'utf8'), { date, note }));
  writeFileSync(CHANGE_TEST, changeTestSource({ date, note }));
  console.log(`Set lastChange to ${date}: ${note}`);
  console.log(`Updated ${GREETING} and ${CHANGE_TEST}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
/* c8 ignore stop */
