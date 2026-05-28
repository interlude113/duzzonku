import SwiftUI

struct DateView: View {
    enum DateTab: String, CaseIterable {
        case course = "코스"
        case expense = "가계부"
    }

    @StateObject private var courseVM = CourseViewModel()
    @StateObject private var expenseVM = ExpenseViewModel()
    @EnvironmentObject private var tabRouter: TabRouter
    @State private var selectedTab: DateTab = .course

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Segmented control
                    Picker("탭", selection: $selectedTab) {
                        ForEach(DateTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)

                    switch selectedTab {
                    case .course:
                        CourseListView(viewModel: courseVM)
                    case .expense:
                        ExpenseListView(viewModel: expenseVM)
                    }
                }
                .background(Color.wooriBackground)

                // FAB
                Button {
                    if selectedTab == .course {
                        courseVM.resetForm()
                        courseVM.showAddSheet = true
                    } else {
                        expenseVM.resetForm()
                        expenseVM.showAddSheet = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.wooriPrimary)
                        .clipShape(Circle())
                        .shadow(
                            color: .wooriPrimary.opacity(0.3),
                            radius: 8, x: 0, y: 4
                        )
                }
                .accessibilityLabel(selectedTab == .course ? "코스 추가" : "지출 추가")
                .padding(Spacing.lg)
            }
            .navigationTitle("데이트")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $courseVM.showAddSheet) {
                AddCourseSheet(viewModel: courseVM)
            }
            .sheet(isPresented: $expenseVM.showAddSheet) {
                AddExpenseSheet(viewModel: expenseVM)
            }
            .alert("오류", isPresented: .init(
                get: {
                    courseVM.errorMessage != nil || expenseVM.errorMessage != nil
                },
                set: { if !$0 {
                    courseVM.errorMessage = nil
                    expenseVM.errorMessage = nil
                }}
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(courseVM.errorMessage ?? expenseVM.errorMessage ?? "")
            }
        }
        .task {
            courseVM.startListening()
            expenseVM.startListening()
        }
        .onDisappear {
            courseVM.stopListening()
            expenseVM.stopListening()
        }
        .onChange(of: tabRouter.dateFilterCourseId) { _, courseId in
            if courseId != nil {
                selectedTab = .course
                tabRouter.dateFilterCourseId = nil
            }
        }
    }
}
