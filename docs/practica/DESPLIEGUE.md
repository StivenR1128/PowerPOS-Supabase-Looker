# Publicación independiente

## Repositorio

Crear un repositorio vacío NUEVO, por ejemplo `PowerPOS-Supabase-Looker`. No inicializarlo con README si se va a subir esta copia. En la carpeta de la copia:

Si descargaste el ZIP, este excluye `.git`: primero ejecutar `git init -b practica-supabase-looker`. La copia local de trabajo sí conserva su rama y el remoto de lectura bloqueado.

```powershell
git remote -v
git status
git add .
git commit -m "Adaptación académica a Supabase y Looker Studio"
git remote add origin https://github.com/TU_USUARIO/PowerPOS-Supabase-Looker.git
git push -u origin practica-supabase-looker
```

No ejecutar el ejemplo sin sustituir TU_USUARIO. Revisar los archivos antes del commit: excluir `.env`, `node_modules`, compilados, uploads y secretos. El remoto `source-original` sirve para consultar la procedencia y tiene push bloqueado.

## Backend y frontend

Desplegar como dos servicios Node compatibles; pueden vivir en el mismo proveedor o separados. No se ha elegido un proveedor de pago ni aceptado cargos.

| Servicio | Directorio raíz | Build | Inicio |
|---|---|---|---|
| API | api | `npm ci && npx prisma generate && npm run build` | `npm run start:prod` |
| Web | web | `npm ci && npm run build -- --webpack` | `npm run start` |

API: configurar `DATABASE_URL`, `JWT_SECRET`, `PORT` del proveedor y `CORS_ORIGINS=https://URL_REAL_WEB`. Web: configurar `NEXT_PUBLIC_API_URL=https://URL_REAL_API` y `NEXT_PUBLIC_LOOKER_EMBED_URL` real **antes de compilar**. El proveedor debe permitir el puerto saliente del pooler y TLS. La API debe ser un servidor persistente compatible con la aplicación, no una conversión improvisada a funciones serverless.

Los uploads del sistema original se guardan en disco: usar volumen persistente si se van a demostrar imágenes cargadas. La demo SQL no necesita imágenes ni servicios opcionales de SMS/correo. No activar esos servicios sin configurarlos.

## Prueba después del despliegue

1. Abrir frontend HTTPS e iniciar sesión con la cuenta ficticia.
2. Registrar producto y editarlo; confirmar en Supabase.
3. Eliminar el producto desde la UI y verificar su baja lógica (`activo=false`), según la lógica original.
4. Registrar una venta desde POS con caja abierta; confirmar pedido, detalles e ingreso financiero.
5. Recargar la página: los datos deben seguir presentes.
6. Abrir dashboard y usar los filtros del informe real.
7. Probar ancho móvil y que no haya desbordamiento horizontal de la página.
8. Entrar con la empresa aislada y comprobar que no accede al catálogo o pedidos de la empresa demo. El informe académico BI está restringido a la empresa demo: no se debe presentarlo como panel multiempresa.

Registrar URLs y evidencias en ENTREGA.md solamente después de verificar estos pasos.
