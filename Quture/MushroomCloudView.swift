import SwiftUI

struct MushroomCloudView: View {
    private let particleCount = 100
    @State private var expandAnimation = false
    @State private var riseAnimation = false
    @State private var fadeOutAnimation = false

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                Circle()
                    .frame(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15))
                    .foregroundColor(.gray.opacity(0.8))
                    .offset(
                        x: expandAnimation ? CGFloat.random(in: -30 ... 30) * (index % 2 == 0 ? -1 : 1) : 0,
                        y: riseAnimation ? CGFloat.random(in: -300 ... -50) : 0
                    )
                    .opacity(fadeOutAnimation ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 2).delay(Double(index) / Double(particleCount)),
                        value: expandAnimation
                    )
                    .animation(
                        Animation.easeInOut(duration: 2).delay(Double(index) / Double(particleCount)),
                        value: riseAnimation
                    )
                    .animation(
                        Animation.easeInOut(duration: 2).delay(2 + Double(index) / Double(particleCount)),
                        value: fadeOutAnimation
                    )
            }
        }
        .onAppear {
            withAnimation {
                expandAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    riseAnimation = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    fadeOutAnimation = true
                }
            }
        }
    }
}

struct MushroomCloudView_Previews: PreviewProvider {
    static var previews: some View {
        MushroomCloudView()
    }
}
