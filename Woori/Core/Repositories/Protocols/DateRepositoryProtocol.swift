import Foundation
import FirebaseFirestore

protocol DateRepositoryProtocol {
    // Courses
    func fetchCourses(coupleDocId: String) async throws -> [DateCourse]
    func addCourse(_ course: DateCourse, coupleDocId: String) async throws -> String
    func updateCourse(_ course: DateCourse, coupleDocId: String) async throws
    func deleteCourse(id: String, coupleDocId: String) async throws
    func listenCourses(coupleDocId: String) -> (stream: AsyncStream<[DateCourse]>, cancel: () -> Void)

    // Course Places
    func fetchCoursePlaces(coupleDocId: String, courseId: String) async throws -> [CoursePlace]
    func addCoursePlace(_ place: CoursePlace, coupleDocId: String, courseId: String) async throws -> String
    func updateCoursePlace(_ place: CoursePlace, coupleDocId: String, courseId: String) async throws
    func deleteCoursePlaces(coupleDocId: String, courseId: String) async throws

    // Expenses
    func fetchExpenses(coupleDocId: String) async throws -> [DateExpense]
    func fetchExpenses(coupleDocId: String, month: Date) async throws -> [DateExpense]
    func fetchExpenses(coupleDocId: String, courseId: String) async throws -> [DateExpense]
    func addExpense(_ expense: DateExpense, coupleDocId: String) async throws -> String
    func deleteExpense(id: String, coupleDocId: String) async throws
    func listenExpenses(coupleDocId: String) -> (stream: AsyncStream<[DateExpense]>, cancel: () -> Void)
}
