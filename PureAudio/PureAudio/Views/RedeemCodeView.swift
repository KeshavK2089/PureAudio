//
//  RedeemCodeView.swift
//  PureAudio
//
//  Professional admin code redemption interface
//

import SwiftUI

struct RedeemCodeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager = SubscriptionManager.shared
    
    @State private var codeText = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var codeFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.primaryPurple.opacity(0.1), .accentPink.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primaryPurple, .accentPink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Redeem Access Code")
                            .font(.title2.weight(.bold))
                        
                        Text("Enter your VIP or press access code to unlock unlimited processing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Code Input
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(spacing: 0) {
                            TextField("ENTER-YOUR-CODE", text: $codeText)
                                .textFieldStyle(.plain)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .font(.system(.title3, design: .monospaced).weight(.medium))
                                .padding()
                                .focused($codeFieldFocused)
                                .multilineTextAlignment(.center)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(codeFieldFocused ? Color.primaryPurple : Color.clear, lineWidth: 2)
                        )
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                            Text("Codes are case-insensitive and provided by PureAudio")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 32)
                    
                    // Redeem Button
                    Button {
                        redeemCode()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Redeem Code")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: codeText.isEmpty ? [.gray, .gray] : [.primaryPurple, .accentPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(codeText.isEmpty)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationTitle("Access Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primaryPurple)
                    }
                }
            }
            .alert("VIP Access Activated!", isPresented: $showingSuccess) {
                Button("Continue") {
                    dismiss()
                }
            } message: {
                Text("✨ You now have unlimited processing!\n\nAll restrictions have been removed.")
            }
            .alert("Invalid Code", isPresented: $showingError) {
                Button("Try Again", role: .cancel) {
                    codeText = ""
                    codeFieldFocused = true
                }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    codeFieldFocused = true
                }
            }
        }
    }
    
    private func redeemCode() {
        let result = manager.redeemCode(codeText)
        
        if result.success {
            showingSuccess = true
        } else {
            errorMessage = result.message
            showingError = true
        }
    }
}

#Preview {
    RedeemCodeView()
}
