import WatchKit
import Combine

/// Manages haptic feedback based on Digital Crown rotation
@MainActor
class HapticManager: ObservableObject {
    @Published var currentPattern: HapticPattern {
        didSet {
            savePattern()
            resetState()
        }
    }

    private let device = WKInterfaceDevice.current()
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

    private func playBasicHaptic() {
        device.play(currentPattern.primaryHaptic)
    }

    private func playHeartbeat() {
        // Heartbeat: strong-weak pattern (lub-dub)
        if rhythmStep % 2 == 0 {
            device.play(.start)
        } else {
            device.play(.stop)
        }
        rhythmStep += 1
    }

    private func playDoubleTap() {
        // Two quick taps
        device.play(.click)
        Task {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            await MainActor.run {
                self.device.play(.click)
            }
        }
    }

    private func playGallop() {
        // Long-short-short rhythm (da-da-dum)
        let haptics: [WKHapticType] = [.notification, .click, .click]
        device.play(haptics[rhythmStep % 3])
        rhythmStep += 1
    }

    private func playWaltz() {
        // 1-2-3 rhythm with emphasis on 1
        let step = rhythmStep % 3
        if step == 0 {
            device.play(.notification) // Strong beat
        } else {
            device.play(.click) // Weak beats
        }
        rhythmStep += 1
    }

    private func playStaccato() {
        // Sharp, crisp taps
        device.play(.click)
    }

    private func playWave() {
        // Intensity builds up then fades
        let haptics: [WKHapticType] = [.click, .directionUp, .directionDown, .notification, .directionDown, .directionUp, .click]
        device.play(haptics[waveIntensity])

        waveIntensity += waveDirection
        if waveIntensity >= haptics.count - 1 {
            waveDirection = -1
        } else if waveIntensity <= 0 {
            waveDirection = 1
        }
    }

    private func playRandom() {
        // Random haptic type
        let haptics: [WKHapticType] = [.click, .directionUp, .directionDown, .success, .failure, .retry, .start, .stop, .notification]
        if let randomHaptic = haptics.randomElement() {
            device.play(randomHaptic)
        }
    }

    func nextPattern() {
        let allPatterns = HapticPattern.allCases
        if let currentIndex = allPatterns.firstIndex(of: currentPattern) {
            let nextIndex = (currentIndex + 1) % allPatterns.count
            currentPattern = allPatterns[nextIndex]
        }
        // Provide feedback for pattern change
        device.play(.click)
    }

    func previousPattern() {
        let allPatterns = HapticPattern.allCases
        if let currentIndex = allPatterns.firstIndex(of: currentPattern) {
            let previousIndex = (currentIndex - 1 + allPatterns.count) % allPatterns.count
            currentPattern = allPatterns[previousIndex]
        }
        // Provide feedback for pattern change
        device.play(.click)
    }
}
