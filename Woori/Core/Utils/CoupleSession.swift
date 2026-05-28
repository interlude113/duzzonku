import Foundation

@MainActor
final class CoupleSession: ObservableObject {
    static let shared = CoupleSession()

    @Published var coupleKey: String
    @Published var myNickname: String
    @Published var partnerNickname: String
    @Published var coupleDocId: String
    @Published var isSetupDone: Bool

    private let defaults = UserDefaults.standard

    private init() {
        self.coupleKey = defaults.string(forKey: UserDefaultsKey.coupleKey) ?? ""
        self.myNickname = defaults.string(forKey: UserDefaultsKey.myNickname) ?? ""
        self.partnerNickname = defaults.string(forKey: UserDefaultsKey.partnerNickname) ?? ""
        self.coupleDocId = defaults.string(forKey: UserDefaultsKey.coupleDocId) ?? ""
        self.isSetupDone = defaults.bool(forKey: UserDefaultsKey.isSetupDone)
    }

    /// 커플 정보 저장 — isSetupDone은 건드리지 않음 (코드 화면 유지용)
    func saveCoupleInfo(coupleKey: String, nickname: String, coupleDocId: String) {
        self.coupleKey = coupleKey
        self.myNickname = nickname
        self.coupleDocId = coupleDocId

        defaults.set(coupleKey, forKey: UserDefaultsKey.coupleKey)
        defaults.set(nickname, forKey: UserDefaultsKey.myNickname)
        defaults.set(coupleDocId, forKey: UserDefaultsKey.coupleDocId)
    }

    /// 커플 정보 저장 + 설정 완료 표시 (join 플로우용)
    func saveSetup(coupleKey: String, nickname: String, coupleDocId: String) {
        saveCoupleInfo(coupleKey: coupleKey, nickname: nickname, coupleDocId: coupleDocId)
        self.isSetupDone = true
        defaults.set(true, forKey: UserDefaultsKey.isSetupDone)
    }

    /// 설정 완료 표시 (create 플로우: 코드 화면 확인 후 호출)
    func markSetupDone() {
        self.isSetupDone = true
        defaults.set(true, forKey: UserDefaultsKey.isSetupDone)
    }

    func savePartnerNickname(_ nickname: String) {
        self.partnerNickname = nickname
        defaults.set(nickname, forKey: UserDefaultsKey.partnerNickname)
    }

    func reset() {
        coupleKey = ""
        myNickname = ""
        partnerNickname = ""
        coupleDocId = ""
        isSetupDone = false

        defaults.removeObject(forKey: UserDefaultsKey.coupleKey)
        defaults.removeObject(forKey: UserDefaultsKey.myNickname)
        defaults.removeObject(forKey: UserDefaultsKey.partnerNickname)
        defaults.removeObject(forKey: UserDefaultsKey.coupleDocId)
        defaults.removeObject(forKey: UserDefaultsKey.isSetupDone)
    }

    /// 6자리 랜덤 coupleKey 생성
    static func generateCoupleKey() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
