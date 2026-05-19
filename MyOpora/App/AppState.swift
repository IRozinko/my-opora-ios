import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var apiBaseURL: String = "" {
        didSet { UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL") }
    }

    @Published var telegramId: String = "" {
        didSet { UserDefaults.standard.set(telegramId, forKey: "telegramId") }
    }

    @Published var isMockMode: Bool = true {
        didSet { UserDefaults.standard.set(isMockMode, forKey: "isMockMode") }
    }

    @Published var selectedNerveStatus: NerveStatus = .yellow
    @Published var todaySnapshot: TodaySnapshot = .mock
    @Published var financeSummary: FinanceSummary = .mock
    @Published var lastMessage: String?
    @Published var lastError: String?
    @Published var isLoading = false

    init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? ""
        self.telegramId = UserDefaults.standard.string(forKey: "telegramId") ?? ""
        self.isMockMode = UserDefaults.standard.object(forKey: "isMockMode") as? Bool ?? true
    }

    var apiClient: OporaApiClient {
        OporaApiClient(baseURLString: apiBaseURL, telegramId: telegramId)
    }

    func refreshAll() async {
        await refreshToday()
        await refreshFinance()
    }

    func refreshToday() async {
        guard !isMockMode else {
            todaySnapshot = .mock
            return
        }

        await runApiAction {
            todaySnapshot = try await apiClient.fetchToday()
        }
    }

    func refreshFinance() async {
        guard !isMockMode else {
            financeSummary = .mock
            return
        }

        await runApiAction {
            financeSummary = try await apiClient.fetchFinanceSummary()
        }
    }

    func createExpense(amount: Decimal, category: String, description: String?) async {
        await runApiAction {
            let response = try await apiClient.createExpense(amount: amount, category: category, description: description)
            lastMessage = response.message
            await refreshAll()
        }
    }

    func markMorning(focus: String?) async {
        await runApiAction {
            let response = try await apiClient.markMorning(focus: focus)
            lastMessage = response.message
            await refreshToday()
        }
    }

    func markEvening(note: String?) async {
        await runApiAction {
            let response = try await apiClient.markEvening(note: note)
            lastMessage = response.message
            await refreshToday()
        }
    }

    func updateNerveStatus(_ status: NerveStatus) async {
        selectedNerveStatus = status

        guard !isMockMode else { return }

        await runApiAction {
            let response = try await apiClient.updateNerveStatus(status)
            lastMessage = response.message
        }
    }

    private func runApiAction(_ action: () async throws -> Void) async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            try await action()
        } catch {
            lastError = error.localizedDescription
        }
    }
}
