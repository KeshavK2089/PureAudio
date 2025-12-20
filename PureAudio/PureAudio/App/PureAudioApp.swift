//
//  PureAudioApp.swift
//  PureAudio
//
//  App entry point
//

import SwiftUI

@main
struct PureAudioApp: App {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.showingOnboarding {
                OnboardingView(viewModel: viewModel)
            } else {
                ContentView(viewModel: viewModel)
            }
        }
    }
}
