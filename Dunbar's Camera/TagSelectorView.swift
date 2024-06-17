import SwiftUI

struct TagSelectorView: View {
    @Binding var selectedTag: String?
    var tags: [String]
    
    var body: some View {
        NavigationView {
            List(tags, id: \.self) { tag in
                Button(action: {
                    selectedTag = tag
                }) {
                    Text(tag)
                }
            }
            .navigationTitle("Select Tag")
        }
    }
}
