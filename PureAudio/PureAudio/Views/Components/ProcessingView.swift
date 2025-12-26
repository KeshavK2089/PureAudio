//
//  ProcessingView.swift
//  AudioPure
//
//  INVESTOR-READY Processing display
//

import SwiftUI

struct ProcessingView: View {
    let job: ProcessingJob
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main animation area
                VStack(spacing: 32) {
                    // Pulsing music note icon
                    PulsingMusicIcon()
                    
                    // Circular visualizer
                    CircularAudioVisualizer()
                        .frame(width: 200, height: 200)
                    
                    // Animated waveform
                    WaveformAnimationView()
                        .frame(width: 280, height: 90)
                }
                
                // Simple status text - NO PERCENTAGES
                VStack(spacing: 12) {
                    Text("Processing Audio")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .primaryPurple.opacity(0.3), radius: 8)
                    
                    Text("AI is analyzing your audio...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Immediate wait time message
                    Text("First processing may take a few minutes")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                
                // Time info (optional - can remove if too technical)
                if let time = job.processingTimeSeconds, time > 5 {
                    Text(String(format: "%.0f seconds", time))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .monospacedDigit()
                }
                
                // Help message (after 45 seconds)
                if job.status == .processing && (job.processingTimeSeconds ?? 0) > 45 {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "hourglass")
                                .font(.caption)
                            Text("Please wait for completion")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal, 48)
                }
                
                Spacer()
                Spacer()
                
                // Cancel button
                Button(role: .destructive) {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 122/255, green: 61/255, blue: 222/255),
                Color(red: 255/255, green: 75/255, blue: 140/255),
                Color(red: 61/255, green: 31/255, blue: 107/255)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Pulsing Music Icon

struct PulsingMusicIcon: View {
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: "waveform.circle.fill")
            .font(.system(size: 70))
            .foregroundColor(.white)
            .scaleEffect(isPulsing ? 1.15 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Circular Audio Visualizer

struct CircularAudioVisualizer: View {
    @State private var animating = false
    let barCount = 36
    
    var body: some View {
        ZStack {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 5, height: animating ? CGFloat.random(in: 25...70) : 25)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(index) * 360.0 / Double(barCount)))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.015),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Waveform Animation

struct WaveformAnimationView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<30) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 5)
                    .frame(height: animating ? CGFloat.random(in: 20...90) : 20)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.03),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    ProcessingView(
        job: ProcessingJob(
            inputFile: AudioFile(url: URL(fileURLWithPath: "/tmp/test.mp3"))!,
            prompt: "voice",
            mode: .remove
        ),
        onCancel: {}
    )
}
