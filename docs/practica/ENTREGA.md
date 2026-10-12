# Entrega y estado verificado — 12 octubre 2026

| Entregable | Estado / enlace |
|---|---|
| Repositorio independiente | https://github.com/StivenR1128/PowerPOS-Supabase-Looker |
| Aplicación desplegada | https://powerpos-ucaldas34265.vercel.app |
| API desplegada | https://powerpos-api-ucaldas34265.vercel.app |
| Supabase universitario | https://supabase.com/dashboard/project/ohtcxzjpdmadwdkbfodi |
| Informe Looker | https://datastudio.google.com/reporting/f1f02891-9021-4b2b-a489-519206715977/page/423AG |
| Video de capturas reales | [PowerPOS-demostracion.mp4](media/PowerPOS-demostracion.mp4) |
| README y ejecución local | README.md |
| DER | DER.md / DER.mmd: 26 tablas |
| SQL | database/schema.sql, seed.sql, security.sql, analytics.sql y verify.sql |
| Persistencia desde interfaz | Creación, lectura, edición y baja de producto; venta 181 confirmada |
| Filtros incrustados | Categoría y rango de fechas comprobados dentro de la aplicación |
| Tres tipos de gráficos | KPI, serie temporal y barras configurados. KPI visible; líneas y barras siguen en blanco en Codex |

## Pruebas en la nube

Migración inicial: 26 tablas con RLS, 180 pedidos, 360 detalles, 230 movimientos financieros y 720 movimientos de inventario. Cero pedidos inconsistentes; diferencia de ingresos BI 0.00. Ver SUPABASE-QA.txt. El seed contiene 60 días y distribuciones asimétricas, no borra datos existentes.

Desde la interfaz publicada se creó el producto 22, Producto demostración UCalDas, a 9500; se editó a 10500; se dio de baja. Supabase confirmó precio 10500.00 y activo=false. La baja conserva el registro.

Se creó desde el POS el pedido 181, número PED-1-17c59d9e-5af2-4ab0-88a6-25c84aa58cd5, una unidad de Agua, total 3000.00, estado PENDIENTE. Se confirmó en Pedidos recientes y en SQL Editor. Looker actualizado pasó de 6604000 a 6607000.

Prueba dentro del iframe: categoría Bebidas → 388835.45; Bebidas + 1 a 11 octubre de 2026 → 37555.56. Ambos controles modifican el KPI. El informe usa el conector PostgreSQL nativo, TLS y un rol de lectura limitado a reporting.ventas.

## Limitación pendiente

Los componentes de líneas y barras están creados en el informe, pero sus marcos de representación aparecen en blanco en el navegador de Codex. El KPI y ambos filtros sí cargan. No se presenta la configuración como prueba de que los tres gráficos se visualizan correctamente. Esta parte debe resolverse antes de considerar cumplida toda la práctica.

## Validación y operación

Backend compilado; 5 suites y 11 pruebas pasan. Frontend: build webpack de producción, TypeScript y 21 páginas correctos. SQL-QA.json corresponde a PostgreSQL embebido; SUPABASE-QA.txt y las pruebas de interfaz corresponden a la instancia real.

Vercel usa el pooler transaccional 6543, pgbouncer=true y connection_limit=1 para evitar agotar sesiones. Looker usa session pooler 5432. El cierre automático de caja queda desactivado por defecto; CIERRE_AUTOMATICO_CAJA=true lo habilita en un servidor persistente con horario comercial adecuado. Los logos se guardan en PostgreSQL para sobrevivir al entorno de Vercel.

Las contraseñas de base de datos no están en GitHub ni en el video. Los parámetros públicos están en CONEXIONES.md; los secretos se entregan en un archivo privado separado del repositorio. El repositorio original permanece intacto.
