import SwiftUI

struct CourseListView: View {
    @ObservedObject var viewModel: CourseViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                if viewModel.courses.isEmpty {
                    EmptyStateView(
                        icon: "map",
                        title: "데이트 코스가 없어요",
                        description: "특별한 데이트 코스를 계획해보세요"
                    )
                } else {
                    ForEach(viewModel.courses) { course in
                        NavigationLink {
                            CourseDetailView(viewModel: viewModel, course: course)
                        } label: {
                            CourseCardView(
                                course: course,
                                placeCount: viewModel.coursePlacesMap[course.id ?? ""]?.count ?? 0
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            .padding(.bottom, 80)
        }
    }
}
