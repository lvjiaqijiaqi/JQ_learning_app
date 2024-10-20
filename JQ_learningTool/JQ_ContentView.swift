import SwiftUI

struct JQ_ContentView: View {
    var body: some View {
        TabView {
            JQ_NoteContentView()
                .tabItem {
                    Label("笔记", systemImage: "note.text")
                }
            
            JQ_ConfigureContentView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }
}
