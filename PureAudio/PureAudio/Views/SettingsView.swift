//
//  SettingsView.swift
//  PureAudio
//
//  About, Help, Terms, and Privacy screen
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        NavigationStack {
            List {
                // How to Use
                SwiftUI.Section {
                    NavigationLink(destination: HowToUseView()) {
                        Label("How to Use PureAudio", systemImage: "questionmark.circle.fill")
                            .foregroundColor(.primaryPurple)
                    }
                } header: {
                    Text("Help")
                }
                
                // About
                SwiftUI.Section {
                    Link(destination: URL(string: "https://huggingface.co/facebook/sam-audio-base")!) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.primaryPurple)
                            Text("Powered by Meta SAM Audio")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.subtleGray)
                        }
                    }
                } header: {
                    Text("Technology")
                }
                
                // Admin Code Entry
                SwiftUI.Section {
                    NavigationLink {
                        RedeemCodeView()
                    } label: {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.primaryPurple)
                            Text("Redeem Access Code")
                            Spacer()
                            if SubscriptionManager.shared.hasVIPAccess {
                                Text("VIP Active")
                                    .font(.caption)
                                    .foregroundColor(.accentPink)
                            }
                        }
                    }
                } header: {
                    Text("Access")
                }
                
                // Legal
                SwiftUI.Section {
                    Button {
                        showingTerms = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.primaryPurple)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.subtleGray)
                        }
                    }
                    
                    Button {
                        showingPrivacy = true
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.primaryPurple)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.subtleGray)
                        }
                    }
                } header: {
                    Text("Legal")
                }
                
                // App Info
                SwiftUI.Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.subtleGray)
                    }
                } header: {
                    Text("App Information")
                } footer: {
                    Text("© 2025 PureAudio. All rights reserved.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryPurple)
                }
            }
            .sheet(isPresented: $showingTerms) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyPolicyView()
            }
        }
    }
}

// MARK: - How to Use View

struct HowToUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("How to Use PureAudio")
                    .font(.title.bold())
                    .padding(.bottom, 8)
                
                // Step 1
                HowToStep(
                    number: "1",
                    title: "Select Your File",
                    description: "Tap 'Select from Photos' for videos from your library, or 'Select from Files' for audio files from iCloud Drive or Downloads.",
                    icon: "photo.on.rectangle"
                )
                
                // Step 2
                HowToStep(
                    number: "2",
                    title: "Describe the Sound",
                    description: "Type what sound you want to process. Be specific! Use 'male voice' instead of just 'voice'. Tap suggestions for quick prompts.",
                    icon: "text.bubble.fill"
                )
                
                // Step 3
                HowToStep(
                    number: "3",
                    title: "Choose Mode",
                    description: "ISOLATE keeps ONLY the sound you describe. REMOVE deletes it and keeps everything else.",
                    icon: "slider.horizontal.3"
                )
                
                // Step 4
                HowToStep(
                    number: "4",
                    title: "Process & Wait",
                    description: "Tap 'Process Audio' and wait 30-90 seconds. The first request takes longer as the AI warms up.",
                    icon: "sparkles"
                )
                
                // Step 5
                HowToStep(
                    number: "5",
                    title: "Play & Share",
                    description: "Listen to your result, then share to social media or save to Files.",
                    icon: "square.and.arrow.up"
                )
                
                Divider()
                    .padding(.vertical)
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Pro Tips")
                        .font(.headline)
                    
                    TipRow(text: "Use short, specific prompts like 'guitar' or 'wind noise'")
                    TipRow(text: "First request takes ~90 seconds, next ones ~30 seconds")
                    TipRow(text: "WiFi recommended for faster uploads")
                    TipRow(text: "Files under 100MB work best")
                }
                .padding()
                .background(Color.primaryPurple.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HowToStep: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            ZStack {
                Circle()
                    .fill(Color.primaryPurple)
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.primaryPurple)
                    Text(title)
                        .font(.headline)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.primaryPurple)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Terms of Service

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.title.bold())
                        .padding(.bottom, 8)
                    
                    Text("Last Updated: December 18, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Section("1. Acceptance of Terms") {
                        Text("By using PureAudio, you agree to these Terms of Service. If you do not agree, please do not use the app.")
                    }
                    
                    Section("2. Description of Service") {
                        Text("PureAudio provides AI-powered audio processing to isolate or remove specific sounds from audio and video files using Meta's SAM Audio technology.")
                    }
                    
                    Section("3. Use of Service") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You agree to:")
                            Text("• Use the service for lawful purposes only")
                            Text("• Not upload content you don't have rights to process")
                            Text("• Not attempt to reverse engineer or abuse the service")
                            Text("• Comply with all applicable laws and regulations")
                        }
                        .font(.subheadline)
                    }
                    
                    Section("4. Content Rights") {
                        Text("You retain all rights to your audio files. PureAudio does not claim ownership of your uploaded content. Files are processed temporarily and not permanently stored.")
                    }
                    
                    Section("5. Service Availability") {
                        Text("We strive to keep PureAudio available 24/7 but do not guarantee uninterrupted access. The service may be unavailable during maintenance or due to technical issues.")
                    }
                    
                    Section("6. Limitation of Liability") {
                        Text("PureAudio is provided 'as is' without warranties. We are not liable for any damages arising from use of the service, including but not limited to data loss or processing errors.")
                    }
                    
                    Section("7. Changes to Terms") {
                        Text("We may update these Terms at any time. Continued use of the app after changes constitutes acceptance of the new Terms.")
                    }
                    
                    Section("8. Contact") {
                        Text("For questions about these Terms, please contact us through the App Store.")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Privacy Policy

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title.bold())
                        .padding(.bottom, 8)
                    
                    Text("Last Updated: December 18, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Section("1. Information We Collect") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("We collect:")
                            Text("• Audio/video files you choose to process (temporarily)")
                            Text("• Text prompts you enter")
                            Text("• Processing mode selections")
                            Text("• Basic usage analytics")
                        }
                        .font(.subheadline)
                    }
                    
                    Section("2. How We Use Your Information") {
                        Text("Your files are sent to our processing servers (Modal) where Meta SAM Audio AI processes them. Files are:")
                        Text("• Used ONLY for audio processing")
                        Text("• Deleted immediately after processing")
                        Text("• Never stored permanently")
                        Text("• Never shared with third parties")
                        Text("• Never used for AI training")
                            .padding(.top, 8)
                    }
                    
                    Section("3. Data Storage") {
                        Text("Processed audio is temporarily stored on your device until you delete it or process a new file. We do not store your original files or results on our servers.")
                    }
                    
                    Section("4. Photo Library Access") {
                        Text("We request access to your Photo Library solely to allow you to select audio/video files for processing. We never access, upload, or view any photos or other content without your explicit selection.")
                    }
                    
                    Section("5. Third-Party Services") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("We use these third-party services:")
                            Text("• Modal: Cloud processing infrastructure")
                            Text("• Meta SAM Audio: AI model for audio separation")
                            Text("• Hugging Face: Model hosting")
                                .padding(.top, 4)
                            Text("Each has their own privacy policies which govern their services.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .font(.subheadline)
                    }
                    
                    Section("6. Data Security") {
                        Text("Files are transmitted securely using HTTPS encryption. Processing occurs on secure GPU servers. However, no method of transmission is 100% secure.")
                    }
                    
                    Section("7. Children's Privacy") {
                        Text("PureAudio is not intended for children under 13. We do not knowingly collect information from children.")
                    }
                    
                    Section("8. Your Rights") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You have the right to:")
                            Text("• Delete the app and all local data anytime")
                            Text("• Choose what files to process")
                            Text("• Not use the service if you disagree with this policy")
                        }
                        .font(.subheadline)
                    }
                    
                    Section("9. Changes to Privacy Policy") {
                        Text("We may update this policy. Continued use after changes means you accept the updated policy.")
                    }
                    
                    Section("10. Contact Us") {
                        Text("Questions about privacy? Contact us through the App Store.")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper for sections
extension View {
    func Section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryPurple)
            
            content()
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    SettingsView()
}
