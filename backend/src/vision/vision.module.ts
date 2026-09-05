import { Module } from '@nestjs/common';
import { VisionService } from './vision.service.js';
import { VisionController } from './vision.controller.js';
import { PrismaModule } from '../prisma/prisma.module.js';

@Module({
  imports: [PrismaModule],
  providers: [VisionService],
  controllers: [VisionController],
  exports: [VisionService],
})
export class VisionModule {}
