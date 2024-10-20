import SwiftUI
import SwiftData

struct JQ_NoteDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var note: JQ_Note
    
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedLevel: Int
    @State private var selectedTags: Set<JQ_Tag>
    @State private var isEditing = false
    
    init(note: JQ_Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedLevel = State(initialValue: note.level)
        _selectedTags = State(initialValue: Set(note.tags))
    }
    
    var body: some View {
        Group {
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isEditing ? "编辑笔记" : note.title)
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "完成" : "编辑")
                }
            }
        }
    }
    
    private var displayView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(note.title)
                        .font(.title)
                    Spacer()
                    Button(action: checkIn) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    Text(note.levelText)
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(note.levelColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text(note.content)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                HStack {
                    Image(systemName: "calendar")
                    Text("创建时间: \(formattedDate(note.creationDate))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("最近打卡: \(formattedDate(note.lastCheckInDate))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "book.fill")
                    Text("学习次数: \(note.studyCount)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !note.tags.isEmpty {
                    Text("标签")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(note.tags) { tag in
                                Text(tag.name)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(tag.uiColor.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var editingView: some View {
        Form {
            Section(header: Text("标题")) {
                TextField("标题", text: $editedTitle)
            }
            
            Section(header: Text("熟练度")) {
                Picker("熟练度", selection: $editedLevel) {
                    Text("初学").tag(0)
                    Text("了解").tag(1)
                    Text("熟练").tag(2)
                    Text("精通").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("内容")) {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 150)
            }
            
            Section(header: Text("标签")) {
                JQ_TagSelectorView(selectedTags: $selectedTags)
            }
            
            Section {
                Button("保存更改") {
                    saveChanges()
                }
            }
        }
    }
    
    private func saveChanges() {
        note.title = editedTitle
        note.content = editedContent
        note.level = editedLevel
        note.tags = Array(selectedTags)
        
        // 更新每个标签的 notes 数组
        for tag in selectedTags {
            if !tag.notes.contains(note) {
                tag.notes.append(note)
            }
        }
        
        // 从未选中的标签中移除此笔记
        for tag in Set(note.tags).subtracting(selectedTags) {
            tag.notes.removeAll { $0.id == note.id }
        }
        
        isEditing = false
    }
    
    private func checkIn() {
        note.studyCount += 1
        note.lastCheckInDate = Date()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// TagToggle 结构体保持不变
