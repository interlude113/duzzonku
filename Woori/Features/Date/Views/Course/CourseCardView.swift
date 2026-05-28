import SwiftUI

struct CourseCardView: View {
    let course: DateCourse
    let placeCount: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.sm) {
                    Text(course.title)
                        .font(.wooriHeadline)
                        .foregroundStyle(.wooriTextPrimary)

                    if course.isCompleted {
                        Text("완료")
                            .font(.wooriCaption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.wooriSuccess)
                            .clipShape(Capsule())
                            .accessibilityLabel("완료된 코스")
                    }
                }

                HStack(spacing: Spacing.md) {
                    if let date = course.date {
                        Label(
                            DateHelper.shortFormatted(date.dateValue()),
                            systemImage: "calendar"
                        )
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextSecond)
                    }

                    Label("\(placeCount)곳", systemImage: "mappin.and.ellipse")
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriTextMuted)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.wooriTextMuted)
                .accessibilityHidden(true)
        }
        .padding(Spacing.md)
        .background(Color.wooriSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}
