import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var couple: Couple?
    @Published var dday: Int = 0
    @Published var detailedDuration: String = ""
    @Published var nextAnniversary: Anniversary?
    @Published var nextAnniversaryDays: Int = 0
    @Published var photoCount: Int = 0
    @Published var placeCount: Int = 0
    @Published var todayMessage: String = ""
    @Published var isEditingMessage = false
    @Published var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    private let coupleRepo: CoupleRepositoryProtocol
    private let anniversaryRepo: AnniversaryRepositoryProtocol
    private let photoRepo: PhotoRepositoryProtocol
    private let placeRepo: PlaceRepositoryProtocol
    private var timerCancellable: AnyCancellable?

    init(
        coupleRepo: CoupleRepositoryProtocol = FirebaseCoupleRepository(),
        anniversaryRepo: AnniversaryRepositoryProtocol = FirebaseAnniversaryRepository(),
        photoRepo: PhotoRepositoryProtocol = FirebasePhotoRepository(),
        placeRepo: PlaceRepositoryProtocol = FirebasePlaceRepository()
    ) {
        self.coupleRepo = coupleRepo
        self.anniversaryRepo = anniversaryRepo
        self.photoRepo = photoRepo
        self.placeRepo = placeRepo
        startMidnightTimer()
    }

    // MARK: - Load Data

    func loadData(coupleId: String) async {
        do {
            let couple = try await coupleRepo.fetchCoupleById(coupleId)
            self.couple = couple

            if let couple {
                updateDday(startDate: couple.startedAt)
                if let msg = couple.todayMessage,
                   let msgDate = couple.todayMessageDate,
                   Calendar.current.isDateInToday(msgDate) {
                    todayMessage = msg
                } else {
                    todayMessage = ""
                }
            }

            // 통계
            async let anniversaries = anniversaryRepo.fetchAll(coupleId: coupleId)
            async let photos = photoRepo.photoCount(coupleId: coupleId)
            async let places = placeRepo.placeCount(coupleId: coupleId)

            let annis = try await anniversaries
            photoCount = try await photos
            placeCount = try await places

            // 다음 기념일
            nextAnniversary = annis
                .filter { $0.daysUntilNext > 0 }
                .min(by: { $0.daysUntilNext < $1.daysUntilNext })
            nextAnniversaryDays = nextAnniversary?.daysUntilNext ?? 0

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Today Message

    func saveTodayMessage(coupleId: String) async {
        do {
            try await coupleRepo.updateTodayMessage(coupleId: coupleId, message: todayMessage)
            isEditingMessage = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - D-day

    private func updateDday(startDate: Date) {
        dday = DateHelper.calculateDday(from: startDate)
        detailedDuration = DateHelper.detailedDuration(from: startDate)
    }

    private func startMidnightTimer() {
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let couple = self.couple else { return }
                self.updateDday(startDate: couple.startedAt)
            }
    }
}
