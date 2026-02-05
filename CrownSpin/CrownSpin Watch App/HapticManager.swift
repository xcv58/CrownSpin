import WatchKit

/// Manages haptic feedback based on Digital Crown rotation
class HapticManager: ObservableObject {
    @Published var currentPattern: HapticPattern {
        didSet {
            savePattern()
            resetState()
        }
    }

    private var lastRotationValue: Double = 0
    private var accumulatedDelta: Double = 0

    // For rhythm patterns
    private var rhythmStep: Int = 0
    private var waveIntensity: Int = 0
    private var waveDirection: Int = 1

    private let userDefaultsKey = "selectedHapticPattern"

    init() {
        // Load saved pattern or default to clicks
        if let savedPattern = UserDefaults.standard.string(forKey: userDefaultsKey),
           let pattern = HapticPattern(rawValue: savedPattern) {
            self.currentPattern = pattern
        } else {
            self.currentPattern = .clicks
        }
    }

    private func savePattern() {
        UserDefaults.standard.set(currentPattern.rawValue, forKey: userDefaultsKey)
    }

    private func resetState() {
        rhythmStep = 0
        waveIntensity = 0
        waveDirection = 1
        accumulatedDelta = 0
    }

    /// Process rotation change and trigger haptics as needed
    func processRotation(_ newValue: Double) {
        let delta = abs(newValue - lastRotationValue)
        lastRotationValue = newValue
        accumulatedDelta += delta

        let sensitivity = currentPattern.sensitivity

        while accumulatedDelta >= sensitivity {
            accumulatedDelta -= sensitivity
            triggerHaptic()
        }
    }

    private func triggerHaptic() {
        switch currentPattern {
        case .clicks, .soft, .heavy:
            playBasicHaptic()
        case .heartbeat:
            playHeartbeat()
        case .doubleTap:
            playDoubleTap()
        case .gallop:
            playGallop()
        case .waltz:
            playWaltz()
        case .staccato:
            playStaccato()
        case .wave:
            playWave()
        case .random:
            playRandom()
        }
    }

    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }

    private func playBasicHaptic() {
        playHaptic(currentPattern.primaryHaptic)
    }

    private func playHeartbeat() {
        // Heartbeat: strong-weak pattern (lub-dub)
        playHaptic(rhythmStep % 2 == 0 ? .start : .stop)
        rhythmStep += 1
    }

    private func playDoubleTap() {
        // Two quick taps
        playHaptic(.click)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.playHaptic(.click)
        }
    }

    private func playGallop() {
        // Long-short-short rhythm (da-da-dum)
        let haptics: [WKHapticType] = [.notification, .click, .click]
        playHaptic(haptics[rhythmStep % 3])
        rhythmStep += 1
    }

    private func playWaltz() {
        // 1-2-3 rhythm with emphasis on 1
        let step = rhythmStep % 3
        playHaptic(step == 0 ? .notification : .click)
        rhythmStep += 1
    }

    private func playStaccato() {
        playHaptic(.click)
    }

    private func playWave() {
        // Intensity builds up then fades
        let haptics: [WKHapticType] = [.click, .directionUp, .directionDown, .notification, .directionDown, .directionUp, .click]
        playHaptic(haptics[waveIntensity])

        waveIntensity += waveDirection
        if waveIntensity >= haptics.count - 1 {
            waveDirection = -1
        } else if waveIntensity <= 0 {
            waveDirection = 1
        }
    }

    private func playRandom() {
        let haptics: [WKHapticType] = [.click, .directionUp, .directionDown, .success, .failure, .retry, .start, .stop, .notification]
        if let randomHaptic = haptics.randomElement() {
            playHaptic(randomHaptic)
        }
    }

    func nextPattern() {
        let allPatterns = HapticPattern.allCases
        if let currentIndex = allPatterns.firstIndex(of: currentPattern) {
            let nextIndex = (currentIndex + 1) % allPatterns.count
            currentPattern = allPatterns[nextIndex]
        }
        playHaptic(.click)
    }

    func previousPattern() {
        let allPatterns = HapticPattern.allCases
        if let currentIndex = allPatterns.firstIndex(of: currentPattern) {
            let previousIndex = (currentIndex - 1 + allPatterns.count) % allPatterns.count
            currentPattern = allPatterns[previousIndex]
        }
        playHaptic(.click)
    }
}
