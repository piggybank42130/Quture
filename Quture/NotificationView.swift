import SwiftUI

struct BidNotification: View {

    let id: Int
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
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var actionToConfirm: (() -> Void)?
    @ObservedObject var notificationsModel: BidNotificationsModel
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(bidNotifications, id: \.self) { index in
                    BidNotification(id: index, text: "New bid received! \(index)", onAccept: {
                        alertTitle = "Confirm Bid"
                        alertMessage = "You are about to confirm the bid."
                        actionToConfirm = {
                            // Logic to accept the bid
                            bidNotifications.removeAll { $0 == index }
                        }
                        showAlert = true
                    }, onReject: {
                        alertTitle = "Decline Bid"
                        alertMessage = "You are about to decline the bid."
                        actionToConfirm = {
                            // Logic to reject the bid
                            bidNotifications.removeAll { $0 == index }
                        }
                        showAlert = true
                    })
                    .frame(height: 150)
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


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        //Instantiate BidNotificationsModel
        let model = BidNotificationsModel()
        NotificationView(notificationsModel: model)
    }
}
