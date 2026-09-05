import { Module } from '@nestjs/common';
import { YojanaService } from './yojana.service.js';
import { YojanaController } from './yojana.controller.js';

@Module({
  providers: [YojanaService],
  controllers: [YojanaController],
  exports: [YojanaService],
})
export class YojanaModule {}
