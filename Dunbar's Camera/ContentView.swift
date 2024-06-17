import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showTagSelector: Bool = false
    @State private var capturedImage: UIImage?
    @State private var selectedTag: String?
    @State private var tags: [String] = ["Work", "Personal", "Travel"] // Example tags

    var body: some View {
        ZStack {
            CameraView(capturedImage: $capturedImage, showTagSelector: $showTagSelector)
                .edgesIgnoringSafeArea(.all)
            
            if let capturedImage = capturedImage {
                VStack {
                    Spacer()
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                    Spacer()
                    Button("Select Tag") {
                        showTagSelector = true
                    }
                    .padding()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        capturePhoto()
                    }) {
                        Circle()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showTagSelector) {
            TagSelectorView(selectedTag: $selectedTag, tags: tags)
                .onDisappear {
                    if let tag = selectedTag, let image = capturedImage {
                        saveImageWithTag(image, tag)
                    }
                }
        }
    }
    
    private func capturePhoto() {
        NotificationCenter.default.post(name: .capturePhoto, object: nil)
    }
    
    private func saveImageWithTag(_ image: UIImage, _ tag: String) {
        // Save the image to the photo library
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeholder = request.placeholderForCreatedAsset
            let assetID = placeholder?.localIdentifier ?? ""
            
            // Save the tag information to UserDefaults
            var savedTags = UserDefaults.standard.dictionary(forKey: "savedTags") as? [String: String] ?? [String: String]()
            savedTags[assetID] = tag
            UserDefaults.standard.setValue(savedTags, forKey: "savedTags")
            
        }) { success, error in
            if success {
                print("Image and tag saved successfully.")
                DispatchQueue.main.async {
                    self.capturedImage = nil
                }
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }
}

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}
