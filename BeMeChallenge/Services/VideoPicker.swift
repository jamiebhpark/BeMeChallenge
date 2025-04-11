import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { sourceURL, error in
                    if let error = error {
                        print("비디오 로드 에러: \(error.localizedDescription)")
                        return
                    }
                    guard let sourceURL = sourceURL else { return }
                    // 파일을 임시 디렉터리로 복사하여 URL 확보
                    let fileManager = FileManager.default
                    let tmpDir = NSTemporaryDirectory()
                    let targetURL = URL(fileURLWithPath: tmpDir).appendingPathComponent(sourceURL.lastPathComponent)
                    do {
                        if fileManager.fileExists(atPath: targetURL.path) {
                            try fileManager.removeItem(at: targetURL)
                        }
                        try fileManager.copyItem(at: sourceURL, to: targetURL)
                        DispatchQueue.main.async {
                            self.parent.videoURL = targetURL
                        }
                    } catch {
                        print("비디오 파일 복사 에러: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
