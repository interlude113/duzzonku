import Foundation
import FirebaseFirestore

final class FirebaseDateRepository: DateRepositoryProtocol {
    private let service = FirestoreService.shared

    private func coursesCollection(coupleDocId: String) -> CollectionReference {
        service.subCollection(coupleDocId: coupleDocId, collection: FirestoreCollection.courses)
    }

    private func coursePlacesCollection(coupleDocId: String, courseId: String) -> CollectionReference {
        coursesCollection(coupleDocId: coupleDocId).document(courseId).collection(FirestoreCollection.places)
    }

    private func expensesCollection(coupleDocId: String) -> CollectionReference {
        service.subCollection(coupleDocId: coupleDocId, collection: FirestoreCollection.expenses)
    }

    // MARK: - Courses

    func fetchCourses(coupleDocId: String) async throws -> [DateCourse] {
        let query = coursesCollection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        return try await service.getDocuments(DateCourse.self, from: query)
    }

    func addCourse(_ course: DateCourse, coupleDocId: String) async throws -> String {
        try await service.addDocument(course, to: coursesCollection(coupleDocId: coupleDocId))
    }

    func updateCourse(_ course: DateCourse, coupleDocId: String) async throws {
        guard let id = course.id else { return }
        let ref = coursesCollection(coupleDocId: coupleDocId).document(id)
        try await service.setDocument(course, at: ref)
    }

    func deleteCourse(id: String, coupleDocId: String) async throws {
        let ref = coursesCollection(coupleDocId: coupleDocId).document(id)
        // Delete sub-collection places first
        let places = try await coursePlacesCollection(coupleDocId: coupleDocId, courseId: id).getDocuments()
        for doc in places.documents {
            try await doc.reference.delete()
        }
        try await service.deleteDocument(at: ref)
    }

    func listenCourses(coupleDocId: String) -> (stream: AsyncStream<[DateCourse]>, cancel: () -> Void) {
        let query = coursesCollection(coupleDocId: coupleDocId).order(by: "createdAt", descending: true)
        let result = service.listen(DateCourse.self, query: query)
        return (result.stream, { result.listener.remove() })
    }

    // MARK: - Course Places

    func fetchCoursePlaces(coupleDocId: String, courseId: String) async throws -> [CoursePlace] {
        let query = coursePlacesCollection(coupleDocId: coupleDocId, courseId: courseId)
            .order(by: "order", descending: false)
        return try await service.getDocuments(CoursePlace.self, from: query)
    }

    func addCoursePlace(_ place: CoursePlace, coupleDocId: String, courseId: String) async throws -> String {
        try await service.addDocument(place, to: coursePlacesCollection(coupleDocId: coupleDocId, courseId: courseId))
    }

    func updateCoursePlace(_ place: CoursePlace, coupleDocId: String, courseId: String) async throws {
        guard let id = place.id else { return }
        let ref = coursePlacesCollection(coupleDocId: coupleDocId, courseId: courseId).document(id)
        try await service.setDocument(place, at: ref)
    }

    func deleteCoursePlaces(coupleDocId: String, courseId: String) async throws {
        let snapshot = try await coursePlacesCollection(coupleDocId: coupleDocId, courseId: courseId).getDocuments()
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }

    // MARK: - Expenses

    func fetchExpenses(coupleDocId: String) async throws -> [DateExpense] {
        let query = expensesCollection(coupleDocId: coupleDocId).order(by: "date", descending: true)
        return try await service.getDocuments(DateExpense.self, from: query)
    }

    func fetchExpenses(coupleDocId: String, month: Date) async throws -> [DateExpense] {
        let range = DateHelper.monthRange(for: month)
        let startTimestamp = Timestamp(date: range.start)
        let endTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: 1, to: range.end)!)

        let query = expensesCollection(coupleDocId: coupleDocId)
            .whereField("date", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("date", isLessThan: endTimestamp)
            .order(by: "date", descending: true)
        return try await service.getDocuments(DateExpense.self, from: query)
    }

    func fetchExpenses(coupleDocId: String, courseId: String) async throws -> [DateExpense] {
        let query = expensesCollection(coupleDocId: coupleDocId)
            .whereField("courseId", isEqualTo: courseId)
            .order(by: "date", descending: true)
        return try await service.getDocuments(DateExpense.self, from: query)
    }

    func addExpense(_ expense: DateExpense, coupleDocId: String) async throws -> String {
        try await service.addDocument(expense, to: expensesCollection(coupleDocId: coupleDocId))
    }

    func deleteExpense(id: String, coupleDocId: String) async throws {
        let ref = expensesCollection(coupleDocId: coupleDocId).document(id)
        try await service.deleteDocument(at: ref)
    }

    func listenExpenses(coupleDocId: String) -> (stream: AsyncStream<[DateExpense]>, cancel: () -> Void) {
        let query = expensesCollection(coupleDocId: coupleDocId).order(by: "date", descending: true)
        let result = service.listen(DateExpense.self, query: query)
        return (result.stream, { result.listener.remove() })
    }
}
