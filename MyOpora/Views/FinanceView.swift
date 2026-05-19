import SwiftUI

struct FinanceView: View {
    @State private var amount = ""
    @State private var selectedCategory = "Коммуналка"
    @State private var note = ""

    private let categories = QuickExpenseCategory.defaults.map(\.title)

    var body: some View {
        NavigationStack {
            Form {
                Section("Быстрый расход") {
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    TextField("Комментарий", text: $note)
                    Button("Записать расход") {
                        amount = ""
                        note = ""
                    }
                }

                Section("Месяц") {
                    LabeledContent("Расходы", value: "0 UAH")
                    LabeledContent("Доходы", value: "0 UAH")
                    LabeledContent("Кредитки", value: "140 000 UAH")
                    LabeledContent("Резерв", value: "0 / 300 000 UAH")
                }

                Section("Правило") {
                    Text("Не запрещаем жизнь. Убираем хаос.")
                }
            }
            .navigationTitle("Финансы")
        }
    }
}

#Preview {
    FinanceView()
}
