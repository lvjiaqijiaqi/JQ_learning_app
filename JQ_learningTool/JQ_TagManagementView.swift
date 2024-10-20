import SwiftUI
import SwiftData

struct JQ_TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [JQ_Tag]
    @State private var newTagName = ""
    @State private var newTagColor = Color.red
    @State private var editingTag: JQ_Tag?
    @State private var showingColorPicker = false
    @State private var showingAddTag = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        List {
            ForEach(tags) { tag in
                TagRow(tag: tag, editAction: { editingTag = tag })
            }
            .onDelete(perform: deleteTags)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("管理标签")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }) {
                        Image(systemName: editMode == .active ? "checkmark" : "pencil")
                    }
                    
                    Button(action: { showingAddTag = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddTag) {
            AddTagView(modelContext: modelContext, showingAddTag: $showingAddTag)
        }
        .sheet(item: $editingTag) { tag in
            EditTagView(tag: tag, showingEditTag: Binding(
                get: { editingTag != nil },
                set: { if !$0 { editingTag = nil } }
            ))
        }
    }
    
    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tags[index])
        }
    }
}

struct TagRow: View {
    let tag: JQ_Tag
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(tag.uiColor)
                .frame(width: 20, height: 20)
            Text(tag.name)
            Spacer()
            Button(action: editAction) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    @Binding var showingAddTag: Bool
    @State private var tagName = ""
    @State private var tagColor = Color.red
    
    var body: some View {
        NavigationView {
            Form {
                TextField("标签名称", text: $tagName)
                ColorPicker("标签颜色", selection: $tagColor)
            }
            .navigationTitle("添加新标签")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    saveTag()
                    dismiss()
                }
                .disabled(tagName.isEmpty)
            )
        }
    }
    
    private func saveTag() {
        let newTag = JQ_Tag(name: tagName, color: tagColor.toHex() ?? "FF0000")
        modelContext.insert(newTag)
    }
}

struct EditTagView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var tag: JQ_Tag
    @Binding var showingEditTag: Bool
    @State private var editedName: String
    @State private var editedColor: Color
    
    init(tag: JQ_Tag, showingEditTag: Binding<Bool>) {
        self.tag = tag
        self._showingEditTag = showingEditTag
        self._editedName = State(initialValue: tag.name)
        self._editedColor = State(initialValue: tag.uiColor)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("标签名称", text: $editedName)
                ColorPicker("标签颜色", selection: $editedColor)
            }
            .navigationTitle("编辑标签")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    saveChanges()
                    dismiss()
                }
                .disabled(editedName.isEmpty)
            )
        }
    }
    
    private func saveChanges() {
        tag.name = editedName
        tag.color = editedColor.toHex() ?? "FF0000"
    }
}

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let hex = String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hex
    }
}
