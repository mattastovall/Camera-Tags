import SwiftUI

struct TagEditor: View {
    @Binding var tags: [PhotoTag]
    @State private var newTagName: String = ""
    @State private var selectedColor: Color = .blue
    @FocusState private var isEditing: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($tags) { $tag in
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 30, height: 30)

                                ColorPicker("", selection: $tag.color)
                                    .labelsHidden()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            }

                            TextField("Tag name", text: $tag.name)
                                .font(.headline)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(.horizontal)
                                .focused($isEditing)
                        }
                        .padding(.vertical, 10)
                    }
                    .onDelete(perform: deleteTags)
                    .onMove(perform: moveTags)
                }
            }
            .navigationTitle("Tags")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addTag) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
        }
    }

    private func addTag() {
        let newTag = PhotoTag(name: "", color: selectedColor)
        tags.append(newTag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isEditing = true
        }
    }

    private func deleteTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }

    private func moveTags(from source: IndexSet, to destination: Int) {
        tags.move(fromOffsets: source, toOffset: destination)
    }
}

struct TagEditor_Previews: PreviewProvider {
    @State static var sampleTags = [
        PhotoTag(name: "Work", color: .blue),
        PhotoTag(name: "Personal", color: .green),
        PhotoTag(name: "Travel", color: .orange)
    ]
    
    static var previews: some View {
        TagEditor(tags: $sampleTags)
    }
}
