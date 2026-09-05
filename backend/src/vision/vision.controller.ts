import { Controller, Post, Body, Get, Req, UseGuards } from '@nestjs/common';
import { VisionService, SubmitDiagnosisDto } from './vision.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('vision')
export class VisionController {
  constructor(private readonly visionService: VisionService) {}

  @Post('diagnose')
  async submitDiagnosis(@Body() body: any, @Req() req: any) {
    const dto: SubmitDiagnosisDto = {
      userId: req.user.userId,
      farmId: body.farmId,
      imageUrl: body.imageUrl,
      onDeviceLabel: body.onDeviceLabel,
      onDeviceConfidence: body.onDeviceConfidence,
      diseaseSeverity: body.diseaseSeverity,
      affectedAreaPct: body.affectedAreaPct,
      treatmentOrganic: body.treatmentOrganic,
      treatmentChemical: body.treatmentChemical,
    };
    return this.visionService.submitDiagnosis(dto);
  }

  @Get('history')
  async getHistory(@Req() req: any) {
    return this.visionService.getHistory(req.user.userId);
  }
}
