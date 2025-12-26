//
//  ResultView.swift
//  AudioPure
//
//  Result display with before/after comparison and sharing
//

import SwiftUI
import AVKit

struct ResultView: View {
    let job: ProcessingJob
    let onShare: () -> Void
    let onProcessAnother: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isPlayingOriginal = false  // A/B toggle
    @State private var isPlaying = false
    
    private var isVideoOutput: Bool {
        job.outputURL?.pathExtension.lowercased() == "mp4"
    }
    
    private var originalURL: URL? {
        job.inputFile.url
    }
    
    private var processedURL: URL? {
        job.outputURL
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    // Success header
                    successHeader
                        .id("top") // Mark top for scrolling
                    
                    // A/B Comparison Toggle
                    if !isVideoOutput {
                        comparisonToggle
                    }
                    
                    // Media player
                    if let url = isPlayingOriginal ? originalURL : processedURL {
                        mediaPlayerSection(url: url)
                    }
                    
                    // Details
                    detailsSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding(.vertical, 24)
            }
            .onAppear {
                // Ensure we start at the top
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - Success Header
    
    private var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.successGreen)
            
            Text("Done")
                .font(.title)
                .fontWeight(.bold)
            
            if let time = job.processingTimeSeconds {
                Text("Processed in \(Int(time))s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 48) // Extra padding to prevent checkmark cutoff
    }
    
    // MARK: - A/B Comparison Toggle
    
    private var comparisonToggle: some View {
        HStack(spacing: 0) {
            // Original
            Button {
                switchToOriginal()
            } label: {
                Text("Original")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(isPlayingOriginal ? .white : .primary)
                    .background(isPlayingOriginal ? Color.primaryBlue : Color.clear)
            }
            
            // Processed
            Button {
                switchToProcessed()
            } label: {
                Text("Processed")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(!isPlayingOriginal ? .white : .primary)
                    .background(!isPlayingOriginal ? Color.primaryBlue : Color.clear)
            }
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 24)
    }
    
    private func switchToOriginal() {
        guard !isPlayingOriginal else { return }
        let currentTime = player?.currentTime()
        isPlayingOriginal = true
        
        if let url = originalURL {
            player = AVPlayer(url: url)
            if let time = currentTime {
                player?.seek(to: time)
            }
            if isPlaying {
                player?.play()
            }
        }
    }
    
    private func switchToProcessed() {
        guard isPlayingOriginal else { return }
        let currentTime = player?.currentTime()
        isPlayingOriginal = false
        
        if let url = processedURL {
            player = AVPlayer(url: url)
            if let time = currentTime {
                player?.seek(to: time)
            }
            if isPlaying {
                player?.play()
            }
        }
    }
    
    // MARK: - Media Player
    
    private func mediaPlayerSection(url: URL) -> some View {
        VStack(spacing: 16) {
            if isVideoOutput {
                // Video player
                VideoPlayer(player: player)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .onAppear {
                        player = AVPlayer(url: url)
                    }
                    .onDisappear {
                        player?.pause()
                    }
                
                Text("Video with processed audio")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Audio player with controls
                VStack(spacing: 16) {
                    // Waveform icon
                    Image(systemName: isPlayingOriginal ? "waveform" : "waveform.badge.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(isPlayingOriginal ? .secondary : .primaryBlue)
                    
                    // Label
                    Text(isPlayingOriginal ? "Original Audio" : "Processed Audio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Play/Pause button
                    Button {
                        togglePlayback()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.primaryBlue)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onAppear {
                    player = AVPlayer(url: url)
                    setupPlaybackObserver()
                }
                .onDisappear {
                    player?.pause()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func togglePlayback() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    private func setupPlaybackObserver() {
        // Reset isPlaying when audio ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            isPlaying = false
            player?.seek(to: .zero)
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Mode", systemImage: job.mode == .isolate ? "speaker.wave.2" : "speaker.slash")
                Spacer()
                Text(job.mode.displayName)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                Label("Prompt", systemImage: "text.bubble")
                Spacer()
                Text("\"\(job.prompt)\"")
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Divider()
            
            HStack {
                Label("Output", systemImage: isVideoOutput ? "video" : "music.note")
                Spacer()
                Text(isVideoOutput ? "Video (MP4)" : "Audio (WAV)")
                    .foregroundColor(.secondary)
            }
        }
        .font(.subheadline)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Share/Save
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Process Another
            Button(action: onProcessAnother) {
                Label("Process Another", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.primaryBlue)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

#Preview {
    var job = ProcessingJob(
        inputFile: AudioFile(url: URL(fileURLWithPath: "/tmp/test.mp3"))!,
        prompt: "voice",
        mode: .remove
    )
    job.complete(outputURL: URL(fileURLWithPath: "/tmp/output.wav"))
    
    return ResultView(
        job: job,
        onShare: {},
        onProcessAnother: {}
    )
}
