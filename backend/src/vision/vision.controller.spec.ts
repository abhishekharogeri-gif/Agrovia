import { Test, TestingModule } from '@nestjs/testing';
import { VisionController } from './vision.controller.js';
import { VisionService } from './vision.service.js';

describe('VisionController', () => {
  let controller: VisionController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VisionController],
      providers: [
        {
          provide: VisionService,
          useValue: {
            processCloudVerification: vi.fn().mockResolvedValue({
              jobId: 'mock-job-123',
              status: 'PROCESSED',
              confidence: 0.96,
              verifiedDisease: 'Yellow Rust',
            }),
            getHistory: vi.fn().mockResolvedValue([]),
          },
        },
      ],
    }).compile();

    controller = module.get<VisionController>(VisionController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
