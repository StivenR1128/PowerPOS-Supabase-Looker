# Parámetros reales de conexión

| Parámetro | Valor |
|---|---|
| Proyecto | PowerPOS-Supabase-Looker, cuenta universitaria |
| Ref | ohtcxzjpdmadwdkbfodi |
| API Supabase | https://ohtcxzjpdmadwdkbfodi.supabase.co |
| Host | aws-0-us-east-2.pooler.supabase.com |
| Base | postgres |
| Usuario backend | powerpos_app.ohtcxzjpdmadwdkbfodi |
| Puerto backend Vercel | 6543, transaccional |
| Usuario BI | powerpos_looker.ohtcxzjpdmadwdkbfodi |
| Puerto Looker | 5432, sesión |
| TLS | Habilitado; sslmode=require para Prisma, CA del pooler para Looker |
| Contraseñas | Configuradas en los servicios; entrega privada separada |

La credencial de aplicación permanece en el servidor. No se usa service_role en el navegador. El rol BI solo consulta la vista aislada reporting.ventas de la empresa ficticia 1; no lee usuarios, contraseñas ni datos personales de clientes.

La cadena backend incluye pgbouncer=true, connection_limit=1, pool_timeout=30 y connect_timeout=30. Para SQL administrativo y Looker se mantiene el puerto 5432. No cambiar contraseñas sin actualizar también Vercel y la fuente Looker.

Referencia: [Prisma y Supabase](https://supabase.com/docs/guides/database/prisma).
