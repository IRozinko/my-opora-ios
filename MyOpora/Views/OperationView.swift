import SwiftUI

struct OperationView: View {
    private let phases: [OperationPhase] = OperationPhase.defaults
    private let redLines: [String] = [
        "Что ломает семью — сразу мимо.",
        "Повышенная нагрузка — максимум как временная операция, не новый образ жизни.",
        "Деньги должны покупать безопасность, а не отнимать жизнь.",
        "Здоровье и сон — не расходник для чужих проектов.",
        "Northbridge строится как система, а не как ещё одна работа на 24/7."
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    phasesCard
                    redLinesCard
                    northbridgeCard
                }
                .padding(16)
            }
            .navigationTitle("Операция")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerCard: some View {
        OporaCard("Выход из режима выживания", systemImage: "shield.lefthalf.filled") {
            Text("Срок: до 6 месяцев повышенной нагрузки")
                .font(.headline)
            Text("Цель — не пахать ради пахоты, а построить базу, резерв и систему дохода, где опыт работает дороже.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var phasesCard: some View {
        OporaCard("Фазы", systemImage: "list.bullet.rectangle.fill") {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(phases) { phase in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(phase.emoji)
                            Text(phase.title)
                                .font(.headline)
                            Spacer()
                            Text(phase.status)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                        }
                        Text(phase.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if phase.id != phases.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    private var redLinesCard: some View {
        OporaCard("Красные линии", systemImage: "exclamationmark.octagon.fill") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(redLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(line)
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    private var northbridgeCard: some View {
        OporaCard("Northbridge", systemImage: "building.2.crop.circle.fill") {
            Text("Resilience сначала дома. Потом в бизнесе.")
                .font(.headline)
            Text("Dou Days, outreach, advisory, первые paid diagnostics и будущий Northbridge Group — это один стратегический контур, а не хаотичные попытки заработать ещё немного.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct OperationPhase: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let description: String
    let status: String

    static let defaults: [OperationPhase] = [
        .init(emoji: "💳", title: "Закрыть уязвимости", description: "Кредитки, обязательные платежи, хаотичные расходы. Сначала убираем угрозы системе.", status: "сейчас"),
        .init(emoji: "🛡", title: "Собрать резерв", description: "Минимум 300 000 грн, потом 500 000 грн, дальше 6–12 месяцев расходов.", status: "следом"),
        .init(emoji: "💼", title: "Стабилизировать доход", description: "Сильный оффер/контракт + страховочные источники без превращения жизни в 24/7 пожар.", status: "в работе"),
        .init(emoji: "🌉", title: "Northbridge", description: "Упаковать опыт в advisory/productized service, где продаётся риск-снижение, а не просто часы.", status: "строим"),
        .init(emoji: "🏡", title: "Семейная база", description: "Дом, машина без кредита, фонды детей, третий ребёнок, спокойная инфраструктура семьи.", status: "горизонт")
    ]
}

#Preview {
    OperationView()
}
