# Construcción del informe real

Esta guía define el informe; no es un enlace a un informe ya creado.

1. Iniciar sesión en Google Looker Studio con la cuenta elegida.
2. Crear fuente de datos y elegir el conector nativo **PostgreSQL**.
3. Introducir host del session pooler, puerto 5432, base postgres, usuario `powerpos_looker.PROJECT_REF` y su contraseña privada. Habilitar SSL según el formulario; no compartir el rol backend.
4. Elegir **CUSTOM QUERY** y pegar el contenido de `database/looker-query.sql`. El selector de tablas no soporta esquemas fuera de public; la consulta personalizada sí.
5. Confirmar que `fecha` sea Fecha y `ingreso_neto` sea número/moneda COP. Convertir enums a texto ya está resuelto en la vista.
6. Crear un informe llamado **PowerPOS · Analítica de ventas**.

## Gráficos y medidas

| Componente | Dimensión | Métrica / configuración |
|---|---|---|
| Tarjeta ingresos | — | SUM(ingreso_neto), COP |
| Tarjeta pedidos válidos | — | COUNT_DISTINCT(pedido_id), excluir estado ANULADO |
| Tarjeta unidades | — | SUM(unidades_vendidas) |
| Línea diaria | fecha | SUM(ingreso_neto), orden por fecha ascendente |
| Barras por categoría | categoria | SUM(ingreso_neto), orden descendente |
| Circular medios de pago | metodo_pago | SUM(ingreso_neto) |

Agregar controles **rango de fechas** y **lista desplegable categoría**, ambos a nivel del informe o agrupados con todos los gráficos que deban filtrar. Agregar sucursal como tercer control opcional. Fijar fecha inicial en últimos 90 días para mostrar el seed histórico.

No sumar total del pedido sobre un JOIN con detalles. `ingreso_neto` ya distribuye el total proporcionalmente por detalle y anula el ingreso de pedidos cancelados. Si se filtra una categoría, el KPI de ingresos muestra su parte de ventas; el recuento distinto muestra pedidos que contienen esa categoría. Una categoría actual de producto podría variar si se reclasifica: el modelo original no guarda un snapshot de categoría.

## Diseño y controles

Informe de una página: encabezado, controles, tres tarjetas, línea, barras y circular. Fondo oscuro, acento naranja y tipografía legible. Probar los controles en pantalla amplia y móvil. En la web el iframe se adapta al ancho y ofrece abrir el informe aparte para pantallas pequeñas.

## Inserción y actualización

En Compartir, habilitar la inserción del informe. Elegir permisos de visualización apropiados para el docente. Para un informe público, usar exclusivamente los datos ficticios incluidos y revisar que no revele información privada. Copiar el `src` HTTPS del iframe, no el enlace de edición, y ponerlo en `web/.env.local` como `NEXT_PUBLIC_LOOKER_EMBED_URL`. Recompilar/reiniciar el frontend.

Configurar la frescura más adecuada que ofrezca el conector y documentarla. **Looker no garantiza actualización instantánea** al registrar una venta: intervienen caché y frescura de fuente. Para el video, mostrar primero la persistencia inmediata en Supabase, luego actualizar los datos del informe y demostrar filtros.

Verificar como lector: abre el informe, cambia fechas y categoría, y comprueba que los gráficos respondan; probar el informe incrustado con la cuenta que evaluará. Un iframe privado puede exigir sesión Google y configuración compatible de cookies.

Fuentes: [conector PostgreSQL](https://docs.cloud.google.com/looker/docs/studio/connect-to-postgresql), [insertar informe](https://docs.cloud.google.com/looker/docs/studio/embed-a-report).
