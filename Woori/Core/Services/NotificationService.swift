import Foundation
import FirebaseMessaging
import UserNotifications

final class NotificationService: NSObject {
    static let shared = NotificationService()

    private override init() {
        super.init()
    }

    /// 푸시 알림 권한 요청
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    /// FCM 토큰 가져오기
    func getFCMToken() async -> String? {
        try? await Messaging.messaging().token()
    }

    /// 상대방에게 푸시 알림 전송 (Cloud Functions 호출 필요)
    /// 실제 서비스에서는 Firebase Cloud Functions로 구현
    func sendPush(to userId: String, title: String, body: String) async {
        // Cloud Functions endpoint 호출
        // 현재는 로컬 알림으로 대체
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
