import SwiftUI

struct HabitsView: View {
    @State private var morningDone = false
    @State private var eveningDone = false
    @State private var voiceDone = false
    @State private var lookDone = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Сегодня") {
                    Toggle("☀️ Утренний ритуал", isOn: $morningDone)
                    Toggle("🌙 Вечерний разбор", isOn: $eveningDone)
                    Toggle("🎙 Голос", isOn: $voiceDone)
                    Toggle("👕 Образ", isOn: $lookDone)
                }

                Section("Статистика") {
                    LabeledContent("Утро", value: "0 / 30")
                    LabeledContent("Вечер", value: "0 / 30")
                    LabeledContent("Голос", value: "0 практик")
                    LabeledContent("Финансы", value: "0 / 30 дней")
                }

                Section("Фраза") {
                    Text("Не ищем идеальность. Строим повторяемость.")
                }
            }
            .navigationTitle("Привычки")
        }
    }
}

#Preview {
    HabitsView()
}
