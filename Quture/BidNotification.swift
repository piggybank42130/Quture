import SwiftUI

struct BidNotification: View {
    let text: String
    var onAccept: () -> Void = {}
    var onReject: () -> Void = {}

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
        .cornerRadius(10)
        .padding(.vertical, 8)
    }
}
