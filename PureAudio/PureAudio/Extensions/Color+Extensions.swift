//
//  Color+Extensions.swift
//  PureAudio
//
//  Custom color palette for the app
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    
    /// Primary purple color (#7A3DDE)
    static let primaryPurple = Color(red: 122/255, green: 61/255, blue: 222/255)
    
    /// Deep purple color (#3D1F6B)
    static let deepPurple = Color(red: 61/255, green: 31/255, blue: 107/255)
    
    /// Accent pink color (#FF4B8C)
    static let accentPink = Color(red: 255/255, green: 75/255, blue: 140/255)
    
    /// Success green (#34C759)
    static let successGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
    
    /// Error red (#FF3B30)
    static let errorRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    
    // MARK: - Gradients
    
    /// Primary gradient (purple to deep purple)
    static let primaryGradient = LinearGradient(
        colors: [.primaryPurple, .deepPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Accent gradient (pink to purple)
    static let accentGradient = LinearGradient(
        colors: [.accentPink, .primaryPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Success gradient
    static let successGradient = LinearGradient(
        colors: [.successGreen, .successGreen.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Semantic Colors
    
    /// Card background (adapts to dark mode)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    /// Subtle gray for hints
    static let subtleGray = Color(uiColor: .secondaryLabel)
}
