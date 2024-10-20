import SwiftUI
import SwiftData
import NaturalLanguage

struct JQ_NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var note: JQ_Note
    
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedLevel: Int
    @State private var selectedTags: Set<JQ_Tag>
    @State private var isEditing = false
    @State private var showingCheckInAlert = false
    @State private var checkInAlertMessage = ""
    @State private var isPlaying = false
    @State private var newComment = ""
    @State private var translatedContent: String?
    @State private var isTranslating = false
    @State private var translationError: String?
    
    private let speechSynthesizer = JQ_SpeechSynthesizer()
    
    init(note: JQ_Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedLevel = State(initialValue: note.level)
        _selectedTags = State(initialValue: Set(note.tags))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    editingView
                } else {
                    displayView
                }
                
                commentsSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isEditing ? "编辑笔记" : note.title)
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "完成" : "编辑")
                }
            }
        }
        .alert(isPresented: $showingCheckInAlert) {
            Alert(title: Text("打卡提醒"), message: Text(checkInAlertMessage), dismissButton: .default(Text("确定")))
        }
    }
    
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title)
                        .font(.title)
                        .fontWeight(.bold)
                    HStack {
                        Text(note.levelText)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(note.levelColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                        Button(action: attemptCheckIn) {
                            Label("打卡", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        Button(action: toggleSpeech) {
                            Label(isPlaying ? "停止" : "播放", systemImage: isPlaying ? "stop.circle" : "play.circle")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            Text(note.content)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if let translated = translatedContent {
                Text(translated)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            if let error = translationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: translateContent) {
                if isTranslating {
                    ProgressView()
                } else {
                    Text(translatedContent == nil ? "翻译成中文" : "重新翻译")
                }
            }
            .disabled(isTranslating)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "calendar")
                    Text("创建时间: \(formattedDate(note.creationDate))")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("最近打卡: \(formattedDate(note.lastCheckInDate))")
                }
                HStack {
                    Image(systemName: "book.fill")
                    Text("学习次数: \(note.studyCount)")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !note.tags.isEmpty {
                Text("标签")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(note.tags) { tag in
                            Text(tag.name)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag.uiColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .onReceive(speechSynthesizer.$isFinishedSpeaking) { finished in
            if finished {
                isPlaying = false
            }
        }
    }
    
    private func translateContent() {
        Task {
            let translatedText = await JQ_TranslationService.translate(note.content, from: "auto", to: "zh-Hans")
            await MainActor.run {
                self.translatedContent = translatedText
                self.isTranslating = false
            }
        }
    }
    
    private var editingView: some View {
        Form {
            Section(header: Text("标题")) {
                TextField("标题", text: $editedTitle)
            }
            
            Section(header: Text("熟练度")) {
                Picker("熟练度", selection: $editedLevel) {
                    Text("初学").tag(0)
                    Text("了解").tag(1)
                    Text("熟练").tag(2)
                    Text("精通").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("内容")) {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 150)
            }
            
            Section(header: Text("标签")) {
                JQ_TagSelectorView(selectedTags: $selectedTags)
            }
            
            Section {
                Button("保存更改") {
                    saveChanges()
                }
            }
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("评论")
                .font(.headline)
            
            ForEach(note.comments, id: \.self) { comment in
                VStack(alignment: .leading) {
                    Text(comment.content)
                    Text(formattedDate(comment.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            HStack {
                TextField("添加评论", text: $newComment)
                Button("发送") {
                    addComment()
                }
                .disabled(newComment.isEmpty)
            }
        }
    }
    
    private func saveChanges() {
        note.title = editedTitle
        note.content = editedContent
        note.level = editedLevel
        note.tags = Array(selectedTags)
        
        for tag in selectedTags {
            if !tag.notes.contains(note) {
                tag.notes.append(note)
            }
        }
        
        for tag in Set(note.tags).subtracting(selectedTags) {
            tag.notes.removeAll { $0.id == note.id }
        }
        
        isEditing = false
    }
    
    private func attemptCheckIn() {
        let currentTime = Date()
        let timeSinceLastCheckIn = currentTime.timeIntervalSince(note.lastCheckInDate)
        let minimumInterval: TimeInterval = 60 * 60 // 60 minutes in seconds
        
        if timeSinceLastCheckIn >= minimumInterval {
            checkIn()
        } else {
            let remainingTime = Int((minimumInterval - timeSinceLastCheckIn) / 60)
            checkInAlertMessage = "距离上次打卡还不到60分钟，请在\(remainingTime)分钟后再试。"
            showingCheckInAlert = true
        }
    }
    
    private func checkIn() {
        note.studyCount += 1
        note.lastCheckInDate = Date()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func toggleSpeech() {
        if isPlaying {
            speechSynthesizer.stopSpeaking()
            isPlaying = false
        } else {
            speechSynthesizer.speak(note.content)
            isPlaying = true
        }
    }
    
    private func addComment() {
        let comment = JQ_Comment(content: newComment)
        note.comments.append(comment)
        newComment = ""
    }
}

// TagToggle 结构体保持不变
