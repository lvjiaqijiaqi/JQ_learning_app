import SwiftUI
import SwiftData

struct JQ_NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var note: JQ_Note
    
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedStatus: NoteStatus
    @State private var selectedTags: Set<JQ_Tag>
    @State private var isEditing = false
    
    init(note: JQ_Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedStatus = State(initialValue: note.status)
        _selectedTags = State(initialValue: Set(note.tags))
    }
    
    var body: some View {
        Form {
            if isEditing {
                TextField("标题", text: $editedTitle)
                TextEditor(text: $editedContent)
                    .frame(minHeight: 200)
                
                Picker("状态", selection: $editedStatus) {
                    Text("未完成").tag(NoteStatus.uncomplete)
                    Text("已完成").tag(NoteStatus.complete)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Section(header: Text("标签")) {
                    JQ_TagSelectorView(selectedTags: $selectedTags)
                }
            } else {
                Text(note.title)
                    .font(.headline)
                Text(note.content)
                Text("状态: \(note.status == .complete ? "已完成" : "未完成")")
                Text("创建时间: \(note.creationDate, style: .date)")
                
                Section(header: Text("标签")) {
                    ForEach(note.tags) { tag in
                        HStack {
                            Text(tag.name)
                            Spacer()
                            Circle()
                                .fill(tag.uiColor)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "编辑笔记" : note.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
    
    private func saveChanges() {
        note.title = editedTitle
        note.content = editedContent
        note.status = editedStatus
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
}

// TagToggle 结构体保持不变
