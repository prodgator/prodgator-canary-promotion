import { test } from 'node:test';
import assert from 'node:assert/strict';
import { greeting } from '../src/greeting.js';

test('greets the world by default', () => {
  assert.equal(greeting(), 'Hello, world!');
});

test('greets a name', () => {
  assert.equal(greeting('Ada'), 'Hello, Ada!');
});

test('trims the name and falls back to the world', () => {
  assert.equal(greeting('  Ada '), 'Hello, Ada!');
  assert.equal(greeting('   '), 'Hello, world!');
});

test('collapses inner spaces in the name', () => {
  assert.equal(greeting('Ada   Lovelace'), 'Hello, Ada Lovelace!');
});

test('caps the name at 40 characters', () => {
  assert.equal(greeting('x'.repeat(50)), `Hello, ${'x'.repeat(40)}!`);
});

test('treats a null name as the world', () => {
  assert.equal(greeting(null), 'Hello, world!');
});
