-- Pegar una única sentencia en CUSTOM QUERY del conector PostgreSQL.
SELECT detalle_id, pedido_id, fecha, sucursal, categoria, producto, estado,
       metodo_pago, unidades, importe_bruto, ingreso_neto, unidades_vendidas
FROM reporting.ventas
