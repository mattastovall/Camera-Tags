import SwiftUI
import Photos

struct ImageGalleryView: View {
    @State private var imagesWithTags: [(UIImage, String, Date, PHAsset)] = []
    @State private var tags: [PhotoTag] = []
    @State private var selectedTag: String?
    @State private var isPreviewPresented: Bool = false
    @State private var selectedImage: (UIImage, String, Date)?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Recent Images Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(imagesWithTags.sorted(by: { $0.2 > $1.2 }), id: \.0) { image, tag, date, asset in
                            HStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                Text(tag)
                                    .font(.headline)
                                    .padding()
                                Spacer()
                                Circle()
                                    .fill(colorForTag(tag))
                                    .frame(width: 10, height: 10)
                                    .padding(.trailing)
                            }
                            .padding(.horizontal)
                            .contentShape(Rectangle()) // Makes the entire HStack tappable
                            .onTapGesture {
                                fetchHighResolutionImage(for: asset) { highResImage in
                                    selectedImage = (highResImage, tag, date)
                                    isPreviewPresented.toggle()
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Tags Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.headline)
                            .padding([.leading, .top], 16)

                        ForEach(Array(Set(tags.map { $0.name })), id: \.self) { tagName in
                            if let tag = tags.first(where: { $0.name == tagName }) {
                                NavigationLink(destination: TagImagesView(tag: tag.name, imagesWithTags: imagesWithTags, tags: tags, colorForTag: colorForTag)) {
                                    HStack {
                                        Text(tag.name)
                                            .font(.headline)
                                            .padding()
                                        Spacer()
                                        Circle()
                                            .fill(tag.color)
                                            .frame(width: 10, height: 10)
                                            .padding(.trailing)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Gallery")
            .onAppear(perform: loadImagesWithTags)
            .background(BlurBackground())
            .sheet(isPresented: $isPreviewPresented) {
                if let selectedImage = selectedImage {
                    ImagePreviewView(image: selectedImage.0, tag: selectedImage.1, date: selectedImage.2, color: colorForTag(selectedImage.1))
                }
            }
        }
    }

    private func colorForTag(_ tag: String) -> Color {
        if let matchedTag = tags.first(where: { $0.name == tag }) {
            return matchedTag.color
        }
        return .gray
    }

    private func loadImagesWithTags() {
        let savedTags = UserDefaults.standard.dictionary(forKey: "savedTags") as? [String: [String: Any]] ?? [String: [String: Any]]()
        imagesWithTags.removeAll()
        tags = Array(Set(savedTags.values.compactMap { dict in
            if let name = dict["name"] as? String,
               let red = dict["red"] as? Double,
               let green = dict["green"] as? Double,
               let blue = dict["blue"] as? Double {
                let color = Color(red: red, green: green, blue: blue)
                print("Loaded tag '\(name)' with color components - Red: \(red), Green: \(green), Blue: \(blue)")
                return PhotoTag(name: name, color: color)
            }
            return nil
        }))

        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        assets.enumerateObjects { asset, _, _ in
            let assetID = asset.localIdentifier
            if let tagDict = savedTags[assetID],
               let tag = tagDict["name"] as? String {
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: options) { image, _ in
                    if let image = image {
                        self.imagesWithTags.append((image, tag, asset.creationDate ?? Date(), asset))
                    }
                }
            }
        }
    }

    private func fetchHighResolutionImage(for asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, _ in
            if let image = image {
                completion(image)
            }
        }
    }
}

struct ImagePreviewView: View {
    var image: UIImage
    var tag: String
    var date: Date
    var color: Color

    var body: some View {
        VStack {
            HStack {
                Text(tag)
                    .font(.largeTitle)
                    .foregroundColor(color)
                    .padding()
                Spacer()
            }
            Spacer()
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Spacer()
            Text("Captured on \(dateFormatter.string(from: date))")
                .font(.headline)
                .padding()
        }
        .background(Color.black.opacity(0.8).edgesIgnoringSafeArea(.all))
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct BlurBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        return blurEffectView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct TagImagesView: View {
    var tag: String
    var imagesWithTags: [(UIImage, String, Date, PHAsset)]
    var tags: [PhotoTag]
    var colorForTag: (String) -> Color

    @State private var isPreviewPresented: Bool = false
    @State private var selectedImage: (UIImage, String, Date)?

    var body: some View {
        List {
            ForEach(imagesWithTags.filter { $0.1 == tag }.sorted(by: { $0.2 > $1.2 }), id: \.0) { image, tag, date, asset in
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    Text(tag)
                        .font(.headline)
                        .padding()
                    Spacer()
                    Circle()
                        .fill(colorForTag(tag))
                        .frame(width: 10, height: 10)
                        .padding(.trailing)
                }
                .contentShape(Rectangle()) // Makes the entire HStack tappable
                .onTapGesture {
                    fetchHighResolutionImage(for: asset) { highResImage in
                        selectedImage = (highResImage, tag, date)
                        isPreviewPresented.toggle()
                    }
                }
            }
        }
        .navigationTitle("Images with tag: \(tag)")
        .sheet(isPresented: $isPreviewPresented) {
            if let selectedImage = selectedImage {
                ImagePreviewView(image: selectedImage.0, tag: selectedImage.1, date: selectedImage.2, color: colorForTag(selectedImage.1))
            }
        }
    }

    private func fetchHighResolutionImage(for asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, _ in
            if let image = image {
                completion(image)
            }
        }
    }
}
