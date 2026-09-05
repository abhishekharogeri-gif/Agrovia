import { Injectable } from '@nestjs/common';

export interface Scheme {
  id: string;
  nameEn: string;
  nameHi: string;
  ministry: string;
  benefitAmount: string;
  category: 'FINANCIAL' | 'SOLAR_IRRIGATION' | 'INSURANCE' | 'SOIL_FERTILIZER';
  description: string;
  eligibilityCriteria: string[];
  requiredDocs: string[];
  applyUrl: string;
}

export class CheckEligibilityDto {
  landSizeAcres: number;
  state: string;
  category?: string;
  hasElectricity?: boolean;
}

@Injectable()
export class YojanaService {
  private readonly schemes: Scheme[] = [
    {
      id: 'sch_pmkisan',
      nameEn: 'PM-KISAN Samman Nidhi',
      nameHi: 'प्रधानमंत्री किसान सम्मान निधि',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      benefitAmount: '₹6,000 / year (3 installments of ₹2,000)',
      category: 'FINANCIAL',
      description: 'Income support to all landholding farmer families in the country.',
      eligibilityCriteria: [
        'Must own cultivable land in name',
        'Valid Aadhaar linked to bank account',
        'Not an institutional landholder or tax payee',
      ],
      requiredDocs: ['Aadhaar Card', 'Land Records (7/12 or Khasra/Khatauni)', 'Bank Passbook'],
      applyUrl: 'https://pmkisan.gov.in',
    },
    {
      id: 'sch_kusum',
      nameEn: 'PM-KUSUM Solar Pump Scheme',
      nameHi: 'प्रधानमंत्री कुसुम सोलर पंप योजना',
      ministry: 'Ministry of New & Renewable Energy',
      benefitAmount: '60% Govt Subsidy on Solar Agriculture Pumps',
      category: 'SOLAR_IRRIGATION',
      description: 'Subsidy for stand-alone solar agriculture pumps and solarization of grid-connected pumps.',
      eligibilityCriteria: [
        'Farmers having agricultural land with irrigation source',
        'Priority to off-grid remote agricultural zones',
      ],
      requiredDocs: ['Aadhaar Card', 'Land Ownership Records', 'Electricity Bill (if applicable)', 'Bank Details'],
      applyUrl: 'https://pmkusum.mnre.gov.in',
    },
    {
      id: 'sch_pmfby',
      nameEn: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      nameHi: 'प्रधानमंत्री फसल बीमा योजना',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      benefitAmount: 'Comprehensive crop loss cover at low premium (1.5% - 2%)',
      category: 'INSURANCE',
      description: 'Insurance coverage and financial support to the farmers in the event of failure of any of the notified crops as a result of natural calamities, pests & diseases.',
      eligibilityCriteria: ['All farmers growing notified crops in notified areas'],
      requiredDocs: ['Sowing Certificate', 'Land Possession Document', 'Aadhaar Card', 'Bank Account'],
      applyUrl: 'https://pmfby.gov.in',
    },
  ];

  async getSchemes(): Promise<Scheme[]> {
    return this.schemes;
  }

  async checkEligibility(dto: CheckEligibilityDto) {
    const eligible: Scheme[] = [];

    for (const s of this.schemes) {
      if (s.id === 'sch_pmkisan' && dto.landSizeAcres > 0) {
        eligible.push(s);
      } else if (s.id === 'sch_kusum' && dto.landSizeAcres >= 0.5) {
        eligible.push(s);
      } else if (s.id === 'sch_pmfby') {
        eligible.push(s);
      }
    }

    return {
      totalFound: eligible.length,
      schemes: eligible,
    };
  }
}
