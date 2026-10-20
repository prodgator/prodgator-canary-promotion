export function greeting(name = 'world') {
  const who = String(name).trim() || 'world';
  return `Hello, ${who}!`;
}

// The demo-change workflow rewrites this line on each automated change.
export const lastChange = { date: "2026-10-20", note: "Initial content" };
