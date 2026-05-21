import SwiftUI

struct GoalsView: View {
    private let goals = GoalItem.mock

    var body: some View {
        NavigationStack {
            List {
                Section("Главные цели") {
                    ForEach(goals) { goal in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.emoji)
                                Text(goal.title)
                                    .font(.headline)
                                Spacer()
                            }
                            ProgressView(value: goal.progress)
                            Text("\(format(goal.currentAmount)) / \(format(goal.targetAmount)) UAH")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Красная линия") {
                    Text("Что ломает семью — сразу мимо.")
                }
            }
            .navigationTitle("Цели")
        }
    }

    private func format(_ value: Decimal) -> String {
        let number = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: number) ?? "0"
    }
}

#Preview {
    GoalsView()
}
