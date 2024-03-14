import SwiftUI

struct FireworkEffectView: View {
    let particleCount = 20 // Number of particles
    @State var startAnimation = false
    @State var explodeAnimation = false

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                ParticleView()
                    .scaleEffect(explodeAnimation ? 2 : 0.1) // Adjusted scale effect for explosion size
                    .offset(x: explodeAnimation ? CGFloat.random(in: -200...200) : 0, y: explodeAnimation ? CGFloat.random(in: -200...200) : 0)
                    .opacity(startAnimation ? 1 : 0)
                    .animation(Animation.easeOut(duration: 1).delay(Double(index) * 0.05), value: explodeAnimation)
            }
        }
        .onAppear {
            startAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                explodeAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    startAnimation = false
                    explodeAnimation = false
                }
            }
        }
    }
}

struct ParticleView: View {
    var body: some View {
        Circle()
            .frame(width: 10, height: 10) // Adjusted particle size
            .foregroundColor(.random)
            .shadow(color: .random.opacity(0.9), radius: 5, x: 0, y: 0) // Enhanced glow effect
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

struct FireworkEffectView_Previews: PreviewProvider {
    static var previews: some View {
        FireworkEffectView()
    }
}
