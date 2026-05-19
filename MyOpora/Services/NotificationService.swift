import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {}

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async throws {
        _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        await refreshAuthorizationStatus()
    }

    func scheduleDefaultPokeNotifications() async throws {
        try await requestAuthorization()
        cancelPokeNotifications()

        let notifications = [
            PokeNotification(id: "opora.poke.morning", hour: 9, minute: 30, title: "Опора", body: "*тык палкой* Живой? Вода, один фокус, без героизма."),
            PokeNotification(id: "opora.poke.midday", hour: 13, minute: 30, title: "Проверка палкой", body: "Квадратная голова? Пауза, вода, механические задачи."),
            PokeNotification(id: "opora.poke.evening", hour: 18, minute: 30, title: "Домой без исчезновения", body: "Назови состояние. Семья — не плата за успех."),
            PokeNotification(id: "opora.poke.night", hour: 22, minute: 00, title: "Вечерняя Опора", body: "Не решаем всю жизнь. Закрываем день и не превращаемся в камень.")
        ]

        for notification in notifications {
            try schedule(notification)
        }
    }

    func cancelPokeNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "opora.poke.morning",
            "opora.poke.midday",
            "opora.poke.evening",
            "opora.poke.night"
        ])
    }

    private func schedule(_ notification: PokeNotification) throws {
        var dateComponents = DateComponents()
        dateComponents.hour = notification.hour
        dateComponents.minute = notification.minute

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

struct PokeNotification {
    let id: String
    let hour: Int
    let minute: Int
    let title: String
    let body: String
}
