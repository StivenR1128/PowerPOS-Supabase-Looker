-- Ejecutar como postgres tras schema + seed + security + analytics.
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;
SELECT 'pedidos' AS tabla, count(*) AS filas FROM public.pedidos
UNION ALL SELECT 'detalle_pedidos', count(*) FROM public.detalle_pedidos
UNION ALL SELECT 'movimientos_financieros', count(*) FROM public.movimientos_financieros
UNION ALL SELECT 'movimientos_inventario', count(*) FROM public.movimientos_inventario;
-- Ambas comprobaciones deben devolver 0.
SELECT count(*) AS pedidos_inconsistentes FROM public.pedidos p
WHERE abs(p.subtotal - (SELECT sum(d.subtotal) FROM public.detalle_pedidos d WHERE d."pedidoId" = p.id)) > 0.01
OR abs(p.total - (p.subtotal - p.descuento + p."costoDomicilio")) > 0.01;
SELECT count(*) AS importes_bi_inconsistentes FROM
(SELECT p.id, p.total, p.estado, sum(v.ingreso_neto) AS ingreso
 FROM public.pedidos p JOIN reporting.ventas v ON v.pedido_id = p.id
 GROUP BY p.id) t WHERE abs(ingreso - CASE WHEN estado::text = 'ANULADO' THEN 0 ELSE total END) > 0.01;
SELECT c.relname, c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
SELECT has_table_privilege('powerpos_looker','public.usuarios','SELECT') AS lector_puede_leer_usuarios,
       has_table_privilege('powerpos_looker','reporting.ventas','SELECT') AS lector_puede_leer_bi;
-- Debe dar false / true.
