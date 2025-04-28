//VideoUploadContainerView.swift
import SwiftUI

struct VideoUploadContainerView: View {
    @State private var selectedVideoURL: URL?
    @State private var isPickerPresented = false
    var challengeId: String
    
    var body: some View {
        VStack {
            if let _ = selectedVideoURL {
                VideoUploadView(videoURL: $selectedVideoURL, challengeId: challengeId)
            } else {
                Button("비디오 선택") {
                    isPickerPresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            VideoPicker(videoURL: $selectedVideoURL)
        }
    }
}

struct VideoUploadContainerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoUploadContainerView(challengeId: "challenge1")
    }
}
