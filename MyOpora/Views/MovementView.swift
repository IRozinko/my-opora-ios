import SwiftUI

struct MovementView: View {
    @StateObject private var healthKit = HealthKitService.shared
    @State private var selectedGoal = 8_000

    private let goals = [5_000, 7_000, 8_000, 10_000]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    stepsCard
                    goalCard
                    rulesCard
                }
                .padding(16)
            }
            .navigationTitle("Движение")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                Button {
                    Task { await healthKit.loadStepSummary(goal: selectedGoal) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await healthKit.loadStepSummary(goal: selectedGoal)
            }
        }
    }

    private var headerCard: some View {
        OporaCard("Не превращаемся в мебель", systemImage: "figure.walk.circle.fill") {
            Text("Ходьба — базовая смазка системы: спина, голова, сон, энергия, стресс.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Не подвиг. Ежедневный минимум.")
                .font(.headline)
        }
    }

    private var stepsCard: some View {
        OporaCard("Шаги сегодня", systemImage: "shoeprints.fill") {
            let summary = healthKit.lastSummary

            HStack(alignment: .firstTextBaseline) {
                Text("\(summary.todaySteps)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                Text("/ \(summary.goal)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ProgressView(value: summary.progress)

            Text("Среднее за 7 дней: \(summary.sevenDayAverage) шагов")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text("\(statusEmoji(summary.status)) \(summary.status.title): \(summary.status.message)")
                .font(.subheadline)

            if let error = healthKit.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var goalCard: some View {
        OporaCard("Цель дня", systemImage: "target") {
            Picker("Цель", selection: $selectedGoal) {
                ForEach(goals, id: \.self) { goal in
                    Text("\(goal) шагов").tag(goal)
                }
            }
            .onChange(of: selectedGoal) { _, newGoal in
                Task { await healthKit.loadStepSummary(goal: newGoal) }
            }

            Text("Зелёный день — 8000–10000. Жёлтый — 5000–7000. Красный — хотя бы 3000–4000 или 15–20 минут прогулки.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var rulesCard: some View {
        OporaCard("Правила", systemImage: "heart.text.square.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("• Каждый день не ноль.")
                Text("• Длинный маршрут — когда есть ресурс.")
                Text("• Короткий маршрут — когда система в энергосбережении.")
                Text("• Боль в спине/усталость — не повод геройствовать.")
                Text("• *тык кроссовком*: ты сегодня двигался или только думал о великих стратегиях?")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private func statusEmoji(_ status: MovementStatus) -> String {
        switch status {
        case .green: return "🟢"
        case .yellow: return "🟡"
        case .red: return "🔴"
        }
    }
}

#Preview {
    MovementView()
}
