import SwiftUI

/// View for displaying haptic statistics
struct StatsView: View {
    @ObservedObject var stats: HapticStats

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StatRow(
                    icon: "hand.tap",
                    label: "This Session",
                    value: stats.formattedSession
                )

                StatRow(
                    icon: "sum",
                    label: "All Time",
                    value: stats.formattedTotal
                )

                StatRow(
                    icon: "trophy",
                    label: "Best Session",
                    value: stats.formattedLongest
                )

                StatRow(
                    icon: "number",
                    label: "Sessions",
                    value: "\(stats.totalSessions)"
                )

                StatRow(
                    icon: "gauge.with.needle",
                    label: "Peak Speed",
                    value: stats.formattedPeakSpeed
                )

                StatRow(
                    icon: "divide",
                    label: "Avg Session",
                    value: stats.formattedAvgSession
                )

                StatRow(
                    icon: "flame",
                    label: "Streak",
                    value: stats.formattedStreak
                )

                StatRow(
                    icon: "timer",
                    label: "Time Spinning",
                    value: stats.formattedSpinTime
                )
            }
            .padding(.horizontal)
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    StatsView(stats: HapticStats.shared)
}
