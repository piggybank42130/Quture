import SwiftUI

struct BidNotification: View, Identifiable {
    let id = UUID()
    
    @State var bidId: Int
    @State var bidBuyerId: Int
    @State var bidSellerId: Int
    @State var bidImageId: Int
    
    @State var bidTitle: String
    @State var bidText: String
    @State var bidPrice: Double
    
    @State var isNew: Bool
    
    var onAccept: () -> Void = {}
    var onReject: () -> Void = {}
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Text(bidTitle)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center) // Aligns text with the width of the bid title
                
                Text(bidText)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center) // Aligns text with the width of the bid title
                
                Text("I'm offering $\(String(format: "%.2f", bidPrice))")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center) // Aligns text with the width of the bid title
                
                HStack(spacing: 10) { // Added spacing between buttons
                    Button(action: onAccept) {
                        Rectangle()
                            .foregroundColor(.green)
                            .frame(height: 50) // Removed the fixed width
                            .cornerRadius(10) // Rounded corners
                            .overlay(
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal, 2) // Minor horizontal padding for button
                    .padding(.vertical, 10)
                    
                    Button(action: onReject) {
                        Rectangle()
                            .foregroundColor(.red)
                            .frame(height: 50) // Removed the fixed width
                            .cornerRadius(10) // Rounded corners
                            .overlay(
                                Image(systemName: "xmark")
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
                    .offset(x: -10, y: -10) // Adjusts the position relative to the top right corner
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
                    .offset(x: -10, y: -10) // Adjusts the position relative to the top right corner
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
    }
}


struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var bidNotifications: [BidNotification] = [] // Initial set of notifications
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var actionToConfirm: (() -> Void)?
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
                    let (bidIds, buyerIds, sellerIds, imageIds, messageTexts, seenBySellers) = try await ServerCommands().getSellerBidInfo(sellerId: sellerId)
                    
                    for index in 0..<bidIds.count {
                        let bidId = bidIds[index]
                        let bidBuyerId = buyerIds[index]
                        let bidSellerId = sellerIds[index]
                        let bidImageId = imageIds[index]
                        let bidMessageText = messageTexts[index]
                        let bidSeenBySeller = seenBySellers[index]
                        let buyerUsername = try await ServerCommands().getUsername(userId: bidBuyerId)
                         print(bidSeenBySeller)
                        let newBid = BidNotification(bidId: bidId, bidBuyerId: bidBuyerId, bidSellerId: bidSellerId, bidImageId: bidImageId, bidTitle: "New Purchase Request from \(buyerUsername):", bidText: "\(bidMessageText)", bidPrice: 1000.00, isNew: !bidSeenBySeller, onAccept: {
                            alertTitle = "Confirm Bid"
                            alertMessage = "You are about to confirm the bid."
                            actionToConfirm = {
                                // Logic to accept the bid
                                 bidNotifications.removeAll { $0.bidId == bidId }
                                 Task{
                                      do {
                                           try await ServerCommands().markBidSuccessful(bidId: bidId)
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
                                           try await ServerCommands().deleteBid(bidId: bidId)
                                      }
                                      catch {
                                           print(error)
                                      }
                                 }
                            }
                            showAlert = true
                        })
                        bidNotifications.append(newBid)
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
