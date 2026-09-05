import { Module } from '@nestjs/common';
import { DpdpService } from './dpdp.service.js';
import { DpdpController } from './dpdp.controller.js';

@Module({
  providers: [DpdpService],
  controllers: [DpdpController],
  exports: [DpdpService],
})
export class DpdpModule {}
