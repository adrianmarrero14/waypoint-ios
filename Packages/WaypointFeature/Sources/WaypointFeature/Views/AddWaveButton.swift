import DesignSystem
import SwiftUI

/// Toolbar button that opens the quick-add sheet.
struct AddWaveButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
        }
        .tint(Color.wpLabelAccent)
        .accessibilityLabel(Text("add.wave.accessibility", bundle: .module))
    }
}
