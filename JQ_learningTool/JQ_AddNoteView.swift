import SwiftUI
import SwiftData

struct JQ_AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var level = 0
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
                
                Section(header: Text("熟练度")) {
                    Picker("熟练度", selection: $level) {
                        Text("初学").tag(0)
                        Text("了解").tag(1)
                        Text("熟练").tag(2)
                        Text("精通").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("标签")) {
                    JQ_TagSelectorView(selectedTags: $selectedTags)
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
        let newNote = JQ_Note(title: title, content: content, level: level)
        newNote.tags = Array(selectedTags)
        modelContext.insert(newNote)
        
        for tag in selectedTags {
            tag.notes.append(newNote)
        }
        
        dismiss()
    }
}
