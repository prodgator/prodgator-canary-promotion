export function greeting(name = 'world') {
  const who = String(name).trim().replace(/\s+/g, ' ').slice(0, 40).trim() || 'world';
  return `Hello, ${who}!`;
}
