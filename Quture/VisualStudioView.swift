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
    
    @State private var rectangles: [RectangleContent] = Array(repeating: RectangleContent(imageId: -1, image: UIImage(systemName: "photo"), caption: ""), count: 20)
    @State private var selectedTab: SelectedTab = .none
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // Adjust the count to control the number of columns
    
    
    
    
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
                                .foregroundColor(.white)
                            Image(systemName: isTopsTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 20) // Adjust this value to move the button lower
                
                
                if isTopsTabExpanded {
                    // Tops: Suit
                    Text("Suit")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    
                    // Tops: Button Up
                    Text("Button Up")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(10..<20) { index in // The next set of items
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Hoodie
                    Text("Hoodie")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Sweater
                    Text("Sweater")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: T-shirt
                    Text("T-shirt")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Athletic
                    Text("Athletic")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Crewneck
                    Text("Crewneck")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Jacket
                    Text("Jacket")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Workwear
                    Text("Workwear")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Casual
                    Text("Casual")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    //Tops: Vintage
                    Text("Vintage")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //MARK: BOTTOMS
                HStack{
                    Button(action: {
                        isBottomsTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Bottoms")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Image(systemName: isBottomsTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 110)
                
                //Bottoms: Dress pants
                if isBottomsTabExpanded {
                    Text("Dress pants")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Shorts
                if isBottomsTabExpanded {
                    Text("Shorts")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Botttoms: Jeans
                if isBottomsTabExpanded {
                    Text("Jeans")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Parachute
                if isBottomsTabExpanded {
                    Text("Parachute")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Athletic
                if isBottomsTabExpanded {
                    Text("Athletic")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Cargo
                if isBottomsTabExpanded {
                    Text("Cargo")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Fitted
                if isBottomsTabExpanded {
                    Text("Fitted")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Bottoms: Vintage
                if isBottomsTabExpanded {
                    Text("Vintage")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //MARK: Shoes
                HStack{
                    Button(action: {
                        isShoesTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Shoes")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Image(systemName: isShoesTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 140)
                
                //Shoes: Boots
                if isShoesTabExpanded {
                    Text("Boots")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Shoes: Loafers
                if isShoesTabExpanded {
                    Text("Loafers")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Shoes: Sneakers
                if isShoesTabExpanded {
                    Text("Sneakers")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Shoes: Dress shoes
                if isShoesTabExpanded {
                    Text("Dress shoes")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Shoes: Sandals
                if isShoesTabExpanded {
                    Text("Sandals")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Shoes: Customs
                if isShoesTabExpanded {
                    Text("Customs")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //MARK: Accessories
                HStack{
                    Button(action: {
                        isAccessoriesTabExpanded.toggle() // Toggle the expansion state of the "Tops" tab
                    }) {
                        HStack {
                            Text("Accessories")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Image(systemName: isAccessoriesTabExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)) // Increase padding to make button bigger
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.leading, -15)
                    Spacer()
                }
                .padding(.top, 150)
                
                //Accessories: Necklaces
                if isAccessoriesTabExpanded {
                    Text("Necklaces")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Accessories: Ear ring
                if isAccessoriesTabExpanded {
                    Text("Ear ring")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Accessories: Ring
                if isAccessoriesTabExpanded {
                    Text("Ring")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                //Accessories: Glasses
                if isAccessoriesTabExpanded {
                    Text("Glasses")
                        .font(.headline)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LayoutConfig.spacing) {
                            ForEach(0..<10) { index in // Assuming you have at least 10 items for demonstration
                                RectangleView(content: rectangles[index])
                                    .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
                            }
                        }
                    }
                    .padding(.bottom)
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
        .onAppear{
            Task{
                do {
                    let (imageIds) = try await ServerCommands().getUserSavedImageIdsByTag(userId: 3, tag: TagManager().getTagById(tagId: 1)!)
                    for (index, imageId) in imageIds.enumerated() where index < self.rectangles.count {
                        let (image, caption) = try await ServerCommands().retrieveImage(imageId: imageId)
                        let tags = try await ServerCommands().getTagsFromImage(imageId: imageId)
                        DispatchQueue.main.async {
                            self.rectangles[index].imageId = imageId
                            self.rectangles[index].tags = tags
                            self.rectangles[index].image = image
                            self.rectangles[index].caption = caption
                            
                            print("You've saved")
                            print("imageIds: \(imageId)")
                            print("Tags: \(tags)")
                        }
                    }
                    print("GOOBERINO")
                    
                    //self.isLoading = false
                    
                } catch {
                    print(error)
                    //self.isLoading = false
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
                    .foregroundColor(.white)
                    .padding(.leading, 20) // Add padding to move the icon further from the left edge
            }
            
            Spacer()
            
            Text("Save") // Center-aligned text
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
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
        .background(Color.black) // Set your desired background color here
    }
}

struct RectangleView: View {
    let content: RectangleContent
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray) // Display a gray rectangle
                .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight) // Use predefined sizes
            Text(content.caption)
                .foregroundColor(.white) // Set text color to ensure it's visible on gray background
        }
        .background(Color.gray) // Sets the background of each rectangle to gray
        .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
    }
}



// This part should be outside any struct or class declaration
extension CGFloat {
    var abs: CGFloat {
        return Swift.abs(self)
    }
}

struct VisualStudioView_Previews: PreviewProvider {
    static var previews: some View {
        VisualStudioView()
    }
}
