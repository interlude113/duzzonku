import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    private init() {}

    /// 알림 권한 요청
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    /// 로컬 알림 스케줄링 (기념일 D-1)
    func scheduleAnniversaryReminder(id: String, title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "우리 기념일 알림"
        content.body = "내일은 \(title)이에요! 💕"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let day = dateComponents.day {
            dateComponents.day = day - 1
        }
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "anniversary_\(id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// 편지 도착 로컬 알림
    func sendLetterNotification(from nickname: String) {
        let content = UNMutableNotificationContent()
        content.title = "새 편지가 도착했어요 💌"
        content.body = "\(nickname)님이 편지를 보냈어요"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// 특정 알림 취소
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["anniversary_\(id)"])
    }
}
