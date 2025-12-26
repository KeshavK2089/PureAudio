//
//  SubscriptionManager.swift
//  AudioPure
//
//  Subscription management with StoreKit 2 integration
//  Uses Keychain for persistence across reinstalls (Apple compliance)
//

import Foundation
import StoreKit
internal import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var isSubscribed: Bool = false
    @Published var remainingProcesses: Int = 2  // Free tier starts with 2 total
    @Published var totalFreeProcessesUsed: Int = 0
    
    // MARK: - Constants
    
    private let maxFreeProcesses = 2  // Total free processes (lifetime)
    
    // MARK: - Singleton
    
    static let shared = SubscriptionManager()
    
    // MARK: - Keys (for subscriber monthly tracking only)
    
    private let processCountKey = "remaining_processes"
    private let lastResetDateKey = "last_reset_date"
    
    // MARK: - Initialization
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        loadState()
        observeStoreKit()
    }
    
    // MARK: - State Management
    
    private func loadState() {
        // Record first install date in Keychain
        KeychainManager.shared.recordFirstInstallIfNeeded()
        
        // Load free processes used from KEYCHAIN
        totalFreeProcessesUsed = KeychainManager.shared.freeProcessesUsed
        remainingProcesses = max(0, maxFreeProcesses - totalFreeProcessesUsed)
        
        // Initial check
        updateTierFromStoreKit()
        
        // Load saved remaining processes for subscribers
        if let savedRemaining = UserDefaults.standard.object(forKey: processCountKey) as? Int, isSubscribed {
            // Only use saved if we haven't switched tiers to something with fewer processes
            if savedRemaining <= currentTier.monthlyLimit {
                remainingProcesses = savedRemaining
            }
        }
    }
    
    private func observeStoreKit() {
        // Observe StoreKitManager changes directly to fix race condition
        StoreKitManager.shared.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTierFromStoreKit()
            }
            .store(in: &cancellables)
            
        // Also listen for direct Transaction updates as backup
        Task {
            for await _ in Transaction.updates {
                await MainActor.run {
                    self.updateTierFromStoreKit()
                }
            }
        }
    }
    
    func updateTierFromStoreKit() {
        let storeKit = StoreKitManager.shared
        
        if storeKit.hasActiveSubscription {
            let newTier = storeKit.currentSubscriptionTier
            
            // If tier changed, reset limits to that tier's max
            if newTier != currentTier {
                currentTier = newTier
                isSubscribed = true
                remainingProcesses = newTier.monthlyLimit
                UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
            } else {
                // Tier is same, ensure subscribed state is accurate
                isSubscribed = true
                // DON'T reset remainingProcesses here - relies on persistence or resetMonthlyLimitIfNeeded
            }
            
            resetMonthlyLimitIfNeeded()
        } else {
            currentTier = .free
            isSubscribed = false
            remainingProcesses = max(0, maxFreeProcesses - totalFreeProcessesUsed)
        }
    }
    
    func updateTier(_ tier: SubscriptionTier) {
        // Manual override (for testing or immediate local updates)
        if tier != currentTier {
            currentTier = tier
            isSubscribed = (tier != .free)
            remainingProcesses = tier.monthlyLimit
            UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
        }
    }
    
    // MARK: - Usage Tracking
    
    func canProcess() -> (allowed: Bool, reason: String?) {
        // Subscribed users check monthly limit
        if isSubscribed {
            if remainingProcesses <= 0 {
                return (false, "Monthly limit reached (\(currentTier.monthlyLimit) processes).\n\nYour limit resets at the start of your next billing period.")
            }
            return (true, nil)
        }
        
        // Free users check total lifetime limit
        if totalFreeProcessesUsed >= maxFreeProcesses {
            return (false, "You've used your \(maxFreeProcesses) free processes.\n\nSubscribe to continue processing audio!")
        }
        
        return (true, nil)
    }
    
    func validateDuration(_ duration: TimeInterval) -> (valid: Bool, reason: String?) {
        if duration > currentTier.maxAudioDuration {
            let maxSeconds = Int(currentTier.maxAudioDuration)
            let actualSeconds = Int(duration)
            return (false, "Audio too long! (\(actualSeconds)s)\n\n\(currentTier.displayName) allows max \(maxSeconds)s.\nUpgrade for longer audio!")
        }
        
        return (true, nil)
    }
    
    func consumeProcess() {
        if isSubscribed {
            remainingProcesses = max(0, remainingProcesses - 1)
            UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
        } else {
            // Use Keychain for free users - persists across reinstalls!
            KeychainManager.shared.incrementFreeProcessesUsed()
            totalFreeProcessesUsed = KeychainManager.shared.freeProcessesUsed
            remainingProcesses = max(0, maxFreeProcesses - totalFreeProcessesUsed)
        }
    }
    
    func resetMonthlyLimitIfNeeded() {
        guard isSubscribed else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let thisMonth = Calendar.current.component(.month, from: today)
        
        if let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastResetMonth = Calendar.current.component(.month, from: lastReset)
            
            if lastResetMonth != thisMonth {
                // New month, reset counter
                remainingProcesses = currentTier.monthlyLimit
                UserDefaults.standard.set(remainingProcesses, forKey: processCountKey)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
        } else {
            // First time
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }
    
    // MARK: - Helper Methods
    
    func getUsageDescription() -> String {
        if isSubscribed {
            return "\(remainingProcesses) of \(currentTier.monthlyLimit) remaining this month"
        }
        
        let remaining = maxFreeProcesses - totalFreeProcessesUsed
        if remaining <= 0 {
            return "No free processes remaining"
        }
        return "\(remaining) free process\(remaining == 1 ? "" : "es") remaining"
    }
    
    var needsSubscription: Bool {
        !isSubscribed && totalFreeProcessesUsed >= maxFreeProcesses
    }
}
