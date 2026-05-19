import Foundation

enum OporaApiError: LocalizedError {
    case missingBaseURL
    case invalidBaseURL
    case missingAuth
    case invalidResponse
    case httpStatus(Int, String)

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            return "API base URL is empty. Set it in Settings."
        case .invalidBaseURL:
            return "API base URL is invalid."
        case .missingAuth:
            return "Auth is missing. Link the app with Telegram or set Telegram ID for MVP mode."
        case .invalidResponse:
            return "Invalid API response."
        case .httpStatus(let code, let body):
            return "API error \(code): \(body)"
        }
    }
}

struct OporaApiClient {
    var baseURLString: String
    var telegramId: String
    var apiToken: String

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }

    func createLinkCode(deviceId: String) async throws -> LinkCodeResponse {
        try await request(path: "/api/auth/link-code", method: "POST", body: LinkCodeRequest(deviceId: deviceId), authRequired: false)
    }

    func exchangeLinkCode(_ code: String) async throws -> TokenResponse {
        try await request(path: "/api/auth/exchange-link-code", method: "POST", body: ExchangeLinkCodeRequest(code: code), authRequired: false)
    }

    func fetchToday() async throws -> TodaySnapshot {
        try await request(path: "/api/today", method: "GET", body: Optional<String>.none)
    }

    func fetchFinanceSummary() async throws -> FinanceSummary {
        try await request(path: "/api/finance/summary", method: "GET", body: Optional<String>.none)
    }

    func createExpense(amount: Decimal, category: String, description: String?) async throws -> ApiMessageResponse {
        let body = ExpenseRequest(amount: amount, currency: "UAH", category: category, description: description)
        return try await request(path: "/api/expenses", method: "POST", body: body)
    }

    func createIncome(amount: Decimal, description: String?) async throws -> ApiMessageResponse {
        let body = IncomeRequest(amount: amount, currency: "UAH", description: description)
        return try await request(path: "/api/income", method: "POST", body: body)
    }

    func markMorning(focus: String?) async throws -> ApiMessageResponse {
        try await request(path: "/api/habits/morning", method: "POST", body: FocusRequest(focus: focus))
    }

    func markEvening(note: String?) async throws -> ApiMessageResponse {
        try await request(path: "/api/habits/evening", method: "POST", body: EveningRequest(note: note))
    }

    func updateNerveStatus(_ status: NerveStatus) async throws -> ApiMessageResponse {
        try await request(path: "/api/nerve-status", method: "POST", body: NerveStatusRequest(status: status.rawValue, note: nil))
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body?,
        authRequired: Bool = true
    ) async throws -> Response {
        guard !baseURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OporaApiError.missingBaseURL
        }
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw OporaApiError.invalidBaseURL
        }

        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authRequired {
            let cleanToken = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanTelegramId = telegramId.trimmingCharacters(in: .whitespacesAndNewlines)

            if !cleanToken.isEmpty {
                request.setValue("Bearer \(cleanToken)", forHTTPHeaderField: "Authorization")
            } else if !cleanTelegramId.isEmpty {
                request.setValue(cleanTelegramId, forHTTPHeaderField: "x-telegram-id")
            } else {
                throw OporaApiError.missingAuth
            }
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OporaApiError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            throw OporaApiError.httpStatus(httpResponse.statusCode, bodyText)
        }

        return try decoder.decode(Response.self, from: data)
    }
}

private struct LinkCodeRequest: Encodable {
    let deviceId: String
}

private struct ExchangeLinkCodeRequest: Encodable {
    let code: String
}

private struct ExpenseRequest: Encodable {
    let amount: Decimal
    let currency: String
    let category: String
    let description: String?
}

private struct IncomeRequest: Encodable {
    let amount: Decimal
    let currency: String
    let description: String?
}

private struct FocusRequest: Encodable {
    let focus: String?
}

private struct EveningRequest: Encodable {
    let note: String?
}

private struct NerveStatusRequest: Encodable {
    let status: String
    let note: String?
}
