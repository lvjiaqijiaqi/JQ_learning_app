import Foundation
import SwiftData
import SwiftUI

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
final class JQ_Comment {
    var content: String
    var date: Date
    
    init(content: String) {
        self.content = content
        self.date = Date()
    }
}

@Model
final class JQ_Note {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    @Relationship(inverse: \JQ_Tag.notes) var tags: [JQ_Tag]
    var creationDate: Date
    var lastCheckInDate: Date
    var level: Int
    var studyCount: Int
    @Relationship var comments: [JQ_Comment]
    
    init(title: String, content: String, level: Int = 0) {
        self.id = UUID().uuidString
        self.title = title
        self.content = content
        self.tags = []
        self.creationDate = Date()
        self.lastCheckInDate = Date()
        self.level = max(0, min(3, level))
        self.studyCount = 0
        self.comments = []
    }
    
    var levelText: String {
        switch level {
        case 0: return "初学"
        case 1: return "了解"
        case 2: return "熟练"
        case 3: return "精通"
        default: return "未知"
        }
    }
    
    var levelColor: Color {
        switch level {
        case 0: return .gray
        case 1: return .red
        case 2: return .yellow
        case 3: return .green
        default: return .gray
        }
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
