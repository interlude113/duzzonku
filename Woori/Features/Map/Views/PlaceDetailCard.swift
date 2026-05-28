import SwiftUI

struct PlaceDetailCard: View {
    let place: Place?
    let coursePlace: CoursePlace?
    let courseName: String?
    let onDelete: (() async -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(displayName)
                        .font(.wooriTitle)
                        .foregroundStyle(.wooriTextPrimary)

                    if let address = displayAddress, !address.isEmpty {
                        Text(address)
                            .font(.wooriCaption)
                            .foregroundStyle(.wooriTextSecond)
                    }
                }
                Spacer()
                categoryBadge
            }

            // Course info
            if let courseName {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.wooriPrimary)
                        .accessibilityHidden(true)
                    Text("포함된 코스: \(courseName)")
                        .font(.wooriCaption)
                        .foregroundStyle(.wooriPrimary)
                }
                .padding(Spacing.sm)
                .background(Color.wooriPrimaryLight.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Memo
            if let memo = displayMemo, !memo.isEmpty {
                Text(memo)
                    .font(.wooriBody)
                    .foregroundStyle(.wooriTextSecond)
            }

            // Delete button (normal places only)
            if place != nil, let onDelete {
                Button(role: .destructive) {
                    Task {
                        await onDelete()
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .accessibilityHidden(true)
                        Text("장소 삭제")
                    }
                    .font(.wooriBody)
                    .foregroundStyle(.wooriError)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
        .padding(Spacing.lg)
        .presentationDetents([.medium])
    }

    private var displayName: String {
        place?.name ?? coursePlace?.name ?? ""
    }

    private var displayAddress: String? {
        place?.address ?? coursePlace?.address
    }

    private var displayMemo: String? {
        place?.memo
    }

    private var displayCategory: String {
        place?.category ?? coursePlace?.category ?? ""
    }

    private var categoryBadge: some View {
        Text(displayCategory)
            .font(.wooriCaption)
            .foregroundStyle(.wooriPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.wooriPrimaryLight)
            .clipShape(Capsule())
    }
}
