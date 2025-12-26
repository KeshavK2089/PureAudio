//
//  ResultView.swift
//  AudioPure
//
//  Result display with playback, sharing, and Before/After comparison
//

import SwiftUI
import AVKit

struct ResultView: View {
    let job: ProcessingJob
    let onShare: () -> Void
    let onProcessAnother: () -> Void
    
    @State private var player: AVPlayer?
    @State private var showingBeforeAfterShare = false
    @State private var isPlayingOriginal = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Success header
                successHeader
                
                // Audio player
                if let url = job.outputURL {
                    audioPlayerSection(url: url)
                }
                
                // File info comparison
                detailsSection
                
                // Before/After Share Card
                beforeAfterShareCard
                
                // Action buttons
                actionButtons
            }
        }
    }
    
    // MARK: - Success Header
    
    private var successHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.successGreen)
            }
            
            Text("Result Ready!")
                .font(.title.weight(.bold))
                .foregroundColor(.primary)
            
            Text(job.formattedTime)
                .font(.subheadline)
                .foregroundColor(.subtleGray)
        }
        .padding(.top, 32)
    }
    
    // MARK: - Audio Player Section
    
    private func audioPlayerSection(url: URL) -> some View {
        VStack(spacing: 12) {
            Text("Processed Audio")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 60)
                    .cornerRadius(12)
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
        .onAppear {
            self.player = AVPlayer(url: url)
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original")
                        .font(.caption)
                        .foregroundColor(.subtleGray)
                    Text("\(job.inputFile.formattedSize) • \(job.inputFile.formattedDuration)")
                        .font(.subheadline.weight(.medium))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.subtleGray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Processed")
                        .font(.caption)
                        .foregroundColor(.subtleGray)
                    Text(job.inputFile.formattedDuration)
                        .font(.subheadline.weight(.medium))
                }
            }
            
            Divider()
            
            HStack {
                Text("Mode:")
                    .foregroundColor(.subtleGray)
                Spacer()
                Text(job.mode.displayName)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            
            HStack {
                Text("Prompt:")
                    .foregroundColor(.subtleGray)
                Spacer()
                Text("\"\(job.prompt)\"")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }
    
    // MARK: - Before/After Share Card
    
    private var beforeAfterShareCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.accentPink)
                Text("Share Your Transformation")
                    .font(.headline)
            }
            
            Text("Show the world your before & after audio magic!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Before/After toggle buttons
            HStack(spacing: 12) {
                BeforeAfterButton(
                    title: "Before",
                    icon: "speaker.wave.1",
                    isPlaying: isPlayingOriginal,
                    color: .orange
                ) {
                    playOriginal()
                }
                
                BeforeAfterButton(
                    title: "After",
                    icon: "speaker.wave.3",
                    isPlaying: !isPlayingOriginal && player?.timeControlStatus == .playing,
                    color: .successGreen
                ) {
                    playProcessed()
                }
            }
            
            // Share Before/After
            Button {
                shareBeforeAfter()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Before/After")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.accentPink, .primaryPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentPink.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentPink.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Share button
            Button {
                onShare()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share / Save")
                }
                .primaryButtonStyle()
            }
            
            // Process another
            Button {
                onProcessAnother()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Process Another")
                }
                .secondaryButtonStyle()
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    // MARK: - Playback Functions
    
    private func playOriginal() {
        player?.pause()
        isPlayingOriginal = true
        // Play original file
        let originalPlayer = AVPlayer(url: job.inputFile.url)
        originalPlayer.play()
        
        // Auto-stop after a few seconds for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            originalPlayer.pause()
            isPlayingOriginal = false
        }
    }
    
    private func playProcessed() {
        isPlayingOriginal = false
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func shareBeforeAfter() {
        // Create shareable text with the transformation details
        guard let outputURL = job.outputURL else { return }
        
        let shareText = """
        🎵 Check out my audio transformation with AudioPure!
        
        I used "\(job.prompt)" to \(job.mode == .isolate ? "isolate" : "remove") sounds.
        
        🔊 Before: \(job.inputFile.formattedDuration)
        ✨ After: Clean, professional audio!
        
        Try it yourself: [App Store Link]
        
        #AudioPure #AudioEditing #AI
        """
        
        let items: [Any] = [shareText, outputURL]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Before/After Button

struct BeforeAfterButton: View {
    let title: String
    let icon: String
    let isPlaying: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    if isPlaying {
                        Circle()
                            .stroke(color, lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .scaleEffect(1.2)
                            .opacity(0.5)
                    }
                    
                    Image(systemName: isPlaying ? "pause.fill" : icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
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
