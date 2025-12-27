//
//  MainViewModel.swift
//  AudioPure
//
//  Main view model for app state management
//

import Foundation
import SwiftUI
import PhotosUI
internal import Combine

@MainActor
class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedFile: AudioFile?
    @Published var prompt: String = ""
    @Published var mode: ProcessingMode = .remove
    @Published var showingFilePicker = false
    @Published var showingDocumentPicker = false
    @Published var showingSettings = false
    @Published var showingOnboarding = false
    @Published var showingResult = false
    @Published var showingShareSheet = false
    @Published var showingSubscription = false
    @Published var highQualityMode = false  // Pro+ feature: quality re-ranking
    
    // Processing state
    private let audioProcessor = AudioProcessor()
    @Published var isProcessing = false
    @Published var currentJob: ProcessingJob?
    @Published var error: String?
    
    // Track if input was video for output merging
    private var inputWasVideo = false
    private var originalVideoURL: URL?
    
    // Subscription management
    let subscriptionManager = SubscriptionManager.shared
    
    // MARK: - Computed Properties
    
    /// Whether high quality mode can be used (Pro+ tier)
    var canUseHighQuality: Bool {
        subscriptionManager.currentTier.priorityLevel >= 2  // Pro or Unlimited
    }
    
    /// Whether the process button should be enabled
    var canProcess: Bool {
        selectedFile != nil && !prompt.isEmpty && !isProcessing
    }
    
    /// Current processing progress (0.0 to 1.0)
    var progress: Double {
        currentJob?.progress ?? 0.0
    }
    
    /// Current status message
    var statusMessage: String {
        currentJob?.status.displayName ?? "Ready"
    }
    
    /// Result audio URL if available
    var resultURL: URL? {
        currentJob?.outputURL
    }
    
    // MARK: - Initialization
    
    init() {
        // Check if onboarding is needed
        showingOnboarding = !Config.hasCompletedOnboarding
    }
    
    // MARK: - File Selection
    
    /// Handle selected document from Files app
    func handleSelectedDocument(_ url: URL?) {
        guard let url = url else { return }
        
        // Track if video for later merging
        inputWasVideo = VideoProcessor.isVideoFile(url)
        if inputWasVideo {
            originalVideoURL = url
        }
        
        // Files app provides direct URL access
        if let audioFile = AudioFile(url: url) {
            if let validationError = audioFile.validationError {
                error = validationError
                selectedFile = nil
            } else {
                selectedFile = audioFile
                error = nil
            }
        } else {
            error = "Failed to process selected file"
            selectedFile = nil
        }
    }
    
    /// Handle selected photo picker item
    func handleSelectedItem(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        // Load the file
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                error = "Failed to load selected file"
                return
            }
            
            // Detect file extension from supported type or content type
            var fileExtension = "wav"
            
            if let contentType = item.supportedContentTypes.first {
                // Map UTType to file extension
                switch contentType.identifier {
                case "public.mpeg-4":
                    fileExtension = "mp4"
                case "com.apple.quicktime-movie":
                    fileExtension = "mov"
                case "public.mp3":
                    fileExtension = "mp3"
                case "com.microsoft.waveform-audio":
                    fileExtension = "wav"
                case "public.mpeg-4-audio", "public.aac-audio":
                    fileExtension = "m4a"
                default:
                    // Try to detect from data
                    if data.starts(with: [0x66, 0x74, 0x79, 0x70]) { // ftyp (MP4/MOV)
                        fileExtension = "mp4"
                    } else if data.starts(with: [0x49, 0x44, 0x33]) { // ID3 (MP3)
                        fileExtension = "mp3"
                    } else if data.starts(with: [0x52, 0x49, 0x46, 0x46]) { // RIFF (WAV)
                        fileExtension = "wav"
                    }
                }
            }
            
            // Track if video for later merging
            inputWasVideo = ["mp4", "mov", "m4v"].contains(fileExtension)
            
            // Save to temporary directory with proper extension
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("input_\(UUID().uuidString).\(fileExtension)")
            
            try data.write(to: tempURL)
            
            // Store original video URL for merging later
            if inputWasVideo {
                originalVideoURL = tempURL
            }
            
            // Create AudioFile
            if let audioFile = AudioFile(url: tempURL) {
                if let validationError = audioFile.validationError {
                    error = validationError
                    selectedFile = nil
                } else {
                    selectedFile = audioFile
                    error = nil
                }
            } else {
                error = "Failed to process selected file"
                selectedFile = nil
            }
            
        } catch {
            self.error = "Error loading file: \(error.localizedDescription)"
            selectedFile = nil
        }
    }
    
    // MARK: - Quick Presets
    
    /// Apply a quick preset configuration
    func applyPreset(_ preset: AudioPreset) {
        mode = preset.mode
        prompt = preset.prompt
    }
    
    /// Construct smart prompt with mode prepended
    /// Returns the user prompt cleaned up
    private func constructSmartPrompt() -> String {
        return prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Processing
    
    /// Start processing the selected file
    func startProcessing() async {
        // Reset monthly limit if needed
        subscriptionManager.resetMonthlyLimitIfNeeded()
        
        // Check usage limits - show paywall if limit exceeded
        let usageCheck = subscriptionManager.canProcess()
        guard usageCheck.allowed else {
            if subscriptionManager.needsSubscription {
                showingSubscription = true
            } else {
                error = usageCheck.reason
            }
            return
        }
        
        guard let file = selectedFile else {
            error = "No file selected"
            return
        }
        
        // Validate duration against tier
        let durationCheck = subscriptionManager.validateDuration(file.duration)
        guard durationCheck.valid else {
            error = durationCheck.reason
            return
        }
        
        guard !prompt.isEmpty else {
            error = "Please enter a prompt"
            return
        }
        
        isProcessing = true
        error = nil
        
        // Construct smart prompt with mode prepended for better AI results
        let smartPrompt = constructSmartPrompt()
        
        // Create job immediately so ProcessingView shows
        currentJob = ProcessingJob(inputFile: file, prompt: smartPrompt, mode: mode)
        
        await audioProcessor.processAudio(file: file, prompt: smartPrompt, mode: mode)
        
        // Consume process on success
        if audioProcessor.error == nil {
            subscriptionManager.consumeProcess()
        }
        
        // Update from processor
        currentJob = audioProcessor.currentJob
        error = audioProcessor.error
        
        // If video input and processing succeeded, merge audio back into video
        if currentJob?.status == .completed,
           inputWasVideo,
           let originalVideo = originalVideoURL,
           let processedAudio = currentJob?.outputURL {
            
            // Check if user has video export permission
            if subscriptionManager.currentTier.canExportVideo {
                await mergeAudioIntoVideo(videoURL: originalVideo, audioURL: processedAudio)
            }
            // If no permission, just show the audio result (current behavior)
        }
        
        // CRITICAL: Set showingResult BEFORE isProcessing = false
        // This prevents the brief flash of the file selection view
        if currentJob?.status == .completed {
            showingResult = true
        }
        
        // Now safe to end processing state
        isProcessing = audioProcessor.isProcessing
    }
    
    /// Merge processed audio back into original video
    private func mergeAudioIntoVideo(videoURL: URL, audioURL: URL) async {
        do {
            let mergedURL = try await VideoProcessor.shared.mergeAsync(
                videoURL: videoURL,
                audioURL: audioURL
            )
            
            // Update job with video output
            currentJob?.complete(outputURL: mergedURL)
        } catch {
            // If merge fails, keep audio output - don't fail the whole process
            print("Video merge failed: \(error.localizedDescription)")
        }
    }
    
    /// Cancel current processing
    func cancelProcessing() {
        audioProcessor.cancel()
        isProcessing = false
        currentJob = nil
    }
    
    /// Reset for new processing
    func reset() {
        selectedFile = nil
        prompt = ""
        mode = .remove
        currentJob = nil
        error = nil
        isProcessing = false
        showingResult = false
        inputWasVideo = false
        originalVideoURL = nil
        audioProcessor.reset()
    }
    
    // MARK: - Sharing
    
    /// Share the result file
    func shareResult() {
        guard resultURL != nil else { return }
        showingShareSheet = true
    }
    
    // MARK: - Onboarding
    
    /// Complete onboarding
    func completeOnboarding() {
        Config.hasCompletedOnboarding = true
        showingOnboarding = false
    }
    
    // MARK: - Prompt Suggestions
    
    /// Common prompt suggestions
    let promptSuggestions = [
        "speech", "wind", "music", "guitar",
        "dog barking", "traffic", "crowd", "siren",
        "keyboard clicking", "footsteps", "door slamming"
    ]
    
    /// Apply a suggestion
    func applySuggestion(_ suggestion: String) {
        prompt = suggestion
    }
}
