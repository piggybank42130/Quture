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
    @State private var rectangleContents: [RectangleContent] = [] // Example for 20 rectangles
    @State private var selectedContent: RectangleContent?

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
    @State private var isActive = false // For the splash screen
    @State private var showingSearchView = false
    @State var isUserLoggedIn = !LocalStorage().needToLogin() // For the login flow
    @State private var showingNotificationView = false
    @State private var isLoading = true
    @State private var isNavigationActive = false
    @State private var hasNotifications = false
    @State private var unseenCount: Int = 0
    @State private var showingPopup = true
    @State private var showingPopupOverlay = false // Add this state variable

    @State private var allImageIds: [Int] = []
    @State private var currentBatchIndex = 0
    @State private var isLoadingContent = false
    private let batchSize = 7
    
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    
    let topTabs = ["Explore", "Curate", "Nearby"]
    let rectangleBaseHeight: CGFloat = 150
    let rectangleMultiplier = 2.6
    let shrinkRatio: CGFloat = 0.8
    
     func handleLoginSuccess() {
         activeScreen = .home
         self.showingPopupOverlay = true
     }
     
    func handleImageConfirmation(image: UIImage, caption: String, tags: Set<Tag>, price: String) {
        Task {
            do {
                self.isLoading = true
                let newImageId = try await ServerCommands().postImage(userId: LocalStorage().getUserId(), image: image, caption: caption, price: price)
                try await ServerCommands().setTagsToImage(imageId: newImageId, tags: tags)
                DispatchQueue.main.async{
                    rectangleContents = [RectangleContent(userId: LocalStorage().getUserId(), imageId: newImageId, image: image, caption: caption, tags: Array(tags))]
                }
            }
            catch {
            }
        }
        
        self.showingDetailScreen = false
        self.inputImage = nil // Reset the inputImage to ensure it's ready for a new selection
        activeScreen = .home
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
        ZStack{
        Group {
            if isActive {
                if isUserLoggedIn {
                    NavigationView {
                        VStack(spacing: 0) {
                            switch activeScreen {
                            case .home:
                                VStack(spacing: 0) {
                                    topBarSection
                                    contentSection
                                    NavigationLink(destination: ImageDisplayView(posterId: -1, imageId: -1, image: imageToDisplay ?? UIImage(), caption: "string", tags: []), isActive: Binding<Bool>(
                                        get: { self.imageToDisplay != nil },
                                        set: { if !$0 { self.imageToDisplay = nil } }
                                    )) {
                                        EmptyView()
                                    }
                                }
                            case .loginSettings:
                                LoginSettingsView(isUserLoggedIn: $isUserLoggedIn)
                            }
                            
                            Spacer()
                            
                            bottomBarSection
                            NavigationLink(destination: DetailScreen(image: inputImage ?? UIImage(), caption: "", price: "", onConfirm: { image, caption, price, topTags, fashionTags in
                                // Here, combine topTags and fashionTags into a single Set<Tag> as they're both sets of Tag objects.
                                let combinedTags = topTags.union(fashionTags)
                                // Call handleImageConfirmation with all the parameters including the combined tags
                                self.handleImageConfirmation(image: image, caption: caption, tags: combinedTags, price: price)
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
                    } //end of navigation view
                } else {
                    
                    LoginView(isUserLoggedIn: $isUserLoggedIn, onLoginSuccess: handleLoginSuccess)
                }
            } else {
                SplashScreen()
            }
            
        }
//        .blur(radius: showingPopupOverlay ? 3 : 0) // Optional: blur the content when the popup is visible

            if showingPopupOverlay {
                // Dimmed background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Optionally allow tapping the dimmed background to dismiss the popup
                        showingPopupOverlay = false
                    }
                
                WelcomeView {
                    // This closure is called when the dismiss button in PopupView is tapped
                    showingPopupOverlay = false
                }
                .transition(.opacity) // Use a transition for the overlay appearance/disappearance
                .zIndex(1) // Ensure the overlay is above other content
            }

        }

        .onAppear {
            // Assuming the splash screen should show for a bit and then transition to the main content
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isActive = true
                }
                
                // Delay showing the popup slightly after the splash screen transition and ContentView is fully active.
                // Consider delaying this further if it interferes with other animations or transitions.
                if (isUserLoggedIn) {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.showingPopupOverlay = true // Ensure you're using the correct variable here
                    }
                }
            }
        }


        
    }
    
    
    
    
    
    func loadImage() {
//        guard let _ = inputImage else { return }
//        showingDetailScreen = true
        if inputImage != nil {
            showingDetailScreen = true
        } else {
            showingDetailScreen = false
        }
    }
    
    
    
    
    // MARK: - Top Bar Section
    var topBarSection: some View {
        VStack(spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 20) // Smaller corner radius for a smaller switch
                    .frame(width: 40, height: 20) // Smaller frame for a more compact appearance
                    .foregroundColor(showingImageDetailView ? .coralGreen : Color.gray) // Color change based on the switch state
                    .overlay(
                        // This will represent the circle of the switch
                        Circle()
                            .foregroundColor(Color.white)
                            .frame(width: 18, height: 18) // Smaller circle to fit the smaller switch
                            .offset(x: showingImageDetailView ? 9 : -9, y: 0) // Adjusted movement for the smaller size
                            .animation(.easeInOut(duration: 0.2), value: showingImageDetailView)
                    )
                    .onTapGesture {
                        // Toggle the switch state
                        showingImageDetailView.toggle()
                    }
                    .padding(.leading, 10) // Move the entire switch slightly to the right

                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(topTabs, id: \.self) { tab in
                        Button(action: {
                            selectedTopTab = topTabs.firstIndex(of: tab) ?? 0
                        }) {
                            Text(tab)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(selectedTopTab == topTabs.firstIndex(of: tab) ? Color.contrastColor(for: colorScheme) : .gray)
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
                        .stroke(Color.sameColor(forScheme: colorScheme), lineWidth: 0.5)
                )
                
                Spacer()
                
                 Button(action: {
                     showingSearchView = true
                 }) {
                     Image(systemName: "magnifyingglass")
                         .iconModifier()
                         .foregroundColor(Color.contrastColor(for: colorScheme))
                 }
                 .frame(width: 36, height: 36) // Set a smaller frame for the icon.
                 .padding(.trailing,  10) // Adjust padding here to move it leftward
                 .padding(.leading, -10)
            }
            
            // Scrolling Tab Section
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 20) {
//                    ForEach(["Minimalism", "Techwear", "Avant-Garde", "Preppy", "Customs", "Denim", "Athleisure", "Archive"], id: \.self) { category in
//                        Button(action: {
//                            // Perform an action when a category is tapped
//                            print("\(category) tapped")
//                            
//                        }) {
//                            Text(category)
//                                .font(.system(size: 16))
//                                .padding(.vertical, 6)
//                                .frame(width: 100)
//                                //.background(Color.gray.opacity(0.2))
//                                .cornerRadius(10)
//                        }
//                        .foregroundColor(Color.contrastColor(for: colorScheme)) // Set the text color for the button
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .frame(height: 40)
        }
        //.background(Color.gray.opacity(0.2))
        .background(
            NavigationLink(destination: SearchView(), isActive: $showingSearchView) {
                EmptyView()
            }
                .hidden()
        )
    }
    func loadImageBatch(){
        let startIndex = currentBatchIndex * batchSize
        if startIndex >= allImageIds.count {
            return
        }
        let endIndex = min(startIndex + batchSize, allImageIds.count)
        let batchIds = Array(allImageIds[startIndex..<endIndex])

        Task {
            var newContents: [RectangleContent] = []
            for imageId in batchIds {
                do {
                    let (userId, image, price, caption) = try await ServerCommands().retrieveImage(imageId: imageId)
                    let tags = try await ServerCommands().getTagsFromImage(imageId: imageId)
                    let newRectangleContent = RectangleContent(userId: userId, imageId: imageId, image: image, caption: caption, tags: tags)
                    newContents.append(newRectangleContent)
                } catch {
                    print("Error loading imageId \(imageId): \(error)")
                }
            }

            DispatchQueue.main.async {
                self.rectangleContents.append(contentsOf: newContents)
                self.currentBatchIndex += 1
                self.isLoading = false
            }
        }
    }
    func loadContent() {
        guard !isLoadingContent else { return }
        isLoadingContent = true
        if allImageIds.isEmpty {
            Task {
                do {
                    let fetchedIds = try await ServerCommands().generateUserFeed(userId: LocalStorage().getUserId(), limit: 200)
                    DispatchQueue.main.async {
                        self.allImageIds = fetchedIds
                        self.loadImageBatch()
                    }
                } catch {
                    // Handle errors
                }
            }
        } else {
            print("allImageIds not empty.")
            loadImageBatch()
        }
        DispatchQueue.main.async {
                self.isLoadingContent = false
            }
    }
    
    // MARK: - Content Section
    var contentSection: some View {
        Group {
            VStack{
                if self.isLoading {
                    ProgressView("Loading images...") // Make sure this is not inside another view unintentionally
                } else {
                    DynamicImageGridView(contents: rectangleContents, isCaptionShown: $showingImageDetailView, onImageTap: { content in
                        self.selectedContent = content
                        self.isNavigationActive = true // Trigger navigation
                    }, loadMoreImages: {
                        loadContent()
                    })
                    .background(
                        NavigationLink(
                            destination: ImageDisplayView(posterId: self.selectedContent?.userId ?? 0, imageId: self.selectedContent?.imageId ?? 0, image: self.selectedContent?.image ?? UIImage(), caption: self.selectedContent?.caption ?? "", tags: self.selectedContent?.tags ?? []),
                            isActive: $isNavigationActive
                        ) { EmptyView() }
                    )
                    
                }
            }
        }
        .refreshable {
            allImageIds.removeAll()
            currentBatchIndex = 0
            rectangleContents.removeAll()
            
            self.isLoading = true
            self.loadContent()
        }
        .onAppear {
            if self.isLoading{
                self.loadContent()
            }
        }
    }
    
    // MARK: - Bottom Bar Section
    var bottomBarSection: some View {
        HStack {
            Spacer() // Add a spacer at the beginning to push icons towards the center
            
            // Home icon
            Image(systemName: "house.fill").iconModifier()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    activeScreen = .home
                }
            
            // Bell icon for notifications
            ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .iconModifier()
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            showingNotificationView = true // Trigger navigation to NotificationView
                        }
                        .onAppear {
                            Task {
                                do {
                                    let count = try await ServerCommands().countUnseenBidMessages(userId: LocalStorage().getUserId())
                                    unseenCount = count
                                } catch {
                                }
                            }
                        }
                        .onChange(of: activeScreen) { _ in
                            Task {
                                do {
                                    let count = try await ServerCommands().countUnseenBidMessages(userId: LocalStorage().getUserId())
                                    unseenCount = count
                                } catch {
                                }
                            }
                        }
                        .onChange(of: showingImageDetail) { _ in
                            Task {
                                do {
                                    let count = try await ServerCommands().countUnseenBidMessages(userId: LocalStorage().getUserId())
                                    unseenCount = count
                                } catch {
                                }
                            }
                        }
                        .onChange(of: showingImagePicker) { _ in
                            Task {
                                do {
                                    let count = try await ServerCommands().countUnseenBidMessages(userId: LocalStorage().getUserId())
                                    unseenCount = count
                                } catch {
                                }
                            }
                        }

                    // Only show the notification count if unseenCount is greater than 0
                    if unseenCount > 0 {
                        Text("\(unseenCount)")
                            .font(.caption).bold()
                            .foregroundColor(.white)
                            .padding(8) // Adjust padding to fit the number
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: -5, y: -10) // Adjust position to correctly place the badge
                    }
                }
            
            // Other icons as placeholders
            Image(systemName: "plus.square.fill").iconModifier()
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    showingImagePicker = true
                }
            
            Image(systemName: "bookmark.fill").iconModifier()
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
            
            Spacer() // Add another spacer at the end to ensure symmetry
        }
        .padding(.horizontal)
        .frame(height: 50)
        //.background(Color.sameColor(forScheme: colorScheme))
        .padding(.bottom)
        .background(
            NavigationLink(destination: VisualStudioView(), isActive: $showingVisualStudioView) {
                EmptyView()
            }
            .hidden() // Hide the NavigationLink since it's used programmatically
        )
        .background(
            NavigationLink(destination: NotificationView(), isActive: $showingNotificationView) {
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
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors

    var body: some View {
        GeometryReader { geometry in
            Image((colorScheme == .dark) ? "QUTURE_DARK" : "QUTURE_LIGHT") // Replace "QUTURE" with your image name
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height * 0.8) // Make the logo smaller
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the cropped image
                .background(Color(.systemBackground)) // Set the background color to white
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
