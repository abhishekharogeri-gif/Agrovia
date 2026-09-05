import { Module } from '@nestjs/common';
import { ConnectService } from './connect.service.js';
import { ConnectController } from './connect.controller.js';

@Module({
  providers: [ConnectService],
  controllers: [ConnectController],
  exports: [ConnectService],
})
export class ConnectModule {}
