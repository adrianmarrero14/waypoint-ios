import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

/// Zero-friction wave composer: one multiline text field, date defaults to
/// today but can be changed, nothing else required. Pass an existing `wave`
/// to edit it in place instead of creating a new one.
struct QuickAddView: View {
    @Environment(WaveStore.self) private var waveStore
    @Environment(\.dismiss) private var dismiss

    private let wave: Wave?
    @State private var text: String
    @State private var date: Date
    @FocusState private var isTextFocused: Bool

    init(initialDate: Date = .now, wave: Wave? = nil) {
        self.wave = wave
        _text = State(initialValue: wave?.text ?? "")
        _date = State(initialValue: wave?.date ?? initialDate)
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                TextField(
                    String(localized: "quickadd.placeholder", bundle: .module),
                    text: $text,
                    axis: .vertical
                )
                .font(.wpBody)
                .foregroundStyle(Color.wpTextPrimary)
                .lineLimit(3...8)
                .focused($isTextFocused)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.wpSurface)
                        .stroke(Color.wpSurfaceBorder, lineWidth: 2)
                )

                DatePicker(
                    selection: $date,
                    displayedComponents: .date
                ) {
                    Text("quickadd.date.label", bundle: .module)
                        .font(.wpBodyBold)
                        .foregroundStyle(Color.wpTextSecondary)
                }
                .tint(Color.wpOceanBlue)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        save()
                    } label: {
                        Text("quickadd.save", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.waypointPrimary)
                    .disabled(trimmedText.isEmpty)

                    if wave != nil {
                        Button(role: .destructive) {
                            deleteWave()
                        } label: {
                            Text("quickadd.delete", bundle: .module)
                                .font(.wpBodyBold)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.red)
                    }
                }
            }
            .padding(20)
            .background(Color.wpBackground)
            .navigationTitle(
                wave == nil
                    ? Text("quickadd.title", bundle: .module)
                    : Text("quickadd.edit.title", bundle: .module)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("quickadd.cancel", bundle: .module)
                    }
                    .tint(Color.wpLabelAccent)
                }
            }
        }
        .onAppear { isTextFocused = true }
        .presentationDetents([.medium])
    }

    private func save() {
        guard !trimmedText.isEmpty else { return }
        if let wave {
            waveStore.update(wave, text: trimmedText, date: date)
        } else {
            waveStore.createWave(text: trimmedText, date: date)
        }
        dismiss()
    }

    private func deleteWave() {
        guard let wave else { return }
        waveStore.delete(wave)
        dismiss()
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    Color.clear.sheet(isPresented: .constant(true)) {
        QuickAddView()
    }
    .modelContainer(container)
    .environment(PreviewData.makeStore(container: container))
}
