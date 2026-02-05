import SwiftUI

struct ContentView: View {
    @StateObject private var hapticManager = HapticManager()
    @State private var crownRotation: Double = 0.0
    @State private var showIndicator: Bool = true
    @State private var ringRotation: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pure black background for discretion
                Color.black
                    .ignoresSafeArea()

                // Subtle rotating ring indicator
                if showIndicator {
                    RotatingRingView(rotation: ringRotation)
                        .opacity(0.3)
                }

                // Pattern indicator at bottom
                if showIndicator {
                    VStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: hapticManager.currentPattern.icon)
                                .font(.system(size: 12))
                            Text(hapticManager.currentPattern.displayName)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 8)
                    }
                }

                // Invisible tap zones
                HStack(spacing: 0) {
                    // Left half - previous pattern
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hapticManager.previousPattern()
                        }

                    // Right half - next pattern
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hapticManager.nextPattern()
                        }
                }
            }
            .onTapGesture(count: 2) {
                // Double tap toggles indicator visibility
                withAnimation(.easeInOut(duration: 0.2)) {
                    showIndicator.toggle()
                }
            }
        }
        .focusable()
        .digitalCrownRotation(
            $crownRotation,
            from: -Double.infinity,
            through: Double.infinity,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: false
        )
        .onChange(of: crownRotation) { oldValue, newValue in
            hapticManager.processRotation(newValue)
            // Update ring rotation for visual feedback
            withAnimation(.linear(duration: 0.1)) {
                ringRotation = newValue * 50 // Amplify for visual effect
            }
        }
    }
}

/// A subtle rotating ring that provides visual feedback
struct RotatingRingView: View {
    let rotation: Double

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .gray.opacity(0.1),
                            .gray.opacity(0.4),
                            .gray.opacity(0.1)
                        ]),
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 80, height: 80)

            // Rotation indicator dot
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
                .offset(y: -40)
        }
        .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    ContentView()
}
