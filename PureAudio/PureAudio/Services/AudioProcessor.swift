//
//  AudioProcessor.swift
//  AudioPure
//
//  Orchestrates the audio processing workflow
//

import Foundation
import AVFoundation
internal import Combine

/// Main audio processor coordinating the workflow
@MainActor
class AudioProcessor: ObservableObject {
    
    @Published var currentJob: ProcessingJob?
    @Published var isProcessing: Bool = false
    @Published var error: String?
    
    private let modalService = ModalService()
    
    // MARK: - Main Processing Method
    
    /// Process an audio file
    func processAudio(
        file: AudioFile,
        prompt: String,
        mode: ProcessingMode
    ) async {
        // Validate file
        print("🎬 Starting processAudio for: \(file.filename)")
        do {
            try validateFile(file)
            print("✅ File validated")
        } catch {
            print("❌ File validation failed: \(error)")
            self.error = error.localizedDescription
            return
        }
        
        // Create job
        var job = ProcessingJob(inputFile: file, prompt: prompt, mode: mode)
        job.start()
        
        self.currentJob = job
        self.isProcessing = true
        self.error = nil
        
        do {
            // Load audio data
            print("📂 Loading audio data...")
            let audioData = try Data(contentsOf: file.url)
            print("✅ Loaded \(audioData.count) bytes")
            
            // Update status to uploading
            job.updateProgress(0.1, status: .uploading)
            self.currentJob = job
            
            // Simulate upload progress
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            job.updateProgress(0.2, status: .processing)
            self.currentJob = job
            
            // Call Modal API
            print("🚀 Calling Modal API...")
            let result = try await modalService.processAudio(
                audioData: audioData,
                prompt: prompt,
                mode: mode
            )
            print("✅ Modal API returned result")
            
            // Update to downloading
            job.updateProgress(0.8, status: .downloading)
            self.currentJob = job
            
            // Download result
            print("📥 Getting result file...")
            let localURL = try await downloadResult(from: result.outputURL)
            print("✅ Result ready at: \(localURL)")
            
            // Complete
            job.complete(outputURL: localURL)
            self.currentJob = job
            self.isProcessing = false
            print("🎉 Processing complete!")
            
        } catch {
            print("❌ Processing failed: \(error)")
            job.fail(error: makeUserFriendlyError(error))
            self.currentJob = job
            self.isProcessing = false
            self.error = job.error
        }
    }
    
    /// Cancel current processing job
    func cancel() {
        isProcessing = false
        if var job = currentJob {
            job.fail(error: "Cancelled by user")
            currentJob = job
        }
    }
    
    /// Reset to start a new job
    func reset() {
        currentJob = nil
        isProcessing = false
        error = nil
    }
    
    // MARK: - Helper Methods
    
    /// Validate file is ready for processing
    private func validateFile(_ file: AudioFile) throws {
        guard file.isValid else {
            throw NSError(
                domain: "PureAudio",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: file.validationError ?? "Invalid file"]
            )
        }
    }
    
    /// Download processed audio to local storage
    private func downloadResult(from url: URL) async throws -> URL {
        print("📥 Download result from: \(url)")
        
        // Check if URL is already a local file (from base64 decoding)
        if url.isFileURL {
            print("✅ URL is already local file, no download needed")
            return url
        }
        
        // Only download if it's a remote URL
        print("🌐 Downloading from remote URL...")
        
        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "processed_\(UUID().uuidString).wav"
        let localURL = tempDir.appendingPathComponent(filename)
        
        // Download file
        let (downloadedURL, response) = try await URLSession.shared.download(from: url)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "PureAudio",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to download processed audio"]
            )
        }
        
        // Move to temporary directory
        try? FileManager.default.removeItem(at: localURL) // Remove if exists
        try FileManager.default.moveItem(at: downloadedURL, to: localURL)
        
        print("✅ Downloaded to: \(localURL)")
        return localURL
    }
    
    /// Convert technical errors to user-friendly messages
    private func makeUserFriendlyError(_ error: Error) -> String {
        if let modalError = error as? ModalServiceError {
            return modalError.localizedDescription
        }
        
        // Handle common network errors
        let nsError = error as NSError
        
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return "No internet connection. Please check your network."
            case NSURLErrorTimedOut:
                return "Request timed out. Please try again."
            case NSURLErrorCannotFindHost:
                return "Cannot connect to server. Please try again later."
            default:
                return "Network error occurred. Please try again."
            }
        }
        
        return "Processing failed. Please try again."
    }
}
