//
//  SubscriptionTier.swift
//  PureAudio
//
//  Professional subscription tier management
//

import Foundation

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case basic = "com.pureaudio.basic.monthly"
    case pro = "com.pureaudio.pro.monthly"
    case professional = "com.pureaudio.professional.monthly"
    case vip = "vip_access"  // Admin code access
    
    // MARK: - Tier Configuration
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .professional: return "Professional"
        case .vip: return "VIP Access"
        }
    }
    
    var dailyLimit: Int {
        switch self {
        case .free: return 1
        case .basic: return 3  // ~10/month
        case .pro: return 10   // ~30/month
        case .professional: return 20  // ~60/month
        case .vip: return Int.max
        }
    }
    
    var monthlyLimit: Int {
        switch self {
        case .free: return 30
        case .basic: return 10
        case .pro: return 30
        case .professional: return 60
        case .vip: return Int.max
        }
    }
    
    var maxAudioDuration: TimeInterval {
        switch self {
        case .free: return 15
        case .basic: return 30
        case .pro: return 60
        case .professional: return 90
        case .vip: return 120
        }
    }
    
    var hasWatermark: Bool {
        switch self {
        case .free: return true
        default: return false
        }
    }
    
    var priorityLevel: Int {
        switch self {
        case .free: return 0
        case .basic: return 1
        case .pro: return 2
        case .professional: return 3
        case .vip: return 99
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .basic: return "$19.99/month"
        case .pro: return "$59.99/month"
        case .professional: return "$119.99/month"
        case .vip: return "VIP Access"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "1 process per day",
                "15-second audio max",
                "PureAudio watermark",
                "Standard queue"
            ]
        case .basic:
            return [
                "10 processes per month",
                "30-second audio max",
                "No watermark",
                "Priority processing"
            ]
        case .pro:
            return [
                "30 processes per month",
                "60-second audio max",
                "No watermark",
                "Priority processing",
                "Batch upload (5 files)"
            ]
        case .professional:
            return [
                "60 processes per month",
                "90-second audio max",
                "No watermark",
                "Top priority processing",
                "Batch upload (unlimited)",
                "Email support"
            ]
        case .vip:
            return [
                "Unlimited processes",
                "120-second audio max",
                "No watermark",
                "VIP priority",
                "No restrictions"
            ]
        }
    }
    
    var badgeColor: String {
        switch self {
        case .free: return "gray"
        case .basic: return "blue"
        case .pro: return "purple"
        case .professional: return "pink"
        case .vip: return "gold"
        }
    }
    
    var iconName: String {
        switch self {
        case .free: return "star"
        case .basic: return "star.fill"
        case .pro: return "crown"
        case .professional: return "crown.fill"
        case .vip: return "sparkles"
        }
    }
}

// MARK: - Pay-as-you-go Packs

enum ProcessingPack: String, Codable, CaseIterable {
    case starter = "com.pureaudio.pack.3"
    case value = "com.pureaudio.pack.10"
    case pro = "com.pureaudio.pack.30"
    
    var displayName: String {
        switch self {
        case .starter: return "Starter Pack"
        case .value: return "Value Pack"
        case .pro: return "Pro Pack"
        }
    }
    
    var processCount: Int {
        switch self {
        case .starter: return 3
        case .value: return 10
        case .pro: return 30
        }
    }
    
    var price: String {
        switch self {
        case .starter: return "$5.99"
        case .value: return "$19.99"
        case .pro: return "$49.99"
        }
    }
    
    var savingsText: String? {
        switch self {
        case .starter: return nil
        case .value: return "Save 15%"
        case .pro: return "Save 25%"
        }
    }
}
