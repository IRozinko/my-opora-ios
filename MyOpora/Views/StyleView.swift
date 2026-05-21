import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct StyleView: View {
    @State private var selectedScenario: StyleScenario = .office
    @State private var selectedMood: StyleMood = .calm
    @State private var selectedEdc: EdcMode = .minimal
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    selectorCard
                    outfitCard
                    edcCard
                    groomingCard
                    checklistCard
                    photoRulesCard
                }
                .padding(16)
            }
            .navigationTitle("Стиль")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerCard: some View {
        OporaCard("Дорогой виски", systemImage: "sparkles") {
            Text("Цель — выглядеть собранно, спокойно и взросло, без режима “что попалось из шкафа”.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Тёмная плотная база + структура сверху + чистая обувь + ухоженное лицо.")
                .font(.headline)
        }
    }

    private var selectorCard: some View {
        OporaCard("Сценарий", systemImage: "person.crop.rectangle.stack.fill") {
            Picker("Куда", selection: $selectedScenario) {
                ForEach(StyleScenario.allCases) { scenario in
                    Text("\(scenario.emoji) \(scenario.title)").tag(scenario)
                }
            }

            Picker("Настроение", selection: $selectedMood) {
                ForEach(StyleMood.allCases) { mood in
                    Text("\(mood.emoji) \(mood.title)").tag(mood)
                }
            }
        }
    }

    private var outfitCard: some View {
        OporaCard("Образ", systemImage: "tshirt.fill") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(selectedScenario.recommendations(for: selectedMood), id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                }
            }
            .font(.subheadline)

            Button(copied ? "Скопировано" : "Скопировать образ") {
                let outfit = selectedScenario.recommendations(for: selectedMood).joined(separator: "\n")
                let edc = selectedEdc.rules.joined(separator: "\n")
                copy(outfit + "\n\nEDC:\n" + edc)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var edcCard: some View {
        OporaCard("Tech / Tactical EDC", systemImage: "backpack.fill") {
            Picker("EDC-режим", selection: $selectedEdc) {
                ForEach(EdcMode.allCases) { mode in
                    Text("\(mode.emoji) \(mode.title)").tag(mode)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(selectedEdc.rules, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                }
            }
            .font(.subheadline)

            Text("Генерал Черешня, Skyfall/Vampire, Вирій — это не случайные брелки, а смысловые маркеры. Главное — не превращать рюкзак в выставку сувениров.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var groomingCard: some View {
        OporaCard("Внешний вид", systemImage: "mustache.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("• Борода: контур, шея, усы не лезут на губу.")
                Text("• Волосы: без хаоса, если торчит — вода/паста/расчёска.")
                Text("• Нос/CPAP-зона: не сдирать, аккуратно закрыть при раздражении.")
                Text("• Руки: ногти коротко, без “я только из гаража”, если не из гаража.")
                Text("• Запах: душ, дезодорант, лёгкий парфюм без атаки химоружием.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var checklistCard: some View {
        OporaCard("Перед выходом", systemImage: "checklist") {
            VStack(alignment: .leading, spacing: 10) {
                Text("☐ футболка не тянет живот")
                Text("☐ верхний слой добавляет структуру")
                Text("☐ штаны сидят по талии, не спасаются ремнём")
                Text("☐ обувь чистая")
                Text("☐ карманы не раздуты")
                Text("☐ EDC не выглядит как новогодняя ёлка")
                Text("☐ телефон / кошелёк / ключи / салфетки")
                Text("☐ лицо спокойное, не “меня добил документооборот”")
            }
            .font(.subheadline)
        }
    }

    private var photoRulesCard: some View {
        OporaCard("Фото для проверки", systemImage: "camera.fill") {
            Text("Чтобы Опора могла честно оценить образ: фото спереди, сбоку, нормальный свет, весь рост или хотя бы до колен. Без геройских ракурсов и без самоуничтожения в комментариях 😄")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
}

enum StyleScenario: String, CaseIterable, Identifiable {
    case office
    case meeting
    case family
    case weekend
    case interview
    case event
    case fishing

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .office: return "💼"
        case .meeting: return "🤝"
        case .family: return "👨‍👩‍👧‍👦"
        case .weekend: return "☕️"
        case .interview: return "🎙"
        case .event: return "🌉"
        case .fishing: return "🎣"
        }
    }

    var title: String {
        switch self {
        case .office: return "Офис"
        case .meeting: return "Встреча"
        case .family: return "Семья"
        case .weekend: return "Выходной"
        case .interview: return "Собес"
        case .event: return "Нетворкинг"
        case .fishing: return "Рыбалка"
        }
    }

    func recommendations(for mood: StyleMood) -> [String] {
        switch self {
        case .office:
            return ["Тёмная плотная футболка или поло regular fit.", "Chinos/тёмные джинсы без потертостей.", "Overshirt/лёгкая рубашка сверху, если хочется структуры.", "Чистая обувь, нормальный ремень, часы.", mood.extra]
        case .meeting:
            return ["Тёмная база без принтов.", "Сверху рубашка/overshirt/лёгкий жакет.", "Штаны без спортивного вайба.", "Минимум визуального шума: аккуратно, спокойно, уверенно.", mood.extra]
        case .family:
            return ["Комфортная, но не растянутая футболка.", "Шорты/джинсы/чиносы по погоде.", "Обувь чистая, карманы не раздуты.", "Выглядеть живым человеком, а не сбежавшим из Jira.", mood.extra]
        case .weekend:
            return ["Плотная футболка relaxed/regular fit.", "Удобные штаны, но не домашняя катастрофа.", "Лёгкая куртка/рубашка, если выходишь из дома.", "Минимум хаоса: ключи, кошелёк, салфетки.", mood.extra]
        case .interview:
            return ["Однотонная тёмная база.", "Сверху структурный слой: рубашка, overshirt или жакет.", "Камера на уровне глаз, свет спереди.", "Борода и волосы привести в порядок до созвона.", mood.extra]
        case .event:
            return ["Тёмная плотная база без натяжения на животе.", "Сверху overshirt/рубашка/лёгкий жакет для структуры.", "Чистая обувь, часы, минимальный EDC.", "Цель: дорогой виски, не случайный посетитель фудкорта.", mood.extra]
        case .fishing:
            return ["Практичная одежда по погоде.", "Слой от ветра/дождя.", "Обувь, которую не жалко, но не убитую.", "Кепка/очки/салфетки/вода.", "Фото с карпом — только как доказательство, что рыбалка была не “чисто посидеть”. Не архивно.", "Рыбалка — техобслуживание нервной системы, а не показ мод."]
        }
    }
}

enum EdcMode: String, CaseIterable, Identifiable {
    case minimal
    case techTactical
    case office
    case travel

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .minimal: return "⚫️"
        case .techTactical: return "🛠"
        case .office: return "💼"
        case .travel: return "🎒"
        }
    }

    var title: String {
        switch self {
        case .minimal: return "Минимум"
        case .techTactical: return "Tech/Tactical"
        case .office: return "Офис"
        case .travel: return "Дорога"
        }
    }

    var rules: [String] {
        switch self {
        case .minimal:
            return ["Один-два смысловых аксессуара максимум.", "Всё лишнее убрать: образ должен дышать.", "Если предмет не нужен и не имеет истории — не вешаем."]
        case .techTactical:
            return ["Один-два смысловых маркера: Вирій, Skyfall/Vampire, Генерал Черешня — ок.", "Смысл есть, клоунады нет.", "Если вещь вызывает вопрос — это conversation starter, но не рекламный стенд.", "EDC должен быть функциональным или иметь историю.", "Не превращать рюкзак в новогоднюю ёлку."]
        case .office:
            return ["Для облэнерго tech/tactical детали допустимы, если общий вид собранный.", "На официальные совещания — меньше навеса, больше структуры.", "Документы, ноут, зарядка, вода, салфетки — важнее декоративности."]
        case .travel:
            return ["Powerbank, кабель, вода, салфетки, таблетки от головы — база.", "Карабин/брелок ок, если не мешает доставать вещи.", "В дороге EDC должен помогать, а не звенеть и цепляться за всё подряд."]
        }
    }
}

enum StyleMood: String, CaseIterable, Identifiable {
    case calm
    case power
    case tired

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .calm: return "🟢"
        case .power: return "⚡️"
        case .tired: return "🟡"
        }
    }

    var title: String {
        switch self {
        case .calm: return "Спокойно"
        case .power: return "Уверенно"
        case .tired: return "Устал"
        }
    }

    var extra: String {
        switch self {
        case .calm: return "Настроение: спокойно, без попытки всем что-то доказать."
        case .power: return "Настроение: добавить структуру сверху, держать осанку, говорить медленнее."
        case .tired: return "Настроение: тёмная база, минимум решений, не экспериментировать утром."
        }
    }
}

#Preview {
    StyleView()
}
