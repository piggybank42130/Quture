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
    
    
    
    
    let topTabs = ["Explore", "Curate", "Nearby"]
    let rectangleBaseHeight: CGFloat = 150
    let rectangleMultiplier = 2.6
    let shrinkRatio: CGFloat = 0.8
    
    
    func handleImageConfirmation(image: UIImage, caption: String, tags: Set<Tag>) {
        if let index = rectangleContents.firstIndex(where: { $0.image == nil }) {
            rectangleContents[index] = RectangleContent(image: image, caption: caption, tags: Array(tags))
            self.showingDetailScreen = false
            self.inputImage = nil // Reset the inputImage to ensure it's ready for a new selection
            postImage(image: image, caption: caption)
        }
    }
    
    func postImage(image: UIImage, caption: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let base64ImageString = imageData.base64EncodedString()
        
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "post_image", "params": ["image_data": base64ImageString, "user_id": 31353, "caption": caption]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let responseData):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                print("Image posted successfully: \(String(describing: responseData))")
                // Further processing of responseData if necessary
                
            case .failure(let error):
                print("Failed to post image: \(error.localizedDescription)")
                // Consider user-friendly error handling here
            }
        }
    }
    
    //###GETTERS###//
    
    func retrieveImage(imageId: Int, completion: @escaping (UIImage?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "method_name": "retrieve_image", // Ensure this matches a valid method in your Flask app
            "params": ["image_id": imageId]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = jsonResponse["result"] as? [String: Any],
                       let imageDataList = result["image_data"] as? [String: Any], let imageDataString = imageDataList["image_data"] as? String { // Assuming 'image_data' is the correct key
                        // Convert Base64 string to UIImage
                        if let imageData = Data(base64Encoded: imageDataString),
                           let image = UIImage(data: imageData) {
                            completion(image, nil) // Successfully converted and returning the image
                        } else {
                            // Failed to convert Base64 string to UIImage
                            completion(nil, NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."]))
                        }
                    } else {
                        // The JSON is not in the expected format
                        print("Error: Unexpected JSON format.")
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    print("Failed to load: \(error.localizedDescription)")
                    completion(nil, error)
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func getImagesForUser(userId: Int, completion: @escaping ([UIImage]?, Error?) -> Void) {
        getUserImages(userId: userId) { (imageIds, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let imageIds = imageIds else {
                completion(nil, NSError(domain: "ImageFetcherError", code: 300, userInfo: [NSLocalizedDescriptionKey: "No image IDs found."]))
                return
            }

            var images = [UIImage]()
            let group = DispatchGroup()

            for imageId in imageIds {
                group.enter()
                self.retrieveImage(imageId: imageId) { image, error in
                    defer { group.leave() }
                    print(image)
                    if let image = image {
                        images.append(image)
                    } else {
                        print("Error or no image for ID \(imageId). Error: \(error?.localizedDescription ?? "Unknown error")")
                        // Adjusted error handling: No longer using `continue`
                    }
                }
            }

            group.notify(queue: .main) {
                completion(images, nil)
            }
        }
    }

    
    func getUserImages(userId: Int, completion: @escaping ([Int]?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "method_name": "get_user_images", // Ensure this matches a valid method in your Flask app
            "params": ["user_id": userId]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let imageIds = result["image_ids"] as? [Int] {
                        
                        print("Successfully retrieved image IDs: \(imageIds)")
                        completion(imageIds, nil)
                    } else {
                        // The JSON is not in the expected format
                        print("Error: Unexpected JSON format.")
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    print("Failed to load: \(error.localizedDescription)")
                    completion(nil, error)
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(nil, error)
            }
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
        NavigationView {
            VStack(spacing: 0) {
                switch activeScreen {
                case .home:
                    VStack(spacing: 0) {
                        topBarSection
                        contentSection
                        NavigationLink(destination: ImageDisplayView(image: imageToDisplay ?? UIImage()), isActive: Binding<Bool>(
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
                
//                NavigationLink(destination: DetailScreen(image: inputImage ?? UIImage(), caption: "", price: "", onConfirm: { image, caption, price, topTags, fashionTags in
//                    // Adjust this part according to your app's logic to handle image, caption, price, and tags
//                    self.handleImageConfirmation(image: image, caption: caption, price: price, tags: topTags.union(fashionTags))
//                }), isActive: $showingDetailScreen) {
//                    EmptyView()
//                }


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
                            destination: ImageDisplayView(image: rectangleContents[index].image ?? UIImage()),
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
            getImagesForUser(userId: 3) { images, error in
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
