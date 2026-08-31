import SwiftUI

/// Global brand styling for UIKit-backed chrome that SwiftUI can't style
/// directly (navigation bar titles). Call once at app launch.
public enum WaypointAppearance {
    public static func apply() {
        WaypointFont.register()
        #if canImport(UIKit)
        let navy = UIColor(Color.wpDeepNavy)
        let appearance = UINavigationBar.appearance()
        if let large = UIFont(name: WaypointFont.Fredoka.semiBold.rawValue, size: 32) {
            appearance.largeTitleTextAttributes = [.font: large, .foregroundColor: navy]
        }
        if let inline = UIFont(name: WaypointFont.Fredoka.semiBold.rawValue, size: 19) {
            appearance.titleTextAttributes = [.font: inline, .foregroundColor: navy]
        }
        #endif
    }
}
