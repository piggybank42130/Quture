import SwiftUI

struct LoginSettingsView: View {
    @State private var rectangleContents = Array(repeating: RectangleContent(userId: -1, imageId: -1, image: nil, caption: "Loading..."), count: 20)
    @State private var selectedContent: RectangleContent?
    
    private let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2
    private let rectangleHeight: CGFloat = ((UIScreen.main.bounds.width - 32) / 2) * (4 / 3)
    @State private var isLoadingImages = true
    @State private var showingLogoutAlert = false // State to control the logout alert
    @State private var isNavigationActive = false
    @State private var showingImageDetailView = true
    @State private var profileImage: UIImage? = nil
    @State private var username: String = ""
    @State private var followerCount: Int = 0

    @State private var isLoading = true
    
    @Binding var isUserLoggedIn: Bool // Now it's a binding
    
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    func loadContent() {
        Task {
            do {
                
                let userId = LocalStorage().getUserId()
                // Directly assign the result without using parentheses
                let imageIds = try await ServerCommands().getUserImageIds(userId: userId).prefix(rectangleContents.count)
                let userName = try await ServerCommands().getUsername(userId: userId)
                username = userName
                self.rectangleContents = []
                for (index, imageId) in imageIds.enumerated() where index < imageIds.count {
                    let (userId, image, price, caption) = try await ServerCommands().retrieveImage(imageId: imageId)
                    let tags = try await ServerCommands().getTagsFromImage(imageId: imageId)
                    DispatchQueue.main.async {
                        let newRectangleContent = RectangleContent(userId: userId, imageId: imageId, image: image, caption: caption, tags: tags)
                        rectangleContents.append(newRectangleContent)
                    }
                }
                
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    
                    
                    Circle()
                        .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
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
                                }
                            }
                        )
                        .clipShape(Circle()) //Clip image to circle
                        .frame(height: geometry.size.height * 0.2)
                    
                    
                    Text(username == "" ? "Your Profile" : "\(username)'s Profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                        .alert(isPresented: $showingLogoutAlert) {
                            Alert(
                                title: Text("Log Out"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .default(Text("Yes"), action: {
                                    LocalStorage().logout()
                                    DispatchQueue.main.async {
                                        self.isUserLoggedIn = false
                                    }
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                    Text("Followers: \(followerCount)")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                        .navigationBarItems(trailing: Button(action: {
                            // Handle gear icon action
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundColor(Color.contrastColor(for: colorScheme))
                                .onTapGesture {
                                    showingLogoutAlert = true
                                }
                        })
                    
                    Group {
                        if isLoading {
                            ProgressView("Loading Images...")
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
                    .refreshable {
                        // Your loading logic here
                        self.isLoading = true
                        self.loadContent()
                    }
                    .onAppear {
                        if self.isLoading{
                            self.loadContent()
                        }
                    }
                    Spacer()
                    
                }
            }
        }
    }
}
