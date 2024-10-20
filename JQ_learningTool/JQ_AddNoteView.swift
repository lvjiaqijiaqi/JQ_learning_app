import SwiftUI
import SwiftData

struct JQ_AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allTags: [JQ_Tag]
    
    @State private var title = ""
    @State private var content = ""
    @State private var status: NoteStatus = .uncomplete
    @State private var selectedTags: Set<JQ_Tag> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("标题")) {
                    TextField("输入标题", text: $title)
                }
                
                Section(header: Text("内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section(header: Text("状态")) {
                    Picker("状态", selection: $status) {
                        Text("未完成").tag(NoteStatus.uncomplete)
                        Text("已完成").tag(NoteStatus.complete)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("标签")) {
                    ForEach(allTags) { tag in
                        TagToggle(tag: tag, isSelected: selectedTags.contains(tag)) { isOn in
                            if isOn {
                                selectedTags.insert(tag)
                            } else {
                                selectedTags.remove(tag)
                            }
                        }
                    }
                }
            }
            .navigationTitle("添加笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveNote()
                    }
                }
            }
        }
    }
    
    private func saveNote() {
        let newNote = JQ_Note(title: title, content: content, status: status)
        newNote.tags = Array(selectedTags)
        modelContext.insert(newNote)
        
        for tag in selectedTags {
            tag.notes.append(newNote)
        }
        
        dismiss()
    }
}

struct TagToggle: View {
    let tag: JQ_Tag
    let isSelected: Bool
    let action: (Bool) -> Void
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { isSelected },
            set: { action($0) }
        )) {
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
