import SwiftUI
import AVFoundation
import Photos

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var showTagSelector: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didCapturePhoto(image: UIImage) {
            parent.capturedImage = image
            parent.showTagSelector = true
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(image: UIImage)
}
