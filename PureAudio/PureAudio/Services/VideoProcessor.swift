//
//  VideoProcessor.swift
//  AudioPure
//
//  AVFoundation-based video/audio merger for video output
//

import Foundation
import AVFoundation

/// Handles merging processed audio back into original video
class VideoProcessor {
    
    static let shared = VideoProcessor()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Check if file is a video format
    static func isVideoFile(_ url: URL) -> Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv"]
        return videoExtensions.contains(url.pathExtension.lowercased())
    }
    
    /// Merge processed audio with original video
    /// - Parameters:
    ///   - videoURL: Original video file
    ///   - audioURL: Processed audio file
    ///   - completion: Returns URL to merged video or error
    func mergeAudioWithVideo(
        videoURL: URL,
        audioURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        Task {
            do {
                let outputURL = try await mergeAsync(videoURL: videoURL, audioURL: audioURL)
                await MainActor.run {
                    completion(.success(outputURL))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Async version of merge
    func mergeAsync(videoURL: URL, audioURL: URL) async throws -> URL {
        // Create assets
        let videoAsset = AVURLAsset(url: videoURL)
        let audioAsset = AVURLAsset(url: audioURL)
        
        // Load tracks
        let videoTracks = try await videoAsset.loadTracks(withMediaType: .video)
        let audioTracks = try await audioAsset.loadTracks(withMediaType: .audio)
        
        guard let videoTrack = videoTracks.first else {
            throw VideoProcessorError.noVideoTrack
        }
        
        guard let audioTrack = audioTracks.first else {
            throw VideoProcessorError.noAudioTrack
        }
        
        // Get durations
        let videoDuration = try await videoAsset.load(.duration)
        let audioDuration = try await audioAsset.load(.duration)
        
        // Use shorter duration to avoid empty frames/silence
        let outputDuration = min(videoDuration, audioDuration)
        
        // Create composition
        let composition = AVMutableComposition()
        
        // Add video track
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoProcessorError.compositionFailed
        }
        
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: outputDuration),
            of: videoTrack,
            at: .zero
        )
        
        // Add audio track
        guard let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoProcessorError.compositionFailed
        }
        
        try compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: outputDuration),
            of: audioTrack,
            at: .zero
        )
        
        // Preserve video orientation
        let videoTransform = try await videoTrack.load(.preferredTransform)
        compositionVideoTrack.preferredTransform = videoTransform
        
        // Create output URL
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AudioPure_\(UUID().uuidString).mp4")
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: outputURL)
        
        // Export
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw VideoProcessorError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        await exportSession.export()
        
        switch exportSession.status {
        case .completed:
            return outputURL
        case .failed:
            throw exportSession.error ?? VideoProcessorError.exportFailed
        case .cancelled:
            throw VideoProcessorError.exportCancelled
        default:
            throw VideoProcessorError.exportFailed
        }
    }
}

// MARK: - Errors

enum VideoProcessorError: LocalizedError {
    case noVideoTrack
    case noAudioTrack
    case compositionFailed
    case exportFailed
    case exportCancelled
    case featureLocked
    
    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "Could not find video track in file"
        case .noAudioTrack:
            return "Could not find audio track in processed file"
        case .compositionFailed:
            return "Failed to create video composition"
        case .exportFailed:
            return "Failed to export video"
        case .exportCancelled:
            return "Video export was cancelled"
        case .featureLocked:
            return "Upgrade to Basic or higher to export videos with audio"
        }
    }
}
