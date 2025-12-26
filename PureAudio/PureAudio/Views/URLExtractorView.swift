//
//  URLExtractorView.swift
//  AudioPure
//
//  Import audio from TikTok, Instagram, YouTube URLs (Pro+ feature)
//

import SwiftUI

struct URLExtractorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var urlText: String = ""
    @State private var isExtracting = false
    @State private var errorMessage: String?
    @State private var showingUpgrade = false
    
    let onAudioExtracted: (URL) -> Void
    
    private var currentTier: SubscriptionTier {
        SubscriptionManager.shared.currentTier
    }
    
    private var isLocked: Bool {
        !currentTier.canExtractURL
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                if isLocked {
                    // Locked state
                    lockedView
                } else {
                    // URL input
                    urlInputSection
                    
                    // Supported platforms
                    supportedPlatformsSection
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingUpgrade) {
                SubscriptionView()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Paste a link to extract audio")
                .font(.headline)
            
            Text("Works with TikTok, Instagram Reels, YouTube Shorts")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Locked View
    
    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("Pro Feature")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Upgrade to Pro or Unlimited to import audio from social media links.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingUpgrade = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 40)
    }
    
    // MARK: - URL Input
    
    private var urlInputSection: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Paste URL here...", text: $urlText)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Paste button
                Button {
                    if let clipboardString = UIPasteboard.general.string {
                        urlText = clipboardString
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Extract button
            Button {
                extractAudio()
            } label: {
                HStack {
                    if isExtracting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                    }
                    Text(isExtracting ? "Extracting..." : "Extract Audio")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(urlText.isEmpty ? Color.gray : Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(urlText.isEmpty || isExtracting)
        }
    }
    
    // MARK: - Supported Platforms
    
    private var supportedPlatformsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Supported Platforms")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                PlatformBadge(name: "TikTok", icon: "play.rectangle.fill", color: .pink)
                PlatformBadge(name: "Instagram", icon: "camera.fill", color: .purple)
                PlatformBadge(name: "YouTube", icon: "play.circle.fill", color: .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
    
    // MARK: - Actions
    
    private func extractAudio() {
        guard let url = URL(string: urlText), url.scheme != nil else {
            errorMessage = "Please enter a valid URL"
            return
        }
        
        isExtracting = true
        errorMessage = nil
        
        // TODO: Implement server-side extraction with yt-dlp
        // For now, show placeholder behavior
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isExtracting = false
            errorMessage = "URL extraction requires backend integration. Coming soon!"
        }
    }
}

// MARK: - Platform Badge

struct PlatformBadge: View {
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    URLExtractorView { url in
        print("Extracted: \(url)")
    }
}
