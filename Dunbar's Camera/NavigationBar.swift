import SwiftUI

struct CustomNavigationBar: View {
    var title: String
    var height: CGFloat

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(height: height)
            .background(BlurBackground().edgesIgnoringSafeArea(.top))
        }
        .frame(height: height)
    }
}

struct BlurBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
