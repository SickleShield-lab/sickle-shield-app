import Foundation
import Speech
import AVFoundation

@MainActor
final class VoiceLogger: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcript = ""
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start() {
        guard !isRecording else { return }
        errorMessage = nil
        transcript = ""

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                guard status == .authorized else {
                    self.errorMessage = "Speech recognition is off. Enable it in Settings > Privacy > Speech Recognition."
                    return
                }
                AVAudioApplication.requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else {
                            self.errorMessage = "Microphone access is off. Enable it in Settings > Privacy > Microphone."
                            return
                        }
                        self.beginRecording()
                    }
                }
            }
        }
    }

    private func beginRecording() {
        let engine = AVAudioEngine()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Couldn't start the microphone."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        do {
            try engine.start()
        } catch {
            errorMessage = "Couldn't start the microphone."
            return
        }

        audioEngine = engine
        self.request = request
        isRecording = true

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stop()
                }
            }
        }
    }

    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        audioEngine = nil
        request = nil
        task = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

/// Rough keyword extraction from a voice transcript like "log pain 8, lower
/// back, started after being out in the cold" - not real NLU, just enough
/// to pre-fill the form so the person confirms rather than types from scratch.
enum VoiceCrisisParser {
    struct Result {
        let rating: Int?
        let location: String?
        let triggers: [String]
    }

    private static let locations = [
        "lower back", "back", "leg", "arm", "chest", "knee", "shoulder",
        "hip", "abdomen", "stomach", "joint", "head"
    ]

    private static let triggerKeywords: [(String, String)] = [
        ("dehydrat", "Dehydration"),
        ("cold", "Cold"),
        ("stress", "Stress"),
    ]

    static func parse(_ text: String) -> Result {
        let lower = text.lowercased()

        var rating: Int?
        if let match = lower.range(of: #"\b(10|[0-9])\b"#, options: .regularExpression) {
            rating = Int(lower[match])
        }

        let location = locations.first { lower.contains($0) }
        let triggers = triggerKeywords.filter { lower.contains($0.0) }.map(\.1)

        return Result(rating: rating, location: location, triggers: triggers)
    }
}
