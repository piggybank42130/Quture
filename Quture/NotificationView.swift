import SwiftUI

struct BidNotification: View {
    let text: String
    var onAccept: () -> Void = {}
    var onReject: () -> Void = {}
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors


    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
                .padding()

            HStack {
                Spacer()

                Button(action: onAccept) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                }
                .padding()

                Button(action: onReject) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(20)
        .padding(.vertical, 2)
    }
}

struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var bidNotifications: [Int] = Array(0..<20) // Initial set of notifications
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    @ObservedObject var notificationsModel: BidNotificationsModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(bidNotifications, id: \.self) { index in
                    BidNotification(text: "New bid received! \(index)", onAccept: {
                        // Handle accept action
                        print("Bid \(index) accepted")
                    }, onReject: {
                        // Handle reject action
                        print("Bid \(index) rejected")
                    })
                    .frame(height: 150) // Set the height of each notification
                    .padding(.vertical, 2) // Add some vertical padding between notifications
                    .padding(.horizontal, 4)
                    .onAppear {
                        // Load more notifications when the last one appears
                        if index == bidNotifications.last {
                            loadMoreNotifications()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.contrastColor(for: colorScheme))
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Notifications")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.contrastColor(for: colorScheme))
            }
        }
    }

    private func loadMoreNotifications() {
        // Append more notifications to the list
        let nextSet = bidNotifications.count..<bidNotifications.count + 20
        bidNotifications.append(contentsOf: Array(nextSet))
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        //Instantiate BidNotificationsModel
        let model = BidNotificationsModel()
        NotificationView(notificationsModel: model)
    }
}
