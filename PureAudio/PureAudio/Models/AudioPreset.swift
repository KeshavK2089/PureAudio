//
//  AudioPreset.swift
//  AudioPure
//
//  Presets optimized for SAM Audio natural language prompting
//
//  Citation:
//  SAM-Audio: Segment Anything in Audio
//  Bowen Shi et al., 2025
//  https://arxiv.org/abs/2512.18099
//  https://github.com/facebookresearch/sam-audio
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
    
    /// Presets with natural language prompts optimized for SAM Audio
    /// SAM Audio works best with descriptive phrases like "A person speaking"
    static let all: [AudioPreset] = [
        
        // PRIMARY - Voice (most used by influencers)
        AudioPreset(
            icon: "person.wave.2.fill",
            title: "Clean My Voice",
            description: "Isolate your voice, remove background",
            mode: .isolate,
            prompt: "A person speaking",
            category: .voice
        ),
        
        // NOISE REMOVAL
        AudioPreset(
            icon: "waveform.badge.minus",
            title: "Remove All Noise",
            description: "Clean up unwanted sounds",
            mode: .remove,
            prompt: "Background noise and ambient sounds",
            category: .noise
        ),
        
        AudioPreset(
            icon: "wind",
            title: "Remove Wind",
            description: "Fix outdoor recordings",
            mode: .remove,
            prompt: "Wind noise",
            category: .noise
        ),
        
        AudioPreset(
            icon: "car.fill",
            title: "Remove Traffic",
            description: "Remove city sounds",
            mode: .remove,
            prompt: "Traffic and car sounds",
            category: .noise
        ),
        
        // MUSIC
        AudioPreset(
            icon: "music.note.slash",
            title: "Remove Music",
            description: "Remove copyrighted music",
            mode: .remove,
            prompt: "Background music",
            category: .music
        ),
        
        AudioPreset(
            icon: "music.note",
            title: "Keep Only Music",
            description: "Remove speech, keep music",
            mode: .isolate,
            prompt: "Music and instruments",
            category: .music
        )
    ]
    
    /// Get presets by category
    static func presets(for category: PresetCategory) -> [AudioPreset] {
        all.filter { $0.category == category }
    }
}
