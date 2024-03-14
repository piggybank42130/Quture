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
    var onDismiss: () -> Void = {}
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
                // Status message about the bid
                Text(isBidSuccessful ? "Your bid of $\(String(format: "%.2f", bidPrice)) has been accepted! Look out for a text/call." : "Your bid of $\(String(format: "%.2f", bidPrice)) has been rejected, sorry.")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isBidSuccessful ? Color.green : Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10) // Add horizontal padding here, outside of the frame
                .padding(.top) // Add some top padding to separate from the status message

                // "See Image" section
                Button(action: {
                    isNavigationActive = true
                }) {
                    VStack {
                        Text("See Image")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Caption: \(bidImageCaption)")
                            .foregroundColor(.black)
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10) // Add horizontal padding here, outside of the frame
                .padding(.top) // Add some top padding to separate from the Dismiss button

            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(20)
            .padding() // This adds padding around the entire VStack within the ZStack for spacing from the edges.

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
                .padding() // Pads the horizontal sides of the HStack to align with the text
                .onTapGesture {
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
                    .offset(x: 10, y: -10) // Adjusts the position relative to the top right corner
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
                    .offset(x: 10, y: -10) // Adjusts the position relative to the top right corner
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
        .padding()
        .background(Color.gray.opacity(0.3)) // Ensure background is applied to VStack
        .cornerRadius(20)
        .padding([.top, .trailing], 0)

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
                    for n in 0..<2 {
                        let (bidIds, buyerIds, sellerIds, imageIds, messageTexts, seenBySellers, successfulBids, isSellerResponses) = try await (n == 0 ? ServerCommands().getBuyerBidInfo(buyerId: LocalStorage().getUserId()) : ServerCommands().getSellerBidInfo(sellerId: LocalStorage().getUserId()))
                        
                        for index in 0..<bidIds.count {
                            print(n, index)
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
                            let isSellerResponse = isSellerResponses[index]
                            let newBid = BidNotification(bidId: bidId, bidBuyerId: bidBuyerId, bidSellerId: bidSellerId, bidImageId: bidImageId, bidImageCaption: bidImageCaption, bidTitle: (n == 0 ? "Purchase Request from \(buyerUsername):" : "Purchase Response from \(buyerUsername):"), bidText: "\(bidMessageText)", bidPrice: 1000.00, isNew: !bidSeenBySeller, isSellerResponse: isSellerResponse, isBidSuccessful: isBidSuccessful, onAccept: {
                                alertTitle = "Confirm Bid"
                                alertMessage = "You are about to confirm the bid."
                                actionToConfirm = {
                                    // Logic to accept the bid
                                    bidNotifications.removeAll { $0.bidId == bidId }
                                    Task{
                                        do {
                                            try await ServerCommands().markBidSuccessful(bidId: bidId)
                                            print("seller accepted, response sent to buyer")
                                            try await ServerCommands().addBid(sellerId: bidSellerId, buyerId: bidBuyerId, imageId: bidImageId, messageText: "Your purchase offer has been accepted!", successful: true, isSellerResponse: true)
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
                                            try await ServerCommands().markBidSuccessful(bidId: bidId)
                                            print("seller accepted, response sent to buyer")
                                            try await ServerCommands().addBid(sellerId: bidSellerId, buyerId: bidBuyerId, imageId: bidImageId, messageText: "Your purchase offer has been rejected, sorry", successful: false, isSellerResponse: true)
                                            //                                          bidNotifications.append(newBuyerNotif)
                                        }
                                        catch {
                                            print(error)
                                        }
                                    }
                                }
                                showAlert = true
                            }, onDismiss: {
                                    bidNotifications.removeAll { $0.bidId == bidId }
                                    Task{
                                        do {
                                            
                                            try await ServerCommands().deleteBid(bidId: bidId)
                                        }
                                        catch {
                                            print(error)
                                        }
                                    }
                                
                            } , showImageDisplayView:
                                ImageDisplayView(posterId: bidSellerId, imageId: bidImageId, image: bidImage, caption: bidImageCaption, tags: bidImageTags)
                            )
                            print(newBid)
                            bidNotifications.append(newBid as! BidNotification)
                            if (!bidSeenBySeller) {
                                try await ServerCommands().markBidAsSeen(bidId: bidId, sellerId: LocalStorage().getUserId())
                            }
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
