//
//  ContentView.swift
//  AudioPure
//
//  Main app screen with all states
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Main NavigationStack (hidden when processing)
            NavigationStack {
                ZStack {
                    // Background gradient
                    Color.primaryGradient
                        .opacity(0.1)
                        .ignoresSafeArea()
                    
                    // Main content based on state
                    ScrollView {
                        VStack(spacing: 24) {
                            if viewModel.showingResult, let job = viewModel.currentJob {
                                // STATE D: Result Ready
                                ResultView(
                                    job: job,
                                    onShare: {
                                        viewModel.shareResult()
                                    },
                                    onProcessAnother: {
                                        withAnimation {
                                            viewModel.reset()
                                        }
                                    }
                                )
                                .transition(.opacity)
                                
                            } else if let file = viewModel.selectedFile {
                                // STATE B: File Selected
                                fileSelectedView(file: file)
                                    .transition(.opacity)
                                
                            } else {
                                // STATE A: No File Selected
                                noFileView
                                    .transition(.opacity)
                            }
                        }
                        .padding(.vertical, 24)
                    }
                }
                .navigationTitle(viewModel.selectedFile == nil ? "AudioPure" : "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !viewModel.isProcessing && !viewModel.showingResult {
                            Button {
                                viewModel.showingSettings = true
                            } label: {
                                Image(systemName: "gear")
                                    .foregroundColor(.primaryPurple)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if viewModel.selectedFile != nil && !viewModel.isProcessing && !viewModel.showingResult {
                            Button {
                                withAnimation {
                                    viewModel.reset()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primaryPurple)
                            }
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $viewModel.showingDocumentPicker) {
                    DocumentPicker(selectedURL: Binding(
                        get: { nil },
                        set: { viewModel.handleSelectedDocument($0) }
                    ))
                }
                .sheet(isPresented: $viewModel.showingShareSheet) {
                    if let url = viewModel.resultURL {
                        ShareSheet(items: [url])
                    }
                }
                .sheet(isPresented: $viewModel.showingSubscription) {
                    SubscriptionView()
                }
            }
            .opacity(viewModel.isProcessing ? 0 : 1)
            
            // Fullscreen Processing Overlay
            if viewModel.isProcessing, let job = viewModel.currentJob {
                ProcessingView(job: job) {
                    viewModel.cancelProcessing()
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                await viewModel.handleSelectedItem(newValue)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("Copy Error") {
                if let error = viewModel.error {
                    UIPasteboard.general.string = error
                }
            }
            Button("OK", role: .cancel) {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error + "\n\nTap 'Copy Error' to share details")
            } else {
                Text("An error occurred")
            }
        }
        .onChange(of: viewModel.error) { oldValue, newValue in
            showingError = (newValue != nil)
        }
    }
    
    // MARK: - STATE A: No File Selected
    
    private var noFileView: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryPurple)
                
                Text("AudioPure")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Powered by Meta SAM Audio")
                    .font(.subheadline)
                    .foregroundColor(.subtleGray)
            }
            .padding(.top, 32)
            
            // File picker buttons
            VStack(spacing: 16) {
                // Photos button
                PhotosPicker(selection: $selectedPhotoItem, matching: .any(of: [.videos, .not(.images)])) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                        Text("Select from Photos")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(Color.primaryGradient)
                    .cornerRadius(16)
                    .shadow(color: Color.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                // Files button
                Button {
                    viewModel.showingDocumentPicker = true
                } label: {
                    HStack {
                        Image(systemName: "folder")
                            .font(.title3)
                        Text("Select from Files")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.primaryPurple)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primaryPurple, lineWidth: 2)
                    )
                }
                
                Text("Supports: MP3, WAV, M4A, MP4, MOV")
                    .font(.caption)
                    .foregroundColor(.subtleGray)
            }
            .padding(.horizontal, 32)
            
            // Example prompts
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                    Text("Example prompts:")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.subtleGray)
                
                VStack(alignment: .leading, spacing: 8) {
                    ExamplePromptRow(icon: "wind", text: "\"wind noise\" - remove wind")
                    ExamplePromptRow(icon: "person.fill", text: "\"voice\" - isolate speaking")
                    ExamplePromptRow(icon: "guitars.fill", text: "\"guitar\" - extract music")
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - STATE B: File Selected
    
    private func fileSelectedView(file: AudioFile) -> some View {
        VStack(spacing: 24) {
            // File info card
            HStack(spacing: 12) {
                Image(systemName: file.iconName)
                    .font(.title2)
                    .foregroundColor(.primaryPurple)
                    .frame(width: 50, height: 50)
                    .background(Color.primaryPurple.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.filename)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(file.formattedSize) • \(file.formattedDuration)")
                        .font(.subheadline)
                        .foregroundColor(.subtleGray)
                }
                
                Spacer()
            }
            .padding()
            .cardStyle()
            .padding(.horizontal, 32)
            
            // Prompt input
            PromptInputCard(
                prompt: $viewModel.prompt,
                suggestions: viewModel.promptSuggestions,
                onSuggestionTap: { suggestion in
                    viewModel.applySuggestion(suggestion)
                }
            )
            .padding(.horizontal, 32)
            
            // Mode picker
            VStack(alignment: .leading, spacing: 12) {
                Picker("Mode", selection: $viewModel.mode) {
                    ForEach(ProcessingMode.allCases) { mode in
                        Text(mode.shortName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(viewModel.mode.description)
                    .font(.subheadline)
                    .foregroundColor(.subtleGray)
            }
            .padding()
            .cardStyle()
            .padding(.horizontal, 32)
            
            // Quick Presets Grid
            PresetGridView(presets: AudioPreset.all) { preset in
                viewModel.applyPreset(preset)
            }
            .padding(.horizontal, 32)
            
            // Process button
            Button {
                Task {
                    await viewModel.startProcessing()
                }
            } label: {
                Text("Process Audio")
                    .primaryButtonStyle()
            }
            .disabled(!viewModel.canProcess)
            .opacity(viewModel.canProcess ? 1.0 : 0.5)
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
    }
}

// MARK: - Example Prompt Row

struct ExamplePromptRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.primaryPurple)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView(viewModel: MainViewModel())
}
