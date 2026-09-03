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
/// slack water is quiet. But the colony has a word in its calm,
/// the way it has a word in its weather: the opening, one soft
/// chime, sparse, at the colony's own pace — the colony's word at
/// home, full in the deep calm and gone at the storm's full, the
/// way the colony's two words turn with the weather. The closing
/// is eight small voices, the glint is six grains, the deep one
/// is one — and the opening is one: the colony's quiet word, the
/// rarest of the colony's words. And the new life's first adult
/// breath is witnessed: when a life completes its becoming, the
/// colony's one opening voice opens for it — a chime, once, the
/// loudest the opening is — and a moment later the water does not
/// remember it, the way it forgets everything. And where the moon's light lies on the
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
/// and the deep one is one. And the deep one's twin, when it
/// passes — rarely, and more rarely still together with the deep
/// one — carries a tone of its own, a little above the deep
/// one's, the way a lesser body's voice sits a little above a
/// larger body's: and where the two bodies are together, the two
/// tones beat against each other, three swells a second, the way
/// two large bodies breathing at once would sound — the piece's
/// rarest sound. And when the passing ends, the tones go with
/// them, and the water does not remember them. And the sky's warm
/// word — the turning, the hour the sky's light comes down warm —
/// is a low warm wash in the water's voice: the sky's dark word is
/// the rain, the sky's cold word is the glint, and the sky's warm
/// word is the gild, and it is the sky's voice on the water's
/// motion, the way the glint is — the moving water gilds, the
/// still water does not — and when the turning turns to the day
/// the wash is gone, and the water does not remember it. And where
/// a body of the deep is in the water, the water hushes its own
/// voice around it: the murmur — the tide's turning, the water's
/// own speech — goes thin where the body speaks, the way a river's
/// voice goes thin around a stone in its bed. The hush is the one
/// taking-away the body makes: everything else the body makes in
/// the piece is a giving — the water goes around it, the body
/// carries a light, the surface answers its breath, the voice
/// carries its tone — and the hush is the body's presence thinning
/// the water's own voice, made for the body, and gone when the body
/// is gone, the way everything is. The hush is on the water's own
/// voice only: the rain keeps falling, the way rain keeps falling
/// on a stone, and the body's own tone keeps its own breath through
/// the hush, the way the body does not read the sky's word. And
/// the sky's dark word has a low end: the rain falls on the
/// surface, hissed into the high, but a storm is a body of
/// weather, and a body has a bottom, the way the sea has a bottom
/// — under the rain there is the roll, very low and very slow,
/// the storm's voice in the deep, rolling within the storm the
/// way a storm rolls within itself. It is the sky's word, not the
/// deep's: the sky does not read the body, the way the body does
/// not read the sky's word — and where the storm is over the
/// water and a body of the deep is under it, the sky's word and
/// the body's word sound in the same deep, the rarest weather
/// heard at its bottom: the meeting is not made, it comes of two
/// voices at once, the way it comes of two bodies at once, and
/// the body's own low tone is heard above the roll, the way the
/// sky's word keeps below the body's. And when the storm passes
/// the roll goes with it, and the water does not remember it, the
/// way it forgets everything.
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
    // The opening: the colony's word in its calm — one soft
    // chime, sparse, at the colony's own pace: the colony's quiet
    // word, full in the deep calm and gone at the storm's full,
    // the way the colony's two words turn with the weather. The
    // piece tells the voice the opening's gain, and the bloom's
    // pulse: the moment a new life completes its becoming, and
    // the opening voice opens for it, once
    private var openTarget: Double = 0
    private var openPulseTarget: Double = 0
    private var glintTarget: Double = 0
    private var swishTarget: Double = 0
    private var deepTarget: Double = 0
    private var twinTarget: Double = 0
    private var gildTarget: Double = 0
    // The roll: the low end of the sky's dark word — the storm's
    // voice in the deep, under the rain, very low and very slow,
    // the way a storm's voice is in the deep. The sky's word, not
    // the body's: where the dark word is over the water and a body
    // of the deep is under it, the sky's word and the body's word
    // sound in the same deep, the rarest weather heard at its
    // bottom — and the low end keeps below the body's own voice,
    // so the tone is heard above the roll, the way the body's
    // voice is the body's
    private var rollTarget: Double = 0
    // The hush: not a voice of the water's making, but the water's
    // own voice thinned where a body of the deep is in the water —
    // the piece tells the voice how hushed the water's own speech
    // is, the way the piece tells it everything
    private var hushTarget: Double = 0
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

    // The colony's opening: its word in its calm — one soft
    // chime, the way no two shells open together. The closing is
    // eight small voices, the glint is six grains, the deep one
    // is one — and the opening is one: the colony's quiet word,
    // the rarest of the colony's words, full in the deep calm and
    // gone at the storm's full. It opens when it opens, at its
    // own pace and its own pitch, sparse, the way the calm is
    // sparse. And when a new life completes its becoming, the
    // opening voice opens for it — a chime, once, the loudest the
    // opening is: the piece's pulse makes it open now, and only
    // now. The opening breathes: a shell opens slowly, and the
    // light it opens to goes slowly — a slow attack, a long soft
    // tail, the way an opening is, not a closing
    private struct Opener {
        var baseFreq: Double
        var freq: Double
        var phase: Double
        var tail: Double
        var age: Int
        var nextIn: Int
        var pulsed: Bool
    }
    private var opener = Opener(baseFreq: 850, freq: 850, phase: 0, tail: 0, age: 0, nextIn: 0, pulsed: false)
    private var openGain: Double = 0

    // The deep one's voice: the piece's first voice that is not
    // the water's — the water's voices are made of the water's
    // motion; the deep one is a body, and a body has a voice of
    // its own: one low tone, the way a single body makes a single
    // sound. The colony's closing is eight small voices, each at
    // its own pace; the deep one is one voice, at its own breath.
    private var deepPhase: Double = 0
    private var deepToneGain: Double = 0
    private var deepSampleClock: Double = 0

    // The twin's voice: its own low tone, a little above the deep
    // one's — the twin breathes at its own breath, the way the
    // twin keeps its own light, and where the two bodies are
    // together the two tones beat against each other, the way two
    // large bodies breathing at once would sound
    private var twinPhase: Double = 0
    private var twinToneGain: Double = 0

    // The sky's warm word: the gild — a low warm wash in the
    // water's voice, present only while the sky's light is warm,
    // the way the glint is present only while the moon's light is:
    // the sky's dark word is the rain, the sky's cold word is the
    // glint, and the sky's warm word is this. The wash is its own
    // draw of the water's own noise, low-passed to a warm low band,
    // and it eases toward the sky's warmth the way water eases
    private var gildBrown: Double = 0
    private var gildLow: Double = 0
    private var gildGain: Double = 0

    // The roll's own draw of the water's noise: the low end is a
    // bottom, and a bottom is its own water — drawn into its own
    // slow memory and low-passed to the deep, the way the deep
    // keeps
    private var rollBrown: Double = 0
    private var rollLow: Double = 0
    private var rollGain: Double = 0

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
        // the colony's opening: its one opening voice, at its own
        // pace — the next opening is somewhere in the first second,
        // and no earlier
        opener.nextIn = Int(drawRng() * 44_100)
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
        // the water can be told to keep its voice: the piece's
        // motion is the piece's motion, whether it is heard or
        // not — and a room that wants quiet is a room that wants
        // quiet
        guard ContentView.voiceEnabled else {
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
    /// the storm tucks the colony in (the tuck), the opening —
    /// the colony's word in its calm: one soft chime, sparse, at
    /// the colony's own pace, full in the deep calm and gone at
    /// the storm's full, the way the colony's two words turn with
    /// the weather — and the bloom's pulse, the moment a new life
    /// completes its becoming, at which the opening voice opens
    /// for it, once (the pulse), the glint where
    /// the moon's light lies on the moving water, the gild where
    /// the sky's light lies warm on the moving water — the sky's
    /// warm word, its dark word being the rain and its cold word
    /// the glint — the swish where
    /// the hand has been (the water's answer, heard), the low tone
    /// under the water where the deep one passes (a body's voice,
    /// the piece's first that is not the water's), and the twin's
    /// tone, a little above it (its body's voice — and where the
    /// two are together, the two tones beat, the piece's rarest
    /// sound), the roll — the low end of the sky's dark word, the
    /// storm's voice in the deep under the rain, the way a storm's
    /// voice is in the deep: the sky's word, kept below the
    /// body's, so where the two are together the rarest weather is
    /// heard at its bottom, and the tone is heard above it — the
    /// hush — how much of the water's own speech is
    /// thinned where a body of the deep is in the water: the murmur
    /// arrives already thinned, and the hush is kept as the piece's
    /// own account of it, the way the piece keeps the water's — and
    /// how low the voice should sit (lower, in the water's night).
    /// The voice eases toward each of them, the way water eases.
    func update(murmur: Double, rain: Double, tuck: Double, opening: Double, openPulse: Double, glint: Double, gild: Double, roll: Double, swish: Double, deep: Double, twin: Double, hush: Double, cutoff: Double) {
        targetLock.lock()
        murmurTarget = murmur
        rainTarget = rain
        tuckTarget = tuck
        openTarget = opening
        openPulseTarget = openPulse
        glintTarget = glint
        gildTarget = gild
        rollTarget = roll
        swishTarget = swish
        deepTarget = deep
        twinTarget = twin
        hushTarget = hush
        cutoffTarget = cutoff
        targetLock.unlock()
        let isSpeaking = murmur + rain + tuck + opening + glint + gild + roll + swish + deep + twin > 0.03
        if isSpeaking != speaking {
            speaking = isSpeaking
        }
    }

    private func pullTargets() -> (murmur: Double, rain: Double, tuck: Double, opening: Double, openPulse: Double, glint: Double, gild: Double, roll: Double, swish: Double, deep: Double, twin: Double, hush: Double, cutoff: Double) {
        targetLock.lock()
        defer { targetLock.unlock() }
        return (murmurTarget, rainTarget, tuckTarget, openTarget, openPulseTarget, glintTarget, gildTarget, rollTarget, swishTarget, deepTarget, twinTarget, hushTarget, cutoffTarget)
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
        // where the gild sits: a fixed warm low band — the gild is
        // a low-light thing, the way the sky's warmth is, and does
        // not sink further in the night the way the deep voice does
        let gildAlpha = 1 - exp(-2 * .pi * 380.0 / Double(format.sampleRate))
        // where the roll sits: the deep — the low end is a bottom,
        // and a bottom is low, lower still than the deep one's
        // tone, so the body's voice is heard above it
        let rollAlpha = 1 - exp(-2 * .pi * 90.0 / Double(format.sampleRate))
        // the colony's closing: the closings come and thicken with
        // the storm — sparse and far at the storm's stirring, a bed
        // of closings at its full — and still where there is no
        // storm, the way the slack water is still
        let tuckDensity = min(1, target.tuck / 0.06)
        let tuckMean = 0.08 + 2.9 * pow(1 - tuckDensity, 3)
        // the colony's opening: the openings come in the calm —
        // sparse, at the colony's own pace, the way no two shells
        // open together — and thin as the storm comes, the way the
        // colony's word thins as the storm comes: the two words
        // turn with the weather, the way a sleeper's breath turns
        let openDensity = min(1, target.opening / 0.015)
        let openMean = 6.0 + 6.0 * pow(1 - openDensity, 3)
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
            // the gild: the sky's warm word — a low warm wash, the
            // water's own noise drawn into its own slow memory and
            // low-passed to the warm low band, present only while
            // the sky's light is warm, the way the glint is present
            // only while the moon's light is
            gildBrown = (gildBrown + 0.02 * white) * 0.999
            gildLow += gildAlpha * (gildBrown - gildLow)
            // the roll: the low end of the sky's dark word — the
            // storm's voice in the deep, under the rain, the way a
            // storm's voice is in the deep; its own draw of the
            // water's noise, remembered into its own slow memory
            // and low-passed to the bottom, the way the bottom
            // keeps
            rollBrown = (rollBrown + 0.02 * white) * 0.999
            rollLow += rollAlpha * (rollBrown - rollLow)
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
            // the colony's opening: its one opening voice opens
            // when it opens, at its own pace and its own pitch —
            // sparse in the calm, the way no two shells open
            // together — and it keeps the calm's word, not the
            // storm's: it thins as the storm comes, the way the
            // colony's two words turn with the weather
            opener.age += 1
            opener.nextIn -= 1
            if opener.nextIn <= 0 {
                opener.phase = 0
                opener.age = 0
                opener.tail = 1
                let jitter = 0.5 + 1.5 * drawRng()
                opener.nextIn = max(220, Int(Double(format.sampleRate) * openMean * jitter))
                // each opening is slightly off the last, the way no
                // two shells open together
                opener.freq = opener.baseFreq * (0.97 + 0.06 * drawRng())
            }
            // the new life's first adult breath: the piece's pulse
            // makes the opening voice open for the new life — a
            // chime, once, at the bloom, and only once: the
            // pulse's window is a moment, and the voice keeps it
            // to one opening
            if target.openPulse > 0.5, !opener.pulsed {
                opener.pulsed = true
                opener.phase = 0
                opener.age = 0
                opener.tail = 1
                let jitter = 0.5 + 1.5 * drawRng()
                opener.nextIn = max(Int(3.0 * Double(format.sampleRate)), Int(Double(format.sampleRate) * openMean * jitter))
                opener.freq = opener.baseFreq * (0.97 + 0.06 * drawRng())
            }
            if target.openPulse <= 0.5 {
                opener.pulsed = false
            }
            opener.phase += 2 * .pi * opener.freq / Double(format.sampleRate)
            if opener.phase >= 4 * .pi { opener.phase -= 4 * .pi }
            // the opening breathes: a shell opens slowly — a slow
            // attack, the way a shell opens — and the light it
            // opens to goes slowly — a long soft tail, the way
            // light goes: an opening, not a closing
            opener.tail *= 0.999
            let openAttack = min(1, Double(opener.age) / (0.08 * Double(format.sampleRate)))
            let openSum = sin(opener.phase) * openAttack * opener.tail
            // the deep one's voice: one low tone, the way a single
            // body makes a single sound — it breathes the way the
            // body breathes, and it comes up slowly and goes down
            // slowly, the way a large body's voice does. The
            // water's voices are the water's motion; this one is a
            // body's motion
            deepSampleClock += 1
            // the deep one's tone: 55 Hz, breathing at the deep
            // one's breath — the 37 s gain-breath, the same breath
            // that makes the deep one's light: one body, one
            // breath, one voice, one light
            deepPhase += 2 * .pi * 55.0 * (
                1 + 0.06 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 29) + 0.4)
            ) / Double(format.sampleRate)
            if deepPhase >= 4 * .pi { deepPhase -= 4 * .pi }
            deepToneGain += (target.deep - deepToneGain) * 0.0008
            let deepTone = sin(deepPhase)
                * deepToneGain * 1.6
                * (0.75 + 0.25 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 37) + 1.2))
            // the twin's tone: 58 Hz — a little above the deep
            // one's, the way a lesser body's voice sits a little
            // above a larger body's — breathing at the twin's own
            // breath, the 41 s gain-breath, the same breath that
            // makes the twin's light: one body, one breath, one
            // voice, one light, for each of them. Where the two
            // bodies are together, the two tones beat against
            // each other — no beating is made; it comes of two
            // voices at once, the way it comes of two bodies at
            // once
            twinPhase += 2 * .pi * 58.0 * (
                1 + 0.06 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 31) + 2.1)
            ) / Double(format.sampleRate)
            if twinPhase >= 4 * .pi { twinPhase -= 4 * .pi }
            twinToneGain += (target.twin - twinToneGain) * 0.0008
            let twinTone = sin(twinPhase)
                * twinToneGain * 1.6
                * (0.75 + 0.25 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 41) + 3.9))
            // the voice eases toward what the water is doing, the
            // way water eases: the murmur slowly, the rain at the
            // storm's pace, the colony tucks in slowly, the colony
            // opens slowly — the calm's word is a slow one, the
            // way a calm is slow — the sky glints slowly, the sky
            // gilds slowly, the sky's dark word rolls slowly still
            // — a bottom moves the way a bottom moves — the deep
            // one's tone and the twin's tone slowly still, and the
            // swish at the hand's
            murmurGain += (target.murmur - murmurGain) * 0.002
            rainGain += (target.rain - rainGain) * 0.006
            tuckGain += (target.tuck - tuckGain) * 0.004
            openGain += (target.opening - openGain) * 0.004
            glintGain += (target.glint - glintGain) * 0.004
            gildGain += (target.gild - gildGain) * 0.004
            rollGain += (target.roll - rollGain) * 0.002
            // the roll's own rolling: two incommensurate swells —
            // the roll comes and goes within the storm, the way a
            // storm comes and goes within itself — and within the
            // storm it never fully goes quiet, the way a storm
            // never fully goes quiet: the lull keeps its low hum
            let rollSwell = 0.3 + 0.7 * (0.5 + 0.5 * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 5.3) + 1.7)
                * sin(2 * .pi * deepSampleClock / (Double(format.sampleRate) * 13.9) + 0.4))
            swishGain += (target.swish - swishGain) * 0.05
            var out = murmurLow * murmurGain * 2.4
                + rainHiss * rainGain * 1.2
                + tuckSum * tuckGain * 1.2
                + openSum * openGain * 1.2
                + glintSum * glintGain * 1.2
                + gildLow * gildGain * 1.2
                + rollLow * rollGain * rollSwell * 1.2
                + swishHiss * swishGain
                + deepTone
                + twinTone
            // a soft edge, the way the water has soft edges
            out = tanh(out * 1.4) / tanh(1.4)
            samples[frame] = Float(out)
            sum += out * out
        }
        level = (sum / Double(frameCount)).squareRoot()
        framesSinceLevelLog -= Int(frameCount)
        if framesSinceLevelLog <= 0 {
            framesSinceLevelLog = Int(44_100 * 8)
            os_log("fb voice: level %f (tuck %f, open %f, glint %f, roll %f, deep %f, twin %f, gild %f, hush %f)", level, tuckGain, openGain, glintGain, rollGain, deepToneGain, twinToneGain, gildGain, target.hush)
        }
    }
}
