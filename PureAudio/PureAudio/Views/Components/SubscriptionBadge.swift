//
//  SubscriptionBadge.swift
//  PureAudio
//
//  Compact subscription tier badge
//

import SwiftUI

struct SubscriptionBadge: View {
    @ObservedObject var manager = SubscriptionManager.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: manager.currentTier.iconName)
                .font(.caption2)
            
            if manager.hasVIPAccess {
                Text("VIP")
                    .font(.caption2.weight(.bold))
            } else {
                Text(manager.currentTier.displayName)
                    .font(.caption2.weight(.semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeGradient)
        .cornerRadius(12)
    }
    
    private var badgeGradient: LinearGradient {
        if manager.hasVIPAccess {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.0)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        switch manager.currentTier {
        case .free:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        case .basic:
            return LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        case .pro:
            return LinearGradient(colors: [.primaryPurple, .accentPink], startPoint: .leading, endPoint: .trailing)
        case .professional:
            return LinearGradient(colors: [.accentPink, .primaryPurple], startPoint: .leading, endPoint: .trailing)
        case .vip:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.0)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SubscriptionBadge()
    }
    .padding()
}
