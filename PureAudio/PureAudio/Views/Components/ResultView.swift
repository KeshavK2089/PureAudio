//
//  ResultView.swift
//  AudioPure
//
//  Result display with playback and sharing
//

import SwiftUI
import AVKit

struct ResultView: View {
    let job: ProcessingJob
    let onShare: () -> Void
    let onProcessAnother: () -> Void
    
    @State private var player: AVPlayer?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Success header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.successGreen)
                    
                    Text("Result Ready!")
                        .font(.title.weight(.bold))
                        .foregroundColor(.successGreen)
                    
                    Text(job.formattedTime)
                        .font(.subheadline)
                        .foregroundColor(.subtleGray)
                }
                .padding(.top, 32)
                
                // Audio player
                if let url = job.outputURL {
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
                
                // File info comparison
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
                
                // Action buttons
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
        }
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
