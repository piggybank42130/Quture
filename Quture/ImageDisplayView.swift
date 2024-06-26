import SwiftUI
import Foundation

extension Binding {
    /// Executes a closure when the binding's value changes.
    /// - Parameter handler: The closure to execute when the value changes.
    /// - Returns: A new binding with the change handler attached.
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}


struct ImageDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showBidWindow = false // State variable for navigation
    @State private var isNewBidWindowVisible = false // New state for NewBidWindow visibility
    
    @State private var heartCount = 0
    @State private var isHeartTapped = false
    @State private var isSaveTapped = false
    @State private var username: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var isFollowing = false
    @State private var hasPlacedBid = true
    
    @State private var showAlert = false
    @State private var alertMessage = "A bid has already been placed." //alert
    @State private var showSuccessAlert = false

    @State private var selectedTopBottomShoesAccessoriesTag: Tag? = nil
    @State private var selectedFashionTag: Tag? = nil
    @State private var showCaptionAndTagsAlert = false


    let sellerPrice: Double = 1000.00 // Dummy seller price
    
    
    @Environment(\.colorScheme) var colorScheme
    
    var posterId: Int
    var imageId: Int
    var image: UIImage
    var caption: String
    var tags: [Tag]
    var onReturn: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 75) // Space from the top
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { gesture in
                                Task {
                                    do {
                                        let userId = LocalStorage().getUserId()
                                        hasPlacedBid = try await ServerCommands().doesBidExist(buyerId: userId, imageId: imageId)
                                        
                                        // Perform the check after the task has completed
                                        if gesture.translation.height < 0 {
                                            if hasPlacedBid {
                                                // Main thread operation, use DispatchQueue if needed
                                                DispatchQueue.main.async {
                                                    // A bid has been placed, show an alert
                                                    self.showAlert = true
                                                }
                                            } else {
                                                // Main thread operation, use DispatchQueue if needed
                                                DispatchQueue.main.async {
                                                    // No bid has been placed, show the bid window
                                                    isNewBidWindowVisible = true
                                                }
                                            }
                                        }
                                    } catch {
                                    }
                                }

                            }
                    )

                Spacer().frame(height: 2) // Adjust the height as needed to create space between the icons and caption
                
                HStack {
                    // VStack for the user profile and its placeholder text
                    VStack(spacing: 2) {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                            .overlay(
                                Group {
                                    if let profileUIImage = profileImage {
                                        Image(uiImage: profileUIImage) // Use the retrieved profileImage
                                            .resizable()
                                            .aspectRatio(contentMode: .fill) // Fill the circle with the image
                                    } else {
                                        Image(systemName: "person.crop.circle.fill") // Default placeholder
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding()
                                    }
                                }
                            )
                            .clipShape(Circle()) //Clip image to circle

                        Text(username)
                            .font(.caption)
                    }
                    
                    Spacer() // Pushes content to the edges
                    
                    // Heart icon with its counter
                    VStack(spacing: 2) {
                        Button(action: {
                            Task{
                                do {
                                    try await ServerCommands().toggleLikeOnImage(userId: LocalStorage().getUserId(), imageId: imageId)
                                    isHeartTapped = !isHeartTapped
                                    heartCount += (isHeartTapped ? 1 : -1)
                                }
                                catch {
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
                            Task {
                                do {
                                    try await ServerCommands().toggleSaveOnImage(userId: LocalStorage().getUserId(), imageId: self.imageId)
                                    DispatchQueue.main.async {
                                        isSaveTapped.toggle()
                                    }
                                } catch {
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
                NewBidWindow(isVisible: $isNewBidWindowVisible, sellerId: posterId, imageId: imageId, onBidPlaced: {
                    showSuccessAlert = true
                })
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

                    let userId = LocalStorage().getUserId()

                    let username = try await ServerCommands().getUsername(userId: posterId)
                    let profileImage = try await ServerCommands().retrieveProfilePicture(userId: posterId)
                    let hasLiked = try await ServerCommands().hasUserLikedImage(userId: userId, imageId: self.imageId)
                    let likeCount = try await ServerCommands().getLikesOnImage(imageId: self.imageId)
                    let hasSaved = try await ServerCommands().hasUserSavedImage(userId: userId, imageId: self.imageId)
                    hasPlacedBid = try await ServerCommands().doesBidExist(buyerId: userId, imageId: imageId)

                    let doesUserFollow = try await ServerCommands().checkIfUserFollows(followerId: userId, followedId: posterId)
                    DispatchQueue.main.async {
                        self.username = username
                        self.profileImage = profileImage
                        self.isHeartTapped = hasLiked
                        self.isSaveTapped = hasSaved
                        self.heartCount = likeCount
                        self.isFollowing = UserDefaults.standard.bool(forKey: "isFollowing_\(posterId)")
                    }
                } catch {
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Bid Placed"),
                message: Text(hasPlacedBid ? alertMessage : "You have successfully placed a bid."),
                dismissButton: .default(Text("OK"))
            )
        }


    }
    
    
    var topBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                self.onReturn?()
                
            }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .bold()
                
            }
            .padding(.leading, 20) // Add padding to move the icon further from the left edge
            
            Spacer()
            if posterId != LocalStorage().getUserId(){

            Button(action: {
                // Action for "Follow" button
                Task{
                    do{
                        let userId = LocalStorage().getUserId()
                        try await ServerCommands().toggleFollow(followerId: userId, followedId: posterId)
                        DispatchQueue.main.async {
                            self.isFollowing.toggle()
                            UserDefaults.standard.set(self.isFollowing, forKey: "isFollowing_\(posterId)")
                        }
                        
                    }
                    catch{
                    }
                }
            }) {
                Text(isFollowing ? "Unfollow" : "Follow") // Change button text based on follow state
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color.contrastColor(for: colorScheme))
            }
            .padding(.trailing, 20) // Add padding to move the text further from the right edge
        }
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
