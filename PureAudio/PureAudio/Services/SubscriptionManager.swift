//
//  SubscriptionManager.swift
//  PureAudio
//
//  Professional subscription and admin code management
//

import Foundation
import StoreKit
internal import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var isSubscribed: Bool = false
    @Published var remainingProcesses: Int = 0
    @Published var hasVIPAccess: Bool = false
    @Published var vipCodeUsed: String? = nil
    
    // MARK: - Singleton
    
    static let shared = SubscriptionManager()
    
    // MARK: - Keys
    
    private let tierKey = "subscription_tier"
    private let vipCodeKey = "vip_access_code"
    private let processCountKey = "remaining_processes"
    private let lastResetDateKey = "last_reset_date"
    
    // MARK: - Admin Codes
    
    private let validCodes: [String: (tier: SubscriptionTier, expires: Date?)] = [
        "PUREAUDIO19": (.vip, nil),  // Admin unlimited access (case-insensitive)
    ]
    
    // MARK: - Initialization
    
    private init() {
        loadSubscriptionState()
        resetDailyLimitIfNeeded()
    }
    
    // MARK: - State Management
    
    private func loadSubscriptionState() {
        // Load tier
        if let tierString = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: tierString) {
            currentTier = tier
            isSubscribed = (tier != .free)
        }
        
        // Load VIP access
        if let code = UserDefaults.standard.string(forKey: vipCodeKey) {
            vipCodeUsed = code
            hasVIPAccess = validateCode(code).isValid
            if hasVIPAccess {
                currentTier = .vip
            }
        }
        
        // Load remaining processes
        remainingProcesses = UserDefaults.standard.integer(forKey: processCountKey)
        if remainingProcesses == 0 {
            remainingProcesses = currentTier.dailyLimit
        }
    }
    
    func updateTier(_ tier: SubscriptionTier) {
        currentTier = tier
        isSubscribed = (tier != .free)
        remainingProcesses = tier.dailyLimit
        
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
        UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
    }
    
    // MARK: - Admin Code System
    
    func redeemCode(_ code: String) -> (success: Bool, message: String) {
        let validation = validateCode(code)
        
        guard validation.isValid else {
            return (false, validation.message ?? "Invalid code")
        }
        
        // Save code
        vipCodeUsed = code
        hasVIPAccess = true
        currentTier = validation.tier ?? .vip
        remainingProcesses = Int.max
        
        UserDefaults.standard.set(code, forKey: vipCodeKey)
        UserDefaults.standard.set(currentTier.rawValue, forKey: tierKey)
        
        return (true, "✨ VIP Access Activated!\nYou now have unlimited processing.")
    }
    
    private func validateCode(_ code: String) -> (isValid: Bool, tier: SubscriptionTier?, message: String?) {
        guard let codeInfo = validCodes[code.uppercased()] else {
            return (false, nil, "Invalid code. Please check and try again.")
        }
        
        // Check if expired
        if let expiry = codeInfo.expires, expiry < Date() {
            return (false, nil, "This code has expired.")
        }
        
        return (true, codeInfo.tier, nil)
    }
    
    func removeVIPAccess() {
        vipCodeUsed = nil
        hasVIPAccess = false
        currentTier = .free
        remainingProcesses = currentTier.dailyLimit
        
        UserDefaults.standard.removeObject(forKey: vipCodeKey)
        UserDefaults.standard.set(currentTier.rawValue, forKey: tierKey)
    }
    
    // MARK: - Usage Tracking
    
    func canProcess() -> (allowed: Bool, reason: String?) {
        // VIP always allowed
        if hasVIPAccess || currentTier == .vip {
            return (true, nil)
        }
        
        // Check remaining processes
        if remainingProcesses <= 0 {
            return (false, "Daily limit reached (\(currentTier.dailyLimit) processes).\n\n" +
                    "Upgrade to \(suggestedUpgradeTier().displayName) for more processes!")
        }
        
        return (true, nil)
    }
    
    func validateDuration(_ duration: TimeInterval) -> (valid: Bool, reason: String?) {
        if hasVIPAccess || currentTier == .vip {
            // VIP gets max duration
            if duration > 120 {
                return (false, "Maximum 120 seconds for VIP tier")
            }
            return (true, nil)
        }
        
        if duration > currentTier.maxAudioDuration {
            let maxSeconds = Int(currentTier.maxAudioDuration)
            let actualSeconds = Int(duration)
            return (false, "Audio too long! (\(actualSeconds)s)\n\n" +
                    "\(currentTier.displayName) tier allows max \(maxSeconds)s.\n" +
                    "Upgrade to \(suggestedUpgradeTier().displayName) for longer audio!")
        }
        
        return (true, nil)
    }
    
    func consumeProcess() {
        guard !hasVIPAccess else { return }
        
        remainingProcesses = max(0, remainingProcesses - 1)
        UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
    }
    
    func resetDailyLimitIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastResetDay = Calendar.current.startOfDay(for: lastReset)
            
            if lastResetDay != today {
                // New day, reset counter
                remainingProcesses = currentTier.dailyLimit
                UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
        } else {
            // First time
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }
    
    // MARK: - Helper Methods
    
    private func suggestedUpgradeTier() -> SubscriptionTier {
        switch currentTier {
        case .free: return .basic
        case .basic: return .pro
        case .pro: return .professional
        case .professional: return .professional
        case .vip: return .vip
        }
    }
    
    func getUsageDescription() -> String {
        if hasVIPAccess {
            return "Unlimited • VIP Access"
        }
        
        return "\(remainingProcesses) of \(currentTier.dailyLimit) remaining today"
    }
}
