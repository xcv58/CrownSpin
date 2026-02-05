import SwiftUI
import WidgetKit

@main
struct CrownSpinApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Widget bundle for complications - included in main app for watchOS 10+
struct CrownSpinWidgetBundle: WidgetBundle {
    var body: some Widget {
        CrownSpinWidget()
    }
}
