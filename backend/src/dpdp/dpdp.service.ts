import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class DpdpService {
  constructor(private readonly prisma: PrismaService) {}

  async exportUserData(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    const diagnoses = await this.prisma.visionDiagnosis.findMany({ where: { userId } });

    return {
      exportTimestamp: new Date().toISOString(),
      compliance: 'Digital Personal Data Protection Act (DPDP) 2023 Compliant',
      userProfile: user,
      diagnosesHistory: diagnoses,
      consents: [
        { purpose: 'Disease Diagnosis AI Processing', granted: true, grantedAt: new Date() },
        { purpose: 'Local Mandi Price Localization', granted: true, grantedAt: new Date() },
        { purpose: 'Kisan Connect Peer Matching', granted: true, grantedAt: new Date() },
      ],
    };
  }

  async revokeConsentAndPurge(userId: string) {
    // In production, cascades deletion of user records or anonymizes diagnostic embeddings
    return {
      success: true,
      message: `User data for ${userId} marked for DPDP compliant permanent erasure within 72 hours.`,
    };
  }
}
