import { Injectable, Logger } from '@nestjs/common';

export class SaanviQueryDto {
  query: string;
  language: 'hi' | 'mr' | 'te' | 'ta' | 'en' | 'pa' | 'gu';
  context?: {
    location?: string;
    crop?: string;
    soilType?: string;
  };
}

export interface SaanviResponse {
  intent: 'DISEASE_DIAGNOSIS' | 'MANDI_PRICE' | 'WEATHER_ALERT' | 'GOV_SCHEME' | 'GENERAL_ADVISORY';
  replyText: string;
  suggestedActions: { label: string; actionType: string; payload?: any }[];
  audioUrl?: string;
  confidence: number;
}

@Injectable()
export class SaanviService {
  private readonly logger = new Logger(SaanviService.name);

  async processQuery(dto: SaanviQueryDto): Promise<SaanviResponse> {
    this.logger.log(`Saanvi query in [${dto.language}]: "${dto.query}"`);
    const q = (dto.query || '').toLowerCase();

    // Multilingual vernacular intent routing
    if (
      q.includes('price') ||
      q.includes('bhav') ||
      q.includes('mandi') ||
      q.includes('rate') ||
      q.includes('भाव') ||
      q.includes('मंडी') ||
      q.includes('దర') ||
      q.includes('விலை')
    ) {
      return this.handleMandiIntent(dto);
    } else if (
      q.includes('disease') ||
      q.includes('keeda') ||
      q.includes('rog') ||
      q.includes('spot') ||
      q.includes('peela') ||
      q.includes('रोग') ||
      q.includes('कीड़ा') ||
      q.includes('తెగులు') ||
      q.includes('நோய்')
    ) {
      return this.handleDiseaseIntent(dto);
    } else if (
      q.includes('scheme') ||
      q.includes('yojana') ||
      q.includes('subsidy') ||
      q.includes('paisa') ||
      q.includes('योजना') ||
      q.includes('सब्सिडी') ||
      q.includes('పథకం') ||
      q.includes('திட்டம்')
    ) {
      return this.handleSchemeIntent(dto);
    } else if (
      q.includes('weather') ||
      q.includes('barish') ||
      q.includes('rain') ||
      q.includes('mausam') ||
      q.includes('मौसम') ||
      q.includes('बारिश') ||
      q.includes('వర్షం') ||
      q.includes('மழை')
    ) {
      return this.handleWeatherIntent(dto);
    }

    return this.handleGeneralAdvisory(dto);
  }

  private handleMandiIntent(dto: SaanviQueryDto): SaanviResponse {
    const replies: Record<string, string> = {
      hi: 'आज इंदौर मंडी में सोयाबीन का भाव ₹4,850/क्विंटल और लासलगांव में प्याज ₹1,820/क्विंटल चल रहा है। आगामी 3 दिनों में तेजी की संभावना है।',
      mr: 'आज लासलगाव मार्केटमध्ये कांद्याचा भाव ₹1,820/क्विंटल आहे आणि सोयाबीन ₹4,850/क्विंटल आहे. विक्रीसाठी अनुकूल काळ आहे.',
      te: 'ఈరోజు గుంటూరు మార్కెట్‌లో మిర్చి ధర క్వింటాల్‌కు ₹18,500 మరియు పత్తి ₹7,200 పలుకుతోంది.',
      ta: 'இன்று திண்டுக்கல் சந்தையில் வெங்காயம் குவிண்டாலுக்கு ₹2,100 மற்றும் பருத்தி ₹7,150 ஆக உள்ளது.',
      en: 'Today Soybean in Indore Mandi is ₹4,850/qtl and Onion in Lasalgaon is ₹1,820/qtl. Upward price trend expected.',
    };

    return {
      intent: 'MANDI_PRICE',
      replyText: replies[dto.language] || replies.en,
      suggestedActions: [
        { label: 'View Mandi Trends', actionType: 'NAVIGATE_TAB', payload: { tab: 'market' } },
        { label: 'Set Price Alert', actionType: 'TRIGGER_ALERT', payload: { crop: 'Soybean' } },
      ],
      confidence: 0.96,
    };
  }

  private handleDiseaseIntent(dto: SaanviQueryDto): SaanviResponse {
    const replies: Record<string, string> = {
      hi: 'पत्तियों पर पीले या भूरे धब्बे फंगल संक्रमण (सर्कोस्पोरा) के लक्षण हो सकते हैं। कृपया Vision X कैमरे से पत्ती का फोटो स्कैन करें।',
      mr: 'पानांवरील पिवळे किंवा तपकिरी डाग बुरशीजन्य रोगाचे लक्षण असू शकतात. कृपया व्हिजन एक्स कॅमेऱ्याने स्कॅन करा.',
      te: 'ఆకులపై పసుపు మచ్చలు ఫంగస్ లక్షణం కావచ్చు. దయచేసి విజన్ ఎక్స్ కెమెరాతో స్కాన్ చేయండి.',
      ta: 'இலைகளில் மஞ்சள் புள்ளிகள் பூஞ்சை தொற்றாக இருக்கலாம். தயவுசெய்து விஷன் எக்ஸ் கேமராவில் ஸ்கேன் செய்யவும்.',
      en: 'Yellow or brown spots indicate fungal foliar disease. Please scan the infected leaf using Vision X camera for instant diagnosis.',
    };

    return {
      intent: 'DISEASE_DIAGNOSIS',
      replyText: replies[dto.language] || replies.en,
      suggestedActions: [
        { label: 'Scan with Vision X', actionType: 'NAVIGATE_TAB', payload: { tab: 'vision' } },
        { label: 'Neem Oil Recipe', actionType: 'VIEW_TREATMENT', payload: { type: 'organic' } },
      ],
      confidence: 0.94,
    };
  }

  private handleSchemeIntent(dto: SaanviQueryDto): SaanviResponse {
    const replies: Record<string, string> = {
      hi: 'पीएम-किसान 17वीं किस्त और पीएम कुसुम सोलर पंप सब्सिडी के लिए ऑनलाइन आवेदन खुले हैं। आप योजना हब में तुरंत पात्रता जांच सकते हैं।',
      mr: 'पीएम-किसान सन्मान निधी आणि कुसुम सोलर पंप योजनेसाठी अर्ज सुरू आहेत. योजना हब मध्ये पात्रता तपासा.',
      te: 'పీఎం-కిసాన్ 17వ విడత మరియు కుసుమ్ సోలార్ పంప్ పథకాలు అందుబాటులో ఉన్నాయి.',
      ta: 'பிஎம்-கிசான் மற்றும் குசும் சோலார் பம்ப் மானிய திட்டங்கள் நடைமுறையில் உள்ளன.',
      en: 'PM-KISAN 17th installment & PM-Kusum Solar Pump 60% subsidies are accepting applications. Check your eligibility in YojanaHub.',
    };

    return {
      intent: 'GOV_SCHEME',
      replyText: replies[dto.language] || replies.en,
      suggestedActions: [
        { label: 'Open YojanaHub', actionType: 'NAVIGATE_TAB', payload: { tab: 'yojana' } },
        { label: 'Check PM-KISAN Status', actionType: 'CHECK_STATUS' },
      ],
      confidence: 0.97,
    };
  }

  private handleWeatherIntent(dto: SaanviQueryDto): SaanviResponse {
    const replies: Record<string, string> = {
      hi: 'अगले 48 घंटों में आपके क्षेत्र में हल्की बारिश और 85% आर्द्रता की संभावना है। कृपया कीटनाशक का छिड़काव 2 दिन के लिए टालें।',
      mr: 'पुढील ४८ तासांत हलक्या पावसाची शक्यता आहे. फवारणी २ दिवस पुढे ढकला.',
      te: 'తదుపరి 48 గంటల్లో తేలికపాటి వర్షం కురిసే అవకాశం ఉంది.',
      ta: 'அடுத்த 48 மணி நேரத்தில் மிதமான மழை பெய்ய வாய்ப்புள்ளது.',
      en: 'Light rainfall (12mm) and 85% humidity forecast over the next 48h. Postpone pesticide spraying until clear skies.',
    };

    return {
      intent: 'WEATHER_ALERT',
      replyText: replies[dto.language] || replies.en,
      suggestedActions: [
        { label: '7-Day Forecast', actionType: 'VIEW_WEATHER' },
        { label: 'Spraying Calendar', actionType: 'VIEW_CALENDAR' },
      ],
      confidence: 0.95,
    };
  }

  private handleGeneralAdvisory(dto: SaanviQueryDto): SaanviResponse {
    const replies: Record<string, string> = {
      hi: 'नमस्ते! मैं सान्वी हूँ, आपकी डिजिटल कृषि सखी। आप मुझसे फसल रोग, मंडी भाव, मौसम या सरकारी योजनाओं के बारे में पूछ सकते हैं।',
      mr: 'नमस्कार! मी सान्वी, तुमची शेती सखी. मला पीक रोग, बाजारभाव, हवामान किंवा योजनांबद्दल विचारा.',
      te: 'నమస్కారం! నేను సాన్వి, మీ డిజిటల్ వ్యవసాయ సహాయకురాలిని.',
      ta: 'வணக்கம்! நான் சாண்வி, உங்கள் டிஜிட்டல் விவசாய தோழி.',
      en: 'Namaste! I am Saanvi, your digital agricultural companion. Ask me about crop health, mandi prices, weather, or government schemes.',
    };

    return {
      intent: 'GENERAL_ADVISORY',
      replyText: replies[dto.language] || replies.en,
      suggestedActions: [
        { label: 'Check Mandi Prices', actionType: 'NAVIGATE_TAB', payload: { tab: 'market' } },
        { label: 'Scan Leaf for Disease', actionType: 'NAVIGATE_TAB', payload: { tab: 'vision' } },
      ],
      confidence: 0.9,
    };
  }
}
