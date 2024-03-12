import SwiftUI

struct SearchedView: View {
    @Environment(\.presentationMode) var presentationMode
    var searchText: String

    let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2 // Assuming 32 is the total horizontal padding
    let rectangleHeight: CGFloat = (UIScreen.main.bounds.width - 32) / 2 * (4 / 3) // For a 3:4 aspect ratio
    @State private var showingImageDetailView = false
    @State private var rectangleContents = Array(repeating: RectangleContent(userId: -1,  imageId: -1, image: nil, caption: "Loading..."), count: 100) // Example for 100 rectangles
    @State private var isNavigationActive = false
    @State private var isLoading = true
    @State private var selectedContent: RectangleContent?
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    

    var body: some View {
        VStack {
            // Top bar
            searchResultTopBar

            // Infinite list of rectangles
            searchResultImagesDynamic
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
    
    private var searchResultTopBar: some View{
        HStack {
            Button(action: {
                // Dismiss SearchedView to go back to SearchView
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.title)
                    .foregroundColor(Color.contrastColor(for: colorScheme))
            }

            Spacer()

            Text("Search results for: \(searchText)")
                .font(.title)
                .bold()

            Spacer()
        }
        .padding()
        .background(Color.sameColor(forScheme: colorScheme))
        .foregroundColor(.contrastColor(for: colorScheme))
    }
    
    private var searchResultImages: some View{
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
                            .foregroundColor(Color.contrastColor(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var searchResultImagesDynamic: some View{
        Group {
            VStack{
                if isLoading {
                    ProgressView("Loading images...") // Make sure this is not inside another view unintentionally
                } else {
                    DynamicImageGridView(contents: rectangleContents, isCaptionShown: $showingImageDetailView, onImageTap: { content in
                        self.selectedContent = content
                        self.isNavigationActive = true // Trigger navigation
                        
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
        
        .onAppear {
            Task {
                isLoading = true
                guard let tagId = TagManager.shared.getTagByName(byName: searchText)?.tagId else {
                    print("Tag ID not found for searchText: \(searchText)")
                    isLoading = false // Update isLoading when done
                    return
                }
                        

                do {
                    // Directly assign the result without using parentheses
                    let imageIds = try await ServerCommands().getImagesForTag(tagId: tagId)
                                
                    self.rectangleContents = []
                    for (index, imageId) in imageIds.enumerated() where index < imageIds.count {
                        let (userId, image, caption) = try await ServerCommands().retrieveImage(imageId: imageId)
                        let tags = try await ServerCommands().getTagsFromImage(imageId: imageId)
                        DispatchQueue.main.async {
                            let newRectangleContent = RectangleContent(userId: userId, imageId: imageId, image: image, caption: caption, tags: tags)
                            rectangleContents.append(newRectangleContent)
                        }
                    }
                    
                    self.isLoading = false
                
                } catch {
                    print(error)
                    self.isLoading = false
                }
            }
        }
        
    }
}


struct SearchedView_Previews: PreviewProvider {
    static var previews: some View {
        SearchedView(searchText: "Example")
    }
}
