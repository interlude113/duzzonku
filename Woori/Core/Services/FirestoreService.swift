import Foundation
import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    /// 커플 문서 경로 반환
    func coupleDocument(coupleDocId: String) -> DocumentReference {
        db.collection(FirestoreCollection.couples).document(coupleDocId)
    }

    /// 커플 하위 컬렉션 경로 반환
    func subCollection(coupleDocId: String, collection: String) -> CollectionReference {
        coupleDocument(coupleDocId: coupleDocId).collection(collection)
    }

    // MARK: - Generic CRUD

    /// 문서 추가 (자동 ID) — async/await 완전 대기
    func addDocument<T: Codable>(_ data: T, to collection: CollectionReference) async throws -> String {
        let ref = collection.document()          // 자동 ID 생성
        try await ref.setData(from: data)        // 쓰기 완료까지 대기
        return ref.documentID
    }

    /// 문서 설정 (지정 ID) — async/await 완전 대기
    func setDocument<T: Codable>(_ data: T, at reference: DocumentReference) async throws {
        try await reference.setData(from: data)
    }

    /// 문서 가져오기
    func getDocument<T: Codable>(_ type: T.Type, from reference: DocumentReference) async throws -> T? {
        let snapshot = try await reference.getDocument()
        return try snapshot.data(as: T.self)
    }

    /// 컬렉션 전체 가져오기
    func getDocuments<T: Codable>(_ type: T.Type, from query: Query) async throws -> [T] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    /// 필드 업데이트
    func updateFields(_ fields: [String: Any], at reference: DocumentReference) async throws {
        try await reference.updateData(fields)
    }

    /// 문서 삭제
    func deleteDocument(at reference: DocumentReference) async throws {
        try await reference.delete()
    }

    /// coupleKey로 커플 문서 조회
    func findCouple(byKey coupleKey: String) async throws -> (docId: String, couple: Couple)? {
        let snapshot = try await db.collection(FirestoreCollection.couples)
            .whereField("coupleKey", isEqualTo: coupleKey)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first else { return nil }
        let couple = try doc.data(as: Couple.self)
        return (doc.documentID, couple)
    }

    /// 실시간 리스너 등록 (AsyncStream 반환)
    func listen<T: Codable>(_ type: T.Type, query: Query) -> (stream: AsyncStream<[T]>, listener: ListenerRegistration) {
        var listener: ListenerRegistration?
        let stream = AsyncStream<[T]> { continuation in
            listener = query.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                let items = snapshot.documents.compactMap { try? $0.data(as: T.self) }
                continuation.yield(items)
            }
            continuation.onTermination = { _ in
                listener?.remove()
            }
        }
        return (stream, listener!)
    }
}
