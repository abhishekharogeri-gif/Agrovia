import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';

@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  // In-memory mock store for local dev / testing before live PostgreSQL DB connection
  private _diagnoses: any[] = [];
  private _users: any[] = [];

  readonly visionDiagnosis = {
    create: async ({ data }: { data: any }) => {
      const record = { id: `diag_${Date.now()}`, createdAt: new Date(), ...data };
      this._diagnoses.push(record);
      return record;
    },
    findMany: async ({ where, take }: { where?: any; take?: number }) => {
      let res = this._diagnoses;
      if (where?.userId) {
        res = res.filter((d) => d.userId === where.userId);
      }
      return res.slice(0, take ?? 20);
    },
    update: async ({ where, data }: { where: { id: string }; data: any }) => {
      const idx = this._diagnoses.findIndex((d) => d.id === where.id);
      if (idx !== -1) {
        this._diagnoses[idx] = { ...this._diagnoses[idx], ...data };
        return this._diagnoses[idx];
      }
      return null;
    },
  };

  readonly user = {
    findUnique: async ({ where }: { where: any }) => {
      return this._users.find((u) => u.phone === where.phone || u.id === where.id) || null;
    },
    create: async ({ data }: { data: any }) => {
      const u = { id: `usr_${Date.now()}`, ...data };
      this._users.push(u);
      return u;
    },
  };

  async onModuleInit() {
    // Database connect hook
  }

  async onModuleDestroy() {
    // Database disconnect hook
  }
}
