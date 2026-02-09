import SwiftUI
import WatchKit

struct ContentView: View {
    // MARK: - Constants
    private enum Constants {
        static let patternKey = "selectedHapticPattern"
        static let ambientModeKey = "ambientModeEnabled"
        static let windowSize = 1000
        static let windowCenter = 500
        static let rebalanceThreshold = 100
        static let idleDelay: TimeInterval = 1.5
    }

    // MARK: - State
    @State private var currentPattern: HapticPattern = .clicks
    @State private var scrollPosition: Int? = Constants.windowCenter
    @State private var lastPosition: Int = Constants.windowCenter
    @State private var isScrolling: Bool = false
    @State private var scrollTimer: Timer?
    @State private var hasInitialized: Bool = false
    @State private var isTapNavigation: Bool = false

    // Random mode state
    @State private var randomChangeCounter: Int = 0
    @State private var randomChangeThreshold: Int = Int.random(in: 3...5)
    @State private var currentRandomPattern: HapticPattern = .clicks

    // Infinite scroll state
    @State private var baseOffset: Int = 0

    // UI state
    @State private var showPatternPicker: Bool = false
    @State private var showStats: Bool = false
    @State private var isAmbientMode: Bool = false

    // Stats
    @StateObject private var stats = HapticStats.shared

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Main scroll view
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(0..<Constants.windowSize, id: \.self) { index in
                            ItemRow(
                                isSelected: scrollPosition == index,
                                displayNumber: index - Constants.windowCenter + baseOffset,
                                isAmbientMode: isAmbientMode,
                                isScrolling: isScrolling
                            )
                            .id(index)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 2) {
                                if scrollPosition == index {
                                    WKInterfaceDevice.current().play(.click)
                                    showStats = true
                                }
                            }
                            .onTapGesture(count: 1) {
                                if scrollPosition == index {
                                    nextPattern()
                                } else {
                                    isTapNavigation = true
                                    showControls()
                                    scrollPosition = index
                                    withAnimation {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        if scrollPosition == index {
                                            WKInterfaceDevice.current().play(.notification)
                                            baseOffset = 0
                                            lastPosition = Constants.windowCenter
                                            scrollPosition = Constants.windowCenter
                                        }
                                    }
                            )
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 60)
                }
                .scrollPosition(id: $scrollPosition, anchor: .center)
                .scrollTargetBehavior(.viewAligned)
                .onChange(of: scrollPosition) { oldValue, newValue in
                    handleScrollChange(from: oldValue, to: newValue)
                }
                .animation(.easeInOut(duration: 0.3), value: isScrolling)
                .onAppear {
                    // Scroll to center on initial load
                    proxy.scrollTo(Constants.windowCenter, anchor: .center)
                }
            }

            // Bottom controls
            VStack {
                Spacer()
                controlLabel
            }
        }
        .sheet(isPresented: $showPatternPicker) {
            PatternPicker(selectedPattern: $currentPattern)
                .onChange(of: currentPattern) { _, newPattern in
                    onPatternChanged(to: newPattern)
                }
        }
        .sheet(isPresented: $showStats) {
            StatsView(stats: stats)
        }
        .onAppear {
            loadSettings()
            stats.startSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasInitialized = true
            }
        }
        .onDisappear {
            scrollTimer?.invalidate()
            stats.endSession()
        }
    }

    // MARK: - Subviews

    private var controlLabel: some View {
        HStack(spacing: 6) {
            if currentPattern == .random {
                Image(systemName: "dice")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Image(systemName: currentRandomPattern.icon)
                    .font(.system(size: 18))
                Text(currentRandomPattern.displayName)
                    .font(.system(size: 16, weight: .semibold))
            } else {
                Image(systemName: currentPattern.icon)
                    .font(.system(size: 18))
                Text(currentPattern.displayName)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(isAmbientMode ? 0.2 : 0.4))
        .cornerRadius(20)
        .padding(.bottom, 4)
        .opacity(currentPattern == .random ? 1.0 : (isScrolling ? 0.0 : 1.0))
        .animation(.easeInOut(duration: 0.3), value: isScrolling)
        .onLongPressGesture(minimumDuration: 0.5, perform: {
            WKInterfaceDevice.current().play(.click)
            showPatternPicker = true
        }, onPressingChanged: { _ in })
        .onTapGesture {
            nextPattern()
        }
        .contextMenu {
            Button {
                showPatternPicker = true
            } label: {
                Label("Effects", systemImage: "waveform")
            }

            Button {
                showStats = true
            } label: {
                Label("Statistics", systemImage: "chart.bar")
            }

            Button {
                toggleAmbientMode()
            } label: {
                Label(isAmbientMode ? "Normal Mode" : "Ambient Mode", systemImage: isAmbientMode ? "sun.max" : "moon")
            }
        }
    }

    // MARK: - Actions

    private func handleScrollChange(from oldValue: Int?, to newValue: Int?) {
        guard let newPos = newValue, newPos != lastPosition else { return }
        lastPosition = newPos

        if hasInitialized {
            triggerHaptic()
            if isTapNavigation {
                isTapNavigation = false
            } else {
                startScrolling()
            }
            checkAndRebalance(newPos)
        }
    }

    private func showControls() {
        scrollTimer?.invalidate()
        isScrolling = false
    }

    private func startScrolling() {
        isScrolling = true
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: Constants.idleDelay, repeats: false) { _ in
            DispatchQueue.main.async {
                isScrolling = false
            }
        }
    }

    private func checkAndRebalance(_ position: Int) {
        if position < Constants.rebalanceThreshold || position > Constants.windowSize - Constants.rebalanceThreshold {
            let offsetFromCenter = position - Constants.windowCenter
            baseOffset += offsetFromCenter
            lastPosition = Constants.windowCenter
            scrollPosition = Constants.windowCenter
        }
    }

    private func nextPattern() {
        let allPatterns = HapticPattern.allCases
        if let currentIndex = allPatterns.firstIndex(of: currentPattern) {
            let nextIndex = (currentIndex + 1) % allPatterns.count
            currentPattern = allPatterns[nextIndex]
        }
        onPatternChanged(to: currentPattern)
    }

    private func onPatternChanged(to pattern: HapticPattern) {
        resetRandomState()
        // Play preview haptic
        if pattern == .random {
            WKInterfaceDevice.current().play(currentRandomPattern.primaryHaptic)
        } else {
            WKInterfaceDevice.current().play(pattern.primaryHaptic)
        }
        saveSettings()
    }

    private func resetRandomState() {
        randomChangeCounter = 0
        randomChangeThreshold = Int.random(in: 3...5)
        currentRandomPattern = HapticPattern.nonRandomPatterns.randomElement() ?? .clicks
    }

    private func triggerHaptic() {
        stats.recordHaptic()

        if currentPattern == .random {
            randomChangeCounter += 1
            if randomChangeCounter >= randomChangeThreshold {
                currentRandomPattern = HapticPattern.nonRandomPatterns.randomElement() ?? .clicks
                randomChangeCounter = 0
                randomChangeThreshold = Int.random(in: 3...5)
            }
            WKInterfaceDevice.current().play(currentRandomPattern.primaryHaptic)
        } else {
            WKInterfaceDevice.current().play(currentPattern.primaryHaptic)
        }
    }

    private func toggleAmbientMode() {
        isAmbientMode.toggle()
        WKInterfaceDevice.current().play(.click)
        UserDefaults.standard.set(isAmbientMode, forKey: Constants.ambientModeKey)
    }

    // MARK: - Persistence

    private func loadSettings() {
        if let saved = UserDefaults.standard.string(forKey: Constants.patternKey),
           let pattern = HapticPattern(rawValue: saved) {
            currentPattern = pattern
        }
        isAmbientMode = UserDefaults.standard.bool(forKey: Constants.ambientModeKey)
    }

    private func saveSettings() {
        UserDefaults.standard.set(currentPattern.rawValue, forKey: Constants.patternKey)
        UserDefaults(suiteName: "group.com.xcv58.crownspin.watchapp")?.set(currentPattern.rawValue, forKey: Constants.patternKey)
    }
}

// MARK: - ItemRow

struct ItemRow: View {
    let isSelected: Bool
    let displayNumber: Int
    let isAmbientMode: Bool
    let isScrolling: Bool

    private var backgroundOpacity: Double {
        if isScrolling && !isSelected {
            return isAmbientMode ? 0.1 : 0.3
        }
        return 1.0
    }

    var body: some View {
        ZStack {
            // Base background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isAmbientMode ? 0.03 : 0.06),
                            Color.white.opacity(isAmbientMode ? 0.01 : 0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(backgroundOpacity)

            // Selection highlight
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAmbientMode ? 0.08 : 0.15))
            }

            // Subtle top highlight line (non-selected only)
            if !isSelected {
                VStack {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(isAmbientMode ? 0.05 : 0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 8)
                    Spacer()
                }
                .opacity(backgroundOpacity)
            }

            // Number
            Text("\(displayNumber)")
                .font(.system(size: isSelected ? 20 : 14, weight: isSelected ? .medium : .regular, design: .rounded))
                .foregroundColor(.white.opacity(isSelected ? (isAmbientMode ? 0.6 : 1.0) : (isAmbientMode ? 0.2 : 0.4)))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: isScrolling)
    }
}

#Preview {
    ContentView()
}
