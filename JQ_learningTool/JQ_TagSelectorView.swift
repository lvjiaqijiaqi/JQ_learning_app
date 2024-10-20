import SwiftUI
import SwiftData

struct JQ_TagSelectorView: View {
    @Query private var allTags: [JQ_Tag]
    @Binding var selectedTags: Set<JQ_Tag>
    
    var body: some View {
        List {
            ForEach(allTags) { tag in
                MultipleSelectionRow(tag: tag, isSelected: selectedTags.contains(tag)) { isSelected in
                    if isSelected {
                        selectedTags.insert(tag)
                    } else {
                        selectedTags.remove(tag)
                    }
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    let tag: JQ_Tag
    let isSelected: Bool
    let action: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            action(!isSelected)
        }) {
            HStack {
                Text(tag.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
                Circle()
                    .fill(tag.uiColor)
                    .frame(width: 20, height: 20)
            }
        }
        .foregroundColor(.primary)
    }
}
