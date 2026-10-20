import { test } from 'node:test';
import assert from 'node:assert/strict';
import { lastChange } from '../src/greeting.js';

test('records the last automated change', () => {
  assert.deepEqual(lastChange, { date: "2026-10-20", note: "Initial content" });
});
