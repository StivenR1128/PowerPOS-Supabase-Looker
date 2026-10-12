import { Controller, Get, Patch, Post, Body, UseGuards, Request, UseInterceptors, UploadedFile, BadRequestException } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { EmpresaService } from './empresa.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('empresa')
export class EmpresaController {
  constructor(private readonly empresaService: EmpresaService) {}

  @Get()
  obtener(@Request() req: any) {
    return this.empresaService.obtener(req.user.empresaId);
  }

  @Patch()
  @Roles('ADMIN_EMPRESA')
  actualizar(@Body() body: any, @Request() req: any) {
    return this.empresaService.actualizar(req.user.empresaId, body);
  }

  @Post('logo')
  @Roles('ADMIN_EMPRESA')
  @UseInterceptors(FileInterceptor('logo', {
    storage: memoryStorage(),
    fileFilter: (req, file, cb) => {
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|webp)$/)) {
        cb(new Error('Solo se permiten imágenes'), false);
      } else {
        cb(null, true);
      }
    },
    limits: { fileSize: 2 * 1024 * 1024 },
  }))
  async subirLogo(@UploadedFile() file: Express.Multer.File, @Request() req: any) {
    if (!file?.buffer) throw new BadRequestException('Selecciona una imagen para el logo');
    // Vercel no ofrece disco persistente: la URL de datos se guarda en PostgreSQL.
    const logoUrl = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
    await this.empresaService.actualizarLogo(req.user.empresaId, logoUrl);
    return { logoUrl };
  }
}
