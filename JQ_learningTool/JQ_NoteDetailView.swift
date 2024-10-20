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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    editingView
                } else {
                    displayView
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "编辑笔记" : note.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: checkIn) {
                        Image(systemName: "checkmark.circle")
                    }
                    Button(action: {
                        if isEditing {
                            saveChanges()
                        }
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "保存" : "编辑")
                    }
                }
            }
        }
    }
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("标题", text: $editedTitle)
                .font(.title)
            
            TextEditor(text: $editedContent)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Stepper("熟练度等级: \(editedLevel)", value: $editedLevel, in: 0...23)
            
            Text("标签")
                .font(.headline)
            JQ_TagSelectorView(selectedTags: $selectedTags)
                .frame(height: 150)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(note.title)
                    .font(.title)
                Spacer()
                Text("Level \(note.level)")
                    .font(.headline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelColor(for: note.level))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text(note.content)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            HStack {
                Image(systemName: "calendar")
                Text("创建时间: \(note.creationDate, style: .date)")
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
    }
    
    private func checkIn() {
        note.studyCount += 1
    }
    
    private func levelColor(for level: Int) -> Color {
        let hue = Double(level) / 23.0 * 0.3 // 0.3 is the hue for green
        return Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }
}

// TagToggle 结构体保持不变
