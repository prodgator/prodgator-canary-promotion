import { test } from 'node:test';
import assert from 'node:assert/strict';
import { applyChange, cleanNote, changeTestSource } from '../scripts/demo-change.mjs';

const source = "export function greeting() {}\nexport const lastChange = { date: '2026-10-20', note: 'Initial content' };\n";

test('cleanNote keeps allowed characters and collapses whitespace', () => {
  assert.equal(cleanNote('  Fix   the (thing): ok!  ', 'x'), 'Fix the (thing): ok!');
});

test('cleanNote drops quotes, backticks and template injection', () => {
  const out = cleanNote('a"b`c${process.exit()}d\\e<f>', 'x');
  assert.doesNotMatch(out, /["`$\\{}<>]/);
});

test('cleanNote caps at 80 characters', () => {
  assert.equal(cleanNote('a'.repeat(200), 'x').length, 80);
});

test('cleanNote falls back when empty', () => {
  assert.equal(cleanNote('', 'fb'), 'fb');
  assert.equal(cleanNote(undefined, 'fb'), 'fb');
  assert.equal(cleanNote('"`${}', 'fb'), 'fb');
});

test('applyChange replaces the lastChange line', () => {
  const out = applyChange(source, { date: '2026-10-21', note: 'hello' });
  assert.match(out, /^export const lastChange = \{ date: "2026-10-21", note: "hello" \};$/m);
  assert.equal(out.match(/lastChange/g).length, 1);
});

test('applyChange keeps odd notes inside the string literal', () => {
  const note = "it's $1 \\ \"q\"";
  const out = applyChange(source, { date: '2026-10-21', note });
  const line = out.split('\n').find((l) => l.startsWith('export const lastChange'));
  const literal = line.match(/note: (".*") \};$/)[1];
  const value = { note: JSON.parse(literal) };
  assert.equal(value.note, note);
});

test('applyChange throws when the line is missing or repeated', () => {
  assert.throws(() => applyChange('const a = 1;\n', { date: 'd', note: 'n' }), /found 0/);
  assert.throws(() => applyChange(source + source, { date: 'd', note: 'n' }), /found 2/);
});

test('changeTestSource embeds the date and note', () => {
  const out = changeTestSource({ date: '2026-10-21', note: 'hello' });
  assert.match(out, /date: "2026-10-21", note: "hello"/);
});
