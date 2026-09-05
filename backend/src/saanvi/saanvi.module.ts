import { Module } from '@nestjs/common';
import { SaanviService } from './saanvi.service.js';
import { SaanviController } from './saanvi.controller.js';

@Module({
  providers: [SaanviService],
  controllers: [SaanviController],
  exports: [SaanviService],
})
export class SaanviModule {}
