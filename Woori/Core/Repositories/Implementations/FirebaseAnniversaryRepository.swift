import Foundation
import FirebaseFirestore

final class FirebaseAnniversaryRepository: AnniversaryRepositoryProtocol {
    private let service = FirestoreService.shared

    private func collection(coupleDocId: String) -> CollectionReference {
        service.subCollection(coupleDocId: coupleDocId, collection: FirestoreCollection.anniversaries)
    }

    func fetchAnniversaries(coupleDocId: String) async throws -> [Anniversary] {
        let query = collection(coupleDocId: coupleDocId).order(by: "date", descending: false)
        return try await service.getDocuments(Anniversary.self, from: query)
    }

    func addAnniversary(_ anniversary: Anniversary, coupleDocId: String) async throws -> String {
        try await service.addDocument(anniversary, to: collection(coupleDocId: coupleDocId))
    }

    func deleteAnniversary(id: String, coupleDocId: String) async throws {
        let ref = collection(coupleDocId: coupleDocId).document(id)
        try await service.deleteDocument(at: ref)
    }

    func listenAnniversaries(coupleDocId: String) -> (stream: AsyncStream<[Anniversary]>, cancel: () -> Void) {
        let query = collection(coupleDocId: coupleDocId).order(by: "date", descending: false)
        let result = service.listen(Anniversary.self, query: query)
        return (result.stream, { result.listener.remove() })
    }
}
