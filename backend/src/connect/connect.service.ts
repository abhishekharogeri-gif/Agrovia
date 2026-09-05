import { Injectable } from '@nestjs/common';

export interface FarmerPost {
  id: string;
  authorId: string;
  authorName: string;
  authorLocation: string;
  cropFocus: string;
  content: string;
  imageUrl?: string;
  audioUrl?: string;
  likesCount: number;
  commentsCount: number;
  createdAt: Date;
}

export class CreatePostDto {
  content: string;
  cropFocus?: string;
  imageUrl?: string;
  audioUrl?: string;
}

@Injectable()
export class ConnectService {
  private posts: FarmerPost[] = [
    {
      id: 'post_1',
      authorId: 'usr_rajesh',
      authorName: 'Rajesh Patil',
      authorLocation: 'Nashik, Maharashtra',
      cropFocus: 'Onion / Tomato',
      content: 'Using fermented buttermilk + neem oil spray helped control thrips on early onion crop. No chemical residues.',
      likesCount: 34,
      commentsCount: 12,
      createdAt: new Date(Date.now() - 3600000 * 4),
    },
    {
      id: 'post_2',
      authorId: 'usr_gurpreet',
      authorName: 'Gurpreet Singh',
      authorLocation: 'Ludhiana, Punjab',
      cropFocus: 'Wheat / Mustard',
      content: 'Direct Seeded Rice (DSR) technique saved ~35% water this season. Happy to share machine calibration tips with nearby farmers.',
      likesCount: 58,
      commentsCount: 19,
      createdAt: new Date(Date.now() - 3600000 * 12),
    },
    {
      id: 'post_3',
      authorId: 'usr_venkat',
      authorName: 'Venkat Rao',
      authorLocation: 'Guntur, Andhra Pradesh',
      cropFocus: 'Chilli / Cotton',
      content: 'Black thrips attack warning in chilli fields near Tenali. Immediate sticky trap placement recommended.',
      likesCount: 82,
      commentsCount: 27,
      createdAt: new Date(Date.now() - 3600000 * 24),
    },
  ];

  async getFeed(): Promise<FarmerPost[]> {
    return this.posts;
  }

  async createPost(userId: string, dto: CreatePostDto): Promise<FarmerPost> {
    const newPost: FarmerPost = {
      id: `post_${Date.now()}`,
      authorId: userId,
      authorName: 'Kisan Mitra',
      authorLocation: 'Indore, MP',
      cropFocus: dto.cropFocus || 'General Farming',
      content: dto.content,
      imageUrl: dto.imageUrl,
      audioUrl: dto.audioUrl,
      likesCount: 0,
      commentsCount: 0,
      createdAt: new Date(),
    };
    this.posts.unshift(newPost);
    return newPost;
  }

  async likePost(postId: string): Promise<{ success: boolean; likes: number }> {
    const p = this.posts.find((item) => item.id === postId);
    if (p) {
      p.likesCount += 1;
      return { success: true, likes: p.likesCount };
    }
    return { success: false, likes: 0 };
  }
}
