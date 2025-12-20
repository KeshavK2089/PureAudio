//
//  View+Extensions.swift
//  PureAudio
//
//  Reusable view modifiers and extensions
//

import SwiftUI

extension View {
    // MARK: - Card Style
    
    /// Apply card styling with shadow
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Button Styles
    
    /// Primary button style (pink gradient)
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.accentGradient)
            .cornerRadius(16)
            .shadow(color: Color.accentPink.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    /// Secondary button style (purple outline)
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primaryPurple)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primaryPurple, lineWidth: 2)
            )
    }
    
    /// Tertiary button style (subtle)
    func tertiaryButtonStyle() -> some View {
        self
            .font(.subheadline.weight(.medium))
            .foregroundColor(.primaryPurple)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primaryPurple.opacity(0.1))
            .cornerRadius(8)
    }
    
    // MARK: - Animations
    
    /// Spring animation
    func springAnimation() -> Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - Custom View Modifiers

/// Toast notification modifier
struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isShowing {
                VStack {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.top, 50)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    /// Show toast notification
    func toast(message: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(message: message, isShowing: isShowing))
    }
}
