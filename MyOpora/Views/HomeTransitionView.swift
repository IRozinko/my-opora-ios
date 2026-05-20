import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HomeTransitionView: View {
    @State private var selectedStatus: HomeStatus = .yellow
    @State private var minutes = "40"
    @State private var customNote = ""
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    statusCard
                    messageCard
                    rulesCard
                }
                .padding(16)
            }
            .navigationTitle("Домой")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerCard: some View {
        OporaCard("Переход из работы домой", systemImage: "figure.walk.arrival") {
            Text("Цель — не исчезать и не приносить домой рабочий пожар молча.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Назови состояние коротко, спокойно и заранее.")
                .font(.headline)
        }
    }

    private var statusCard: some View {
        OporaCard("Статус вечера", systemImage: "trafficlight.fill") {
            Picker("Статус", selection: $selectedStatus) {
                ForEach(HomeStatus.allCases) { status in
                    Text("\(status.emoji) \(status.title)").tag(status)
                }
            }
            .pickerStyle(.segmented)

            if selectedStatus != .green {
                TextField("Сколько минут нужно", text: $minutes)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Дополнительно, если нужно", text: $customNote, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var messageCard: some View {
        OporaCard("Сообщение жене", systemImage: "message.fill") {
            Text(generatedMessage)
                .font(.body)
                .textSelection(.enabled)

            Button(copied ? "Скопировано" : "Скопировать сообщение") {
                copy(generatedMessage)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copied = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var rulesCard: some View {
        OporaCard("Правила", systemImage: "heart.text.square.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("• Не молчать до последнего.")
                Text("• Не превращать рабочий хвост в семейный туман.")
                Text("• Если просишь время — потом реально вернуться в семью.")
                Text("• Семья — причина, а не плата за успех.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var generatedMessage: String {
        var text = selectedStatus.message(minutes: minutes)
        if !customNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text += "\n\n" + customNote.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
}

enum HomeStatus: String, CaseIterable, Identifiable {
    case green
    case yellow
    case red

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .green: return "🟢"
        case .yellow: return "🟡"
        case .red: return "🔴"
        }
    }

    var title: String {
        switch self {
        case .green: return "Зелёный"
        case .yellow: return "Жёлтый"
        case .red: return "Красный"
        }
    }

    func message(minutes: String) -> String {
        let cleanMinutes = minutes.isEmpty ? "40" : minutes

        switch self {
        case .green:
            return "Еду. Сегодня без рабочих хвостов, дома нормально включаюсь."
        case .yellow:
            return "Еду. Сегодня жёлтый: нужно примерно \(cleanMinutes) минут закрыть задачу по работе. Я понимаю, что ты тоже устала. Дома спокойно договоримся, я закрываю хвост и потом включаюсь в семью."
        case .red:
            return "Еду. Сегодня красный: нужно примерно \(cleanMinutes) минут закрыть критичную задачу. Я понимаю, что ты тоже устала. Давай дома спокойно договоримся: после этого беру на себя дочку/купание/укладывание или другой кусок быта."
        }
    }
}

#Preview {
    HomeTransitionView()
}
