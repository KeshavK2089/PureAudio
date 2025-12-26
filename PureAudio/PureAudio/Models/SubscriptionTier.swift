//
//  SubscriptionTier.swift
//  AudioPure
//
//  Professional subscription tier management with premium feature flags
//

import Foundation
import SwiftUI

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case basic = "com.pureaudio.basic"
    case pro = "com.pureaudio.pro"
    case professional = "com.pureaudio.unlimited"
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .professional: return "Unlimited"
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
    
    var accentColor: Color {
        switch self {
        case .free: return .secondary
        case .basic: return .blue
        case .pro: return .purple
        case .professional: return .pink
        }
    }
    
    // MARK: - Limits
    
    var monthlyLimit: Int {
        switch self {
        case .free: return 2
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
        self == .free
    }
    
    var priorityLevel: Int {
        switch self {
        case .free: return 0
        case .basic: return 1
        case .pro: return 2
        case .professional: return 3
        }
    }
    
    // MARK: - Premium Feature Flags
    
    /// Can export video with processed audio (Basic+)
    var canExportVideo: Bool {
        switch self {
        case .free: return false
        case .basic, .pro, .professional: return true
        }
    }
    
    /// Can extract audio from TikTok/Instagram URLs (Pro+)
    var canExtractURL: Bool {
        switch self {
        case .free, .basic: return false
        case .pro, .professional: return true
        }
    }
    
    /// Can use tap-to-isolate in video mode (Unlimited only)
    var canTapToIsolate: Bool {
        self == .professional
    }
    
    /// Minimum tier required to unlock video export
    static var videoExportMinTier: SubscriptionTier { .basic }
    
    /// Minimum tier required for URL extraction
    static var urlExtractMinTier: SubscriptionTier { .pro }
    
    /// Minimum tier required for tap-to-isolate
    static var tapToIsolateMinTier: SubscriptionTier { .professional }
    
    // MARK: - Pricing
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .basic: return "$9.99/mo"
        case .pro: return "$29.99/mo"
        case .professional: return "$59.99/mo"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "2 processes total",
                "15-second audio max",
                "MP3 output only",
                "AudioPure watermark"
            ]
        case .basic:
            return [
                "5 processes/month",
                "30-second audio max",
                "Video output with audio",
                "No watermark"
            ]
        case .pro:
            return [
                "20 processes/month",
                "60-second audio max",
                "TikTok/Instagram import",
                "Priority processing"
            ]
        case .professional:
            return [
                "50 processes/month",
                "2-minute audio max",
                "Tap-to-isolate video mode",
                "VIP priority"
            ]
        }
    }
}

// MARK: - Feature Lock State

enum FeatureLockState {
    case unlocked
    case locked(requiredTier: SubscriptionTier)
    
    var isLocked: Bool {
        if case .locked = self { return true }
        return false
    }
}
