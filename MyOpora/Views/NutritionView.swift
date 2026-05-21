import SwiftUI

struct NutritionView: View {
    @State private var selectedMeal: MealType = .breakfast
    @State private var selectedMode: MealMode = .balanced
    @State private var selectedIdea: MealIdea? = nil
    @State private var ateNormally = false
    @State private var waterDone = false
    @State private var supplementsDone = Set<Int>()
    @State private var supplementPlans = SupplementPlan.defaultPlans

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    mealSelectorCard
                    mealIdeaCard
                    todayBasicsCard
                    supplementPlanCard
                    supplementSafetyCard
                    rulesCard
                }
                .padding(16)
            }
            .navigationTitle("Питание")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerCard: some View {
        OporaCard("Еда без хаоса", systemImage: "fork.knife.circle.fill") {
            Text("Не строим идеальный бодибилдерский рацион с понедельника. Строим систему, где ты не работаешь на кофе и злости.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Белок + нормальная еда + вода + без самобичевания.")
                .font(.headline)
        }
    }

    private var mealSelectorCard: some View {
        OporaCard("Идея еды", systemImage: "lightbulb.fill") {
            Picker("Приём пищи", selection: $selectedMeal) {
                ForEach(MealType.allCases) { meal in
                    Text("\(meal.emoji) \(meal.title)").tag(meal)
                }
            }

            Picker("Режим", selection: $selectedMode) {
                ForEach(MealMode.allCases) { mode in
                    Text("\(mode.emoji) \(mode.title)").tag(mode)
                }
            }

            Button("Дай идею на сейчас") {
                selectedIdea = MealIdea.pick(meal: selectedMeal, mode: selectedMode)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var mealIdeaCard: some View {
        OporaCard(selectedIdea?.title ?? "Вариант на сейчас", systemImage: "takeoutbag.and.cup.and.straw.fill") {
            if let selectedIdea {
                VStack(alignment: .leading, spacing: 10) {
                    Text(selectedIdea.description)
                        .font(.body)
                    Text(selectedIdea.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Выбери приём пищи и режим, потом нажми кнопку. Опора подскажет простой вариант без кулинарного героизма.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var todayBasicsCard: some View {
        OporaCard("Сегодня", systemImage: "checkmark.circle.fill") {
            Toggle("Я поел нормально", isOn: $ateNormally)
            Toggle("Вода была", isOn: $waterDone)

            Button("*тык ложкой*") {
                selectedIdea = MealIdea(
                    title: "Проверка ложкой",
                    description: "Ты ел нормальную еду или опять работаешь на кофе и злости?",
                    note: "Сначала еда и вода. Потом великие стратегические решения."
                )
            }
            .buttonStyle(.bordered)
        }
    }

    private var supplementPlanCard: some View {
        OporaCard("Витамины / добавки", systemImage: "pills.fill") {
            Text("Это не назначения. Это карточки режима: что, когда, сколько, почему и до какой даты. Реальные дозировки потом заполним по анализам/врачу.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(supplementPlans) { plan in
                    supplementRow(plan)
                    if plan.id != supplementPlans.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    private func supplementRow(_ plan: SupplementPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(plan.slot.emoji)
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                    Text("\(plan.dosage) • \(plan.slot.title) • \(plan.withFood ? "с едой" : "по инструкции")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { supplementsDone.contains(plan.id) },
                    set: { isOn in
                        if isOn { supplementsDone.insert(plan.id) } else { supplementsDone.remove(plan.id) }
                    }
                ))
                .labelsHidden()
            }

            Text(plan.reason)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Курс: \(plan.course)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var supplementSafetyCard: some View {
        OporaCard("Безопасность добавок", systemImage: "cross.case.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("• Новые добавки — только осознанно, лучше после анализов.")
                Text("• Высокие дозировки — не без врача.")
                Text("• Если появилась странная реакция — пауза и записать симптом.")
                Text("• Не лечим тревогу покупкой баночек.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var rulesCard: some View {
        OporaCard("Правила", systemImage: "heart.text.square.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("• Белок в каждом основном приёме пищи.")
                Text("• Еда — топливо для системы, не награда и не наказание.")
                Text("• После зала — белок + углеводы, а не только героизм.")
                Text("• Если нет сил готовить — выбираем простой нормальный вариант, не мусор.")
                Text("• Новые добавки и высокие дозировки — не без врача/анализов.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack
    case afterWorkout

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .breakfast: return "🍳"
        case .lunch: return "🍲"
        case .dinner: return "🥗"
        case .snack: return "🍎"
        case .afterWorkout: return "🏋️"
        }
    }

    var title: String {
        switch self {
        case .breakfast: return "Завтрак"
        case .lunch: return "Обед"
        case .dinner: return "Ужин"
        case .snack: return "Перекус"
        case .afterWorkout: return "После зала"
        }
    }
}

enum MealMode: String, CaseIterable, Identifiable {
    case balanced
    case fast
    case noCooking
    case family
    case light
    case highProtein

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .balanced: return "⚖️"
        case .fast: return "⚡️"
        case .noCooking: return "🥡"
        case .family: return "👨‍👩‍👧‍👦"
        case .light: return "🌙"
        case .highProtein: return "🥩"
        }
    }

    var title: String {
        switch self {
        case .balanced: return "Сбалансировано"
        case .fast: return "Быстро"
        case .noCooking: return "Без готовки"
        case .family: return "Семейно"
        case .light: return "Легко"
        case .highProtein: return "Белково"
        }
    }
}

struct MealIdea: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let note: String

    static func pick(meal: MealType, mode: MealMode) -> MealIdea {
        switch (meal, mode) {
        case (.breakfast, .fast), (.breakfast, .balanced):
            return .init(title: "Омлет + овощи", description: "2–3 яйца, овощи, кусок хлеба/тост, чай/кофе после еды.", note: "Быстро, белково, без утреннего хаоса.")
        case (.breakfast, .noCooking):
            return .init(title: "Творог/йогурт + ягоды", description: "Творог или греческий йогурт, ягоды/банан, немного орехов.", note: "Хорошо, когда нет ресурса готовить.")
        case (.lunch, .noCooking):
            return .init(title: "Нормальная доставка", description: "Курица/индейка/рыба + крупа/картофель + овощи. Не бургер как аварийное питание.", note: "Доставка может быть инструментом, если она снижает хаос, а не добавляет его.")
        case (.lunch, _):
            return .init(title: "Белок + гарнир + овощи", description: "Курица/говядина/рыба, гречка/рис/картофель, салат или овощи.", note: "Базовый рабочий обед без кулинарного подвига.")
        case (.dinner, .light):
            return .init(title: "Лёгкий белковый ужин", description: "Рыба/курица/творог + овощи. Без тяжёлого дожора перед сном.", note: "Цель — лечь спать человеком, а не контейнером еды.")
        case (.dinner, .family):
            return .init(title: "Семейный ужин без хаоса", description: "Общее блюдо: мясо/рыба + гарнир + овощи. Без трёх разных меню, если можно проще.", note: "Разгружаем жену и не превращаем ужин в проект.")
        case (.afterWorkout, _):
            return .init(title: "После зала", description: "Белок + углеводы: мясо/рыба/яйца/творог + рис/гречка/картофель/фрукты.", note: "После тренировки не геройствуем. Восстановление — часть прогресса.")
        case (.snack, .highProtein):
            return .init(title: "Белковый перекус", description: "Йогурт/творог/сыр/яйца/протеиновый вариант, плюс фрукт при необходимости.", note: "Лучше так, чем кофе и злость.")
        case (.snack, _):
            return .init(title: "Простой перекус", description: "Фрукт + йогурт/сыр/орехи. Не идеал, но система держится.", note: "Перекус не должен превращаться в пакет печенья на автомате.")
        default:
            return .init(title: "Простая нормальная еда", description: "Белок + овощи + понятный гарнир. Без героизма и без мусорного хаоса.", note: "Если сомневаешься — выбирай самый простой нормальный вариант.")
        }
    }
}

enum SupplementSlot: String, CaseIterable, Identifiable, Hashable {
    case morning
    case lunch
    case evening

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .lunch: return "☀️"
        case .evening: return "🌙"
        }
    }

    var title: String {
        switch self {
        case .morning: return "Утро"
        case .lunch: return "День"
        case .evening: return "Вечер"
        }
    }
}

struct SupplementPlan: Identifiable {
    let id: Int
    let name: String
    let dosage: String
    let slot: SupplementSlot
    let withFood: Bool
    let course: String
    let reason: String
    let status: SupplementStatus

    static let defaultPlans: [SupplementPlan] = [
        .init(id: 1, name: "Добавка 1", dosage: "дозировку заполнить", slot: .morning, withFood: true, course: "до даты / по назначению", reason: "причина: анализы / врач / цель", status: .active),
        .init(id: 2, name: "Добавка 2", dosage: "дозировку заполнить", slot: .lunch, withFood: true, course: "до даты / по назначению", reason: "причина: анализы / врач / цель", status: .active),
        .init(id: 3, name: "Добавка 3", dosage: "дозировку заполнить", slot: .evening, withFood: false, course: "до даты / по назначению", reason: "причина: анализы / врач / цель", status: .paused)
    ]
}

enum SupplementStatus: String {
    case active
    case paused
    case completed
}

#Preview {
    NutritionView()
}
