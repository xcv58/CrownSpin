import SwiftUI
import WatchKit

/// Grid picker for selecting haptic patterns
struct PatternPicker: View {
    @Binding var selectedPattern: HapticPattern
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(HapticPattern.Category.allCases) { category in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(category.patterns) { pattern in
                                    PatternCell(
                                        pattern: pattern,
                                        isSelected: selectedPattern == pattern
                                    ) {
                                        selectedPattern = pattern
                                        // Play preview haptic
                                        if pattern == .random {
                                            WKInterfaceDevice.current().play(HapticPattern.nonRandomPatterns.randomElement()?.primaryHaptic ?? .click)
                                        } else {
                                            WKInterfaceDevice.current().play(pattern.primaryHaptic)
                                        }
                                        dismiss()
                                    }
                                    .id(pattern.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(selectedPattern.id, anchor: .center)
                }
            }
        }
        .navigationTitle("Effects")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PatternCell: View {
    let pattern: HapticPattern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: pattern.icon)
                    .font(.system(size: 22))
                Text(pattern.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PatternPicker(selectedPattern: .constant(.clicks))
}
