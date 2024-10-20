import SwiftUI
import SwiftData

struct JQ_TagManagementView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [JQ_Tag]
    @State private var newTagName = ""
    @State private var editingTag: JQ_Tag?
    @State private var selectedTag: JQ_Tag?
    
    var body: some View {
        NavigationView {
            List {
                addNewTagSection
                existingTagsSection
            }
            .navigationTitle("管理标签")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private var addNewTagSection: some View {
        Section(header: Text("添加新标签")) {
            HStack {
                TextField("新标签名称", text: $newTagName)
                Button("添加") {
                    addNewTag()
                }
                .disabled(newTagName.isEmpty)
            }
        }
    }
    
    private var existingTagsSection: some View {
        Section(header: Text("现有标签")) {
            ForEach(tags) { tag in
                tagRow(for: tag)
            }
            .onDelete(perform: deleteTags)
        }
    }
    
    private func tagRow(for tag: JQ_Tag) -> some View {
        HStack {
            if editingTag?.id == tag.id {
                TextField("编辑标签", text: Binding(
                    get: { self.editingTag?.name ?? "" },
                    set: { self.editingTag?.name = $0 }
                ))
                .onSubmit {
                    saveEditedTag()
                }
            } else {
                Text(tag.name)
                Spacer()
                Text("\(taggedNotesCount(for: tag)) 笔记")
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            if editingTag == nil {
                selectedTag = tag
            } else {
                editingTag = tag
            }
        }
    }
    
    private func addNewTag() {
        let newTag = JQ_Tag(name: newTagName)
        modelContext.insert(newTag)
        newTagName = ""
    }
    
    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tags[index])
        }
    }
    
    private func saveEditedTag() {
        editingTag = nil
    }
    
    private func taggedNotesCount(for tag: JQ_Tag) -> Int {
        return tag.notes.count
    }
}

