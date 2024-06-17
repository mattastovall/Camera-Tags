import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showTagEditor: Bool = false
    @State private var showTagSelector: Bool = false
    @State private var selectedTag: String?
    @State private var capturedImage: UIImage?
    @State private var tags: [PhotoTag] = [
        PhotoTag(name: "Work", color: .blue),
        PhotoTag(name: "Personal", color: .green),
        PhotoTag(name: "Travel", color: .orange)
    ]
    

    var body: some View {
        NavigationView {
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
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: capturedImage)
                        Spacer()
                        Button("Select Tag") {
                            withAnimation {
                                showTagSelector = true
                            }
                        }
                        .padding()
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        NavigationLink(destination: ImageGalleryView()) {
                            Image(systemName: "photo")
                                .resizable() // Enables resizing
                                .aspectRatio(contentMode: .fit) // Maintains aspect ratio while fitting
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.clear)
                        }
                        Spacer()
                        Button(action: {
                            capturePhoto()
                        }) {
                            Circle()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                                .background(Color.clear)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        Spacer()
                        Button(action: {
                            showTagEditor = true
                        }) {
                            Image(systemName: "tag")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.clear)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showTagEditor) {
                TagEditor(tags: $tags)
            }
            .onReceive(NotificationCenter.default.publisher(for: .dismissTagSelector)) { _ in
              withAnimation {
                capturedImage = nil
              }
            }
            .overlay(
                Group {
                    if showTagSelector {
                        Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                        TagSelectorView(selectedTag: $selectedTag, tags: $tags, showTagSelector: $showTagSelector)
                            .onDisappear {
                                if let tag = selectedTag, let image = capturedImage {
                                    saveImageWithTag(image, tag)
                                }
                            }
                            .frame(width: 300, height: 400)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: showTagSelector)
                    }
                }
            )
        }
    }
    
    private func capturePhoto() {
        NotificationCenter.default.post(name: .capturePhoto, object: nil)
        
    }
    
    
    
    private func saveImageWithTag(_ image: UIImage, _ tag: String) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeholder = request.placeholderForCreatedAsset
            let assetID = placeholder?.localIdentifier ?? ""
            
            var savedTags = UserDefaults.standard.dictionary(forKey: "savedTags") as? [String: [String: Any]] ?? [String: [String: Any]]()
            if let matchedTag = tags.first(where: { $0.name == tag }) {
                let colorComponents = matchedTag.color.colorComponents
                print("Saving tag '\(tag)' with color components - Red: \(colorComponents.red), Green: \(colorComponents.green), Blue: \(colorComponents.blue)")
                savedTags[assetID] = [
                    "name": matchedTag.name,
                    "red": colorComponents.red,
                    "green": colorComponents.green,
                    "blue": colorComponents.blue
                ]
                
            }
            UserDefaults.standard.setValue(savedTags, forKey: "savedTags")
            
        }) { success, error in
            if success {
                print("Image and tag saved successfully.")
                DispatchQueue.main.async {
                    withAnimation {
                        self.capturedImage = nil
                        self.showTagSelector = false
                    }
                }
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }
}
// Define a notification name for dismissing the tag selector
extension Notification.Name {
  static let dismissTagSelector = Notification.Name("dismissTagSelector")
}


extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
    
}


