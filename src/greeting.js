export function greeting(name = 'world') {
  const who = String(name).trim() || 'world';
  return `Hello, ${who}!`;
}
