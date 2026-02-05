import SwiftUI

struct ContentView: View {
    @StateObject private var hapticManager = HapticManager()
    @State private var crownRotation: Double = 0.0
    @State private var showIndicator: Bool = true

    var body: some View {
        ZStack {
            // Pure black background for discretion
            Color.black
                .ignoresSafeArea()

            // Subtle rotating ring indicator
            if showIndicator {
                RotatingRingView(rotation: crownRotation * 50)
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

            // Tap zones overlay
            HStack(spacing: 0) {
                // Left half - previous pattern
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hapticManager.previousPattern()
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        withAnimation {
                            showIndicator.toggle()
                        }
                    }

                // Right half - next pattern
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hapticManager.nextPattern()
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        withAnimation {
                            showIndicator.toggle()
                        }
                    }
            }
        }
        .focusable()
        .digitalCrownRotation($crownRotation)
        .onChange(of: crownRotation) { oldValue, newValue in
            hapticManager.processRotation(newValue)
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
