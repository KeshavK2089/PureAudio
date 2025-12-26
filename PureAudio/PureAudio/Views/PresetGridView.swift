//
//  PresetGridView.swift
//  AudioPure
//
//  Quick preset grid with persona-based categories
//

import SwiftUI

struct PresetGridView: View {
    let presets: [AudioPreset]
    let onPresetTap: (AudioPreset) -> Void
    
    @State private var selectedPersona: CreatorPersona? = nil
    @State private var showingPersonaPicker = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var displayedPresets: [AudioPreset] {
        if let persona = selectedPersona {
            return AudioPreset.presets(for: persona)
        }
        return presets
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with persona selector
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                    Text(selectedPersona?.rawValue ?? "Quick Presets")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.subtleGray)
                
                Spacer()
                
                // Persona Picker Button
                Button {
                    showingPersonaPicker = true
                } label: {
                    HStack(spacing: 4) {
                        if let persona = selectedPersona {
                            Image(systemName: persona.icon)
                                .foregroundColor(persona.color)
                        } else {
                            Image(systemName: "person.crop.rectangle.stack")
                        }
                        Text(selectedPersona == nil ? "I'm a..." : "Change")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(.primaryPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primaryPurple.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)
            
            // Persona tagline
            if let persona = selectedPersona {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text(persona.tagline)
                        .font(.caption)
                }
                .foregroundColor(persona.color)
                .padding(.horizontal, 4)
            }
            
            // Preset Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(displayedPresets) { preset in
                    PresetCard(preset: preset, persona: selectedPersona) {
                        onPresetTap(preset)
                    }
                }
            }
        }
        .sheet(isPresented: $showingPersonaPicker) {
            PersonaPickerSheet(selectedPersona: $selectedPersona)
        }
    }
}

// MARK: - Preset Card

struct PresetCard: View {
    let preset: AudioPreset
    let persona: CreatorPersona?
    let action: () -> Void
    
    private var accentColor: Color {
        persona?.color ?? .primaryPurple
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: preset.icon)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
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
            .background(accentColor.opacity(0.06))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Persona Picker Sheet

struct PersonaPickerSheet: View {
    @Binding var selectedPersona: CreatorPersona?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("What kind of creator are you?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("We'll show presets tailored to your needs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(CreatorPersona.allCases) { persona in
                        PersonaOptionCard(
                            persona: persona,
                            isSelected: selectedPersona == persona
                        ) {
                            selectedPersona = persona
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
                
                // Reset option
                Button {
                    selectedPersona = nil
                    dismiss()
                } label: {
                    Text("Show all presets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .navigationTitle("Choose Your Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PersonaOptionCard: View {
    let persona: CreatorPersona
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: persona.icon)
                    .font(.title2)
                    .foregroundColor(persona.color)
                    .frame(width: 44, height: 44)
                    .background(persona.color.opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(persona.tagline)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(persona.color)
                }
            }
            .padding()
            .background(isSelected ? persona.color.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? persona.color : .clear, lineWidth: 2)
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
