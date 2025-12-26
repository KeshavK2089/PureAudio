//
//  ResultView.swift
//  AudioPure
//
//  Result display with playback and sharing - Apple-style design
//

import SwiftUI
import AVKit

struct ResultView: View {
    let job: ProcessingJob
    let onShare: () -> Void
    let onProcessAnother: () -> Void
    
    @State private var player: AVPlayer?
    
    private var isVideoOutput: Bool {
        job.outputURL?.pathExtension.lowercased() == "mp4"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success header
                successHeader
                
                // Media player
                if let url = job.outputURL {
                    mediaPlayerSection(url: url)
                }
                
                // Details
                detailsSection
                
                // Action buttons
                actionButtons
            }
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - Success Header
    
    private var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("Done")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let time = job.processingTimeSeconds {
                Text("Processed in \(Int(time))s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
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
                // Audio player
                VStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onAppear {
                    player = AVPlayer(url: url)
                }
                .onDisappear {
                    player?.pause()
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
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
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Process Another
            Button(action: onProcessAnother) {
                Label("Process Another", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.accentColor)
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
