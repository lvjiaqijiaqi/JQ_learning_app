import SwiftUI
import SwiftData

struct JQ_NoteContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [JQ_Note]
    @State private var showingAddNote = false
    @State private var showingTagManagement = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NavigationLink(destination: JQ_NoteDetailView(note: note)) {
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content.prefix(50))
                                .lineLimit(1)
                            Text(note.tags.map { $0.name }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(note.creationDate, style: .date)
                                .font(.caption)
                            Text(note.status == .complete ? "已完成" : "未完成")
                                .font(.caption)
                                .foregroundColor(note.status == .complete ? .green : .blue)
                        }
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("英语笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingAddNote = true }) {
                            Image(systemName: "plus")
                        }
                        Button(action: { showingTagManagement = true }) {
                            Image(systemName: "tag")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                JQ_AddNoteView()
            }
            .sheet(isPresented: $showingTagManagement) {
                JQ_TagManagementView()
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(notes[index])
            }
        }
    }
}
