import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Backend") {
                    Toggle("Mock mode", isOn: $appState.isMockMode)
                    TextField("API base URL", text: $appState.apiBaseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                Section("Связка с Telegram") {
                    Text("MVP-схема: приложение покажет код, а в Telegram нужно будет отправить /link <код>.")
                        .font(.subheadline)
                    Button("Сгенерировать link code") {}
                }

                Section("Напоминания") {
                    Toggle("Утро", isOn: .constant(true))
                    Toggle("Проверка палкой", isOn: .constant(true))
                    Toggle("Вечерний разбор", isOn: .constant(true))
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
