// Ejecutar contra la API de la base ficticia, después de configurar Supabase.
// Crea un producto QA, lo edita, lee y da de baja; crea una venta identificable.
import assert from 'node:assert/strict';
const base = process.env.POWERPOS_API_URL || 'http://localhost:3000';
const password = process.env.POWERPOS_DEMO_PASSWORD;
if (!password) throw new Error('Configura POWERPOS_DEMO_PASSWORD para la cuenta ficticia');
let token;
async function request(route, method = 'GET', body) {
  const result = await fetch(base + route, { signal: AbortSignal.timeout(15000), method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) }, ...(body ? { body: JSON.stringify(body) } : {}) });
  const text = await result.text();
  if (!result.ok) throw new Error(`${method} ${route}: ${result.status} ${text}`);
  return text ? JSON.parse(text) : null;
}
const login = await request('/auth/login','POST',{ email: 'admin@powerpos.demo', password });
token = login.access_token;
assert(token);
assert.equal(login.usuario.empresaId,1,'Este smoke está reservado a la empresa ficticia del seed');
const categories = await request('/categorias');
const stamp = Date.now();
const product = await request('/productos','POST',{ nombre: 'QA persistencia ' + stamp, precio: 9500, categoriaId: categories[0].id, aceptaAdicionales:false });
assert(product.id);
await request('/productos/' + product.id,'PATCH',{nombre:'QA editado ' + stamp,precio:10500});
const persisted = await request('/productos/' + product.id);
assert.equal(persisted.nombre,'QA editado ' + stamp);
assert.equal(Number(persisted.precio),10500);
const caja = await request('/caja/abierta');
if (!caja?.id) throw new Error('Abre una caja a nombre de Admin Demo en Centro antes de probar la venta');
const pedido = await request('/pedidos','POST',{ sucursalId:1, metodoPago:'EFECTIVO', observacion:'QA persistencia '+stamp, items:[{productoId:product.id,cantidad:2,exclusiones:[],adicionales:[]}] });
assert(pedido.id);
assert.equal(Number(pedido.total),21000);
const ventas = await request('/pedidos');
assert(ventas.some(p => p.id === pedido.id),'Venta no aparece en lectura posterior');
await request('/productos/' + product.id,'DELETE');
const catalog = await request('/productos');
assert(!catalog.some(p => p.id === product.id),'Producto dado de baja sigue en catálogo activo');
console.log(JSON.stringify({ result:'PASS HTTP',productoId:product.id,pedidoId:pedido.id,numero:pedido.numero,total:pedido.total,nota:'Confirmar estos IDs en Supabase y en la interfaz; una prueba HTTP no sustituye la prueba visual.' },null,2));
