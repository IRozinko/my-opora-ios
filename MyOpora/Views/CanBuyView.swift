import SwiftUI

struct CanBuyView: View {
    @State private var amount = ""
    @State private var purchase = ""
    @State private var selectedType: PurchaseType = .personal
    @State private var result: PurchaseDecision? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    inputCard
                    if let result {
                        resultCard(result)
                    }
                    rulesCard
                    categoriesCard
                }
                .padding(16)
            }
            .navigationTitle("Can Buy?")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerCard: some View {
        OporaCard("Проверка покупки", systemImage: "cart.badge.questionmark") {
            Text("Не запрещаем жизнь. Охлаждаем хаос.")
                .font(.headline)
            Text("Быстро проверь покупку через фильтр: кредитки, резерв, семья, здоровье, работа, восстановление.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var inputCard: some View {
        OporaCard("Что хочешь купить?", systemImage: "creditcard.fill") {
            TextField("Сумма, грн", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            TextField("Покупка", text: $purchase)
                .textFieldStyle(.roundedBorder)

            Picker("Тип", selection: $selectedType) {
                ForEach(PurchaseType.allCases) { type in
                    Text("\(type.emoji) \(type.title)").tag(type)
                }
            }

            Button("Проверить") {
                result = PurchaseDecision.evaluate(
                    amountText: amount,
                    purchase: purchase,
                    type: selectedType
                )
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func resultCard(_ decision: PurchaseDecision) -> some View {
        OporaCard(decision.title, systemImage: decision.systemImage) {
            Text(decision.verdict)
                .font(.title3)
                .fontWeight(.semibold)

            Text(decision.explanation)
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            Text(decision.nextStep)
                .font(.subheadline)
        }
    }

    private var rulesCard: some View {
        OporaCard("Фильтры Опоры", systemImage: "line.3.horizontal.decrease.circle.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Закрытие кредиток важнее хотелок.")
                Text("2. Семейная разгрузка — не просто расход.")
                Text("3. Здоровье, сон, работа и восстановление — инвестиции, если без хаоса.")
                Text("4. Если покупка делается из тревоги — пауза 24 часа.")
                Text("5. Если стыдно записать расход — это красный флаг.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var categoriesCard: some View {
        OporaCard("Быстрая логика", systemImage: "brain.head.profile") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(PurchaseType.allCases) { type in
                    HStack(alignment: .top) {
                        Text(type.emoji)
                        VStack(alignment: .leading) {
                            Text(type.title)
                                .font(.headline)
                            Text(type.hint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

enum PurchaseType: String, CaseIterable, Identifiable {
    case family
    case health
    case work
    case recovery
    case personal
    case impulse

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .family: return "👨‍👩‍👧‍👦"
        case .health: return "💊"
        case .work: return "💼"
        case .recovery: return "🌿"
        case .personal: return "🙂"
        case .impulse: return "⚡️"
        }
    }

    var title: String {
        switch self {
        case .family: return "Семья"
        case .health: return "Здоровье"
        case .work: return "Работа/доход"
        case .recovery: return "Восстановление"
        case .personal: return "Личное"
        case .impulse: return "Импульс"
        }
    }

    var hint: String {
        switch self {
        case .family: return "Если разгружает жену/детей/быт — часто можно, но записать и держать лимит."
        case .health: return "Не экономить на реальном здоровье, но без аптечного хаоса."
        case .work: return "Если помогает зарабатывать или не тормозит работу — можно планировать."
        case .recovery: return "Рыбалка, природа, сон, спорт — не баловство, если не ломает бюджет."
        case .personal: return "Можно, если не из тревоги и не вместо кредиток/резерва."
        case .impulse: return "Пауза 24 часа. Особенно ночью, после стресса или усталости."
        }
    }
}

struct PurchaseDecision {
    let title: String
    let systemImage: String
    let verdict: String
    let explanation: String
    let nextStep: String

    static func evaluate(amountText: String, purchase: String, type: PurchaseType) -> PurchaseDecision {
        let normalizedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        let amount = Decimal(string: normalizedAmount) ?? 0
        let amountNumber = NSDecimalNumber(decimal: amount).doubleValue
        let cleanPurchase = purchase.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = cleanPurchase.isEmpty ? "покупка" : cleanPurchase

        if amount <= 0 {
            return .init(
                title: "Нужна сумма",
                systemImage: "questionmark.circle.fill",
                verdict: "Сначала введи сумму",
                explanation: "Опора не может охладить хаос, если не видит размер покупки.",
                nextStep: "Введи сумму и нажми “Проверить”."
            )
        }

        if type == .impulse {
            return .init(
                title: "Охладить",
                systemImage: "pause.circle.fill",
                verdict: "Пауза 24 часа",
                explanation: "\(name) выглядит как импульсная покупка. Это не запрет, а защита от покупки из усталости, злости или тревоги.",
                nextStep: "Запиши в wishlist. Если завтра всё ещё нужно — вернись к решению."
            )
        }

        if type == .family && amountNumber <= 10_000 {
            return .init(
                title: "Можно планово",
                systemImage: "checkmark.seal.fill",
                verdict: "Скорее можно",
                explanation: "\(name) относится к семье/быту. Если это реально разгружает жену, детей или дом — это не просто расход, а снижение хаоса.",
                nextStep: "Запиши расход и не смешивай с хаотичными доставками."
            )
        }

        if type == .health && amountNumber <= 15_000 {
            return .init(
                title: "Здоровье в приоритете",
                systemImage: "heart.fill",
                verdict: "Можно, если это реальная потребность",
                explanation: "\(name) связано со здоровьем. Тут не играем в героизм, но фиксируем сумму и не превращаем аптеку в тревожный шопинг.",
                nextStep: "Если есть сомнения — уточнить у врача/специалиста. Расход записать."
            )
        }

        if type == .work && amountNumber <= 25_000 {
            return .init(
                title: "Инвестиция в доход",
                systemImage: "briefcase.fill",
                verdict: "Можно планировать",
                explanation: "\(name) может быть рабочим инструментом. Если оно ускоряет работу, качество созвонов, фокус или доход — это не обычная хотелка.",
                nextStep: "Проверь: окупается ли это через доход/эффективность за 1–3 месяца?"
            )
        }

        if type == .recovery && amountNumber <= 8_000 {
            return .init(
                title: "Восстановление — часть системы",
                systemImage: "leaf.fill",
                verdict: "Можно, если не ломает бюджет",
                explanation: "\(name) относится к восстановлению. Для тебя это важно: рыбалка, природа, спорт и тишина помогают не превращаться в камень.",
                nextStep: "Запиши как восстановление, а не как “стыдную трату”."
            )
        }

        if amountNumber >= 20_000 {
            return .init(
                title: "Большая покупка",
                systemImage: "exclamationmark.triangle.fill",
                verdict: "Охладить и запланировать",
                explanation: "\(name) — уже заметная сумма. Пока кредитки/резерв не закрыты, такие покупки должны проходить через паузу и план.",
                nextStep: "Пауза 48 часов. Потом решить: сейчас, в фонд, после кредиток или после резерва."
            )
        }

        if amountNumber <= 2_000 {
            return .init(
                title: "Мелкая покупка",
                systemImage: "checkmark.circle.fill",
                verdict: "Можно, но записать",
                explanation: "\(name) не выглядит опасно по сумме. Главный риск — не сумма, а привычка не фиксировать мелочи.",
                nextStep: "Покупаешь — сразу записываешь расход."
            )
        }

        return .init(
            title: "Нейтрально",
            systemImage: "scale.3d",
            verdict: "Можно после короткой паузы",
            explanation: "\(name) не выглядит критичной, но и не является обязательной. Тут важно не покупать из усталости.",
            nextStep: "Подожди 30 минут. Если всё ещё надо — покупка ок, но расход записать."
        )
    }
}

#Preview {
    CanBuyView()
}
