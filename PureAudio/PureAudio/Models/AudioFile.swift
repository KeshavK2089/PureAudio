//
//  AudioFile.swift
//  PureAudio
//
//  Model representing an audio or video file
//

import Foundation
import AVFoundation

/// Represents an audio or video file with metadata
struct AudioFile: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let filename: String
    let fileSize: Int64 // in bytes
    let duration: TimeInterval // in seconds
    let format: String
    
    // MARK: - Initialization
    
    /// Initialize from a URL, extracting metadata
    init?(url: URL) {
        // Validate file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        self.url = url
        self.filename = url.lastPathComponent
        self.format = url.pathExtension.lowercased()
        
        // Get file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            self.fileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            print("Error getting file size: \(error)")
            return nil
        }
        
        // Get duration using AVAsset
        let asset = AVAsset(url: url)
        self.duration = asset.duration.seconds
        
        // Validate format is supported
        guard Config.isFormatSupported(format) else {
            print("Unsupported format: \(format)")
            return nil
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if file is valid (size and format)
    var isValid: Bool {
        Config.isFileSizeValid(fileSize) && Config.isFormatSupported(format)
    }
    
    /// Formatted file size (e.g., "5.2 MB")
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /// Formatted duration (e.g., "3:45")
    var formattedDuration: String {
        guard duration.isFinite && duration > 0 else {
            return "0:00"
        }
        
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// File extension in uppercase
    var formatUppercase: String {
        format.uppercased()
    }
    
    /// Icon name based on file type
    var iconName: String {
        switch format {
        case "mp4", "mov":
            return "video.fill"
        case "mp3", "wav", "m4a", "aac", "flac", "aiff":
            return "waveform"
        default:
            return "doc.fill"
        }
    }
    
    // MARK: - Validation Error Messages
    
    /// Get validation error message if file is invalid
    var validationError: String? {
        if !Config.isFormatSupported(format) {
            return "Unsupported file format: .\(format)\nSupported: \(Config.supportedFormats.joined(separator: ", "))"
        }
        
        if !Config.isFileSizeValid(fileSize) {
            if fileSize > Config.maxFileSizeBytes {
                return "File too large (\(formattedSize))\nMaximum: \(Config.formattedMaxFileSize)"
            } else {
                return "Invalid file size"
            }
        }
        
        // NEW: Duration validation (30s hard limit)
        if duration > Config.maxAudioDurationSeconds {
            let maxSeconds = Int(Config.maxAudioDurationSeconds)
            let actualSeconds = Int(duration)
            let recommendedSeconds = Int(Config.recommendedAudioDurationSeconds)
            return "Audio too long! (\(actualSeconds)s)\nMaximum: \(maxSeconds)s\nRecommended: \(recommendedSeconds)s for best results"
        }
        
        return nil
    }
    
    // MARK: - Equatable
    
    static func == (lhs: AudioFile, rhs: AudioFile) -> Bool {
        lhs.id == rhs.id
    }
}
