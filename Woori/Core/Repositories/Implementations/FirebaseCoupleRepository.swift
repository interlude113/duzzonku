import Foundation
import FirebaseFirestore

final class FirebaseCoupleRepository: CoupleRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func createCouple(_ couple: Couple) async throws -> String {
        let ref = db.collection(Collections.couples).document()
        var newCouple = couple
        newCouple.inviteCode = generateInviteCode()
        try ref.setData(from: newCouple)
        return ref.documentID
    }

    func fetchCouple(for userId: String) async throws -> Couple? {
        // user1Id로 검색
        let snap1 = try await db.collection(Collections.couples)
            .whereField("user1Id", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()

        if let doc = snap1.documents.first {
            return try doc.data(as: Couple.self)
        }

        // user2Id로 검색
        let snap2 = try await db.collection(Collections.couples)
            .whereField("user2Id", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()

        return try snap2.documents.first?.data(as: Couple.self)
    }

    func fetchCoupleById(_ coupleId: String) async throws -> Couple? {
        let doc = try await db.collection(Collections.couples).document(coupleId).getDocument()
        return try doc.data(as: Couple.self)
    }

    func joinCouple(inviteCode: String, userId: String) async throws -> Couple {
        let snap = try await db.collection(Collections.couples)
            .whereField("inviteCode", isEqualTo: inviteCode)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snap.documents.first else {
            throw CoupleError.invalidInviteCode
        }

        var couple = try doc.data(as: Couple.self)
        guard couple.user2Id == nil else {
            throw CoupleError.alreadyPaired
        }

        try await doc.reference.updateData(["user2Id": userId])
        couple.user2Id = userId
        return couple
    }

    func updateTodayMessage(coupleId: String, message: String) async throws {
        try await db.collection(Collections.couples).document(coupleId).updateData([
            "todayMessage": message,
            "todayMessageDate": Timestamp(date: Date())
        ])
    }

    func listenToCouple(coupleId: String) -> AsyncStream<Couple?> {
        AsyncStream { continuation in
            listener = db.collection(Collections.couples).document(coupleId)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot, error == nil else {
                        continuation.yield(nil)
                        return
                    }
                    let couple = try? snapshot.data(as: Couple.self)
                    continuation.yield(couple)
                }
            continuation.onTermination = { [weak self] _ in
                self?.listener?.remove()
            }
        }
    }

    // MARK: - Private

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<AppConstants.inviteCodeLength).map { _ in
            chars.randomElement()!
        })
    }
}

enum CoupleError: LocalizedError {
    case invalidInviteCode
    case alreadyPaired

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode: return "유효하지 않은 초대 코드입니다."
        case .alreadyPaired: return "이미 연결된 커플입니다."
        }
    }
}
