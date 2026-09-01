import AVFoundation
import Combine
import os.log

/// The water's voice. Not a sound added to the piece: the piece's
/// own motion, heard. The same tide that carries the motes is what
/// murmurs — the water speaks as the tide *turns*, so the slack
/// water is quiet, and the flood and the ebb speak. The same storm
/// that darkens the water is what falls as rain. And a moving hand
/// is what swishes, the way the sea swishes where a wave breaks —
/// the same hand that makes the wake makes the swish, and a still
/// hand makes neither: a still hand is only a lamp.
///
/// The voice is made, not played: noise the water itself draws,
/// shaped by the same functions that move the water. Nothing in it
/// is a recording; everything in it is the water.
final class WaterVoice: ObservableObject {

    /// Whether the water is speaking at all. The slack water is
    /// quiet, and the water knows it the way the water knows
    /// everything: only for a moment.
    @Published private(set) var speaking = false

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private let format: AVAudioFormat
    private var started = false

    // The world's targets for the voice, set by the piece a few
    // times a second, and copied to the render thread under a lock.
    // The water eases toward them, the way water eases.
    private let targetLock = NSLock()
    private var murmurTarget: Double = 0
    private var rainTarget: Double = 0
    private var swishTarget: Double = 0
    private var cutoffTarget: Double = 500

    // The render state, touched only on the audio thread.
    private var rngState: UInt64 = 0x564F4345 // "VOCE" in hex: the voice
    private var brown: Double = 0
    private var murmurLow: Double = 0
    private var rainLow: Double = 0
    private var swishLow: Double = 0
    private var murmurGain: Double = 0
    private var rainGain: Double = 0
    private var swishGain: Double = 0
    private var level: Double = 0
    private var framesSinceLevelLog: Int = 0

    init() {
        // the water's own clock of samples: forty-four thousand a
        // second, one channel — the voice is one voice. The engine's
        // graph is not built here: the water's audio service is
        // spoken to only when the water is actually going to speak.
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
            ?? AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1)!
    }

    // The voice's own quiet thread: the water's audio service is
    // spoken to off the piece's main thread, the way one speaks
    // softly — the piece keeps moving while the voice comes up
    private let voiceLock = NSLock()

    /// The voice begins when the piece appears, and ends when it
    /// goes away, the way a voice does.
    func start() {
        voiceLock.lock()
        guard !started else {
            voiceLock.unlock()
            return
        }
        // the water does not speak in the test harness: the
        // harness's audio service answers slowly, and the voice
        // would rather be quiet than be late
        guard NSClassFromString("XCTestCase") == nil else {
            voiceLock.unlock()
            return
        }
        started = true
        voiceLock.unlock()
        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            do {
                let session = AVAudioSession.sharedInstance()
                // the voice is the water's, not the room's: it mixes
                // with whatever else the room is doing, and obeys the
                // room's quiet
                try session.setCategory(.ambient, options: [.mixWithOthers])
                try session.setActive(true)
                if self.source == nil {
                    // the graph is built only once the session is up,
                    // and the water's own noise is what the voice is
                    // made of
                    let node = AVAudioSourceNode(format: self.format) { [weak self] _, _, frameCount, outputData in
                        guard let self else { return 0 }
                        self.render(frameCount: frameCount, outputData: outputData)
                        return 0
                    }
                    self.engine.attach(node)
                    self.engine.connect(node, to: self.engine.outputNode, format: self.format)
                    self.engine.prepare()
                    self.source = node
                }
                try self.engine.start()
                os_log("fb voice: the water's voice is running")
            } catch {
                os_log("fb voice: the water's voice could not start: %{public}@", error.localizedDescription)
                // the voice may be tried again when the piece
                // appears next
                self.voiceLock.lock()
                self.started = false
                self.voiceLock.unlock()
            }
        }
    }

    func stop() {
        voiceLock.lock()
        guard started else {
            voiceLock.unlock()
            return
        }
        started = false
        voiceLock.unlock()
        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            if self.engine.isRunning {
                self.engine.stop()
            }
            if let node = self.source {
                self.engine.detach(node)
            }
            self.source = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    /// The piece tells the voice what it is doing: how fast the
    /// current is turning (the murmur), how much storm is over the
    /// water (the rain), the swish where the hand has been (the
    /// water's answer, heard), and how low the voice should sit
    /// (lower, in the water's night). The voice eases toward each
    /// of them, the way water eases.
    func update(murmur: Double, rain: Double, swish: Double, cutoff: Double) {
        targetLock.lock()
        murmurTarget = murmur
        rainTarget = rain
        swishTarget = swish
        cutoffTarget = cutoff
        targetLock.unlock()
        let isSpeaking = murmur + rain + swish > 0.03
        if isSpeaking != speaking {
            speaking = isSpeaking
        }
    }

    private func pullTargets() -> (murmur: Double, rain: Double, swish: Double, cutoff: Double) {
        targetLock.lock()
        defer { targetLock.unlock() }
        return (murmurTarget, rainTarget, swishTarget, cutoffTarget)
    }

    private func render(frameCount: AVAudioFrameCount, outputData: UnsafeMutablePointer<AudioBufferList>) {
        guard frameCount > 0 else { return }
        var buffer = outputData.pointee.mBuffers
        guard let pointer = buffer.mData else { return }
        let samples = pointer.assumingMemoryBound(to: Float.self)
        let target = pullTargets()
        // where the deep voice sits: lower in the water's night,
        // the way a sleeper's voice is lower
        let cutoffAlpha = 1 - exp(-2 * .pi * target.cutoff / Double(format.sampleRate))

        var sum: Double = 0
        for frame in 0..<Int(frameCount) {
            // the water's own noise: a draw of white, remembered
            // into brown
            rngState ^= rngState << 13
            rngState ^= rngState >> 7
            rngState ^= rngState << 17
            let white = (Double(rngState & 0x00FFFFFF) / 0x800_000 - 1) * 0.9
            brown = (brown + 0.02 * white) * 0.999
            // the murmur: the brown water, low-passed — the deep
            // voice of the current
            murmurLow += cutoffAlpha * (brown - murmurLow)
            // the rain and the swish: the same draw, hissed into
            // the high — the falling ones, and the parting
            rainLow += 0.012 * (white - rainLow)
            let rainHiss = white - rainLow
            swishLow += 0.05 * (white - swishLow)
            let swishHiss = white - swishLow
            // the voice eases toward what the water is doing, the
            // way water eases: the murmur slowly, the rain at the
            // storm's pace, the swish at the hand's
            murmurGain += (target.murmur - murmurGain) * 0.002
            rainGain += (target.rain - rainGain) * 0.006
            swishGain += (target.swish - swishGain) * 0.05
            var out = murmurLow * murmurGain * 2.4
                + rainHiss * rainGain * 1.2
                + swishHiss * swishGain
            // a soft edge, the way the water has soft edges
            out = tanh(out * 1.4) / tanh(1.4)
            samples[frame] = Float(out)
            sum += out * out
        }
        level = (sum / Double(frameCount)).squareRoot()
        framesSinceLevelLog -= Int(frameCount)
        if framesSinceLevelLog <= 0 {
            framesSinceLevelLog = Int(44_100 * 8)
            os_log("fb voice: level %f", level)
        }
    }
}
