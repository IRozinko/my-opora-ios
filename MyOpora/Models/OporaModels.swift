import Foundation

enum NerveStatus: String, CaseIterable, Identifiable {
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

struct TodaySnapshot: Identifiable {
    let id = UUID()
    var focus: String
    var spentToday: Decimal
    var currency: String
    var morningDone: Bool
    var eveningDone: Bool
    var activeGoal: String

    static let mock = TodaySnapshot(
        focus: "Доехать, зайти спокойно, собрать контакты",
        spentToday: 0,
        currency: "UAH",
        morningDone: false,
        eveningDone: false,
        activeGoal: "Операция: выход из режима выживания"
    )
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

struct GoalItem: Identifiable {
    let id = UUID()
    let title: String
    let current: Decimal
    let target: Decimal
    let emoji: String

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(truncating: current as NSNumber) / Double(truncating: target as NSNumber), 1)
    }

    static let mock: [GoalItem] = [
        .init(title: "Кредитки в ноль", current: 0, target: 140_000, emoji: "💳"),
        .init(title: "Минимальный резерв", current: 0, target: 300_000, emoji: "🛡"),
        .init(title: "Новая машина", current: 0, target: 2_500_000, emoji: "🚙"),
        .init(title: "Дом", current: 0, target: 5_000_000, emoji: "🏡")
    ]
}
