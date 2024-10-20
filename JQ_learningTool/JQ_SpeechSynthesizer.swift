import Foundation
import AVFoundation
import Combine

class JQ_SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isFinishedSpeaking = true
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN") // 使用中文语音
        synthesizer.speak(utterance)
        isFinishedSpeaking = false
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // AVSpeechSynthesizerDelegate 方法
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isFinishedSpeaking = true
    }
}
