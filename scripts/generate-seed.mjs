import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
fs.mkdirSync(path.join(root, 'database'), { recursive: true });
const raw = sql => ({ sql });
const quote = v => v === undefined ? 'DEFAULT' : v === null ? 'NULL' : v && typeof v === 'object' && 'sql' in v ? v.sql : typeof v === 'number' || typeof v === 'boolean' ? String(v) : `'${String(v).replaceAll("'", "''")}'`;
const day = (n, hour = 12) => raw(`(CURRENT_DATE - ${n}) + INTERVAL '${hour} hours'`);
const tables = new Map();
const add = (table, row) => { if (!tables.has(table)) tables.set(table, []); tables.get(table).push(row); };
// Password exclusively for fictitious classroom accounts: Practica2026*
const hash = '$2b$10$sj3m6mQpu9kGaX8PmC0M1.onbD8izPuNkCicUPPtKyVSlwEBA.EAG';
add('empresas', { id: 1, nombre: 'PowerPOS Demo Académica', nit: 'DEMO-2026-001', email: 'demo@example.com', plan: 'PREMIUM', tiendaSlug: 'powerpos-demo', actualizadoEn: day(0), consumoEmpleadosHabilitado: true });
add('empresas', { id: 2, nombre: 'Empresa de prueba aislada', nit: 'DEMO-2026-002', email: 'aislada@example.com', tiendaSlug: 'empresa-aislada', actualizadoEn: day(0) });
for (let i = 1; i <= 3; i++) add('sucursales', { id: i, empresaId: 1, nombre: ['Centro', 'Norte', 'Sur'][i - 1] });
add('sucursales', { id: 4, empresaId: 2, nombre: 'Sucursal aislada' });
for (let i = 1; i <= 5; i++) add('usuarios', { id: i, empresaId: 1, sucursalId: 1, nombre: ['Admin Demo', 'Gerente Demo', 'Cajero Demo', 'Cocinero Demo', 'Domiciliario Demo'][i - 1], email: ['admin', 'gerente', 'cajero', 'cocina', 'domiciliario'][i - 1] + '@powerpos.demo', password: hash, rol: ['ADMIN_EMPRESA', 'GERENTE', 'CAJERO', 'COCINERO', 'DOMICILIARIO'][i - 1], actualizadoEn: day(0) });
add('usuarios', { id: 6, empresaId: 2, sucursalId: 4, nombre: 'Admin aislado', email: 'aislado@powerpos.demo', password: hash, rol: 'ADMIN_EMPRESA', actualizadoEn: day(0) });
for (let i = 1; i <= 5; i++) add('categorias', { id: i, empresaId: 1, nombre: ['Hamburguesas', 'Perros calientes', 'Bebidas', 'Acompañamientos', 'Postres'][i - 1] });
add('categorias', { id: 6, empresaId: 2, nombre: 'Catálogo aislado' });
const names = ['Hamburguesa clásica', 'Hamburguesa doble', 'Hamburguesa de pollo', 'Hamburguesa vegetariana', 'Perro clásico', 'Perro especial', 'Perro doble', 'Perro con queso', 'Gaseosa', 'Agua', 'Limonada', 'Jugo natural', 'Papas pequeñas', 'Papas grandes', 'Aros de cebolla', 'Nachos', 'Brownie', 'Helado', 'Torta', 'Galletas'];
const prices = [14000, 22000, 18000, 17000, 10000, 16000, 19000, 13000, 4000, 3000, 6000, 7000, 6000, 10000, 8000, 12000, 6500, 5500, 8000, 4000];
for (let i = 1; i <= 20; i++) add('productos', { id: i, empresaId: 1, categoriaId: Math.ceil(i / 4), nombre: names[i - 1], precio: prices[i - 1], costo: prices[i - 1] * .4, actualizadoEn: day(0) });
add('productos', { id: 21, empresaId: 2, categoriaId: 6, nombre: 'Producto aislado', precio: 9999, actualizadoEn: day(0) });
for (let i = 1; i <= 12; i++) add('ingredientes', { id: i, empresaId: 1, nombre: ['Pan', 'Carne', 'Pollo', 'Queso', 'Lechuga', 'Tomate', 'Salchicha', 'Papas', 'Salsa', 'Cebolla', 'Tocineta', 'Harina'][i - 1], unidad: 'porciones', stock: 9940, stockMinimo: 100, costoUnitario: 500 + i * 70 });
for (let i = 1; i <= 20; i++) for (let j = 0; j < 3; j++) add('producto_ingredientes', { id: (i - 1) * 3 + j + 1, productoId: i, ingredienteId: (i + j - 1) % 12 + 1, cantidad: 1 });
for (let i = 1; i <= 6; i++) {
  add('adicionales', { id: i, empresaId: 1, nombre: 'Extra ' + i, precio: 1000 + i * 500, ingredienteId: i, cantidad: 1, actualizadoEn: day(0) });
  add('preparaciones', { id: i, empresaId: 1, nombre: 'Preparación base ' + i });
}
for (let i = 1; i <= 20; i++) for (let j = 0; j < 3; j++) add('producto_adicionales', { id: (i - 1) * 3 + j + 1, productoId: i, adicionalId: (i + j - 1) % 6 + 1 });
for (let i = 1; i <= 60; i++) {
  add('clientes', { id: i, empresaId: 1, nombre: 'Cliente ficticio ' + i, documento: 'DEMO-' + i, email: `cliente${i}@example.com` });
  add('preparacion_ingredientes', { id: i, preparacionId: (i - 1) % 6 + 1, ingredienteId: Math.floor((i - 1) / 6) + 1, cantidad: 1 + i % 3 });
  add('lotes_preparacion', { id: i, empresaId: 1, preparacionId: (i - 1) % 6 + 1, usuarioId: 4, fecha: day(61 - i, 8), loteNumero: 'DEMO-LOTE-' + i, cantidadProducida: 10 + i % 7 });
  add('lote_preparacion_ingredientes', { id: i, loteId: i, ingredienteId: (i - 1) % 12 + 1, cantidadUsada: 5 + i % 4 });
}
for (let i = 1; i <= 20; i++) for (let j = 0; j < 3; j++) add('producto_preparaciones', { id: (i - 1) * 3 + j + 1, productoId: i, preparacionId: (i + j - 1) % 6 + 1, cantidad: 1 });
const cajaTotals = Array(61).fill(0);
let detalleId = 0;
let adicionalId = 0;
let financialId = 0;
for (let i = 1; i <= 180; i++) {
  const caja = Math.floor((i - 1) / 3) + 1;
  const age = 61 - caja;
  const productoA = i % 5 === 0 ? i % 20 + 1 : i % 8 + 1;
  const productoB = 9 + i % 12;
  const quantity = 1 + i % 3;
  const extra = i <= 60 ? (i - 1) % 6 + 1 : null;
  const extraPrice = extra ? 1000 + extra * 500 : 0;
  const totalA = (prices[productoA - 1] + extraPrice) * quantity;
  const totalB = prices[productoB - 1];
  const subtotal = totalA + totalB;
  const discount = i % 7 === 0 ? 2000 : 0;
  const state = i % 17 === 0 ? 'ANULADO' : i % 13 === 0 ? 'LISTO' : 'ENTREGADO';
  const branch = caja % 10 === 0 ? 3 : caja % 4 === 0 ? 2 : 1;
  const metodo = i % 10 < 6 ? 'EFECTIVO' : i % 10 < 8 ? 'NEQUI' : i % 10 === 8 ? 'TARJETA' : 'TRANSFERENCIA';
  add('pedidos', { id: i, sucursalId: branch, usuarioId: 1, clienteId: (i - 1) % 60 + 1, cajaId: caja, numero: 'DEMO-' + String(i).padStart(5, '0'), estado: state, metodoPago: metodo, subtotal, descuento: discount, total: subtotal - discount, creadoEn: day(age, 11 + i % 9), actualizadoEn: day(age, 12 + i % 9), observacion: 'Venta ficticia para la práctica' });
  add('detalle_pedidos', { id: ++detalleId, pedidoId: i, productoId: productoA, cantidad: quantity, precioUnitario: prices[productoA - 1], subtotal: totalA, exclusiones: raw("ARRAY[]::text[]") });
  if (extra) add('detalle_pedido_adicionales', { id: ++adicionalId, detallePedidoId: detalleId, adicionalId: extra, nombre: 'Extra ' + extra, precio: extraPrice, cantidad: 1, subtotal: extraPrice * quantity });
  add('detalle_pedidos', { id: ++detalleId, pedidoId: i, productoId: productoB, cantidad: 1, precioUnitario: prices[productoB - 1], subtotal: totalB, exclusiones: raw("ARRAY[]::text[]") });
  if (state !== 'ANULADO') {
    cajaTotals[caja] += subtotal - discount;
    add('movimientos_financieros', { id: ++financialId, empresaId: 1, sucursalId: branch, usuarioId: 1, tipo: 'INGRESO', categoria: 'VENTA', descripcion: 'Venta DEMO-' + String(i).padStart(5, '0'), monto: subtotal - discount, fecha: day(age, 12 + i % 9), pedidoId: i });
  }
}
for (let i = 1; i <= 60; i++) {
  const branch = i % 10 === 0 ? 3 : i % 4 === 0 ? 2 : 1;
  add('cajas', { id: i, sucursalId: branch, usuarioId: 1, estado: 'CERRADA', montoInicial: 100000, montoFinal: 100000 + cajaTotals[i], diferencia: 0, abiertaEn: day(61 - i, 8), cerradaEn: day(61 - i, 23) });
  add('eventos_caja', { id: i, cajaId: i, usuarioId: 1, tipo: 'CIERRE', descripcion: 'Cierre de caja ficticia sin diferencia', creadoEn: day(61 - i, 23) });
  add('movimientos_financieros', { id: ++financialId, empresaId: 1, sucursalId: branch, usuarioId: 1, tipo: 'EGRESO', categoria: i % 4 ? 'COMPRA_INSUMOS' : 'SERVICIOS', descripcion: 'Gasto ficticio ' + i, monto: 10000 + i % 8 * 3500, fecha: day(61 - i, 9) });
  add('consumos_empleados', { id: i, empresaId: 1, sucursalId: branch, usuarioId: 4, empleadoNombre: 'Empleado ficticio ' + (i % 5 + 1), creadoEn: day(61 - i, 13) });
  add('consumo_empleado_items', { id: i, consumoEmpleadoId: i, productoId: i % 20 + 1, cantidad: 1, precioReferencia: prices[i % 20] });
  add('auditorias', { id: i, empresaId: 1, usuarioId: 1, accion: 'CIERRE_CAJA', entidad: 'cajas', entidadId: i, detalle: raw(`'${JSON.stringify({ origen: 'seed académico', diferencia: 0 })}'::jsonb`), creadoEn: day(61 - i, 23) });
  const webTotal = prices[0] + 3000;
  add('pedidos_web', { id: `00000000-0000-4000-8000-${String(i).padStart(12, '0')}`, empresaId: 1, sucursalId: branch, clave: 'DEMO-WEB-' + i, estado: i % 4 === 0 ? 'RECHAZADO' : 'RECIBIDO', nombre: 'Cliente web ficticio ' + i, telefono: 'DEMO-NO-CONTACTAR', direccion: 'Dirección ficticia', zona: 'Zona ' + (i % 3 + 1), items: raw(`'${JSON.stringify([{ productoId: 1, cantidad: 1 }])}'::jsonb`), subtotal: prices[0], costoDomicilio: 3000, total: webTotal, actualizadoEn: day(61 - i, 14), creadoEn: day(61 - i, 14), metodoPago: 'EFECTIVO' });
}
add('cajas', { id: 61, sucursalId: 1, usuarioId: 1, estado: 'ABIERTA', montoInicial: 100000, montoFinal: null, diferencia: null, abiertaEn: day(0, 8), cerradaEn: null });
for (let ing = 1; ing <= 12; ing++) for (let i = 1; i <= 60; i++) add('movimientos_inventario', { id: (ing - 1) * 60 + i, ingredienteId: ing, productoId: null, usuarioId: 1, tipo: 'SALIDA', cantidadMovida: 1, stockAnterior: 10001 - i, stockNuevo: 10000 - i, descripcion: 'Ajuste histórico ficticio', creadoEn: day(61 - i, 10) });
// Dependency order; empty database is mandatory and prevents destructive seeding.
const order = ['empresas','sucursales','usuarios','categorias','productos','ingredientes','producto_ingredientes','adicionales','producto_adicionales','preparaciones','preparacion_ingredientes','lotes_preparacion','lote_preparacion_ingredientes','producto_preparaciones','clientes','cajas','pedidos','detalle_pedidos','detalle_pedido_adicionales','eventos_caja','movimientos_financieros','consumos_empleados','consumo_empleado_items','auditorias','pedidos_web','movimientos_inventario'];
let sql = `-- Datos completamente ficticios. Ejecutar SOLO en la base nueva y vacía.\nBEGIN;\nSET LOCAL TIME ZONE 'America/Bogota';\nDO $$ BEGIN IF EXISTS(SELECT 1 FROM public.empresas) THEN RAISE EXCEPTION 'Seed cancelado: la base ya contiene empresas. No se elimina ningún dato.'; END IF; END $$;\n`;
for (const table of order) {
  const rows = tables.get(table);
  const columns = Object.keys(rows[0]);
  sql += `\n-- ${table}: ${rows.length} filas\nINSERT INTO public."${table}" (${columns.map(c => `"${c}"`).join(',')}) VALUES\n${rows.map(row => '(' + columns.map(c => quote(row[c])).join(',') + ')').join(',\n')};\n`;
  if (typeof rows[0].id === 'number') sql += `SELECT setval(pg_get_serial_sequence('public.${table}', 'id'), (SELECT MAX(id) FROM public."${table}"), true);\n`;
}
sql += '\nCOMMIT;\n';
fs.writeFileSync(path.join(root, 'database/seed.sql'), sql);
fs.writeFileSync(path.join(root, 'database/seed-manifest.json'), JSON.stringify(Object.fromEntries(order.map(t => [t, tables.get(t).length])), null, 2));
console.log('Seed generado:', Object.fromEntries(order.map(t => [t, tables.get(t).length])));
