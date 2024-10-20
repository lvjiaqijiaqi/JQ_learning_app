import SwiftUI
import SwiftData

struct JQ_ConfigureContentView: View {
    @Query private var allTags: [JQ_Tag]
    @Query private var allNotes: [JQ_Note]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("标签统计")) {
                    HStack {
                        Text("总标签数")
                        Spacer()
                        Text("\(allTags.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总笔记数")
                        Spacer()
                        Text("\(allNotes.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总学习次数")
                        Spacer()
                        Text("\(totalStudyCount)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("标签情")) {
                    ForEach(allTags) { tag in
                        NavigationLink(destination: TagDetailView(tag: tag)) {
                            TagRowView(tag: tag)
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: JQ_TagManagementView()) {
                        Label("标签管理", systemImage: "tag")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
    
    private var totalStudyCount: Int {
        allNotes.reduce(0) { $0 + $1.studyCount }
    }
}

struct TagRowView: View {
    let tag: JQ_Tag
    
    var body: some View {
        HStack {
            Circle()
                .fill(tag.uiColor)
                .frame(width: 20, height: 20)
            Text(tag.name)
            Spacer()
            Text("\(tag.notes.count) 笔记")
                .foregroundColor(.secondary)
        }
    }
}

struct TagDetailView: View {
    let tag: JQ_Tag
    
    var body: some View {
        List {
            Section(header: Text("统计信息")) {
                HStack {
                    Text("关联笔记数")
                    Spacer()
                    Text("\(tag.notes.count)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("总学习次数")
                    Spacer()
                    Text("\(totalStudyCount)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("平均熟练度")
                    Spacer()
                    Text(String(format: "%.1f", averageLevel))
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("关联笔记")) {
                ForEach(tag.notes) { note in
                    NavigationLink(destination: JQ_NoteDetailView(note: note)) {
                        VStack(alignment: .leading) {
                            Text(note.title)
                            HStack {
                                Text("学习次数: \(note.studyCount)")
                                Spacer()
                                Text(note.levelText)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(note.levelColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            Text("最近打卡: \(formattedDate(note.lastCheckInDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(tag.name)
    }
    
    private var totalStudyCount: Int {
        tag.notes.reduce(0) { $0 + $1.studyCount }
    }
    
    private var averageLevel: Double {
        guard !tag.notes.isEmpty else { return 0 }
        let totalLevel = tag.notes.reduce(0) { $0 + $1.level }
        return Double(totalLevel) / Double(tag.notes.count)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
