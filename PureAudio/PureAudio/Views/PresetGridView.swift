//
//  PresetGridView.swift
//  AudioPure
//
//  Quick preset grid for easy audio processing
//

import SwiftUI

struct PresetGridView: View {
    let presets: [AudioPreset]
    let onPresetTap: (AudioPreset) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                Text("Quick Presets")
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(.subtleGray)
            .padding(.horizontal, 4)
            
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

struct PresetCard: View {
    let preset: AudioPreset
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: preset.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.primaryPurple)
                    .frame(height: 32)
                
                VStack(spacing: 4) {
                    Text(preset.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(preset.description)
                        .font(.caption2)
                        .foregroundColor(.subtleGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(12)
            .background(Color.primaryPurple.opacity(0.06))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primaryPurple.opacity(0.15), lineWidth: 1)
            )
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
