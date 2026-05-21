import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var apiBaseURL: String = "" {
        didSet { UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL") }
    }

    @Published var telegramId: String = "" {
        didSet { UserDefaults.standard.set(telegramId, forKey: "telegramId") }
    }

    @Published var apiToken: String = "" {
        didSet { UserDefaults.standard.set(apiToken, forKey: "apiToken") }
    }

    @Published var currentLinkCode: String? = nil
    @Published var currentLinkInstruction: String? = nil

    @Published var isMockMode: Bool = true {
        didSet { UserDefaults.standard.set(isMockMode, forKey: "isMockMode") }
    }

    @Published var pokeNotificationsEnabled: Bool = false {
        didSet { UserDefaults.standard.set(pokeNotificationsEnabled, forKey: "pokeNotificationsEnabled") }
    }

    @Published var ruthlessPokeMode: Bool = false {
        didSet { UserDefaults.standard.set(ruthlessPokeMode, forKey: "ruthlessPokeMode") }
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
        self.apiToken = UserDefaults.standard.string(forKey: "apiToken") ?? ""
        self.isMockMode = UserDefaults.standard.object(forKey: "isMockMode") as? Bool ?? true
        self.pokeNotificationsEnabled = UserDefaults.standard.object(forKey: "pokeNotificationsEnabled") as? Bool ?? false
        self.ruthlessPokeMode = UserDefaults.standard.object(forKey: "ruthlessPokeMode") as? Bool ?? false
    }

    var apiClient: OporaApiClient {
        OporaApiClient(baseURLString: apiBaseURL, telegramId: telegramId, apiToken: apiToken)
    }

    var isLinkedWithTelegram: Bool {
        !apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func refreshAll() async {
        await refreshToday()
        await refreshFinance()
    }

    func enablePokeNotifications() async {
        await runApiAction {
            let mode: PokeMode = ruthlessPokeMode ? .ruthless : .humane
            try await NotificationService.shared.scheduleDefaultPokeNotifications(mode: mode)
            pokeNotificationsEnabled = true
            lastMessage = ruthlessPokeMode ? "Режим без гуманности включен. Кроссовок заряжен." : "Проверка палкой по крону включена."
        }
    }

    func disablePokeNotifications() {
        NotificationService.shared.cancelPokeNotifications()
        pokeNotificationsEnabled = false
        lastMessage = "Проверка палкой по крону выключена."
    }

    func setRuthlessPokeMode(_ enabled: Bool) async {
        ruthlessPokeMode = enabled
        if pokeNotificationsEnabled {
            await enablePokeNotifications()
        }
    }

    func createTelegramLinkCode() async {
        await runApiAction {
            let response = try await apiClient.createLinkCode(deviceId: deviceId())
            currentLinkCode = response.code
            currentLinkInstruction = response.message
            lastMessage = response.message
        }
    }

    func exchangeTelegramLinkCode() async {
        guard let code = currentLinkCode else {
            lastError = "Сначала сгенерируй link code."
            return
        }

        await runApiAction {
            let response = try await apiClient.exchangeLinkCode(code)
            apiToken = response.token
            telegramId = ""
            isMockMode = false
            lastMessage = response.message
            await refreshAll()
        }
    }

    func logout() {
        apiToken = ""
        currentLinkCode = nil
        currentLinkInstruction = nil
        lastMessage = "Привязка сброшена."
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

    private func deviceId() -> String {
        if let existing = UserDefaults.standard.string(forKey: "deviceId") {
            return existing
        }

        let newValue = UUID().uuidString
        UserDefaults.standard.set(newValue, forKey: "deviceId")
        return newValue
    }
}
