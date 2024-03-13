import SwiftUI

struct BidNotification: View, Identifiable {
    let id = UUID()
    
    @State var bidId: Int
    @State var bidBuyerId: Int
    @State var bidSellerId: Int
    @State var bidImageId: Int
    @State var bidImageCaption: String

    @State var bidTitle: String
    @State var bidText: String
    @State var bidPrice: Double
    
    @State var isNew: Bool
    @State var isSellerResponse: Bool
    @State var isBidSuccessful: Bool
    @State var onCheckmarkPressed: () -> Void = {}
    
    @State private var isNavigationActive: Bool = false

    
    var onAccept: () -> Void = {}
    var onReject: () -> Void = {}
    var showImageDisplayView: ImageDisplayView?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if isSellerResponse {
                    buyerView //show the buyer notif if it's a seller response
                } else {
                    sellerView //show seller notif if it's a buyer response
                }
            }
            
        }
    }
    
    private var buyerView: some View{
        ZStack(alignment: .topTrailing) {
            VStack {
                // Red circle indicator for new notifications
                
                let statusMessage = isBidSuccessful ? "Your bid of $\(String(format: "%.2f", bidPrice)) has been accepted." : "Your bid of $\(String(format: "%.2f", bidPrice)) has been rejected."
                Text(statusMessage)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) { // Added spacing between buttons
                    Button(action: onCheckmarkPressed) {
                        Rectangle()
                            .foregroundColor(.green)
                            .frame(height: 50)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal, 2) // Minor horizontal padding for button
                    .padding(.vertical, 10)
                    
                }
                .frame(maxWidth: .infinity) // Makes HStack cover the full width
                .padding(.horizontal) // Pads the horizontal sides of the HStack to align with the text
                
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(20)
            .padding(.vertical, 2)
            
            
        }
        .background(
            NavigationLink(
                destination: showImageDisplayView,
                isActive: $isNavigationActive
            ) { EmptyView() }
        )
    }
    
    private var sellerView: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                 Text(bidTitle)
                     .font(.headline)
                     .padding()
                     .frame(maxWidth: .infinity, alignment: .center)
                 
                 Text(bidText)
                     .font(.headline)
                     .padding()
                     .frame(maxWidth: .infinity, alignment: .center)
                 
                 Text("I'm offering $\(String(format: "%.2f", bidPrice))")
                     .font(.headline)
                     .padding()
                     .frame(maxWidth: .infinity, alignment: .center)
                 
                 HStack(spacing: 10) {
                     Button(action: onAccept) {
                         Rectangle()
                             .foregroundColor(.green)
                             .frame(height: 50)
                             .cornerRadius(10)
                             .overlay(
                                 Image(systemName: "checkmark")
                                     .foregroundColor(.white)
                             )
                     }
                     .padding(.horizontal, 2)
                     .padding(.vertical, 10)
                     
                     Button(action: onReject) {
                         Rectangle()
                             .foregroundColor(.red)
                             .frame(height: 50)
                             .cornerRadius(10)
                             .overlay(
                                 Image(systemName: "xmark")
                                     .foregroundColor(.white)
                             )
                     }
                     .padding(.horizontal, 2)
                     .padding(.vertical, 10)
                 }
                 .frame(maxWidth: .infinity)
                 .padding(.horizontal)
                
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: 50) // Removed the fixed width
                    .cornerRadius(10) // Rounded corners
                    .overlay(
                        VStack {
                            Text("See Image")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)

                            Text("Caption: \(bidImageCaption)")
                                .foregroundColor(.black)
                                .font(.system(size: 10))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding()
                        .frame(height: 90)

                    )
            
                .frame(maxWidth: .infinity) // Makes HStack cover the full width
                .padding(.horizontal) // Pads the horizontal sides of the HStack to align with the text
                .onTapGesture {
                    //DAIFISDHFASHDFIADSIFHASIDFHDAHISFDISFAISDHFAISDHFHASDIF
                    isNavigationActive = true
                }

            }
            
            // Red circle indicator for new notifications
            if isNew {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.red)
                    .frame(width: 40, height: 25) // Adjust size to fit the text
                    .overlay(
                        Text("NEW")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                    .offset(x: -0, y: 0) // Adjusts the position relative to the top right corner
            }
            else {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray)
                    .frame(width: 100, height: 25) // Adjust size to fit the text
                    .overlay(
                        Text("MARK AS NEW")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                    .offset(x: -0, y: 0) // Adjusts the position relative to the top right corner
                    .onTapGesture {
                        Task{
                            do {
                                try await ServerCommands().markBidAsUnseen(bidId: bidId, sellerId: bidSellerId)
                                withAnimation(.easeInOut) { // Animate the transition
                                    isNew = true
                                }
                            }
                            catch{
                                print(error)
                            }
                        }
                    }
            }
        }
        .background(Color.gray.opacity(0.3)) // Ensure background is applied to VStack
        .cornerRadius(20)
        .padding(.vertical, 2)
        .background(
            NavigationLink(
                destination: showImageDisplayView,
                isActive: $isNavigationActive
            ) { EmptyView() }
        )
    }
}


struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var bidNotifications: [BidNotification] = [] // Initial set of notifications
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var actionToConfirm: (() -> Void)?
    @State private var isNavigationActive = false
    @State private var selectedContent: RectangleContent?

    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    @State var sellerId: Int

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(bidNotifications) { bidNotification in
                    bidNotification
//                    .frame(height: 150)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                }
            }
            .padding(.top, 20) // Add padding at the top of the ScrollView

        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Confirm")) {
                    actionToConfirm?()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Notifications")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.contrastColor(for: colorScheme))
            }
        }
        
        .onAppear{
            Task {
                do{
                    self.bidNotifications.removeAll()
                    let (bidIds, buyerIds, sellerIds, imageIds, messageTexts, seenBySellers, successfulBids) = try await ServerCommands().getSellerBidInfo(sellerId: sellerId)
                    
                    for index in 0..<bidIds.count {
                        let bidId = bidIds[index]
                        let bidBuyerId = buyerIds[index]
                        let bidSellerId = sellerIds[index]
                        let bidImageId = imageIds[index]
                        let (_, bidImage, bidImageCaption) = try await ServerCommands().retrieveImage(imageId: bidImageId)
                        let bidImageTags = try await ServerCommands().getTagsFromImage(imageId: bidImageId)
                        let bidMessageText = messageTexts[index]
                        let bidSeenBySeller = seenBySellers[index]
                        let buyerUsername = try await ServerCommands().getUsername(userId: bidBuyerId)
                        let isBidSuccessful = successfulBids[index]
                        print(bidSeenBySeller)
                        let newBid = BidNotification(bidId: bidId, bidBuyerId: bidBuyerId, bidSellerId: bidSellerId, bidImageId: bidImageId, bidImageCaption: bidImageCaption, bidTitle: "New Purchase Request from \(buyerUsername):", bidText: "\(bidMessageText)", bidPrice: 1000.00, isNew: !bidSeenBySeller, isSellerResponse: false, isBidSuccessful: isBidSuccessful, onAccept: {
                            alertTitle = "Confirm Bid"
                            alertMessage = "You are about to confirm the bid."
                            actionToConfirm = {
                                // Logic to accept the bid
                                bidNotifications.removeAll { $0.bidId == bidId }
                                 Task{
                                      do {
                                          try await ServerCommands().markBidSuccessful(bidId: bidId)
//                                          let newBuyerNotif = BidNotification(bidId: bidId, bidBuyerId: bidBuyerId, bidSellerId: bidImageId, bidImageId: bidImageId, bidImageCaption: "", bidTitle: "", bidText: "", bidPrice: 1000.00, isNew: bidSeenBySeller, isSellerResponse: true, isBidSuccessful: true, onCheckmarkPressed: {
//                                              DispatchQueue.main.async {
//                                                  bidNotifications.removeAll { $0.bidId == bidId }
//                                              }
//                                          })
                                          print("seller accepted, response sent to buyer")
                                          try await ServerCommands().addBid(sellerId: bidSellerId, buyerId: bidBuyerId, imageId: bidImageId, messageText: "Your purchase offer has been accepted!", isSellerResponse: true)
//                                          bidNotifications.append(newBuyerNotif)
                                      }
                                      catch {
                                          print(error)
                                      }
                                 }
                            }
                            showAlert = true
                        }, onReject: {
                            alertTitle = "Decline Bid"
                            alertMessage = "You are about to decline the bid."
                            actionToConfirm = {
                                // Logic to reject the bid
                                bidNotifications.removeAll { $0.bidId == bidId }
                                 Task{
                                      do {
                                          let newBuyerNotif = BidNotification(bidId: bidId, bidBuyerId: bidBuyerId, bidSellerId: bidImageId, bidImageId: bidImageId, bidImageCaption: "", bidTitle: "", bidText: "", bidPrice: 1000.00, isNew: bidSeenBySeller, isSellerResponse: true, isBidSuccessful: false, onCheckmarkPressed: {
                                              DispatchQueue.main.async {
                                                  bidNotifications.removeAll { $0.bidId == bidId }
                                              }
                                          })
                                          try await ServerCommands().deleteBid(bidId: bidId)
                                          print("seller rejected, response sent to buyer")
                                          bidNotifications.append(newBuyerNotif)
                                      }
                                      catch {
                                           print(error)
                                      }
                                 }
                            }
                            showAlert = true
                        }, showImageDisplayView:
                            ImageDisplayView(posterId: bidSellerId, imageId: bidImageId, image: bidImage, caption: bidImageCaption, tags: bidImageTags)
                        )
                        print(newBid)
                        bidNotifications.append(newBid as! BidNotification)
                        if (!bidSeenBySeller) {
                            try await ServerCommands().markBidAsSeen(bidId: bidId, sellerId: sellerId)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }

    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.contrastColor(for: colorScheme))
        }
    }
}
