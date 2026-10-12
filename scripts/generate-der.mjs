import fs from 'node:fs';
const schema = fs.readFileSync(new URL('../api/prisma/schema.prisma', import.meta.url), 'utf8');
const models = [...schema.matchAll(/model (\w+) \{([\s\S]*?)\n\}/g)];
const names = new Map(models.map(([, name, body]) => [name, body.match(/@@map\("([^"]+)"\)/)?.[1] || name]));
let diagram = 'erDiagram\n';
for (const [, name, body] of models) {
  diagram += `  ${names.get(name)} {\n`;
  for (const line of body.split('\n')) {
    const field = line.trim().match(/^(\w+)\s+(Int|String|Decimal|DateTime|Boolean|Json)(\??|\[\])(?:\s|$)(.*)/);
    if (!field || field[3] === '[]') continue;
    const [, col, type, optional, attrs] = field;
    const fk = new RegExp(`fields: \\[${col}\\]`).test(body);
    diagram += `    ${type} ${col}${attrs.includes('@id') ? ' PK' : fk ? ' FK' : ''}\n`;
  }
  diagram += '  }\n';
}
for (const [, name, body] of models) for (const relation of body.matchAll(/^\s*\w+\s+(\w+)(\??)\s+@relation\([^\n]*fields: \[([^\]]+)\]/gm)) {
  if (names.has(relation[1])) diagram += `  ${names.get(relation[1])} ${relation[2] ? '|o' : '||'}--o{ ${names.get(name)} : "${relation[3]}"\n`;
}
fs.mkdirSync(new URL('../docs/practica/', import.meta.url), { recursive: true });
fs.writeFileSync(new URL('../docs/practica/DER.mmd', import.meta.url), diagram);
fs.writeFileSync(new URL('../docs/practica/DER.md', import.meta.url), '# Diagrama entidad-relación\n\nModelo completo: 26 tablas. Las relaciones y claves se generan desde schema.prisma.\n\n```mermaid\n' + diagram + '```\n');
console.log('DER completo generado: ' + models.length + ' entidades');
