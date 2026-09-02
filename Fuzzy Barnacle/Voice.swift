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
/// hand makes neither: a still hand is only a lamp. And the colony,
/// when the storm comes and it tucks in, closes its shells, and
/// the closing is a granular voice, made of the colony itself:
/// sparse at the storm's stirring, a bed of closings at the
/// storm's full, and quiet where there is no storm, the way the
/// slack water is quiet. And where the moon's light lies on the
/// moving water, the water glints: small and high and sparse, the
/// way a glint is — the sky's voice on the water, and when the
/// crossing passes, the sky is silent again, the way the sky is
/// silent most of the time. And the deep one, when it passes
/// under the water, makes the piece's first voice that is not the
/// water's: the water's voices are the water's motion — the
/// murmur, the rain, the swish — and the granular voices of the
/// populations — the colony's closing, the sky's glint. But the
/// deep one is a body of its own, and a body has a voice of its
/// own: one low tone under the water, the way a single body makes
/// a single sound — the colony's closing is eight small voices,
/// and the deep one is one. And when the passing ends, the tone
/// goes with it, and the water does not remember it.
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
    private var tuckTarget: Double = 0
    private var glintTarget: Double = 0
    private var swishTarget: Double = 0
    private var deepTarget: Double = 0
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

    // The colony's closing: many small voices, each closing when it
    // closes, at its own pace and its own pitch, the way no two
    // shells close together. The closing is a short sharp voice —
    // a shell that has closed, gone in a moment.
    private struct Clicker {
        var baseFreq: Double
        var freq: Double
        var phase: Double
        var env: Double
        var nextIn: Int
        var weight: Double
    }
    private var clickers: [Clicker] = []
    private var tuckGain: Double = 0

    // The sky's glint: six grains of the water's own light, each
    // glinting when it glints, at its own pace and its own pitch,
    // the way no two glints are the same. The glint is a moment of
    // light — a grain of the moon's light on the moving water,
    // gone in a moment.
    private struct Glinter {
        var baseFreq: Double
        var freq: Double
        var phase: Double
        var env: Double
        var nextIn: Int
        var weight: Double
    }
    private var glinters: [Glinter] = []
    private var glintGain: Double = 0

    // The deep one's voice: the piece's first voice that is not
    // the water's — the water's voices are made of the water's
    // motion; the deep one is a body, and a body has a voice of
    // its own: one low tone, the way a single body makes a single
    // sound. The colony's closing is eight small voices, each at
    // its own pace; the deep one is one voice, at its own breath.
    private var deepPhase: Double = 0
    private var deepToneGain: Double = 0
    private var deepSampleClock: Double = 0

    /// The voice's own draw: a unit random, the way the water draws
    /// its motes
    @inline(__always)
    private func drawRng() -> Double {
        rngState ^= rngState << 13
        rngState ^= rngState >> 7
        rngState ^= rngState << 17
        return Double(rngState & 0x00FFFFFF) / 0x00800000
    }

    init() {
        // the water's own clock of samples: forty-four thousand a
        // second, one channel — the voice is one voice. The engine's
        // graph is not built here: the water's audio service is
        // spoken to only when the water is actually going to speak.
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
            ?? AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1)!
        // the colony's closing: eight of the colony's small voices,
        // each at its own pace and its own pitch, the way no two
        // shells are the same
        for _ in 0..<8 {
            let f = drawRng()
            clickers.append(Clicker(
                baseFreq: 1300 + 1900 * f,
                freq: 1300 + 1900 * f,
                phase: 0,
                env: 0,
                nextIn: Int(drawRng() * 44_100),
                weight: 0.8 + 0.4 * drawRng()
            ))
        }
        // the sky's glint: six grains, higher and shorter than the
        // colony's closings — a glint of light, not a closing of a
        // shell
        for _ in 0..<6 {
            let f = drawRng()
            glinters.append(Glinter(
                baseFreq: 2600 + 2600 * f,
                freq: 2600 + 2600 * f,
                phase: 0,
                env: 0,
                nextIn: Int(drawRng() * 44_100),
                weight: 0.7 + 0.3 * drawRng()
            ))
        }
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
    /// water (the rain), the closing of the colony's shells where
    /// the storm tucks the colony in (the tuck), the glint where
    /// the moon's light lies on the moving water, the swish where
    /// the hand has been (the water's answer, heard), the low tone
    /// under the water where the deep one passes (a body's voice,
    /// the piece's first that is not the water's), and how low the
    /// voice should sit (lower, in the water's night). The voice
    /// eases toward each of them, the way water eases.
    func update(murmur: Double, rain: Double, tuck: Double, glint: Double, swish: Double, deep: Double, cutoff: Double) {
        targetLock.lock()
        murmurTarget = murmur
        rainTarget = rain
        tuckTarget = tuck
        glintTarget = glint
        swishTarget = swish
        deepTarget = deep
        cutoffTarget = cutoff
        targetLock.unlock()
        let isSpeaking = murmur + rain + tuck + glint + swish + deep > 0.03
        if isSpeaking != speaking {
            speaking = isSpeaking
        }
    }

    private func pullTargets() -> (murmur: Double, rain: Double, tuck: Double, glint: Double, swish: Double, deep: Double, cutoff: Double) {
        targetLock.lock()
        defer { targetLock.unlock() }
        return (murmurTarget, rainTarget, tuckTarget, glintTarget, swishTarget, deepTarget, cutoffTarget)
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
        // the colony's closing: the closings come and thicken with
        // the storm — sparse and far at the storm's stirring, a bed
        // of closings at its full — and still where there is no
        // storm, the way the slack water is still
        let tuckDensity = min(1, target.tuck / 0.06)
        let tuckMean = 0.08 + 2.9 * pow(1 - tuckDensity, 3)
        // the sky's glint: the glints come and thicken with the
        // moon — sparse and far where the moon is low, a bed of
        // glints where it is high — and still where the moon is
        // not, the way the sky is still most of the time
        let glintDensity = min(1, target.glint / 0.03)
        let glintMean = 0.5 + 2.5 * pow(1 - glintDensity, 3)

        var sum: Double = 0
        var tuckSum: Double = 0
        var glintSum: Double = 0
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
            // the colony's closing: each of the colony's small
            // voices closes when it closes, at its own pace and its
            // own pitch — a shell that has closed, gone in a moment
            for ci in clickers.indices {
                var c = clickers[ci]
                c.nextIn -= 1
                if c.nextIn <= 0 {
                    c.env = 1
                    c.phase = 0
                    let jitter = 0.4 + drawRng()
                    c.nextIn = max(220, Int(Double(format.sampleRate) * tuckMean * jitter))
                    // each closing is slightly off the last, the way
                    // no two shells are the same
                    c.freq = c.baseFreq * (0.97 + 0.06 * drawRng())
                }
                c.phase += 2 * .pi * c.freq / Double(format.sampleRate)
                if c.phase >= 4 * .pi { c.phase -= 4 * .pi }
                c.env *= 0.994
                tuckSum += sin(c.phase) * c.env * c.weight
                clickers[ci] = c
            }
            // the sky's glint: each grain glints when it glints, at
            // its own pace and its own pitch — a moment of light,
            // gone in a moment
            for gi in glinters.indices {
                var g = glinters[gi]
                g.nextIn -= 1
                if g.nextIn <= 0 {
                    g.env = 1
                    g.phase = 0
                    let jitter = 0.5 + drawRng()
                    g.nextIn = max(220, Int(Double(format.sampleRate) * glintMean * jitter))
                    // each glint is slightly off the last, the way
                    // no two glints are the same
                    g.freq = g.baseFreq * (0.9 + 0.2 * drawRng())
                }
                g.phase += 2 * .pi * g.freq / Double(format.sampleRate)
                if g.phase >= 4 * .pi { g.phase -= 4 * .pi }
                g.env *= 0.988
                glintSum += sin(g.phase) * g.env * g.weight
                glinters[gi] = g
            }
            // the deep one's voice: one low tone, the way a single
            // body makes a single sound — it breathes the way the
            // body breathes, and it comes up slowly and goes down
            // slowly, the way a large body's voice does. The
            // water's voices are the water's motion; this one is a
            // body's motion
            deepSampleClock += 1
            deepPhase += 2 * .pi * 55.0 * (
                1 + 0.06 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 29) + 0.4)
            ) / Double(format.sampleRate)
            if deepPhase >= 4 * .pi { deepPhase -= 4 * .pi }
            deepToneGain += (target.deep - deepToneGain) * 0.0008
            let deepTone = sin(deepPhase)
                * deepToneGain * 1.6
                * (0.75 + 0.25 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 37) + 1.2))
            // the voice eases toward what the water is doing, the
            // way water eases: the murmur slowly, the rain at the
            // storm's pace, the colony tucks in slowly, the sky
            // glints slowly, the deep one's tone slowly still, and
            // the swish at the hand's
            murmurGain += (target.murmur - murmurGain) * 0.002
            rainGain += (target.rain - rainGain) * 0.006
            tuckGain += (target.tuck - tuckGain) * 0.004
            glintGain += (target.glint - glintGain) * 0.004
            swishGain += (target.swish - swishGain) * 0.05
            var out = murmurLow * murmurGain * 2.4
                + rainHiss * rainGain * 1.2
                + tuckSum * tuckGain * 1.2
                + glintSum * glintGain * 1.2
                + swishHiss * swishGain
                + deepTone
            // a soft edge, the way the water has soft edges
            out = tanh(out * 1.4) / tanh(1.4)
            samples[frame] = Float(out)
            sum += out * out
        }
        level = (sum / Double(frameCount)).squareRoot()
        framesSinceLevelLog -= Int(frameCount)
        if framesSinceLevelLog <= 0 {
            framesSinceLevelLog = Int(44_100 * 8)
            os_log("fb voice: level %f (tuck %f, glint %f, deep %f)", level, tuckGain, glintGain, deepToneGain)
        }
    }
}
