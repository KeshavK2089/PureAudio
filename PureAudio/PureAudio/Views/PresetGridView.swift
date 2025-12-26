//
//  PresetGridView.swift
//  AudioPure
//
//  Quick preset grid - Apple-style minimal design
//

import SwiftUI

struct PresetGridView: View {
    let presets: [AudioPreset]
    let onPresetTap: (AudioPreset) -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Quick Actions")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            // Preset Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(presets) { preset in
                    PresetCard(preset: preset) {
                        onPresetTap(preset)
                    }
                }
            }
        }
    }
}

// MARK: - Preset Card (Apple-style)

struct PresetCard: View {
    let preset: AudioPreset
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: preset.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Circle())
                
                // Text
                VStack(spacing: 4) {
                    Text(preset.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(preset.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PresetGridView(presets: AudioPreset.all) { preset in
        print("Tapped: \(preset.title)")
    }
    .padding()
}
