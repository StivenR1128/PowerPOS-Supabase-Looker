import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// Seed no destructivo: exige base nueva y vacía y el rol propietario.
function statements(sql: string): string[] {
  const result: string[] = [];
  let start = 0, quoted = false, dollar = false, comment = false;
  for (let i = 0; i < sql.length; i++) {
    if (comment) { if (sql[i] === '\n') comment = false; continue; }
    if (!quoted && !dollar && sql.slice(i, i + 2) === '--') { comment = true; i++; continue; }
    if (!quoted && sql.slice(i, i + 2) === '$$') { dollar = !dollar; i++; continue; }
    if (!dollar && sql[i] === "'") {
      if (quoted && sql[i + 1] === "'") { i++; continue; }
      quoted = !quoted;
    }
    if (!quoted && !dollar && sql[i] === ';') { result.push(sql.slice(start, i + 1)); start = i + 1; }
  }
  return result;
}
const prisma = new PrismaClient();
async function main() {
  const sql = readFileSync(resolve(__dirname, '../../database/seed.sql'), 'utf8');
  const commands = statements(sql).map(s => s.replace(/--[^\n]*/g, '').trim()).filter(s => s && !/^(BEGIN|COMMIT);$/i.test(s));
  await prisma.$transaction(async tx => {
    for (const command of commands) {
      if (/^SELECT\b/i.test(command)) await tx.$queryRawUnsafe(command);
      else await tx.$executeRawUnsafe(command);
    }
  }, { timeout: 120000 });
  console.log('Datos ficticios insertados. No se eliminó ningún registro.');
}
main().catch(e => { console.error(e.message); process.exitCode = 1; }).finally(() => prisma.$disconnect());
