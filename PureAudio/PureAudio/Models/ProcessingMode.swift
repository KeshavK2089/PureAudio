//
//  ProcessingMode.swift
//  PureAudio
//
//  Enum defining audio processing operations
//

import Foundation

/// Audio processing mode: isolate or remove specific sounds
enum ProcessingMode: String, CaseIterable, Identifiable {
    case isolate
    case remove
    
    var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// User-facing display name
    var displayName: String {
        switch self {
        case .isolate:
            return "Isolate Sound"
        case .remove:
            return "Remove Sound"
        }
    }
    
    /// Short display name for buttons
    var shortName: String {
        switch self {
        case .isolate:
            return "Isolate"
        case .remove:
            return "Remove"
        }
    }
    
    /// Description of what this mode does
    var description: String {
        switch self {
        case .isolate:
            return "Keep ONLY the specified sound, remove everything else"
        case .remove:
            return "Remove the specified sound, keep everything else"
        }
    }
    
    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .isolate:
            return "speaker.wave.2.fill"
        case .remove:
            return "speaker.slash.fill"
        }
    }
    
    /// Example use case
    var example: String {
        switch self {
        case .isolate:
            return "Extract vocals from a song, or isolate a specific instrument"
        case .remove:
            return "Remove background noise, wind, or unwanted sounds"
        }
    }
    
    /// Emoji for display
    var emoji: String {
        switch self {
        case .isolate:
            return "🎯"
        case .remove:
            return "🗑️"
        }
    }
}
