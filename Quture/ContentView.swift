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
    @State private var rectangleContents = Array(repeating: RectangleContent(imageId: -1, image: nil, caption: "Loading..."), count: 20) // Example for 20 rectangles
    @State private var showingLoginSettings = false
    @State private var activeScreen = ActiveScreen.home
    @State private var selectedImage: UIImage? // Track the selected image
    @State private var showingImageDetail = false // Whether to show the detail view
    @State private var showingPostPage = false // State to control the presentation of PostPageView
    @State private var selectedImageForPostPage: UIImage? // Add this line
    @State private var showingImageDetailView = false
    @State private var imageToDisplay: UIImage?
    @State private var navigateToPostView = false
    @State private var selectedRectangleIndex: Int? = nil
    @State private var showingVisualStudioView = false
    @State private var fetchedImages: [UIImage] = []
    @State private var isLoadingImages = true
    @State private var isActive = false // For the splash screen
    @State private var showingSearchView = false
    
    
    
    
    
    
    let topTabs = ["Explore", "Curate", "Nearby"]
    let rectangleBaseHeight: CGFloat = 150
    let rectangleMultiplier = 2.6
    let shrinkRatio: CGFloat = 0.8
    
    
    func handleImageConfirmation(image: UIImage, caption: String, tags: Set<Tag>) {
        if let index = rectangleContents.firstIndex(where: { $0.image == nil }) {
            ServerCommands().postImage(image: image, caption: caption) { newImageId, error in
                if let newImageId = newImageId {
                    rectangleContents[index] = RectangleContent(imageId: newImageId, image: image, caption: caption, tags: Array(tags))
                } else {
                    // Handle errors or set a default image
                    print(error?.localizedDescription ?? "Failed to fetch newImageId.")
                }
            }
            
            self.showingDetailScreen = false
            self.inputImage = nil // Reset the inputImage to ensure it's ready for a new selection
        }
    }
    
    //#################################
    //#################################
    //#################################
    
    
    // Computed property to adjust rectangle size when layout is modified
    var adjustedSize: CGFloat {
        rectangleBaseHeight * rectangleMultiplier * shrinkRatio
    }
    
    // Computed property for the original size of the rectangles
    var originalSize: CGFloat {
        rectangleBaseHeight * rectangleMultiplier
    }
    
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
        Group {
            if isActive {
                NavigationView {
                    VStack(spacing: 0) {
                        switch activeScreen {
                        case .home:
                            VStack(spacing: 0) {
                                topBarSection
                                contentSection
                                NavigationLink(destination: ImageDisplayView(imageId: 0, image: imageToDisplay ?? UIImage(), caption: "string"), isActive: Binding<Bool>(
                                    get: { self.imageToDisplay != nil },
                                    set: { if !$0 { self.imageToDisplay = nil } }
                                )) {
                                    EmptyView()
                                }
                            }
                        case .loginSettings:
                            LoginSettingsView()
                        }
                        
                        Spacer()
                        
                        bottomBarSection
                        NavigationLink(destination: DetailScreen(image: inputImage ?? UIImage(), caption: "", price: "", onConfirm: { image, caption, price, topTags, fashionTags in
                            // Adjust this part according to your app's logic to handle image, caption, price, and tags
                            self.handleImageConfirmation(image: image, caption: caption, tags: topTags.union(fashionTags))
                        }), isActive: $showingDetailScreen) {
                            EmptyView()
                        }
                        
                        // Additional navigation links if needed
                        // ...
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: $inputImage)
                    }
                    .fullScreenCover(isPresented: $showingPostPage) {
                        if let selectedImage = selectedImageForPostPage {
                            PostPageView(image: selectedImage)
                        } else {
                            Text("No image selected")
                        }
                    }
                }
            } else {
                SplashScreen()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isActive = true
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
                    .iconModifier()
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
                        .padding(.horizontal, 8)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                
                Spacer()
                
                Button(action: {
                    showingSearchView = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .iconModifier()
                        .foregroundColor(.white)
                }
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
        .background(
            NavigationLink(destination: SearchView(), isActive: $showingSearchView) {
                EmptyView()
            }
                .hidden()
        )
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
                                .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                                .clipped()
                                .onTapGesture {
                                    self.selectedRectangleIndex = index // Mark the selected image
                                }
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                        }
                        
                        if isLayoutModified {
                            Text(rectangleContents[index].caption)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .background(
                        NavigationLink(
                            destination: ImageDisplayView(imageId: rectangleContents[index].imageId, image: rectangleContents[index].image ?? UIImage(), caption: rectangleContents[index].caption),
                            isActive: .init(
                                get: { self.selectedRectangleIndex == index },
                                set: { _ in self.selectedRectangleIndex = nil }
                            )
                        ) { EmptyView() }
                            .hidden()
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            isLoadingImages = true
            ServerCommands().getImagesForUser(userId: 3) { images, captions, error in
                if let images = images {
                    for (index, image) in images.enumerated() where index < self.rectangleContents.count {
                        self.rectangleContents[index].image = image
                    }
                } else {
                    // Handle errors or set a default image
                    print(error?.localizedDescription ?? "Failed to fetch images.")
                }
                if let captions = captions {
                    for (index, caption) in captions.enumerated() where index < self.rectangleContents.count {
                        self.rectangleContents[index].caption = caption
                    }
                } else {
                    // Handle errors or set a default image
                    print(error?.localizedDescription ?? "Failed to fetch captions.")
                }
                isLoadingImages = false
            }
        }
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
                .onTapGesture {
                    showingVisualStudioView = true // Trigger navigation
                }
            
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
        .background(
            NavigationLink(destination: VisualStudioView(), isActive: $showingVisualStudioView) {
                EmptyView()
            }
                .hidden() // Hide the NavigationLink since it's used programmatically
        )
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

struct SplashScreen: View {
    var body: some View {
        GeometryReader { geometry in
            Image("QUTURE") // Replace "QUTURE" with your image name
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height * 0.8) // Make the logo smaller
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the cropped image
                .background(Color.white) // Set the background color to white
                .edgesIgnoringSafeArea(.all)
        }
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
