import SwiftUI
import FirebaseFirestore

@MainActor
final class CourseViewModel: ObservableObject {
    @Published var courses: [DateCourse] = []
    @Published var coursePlacesMap: [String: [CoursePlace]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddSheet = false

    // Add form
    @Published var newTitle = ""
    @Published var newDate = Date()
    @Published var newHasDate = false
    @Published var newMemo = ""
    @Published var newPlaces: [CoursePlace] = []
    @Published var searchQuery = ""

    // Detail
    @Published var selectedCourse: DateCourse?
    @Published var detailPlaces: [CoursePlace] = []
    @Published var detailExpenseTotal: Int = 0

    private let repository = FirebaseDateRepository()
    private let placeRepository = FirebasePlaceRepository()
    private let session = CoupleSession.shared
    private var cancelListener: (() -> Void)?

    var coupleDocId: String { session.coupleDocId }

    // MARK: - Listeners

    func startListening() {
        let result = repository.listenCourses(coupleDocId: coupleDocId)
        cancelListener = result.cancel
        Task {
            for await items in result.stream {
                self.courses = items
                await self.loadAllCoursePlaces()
            }
        }
    }

    func stopListening() {
        cancelListener?()
        cancelListener = nil
    }

    private func loadAllCoursePlaces() async {
        var map: [String: [CoursePlace]] = [:]
        for course in courses {
            guard let id = course.id else { continue }
            if let places = try? await repository.fetchCoursePlaces(
                coupleDocId: coupleDocId, courseId: id
            ) {
                map[id] = places
            }
        }
        self.coursePlacesMap = map
    }

    // MARK: - Add Course

    func addCourse() async {
        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "코스 이름을 입력해주세요"
            return
        }
        isLoading = true
        do {
            let course = DateCourse(
                title: newTitle.trimmingCharacters(in: .whitespaces),
                date: newHasDate ? Timestamp(date: newDate) : nil,
                memo: newMemo.isEmpty ? nil : newMemo,
                isCompleted: false,
                createdAt: Timestamp(date: Date())
            )
            let courseId = try await repository.addCourse(course, coupleDocId: coupleDocId)

            // Add places
            for (index, var place) in newPlaces.enumerated() {
                place.order = index + 1
                _ = try await repository.addCoursePlace(
                    place, coupleDocId: coupleDocId, courseId: courseId
                )
            }

            resetForm()
            showAddSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Detail

    func loadDetail(for course: DateCourse) async {
        guard let courseId = course.id else { return }
        selectedCourse = course
        do {
            detailPlaces = try await repository.fetchCoursePlaces(
                coupleDocId: coupleDocId, courseId: courseId
            )
            let expenses = try await repository.fetchExpenses(
                coupleDocId: coupleDocId, courseId: courseId
            )
            detailExpenseTotal = expenses.reduce(0) { $0 + $1.amount }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func togglePlaceVisited(_ place: CoursePlace) async {
        guard let courseId = selectedCourse?.id, place.id != nil else { return }
        var updated = place
        updated.isVisited.toggle()
        do {
            try await repository.updateCoursePlace(
                updated, coupleDocId: coupleDocId, courseId: courseId
            )

            // Refresh
            detailPlaces = try await repository.fetchCoursePlaces(
                coupleDocId: coupleDocId, courseId: courseId
            )

            // Check if all visited → mark course completed
            let allVisited = detailPlaces.allSatisfy { $0.isVisited }
            if allVisited, var course = selectedCourse, !course.isCompleted {
                course.isCompleted = true
                try await repository.updateCourse(course, coupleDocId: coupleDocId)
                selectedCourse = course
            } else if !allVisited, var course = selectedCourse, course.isCompleted {
                course.isCompleted = false
                try await repository.updateCourse(course, coupleDocId: coupleDocId)
                selectedCourse = course
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCourse(_ course: DateCourse) async {
        guard let id = course.id else { return }
        do {
            try await repository.deleteCourse(id: id, coupleDocId: coupleDocId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Places for Add Form

    func addSearchResultPlace(_ item: MKMapItemWrapper) {
        let place = CoursePlace(
            name: item.name,
            address: item.address,
            latitude: item.latitude,
            longitude: item.longitude,
            category: "기타",
            order: newPlaces.count + 1,
            isVisited: false,
            linkedPlaceId: nil,
            createdAt: Timestamp(date: Date())
        )
        newPlaces.append(place)
    }

    func addFromSavedPlace(_ place: Place) {
        let cp = CoursePlace(
            name: place.name,
            address: place.address,
            latitude: place.latitude,
            longitude: place.longitude,
            category: place.category,
            order: newPlaces.count + 1,
            isVisited: false,
            linkedPlaceId: place.id,
            createdAt: Timestamp(date: Date())
        )
        newPlaces.append(cp)
    }

    func movePlaces(from source: IndexSet, to destination: Int) {
        newPlaces.move(fromOffsets: source, toOffset: destination)
        for i in newPlaces.indices {
            newPlaces[i].order = i + 1
        }
    }

    func removePlaceFromForm(at offsets: IndexSet) {
        newPlaces.remove(atOffsets: offsets)
        for i in newPlaces.indices {
            newPlaces[i].order = i + 1
        }
    }

    /// Fetch saved places for picker
    func fetchSavedPlaces() async -> [Place] {
        (try? await placeRepository.fetchPlaces(coupleDocId: coupleDocId)) ?? []
    }

    func resetForm() {
        newTitle = ""
        newDate = Date()
        newHasDate = false
        newMemo = ""
        newPlaces = []
        searchQuery = ""
    }
}

// MARK: - Helper

struct MKMapItemWrapper: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let latitude: Double
    let longitude: Double
}
