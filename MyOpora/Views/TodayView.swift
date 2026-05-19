import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @State private var focusText = ""
    @State private var quickExpenseAmount = ""
    @State private var quickExpenseCategory = "Кофе"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error = appState.lastError {
                        errorCard(error)
                    }
                    if let message = appState.lastMessage {
                        messageCard(message)
                    }
                    nerveStatusCard
                    morningCard
                    quickExpenseCard
                    familyStatusCard
                    goalCard
                }
                .padding(16)
            }
            .navigationTitle("Сегодня")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                Button {
                    Task { await appState.refreshAll() }
                } label: {
                    if appState.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await appState.refreshAll()
            }
        }
    }

    private var nerveStatusCard: some View {
        OporaCard("Нервная система", systemImage: "bolt.heart.fill") {
            Picker("Статус", selection: $appState.selectedNerveStatus) {
                ForEach(NerveStatus.allCases) { status in
                    Text("\(status.emoji) \(status.title)").tag(status)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appState.selectedNerveStatus) { _, newValue in
                Task { await appState.updateNerveStatus(newValue) }
            }

            Text(appState.selectedNerveStatus.recommendation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Проверка палкой") {
                Task { await appState.updateNerveStatus(.yellow) }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var morningCard: some View {
        OporaCard("Утро", systemImage: "sun.max.fill") {
            HStack {
                Image(systemName: appState.todaySnapshot.morningDone ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading) {
                    Text(appState.todaySnapshot.morningDone ? "Утро отмечено" : "Отметить утро")
                    Text("Вода, лицо, одежда, голос, один фокус")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            TextField("Фокус дня", text: $focusText)
                .textFieldStyle(.roundedBorder)

            Button("Отметить morning") {
                Task { await appState.markMorning(focus: focusText.isEmpty ? nil : focusText) }
            }
            .buttonStyle(.bordered)
        }
    }

    private var quickExpenseCard: some View {
        OporaCard("Быстрый расход", systemImage: "plus.circle.fill") {
            HStack {
                TextField("Сумма", text: $quickExpenseAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Picker("Категория", selection: $quickExpenseCategory) {
                    ForEach(QuickExpenseCategory.defaults) { category in
                        Text("\(category.emoji) \(category.title)").tag(category.title)
                    }
                }
            }

            Button("Записать") {
                guard let decimal = Decimal(string: quickExpenseAmount.replacingOccurrences(of: ",", with: ".")) else { return }
                Task {
                    await appState.createExpense(amount: decimal, category: quickExpenseCategory, description: quickExpenseCategory)
                    quickExpenseAmount = ""
                }
            }
            .buttonStyle(.borderedProminent)

            Text("Сегодня: \(format(appState.todaySnapshot.spentToday)) UAH")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var familyStatusCard: some View {
        OporaCard("Домой без исчезновения", systemImage: "house.fill") {
            Text("Если есть рабочий хвост — назови его спокойно.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Button("🟢 Зелёный") {}
                    .buttonStyle(.bordered)
                Button("🟡 40 мин") {}
                    .buttonStyle(.bordered)
                Button("🔴 90 мин") {}
                    .buttonStyle(.bordered)
            }
        }
    }

    private var goalCard: some View {
        OporaCard("Активный маяк", systemImage: "target") {
            Text(appState.todaySnapshot.activeGoal)
                .font(.body)
            Text(appState.todaySnapshot.phrase)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func errorCard(_ error: String) -> some View {
        OporaCard("Ошибка", systemImage: "exclamationmark.triangle.fill") {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private func messageCard(_ message: String) -> some View {
        OporaCard("Ответ", systemImage: "checkmark.circle.fill") {
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }
}

#Preview {
    TodayView()
        .environmentObject(AppState())
}
