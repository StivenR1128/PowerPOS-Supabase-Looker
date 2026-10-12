-- Ejecutar como postgres solamente en el proyecto NUEVO de la práctica.
BEGIN;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'powerpos_app') THEN
    CREATE ROLE powerpos_app NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'powerpos_looker') THEN
    CREATE ROLE powerpos_looker NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  END IF;
END $$;
-- El asistente de proyectos puede crear este trigger con SECURITY DEFINER.
-- Su ejecución no necesita quedar disponible para usuarios de la Data API.
DO $$ BEGIN
  IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
    REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
  END IF;
END $$;
GRANT USAGE ON SCHEMA public TO powerpos_app;
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['empresas','sucursales','usuarios','categorias','productos','ingredientes','producto_ingredientes','adicionales','producto_adicionales','preparaciones','preparacion_ingredientes','lotes_preparacion','lote_preparacion_ingredientes','producto_preparaciones','clientes','cajas','pedidos','detalle_pedidos','detalle_pedido_adicionales','eventos_caja','movimientos_financieros','consumos_empleados','consumo_empleado_items','auditorias','pedidos_web','movimientos_inventario'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('REVOKE ALL ON public.%I FROM PUBLIC, anon, authenticated, powerpos_looker', t);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO powerpos_app', t);
    EXECUTE format('DROP POLICY IF EXISTS backend_only ON public.%I', t);
    -- Credencial exclusiva del servidor. JWT y aislamiento empresarial se validan en NestJS.
    EXECUTE format('CREATE POLICY backend_only ON public.%I FOR ALL TO powerpos_app USING (true) WITH CHECK (true)', t);
  END LOOP;
END $$;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO powerpos_app;
COMMIT;
-- Los roles NOLOGIN no son credenciales hasta configurar LOGIN/PASSWORD de forma privada.
-- Nunca poner esas contraseñas en este archivo, GitHub ni NEXT_PUBLIC_*.
