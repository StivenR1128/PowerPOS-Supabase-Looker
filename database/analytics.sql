-- Vista de BI aislada: solamente la empresa ficticia con id=1.
-- Una fila por detalle. El total del pedido se distribuye para no duplicarlo.
BEGIN;
CREATE SCHEMA IF NOT EXISTS reporting;
REVOKE ALL ON SCHEMA reporting FROM PUBLIC, anon, authenticated;
CREATE OR REPLACE VIEW reporting.ventas AS
SELECT
  d.id AS detalle_id, p.id AS pedido_id, p."creadoEn"::date AS fecha,
  s.nombre AS sucursal, c.nombre AS categoria, pr.nombre AS producto,
  p.estado::text AS estado, p."metodoPago"::text AS metodo_pago,
  d.cantidad AS unidades,
  d.subtotal AS importe_bruto,
  CASE WHEN p.estado::text = 'ANULADO' THEN 0::numeric
    ELSE p.total * d.subtotal / NULLIF(sum(d.subtotal) OVER (PARTITION BY p.id), 0)
  END AS ingreso_neto,
  CASE WHEN p.estado::text = 'ANULADO' THEN 0 ELSE d.cantidad END AS unidades_vendidas
FROM public.pedidos p
JOIN public.sucursales s ON s.id = p."sucursalId"
JOIN public.detalle_pedidos d ON d."pedidoId" = p.id
JOIN public.productos pr ON pr.id = d."productoId"
JOIN public.categorias c ON c.id = pr."categoriaId"
WHERE s."empresaId" = 1 AND pr."empresaId" = 1 AND c."empresaId" = 1;
-- La vista usa permisos del propietario intencionalmente: el lector NO recibe
-- acceso a las tablas operativas, usuarios, contraseñas o datos de clientes.
REVOKE ALL ON reporting.ventas FROM PUBLIC, anon, authenticated, powerpos_app;
GRANT USAGE ON SCHEMA reporting TO powerpos_looker;
GRANT SELECT ON reporting.ventas TO powerpos_looker;
COMMIT;
