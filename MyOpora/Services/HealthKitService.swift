import Foundation
import HealthKit

struct StepSummary {
    let todaySteps: Int
    let sevenDayAverage: Int
    let goal: Int

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(todaySteps) / Double(goal), 1)
    }

    var status: MovementStatus {
        if todaySteps >= goal { return .green }
        if todaySteps >= 5_000 { return .yellow }
        return .red
    }

    static let mock = StepSummary(todaySteps: 3_959, sevenDayAverage: 7_029, goal: 8_000)
}

enum MovementStatus {
    case green
    case yellow
    case red

    var title: String {
        switch self {
        case .green: return "Зелёный"
        case .yellow: return "Жёлтый"
        case .red: return "Красный"
        }
    }

    var message: String {
        switch self {
        case .green:
            return "Тело включено. Не надо добивать норму любой ценой."
        case .yellow:
            return "Нормально. Ещё короткий круг — и система скажет спасибо."
        case .red:
            return "Не превращаемся в мебель. 10–15 минут прогулки уже зачёт."
        }
    }
}

@MainActor
final class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    @Published var lastSummary: StepSummary = .mock
    @Published var lastError: String?

    private let healthStore = HKHealthStore()

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.healthDataUnavailable
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.stepTypeUnavailable
        }

        try await healthStore.requestAuthorization(toShare: [], read: [stepType])
    }

    func loadStepSummary(goal: Int = 8_000) async {
        do {
            try await requestAuthorization()
            async let today = fetchSteps(from: Calendar.current.startOfDay(for: Date()), to: Date())
            async let average = fetchSevenDayAverage()

            lastSummary = StepSummary(todaySteps: try await today, sevenDayAverage: try await average, goal: goal)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func fetchSevenDayAverage() async throws -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: startOfToday) else { return 0 }

        let total = try await fetchSteps(from: sevenDaysAgo, to: now)
        return total / 7
    }

    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.stepTypeUnavailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }

            healthStore.execute(query)
        }
    }
}

enum HealthKitError: LocalizedError {
    case healthDataUnavailable
    case stepTypeUnavailable

    var errorDescription: String? {
        switch self {
        case .healthDataUnavailable:
            return "Health data is not available on this device."
        case .stepTypeUnavailable:
            return "Step count type is unavailable."
        }
    }
}
