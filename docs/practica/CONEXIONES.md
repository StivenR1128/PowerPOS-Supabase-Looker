# Parámetros de conexión para la entrega

## Pendientes de la instancia real

| Parámetro | Valor |
|---|---|
| Proyecto Supabase | PowerPOS-Supabase-Looker · cuenta universitaria |
| Project ref | ohtcxzjpdmadwdkbfodi |
| API URL | `https://ohtcxzjpdmadwdkbfodi.supabase.co` |
| Host PostgreSQL/pooler | aws-0-us-east-2.pooler.supabase.com |
| Puerto de session pooler | 5432 |
| Base | postgres |
| Usuario aplicación | powerpos_app.ohtcxzjpdmadwdkbfodi para pooler; LOGIN pendiente |
| Usuario BI | powerpos_looker.ohtcxzjpdmadwdkbfodi para pooler; LOGIN pendiente |
| Contraseña | Entrega privada; no guardar aquí |
| TLS | Habilitado |

Para conexión directa los usuarios son `powerpos_app` y `powerpos_looker`, sin sufijo; copiar el host de Supabase y verificar conectividad IPv6. Session pooler facilita entornos IPv4. No usar el transaction pooler 6543 para Looker.

## Activar roles sin publicar secretos

En el SQL Editor, como propietario, crear dos contraseñas diferentes y ejecutar privadamente:

```sql
ALTER ROLE powerpos_app LOGIN PASSWORD 'REEMPLAZAR_PRIVADAMENTE';
ALTER ROLE powerpos_looker LOGIN PASSWORD 'REEMPLAZAR_PRIVADAMENTE';
```

No ejecutar esas sentencias con el texto de ejemplo. No guardar la versión con contraseñas en GitHub, capturas públicas o README. Las credenciales son para la instancia académica nueva, nunca para la base original.

La cadena del backend usa `sslmode=require`; codificar los caracteres especiales de la contraseña en una URL. Looker se configura con host, puerto, base, usuario y contraseña por separado, habilitando SSL y el certificado que pida el conector. Copiar el CA desde las opciones de conexión de Supabase si corresponde.

La Data API no se utiliza en esta arquitectura. `SUPABASE_URL` y una clave pública no sustituyen `DATABASE_URL`; no se necesita clave service_role ni secret key en el frontend. Si se mantiene habilitada la Data API, dejar `reporting` fuera de los esquemas expuestos.

Fuentes: [Prisma y Supabase](https://supabase.com/docs/guides/database/prisma), [conectar PostgreSQL](https://docs.cloud.google.com/looker/docs/studio/connect-to-postgresql).
