import Foundation

enum FirestoreCollection {
    static let couples = "couples"
    static let anniversaries = "anniversaries"
    static let letters = "letters"
    static let places = "places"
    static let courses = "courses"
    static let expenses = "expenses"
}

enum UserDefaultsKey {
    static let coupleKey = "woori_couple_key"
    static let myNickname = "woori_my_nickname"
    static let isSetupDone = "woori_is_setup_done"
    static let coupleDocId = "woori_couple_doc_id"
    static let partnerNickname = "woori_partner_nickname"
}
