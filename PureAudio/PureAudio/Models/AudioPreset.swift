//
//  AudioPreset.swift
//  AudioPure
//
//  Presets optimized for SAM Audio natural language prompting
//  Enhanced with persona-based bundles for different creator types
//
//  Citation:
//  SAM-Audio: Segment Anything in Audio
//  Bowen Shi et al., 2025
//  https://arxiv.org/abs/2512.18099
//  https://github.com/facebookresearch/sam-audio
//

import Foundation
import SwiftUI

/// A quick preset with optimized prompt for common audio tasks
struct AudioPreset: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let mode: ProcessingMode
    let prompt: String
    let category: PresetCategory
    let persona: CreatorPersona?
    
    enum PresetCategory: String, CaseIterable {
        case voice = "Voice"
        case noise = "Noise"
        case music = "Music"
        case environment = "Environment"
    }
    
    init(icon: String, title: String, description: String, mode: ProcessingMode, prompt: String, category: PresetCategory, persona: CreatorPersona? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.mode = mode
        self.prompt = prompt
        self.category = category
        self.persona = persona
    }
}

/// Creator personas for targeted preset bundles
enum CreatorPersona: String, CaseIterable, Identifiable {
    case podcaster = "Podcaster"
    case vlogger = "Vlogger"
    case musician = "Musician"
    case student = "Student"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .podcaster: return "mic.fill"
        case .vlogger: return "video.fill"
        case .musician: return "guitars.fill"
        case .student: return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .podcaster: return .orange
        case .vlogger: return .pink
        case .musician: return .purple
        case .student: return .blue
        }
    }
    
    var tagline: String {
        switch self {
        case .podcaster: return "Crystal clear conversations"
        case .vlogger: return "Professional outdoor audio"
        case .musician: return "Isolate any instrument"
        case .student: return "Never miss a lecture"
        }
    }
}

// MARK: - Preset Library

extension AudioPreset {
    
    // MARK: - Quick Presets (Most Used)
    
    static let quickPresets: [AudioPreset] = [
        AudioPreset(
            icon: "person.wave.2.fill",
            title: "Clean My Voice",
            description: "Isolate your voice, remove background",
            mode: .isolate,
            prompt: "A person speaking",
            category: .voice
        ),
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
            category: .environment
        ),
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
    
    // MARK: - Podcaster Presets
    
    static let podcasterPresets: [AudioPreset] = [
        AudioPreset(
            icon: "mic.fill",
            title: "Studio Quality Voice",
            description: "Broadcast-ready voice clarity",
            mode: .isolate,
            prompt: "A person speaking clearly into a microphone",
            category: .voice,
            persona: .podcaster
        ),
        AudioPreset(
            icon: "waveform.path.ecg",
            title: "Remove Room Echo",
            description: "Fix echoey recordings",
            mode: .remove,
            prompt: "Room echo and reverb",
            category: .environment,
            persona: .podcaster
        ),
        AudioPreset(
            icon: "keyboard.fill",
            title: "Remove Keyboard Clicks",
            description: "Clean up typing sounds",
            mode: .remove,
            prompt: "Keyboard typing and clicking sounds",
            category: .noise,
            persona: .podcaster
        ),
        AudioPreset(
            icon: "fan.fill",
            title: "Remove AC/Fan Noise",
            description: "Fix HVAC background hum",
            mode: .remove,
            prompt: "Air conditioning fan and humming noise",
            category: .noise,
            persona: .podcaster
        )
    ]
    
    // MARK: - Vlogger Presets
    
    static let vloggerPresets: [AudioPreset] = [
        AudioPreset(
            icon: "wind",
            title: "Outdoor Wind Fix",
            description: "Crystal clear outdoor audio",
            mode: .remove,
            prompt: "Strong wind and breeze noise",
            category: .environment,
            persona: .vlogger
        ),
        AudioPreset(
            icon: "figure.walk",
            title: "Remove Crowd Noise",
            description: "Hear yourself in busy places",
            mode: .remove,
            prompt: "Crowd chatter and people talking",
            category: .environment,
            persona: .vlogger
        ),
        AudioPreset(
            icon: "car.fill",
            title: "Remove Street Noise",
            description: "Clean urban recordings",
            mode: .remove,
            prompt: "Traffic noise cars and sirens",
            category: .environment,
            persona: .vlogger
        ),
        AudioPreset(
            icon: "music.note.slash",
            title: "Remove Copyright Music",
            description: "Avoid content strikes",
            mode: .remove,
            prompt: "Background music playing",
            category: .music,
            persona: .vlogger
        )
    ]
    
    // MARK: - Musician Presets
    
    static let musicianPresets: [AudioPreset] = [
        AudioPreset(
            icon: "music.mic",
            title: "Isolate Vocals",
            description: "Extract singing voice only",
            mode: .isolate,
            prompt: "Singing voice and vocals",
            category: .voice,
            persona: .musician
        ),
        AudioPreset(
            icon: "guitars.fill",
            title: "Isolate Guitar",
            description: "Extract guitar parts",
            mode: .isolate,
            prompt: "Guitar playing acoustic or electric",
            category: .music,
            persona: .musician
        ),
        AudioPreset(
            icon: "drum.fill",
            title: "Isolate Drums",
            description: "Extract drum and percussion",
            mode: .isolate,
            prompt: "Drums and percussion instruments",
            category: .music,
            persona: .musician
        ),
        AudioPreset(
            icon: "pianokeys",
            title: "Isolate Piano",
            description: "Extract piano/keys",
            mode: .isolate,
            prompt: "Piano and keyboard instruments",
            category: .music,
            persona: .musician
        ),
        AudioPreset(
            icon: "waveform.badge.minus",
            title: "Remove Clicks/Pops",
            description: "Clean up recording artifacts",
            mode: .remove,
            prompt: "Clicks pops and static noise",
            category: .noise,
            persona: .musician
        )
    ]
    
    // MARK: - Student Presets
    
    static let studentPresets: [AudioPreset] = [
        AudioPreset(
            icon: "person.fill",
            title: "Isolate Professor",
            description: "Hear the lecture clearly",
            mode: .isolate,
            prompt: "A professor or teacher speaking",
            category: .voice,
            persona: .student
        ),
        AudioPreset(
            icon: "studentdesk",
            title: "Remove Classroom Noise",
            description: "Remove student chatter",
            mode: .remove,
            prompt: "Students talking and classroom noise",
            category: .environment,
            persona: .student
        ),
        AudioPreset(
            icon: "pencil.line",
            title: "Remove Paper Sounds",
            description: "Remove rustling/writing",
            mode: .remove,
            prompt: "Paper rustling and writing sounds",
            category: .noise,
            persona: .student
        ),
        AudioPreset(
            icon: "building.2.fill",
            title: "Remove Hall Echo",
            description: "Fix lecture hall recordings",
            mode: .remove,
            prompt: "Large room echo and reverb",
            category: .environment,
            persona: .student
        )
    ]
    
    // MARK: - Helpers
    
    /// All presets combined (for backward compatibility)
    static let all: [AudioPreset] = quickPresets
    
    /// Get presets for a specific persona
    static func presets(for persona: CreatorPersona) -> [AudioPreset] {
        switch persona {
        case .podcaster: return podcasterPresets
        case .vlogger: return vloggerPresets
        case .musician: return musicianPresets
        case .student: return studentPresets
        }
    }
    
    /// Get presets by category
    static func presets(for category: PresetCategory) -> [AudioPreset] {
        let allPresets = quickPresets + podcasterPresets + vloggerPresets + musicianPresets + studentPresets
        return allPresets.filter { $0.category == category }
    }
}
