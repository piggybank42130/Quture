import SwiftUI

enum SelectedTab {
    case none, tops, bottoms, shoes, accessories
}


struct VisualStudioView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isTopsTabExpanded: Bool = false
    @State private var isBottomsTabExpanded: Bool = false
    @State private var isShoesTabExpanded: Bool = false
    @State private var isAccessoriesTabExpanded: Bool = false
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    @State private var rectangles: [Int: [RectangleContent]] = Dictionary(uniqueKeysWithValues: TagManager.shared.tags.filter { $0.tagId != -1 }.map { ($0.tagId, [RectangleContent]()) })
    
    private var topCategoryTagIds: [Int] {
        TagManager.shared.getTagIdsByCategory(category: .top)
    }
    private var bottomCategoryTagIds: [Int] {
        TagManager.shared.getTagIdsByCategory(category: .bottom)
    }
    private var shoeCategoryTagIds: [Int] {
        TagManager.shared.getTagIdsByCategory(category: .shoe)
    }
    private var accessoriesCategoryTagIds: [Int] {
        TagManager.shared.getTagIdsByCategory(category: .accessories)
    }
    
    
    @State private var selectedTab: SelectedTab = .none
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // Adjust the count to control the number of columns
    
    func resetRectangles() {
        self.rectangles = Dictionary(uniqueKeysWithValues: TagManager.shared.tags.filter { $0.tagId != -1 }.map { ($0.tagId, [RectangleContent]()) })
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                topBar // Custom top bar implementation
                // Collapsible "Tops" Tab
                
                //MARK: - Tops
                HStack{
                    Button(action: {
                        isTopsTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Tops")
                                .font(.system(size: 24))
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                            Image(systemName: isTopsTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.sameColor(forScheme: colorScheme))
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 20) // Adjust this value to move the button lower
                
                
                if isTopsTabExpanded {
                    
                    
                    ForEach(topCategoryTagIds, id: \.self) { tagId in
                        Group { // Using Group to explicitly wrap our views
                            if let tag = TagManager.shared.getTagById(tagId: tagId) {
                                VStack {
                                    Text(tag.name)
                                        .font(.headline)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: LayoutConfig.spacing) {
                                            ForEach(0..<(rectangles[tagId]?.count ?? 0), id: \.self) { index in
                                                if let rectangleContent = rectangles[tagId]?[index] {
                                                    // Simplify by handling image processing inside RectangleView or beforehand
                                                    RectangleView(content: rectangleContent,onNavigationTriggered: { self.resetRectangles() }
                                                    )
                                                } else {
                                                    // Fallback view
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                            } else {
                                // Fallback for missing tag
                                EmptyView()
                            }
                        }
                    }

                }

                
                //MARK: BOTTOMS
                HStack{
                    Button(action: {
                        isBottomsTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Bottoms")
                                .font(.system(size: 24))
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                            Image(systemName: isBottomsTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.sameColor(forScheme: colorScheme))
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 10)
                
                //Bottoms: Dress pants
                if isBottomsTabExpanded {
                    ForEach(bottomCategoryTagIds, id: \.self) { tagId in
                        Group { // Using Group to explicitly wrap our views
                            if let tag = TagManager.shared.getTagById(tagId: tagId) {
                                VStack {
                                    Text(tag.name)
                                        .font(.headline)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: LayoutConfig.spacing) {
                                            ForEach(0..<(rectangles[tagId]?.count ?? 0), id: \.self) { index in
                                                if let rectangleContent = rectangles[tagId]?[index] {
                                                    // Simplify by handling image processing inside RectangleView or beforehand
                                                    RectangleView(content: rectangleContent,onNavigationTriggered: { self.resetRectangles() }
                                                    )
                                                } else {
                                                    // Fallback view
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                            } else {
                                // Fallback for missing tag
                                EmptyView()
                            }
                        }
                    }
                }
                
                //MARK: Shoes
                HStack{
                    Button(action: {
                        isShoesTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Shoes")
                                .font(.system(size: 24))
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                            Image(systemName: isShoesTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.sameColor(forScheme: colorScheme))
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 10)
                
                //Shoes: Boots
                if isShoesTabExpanded {
                    ForEach(shoeCategoryTagIds, id: \.self) { tagId in
                        Group { // Using Group to explicitly wrap our views
                            if let tag = TagManager.shared.getTagById(tagId: tagId) {
                                VStack {
                                    Text(tag.name)
                                        .font(.headline)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: LayoutConfig.spacing) {
                                            ForEach(0..<(rectangles[tagId]?.count ?? 0), id: \.self) { index in
                                                if let rectangleContent = rectangles[tagId]?[index] {
                                                    // Simplify by handling image processing inside RectangleView or beforehand
                                                    RectangleView(content: rectangleContent,onNavigationTriggered: { self.resetRectangles() }
                                                    )
                                                } else {
                                                    // Fallback view
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                            } else {
                                // Fallback for missing tag
                                EmptyView()
                            }
                        }
                    }
                }
                
                //MARK: Accessories
                HStack{
                    Button(action: {
                        isAccessoriesTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Accessories")
                                .font(.system(size: 24))
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                            Image(systemName: isAccessoriesTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.sameColor(forScheme: colorScheme))
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 10)
                
                //Accessories: Necklaces
                if isAccessoriesTabExpanded {
                    ForEach(accessoriesCategoryTagIds, id: \.self) { tagId in
                        Group { // Using Group to explicitly wrap our views
                            if let tag = TagManager.shared.getTagById(tagId: tagId) {
                                VStack {
                                    Text(tag.name)
                                        .font(.headline)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: LayoutConfig.spacing) {
                                            ForEach(0..<(rectangles[tagId]?.count ?? 0), id: \.self) { index in
                                                if let rectangleContent = rectangles[tagId]?[index] {
                                                    // Simplify by handling image processing inside RectangleView or beforehand
                                                    RectangleView(content: rectangleContent,onNavigationTriggered: {        self.resetRectangles()
                                                        
                                                        }
                                                    )
                                                } else {
                                                    // Fallback view
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                            } else {
                                // Fallback for missing tag
                                EmptyView()
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .gesture(
                DragGesture().onEnded { value in
                    // Dismiss the view if a swipe gesture is detected
                    if value.translation.width > 100 && abs(value.translation.height) < abs(value.translation.width) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .onAppear {
            
                Task {
                    let tagIds = TagManager.shared.tags.filter { $0.tagId != -1 }.map { $0.tagId }
                    for tagId in tagIds {
                        do {
                            // Assuming getUserSavedImageIdsByTag now takes a tag name instead of a Tag object for simplicity
                            // Ensure you have a suitable method to handle fetching by tag name or adapt this code to work with your current setup
                            guard let tag = TagManager.shared.getTagById(tagId: tagId)
                            else {
                                continue
                            }
                            let imageIds = try await ServerCommands().getUserSavedImageIdsByTag                        (userId: LocalStorage().getUserId(), tag: tag)
                            for imageId in imageIds {
                                let (userId, image, price, caption) = try await ServerCommands().retrieveImage(imageId: imageId)
                                let tags = try await ServerCommands().getTagsFromImage(imageId: imageId)
                                DispatchQueue.main.async {
                                    // Initialize tag key with an empty array if it doesn't already exist
                                    if self.rectangles[tagId] == nil {
                                        self.rectangles[tagId] = []
                                    }

                                    // Create a new RectangleContent object
                                    let newRectangleContent = RectangleContent(userId: userId, imageId: imageId, image: image, caption: caption, tags: tags)

                                    // Append the new object to the array under the tag name
                                    self.rectangles[tagId]!.append(newRectangleContent)
                                }
                            }
                        } catch {
                        }
                    }
                }
        }
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss() // Action to dismiss the current view
            }) {
                Image(systemName: "arrowtriangle.left.fill") // Triangle-shaped back button
                    .font(.system(size: 24))
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .padding(.leading, 20) // Add padding to move the icon further from the left edge
            }
            
            Spacer()
            
            Text("Save") // Center-aligned text
                .font(.title)
                .bold()
                .foregroundColor(Color.contrastColor(for: colorScheme))
            
            Spacer()
            
            // This is a placeholder to balance the 'Save' text in the center.
            // It's invisible but takes the same space as the back button for symmetry.
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .opacity(0) // Make it invisible
        }
        .padding(.vertical, 10)
        .background(Color.sameColor(forScheme: colorScheme)) // Set your desired background color here
    }
}

struct RectangleView: View {
    let content: RectangleContent
    
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors

    @State private var isNavigationActive = false
    var onNavigationTriggered: () -> Void

    var body: some View {
        VStack {
            if let uiImage = content.image {
                // Calculate the new width based on the image's original aspect ratio.
                let originalAspectRatio = uiImage.size.width / uiImage.size.height
                let scaledWidth = LayoutConfig.rectangleHeight * originalAspectRatio
                
                Image(uiImage: uiImage)
                    .resizable()
                    // Scale the image to the specific height, keeping its aspect ratio
                    .frame(width: scaledWidth, height: LayoutConfig.rectangleHeight)
                    .clipped() // Clip the image to fit within the frame dimensions
                    .onTapGesture {
                        self.isNavigationActive = true
                    }
                    .background(
                        NavigationLink(
                            destination: ImageDisplayView(posterId: content.userId ?? 0, imageId: content.imageId ?? 0, image: content.image ?? UIImage(), caption: content.caption ?? "", tags: content.tags ?? [], onReturn: {
                                    self.onNavigationTriggered()
                                }),
                            isActive: $isNavigationActive
                        ) { EmptyView() }
                    )
                
                Text(content.caption)
                    .font(.caption)
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: scaledWidth, alignment: .leading)
            } else {
                // Display a gray rectangle if there's no image
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: LayoutConfig.rectangleHeight)
            }
            // Caption for the image

        }
        // Background color for the entire VStack
        //.background(Color.gray) // Your existing background
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)

    }
}
