//
//  AudioPreset.swift
//  PureAudio
//
//  Quick preset configurations for common audio processing tasks
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
    let category: PresetCategory
    
    enum PresetCategory {
        case voice
        case noise
        case music
    }
}

// MARK: - Preset Library

extension AudioPreset {
    
    /// All available quick presets optimized for best results
    static let all: [AudioPreset] = [
        // VOICE PRESETS
        AudioPreset(
            icon: "person.wave.2.fill",
            title: "Isolate Voice",
            description: "Perfect for vlogs, podcasts, interviews",
            mode: .isolate,
            prompt: "speech and vocals",
            category: .voice
        ),
        
        AudioPreset(
            icon: "mic.fill",
            title: "Remove Voice",
            description: "Remove dialogue, keep background",
            mode: .remove,
            prompt: "speech and vocals",
            category: .voice
        ),
        
        // NOISE REMOVAL PRESETS
        AudioPreset(
            icon: "wind",
            title: "Remove Wind",
            description: "Clean outdoor recordings",
            mode: .remove,
            prompt: "wind noise",
            category: .noise
        ),
        
        AudioPreset(
            icon: "waveform.badge.minus",
            title: "Remove Background Noise",
            description: "Remove ambient noise and hum",
            mode: .remove,
            prompt: "background noise and static",
            category: .noise
        ),
        
        AudioPreset(
            icon: "car.fill",
            title: "Remove Traffic",
            description: "Remove car sounds and honking",
            mode: .remove,
            prompt: "traffic and car noise",
            category: .noise
        ),
        
        AudioPreset(
            icon: "person.3.fill",
            title: "Remove Crowd",
            description: "Remove background chatter",
            mode: .remove,
            prompt: "crowd noise and chatter",
            category: .noise
        ),
        
        // MUSIC PRESETS
        AudioPreset(
            icon: "music.note",
            title: "Isolate Music",
            description: "Extract music, remove dialogue",
            mode: .isolate,
            prompt: "music and instruments",
            category: .music
        ),
        
        AudioPreset(
            icon: "music.note.slash",
            title: "Remove Music",
            description: "Remove background music",
            mode: .remove,
            prompt: "background music",
            category: .music
        ),
        
        AudioPreset(
            icon: "guitars.fill",
            title: "Isolate Guitar",
            description: "Extract guitar from mix",
            mode: .isolate,
            prompt: "guitar",
            category: .music
        ),
        
        AudioPreset(
            icon: "music.mic",
            title: "Isolate Vocals",
            description: "Extract singing vocals only",
            mode: .isolate,
            prompt: "singing vocals",
            category: .music
        )
    ]
    
    /// Get presets by category
    static func presets(for category: PresetCategory) -> [AudioPreset] {
        all.filter { $0.category == category }
    }
}
