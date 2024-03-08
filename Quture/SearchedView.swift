import SwiftUI

struct SearchedView: View {
    @Environment(\.presentationMode) var presentationMode
    var searchText: String

    let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2 // Assuming 32 is the total horizontal padding
    let rectangleHeight: CGFloat = (UIScreen.main.bounds.width - 32) / 2 * (4 / 3) // For a 3:4 aspect ratio
    @State private var rectangleContents = Array(repeating: RectangleContent(image: nil, caption: "input"), count: 100) // Example for 100 rectangles

    var body: some View {
        VStack {
            // Top bar
            HStack {
                Button(action: {
                    // Dismiss SearchedView to go back to SearchView
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Search results for: \(searchText)")
                    .font(.title)
                    .bold()

                Spacer()
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)

            // Infinite list of rectangles
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible())], spacing: 10) {
                    ForEach(rectangleContents.indices, id: \.self) { index in
                        VStack {
                            if let image = rectangleContents[index].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: rectangleWidth, height: rectangleHeight)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: rectangleWidth, height: rectangleHeight)
                            }
                            Text(rectangleContents[index].caption)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            Spacer()
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
}

struct SearchedView_Previews: PreviewProvider {
    static var previews: some View {
        SearchedView(searchText: "Example")
    }
}
