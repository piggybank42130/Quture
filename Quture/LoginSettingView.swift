import SwiftUI

struct LoginSettingsView: View {
    @State private var rectangleContents = Array(repeating: RectangleContent(image: nil, caption: "input"), count: 20)

    private let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2
    private let rectangleHeight: CGFloat = ((UIScreen.main.bounds.width - 32) / 2) * (4 / 3)
    @State private var isLoadingImages = true
    
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
                        ForEach(0..<rectangleContents.count, id: \.self) { index in
                            VStack {
                                if let uiImage = rectangleContents[index].image {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: rectangleWidth, height: rectangleHeight)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: rectangleWidth, height: rectangleHeight)
                                }
                                
                                Text(rectangleContents[index].caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: geometry.size.height * 0.55)
                .onAppear {
                    isLoadingImages = true
                    Getter().getImagesForUser(userId: 3) { images, error in
                        DispatchQueue.main.async { // Ensure UI operations are on the main thread
                            if let images = images {
                                for (index, image) in images.enumerated() where index < self.rectangleContents.count {
                                    self.rectangleContents[index].image = image
                                }
                            } else {
                                // Handle errors or set a default image
                                print(error?.localizedDescription ?? "Failed to fetch images.")
                            }
                            isLoadingImages = false
                        }
                    }
                }
            }
        }
    }
}

struct LoginSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSettingsView()
    }
}
