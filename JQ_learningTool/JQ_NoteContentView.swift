import SwiftUI
import SwiftData

struct JQ_NoteContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [JQ_Note]
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NavigationLink(destination: JQ_NoteDetailView(note: note)) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.content.prefix(50))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                HStack {
                                    ForEach(note.tags) { tag in
                                        Text(tag.name)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(tag.uiColor.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.secondary)
                                    Text(note.creationDate, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: note.status == .complete ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(note.status == .complete ? .green : .gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("英语笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                JQ_AddNoteView()
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
