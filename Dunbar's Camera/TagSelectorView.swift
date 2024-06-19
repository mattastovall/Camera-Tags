import SwiftUI

struct TagSelectorView: View {
    @Binding var selectedTag: String?
    @Binding var tags: [PhotoTag]
    @Binding var showTagSelector: Bool
    @State private var showTagEditor: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    withAnimation {
                        showTagSelector = false
                        // Post notification here (assuming you want to from TagSelectorView)
                        NotificationCenter.default.post(name: .dismissTagSelector, object: nil)
                    }
                }) {
                    Text("Close")
                }
                Spacer()
                Button(action: {
                    // Action to show tag editor
                    showTagEditor = true
                }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showTagEditor) {
                    TagEditor(tags: $tags)
                }
            }
            .padding(.horizontal)

            ForEach(tags) { tag in
                Button(action: {
                    withAnimation {
                        selectedTag = tag.name
                        showTagSelector = false
                    }
                }) {
                    HStack {
                        Circle()
                            .fill(tag.color)
                            .frame(width: 20, height: 20)
                        Text(tag.name)
                            .font(.title3)
                            .padding(.leading, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedTag == tag.name ? Color.gray.opacity(0.5) : Color.clear)
                    .cornerRadius(10)
                }
            }

            Button(action: {
                withAnimation {
                    showTagSelector = false // Close the tag selector
                }
            }) {
                Text("Done")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: showTagSelector)
    }
}
