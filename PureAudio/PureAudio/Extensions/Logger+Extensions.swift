//
//  Logger+Extensions.swift
//  AudioPure
//
//  Production-ready logging using Apple's OSLog framework
//

import Foundation
import os.log

/// App-wide logger using Apple's unified logging system
extension Logger {
    
    /// Bundle identifier for logging subsystem
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.audiopure.app"
    
    /// Logger for audio processing operations
    static let audioProcessor = Logger(subsystem: subsystem, category: "AudioProcessor")
    
    /// Logger for Modal API service
    static let modalService = Logger(subsystem: subsystem, category: "ModalService")
    
    /// Logger for video processing operations
    static let videoProcessor = Logger(subsystem: subsystem, category: "VideoProcessor")
    
    /// Logger for StoreKit operations
    static let storeKit = Logger(subsystem: subsystem, category: "StoreKit")
    
    /// Logger for general app events
    static let app = Logger(subsystem: subsystem, category: "App")
}

/// Conditional logging wrapper for debug builds
enum AppLog {
    
    /// Log debug message (only in DEBUG builds)
    static func debug(_ message: String, category: Logger = .app) {
        #if DEBUG
        category.debug("\(message, privacy: .public)")
        #endif
    }
    
    /// Log info message
    static func info(_ message: String, category: Logger = .app) {
        category.info("\(message, privacy: .public)")
    }
    
    /// Log error message
    static func error(_ message: String, category: Logger = .app) {
        category.error("\(message, privacy: .public)")
    }
    
    /// Log fault (critical error)
    static func fault(_ message: String, category: Logger = .app) {
        category.fault("\(message, privacy: .public)")
    }
}
