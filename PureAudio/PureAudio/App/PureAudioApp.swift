//
//  AudioPureApp.swift
//  AudioPure
//
//  App entry point
//

import SwiftUI

@main
struct AudioPureApp: App {
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
