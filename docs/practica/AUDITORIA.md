# Auditoría del modelo y adecuación

## Proyecto y alcance

Origen: PowerPos-Pioneers, commit `fca5fad`. Backend NestJS 11 + Prisma 5.22, PostgreSQL; frontend Next.js 16.2.9. Se conserva la lógica de negocio y se trabaja en una copia con remoto de subida al original bloqueado.

## Hallazgos y cambios

| Criterio | Hallazgo | Adecuación |
|---|---|---|
| Entidades | 26 modelos relacionales | Se conserva el modelo completo |
| PK/FK | PK en todos los modelos y FK explícitas | SQL generado desde Prisma |
| Borrado/actualización | RESTRICT, SET NULL y CASCADE en las FK | Se mantienen: ventas e inventario no deben borrarse en cascada |
| Índices | Pocos índices explícitos por FK | Índices para columnas referenciadoras |
| Unicidad | NIT, email, número de pedido y puentes de productos | Se conserva y se refuerzan dos puentes de preparación |
| Importes | Decimal(10,2), pero faltan CHECK | CHECK de precios, cantidades, total de pedido y objetivos de inventario |
| Seed | Catálogo pequeño; eliminación masiva | Datos académicos, transacción y rechazo de base ya poblada |
| Seguridad | Backend JWT; conexión local | TLS privado, RLS y roles diferenciados, CORS configurable, JWT obligatorio |
| BI | Recharts, sin Looker | Vista sin PII y contenedor iframe en ambos dashboards |

## Normalización

El núcleo relacional permite identificar al menos diez tablas con atributos escalares y relaciones independientes: empresas, sucursales, usuarios, categorías, productos, ingredientes, producto_ingredientes, clientes, cajas y movimientos_financieros. Las tablas puente resuelven relaciones N:M y evitan repetir listas de productos o ingredientes como columnas. Los datos descriptivos de empresa, categoría, usuario y producto se almacenan en su entidad y se relacionan mediante claves.

No se afirma que todo el sistema original esté en tercera forma normal estricta. Hay excepciones deliberadas que se conservan por compatibilidad:

- `detalle_pedidos.exclusiones` es un arreglo PostgreSQL; no cumple el criterio clásico de valores atómicos. No es fuente del informe BI.
- `pedidos_web.items` y configuraciones son JSON: representan solicitudes y configuración, no la tabla normalizada de ventas.
- `subtotal`, `total`, precio y nombre históricos de adicionales preservan los valores de una venta; son snapshots/derivaciones documentadas.
- Empresa aparece en algunas entidades además de poder inferirse por sucursal. La API comprueba la empresa; las FK simples no imponen por sí mismas todas las restricciones de pertenencia entre empresas.

El DER completo documenta las 26 entidades. Si el docente exige que absolutamente todas las columnas sean 1NF/3NF estricta, se debe acordar normalizar también esos campos multivalor; el mínimo de tablas normalizadas ya está cubierto por el núcleo descrito.

## Acceso y límites

`powerpos_app` tiene CRUD para el backend. Las políticas no usan `auth.uid()` porque el sistema conserva su JWT de NestJS y una conexión PostgreSQL del servidor. El aislamiento empresarial depende de la autorización de la API; RLS impide usar roles públicos para acceder a tablas.

`powerpos_looker` solo puede consultar `reporting.ventas`, restringida a empresa 1. La vista usa permisos del propietario intencionalmente, en un esquema no expuesto a la Data API; no se dan permisos sobre las tablas operativas al lector. No compartir este informe con empresas reales distintas: se creó para datos ficticios de una única empresa.

## Verificación

SQL probado en PostgreSQL embebido con PGlite: 26 conteos, integridad de importes, RLS, denegación al lector BI y rol público, CRUD del backend y rechazo de segundo seed. El backend compila y pasan 5 suites/11 pruebas existentes. La prueba de conexión y persistencia en Supabase queda pendiente de la cuenta elegida. Consultar ENTREGA.md para el estado actual del frontend y las pruebas externas.
