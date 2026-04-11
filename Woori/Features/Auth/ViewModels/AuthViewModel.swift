import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var coupleId: String?
    @Published var userId: String?
    @Published var partnerId: String?
    @Published var couple: Couple?
    @Published var isLoading = true
    @Published var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    private let coupleRepo: CoupleRepositoryProtocol
    private var coupleTask: Task<Void, Never>?

    init(coupleRepo: CoupleRepositoryProtocol = FirebaseCoupleRepository()) {
        self.coupleRepo = coupleRepo
    }

    // MARK: - Load Couple

    func loadCouple(for userId: String) async {
        self.userId = userId
        isLoading = true
        do {
            if let couple = try await coupleRepo.fetchCouple(for: userId) {
                self.couple = couple
                self.coupleId = couple.coupleId
                self.partnerId = couple.user1Id == userId ? couple.user2Id : couple.user1Id
                startListening(coupleId: couple.coupleId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Create Couple

    func createCouple(name: String, startDate: Date, userId: String) async {
        isLoading = true
        do {
            let newCouple = Couple(
                coupleName: name,
                startedAt: startDate,
                user1Id: userId,
                user2Id: nil,
                inviteCode: "",
                todayMessage: nil,
                todayMessageDate: nil,
                createdAt: Date()
            )
            let id = try await coupleRepo.createCouple(newCouple)
            self.coupleId = id
            await loadCouple(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Join Couple

    func joinCouple(inviteCode: String, userId: String) async {
        isLoading = true
        do {
            let couple = try await coupleRepo.joinCouple(inviteCode: inviteCode, userId: userId)
            self.couple = couple
            self.coupleId = couple.coupleId
            self.partnerId = couple.user1Id == userId ? couple.user2Id : couple.user1Id
            startListening(coupleId: couple.coupleId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Today Message

    func updateTodayMessage(_ message: String) async {
        guard let coupleId else { return }
        do {
            try await coupleRepo.updateTodayMessage(coupleId: coupleId, message: message)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Realtime Listener

    private func startListening(coupleId: String) {
        coupleTask?.cancel()
        coupleTask = Task {
            for await updated in coupleRepo.listenToCouple(coupleId: coupleId) {
                guard !Task.isCancelled else { break }
                self.couple = updated
            }
        }
    }
}
