//
//  Config.swift
//  PureAudio
//
//  Configuration and constants for the PureAudio app
//

import Foundation

/// Central configuration for the PureAudio app
struct Config {
    // MARK: - Modal API Configuration
    
    /// Base URL for Modal API endpoint
    static let modalAPIBase = "https://keshavk2089--pureaudio-fastapi-app.modal.run"
    
    /// Processing endpoint
    static let processEndpoint = "/process"
    
    // MARK: - File Constraints
    
    /// Maximum file size in megabytes
    static let maxFileSizeMB: Double = 100.0
    
    /// Maximum file size in bytes
    static var maxFileSizeBytes: Int64 {
        Int64(maxFileSizeMB * 1_000_000)
    }
    
    /// Supported audio/video file formats
    static let supportedFormats = ["mp3", "wav", "m4a", "aac", "flac", "mp4", "mov", "aiff"]
    
    // MARK: - Processing
    
    /// Timeout for upload requests (seconds)
    /// Set to 10 minutes for maximum buffer (SAM Audio first request can take 60-120s)
    static let uploadTimeoutSeconds: TimeInterval = 600
    
    /// Timeout for processing requests (seconds)
    static let processingTimeoutSeconds: TimeInterval = 600
    
    /// Poll interval for async jobs (seconds)
    static let pollIntervalSeconds: TimeInterval = 2.0
    
    // MARK: - NEW: Audio Duration Limits
    
    /// HARD LIMIT: Maximum audio duration (30 seconds)
    /// Prevents excessive backend costs
    static let maxAudioDurationSeconds: TimeInterval = 30
    
    /// RECOMMENDED: Optimal duration for best results (15 seconds)
    /// Faster processing, lower costs
    static let recommendedAudioDurationSeconds: TimeInterval = 15
    
    // MARK: - App Settings
    
    /// UserDefaults key for onboarding completion
    private static let onboardingKey = "hasCompletedOnboarding"
    
    /// Check if user has completed onboarding
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: onboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingKey)
        }
    }
    
    // MARK: - Validation
    
    /// Validate if a file extension is supported
    static func isFormatSupported(_ fileExtension: String) -> Bool {
        supportedFormats.contains(fileExtension.lowercased())
    }
    
    /// Validate if a file size is within limits
    static func isFileSizeValid(_ sizeInBytes: Int64) -> Bool {
        sizeInBytes > 0 && sizeInBytes <= maxFileSizeBytes
    }
    
    /// Get formatted file size limit
    static var formattedMaxFileSize: String {
        String(format: "%.0f MB", maxFileSizeMB)
    }
}
