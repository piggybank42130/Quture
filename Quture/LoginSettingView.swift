import SwiftUI

struct LoginSettingsView: View {
    @State private var rectangleContents = Array(repeating: RectangleContent(imageId: -1, image: nil, caption: "Loading..."), count: 20)
    
    private let rectangleWidth: CGFloat = (UIScreen.main.bounds.width - 32) / 2
    private let rectangleHeight: CGFloat = ((UIScreen.main.bounds.width - 32) / 2) * (4 / 3)
    @State private var isLoadingImages = true
    @State private var showingLogoutAlert = false // State to control the logout alert
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
                
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<rectangleContents.count, id: \.self) { index in
                            VStack {
                                if let uiImage = rectangleContents[index].image {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: rectangleWidth, height: rectangleHeight)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: rectangleWidth, height: rectangleHeight)
                                }
                                
                                Text(rectangleContents[index].caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 4)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: geometry.size.height * 0.55)
                
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
                            let (imageIds, images, captions) = try await ServerCommands().getImagesForUser(userId: 3)
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
            }
        }
    }
}

struct LoginSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSettingsView()
    }
}
