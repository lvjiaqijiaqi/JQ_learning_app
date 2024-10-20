import SwiftUI
import SwiftData

struct JQ_TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [JQ_Tag]
    @State private var newTagName = ""
    @State private var newTagColor = Color.red
    @State private var editingTag: JQ_Tag?
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("添加新标签")) {
                    HStack {
                        TextField("新标签名称", text: $newTagName)
                        ColorPicker("", selection: $newTagColor)
                        Button("添加") {
                            addNewTag()
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
                
                Section(header: Text("现有标签")) {
                    ForEach(tags) { tag in
                        HStack {
                            if editingTag?.id == tag.id {
                                TextField("编辑标签", text: Binding(
                                    get: { self.editingTag?.name ?? "" },
                                    set: { self.editingTag?.name = $0 }
                                ))
                                ColorPicker("", selection: Binding(
                                    get: { self.editingTag?.uiColor ?? .red },
                                    set: { self.editingTag?.color = $0.toHex() ?? "FF0000" }
                                ))
                                .onChange(of: editingTag?.color) { _ in
                                    saveEditedTag()
                                }
                            } else {
                                Text(tag.name)
                                Spacer()
                                Circle()
                                    .fill(tag.uiColor)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .onTapGesture {
                            if editingTag == nil {
                                editingTag = tag
                            } else {
                                saveEditedTag()
                            }
                        }
                    }
                    .onDelete(perform: deleteTags)
                }
            }
            .navigationTitle("管理标签")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func addNewTag() {
        let newTag = JQ_Tag(name: newTagName, color: newTagColor.toHex() ?? "FF0000")
        modelContext.insert(newTag)
        newTagName = ""
        newTagColor = .red
    }
    
    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tags[index])
        }
    }
    
    private func saveEditedTag() {
        editingTag = nil
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
