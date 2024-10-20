import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case level = "熟练度"
    case studyCount = "学习次数"
    case date = "创建日期"
}

struct JQ_NoteContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [JQ_Note]
    @Query private var allTags: [JQ_Tag]
    @State private var showingAddNote = false
    @State private var selectedTag: JQ_Tag?
    @State private var sortOption: SortOption = .date
    @State private var sortAscending = false
    @State private var showingFilterSort = false
    
    var filteredAndSortedNotes: [JQ_Note] {
        let filtered = selectedTag == nil ? allNotes : allNotes.filter { $0.tags.contains(selectedTag!) }
        return filtered.sorted { note1, note2 in
            switch sortOption {
            case .level:
                return sortAscending ? note1.level < note2.level : note1.level > note2.level
            case .studyCount:
                return sortAscending ? note1.studyCount < note2.studyCount : note1.studyCount > note2.studyCount
            case .date:
                return sortAscending ? note1.creationDate < note2.creationDate : note1.creationDate > note2.creationDate
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredAndSortedNotes) { note in
                    NavigationLink(destination: JQ_NoteDetailView(note: note)) {
                        noteRow(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("英语笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilterSort = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                JQ_AddNoteView()
            }
            .sheet(isPresented: $showingFilterSort) {
                filterSortView
            }
        }
    }
    
    private func noteRow(note: JQ_Note) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                Spacer()
                Text(note.levelText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(note.levelColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
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
                Text("创建: \(formattedDate(note.creationDate))")
                Spacer()
                Image(systemName: "checkmark.circle")
                Text("最近打卡: \(formattedDate(note.lastCheckInDate))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private var filterSortView: some View {
        NavigationView {
            Form {
                Section(header: Text("筛选")) {
                    Picker("标签", selection: $selectedTag) {
                        Text("全部").tag(nil as JQ_Tag?)
                        ForEach(allTags) { tag in
                            Text(tag.name).tag(tag as JQ_Tag?)
                        }
                    }
                }
                
                Section(header: Text("排序")) {
                    Picker("排序方式", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    Toggle("升序", isOn: $sortAscending)
                }
            }
            .navigationTitle("筛选和排序")
            .navigationBarItems(trailing: Button("完成") {
                showingFilterSort = false
            })
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredAndSortedNotes[index])
            }
        }
    }
    
    private func levelColor(for level: Int) -> Color {
        let hue = Double(level) / 23.0 * 0.3 // 0.3 is the hue for green
        return Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }
}
