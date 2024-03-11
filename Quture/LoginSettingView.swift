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
    
    
    @State private var isLoading = true
    

    @Environment(\.colorScheme) var colorScheme // light and dark mode colors

    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Circle()
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    )
                    .padding()
                    .frame(height: geometry.size.height * 0.45)
                
                
                Text("User Profile")
                    .font(.title)
                    .padding()
                
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Log Out"),
                        message: Text("Are you sure you want to log out?"),
                        primaryButton: .default(Text("Yes"), action: {
                            // Handle logout action
                            print("Logged out")
                        }),
                        secondaryButton: .cancel()
                    )
                }
                .onAppear {
                    Task {
                        do {
                            isLoadingImages = true
                            let (imageIds, images, captions) = try await ServerCommands().getImagesForUser(userId: 1)
                            DispatchQueue.main.async { // Ensure UI operations are on the main thread
                            
                                for (index, imageId) in imageIds.enumerated() where index < self.rectangleContents.count {
                                    self.rectangleContents[index].imageId = imageId
                                }
                                for (index, image) in images.enumerated() where index < self.rectangleContents.count {
                                    self.rectangleContents[index].image = image
                                }
                                for (index, caption) in captions.enumerated() where index < self.rectangleContents.count {
                                    self.rectangleContents[index].caption = caption
                                }
                                isLoadingImages = false
                            }
                        }
                        catch {
                            print(error)
                        }
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    // Handle gear icon action
                    print("Gear icon tapped")
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
                .onAppear {
                    Task {
                        do {
                            // Directly assign the result without using parentheses
                            let imageIds = try await ServerCommands().getUserImageIds(userId: 1).prefix(rectangleContents.count)
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
    }
}
