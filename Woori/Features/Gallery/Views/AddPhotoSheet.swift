import SwiftUI
import PhotosUI

struct AddPhotoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var caption = ""
    @State private var selectedPlaceId: String?
    let places: [Place]
    let onSave: (UIImage, String?, String?) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wooriBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // Photo Picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: Spacing.sm) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.wooriTextMuted)
                                    Text("사진을 선택해주세요")
                                        .font(.wooriBody)
                                        .foregroundStyle(Color.wooriTextMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.wooriSurfaceWarm)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }

                        WooriTextField(placeholder: "캡션 (선택)", text: $caption)

                        // Place Picker
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("장소 연결 (선택)")
                                .font(.wooriCaption)
                                .foregroundStyle(Color.wooriTextSecond)

                            Picker("장소", selection: $selectedPlaceId) {
                                Text("없음").tag(String?.none)
                                ForEach(places) { place in
                                    Text(place.name).tag(Optional(place.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.wooriPrimary)
                        }
                        .wooriCard()
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("사진 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(Color.wooriTextSecond)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        guard let image = selectedImage else { return }
                        onSave(image, caption.isEmpty ? nil : caption, selectedPlaceId)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.wooriPrimary)
                    .disabled(selectedImage == nil)
                }
            }
        }
    }
}
