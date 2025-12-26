//
//  Color+Extensions.swift
//  AudioPure
//
//  Professional color palette - Sky Blue / Blue / Purple scheme
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors (Sky Blue / Blue / Purple)
    
    /// Primary blue color (#3B82F6) - Professional blue
    static let primaryBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    /// Sky blue color (#0EA5E9) - Light accent
    static let skyBlue = Color(red: 14/255, green: 165/255, blue: 233/255)
    
    /// Deep purple color (#6366F1) - Secondary accent
    static let deepPurple = Color(red: 99/255, green: 102/255, blue: 241/255)
    
    /// Indigo color (#4F46E5) - Premium accent
    static let indigo = Color(red: 79/255, green: 70/255, blue: 229/255)
    
    /// Success green (#22C55E) - Apple system green equivalent
    static let successGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    
    /// Error red (#EF4444) - Apple system red equivalent
    static let errorRed = Color(red: 239/255, green: 68/255, blue: 68/255)
    
    // MARK: - Legacy Aliases (for backward compatibility)
    
    /// Primary purple - now maps to primaryBlue for consistency
    static let primaryPurple = primaryBlue
    
    /// Accent pink - now maps to deepPurple for professional look
    static let accentPink = deepPurple
    
    // MARK: - Gradients
    
    /// Primary gradient (sky blue to deep purple)
    static let primaryGradient = LinearGradient(
        colors: [.skyBlue, .primaryBlue, .deepPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Accent gradient (blue to purple)
    static let accentGradient = LinearGradient(
        colors: [.primaryBlue, .indigo],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Success gradient
    static let successGradient = LinearGradient(
        colors: [.successGreen, .successGreen.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Semantic Colors
    
    /// Card background (adapts to dark mode)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    /// Subtle gray for hints
    static let subtleGray = Color(uiColor: .secondaryLabel)
}
