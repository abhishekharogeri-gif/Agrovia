import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './auth/auth.module.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { VisionModule } from './vision/vision.module.js';
import { SaanviModule } from './saanvi/saanvi.module.js';
import { ConnectModule } from './connect/connect.module.js';
import { MarketModule } from './market/market.module.js';
import { YojanaModule } from './yojana/yojana.module.js';
import { DpdpModule } from './dpdp/dpdp.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    PrismaModule,
    VisionModule,
    SaanviModule,
    ConnectModule,
    MarketModule,
    YojanaModule,
    DpdpModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
