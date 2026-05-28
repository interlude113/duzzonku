import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SetupViewModel: ObservableObject {
    enum SetupMode {
        case none
        case create
        case join
    }

    enum SetupStep {
        case chooseMode
        case createInput
        case showCode
        case joinInput
    }

    @Published var mode: SetupMode = .none
    @Published var step: SetupStep = .chooseMode
    @Published var nickname = ""
    @Published var startDate = Date()
    @Published var coupleKey = ""
    @Published var joinCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var generatedKey = ""

    private let firestoreService = FirestoreService.shared

    // MARK: - Create Couple

    func createCouple() async {
        guard !nickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "닉네임을 입력해주세요"
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "인증 오류가 발생했습니다"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let key = CoupleSession.generateCoupleKey()
            let couple = Couple(
                coupleKey: key,
                startedAt: Timestamp(date: startDate),
                user1Id: uid,
                user2Id: nil,
                user1Nickname: nickname.trimmingCharacters(in: .whitespaces),
                user2Nickname: nil,
                todayMessage: nil,
                todayMessageDate: nil,
                createdAt: Timestamp(date: Date())
            )

            let docId = try await firestoreService.addDocument(
                couple,
                to: Firestore.firestore().collection(FirestoreCollection.couples)
            )

            // 처음 사귄 날 기념일을 자동 추가
            let primaryAnniversary = Anniversary(
                title: "사귄 날",
                date: Timestamp(date: startDate),
                isRecurring: true,
                emoji: "💑",
                isPrimary: true,
                createdAt: Timestamp(date: Date())
            )
            let annivCollection = firestoreService.subCollection(
                coupleDocId: docId,
                collection: FirestoreCollection.anniversaries
            )
            _ = try await firestoreService.addDocument(primaryAnniversary, to: annivCollection)

            generatedKey = key
            // isSetupDone은 아직 설정 안 함 → 코드 화면 유지
            CoupleSession.shared.saveCoupleInfo(coupleKey: key, nickname: nickname.trimmingCharacters(in: .whitespaces), coupleDocId: docId)

            step = .showCode
            isLoading = false
        } catch {
            errorMessage = "커플 생성에 실패했습니다: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Join Couple

    func joinCouple() async {
        guard !nickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "닉네임을 입력해주세요"
            return
        }
        guard !joinCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "커플 코드를 입력해주세요"
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "인증 오류가 발생했습니다"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let code = joinCode.trimmingCharacters(in: .whitespaces).uppercased()
            guard let result = try await firestoreService.findCouple(byKey: code) else {
                errorMessage = "해당 코드의 커플을 찾을 수 없습니다"
                isLoading = false
                return
            }

            if result.couple.user2Id != nil {
                errorMessage = "이미 연결된 커플입니다"
                isLoading = false
                return
            }

            let trimmedNickname = nickname.trimmingCharacters(in: .whitespaces)

            // Update couple document with user2
            let ref = firestoreService.coupleDocument(coupleDocId: result.docId)
            try await firestoreService.updateFields([
                "user2Id": uid,
                "user2Nickname": trimmedNickname
            ], at: ref)

            CoupleSession.shared.saveSetup(coupleKey: code, nickname: trimmedNickname, coupleDocId: result.docId)
            CoupleSession.shared.savePartnerNickname(result.couple.user1Nickname)

            isLoading = false
        } catch {
            errorMessage = "연결에 실패했습니다: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func completeSetup() {
        CoupleSession.shared.markSetupDone()
    }
}
