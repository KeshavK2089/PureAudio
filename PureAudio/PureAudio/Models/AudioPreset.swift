//
//  AudioPreset.swift
//  AudioPure
//
//  Curated presets for SAM Audio - Apple-style minimal selection
//

import Foundation

/// A quick preset with optimized prompt for common audio tasks
struct AudioPreset: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let mode: ProcessingMode
    let prompt: String
}

// MARK: - Curated Preset Library

extension AudioPreset {
    
    /// Core presets - most useful for 80% of use cases
    static let all: [AudioPreset] = [
        
        // Voice
        AudioPreset(
            icon: "person.wave.2",
            title: "Isolate Voice",
            description: "Extract speech, remove background",
            mode: .isolate,
            prompt: "speech"
        ),
        
        // Noise removal
        AudioPreset(
            icon: "waveform.badge.minus",
            title: "Remove Noise",
            description: "Clean up unwanted sounds",
            mode: .remove,
            prompt: "noise"
        ),
        
        // Wind
        AudioPreset(
            icon: "wind",
            title: "Remove Wind",
            description: "Fix outdoor recordings",
            mode: .remove,
            prompt: "wind"
        ),
        
        // Music
        AudioPreset(
            icon: "music.note",
            title: "Isolate Music",
            description: "Keep music, remove speech",
            mode: .isolate,
            prompt: "music"
        ),
        
        // Vocals
        AudioPreset(
            icon: "music.mic",
            title: "Isolate Vocals",
            description: "Extract singing voice",
            mode: .isolate,
            prompt: "singing"
        ),
        
        // Remove music
        AudioPreset(
            icon: "music.note.slash",
            title: "Remove Music",
            description: "Keep speech, remove music",
            mode: .remove,
            prompt: "music"
        )
    ]
}
