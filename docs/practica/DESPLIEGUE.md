# Despliegue real e independiente

Repositorio: https://github.com/StivenR1128/PowerPOS-Supabase-Looker

Frontend: https://powerpos-ucaldas34265.vercel.app

API: https://powerpos-api-ucaldas34265.vercel.app

Se crearon dos proyectos Vercel en la cuenta universitaria, sin seleccionar un plan de pago. Ambos parten de este repositorio; el original no se modificó.

| Proyecto | Raíz | Framework |
|---|---|---|
| powerpos-api-ucaldas34265 | api | NestJS, soporte nativo Vercel |
| powerpos-ucaldas34265 | web | Next.js |

Backend: DATABASE_URL privada con pooler transaccional 6543, TLS, pgbouncer=true y connection_limit=1. JWT_SECRET privado y CORS_ORIGINS limitado a la aplicación y localhost de desarrollo.

Frontend: NEXT_PUBLIC_API_URL y NEXT_PUBLIC_LOOKER_EMBED_URL configurados antes del build. Estos valores son públicos; ninguna contraseña PostgreSQL llega al navegador.

Los logos se guardan en PostgreSQL, con límite de 2 MB y validación del tipo de imagen. No dependen de un disco de Vercel.

El cierre automático de caja está desactivado por defecto para permitir demostraciones a cualquier hora. CIERRE_AUTOMATICO_CAJA=true lo habilita; requiere un servidor persistente y revisar el horario comercial. Las tareas cron y los eventos persistentes del proyecto original no deben suponerse disponibles continuamente en funciones serverless. No se usan para demostrar la persistencia HTTP exigida.

Cuenta ficticia: admin@powerpos.demo / Practica2026*. Abrir caja desde Dashboard con un monto inicial antes de registrar una venta. La base de caja no se cuenta como ingreso de ventas.

Ver ENTREGA.md y VERIFICACION-WEB.json para las pruebas y la limitación pendiente de representación de líneas y barras en Looker.
