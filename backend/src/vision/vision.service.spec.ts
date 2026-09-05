import { Test, TestingModule } from '@nestjs/testing';
import { VisionService } from './vision.service.js';
import { PrismaService } from '../prisma/prisma.service.js';

describe('VisionService', () => {
  let service: VisionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VisionService,
        {
          provide: PrismaService,
          useValue: {
            visionDiagnosis: {
              create: vi.fn(),
              findMany: vi.fn().mockResolvedValue([]),
            },
          },
        },
      ],
    }).compile();

    service = module.get<VisionService>(VisionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
