export function greeting(name = 'world') {
  const who = String(name ?? 'world').trim().replace(/\s+/g, ' ').slice(0, 40).trim().replace(/!+$/, '') || 'world';
  return `Hello, ${who}!`;
}
