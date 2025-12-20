//
//  OnboardingView.swift
//  PureAudio
//
//  First-time user onboarding screen
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App icon placeholder
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                // Title
                VStack(spacing: 8) {
                    Text("Welcome to PureAudio")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Powered by Meta SAM Audio")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Features
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "speaker.wave.2.fill",
                        title: "Isolate Sounds",
                        description: "Extract specific sounds from audio"
                    )
                    
                    FeatureRow(
                        icon: "speaker.slash.fill",
                        title: "Remove Noise",
                        description: "Clean up background noise instantly"
                    )
                    
                    FeatureRow(
                        icon: "text.bubble.fill",
                        title: "Text-Based",
                        description: "Simple prompts like 'voice' or 'wind'"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Get Started button
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.completeOnboarding()
                    }
                } label: {
                    Text("Get Started")
                        .primaryButtonStyle()
                }
                .padding(.horizontal, 32)
                
                Text("Setup takes 30 seconds")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
}

#Preview {
    OnboardingView(viewModel: MainViewModel())
}
