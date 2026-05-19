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

                Section("Telegram auth") {
                    if appState.isLinkedWithTelegram {
                        Label("Приложение связано с Telegram", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Button("Сбросить привязку", role: .destructive) {
                            appState.logout()
                        }
                    } else {
                        Text("1. Сгенерируй код.\n2. Отправь его Telegram-боту командой /link <код>.\n3. Вернись сюда и нажми “Проверить привязку”.")
                            .font(.subheadline)

                        if let code = appState.currentLinkCode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(code)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .textSelection(.enabled)
                                Text("/link \(code)")
                                    .font(.headline)
                                    .textSelection(.enabled)
                            }
                        }

                        Button("Сгенерировать link code") {
                            Task { await appState.createTelegramLinkCode() }
                        }

                        Button("Проверить привязку") {
                            Task { await appState.exchangeTelegramLinkCode() }
                        }
                        .disabled(appState.currentLinkCode == nil)
                    }
                }

                Section("MVP fallback") {
                    TextField("Telegram ID вручную", text: $appState.telegramId)
                        .keyboardType(.numberPad)
                    Text("Это запасной режим для теста. Основной сценарий — Telegram auth через /link.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let error = appState.lastError {
                    Section("Ошибка") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                if let message = appState.lastMessage {
                    Section("Сообщение") {
                        Text(message)
                            .font(.caption)
                    }
                }

                Section("Напоминания") {
                    Toggle("Утро", isOn: .constant(true))
                    Toggle("Проверка палкой", isOn: .constant(true))
                    Toggle("Вечерний разбор", isOn: .constant(true))
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                if appState.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
