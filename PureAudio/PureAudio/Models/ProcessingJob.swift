//
//  ProcessingJob.swift
//  AudioPure
//
//  Model tracking the state of an audio processing job
//

import Foundation

/// Represents a processing job with its current state
struct ProcessingJob: Identifiable {
    let id = UUID()
    let inputFile: AudioFile
    let prompt: String
    let mode: ProcessingMode
    
    var status: ProcessingStatus = .idle
    var progress: Double = 0.0 // 0.0 to 1.0
    var jobID: String?
    var outputURL: URL?
    var error: String?
    var startTime: Date?
    var endTime: Date?
    
    // MARK: - Processing Status
    
    enum ProcessingStatus: Equatable {
        case idle
        case uploading
        case processing
        case downloading
        case completed
        case failed
        
        var displayName: String {
            switch self {
            case .idle:
                return "Ready"
            case .uploading:
                return "Uploading to cloud..."
            case .processing:
                return "AI analyzing audio..."
            case .downloading:
                return "Downloading result..."
            case .completed:
                return "Complete!"
            case .failed:
                return "Failed"
            }
        }
        
        var isInProgress: Bool {
            switch self {
            case .uploading, .processing, .downloading:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Processing time in seconds
    var processingTimeSeconds: TimeInterval? {
        guard let start = startTime else { return nil }
        let end = endTime ?? Date()
        return end.timeIntervalSince(start)
    }
    
    /// Formatted processing time (e.g., "52 seconds")
    var formattedTime: String {
        guard let time = processingTimeSeconds else {
            return "—"
        }
        
        if time < 60 {
            return String(format: "%.0f seconds", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%d min %d sec", minutes, seconds)
        }
    }
    
    /// Progress percentage (0-100)
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    /// Estimated time remaining (rough estimate)
    var estimatedTimeRemaining: String {
        guard status.isInProgress else { return "—" }
        
        // Rough estimate based on progress
        let _ = 60 as TimeInterval // Average estimate (not used directly)
        let elapsed = processingTimeSeconds ?? 0
        
        if progress > 0 {
            let estimatedTotal = elapsed / progress
            let remaining = max(0, estimatedTotal - elapsed)
            
            if remaining < 60 {
                return String(format: "~%.0f sec", remaining)
            } else {
                return String(format: "~%.0f min", remaining / 60)
            }
        }
        
        return "~1 minute"
    }
    
    /// Whether the job can be cancelled
    var canCancel: Bool {
        status.isInProgress
    }
    
    // MARK: - Initialization
    
    init(inputFile: AudioFile, prompt: String, mode: ProcessingMode) {
        self.inputFile = inputFile
        self.prompt = prompt
        self.mode = mode
    }
    
    // MARK: - Mutating Methods
    
    /// Start the processing job
    mutating func start() {
        startTime = Date()
        status = .uploading
        progress = 0.0
        error = nil
        outputURL = nil
    }
    
    /// Update progress (0.0 to 1.0)
    mutating func updateProgress(_ newProgress: Double, status: ProcessingStatus) {
        self.progress = min(max(newProgress, 0.0), 1.0)
        self.status = status
    }
    
    /// Mark as completed with output URL
    mutating func complete(outputURL: URL) {
        self.status = .completed
        self.progress = 1.0
        self.outputURL = outputURL
        self.endTime = Date()
    }
    
    /// Mark as failed with error message
    mutating func fail(error: String) {
        self.status = .failed
        self.error = error
        self.endTime = Date()
    }
}
