//
//  SubscriptionTier.swift
//  AudioPure
//
//  Professional subscription tier management
//

import Foundation

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case basic = "com.pureaudio.basic"
    case pro = "com.pureaudio.pro"
    case professional = "com.pureaudio.unlimited"
    
    // MARK: - Tier Configuration
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .professional: return "Unlimited"
        }
    }
    
    var dailyLimit: Int {
        switch self {
        case .free: return Int.max  // Not limited by daily, but by total
        case .basic: return Int.max
        case .pro: return Int.max
        case .professional: return Int.max
        }
    }
    
    var monthlyLimit: Int {
        switch self {
        case .free: return 2  // 2 total lifetime
        case .basic: return 5
        case .pro: return 20
        case .professional: return 50
        }
    }
    
    var maxAudioDuration: TimeInterval {
        switch self {
        case .free: return 15
        case .basic: return 30
        case .pro: return 60
        case .professional: return 120
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
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .basic: return "$9.99/month"
        case .pro: return "$29.99/month"
        case .professional: return "$59.99/month"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "2 processes total",
                "15-second audio max",
                "PureAudio watermark",
                "Standard queue"
            ]
        case .basic:
            return [
                "5 processes per month",
                "30-second audio max",
                "No watermark",
                "Priority processing"
            ]
        case .pro:
            return [
                "20 processes per month",
                "60-second audio max",
                "No watermark",
                "Priority processing"
            ]
        case .professional:
            return [
                "50 processes per month",
                "2-minute audio max",
                "No watermark",
                "VIP priority processing"
            ]
        }
    }
    
    var badgeColor: String {
        switch self {
        case .free: return "gray"
        case .basic: return "blue"
        case .pro: return "purple"
        case .professional: return "pink"
        }
    }
    
    var iconName: String {
        switch self {
        case .free: return "star"
        case .basic: return "star.fill"
        case .pro: return "crown"
        case .professional: return "crown.fill"
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
