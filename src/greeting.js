export function greeting(name = 'world') {
  const who = String(name).trim().replace(/\s+/g, ' ') || 'world';
  return `Hello, ${who}!`;
}
