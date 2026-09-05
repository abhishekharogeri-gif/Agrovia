import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

export interface SubmitDiagnosisDto {
  userId: string;
  farmId?: string;
  imageUrl: string;
  onDeviceLabel: string;
  onDeviceConfidence: number;
  diseaseSeverity?: string;
  affectedAreaPct?: number;
  treatmentOrganic?: string;
  treatmentChemical?: string;
}

@Injectable()
export class VisionService {
  private readonly logger = new Logger(VisionService.name);

  constructor(private readonly prisma: PrismaService) {}

  async submitDiagnosis(dto: SubmitDiagnosisDto) {
    this.logger.log(`Received diagnosis submission for user ${dto.userId}: ${dto.onDeviceLabel}`);

    // Persist diagnosis in PostgreSQL via Prisma
    const diagnosis = await this.prisma.visionDiagnosis.create({
      data: {
        userId: dto.userId,
        farmId: dto.farmId,
        imageUrl: dto.imageUrl,
        onDeviceLabel: dto.onDeviceLabel,
        onDeviceConfidence: dto.onDeviceConfidence,
        diseaseSeverity: dto.diseaseSeverity,
        affectedAreaPct: dto.affectedAreaPct,
        treatmentOrganic: dto.treatmentOrganic,
        treatmentChemical: dto.treatmentChemical,
        stage: 'ON_DEVICE_COMPLETE',
      },
    });

    // Trigger async Cloud CNN verification in background
    this.scheduleCloudVerification(diagnosis.id, dto.imageUrl);

    return diagnosis;
  }

  async getHistory(userId: string) {
    return this.prisma.visionDiagnosis.findMany({
      where: { userId },
      take: 20,
    });
  }

  private async scheduleCloudVerification(diagnosisId: string, _imageUrl: string) {
    // Non-blocking async simulation of cloud heavy CNN ensemble
    setTimeout(async () => {
      try {
        this.logger.log(`Running cloud verification for diagnosis ${diagnosisId}...`);
        await this.prisma.visionDiagnosis.update({
          where: { id: diagnosisId },
          data: {
            cloudVerifiedLabel: 'Frogeye Leaf Spot (Verified)',
            cloudConfidence: 0.985,
            stage: 'CLOUD_VERIFIED',
          },
        });
        this.logger.log(`Cloud verification finished for ${diagnosisId}`);
      } catch (err) {
        this.logger.error(`Cloud verification error for ${diagnosisId}: ${err}`);
      }
    }, 5000);
  }
}
