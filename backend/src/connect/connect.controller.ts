import { Controller, Get, Post, Body, Param, Req, UseGuards } from '@nestjs/common';
import { ConnectService, CreatePostDto } from './connect.service.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';

@UseGuards(JwtAuthGuard)
@Controller('connect')
export class ConnectController {
  constructor(private readonly connectService: ConnectService) {}

  @Get('feed')
  async getFeed() {
    return this.connectService.getFeed();
  }

  @Post('post')
  async createPost(@Body() dto: CreatePostDto, @Req() req: any) {
    return this.connectService.createPost(req.user.userId, dto);
  }

  @Post('post/:id/like')
  async likePost(@Param('id') id: string) {
    return this.connectService.likePost(id);
  }
}
