import Foundation
import AVFoundation

class JQ_SpeechSynthesizer: NSObject {
    private var synthesizer: AVSpeechSynthesizer
    private var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    private var pitch: Float = 1.0
    private var volume: Float = 1.0
    private var voice: AVSpeechSynthesisVoice?
    
    override init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
        synthesizer.delegate = self
        voice = AVSpeechSynthesisVoice(language: "en-US") // 默认使用英语声音
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = voice
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func setVoice(identifier: String) {
        voice = AVSpeechSynthesisVoice(identifier: identifier)
    }
    
    func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    func setRate(_ newRate: Float) {
        rate = newRate
    }
    
    func setPitch(_ newPitch: Float) {
        pitch = newPitch
    }
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
    }
}

extension JQ_SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // 可以在这里添加开始播放的回调
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 可以在这里添加结束播放的回调
    }
}
