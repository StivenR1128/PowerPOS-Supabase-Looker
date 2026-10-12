# Estado real de entregables

| Entregable | Estado / enlace |
|---|---|
| Código en copia independiente | Preparado localmente |
| README y ejecución local | Preparados |
| DER | DER.md / DER.mmd: 26 tablas |
| schema.sql / seed.sql | Preparados y probados en PostgreSQL embebido |
| RLS y roles | security.sql probado localmente |
| Vista BI y consulta | analytics.sql y looker-query.sql probados |
| Iframe adaptable | Implementado en ambos dashboards |
| Backend | Build correcto; 5 suites / 11 pruebas pasan |
| Frontend | Build de producción webpack completo, TypeScript y generación de 21 páginas correctos |
| Instancia Supabase | Creada y poblada en cuenta universitaria: https://supabase.com/dashboard/project/ohtcxzjpdmadwdkbfodi |
| Persistencia web → Supabase | Pendiente: prueba en instancia real |
| Informe Looker con 3 gráficos y 2 filtros | Pendiente: acceso al navegador conectado y creación del informe |
| URL del repositorio nuevo | Pendiente |
| URL del proyecto desplegado | Pendiente |
| Parámetros reales de conexión | Host y ref confirmados; faltan credenciales privadas de aplicación/BI |
| Video demostrativo | Pendiente tras verificar servicios reales |

## Evidencias disponibles

`SQL-QA.json`: esquema y seed, 26 conteos, consistencia de pedidos, ingresos BI sin duplicaciones, RLS, permisos lector BI, denegación de rol público, CRUD del backend y rechazo de seed sobre datos existentes. Motor usado: PGlite, PostgreSQL embebido, no instancia Supabase.

La conexión de Supabase que existía al iniciar la adaptación pertenece a otra cuenta. No se crearon ni modificaron proyectos en esa cuenta. El repositorio original no recibió cambios ni pushes.

La sesión de navegador se verificó con `jose.rodas34265@ucaldas.edu.co`, organización `StivenR1128's Org`. Se creó el proyecto `PowerPOS-Supabase-Looker` (`ohtcxzjpdmadwdkbfodi`, us-east-2) y se ejecutaron schema, seed, security y analytics. Ver `SUPABASE-QA.txt`: 26 tablas, 180 pedidos, 360 detalles, 230 movimientos financieros, 720 movimientos de inventario, 26 tablas con RLS, 0 pedidos inconsistentes y diferencia de ingresos BI 0.00. Esto confirma la migración en la nube; todavía no confirma el flujo desde la interfaz web.

En este entorno de Windows, los compiladores necesitaron un ajuste temporal de resolución de rutas para completar la verificación. Ese ajuste queda en archivos de trabajo fuera del entregable; el proyecto conserva los comandos estándar de Node/Prisma/Next.js.

## Checklist para cerrar la entrega

- [x] Acceder a Supabase con el correo elegido y crear proyecto nuevo.
- [x] Ejecutar SQL y verificar conteos e integridad en Supabase.
- [ ] Revisar los asesores de Supabase tras la migración.
- [ ] Activar credenciales privadas y conexión del backend.
- [ ] Verificar creación, lectura, edición y baja desde la interfaz con evidencia de persistencia.
- [ ] Crear fuente PostgreSQL y el informe real de Looker.
- [ ] Probar gráficos y al menos dos filtros dentro del iframe.
- [ ] Publicar repositorio nuevo y servicios web/API.
- [ ] Registrar enlaces reales, accesos y video.

Este checklist distingue lo implementado de lo pendiente; no es evidencia de una entrega completa.
