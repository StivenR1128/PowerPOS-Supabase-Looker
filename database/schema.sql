-- Ejecutar una vez en la instancia NUEVA y vacía.
BEGIN;
SET LOCAL search_path = public;
-- CreateEnum
CREATE TYPE "PlanEmpresa" AS ENUM ('BASICO', 'MEDIUM', 'PREMIUM');

-- CreateEnum
CREATE TYPE "ModoPreparacion" AS ENUM ('KDS', 'COMANDAS');

-- CreateEnum
CREATE TYPE "TipoNegocio" AS ENUM ('RESTAURANTE', 'SUPERMERCADO', 'TIENDA', 'COMERCIO');

-- CreateEnum
CREATE TYPE "RolUsuario" AS ENUM ('SUPERADMIN', 'ADMIN_EMPRESA', 'GERENTE', 'CAJERO', 'COCINERO', 'DOMICILIARIO');

-- CreateEnum
CREATE TYPE "EstadoPedido" AS ENUM ('PENDIENTE', 'EN_COCINA', 'LISTO', 'ENTREGADO', 'ANULADO');

-- CreateEnum
CREATE TYPE "MetodoPago" AS ENUM ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'NEQUI', 'DAVIPLATA');

-- CreateEnum
CREATE TYPE "EstadoCaja" AS ENUM ('ABIERTA', 'CERRADA');

-- CreateEnum
CREATE TYPE "TipoEventoCaja" AS ENUM ('APERTURA', 'CIERRE', 'APERTURA_IRREGULAR', 'DIFERENCIA', 'MOVIMIENTO');

-- CreateEnum
CREATE TYPE "TipoMovimiento" AS ENUM ('INGRESO', 'EGRESO');

-- CreateEnum
CREATE TYPE "CategoriaMovimiento" AS ENUM ('VENTA', 'COMPRA_INSUMOS', 'NOMINA', 'SERVICIOS', 'ARRIENDO', 'MANTENIMIENTO', 'IMPUESTOS', 'OTROS');

-- CreateTable
CREATE TABLE "empresas" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "nit" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "telefono" TEXT,
    "direccion" TEXT,
    "logo" TEXT,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "tipoNegocio" "TipoNegocio" NOT NULL DEFAULT 'RESTAURANTE',
    "plan" "PlanEmpresa" NOT NULL DEFAULT 'BASICO',
    "permisos" JSONB NOT NULL DEFAULT '{}',
    "modoPreparacion" "ModoPreparacion" NOT NULL DEFAULT 'KDS',
    "facturacionElectronicaHabilitada" BOOLEAN NOT NULL DEFAULT false,
    "consumoEmpleadosHabilitado" BOOLEAN NOT NULL DEFAULT false,
    "tiendaSlug" TEXT NOT NULL,
    "tiendaConfig" JSONB NOT NULL DEFAULT '{}',
    "fidelizacionConfig" JSONB NOT NULL DEFAULT '{}',
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "empresas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucursales" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "direccion" TEXT,
    "telefono" TEXT,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sucursales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER,
    "sucursalId" INTEGER,
    "nombre" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "rol" "RolUsuario" NOT NULL,
    "permisos" JSONB,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categorias" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "parentId" INTEGER,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "icono" TEXT,
    "color" TEXT,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categorias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "productos" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "categoriaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "precio" DECIMAL(10,2) NOT NULL,
    "costo" DECIMAL(10,2),
    "codigoBarras" TEXT,
    "controlaStock" BOOLEAN NOT NULL DEFAULT false,
    "stockActual" INTEGER NOT NULL DEFAULT 0,
    "stockMinimo" INTEGER NOT NULL DEFAULT 0,
    "imagen" TEXT,
    "disponible" BOOLEAN NOT NULL DEFAULT true,
    "aceptaAdicionales" BOOLEAN NOT NULL DEFAULT true,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "productos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ingredientes" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "unidad" TEXT NOT NULL,
    "unidadCompra" TEXT,
    "factorConversion" DECIMAL(10,3),
    "costoUnitario" DECIMAL(10,4),
    "stock" DECIMAL(10,3) NOT NULL,
    "stockMinimo" DECIMAL(10,3) NOT NULL DEFAULT 0,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ingredientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimientos_inventario" (
    "id" SERIAL NOT NULL,
    "ingredienteId" INTEGER,
    "productoId" INTEGER,
    "usuarioId" INTEGER NOT NULL,
    "tipo" TEXT NOT NULL,
    "cantidadMovida" DECIMAL(10,3) NOT NULL,
    "unidadCompra" TEXT,
    "factorAplicado" DECIMAL(10,3),
    "stockAnterior" DECIMAL(10,3) NOT NULL,
    "stockNuevo" DECIMAL(10,3) NOT NULL,
    "descripcion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "movimientos_inventario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "producto_ingredientes" (
    "id" SERIAL NOT NULL,
    "productoId" INTEGER NOT NULL,
    "ingredienteId" INTEGER NOT NULL,
    "cantidad" DECIMAL(10,3) NOT NULL,

    CONSTRAINT "producto_ingredientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "preparaciones" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "unidad" TEXT NOT NULL DEFAULT 'porciones',
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "preparaciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "preparacion_ingredientes" (
    "id" SERIAL NOT NULL,
    "preparacionId" INTEGER NOT NULL,
    "ingredienteId" INTEGER NOT NULL,
    "cantidad" DECIMAL(10,3) NOT NULL,
    "unidad" TEXT,
    "observacion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "preparacion_ingredientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lotes_preparacion" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "preparacionId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "fecha" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "loteNumero" TEXT,
    "cantidadProducida" DECIMAL(10,3) NOT NULL,
    "pesoTotal" DECIMAL(10,3),
    "pesoPorBolsa" DECIMAL(10,3),
    "porcionesPorBolsa" DECIMAL(10,3),
    "porcionesTotales" DECIMAL(10,3),
    "observacion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lotes_preparacion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lote_preparacion_ingredientes" (
    "id" SERIAL NOT NULL,
    "loteId" INTEGER NOT NULL,
    "ingredienteId" INTEGER NOT NULL,
    "cantidadUsada" DECIMAL(10,3) NOT NULL,
    "unidad" TEXT,
    "observacion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lote_preparacion_ingredientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "producto_preparaciones" (
    "id" SERIAL NOT NULL,
    "productoId" INTEGER NOT NULL,
    "preparacionId" INTEGER NOT NULL,
    "cantidad" DECIMAL(10,3) NOT NULL DEFAULT 1,
    "unidad" TEXT NOT NULL DEFAULT 'porciones',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "producto_preparaciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "adicionales" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "precio" DECIMAL(10,2) NOT NULL,
    "ingredienteId" INTEGER,
    "cantidad" DECIMAL(10,3),
    "disponible" BOOLEAN NOT NULL DEFAULT true,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "adicionales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "producto_adicionales" (
    "id" SERIAL NOT NULL,
    "productoId" INTEGER NOT NULL,
    "adicionalId" INTEGER NOT NULL,

    CONSTRAINT "producto_adicionales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "documento" TEXT,
    "telefono" TEXT,
    "email" TEXT,
    "direccion" TEXT,
    "fechaNacimiento" TIMESTAMP(3),
    "puntos" INTEGER NOT NULL DEFAULT 0,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pedidos" (
    "id" SERIAL NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "clienteId" INTEGER,
    "cajaId" INTEGER,
    "numero" TEXT NOT NULL,
    "estado" "EstadoPedido" NOT NULL DEFAULT 'PENDIENTE',
    "metodoPago" "MetodoPago" NOT NULL DEFAULT 'EFECTIVO',
    "subtotal" DECIMAL(10,2) NOT NULL,
    "descuento" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "total" DECIMAL(10,2) NOT NULL,
    "observacion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,
    "puntosGanados" INTEGER NOT NULL DEFAULT 0,
    "puntosCanjeados" INTEGER NOT NULL DEFAULT 0,
    "valorPuntoAplicado" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "costoDomicilio" DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT "pedidos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "detalle_pedidos" (
    "id" SERIAL NOT NULL,
    "pedidoId" INTEGER NOT NULL,
    "productoId" INTEGER NOT NULL,
    "cantidad" INTEGER NOT NULL,
    "precioUnitario" DECIMAL(10,2) NOT NULL,
    "subtotal" DECIMAL(10,2) NOT NULL,
    "exclusiones" TEXT[],
    "observacion" TEXT,

    CONSTRAINT "detalle_pedidos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "detalle_pedido_adicionales" (
    "id" SERIAL NOT NULL,
    "detallePedidoId" INTEGER NOT NULL,
    "adicionalId" INTEGER NOT NULL,
    "nombre" TEXT NOT NULL,
    "precio" DECIMAL(10,2) NOT NULL,
    "cantidad" INTEGER NOT NULL DEFAULT 1,
    "subtotal" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "detalle_pedido_adicionales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cajas" (
    "id" SERIAL NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "estado" "EstadoCaja" NOT NULL DEFAULT 'ABIERTA',
    "montoInicial" DECIMAL(10,2) NOT NULL,
    "montoFinal" DECIMAL(10,2),
    "diferencia" DECIMAL(10,2),
    "abiertaEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cerradaEn" TIMESTAMP(3),

    CONSTRAINT "cajas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "eventos_caja" (
    "id" SERIAL NOT NULL,
    "cajaId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "tipo" "TipoEventoCaja" NOT NULL,
    "descripcion" TEXT NOT NULL,
    "esAlerta" BOOLEAN NOT NULL DEFAULT false,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "eventos_caja_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimientos_financieros" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "tipo" "TipoMovimiento" NOT NULL,
    "categoria" "CategoriaMovimiento" NOT NULL,
    "descripcion" TEXT NOT NULL,
    "monto" DECIMAL(10,2) NOT NULL,
    "fecha" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "pedidoId" INTEGER,
    "comprobante" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "movimientos_financieros_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consumos_empleados" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "usuarioId" INTEGER NOT NULL,
    "empleadoNombre" TEXT NOT NULL,
    "observacion" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "consumos_empleados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consumo_empleado_items" (
    "id" SERIAL NOT NULL,
    "consumoEmpleadoId" INTEGER NOT NULL,
    "productoId" INTEGER NOT NULL,
    "cantidad" INTEGER NOT NULL,
    "precioReferencia" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "consumo_empleado_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auditorias" (
    "id" SERIAL NOT NULL,
    "empresaId" INTEGER,
    "usuarioId" INTEGER,
    "accion" TEXT NOT NULL,
    "entidad" TEXT NOT NULL,
    "entidadId" INTEGER,
    "detalle" JSONB,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auditorias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pedidos_web" (
    "id" TEXT NOT NULL,
    "empresaId" INTEGER NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "clave" TEXT NOT NULL,
    "estado" TEXT NOT NULL DEFAULT 'RECIBIDO',
    "nombre" TEXT NOT NULL,
    "telefono" TEXT NOT NULL,
    "direccion" TEXT NOT NULL,
    "zona" TEXT NOT NULL,
    "observacion" TEXT,
    "items" JSONB NOT NULL,
    "subtotal" DECIMAL(10,2) NOT NULL,
    "costoDomicilio" DECIMAL(10,2) NOT NULL,
    "total" DECIMAL(10,2) NOT NULL,
    "metodoPago" "MetodoPago" NOT NULL DEFAULT 'EFECTIVO',
    "pedidoId" INTEGER,
    "repartidorId" INTEGER,
    "motivo" TEXT,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pedidos_web_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "empresas_nit_key" ON "empresas"("nit");

-- CreateIndex
CREATE UNIQUE INDEX "empresas_tiendaSlug_key" ON "empresas"("tiendaSlug");

-- CreateIndex
CREATE INDEX "sucursales_empresaId_idx" ON "sucursales"("empresaId");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE INDEX "usuarios_empresaId_idx" ON "usuarios"("empresaId");

-- CreateIndex
CREATE INDEX "usuarios_sucursalId_idx" ON "usuarios"("sucursalId");

-- CreateIndex
CREATE INDEX "categorias_empresaId_idx" ON "categorias"("empresaId");

-- CreateIndex
CREATE INDEX "categorias_parentId_idx" ON "categorias"("parentId");

-- CreateIndex
CREATE INDEX "productos_empresaId_idx" ON "productos"("empresaId");

-- CreateIndex
CREATE INDEX "productos_categoriaId_idx" ON "productos"("categoriaId");

-- CreateIndex
CREATE UNIQUE INDEX "productos_empresaId_codigoBarras_key" ON "productos"("empresaId", "codigoBarras");

-- CreateIndex
CREATE INDEX "ingredientes_empresaId_activo_idx" ON "ingredientes"("empresaId", "activo");

-- CreateIndex
CREATE INDEX "ingredientes_empresaId_idx" ON "ingredientes"("empresaId");

-- CreateIndex
CREATE INDEX "movimientos_inventario_productoId_creadoEn_idx" ON "movimientos_inventario"("productoId", "creadoEn");

-- CreateIndex
CREATE INDEX "movimientos_inventario_ingredienteId_idx" ON "movimientos_inventario"("ingredienteId");

-- CreateIndex
CREATE INDEX "movimientos_inventario_productoId_idx" ON "movimientos_inventario"("productoId");

-- CreateIndex
CREATE INDEX "movimientos_inventario_usuarioId_idx" ON "movimientos_inventario"("usuarioId");

-- CreateIndex
CREATE INDEX "producto_ingredientes_productoId_idx" ON "producto_ingredientes"("productoId");

-- CreateIndex
CREATE INDEX "producto_ingredientes_ingredienteId_idx" ON "producto_ingredientes"("ingredienteId");

-- CreateIndex
CREATE UNIQUE INDEX "producto_ingredientes_productoId_ingredienteId_key" ON "producto_ingredientes"("productoId", "ingredienteId");

-- CreateIndex
CREATE INDEX "preparaciones_empresaId_idx" ON "preparaciones"("empresaId");

-- CreateIndex
CREATE INDEX "preparacion_ingredientes_preparacionId_idx" ON "preparacion_ingredientes"("preparacionId");

-- CreateIndex
CREATE INDEX "preparacion_ingredientes_ingredienteId_idx" ON "preparacion_ingredientes"("ingredienteId");

-- CreateIndex
CREATE INDEX "lotes_preparacion_empresaId_idx" ON "lotes_preparacion"("empresaId");

-- CreateIndex
CREATE INDEX "lotes_preparacion_preparacionId_idx" ON "lotes_preparacion"("preparacionId");

-- CreateIndex
CREATE INDEX "lotes_preparacion_usuarioId_idx" ON "lotes_preparacion"("usuarioId");

-- CreateIndex
CREATE INDEX "lote_preparacion_ingredientes_loteId_idx" ON "lote_preparacion_ingredientes"("loteId");

-- CreateIndex
CREATE INDEX "lote_preparacion_ingredientes_ingredienteId_idx" ON "lote_preparacion_ingredientes"("ingredienteId");

-- CreateIndex
CREATE INDEX "producto_preparaciones_productoId_idx" ON "producto_preparaciones"("productoId");

-- CreateIndex
CREATE INDEX "producto_preparaciones_preparacionId_idx" ON "producto_preparaciones"("preparacionId");

-- CreateIndex
CREATE UNIQUE INDEX "producto_preparaciones_productoId_preparacionId_key" ON "producto_preparaciones"("productoId", "preparacionId");

-- CreateIndex
CREATE INDEX "adicionales_empresaId_idx" ON "adicionales"("empresaId");

-- CreateIndex
CREATE INDEX "adicionales_ingredienteId_idx" ON "adicionales"("ingredienteId");

-- CreateIndex
CREATE INDEX "producto_adicionales_productoId_idx" ON "producto_adicionales"("productoId");

-- CreateIndex
CREATE INDEX "producto_adicionales_adicionalId_idx" ON "producto_adicionales"("adicionalId");

-- CreateIndex
CREATE UNIQUE INDEX "producto_adicionales_productoId_adicionalId_key" ON "producto_adicionales"("productoId", "adicionalId");

-- CreateIndex
CREATE INDEX "clientes_empresaId_idx" ON "clientes"("empresaId");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_empresaId_documento_key" ON "clientes"("empresaId", "documento");

-- CreateIndex
CREATE UNIQUE INDEX "pedidos_numero_key" ON "pedidos"("numero");

-- CreateIndex
CREATE INDEX "pedidos_sucursalId_idx" ON "pedidos"("sucursalId");

-- CreateIndex
CREATE INDEX "pedidos_usuarioId_idx" ON "pedidos"("usuarioId");

-- CreateIndex
CREATE INDEX "pedidos_clienteId_idx" ON "pedidos"("clienteId");

-- CreateIndex
CREATE INDEX "pedidos_cajaId_idx" ON "pedidos"("cajaId");

-- CreateIndex
CREATE INDEX "detalle_pedidos_pedidoId_idx" ON "detalle_pedidos"("pedidoId");

-- CreateIndex
CREATE INDEX "detalle_pedidos_productoId_idx" ON "detalle_pedidos"("productoId");

-- CreateIndex
CREATE INDEX "detalle_pedido_adicionales_detallePedidoId_idx" ON "detalle_pedido_adicionales"("detallePedidoId");

-- CreateIndex
CREATE INDEX "detalle_pedido_adicionales_adicionalId_idx" ON "detalle_pedido_adicionales"("adicionalId");

-- CreateIndex
CREATE INDEX "cajas_sucursalId_idx" ON "cajas"("sucursalId");

-- CreateIndex
CREATE INDEX "cajas_usuarioId_idx" ON "cajas"("usuarioId");

-- CreateIndex
CREATE INDEX "eventos_caja_cajaId_idx" ON "eventos_caja"("cajaId");

-- CreateIndex
CREATE INDEX "eventos_caja_usuarioId_idx" ON "eventos_caja"("usuarioId");

-- CreateIndex
CREATE INDEX "movimientos_financieros_empresaId_idx" ON "movimientos_financieros"("empresaId");

-- CreateIndex
CREATE INDEX "movimientos_financieros_sucursalId_idx" ON "movimientos_financieros"("sucursalId");

-- CreateIndex
CREATE INDEX "movimientos_financieros_usuarioId_idx" ON "movimientos_financieros"("usuarioId");

-- CreateIndex
CREATE INDEX "movimientos_financieros_pedidoId_idx" ON "movimientos_financieros"("pedidoId");

-- CreateIndex
CREATE INDEX "consumos_empleados_empresaId_idx" ON "consumos_empleados"("empresaId");

-- CreateIndex
CREATE INDEX "consumos_empleados_sucursalId_idx" ON "consumos_empleados"("sucursalId");

-- CreateIndex
CREATE INDEX "consumos_empleados_usuarioId_idx" ON "consumos_empleados"("usuarioId");

-- CreateIndex
CREATE INDEX "consumo_empleado_items_consumoEmpleadoId_idx" ON "consumo_empleado_items"("consumoEmpleadoId");

-- CreateIndex
CREATE INDEX "consumo_empleado_items_productoId_idx" ON "consumo_empleado_items"("productoId");

-- CreateIndex
CREATE INDEX "auditorias_empresaId_creadoEn_idx" ON "auditorias"("empresaId", "creadoEn");

-- CreateIndex
CREATE INDEX "auditorias_empresaId_idx" ON "auditorias"("empresaId");

-- CreateIndex
CREATE INDEX "auditorias_usuarioId_idx" ON "auditorias"("usuarioId");

-- CreateIndex
CREATE UNIQUE INDEX "pedidos_web_pedidoId_key" ON "pedidos_web"("pedidoId");

-- CreateIndex
CREATE INDEX "pedidos_web_empresaId_estado_creadoEn_idx" ON "pedidos_web"("empresaId", "estado", "creadoEn");

-- CreateIndex
CREATE INDEX "pedidos_web_empresaId_idx" ON "pedidos_web"("empresaId");

-- CreateIndex
CREATE INDEX "pedidos_web_pedidoId_idx" ON "pedidos_web"("pedidoId");

-- CreateIndex
CREATE INDEX "pedidos_web_sucursalId_idx" ON "pedidos_web"("sucursalId");

-- CreateIndex
CREATE INDEX "pedidos_web_repartidorId_idx" ON "pedidos_web"("repartidorId");

-- CreateIndex
CREATE UNIQUE INDEX "pedidos_web_empresaId_clave_key" ON "pedidos_web"("empresaId", "clave");

-- AddForeignKey
ALTER TABLE "sucursales" ADD CONSTRAINT "sucursales_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "categorias" ADD CONSTRAINT "categorias_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "categorias" ADD CONSTRAINT "categorias_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "categorias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "productos" ADD CONSTRAINT "productos_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "productos" ADD CONSTRAINT "productos_categoriaId_fkey" FOREIGN KEY ("categoriaId") REFERENCES "categorias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ingredientes" ADD CONSTRAINT "ingredientes_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_ingredienteId_fkey" FOREIGN KEY ("ingredienteId") REFERENCES "ingredientes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_ingredientes" ADD CONSTRAINT "producto_ingredientes_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_ingredientes" ADD CONSTRAINT "producto_ingredientes_ingredienteId_fkey" FOREIGN KEY ("ingredienteId") REFERENCES "ingredientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "preparaciones" ADD CONSTRAINT "preparaciones_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "preparacion_ingredientes" ADD CONSTRAINT "preparacion_ingredientes_preparacionId_fkey" FOREIGN KEY ("preparacionId") REFERENCES "preparaciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "preparacion_ingredientes" ADD CONSTRAINT "preparacion_ingredientes_ingredienteId_fkey" FOREIGN KEY ("ingredienteId") REFERENCES "ingredientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lotes_preparacion" ADD CONSTRAINT "lotes_preparacion_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lotes_preparacion" ADD CONSTRAINT "lotes_preparacion_preparacionId_fkey" FOREIGN KEY ("preparacionId") REFERENCES "preparaciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lotes_preparacion" ADD CONSTRAINT "lotes_preparacion_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lote_preparacion_ingredientes" ADD CONSTRAINT "lote_preparacion_ingredientes_loteId_fkey" FOREIGN KEY ("loteId") REFERENCES "lotes_preparacion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lote_preparacion_ingredientes" ADD CONSTRAINT "lote_preparacion_ingredientes_ingredienteId_fkey" FOREIGN KEY ("ingredienteId") REFERENCES "ingredientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_preparaciones" ADD CONSTRAINT "producto_preparaciones_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_preparaciones" ADD CONSTRAINT "producto_preparaciones_preparacionId_fkey" FOREIGN KEY ("preparacionId") REFERENCES "preparaciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "adicionales" ADD CONSTRAINT "adicionales_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "adicionales" ADD CONSTRAINT "adicionales_ingredienteId_fkey" FOREIGN KEY ("ingredienteId") REFERENCES "ingredientes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_adicionales" ADD CONSTRAINT "producto_adicionales_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producto_adicionales" ADD CONSTRAINT "producto_adicionales_adicionalId_fkey" FOREIGN KEY ("adicionalId") REFERENCES "adicionales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "clientes" ADD CONSTRAINT "clientes_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos" ADD CONSTRAINT "pedidos_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos" ADD CONSTRAINT "pedidos_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos" ADD CONSTRAINT "pedidos_clienteId_fkey" FOREIGN KEY ("clienteId") REFERENCES "clientes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos" ADD CONSTRAINT "pedidos_cajaId_fkey" FOREIGN KEY ("cajaId") REFERENCES "cajas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_pedidos" ADD CONSTRAINT "detalle_pedidos_pedidoId_fkey" FOREIGN KEY ("pedidoId") REFERENCES "pedidos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_pedidos" ADD CONSTRAINT "detalle_pedidos_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_pedido_adicionales" ADD CONSTRAINT "detalle_pedido_adicionales_detallePedidoId_fkey" FOREIGN KEY ("detallePedidoId") REFERENCES "detalle_pedidos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "detalle_pedido_adicionales" ADD CONSTRAINT "detalle_pedido_adicionales_adicionalId_fkey" FOREIGN KEY ("adicionalId") REFERENCES "adicionales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cajas" ADD CONSTRAINT "cajas_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cajas" ADD CONSTRAINT "cajas_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "eventos_caja" ADD CONSTRAINT "eventos_caja_cajaId_fkey" FOREIGN KEY ("cajaId") REFERENCES "cajas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "eventos_caja" ADD CONSTRAINT "eventos_caja_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_financieros" ADD CONSTRAINT "movimientos_financieros_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_financieros" ADD CONSTRAINT "movimientos_financieros_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_financieros" ADD CONSTRAINT "movimientos_financieros_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimientos_financieros" ADD CONSTRAINT "movimientos_financieros_pedidoId_fkey" FOREIGN KEY ("pedidoId") REFERENCES "pedidos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos_empleados" ADD CONSTRAINT "consumos_empleados_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos_empleados" ADD CONSTRAINT "consumos_empleados_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos_empleados" ADD CONSTRAINT "consumos_empleados_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumo_empleado_items" ADD CONSTRAINT "consumo_empleado_items_consumoEmpleadoId_fkey" FOREIGN KEY ("consumoEmpleadoId") REFERENCES "consumos_empleados"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumo_empleado_items" ADD CONSTRAINT "consumo_empleado_items_productoId_fkey" FOREIGN KEY ("productoId") REFERENCES "productos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditorias" ADD CONSTRAINT "auditorias_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditorias" ADD CONSTRAINT "auditorias_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos_web" ADD CONSTRAINT "pedidos_web_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos_web" ADD CONSTRAINT "pedidos_web_pedidoId_fkey" FOREIGN KEY ("pedidoId") REFERENCES "pedidos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos_web" ADD CONSTRAINT "pedidos_web_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos_web" ADD CONSTRAINT "pedidos_web_repartidorId_fkey" FOREIGN KEY ("repartidorId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- Refuerzo de integridad para la copia académica. Ejecutar UNA vez.
ALTER TABLE public.productos ADD CONSTRAINT productos_precio_no_negativo CHECK (precio >= 0 AND (costo IS NULL OR costo >= 0));
ALTER TABLE public.detalle_pedidos ADD CONSTRAINT detalle_cantidad_positiva CHECK (cantidad > 0 AND "precioUnitario" >= 0 AND subtotal >= 0);
ALTER TABLE public.pedidos ADD CONSTRAINT pedido_importes_validos CHECK (subtotal >= 0 AND descuento >= 0 AND descuento <= subtotal AND "costoDomicilio" >= 0 AND total = subtotal - descuento + "costoDomicilio");
ALTER TABLE public.movimientos_financieros ADD CONSTRAINT movimiento_monto_positivo CHECK (monto >= 0);
ALTER TABLE public.movimientos_inventario ADD CONSTRAINT movimiento_un_objetivo CHECK (("ingredienteId" IS NOT NULL)::int + ("productoId" IS NOT NULL)::int = 1);
ALTER TABLE public.preparacion_ingredientes ADD CONSTRAINT preparacion_ingrediente_unico UNIQUE ("preparacionId", "ingredienteId");
ALTER TABLE public.lote_preparacion_ingredientes ADD CONSTRAINT lote_ingrediente_unico UNIQUE ("loteId", "ingredienteId");

COMMIT;
