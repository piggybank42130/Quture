import SwiftUI
import Foundation

struct ImageDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showBidWindow = false // State variable for navigation
    @State private var isNewBidWindowVisible = false // New state for NewBidWindow visibility
    
    @State private var heartCount = 0
    @State private var isHeartTapped = false
    @State private var isSaveTapped = false
    @State private var username: String = ""
    
    let sellerPrice: Double = 1000.00 // Dummy seller price
    let customerPrice: Double = 950.00 // Dummy customer price
    
    @Environment(\.colorScheme) var colorScheme
    
    var posterId: Int
    var imageId: Int
    var image: UIImage
    var caption: String
    var tags: [Tag]
        
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 50) // Space from the top
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { gesture in
                                if gesture.translation.height < 0 {
                                    // Swipe up detected
                                    isNewBidWindowVisible = true
                                }
                            }
                    )
                
                Spacer().frame(height: 2) // Adjust the height as needed to create space between the icons and caption
                
                HStack {
                    // VStack for the user profile and its placeholder text
                    VStack(spacing: 2) {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        Text(username)
                            .font(.caption)
                    }
                    
                    Spacer() // Pushes content to the edges
                    
                    // Heart icon with its counter
                    VStack(spacing: 2) {
                        Button(action: {
                            Task{
                                do {
                                    try await ServerCommands().toggleLikeOnImage(userId: 3, imageId: imageId)
                                    isHeartTapped = !isHeartTapped
                                    heartCount += (isHeartTapped ? 1 : -1)
                                }
                                catch {
                                    print(error)
                                }
                            }
                        }) {
                            Image(systemName: isHeartTapped ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isHeartTapped ? .red : .primary)
                        }
                        Text("\(heartCount)")
                            .font(.caption)
                    }
                    
                    // Bookmark icon with placeholder text
                    VStack(spacing: 2) {
                        Button(action: {
                            // Bookmark button logic
                            print("Bookmark tapped")
                            Task {
                                do {
                                    try await ServerCommands().toggleSaveOnImage(userId: 3, imageId: self.imageId)
                                    DispatchQueue.main.async {
                                        isSaveTapped.toggle()
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        }) {
                            Image(systemName: isSaveTapped ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isSaveTapped ? Color.contrastColor(for: colorScheme) : .primary)
                        }
                        Text(isSaveTapped ? "Saved" : "Save")
                            .font(.caption)
                    }
                }
                .padding() // Adjust padding as necessary for the whole HStack
                
                Spacer().frame(height: 2) // Adjust the height as needed to create space between the icons and caption
                
                // Caption directly below the sidebar
                ScrollView(.vertical, showsIndicators: true) {
                    Text(caption)
                        .font(.body)
                        .foregroundColor(Color.contrastColor(for: colorScheme))
                        .padding()
                }
                // .frame(height: 50)
                .frame(width: UIScreen.main.bounds.width - 40, height: 60, alignment: .leading)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                Spacer().frame(height: 10) // Adjust the height as needed to create space between the icons and caption
                
                // Tags section moved under the caption
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(tags, id: \.tagId) { tag in
                            Text(tag.name.capitalized)
                                .padding(.all, 5)
                                .background(Color.gray)
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer() // Push everything up
            }
            
            if isNewBidWindowVisible {
                NewBidWindow(isVisible: $isNewBidWindowVisible, sellerId: posterId, imageId: imageId)
                    .transition(.scale)
            }
            
            VStack {
                topBar
                    .padding(.top, 30)
                    .zIndex(1)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    let username = try await ServerCommands().getUsername(userId: posterId)
                    let hasLiked = try await ServerCommands().hasUserLikedImage(userId: 1, imageId: self.imageId)
                    let likeCount = try await ServerCommands().getLikesOnImage(imageId: self.imageId)
                    let hasSaved = try await ServerCommands().hasUserSavedImage(userId: 1, imageId: self.imageId)
                    DispatchQueue.main.async {
                        self.username = username
                        self.isHeartTapped = hasLiked
                        self.isSaveTapped = hasSaved
                        self.heartCount = likeCount
                    }
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
    
    var topBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .bold()
            }
            .padding(.leading, 20) // Add padding to move the icon further from the left edge
            
            Spacer()
            
            Button(action: {
                // Action for "Follow" button
                print("Follow tapped")
            }) {
                Text("Follow")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color.contrastColor(for: colorScheme))
            }
            .padding(.trailing, 20) // Add padding to move the text further from the right edge
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
    
}



struct ImageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImageDisplayView(posterId: -1, imageId: -1, image: UIImage(named: "yourImageNameHere") ?? UIImage(), caption:"Loading...", tags: [])
        }
    }
}
