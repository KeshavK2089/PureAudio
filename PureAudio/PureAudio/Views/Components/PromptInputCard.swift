//
//  PromptInputCard.swift
//  AudioPure
//
//  Reusable prompt input component with suggestions
//

import SwiftUI

struct PromptInputCard: View {
    @Binding var prompt: String
    let suggestions: [String]
    let onSuggestionTap: (String) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("What sound?")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Text field
            HStack {
                TextField("e.g., voice, music, wind", text: $prompt)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .font(.body)
                
                if !prompt.isEmpty {
                    Button {
                        prompt = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.subtleGray)
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.primaryPurple : Color.clear, lineWidth: 2)
            )
            
            // Hint
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                
                Text("Be specific: \"male voice\" not just \"voice\"")
                    .font(.caption)
            }
            .foregroundColor(.subtleGray)
            
            // Suggestions
            if suggestions.count > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestions:")
                        .font(.caption)
                        .foregroundColor(.subtleGray)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(suggestions.prefix(8), id: \.self) { suggestion in
                            Button {
                                onSuggestionTap(suggestion)
                            } label: {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryPurple.opacity(0.1))
                                    .foregroundColor(.primaryPurple)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    PromptInputCard(
        prompt: .constant(""),
        suggestions: ["voice", "wind", "music", "guitar"],
        onSuggestionTap: { _ in }
    )
    .padding()
}
