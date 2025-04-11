import SwiftUI
import AVKit

struct VideoUploadView: View {
    @Binding var videoURL: URL?
    var challengeId: String
    @StateObject var viewModel = VideoUploadViewModel()
    @State private var isUploading = false
    @State private var uploadError: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()
            } else {
                Text("선택된 비디오가 없습니다.")
            }
            
            HStack(spacing: 16) {
                Button("다시 선택") {
                    videoURL = nil
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Button(action: {
                    guard let videoURL = videoURL else { return }
                    isUploading = true
                    viewModel.uploadVideo(videoURL: videoURL, forChallenge: challengeId) { result in
                        DispatchQueue.main.async {
                            isUploading = false
                            switch result {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                uploadError = error.localizedDescription
                            }
                        }
                    }
                }) {
                    if isUploading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("비디오 업로드")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("비디오 업로드")
        .alert(item: $uploadError) { error in
            Alert(title: Text("업로드 오류"), message: Text(error), dismissButton: .default(Text("확인")))
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct VideoUploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoUploadView(videoURL: .constant(URL(string:"https://www.example.com/sample.mov")), challengeId: "challenge1")
        }
    }
}
