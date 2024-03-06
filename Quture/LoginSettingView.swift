import SwiftUI

struct LoginSettingsView: View {
    let rectangles = Array(repeating: RectangleContent(image: nil, caption: "input", tags: []), count: 20)

    // Use the exact dimensions and spacing as in ContentView
    private let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2
    private let rectangleHeight: CGFloat = ((UIScreen.main.bounds.width - 32) / 2) * (4 / 3)

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Circle()
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    )
                    .padding()
                    .frame(height: geometry.size.height * 0.45)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<rectangles.count, id: \.self) { index in
                            VStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: rectangleWidth, height: rectangleHeight)
                                
                                Text(rectangles[index].caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: geometry.size.height * 0.55)
            }
        }
    }
}

struct LoginSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSettingsView()
    }
}
