//
//  KeychainManager.swift
//  AudioPure
//
//  Secure storage that persists across app reinstalls
//  Prevents users from resetting free trial by deleting the app
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private let serviceName = "com.pureaudio.app"
    
    private init() {}
    
    // MARK: - Free Process Tracking
    
    private let freeProcessesKey = "free_processes_used"
    
    /// Get the number of free processes used (persists across reinstalls)
    var freeProcessesUsed: Int {
        get {
            guard let data = read(key: freeProcessesKey),
                  let value = String(data: data, encoding: .utf8),
                  let count = Int(value) else {
                return 0
            }
            return count
        }
        set {
            let data = String(newValue).data(using: .utf8)!
            save(key: freeProcessesKey, data: data)
        }
    }
    
    /// Increment the free processes used counter
    func incrementFreeProcessesUsed() {
        freeProcessesUsed += 1
    }
    
    // MARK: - First Install Date (for time-based trials if needed)
    
    private let firstInstallKey = "first_install_date"
    
    var firstInstallDate: Date? {
        get {
            guard let data = read(key: firstInstallKey),
                  let timeInterval = String(data: data, encoding: .utf8),
                  let interval = Double(timeInterval) else {
                return nil
            }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            guard let date = newValue else { return }
            let data = String(date.timeIntervalSince1970).data(using: .utf8)!
            save(key: firstInstallKey, data: data)
        }
    }
    
    /// Record first install if not already recorded
    func recordFirstInstallIfNeeded() {
        if firstInstallDate == nil {
            firstInstallDate = Date()
        }
    }
    
    // MARK: - Keychain Operations
    
    private func save(key: String, data: Data) {
        // Delete existing item first
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("KeychainManager: Failed to save \(key), status: \(status)")
        }
    }
    
    private func read(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Debug/Testing (remove in production)
    
    #if DEBUG
    func resetForTesting() {
        delete(key: freeProcessesKey)
        delete(key: firstInstallKey)
        print("KeychainManager: Reset for testing")
    }
    #endif
}
