import SwiftUI

struct PhotoTag: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
}
