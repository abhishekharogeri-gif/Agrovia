// Shared Types across Agrovia Full-stack

export interface User {
  id: string;
  phone: string;
  email?: string;
  name?: string;
  state?: string;
  district?: string;
  language?: string;
  kyc_status: 'PENDING' | 'VERIFIED' | 'REJECTED';
}

export interface Farm {
  id: string;
  userId: string;
  name: string;
  areaAcres: number;
}
