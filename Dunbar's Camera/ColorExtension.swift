import SwiftUI

extension Color {
    var colorComponents: (red: Double, green: Double, blue: Double, opacity: Double) {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
        #else
        return (0, 0, 0, 0) // or some default value
        #endif
    }
}
