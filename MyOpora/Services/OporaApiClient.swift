import Foundation

struct OporaApiClient {
    var baseURL: URL?

    func fetchToday() async throws -> TodaySnapshot {
        // MVP placeholder. Реальное API подключим после добавления endpoints в backend.
        return .mock
    }

    func createExpense(amount: Decimal, category: String, description: String?) async throws {
        // TODO: POST /api/expenses
    }

    func markMorning(focus: String?) async throws {
        // TODO: POST /api/habits/morning
    }

    func markEvening(note: String?) async throws {
        // TODO: POST /api/habits/evening
    }

    func updateNerveStatus(_ status: NerveStatus) async throws {
        // TODO: POST /api/nerve-status
    }
}
