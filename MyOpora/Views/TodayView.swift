import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @State private var snapshot = TodaySnapshot.mock
    @State private var focusText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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

            Text(appState.selectedNerveStatus.recommendation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Проверка палкой") {
                appState.selectedNerveStatus = .yellow
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var morningCard: some View {
        OporaCard("Утро", systemImage: "sun.max.fill") {
            HStack {
                Image(systemName: snapshot.morningDone ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading) {
                    Text(snapshot.morningDone ? "Утро отмечено" : "Отметить утро")
                    Text("Вода, лицо, одежда, голос, один фокус")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            TextField("Фокус дня", text: $focusText)
                .textFieldStyle(.roundedBorder)

            Button("Отметить morning") {
                snapshot.morningDone = true
                if !focusText.isEmpty { snapshot.focus = focusText }
            }
            .buttonStyle(.bordered)
        }
    }

    private var quickExpenseCard: some View {
        OporaCard("Быстрый расход", systemImage: "plus.circle.fill") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                ForEach(QuickExpenseCategory.defaults) { category in
                    Button("\(category.emoji) \(category.title)") {
                        // MVP: real form/API later
                    }
                    .buttonStyle(.bordered)
                }
            }
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
            Text(snapshot.activeGoal)
                .font(.body)
            Text("Не выходим из финансовой ямы ценой семьи.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(AppState())
}
