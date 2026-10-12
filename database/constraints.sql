-- Refuerzo de integridad para la copia académica. Ejecutar UNA vez.
BEGIN;
ALTER TABLE public.productos ADD CONSTRAINT productos_precio_no_negativo CHECK (precio >= 0 AND (costo IS NULL OR costo >= 0));
ALTER TABLE public.detalle_pedidos ADD CONSTRAINT detalle_cantidad_positiva CHECK (cantidad > 0 AND "precioUnitario" >= 0 AND subtotal >= 0);
ALTER TABLE public.pedidos ADD CONSTRAINT pedido_importes_validos CHECK (subtotal >= 0 AND descuento >= 0 AND descuento <= subtotal AND "costoDomicilio" >= 0 AND total = subtotal - descuento + "costoDomicilio");
ALTER TABLE public.movimientos_financieros ADD CONSTRAINT movimiento_monto_positivo CHECK (monto >= 0);
ALTER TABLE public.movimientos_inventario ADD CONSTRAINT movimiento_un_objetivo CHECK (("ingredienteId" IS NOT NULL)::int + ("productoId" IS NOT NULL)::int = 1);
ALTER TABLE public.preparacion_ingredientes ADD CONSTRAINT preparacion_ingrediente_unico UNIQUE ("preparacionId", "ingredienteId");
ALTER TABLE public.lote_preparacion_ingredientes ADD CONSTRAINT lote_ingrediente_unico UNIQUE ("loteId", "ingredienteId");
COMMIT;
