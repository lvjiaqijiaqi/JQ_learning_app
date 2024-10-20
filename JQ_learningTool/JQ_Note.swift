import Foundation
import SwiftData
import SwiftUI

enum NoteStatus: String, Codable {
    case uncomplete
    case complete
}

@Model
final class JQ_Tag {
    var name: String
    var color: String // 使用字符串存储颜色
    var notes: [JQ_Note]
    
    init(name: String, color: String = "FF0000") { // 默认红色
        self.name = name
        self.color = color
        self.notes = []
    }
    
    var uiColor: Color {
        Color(hex: color) ?? .red
    }
}

extension JQ_Tag: Hashable {
    static func == (lhs: JQ_Tag, rhs: JQ_Tag) -> Bool {
        lhs.name == rhs.name && lhs.color == rhs.color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(color)
    }
}

@Model
final class JQ_Note {
    var title: String
    var content: String
    @Relationship(inverse: \JQ_Tag.notes) var tags: [JQ_Tag]
    var creationDate: Date
    var status: NoteStatus
    
    init(title: String, content: String, status: NoteStatus = .uncomplete) {
        self.title = title
        self.content = content
        self.tags = []
        self.creationDate = Date()
        self.status = status
    }
}

// 辅助扩展，用于将十六进制颜色字符串转换为 Color
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
}
