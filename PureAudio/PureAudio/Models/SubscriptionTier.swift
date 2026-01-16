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
        case .basic: return .primaryBlue
        case .pro: return .deepPurple
        case .professional: return .indigo
        }
    }
    
    // MARK: - Limits
    
    var monthlyLimit: Int {
        switch self {
        case .free: return 3
        case .basic: return 10
        case .pro: return 30
        case .professional: return 999  // Effectively unlimited
        }
    }
    
    var maxAudioDuration: TimeInterval {
        switch self {
        case .free: return 15
        case .basic: return 60
        case .pro: return 150      // 2.5 minutes
        case .professional: return 300  // 5 minutes
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
    
    /// Video export with processed audio - FREE for all users (on-device AVFoundation, no backend cost)
    var canExportVideo: Bool {
        return true  // Available to all tiers - no server cost
    }
    
    /// Can use tap-to-isolate in video mode (Unlimited only)
    var canTapToIsolate: Bool {
        self == .professional
    }
    
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
                "3 processes total",
                "15-second audio max",
                "Video output included",
                "AudioPure watermark"
            ]
        case .basic:
            return [
                "10 processes/month",
                "Up to 1-minute clips",
                "Video output included",
                "No watermark"
            ]
        case .pro:
            return [
                "30 processes/month",
                "Up to 2.5 minute clips",
                "High Quality Mode",
                "Priority processing"
            ]
        case .professional:
            return [
                "Unlimited processes",
                "Up to 5 minute clips",
                "High Quality Mode",
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
