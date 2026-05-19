import SwiftUI

struct FinanceView: View {
    @EnvironmentObject private var appState: AppState
    @State private var amount = ""
    @State private var selectedCategory = "Коммуналка"
    @State private var note = ""

    private let categories = QuickExpenseCategory.defaults.map(\.title)

    var body: some View {
        NavigationStack {
            Form {
                if let error = appState.lastError {
                    Section("Ошибка") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                if let message = appState.lastMessage {
                    Section("Ответ") {
                        Text(message)
                            .font(.caption)
                    }
                }

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
                        guard let decimal = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) else { return }
                        Task {
                            await appState.createExpense(amount: decimal, category: selectedCategory, description: note.isEmpty ? selectedCategory : note)
                            amount = ""
                            note = ""
                        }
                    }
                }

                Section("Месяц") {
                    LabeledContent("Расходы", value: "\(format(appState.financeSummary.monthExpenses)) UAH")
                    LabeledContent("Доходы", value: "\(format(appState.financeSummary.monthIncome)) UAH")
                    LabeledContent("Кредитки", value: "\(format(totalDebt)) UAH")
                    LabeledContent("Резерв", value: reserveText)
                }

                Section("Лимиты") {
                    if appState.financeSummary.budgets.isEmpty {
                        Text("Лимиты пока не заданы")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.financeSummary.budgets) { budget in
                            LabeledContent(budget.category, value: "\(format(budget.monthlyLimit)) \(budget.currency)")
                        }
                    }
                }

                Section("Правило") {
                    Text("Не запрещаем жизнь. Убираем хаос.")
                }
            }
            .navigationTitle("Финансы")
            .toolbar {
                Button {
                    Task { await appState.refreshFinance() }
                } label: {
                    if appState.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await appState.refreshFinance()
            }
        }
    }

    private var totalDebt: Decimal {
        appState.financeSummary.debts.reduce(0) { $0 + $1.remainingAmount }
    }

    private var reserveText: String {
        guard let reserve = appState.financeSummary.goals.first(where: { $0.name.lowercased().contains("резерв") }) else {
            return "0 / 300 000 UAH"
        }
        return "\(format(reserve.currentAmount)) / \(format(reserve.targetAmount)) UAH"
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }
}

#Preview {
    FinanceView()
        .environmentObject(AppState())
}
