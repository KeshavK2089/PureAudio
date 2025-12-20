//
//  FilePickerButton.swift
//  PureAudio
//
//  Reusable file picker button component
//

import SwiftUI
import PhotosUI

struct FilePickerButton: View {
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .any(of: [.videos, .not(.images)])) {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryPurple)
                
                VStack(spacing: 8) {
                    Text("Select Audio/Video")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("Tap to import file")
                        .font(.subheadline)
                        .foregroundColor(.subtleGray)
                }
                
                Text("Supports: MP3, WAV, M4A, MP4, MOV")
                    .font(.caption)
                    .foregroundColor(.subtleGray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FilePickerButton(selectedItem: .constant(nil))
        .padding()
}
