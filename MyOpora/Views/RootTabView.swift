import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Сегодня", systemImage: "sun.max.fill") }

            FinanceView()
                .tabItem { Label("Финансы", systemImage: "creditcard.fill") }

            CanBuyView()
                .tabItem { Label("Can Buy?", systemImage: "cart.badge.questionmark") }

            HomeTransitionView()
                .tabItem { Label("Домой", systemImage: "house.fill") }

            OperationView()
                .tabItem { Label("Операция", systemImage: "shield.lefthalf.filled") }

            HabitsView()
                .tabItem { Label("Привычки", systemImage: "checkmark.circle.fill") }

            GoalsView()
                .tabItem { Label("Цели", systemImage: "target") }

            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
}
