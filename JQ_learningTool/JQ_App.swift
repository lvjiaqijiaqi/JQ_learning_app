import SwiftUI
import SwiftData

@main
struct JQ_App: App {
    var body: some Scene {
        WindowGroup {
            JQ_ContentView()
        }
        .modelContainer(for: [JQ_Note.self, JQ_Tag.self, JQ_Comment.self])
    }
}
