import Foundation

enum NerveStatus: String, CaseIterable, Identifiable, Codable {
    case green
    case yellow
    case red

    var id: String { rawValue }

    var title: String {
        switch self {
        case .green: return "Живой"
        case .yellow: return "Квадратная голова"
        case .red: return "Потыкали палкой"
        }
    }

    var emoji: String {
        switch self {
        case .green: return "🟢"
        case .yellow: return "🟡"
        case .red: return "🔴"
        }
    }

    var recommendation: String {
        switch self {
        case .green:
            return "Один главный фокус. Не распыляться."
        case .yellow:
            return "Только механические задачи, вода, чай, без героизма."
        case .red:
            return "Не принимать больших решений. Еда, вода, тишина, домой при возможности."
        }
    }
}

struct TodaySnapshot: Identifiable, Codable {
    let id = UUID()
    var date: String
    var focus: String
    var morningDone: Bool
    var eveningDone: Bool
    var spentToday: Decimal
    var monthExpenses: Decimal
    var monthIncome: Decimal
    var debts: [DebtItem]
    var goals: [GoalItem]
    var phrase: String

    enum CodingKeys: String, CodingKey {
        case date, focus, morningDone, eveningDone, spentToday, monthExpenses, monthIncome, debts, goals, phrase
    }

    var currency: String { "UAH" }
    var activeGoal: String { goals.first?.title ?? "Операция: выход из режима выживания" }

    static let mock = TodaySnapshot(
        date: "today",
        focus: "Доехать, зайти спокойно, собрать контакты",
        morningDone: false,
        eveningDone: false,
        spentToday: 0,
        monthExpenses: 0,
        monthIncome: 0,
        debts: DebtItem.mock,
        goals: GoalItem.mock,
        phrase: "Я не выхожу из финансовой ямы ценой семьи."
    )
}

struct FinanceSummary: Codable {
    var monthIncome: Decimal
    var monthExpenses: Decimal
    var budgets: [BudgetItem]
    var debts: [DebtItem]
    var goals: [GoalItem]

    static let mock = FinanceSummary(
        monthIncome: 0,
        monthExpenses: 0,
        budgets: [],
        debts: DebtItem.mock,
        goals: GoalItem.mock
    )
}

struct BudgetItem: Identifiable, Codable {
    let id: Int
    let category: String
    let monthlyLimit: Decimal
    let currency: String
}

struct DebtItem: Identifiable, Codable {
    let id: Int
    let name: String
    let remainingAmount: Decimal
    let monthlyPayment: Decimal

    static let mock: [DebtItem] = [
        .init(id: 1, name: "Кредитка 1", remainingAmount: 70_000, monthlyPayment: 4_000),
        .init(id: 2, name: "Кредитка 2", remainingAmount: 70_000, monthlyPayment: 4_000)
    ]
}

struct QuickExpenseCategory: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String

    static let defaults: [QuickExpenseCategory] = [
        .init(title: "Кофе", emoji: "☕️"),
        .init(title: "Коммуналка", emoji: "🏠"),
        .init(title: "Safe food сына", emoji: "🧒"),
        .init(title: "Такси", emoji: "🚕"),
        .init(title: "Рыбалка", emoji: "🎣"),
        .init(title: "Медицина", emoji: "💊"),
        .init(title: "Одежда", emoji: "👕"),
        .init(title: "Прочее", emoji: "🧾")
    ]
}

struct GoalItem: Identifiable, Codable {
    let id: Int
    let name: String
    let targetAmount: Decimal
    let currentAmount: Decimal
    let status: String?
    let priority: Int?

    var title: String { name }

    var emoji: String {
        let lower = name.lowercased()
        if lower.contains("кредит") { return "💳" }
        if lower.contains("резерв") { return "🛡" }
        if lower.contains("авто") || lower.contains("машин") { return "🚙" }
        if lower.contains("дом") { return "🏡" }
        return "🎯"
    }

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(truncating: currentAmount as NSNumber) / Double(truncating: targetAmount as NSNumber), 1)
    }

    static let mock: [GoalItem] = [
        .init(id: 1, name: "Кредитки в ноль", targetAmount: 140_000, currentAmount: 0, status: "active", priority: 0),
        .init(id: 2, name: "Минимальный резерв", targetAmount: 300_000, currentAmount: 0, status: "active", priority: 1),
        .init(id: 3, name: "Новая машина", targetAmount: 2_500_000, currentAmount: 0, status: "paused", priority: 3),
        .init(id: 4, name: "Дом", targetAmount: 5_000_000, currentAmount: 0, status: "paused", priority: 4)
    ]
}

struct ApiMessageResponse: Codable {
    let ok: Bool
    let message: String
}
