import SwiftUI
import Swift

enum ActiveScreen {
    case home
    case loginSettings
    // Add other cases as needed
}

struct ContentView: View {
    //overall tabs and layout
    @State private var selectedTopTab = 0
    @State private var isLayoutModified = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingDetailScreen = false
    @State private var rectangleContents = Array(repeating: RectangleContent(image: nil, caption: "input"), count: 20) // Example for 20 rectangles
    // Add to your ContentView's state variables
    @State private var showingLoginSettings = false
    @State private var activeScreen = ActiveScreen.home
    @State private var selectedImage: UIImage? // Track the selected image
    @State private var showingImageDetail = false // Whether to show the detail view
    @State private var showingPostPage = false // State to control the presentation of PostPageView
    @State private var selectedImageForPostPage: UIImage? // Add this line
    @State private var showingImageDetailView = false
    @State private var imageToDisplay: UIImage?


    
    
    
    let topTabs = ["Explore", "Curate", "Nearby"]
    let rectangleBaseHeight: CGFloat = 150
    let rectangleMultiplier = 2.6
    let shrinkRatio: CGFloat = 0.8
    
    
    func handleImageConfirmation(image: UIImage, caption: String) {
        // Find the first rectangle that doesn't have an image and update it
        if let index = rectangleContents.firstIndex(where: { $0.image == nil }) {
            rectangleContents[index] = RectangleContent(image: image, caption: caption)
        }
    }
    
    
    // Computed property to adjust rectangle size when layout is modified
    var adjustedSize: CGFloat {
        rectangleBaseHeight * rectangleMultiplier * shrinkRatio
    }
    
    // Computed property for the original size of the rectangles
    var originalSize: CGFloat {
        rectangleBaseHeight * rectangleMultiplier
    }
    
    //    //horizontal image width
    //    var rectangleWidth: CGFloat {
    //        // Assuming the screen width is divided into two columns with some padding
    //        let totalPadding: CGFloat = 32 // Adjust based on your design's padding
    //        return (UIScreen.main.bounds.width - totalPadding) / 2
    //    }
    //    //horizonal image height
    //    var rectangleHeight: CGFloat {
    //        // Maintaining a 4:3 aspect ratio
    //        return rectangleWidth * (3 / 4)
    //    }
    
    var rectangleWidth: CGFloat {
        // Assuming a specific padding between the grid items and the screen edges
        let totalHorizontalPadding: CGFloat = 32 // Example padding - adjust as needed
        return (UIScreen.main.bounds.width - totalHorizontalPadding) / 2
    }
    
    // Compute rectangleHeight for a 3:4 aspect ratio
    var rectangleHeight: CGFloat {
        return rectangleWidth * (4 / 3)
    }

    //MARK: Body: some view
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                switch activeScreen {
                case .home:
                    VStack(spacing: 0) {
                        topBarSection
                        contentSection
                            .overlay {
                                if let imageToDisplay = imageToDisplay {
                                    Color.black.opacity(0.4)
                                        .edgesIgnoringSafeArea(.all)
                                        .onTapGesture {
                                            self.imageToDisplay = nil // Dismiss the overlay by setting the image to nil
                                        }

                                    Image(uiImage: imageToDisplay)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 300, height: 400)
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                        .padding()
                                        .onTapGesture {
                                            self.imageToDisplay = nil // Allow tapping the image itself to also dismiss
                                        }
                                }
                            }
                    }
                case .loginSettings:
                    LoginSettingsView()
                }
                
                Spacer()
                
                bottomBarSection
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .sheet(isPresented: $showingDetailScreen) {
                if let image = inputImage {
                    DetailScreen(image: image, caption: "", onConfirm: handleImageConfirmation)
                }
            }
            .fullScreenCover(isPresented: $showingPostPage) {
                if let selectedImage = selectedImageForPostPage {
                    PostPageView(image: selectedImage)
                } else {
                    // Consider a fallback view or error handling if no image is selected
                    Text("No image selected")
                }
            }
        }
    }

    func loadImage() {
        guard let _ = inputImage else { return }
        showingDetailScreen = true
    }
    
    
    // MARK: - Top Bar Section
    var topBarSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(.leading)
                    .foregroundColor(.coralGreen)
                    .onTapGesture {
                        withAnimation {
                            isLayoutModified.toggle()
                        }
                    }
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(topTabs, id: \.self) { tab in
                        Button(action: {
                            selectedTopTab = topTabs.firstIndex(of: tab) ?? 0
                        }) {
                            Text(tab)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(selectedTopTab == topTabs.firstIndex(of: tab) ? .white : .primary)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(.trailing)
                    .foregroundColor(.white)
            }
            
            // Scrolling Tab Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(["Minimalism", "Techwear", "Avant-Garde", "Preppy", "Customs", "Denim", "Athleisure", "Archive"], id: \.self) { category in
                        Button(action: {
                            // Perform an action when a category is tapped
                            print("\(category) tapped")
                        }) {
                            Text(category)
                                .font(.system(size: 16))
                                .padding(.vertical, 6)
                                .frame(width: 100)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .foregroundColor(.white) // Set the text color for the button
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
        }
        .background(Color.gray.opacity(0.2))
    }
    
    
    // MARK: - Content Section
    var contentSection: some View {
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
                                   .onTapGesture {
                                       self.imageToDisplay = image
                                       self.showingImageDetailView = true
                                   }
                           } else {
                               Rectangle()
                                   .fill(Color.gray.opacity(0.3))
                                   .frame(width: rectangleWidth, height: rectangleHeight)
                           }

                           if isLayoutModified {
                               Text(rectangleContents[index].caption)
                                   .foregroundColor(.white)
                                   .frame(maxWidth: .infinity, alignment: .leading)
                           }
                       }
                       .frame(height: rectangleHeight + (isLayoutModified ? 20 : 0))
                       .sheet(isPresented: $showingImageDetailView) {
                           if let imageToDisplay = imageToDisplay {
                               ImageDetailView(image: imageToDisplay)
                           }
                       }
                       .frame(height: rectangleHeight + (isLayoutModified ? 20 : 0))
                   }
               }
               .padding(.horizontal, 16)
           }
           .frame(maxHeight: .infinity)
       }
    
    
    
    // MARK: - Bottom Bar Section
    var bottomBarSection: some View {
        HStack {
            // Home icon
            Image(systemName: "house.fill").iconModifier()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    activeScreen = .home
                }
            
            // Other icons as placeholders
            Image(systemName: "bell.fill").iconModifier()
                .frame(maxWidth: .infinity)
            
            Image(systemName: "plus.square.fill").iconModifier()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    showingImagePicker = true
                }
            
            Image(systemName: "heart.fill").iconModifier()
                .frame(maxWidth: .infinity)
            
            // User login/settings icon
            Image(systemName: "person.fill").iconModifier()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    activeScreen = .loginSettings
                }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color.black)
        .padding(.bottom)
    }
}


extension Image {
    func iconModifier() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImageDetailView: View {
    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Actions if needed, e.g., close view
                    }) {
                        Text("Close")
                    }
                }
            }
    }
}
