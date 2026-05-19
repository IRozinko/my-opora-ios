import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var apiBaseURL: String = ""
    @Published var isMockMode: Bool = true
    @Published var selectedNerveStatus: NerveStatus = .yellow

    let apiClient = OporaApiClient()
}
