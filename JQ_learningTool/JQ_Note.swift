import Foundation
import SwiftData

enum NoteStatus: Int, Codable {
    case uncomplete
    case complete
}

@Model
final class JQ_Tag {
    
    var name: String
    var notes: [JQ_Note]
    
    init(name: String) {
        self.name = name
        self.notes = []
    }
}

@Model
final class JQ_Note {
    
    var title: String
    var content: String
    var creationDate: Date
    var status: NoteStatus
    
    @Relationship(inverse: \JQ_Tag.notes)
    var tags: [JQ_Tag]
    
    init(title: String, content: String, status: NoteStatus = .uncomplete) {
        self.title = title
        self.content = content
        self.tags = []
        self.creationDate = Date()
        self.status = status
    }
}
