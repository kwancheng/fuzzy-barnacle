import SwiftUI
import SwiftData

/// Open water. Press anywhere and a barnacle settles there; hold and
/// one lets go. The colony is the record — every press is a moment
/// that decided to stay. The water keeps time: the creatures grow,
/// they slow with age, and where one has let go, a trace remains a
/// while before the water forgets it. And the water moves: a tide
/// runs through it, carrying the motes and the plumes, and it parts
/// around a hand, the way water goes around a rock. And the quick
/// ones pass through: small lives that ride the current, scatter from
/// the hand, and leave no trace at all — the water keeps what stays,
/// and lets go what passes. And the light above it dims and
/// brightens again on the water's own clock — the water has a day
/// and a night — and in the night the colony glows faintly of its
/// own, and a moving hand stirs that glow, and the glow lingers a
/// moment after the hand is gone, and the traces go dark except where
/// the hand's light reaches them. And the sky's light is not only
/// a brightness: it has a color — it comes down warm gold at the
/// water's turning, and white at the high — and the water drinks
/// the color of the light it is given, gilded at the turning the
/// way the sea is gilded at dusk, and its own blue at the high,
/// the way the sea is its own blue under a white sky, and when the
/// turning turns to the day the water is the water again, and does
/// not remember the gold, the way it forgets everything. And,
/// rarely, a storm comes over
/// the water: the current surges, the rain falls, the light from
/// above dims under the cloud, the colony tucks in, and the quick
/// ones ride it — and when the storm passes, the water is the water
/// again, and does not remember it. And a hand moving through the
/// dark stirs the water's own small light along its path, the way
/// the sea sparkles where a wave breaks — and the water forgets
/// that light, the way it forgets everything. And the water
/// speaks: the same tide that carries the motes is what murmurs,
/// the same storm is what falls as rain, and a moving hand is what
/// swishes, the way the sea swishes where a wave breaks — and the
/// slack water is quiet, and the water says so. And when the water
/// comes to its turning and the sky's light comes down warm, the
/// voice warms with it — a low warm wash, the sky's own word in
/// its warm hour, the way the rain is the sky's word in its dark
/// hour, and gone the moment the turning turns to the day. And
/// the colony
/// speaks when it tucks in: when the storm comes and the colony
/// closes its shells, there is a granular voice, made of the
/// colony itself — sparse and far at the storm's stirring, a bed
/// of closings at its full — and where there is no storm the
/// colony is quiet, the way the slack water is quiet. And the
/// colony has a word in its calm, the way it has a word in its
/// weather: where there is no storm the colony opens, sparsely,
/// at its own pace — one soft chime, the colony's one opening
/// voice, the way no two shells open together — and when a new
/// life completes its becoming, the sixty seconds of layering,
/// the colony opens to it: a small ring of the colony's own
/// light, going out once, and the chime, the loudest the opening
/// is — and a moment later the water is the water again, and
/// does not remember the becoming, the way it forgets
/// everything. And,
/// rarely, in the night, the moon crosses the water: a broad
/// beam of the sky's cold light, drifting across it, the colony
/// lit by the sky for a while, the motes catching the beam, the
/// moving water glinting under it, the way the sea glints under
/// the moon — and when the crossing passes, the water does not
/// remember it, the way it does not remember the storm. And,
/// most rarely of all, something passes through the deep: a
/// large slow body in the water's depths, below the rock the
/// colony is on, the water's current going around its back the
/// way it goes around the hand, the colony slowing its breath
/// under it, the way sleepers slow under a passing shadow — and
/// under it all a low tone, one low tone, the way a single body
/// makes a single sound: the piece's first voice that is not the
/// water's. And in the water's night, where the light from above
/// has given up, the deep one has a light of its own: the piece's
/// first light that is not the sky's — a small cold one, made by
/// the body, breathing at the body's breath, the colony above it
/// lit from below by it, the way sleepers are lit by a lamp under
/// them. And when the passing ends, the water is the water again,
/// and does not remember it, and the deep one does not remember
/// the water either. And, rarely still, the deep one is not alone:
/// its twin keeps a little higher in the water, smaller, on its
/// own currents and its own calendar — and the two are rarely
/// there together, the piece's rarest moment — each with its own
/// small light, the twin's the fainter, less blue of the two, each
/// with its own low tone a little above the other's, so that where
/// the two are together the two tones beat against each other, the
/// way two large bodies breathing at once would sound, and when the
/// passing ends, the lights go with them and the tones go with
/// them, and the water is the water again, and does not remember
/// any of it, the way it forgets everything. And, while the bodies
/// are under the water in the water's night, the surface answers
/// their breath: the breath of a body that deep reaches a long
/// way, and where it arrives at the surface the water answers with
/// a faint cold swell — a small slow ripple no wind made, traveling
/// at the water's pace and swelling at the body's breath, the water
/// carrying the answer and the body breathing it — and the twin's
/// answer keeps a little higher and a little fainter, at the twin's
/// own breath, so that where the two are together, the piece's
/// rarest moment, the surface carries two swells at once, each at
/// its own breath: the rarest moment seen from above, the way the
/// rarest sound is heard from below. And in the full day the light
/// from above is enough, and no answer is seen, the way the deep's
/// lights are not seen in the sun, and when the passing ends the
/// surface is the surface again, and does not remember the answer,
/// the way it forgets everything. And, rarely still, the sky's dark
/// word finds the deep one: the storm is what the sky remembers of
/// the water, and the deep one is a body of its own, and the two
/// calendars are the sky's and the deep's, and they agree rarely —
/// and where the storm is over the water and a body of the deep is
/// under it, the water goes around the body's back more, the way a
/// flood bends more around a stone, and the deep's small light —
/// the piece's first light that is not the sky's — is brightest of
/// all under the sky's dark word, because it is not the sky's
/// light, and the rain falls on the answer, and the colony tucks in
/// and slows its breath at the same time — and, rarely still, the
/// sky's dark word is over both of them at once, a matter of
/// seconds in a year — and when the storm passes and the passing
/// ends, the water is the water again, and does not remember the
/// meeting, the way it does not remember either of them.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Barnacle.timestamp) private var barnacles: [Barnacle]
    @Query(sort: \Ghost.departedAt) private var ghosts: [Ghost]

    @State private var pressStart: Date?
    @State private var ripples: [Ripple] = []
    @State private var nextRippleID = 0

    // the hand in the water: the colony feels the current it makes
    @State private var fingerDown = false
    @State private var fingerPoint: CGPoint?
    @State private var fingerDownSince: Date?
    @State private var fingerUpSince: Date?

    // how fast the hand is moving through the water: in the water's
    // night that speed is light — the stirring of the colony's own
    // glow
    @State private var handSpeed: Double = 0
    @State private var handSpeedAt: Date = .distantPast
    @State private var lastMoveAt: Date?

    // the wake: the light a moving hand makes in the water itself,
    // the way the sea sparkles where a wave breaks — kept only so
    // long as the light lasts, and no longer
    @State private var handTrail: [WakeSample] = []

    // the opening: the colony's word in its calm, and the new
    // life's first adult breath, witnessed — a bloom of the
    // colony's own light, one slow ring, and the colony's one
    // opening voice, opening for it. The piece keeps the witness
    // only while the bloom lasts, and no longer: after the
    // moment, the creature is what it is, and the piece keeps
    // its size, not its becoming
    @State private var bloomed: Set<Int> = []
    @State private var blooms: [Bloom] = []

    // the water's knowing of the comings and the goings: a new
    // life settles, and the water knows a life has come to it; a
    // life is pried off, and the water knows a life has left it.
    // The piece keeps the witness only a moment, the way a
    // witness is a witness — and then forgets it, the way the
    // water forgets everything: the water keeps the body and the
    // trace, and not the knowing
    @State private var witnesses: [Witness] = []

    // the voice: the water's own motion, heard — the tide that
    // carries the motes is what murmurs, the storm is what falls
    // as rain, and the moving hand is what swishes
    @StateObject private var voice = WaterVoice()

    struct Ripple: Identifiable {
        let id: Int
        let unitPoint: CGPoint
        let start: Date
        let kind: Kind

        enum Kind {
            case settle
            case pryOff
        }
    }

    /// One point of the hand's recent path, with the speed the hand
    /// had there: the material the wake is made of. Nothing else is
    /// kept — the water keeps the light only while it lasts.
    struct WakeSample {
        let point: CGPoint
        let time: Date
        let speed: Double
    }

    /// One witnessed becoming: which life, and when the piece saw
    /// it open to the water. It is kept on the piece's own clock,
    /// the way the colony's becoming keeps the colony's time — and
    /// it is kept only a moment, the way the bloom lasts. Nothing
    /// longer: after the moment the creature is what it is, and
    /// the piece keeps its size, not its becoming.
    struct Bloom {
        let seed: Int
        let at: Date
    }

    /// One witnessed coming or going: which life, which of the two,
    /// and when. The piece has always kept the bodies — the colony
    /// in the store, the trace of the gone one, kept a while and
    /// pruned — and the faces of the two moments: the ripple where
    /// a life settles, the small ripple where one is pried off.
    /// What it did not keep was the knowing itself — the water
    /// knowing a life has come to it, the water knowing a life has
    /// left it. This keeps it a moment, the way a witness is a
    /// witness, and no longer: the water keeps the body and the
    /// trace, and not the knowing.
    struct Witness {
        enum Kind {
            case coming
            case going
        }
        let seed: Int
        let kind: Kind
        let at: Date
    }

    var body: some View {
        ZStack {
            canvas
                .ignoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            if barnacles.count > 0 {
                caption
            }
        }
        .overlay {
            if barnacles.isEmpty {
                hint
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { voice.start() }
        .onDisappear { voice.stop() }
        .task {
            // the water forgets: traces are kept for a while, then gone
            while !Task.isCancelled {
                pruneGhosts()
                try? await Task.sleep(for: .seconds(20))
            }
        }
        .task {
            // the water speaks: the piece tells the voice what it is
            // doing, a few times a second, and the voice eases toward
            // it, the way water eases
            while !Task.isCancelled {
                speak()
                try? await Task.sleep(for: .seconds(0.25))
            }
        }
    }

    /// One telling of the voice: how fast the current is turning
    /// (the murmur), how much storm is over the water (the rain),
    /// the closing of the colony's shells where the storm tucks the
    /// colony in (the tuck), the opening — the colony's word in its
    /// calm: one soft chime, sparse, at the colony's own pace, full
    /// in the deep calm and gone at the storm's full, the way the
    /// colony's two words turn with the weather — and the new
    /// life's first adult breath, witnessed: a bloom of the
    /// colony's own light, one slow ring, and the chime, the
    /// loudest the opening is, kept a moment and forgotten the way
    /// everything is — the glint where the moon's light lies
    /// on the moving water, the gild where the sky's light lies warm
    /// on the moving water — the sky's warm word, the sky's dark
    /// word being the rain and its cold word the glint — the swish
    /// where the hand has been, the low tone under the water where
    /// the deep one passes — the piece's first voice that is not the
    /// water's — and its twin's, a second low tone sitting a little
    /// above the first, so that where the two bodies are together
    /// the two tones beat against each other, three swells a second,
    /// the way two large bodies breathing at once would sound, the
    /// piece's rarest sound — and how low the voice sits, which is
    /// lower in the water's night.
    /// The swish runs on the world's time, the way the hand's other
    /// answers do — it is the hand the water knows, not the clock
    /// the water keeps. The bloom runs on the piece's own clock,
    /// the way the colony's becoming keeps the colony's time. And
    /// the water knows the comings and the goings — a life
    /// settling, a life pried off: a small grain each, kept a
    /// moment, and forgotten, the way the water keeps the body and
    /// the trace, and not the knowing.
    private func speak() {
        let now = Date.now
        let vnow = now.addingTimeInterval(Self.timeOffset)
        let t = vnow.timeIntervalSinceReferenceDate
        let light = Self.drawnLight(t)
        let stormNow = Self.storm(t)
        let moonNow = Self.moonDrawn(t)
        let deepNow = Self.deep(t)
        let twinNow = Self.deepTwin(t)
        // the new life's first adult breath, witnessed: the
        // colony's becoming keeps the colony's time — the piece's
        // own clock — and the piece sees it while it is
        // happening, and keeps the seeing only a moment. A life
        // that is no longer becoming is an adult, and the piece
        // keeps its size, not its becoming
        for barnacle in barnacles {
            let age = vnow.timeIntervalSince(barnacle.timestamp)
            if Self.isBecoming(age), !bloomed.contains(barnacle.seed) {
                bloomed.insert(barnacle.seed)
                blooms.append(Bloom(seed: barnacle.seed, at: vnow))
            }
        }
        blooms.removeAll { vnow.timeIntervalSince($0.at) > 8 }
        bloomed.subtract(barnacles.filter { vnow.timeIntervalSince($0.timestamp) > 90 }.map(\.seed))
        // the bloom's chime: the colony's one opening voice,
        // opening for a new life — and thin where the storm is,
        // the way the colony's word is thin where the storm is
        let bloomChime = min(
            0.05,
            blooms.map { Self.bloomChime(vnow.timeIntervalSince($0.at)) * (1 - stormNow) }.reduce(0, +)
        )
        // the bloom's pulse: the telling that makes the opening
        // voice open for the new life, once, at the bloom
        let openPulse = blooms.map { 1 - Self.smoothstep(0, 1.2, vnow.timeIntervalSince($0.at)) }.max() ?? 0
        // the water's knowing of the comings and the goings: a
        // life settles, and the water knows a life has come to it
        // — a small grain, gone in a few seconds, and not
        // remembered; a life is pried off, and the water knows a
        // life has left it — a smaller grain, a little deeper, a
        // little longer: a loss is quieter than a coming, and a
        // loss lingers a moment longer. The hand keeps the
        // world's time, the way the hand's other answers do, and
        // the water keeps the knowing only a moment, the way it
        // keeps everything
        let comings = witnesses
            .filter { $0.kind == .coming }
            .map { Self.comingGain(now.timeIntervalSince($0.at)) }
            .reduce(0, +)
        let goings = witnesses
            .filter { $0.kind == .going }
            .map { Self.goingGain(now.timeIntervalSince($0.at)) }
            .reduce(0, +)
        witnesses.removeAll { now.timeIntervalSince($0.at) > 12 }
        voice.update(
            murmur: Self.spokenMurmur(
                strengthNow: Self.tide(t).strength,
                strengthThen: Self.tide(t - 2).strength,
                deep: deepNow,
                twin: twinNow,
                t: t
            ),
            rain: Self.rainGain(storm: stormNow, light: light),
            tuck: Self.tuckGain(storm: stormNow),
            opening: Self.openingGain(storm: stormNow) + bloomChime,
            openPulse: openPulse,
            glint: Self.glintGain(moon: moonNow, current: Self.tide(t).strength),
            gild: Self.gildGain(warmth: Self.skyWarmth(t), current: Self.tide(t).strength),
            roll: Self.rollGain(storm: stormNow, light: light),
            // the quick ones' skitter: the piece's own small motion,
            // heard — the current carrying the quick ones, a little
            // more in the night the way the quick ones' light is,
            // more in the storm the way the quick ones ride the
            // storm — and the hand's answer to the quick ones: a
            // moving hand parts them, and the quick ones, parted,
            // skitter away, the way startled things skitter
            skitter: Self.skitterGain(current: Self.tide(t).strength, light: light, storm: stormNow)
                + Self.skitterStartle(speed: handSpeed, age: max(0, now.timeIntervalSince(handSpeedAt))),
            swish: Self.handSwish(speed: handSpeed, age: max(0, now.timeIntervalSince(handSpeedAt))),
            deep: Self.deepGain(deepNow),
            twin: Self.deepTwinGain(twinNow),
            hush: Self.hushGain(deep: deepNow, twin: twinNow, t: t),
            // the water's knowing of the comings and the goings —
            // the coming's grain, and the going's: the small keeps
            // below the large, the way the piece keeps its own
            // account of its own voices
            coming: comings,
            going: goings,
            cutoff: 240 + 660 * (0.3 + 0.7 * light)
        )
    }

    private func pruneGhosts() {
        let cutoff = Date.now.addingTimeInterval(-170)
        for ghost in ghosts where ghost.departedAt < cutoff {
            modelContext.delete(ghost)
        }
    }

    private var canvas: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let now = timeline.date
                // the piece's own clock: the world's time, shifted
                // when it is shifted. The water only ever knows its
                // own clock.
                let vnow = now.addingTimeInterval(Self.timeOffset)
                Canvas { context, size in
                    let t = vnow.timeIntervalSinceReferenceDate
                    let presence = fingerPresence(now: now)
                    let stormNow = Self.storm(t)
                    let light = Self.drawnLight(t)
                    let moonNow = Self.moonDrawn(t)
                    let moonBeamX = Self.moonBeamX(t, width: size.width)
                    let deepNow = Self.deep(t)
                    let deepCenter = CGPoint(
                        x: Self.deepX(t, width: size.width),
                        y: Self.deepY(t, height: size.height)
                    )
                    let deepTwinNow = Self.deepTwin(t)
                    let deepTwinCenter = CGPoint(
                        x: Self.deepTwinX(t, width: size.width),
                        y: Self.deepTwinY(t, height: size.height)
                    )
                    let handFlash = presence > 0.001 && handSpeed > 1
                        ? Self.handFlashEnvelope(speed: handSpeed, age: now.timeIntervalSince(handSpeedAt), light: light)
                        : 0
                    drawWater(&context, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light, storm: stormNow, moon: moonNow, moonBeamX: moonBeamX, deep: deepNow, deepCenter: deepCenter, deepTwin: deepTwinNow, deepTwinCenter: deepTwinCenter)
                    // the wake: the water's own small light, stirred
                    // along the hand's path, drawn in the water and
                    // under everything the water carries
                    drawWake(&context, now: now, light: light, storm: stormNow)
                    drawHandGlow(&context, fingerPoint: fingerPoint, presence: presence, light: light, storm: stormNow)
                    drawPassing(&context, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash, storm: stormNow, moon: moonNow, moonBeamX: moonBeamX)
                    for ghost in ghosts {
                        drawGhost(&context, ghost, size: size, now: vnow, light: light, storm: stormNow, fingerPoint: fingerPoint, presence: presence, moon: moonNow, moonBeamX: moonBeamX)
                    }
                    for barnacle in barnacles {
                        drawBarnacle(&context, barnacle, size: size, now: vnow, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash, storm: stormNow, moon: moonNow, moonBeamX: moonBeamX, deep: deepNow, deepCenter: deepCenter, deepTwin: deepTwinNow, deepTwinCenter: deepTwinCenter)
                    }
                    // the new life's first adult breath, witnessed:
                    // a bloom of the colony's own light, one slow
                    // ring that goes out once, over the colony, the
                    // way a breath goes out — and gone, and
                    // forgotten, the way the water forgets
                    for bloom in blooms {
                        drawBloom(&context, bloom, size: size, now: vnow, light: light)
                    }
                    for ripple in ripples {
                        drawRipple(&context, ripple, size: size, now: now)
                    }
                    drawVignette(&context, size: size)
                }
            }
            .contentShape(Rectangle())
            .gesture(press(in: geo.size))
        }
    }

    // MARK: - Interaction

    private func press(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let now = Date.now
                if pressStart == nil {
                    pressStart = now
                }
                if !fingerDown {
                    fingerDown = true
                    fingerDownSince = now
                    fingerUpSince = nil
                    handSpeed = 0
                    lastMoveAt = now
                }
                // the speed of the hand: what stirs the dark water
                if let last = fingerPoint, let lastAt = lastMoveAt {
                    let dt = now.timeIntervalSince(lastAt)
                    if dt > 0.004 {
                        let v = hypot(value.location.x - last.x, value.location.y - last.y) / dt
                        handSpeed = min(600, 0.5 * handSpeed + 0.5 * v)
                        handSpeedAt = now
                    }
                }
                lastMoveAt = now
                fingerPoint = value.location
                // the wake: a moving hand stirs the water's own small
                // light along its path, and the water forgets the
                // light, the way it forgets the hand
                if handSpeed > 25 {
                    handTrail.removeAll { now.timeIntervalSince($0.time) > Self.wakeLife }
                    if let last = handTrail.last {
                        let dt = now.timeIntervalSince(last.time)
                        let dx = value.location.x - last.point.x
                        let dy = value.location.y - last.point.y
                        if dt >= 0.033 || hypot(dx, dy) > 6 {
                            handTrail.append(WakeSample(point: value.location, time: now, speed: handSpeed))
                            if handTrail.count > 80 {
                                handTrail.removeFirst(handTrail.count - 80)
                            }
                        }
                    } else {
                        handTrail.append(WakeSample(point: value.location, time: now, speed: handSpeed))
                    }
                }
            }
            .onEnded { value in
                defer { pressStart = nil }
                let start = pressStart ?? .now
                let held = Date.now.timeIntervalSince(start)
                let travel = hypot(value.translation.width, value.translation.height)
                fingerDown = false
                fingerUpSince = .now
                lastMoveAt = nil
                guard travel < 16 else { return }
                if held >= 0.35 {
                    pryOff(at: value.location, in: size)
                } else {
                    settle(at: value.location, in: size)
                }
            }
    }

    private func settle(at point: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let now = Date.now
        // the water's floor: nothing settles behind the caption
        let unitX = point.x / size.width
        let unitY = min(point.y / size.height, 0.84)
        let barnacle = Barnacle(
            timestamp: now,
            x: unitX,
            y: unitY,
            seed: Int.random(in: Int.min...Int.max),
            size: .random(in: 15...30)
        )
        modelContext.insert(barnacle)
        spawnRipple(CGPoint(x: unitX, y: unitY), kind: .settle)
        // the water knows a life has come to it — the ripple is
        // the coming's face, and the witness is its knowing, kept
        // a moment, and forgotten, the way the water forgets
        // everything. The hand keeps the world's time, the way
        // the hand's other answers do
        witnesses.append(Witness(seed: barnacle.seed, kind: .coming, at: now))
    }

    private func pryOff(at point: CGPoint, in size: CGSize) {
        var nearest: Barnacle?
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        for candidate in barnacles {
            let dx = point.x - candidate.x * size.width
            let dy = point.y - candidate.y * size.height
            let distance = hypot(dx, dy)
            if distance < nearestDistance {
                nearest = candidate
                nearestDistance = distance
            }
        }
        guard let nearest, nearestDistance <= 44 else { return }
        spawnRipple(nearest.unitPoint, kind: .pryOff)
        // the water does not forget at once: the trace keeps the shape
        // of the absence, at the size the creature had when it left
        let trace = Ghost(
            departedAt: .now,
            x: nearest.x,
            y: nearest.y,
            seed: nearest.seed,
            size: grownRadius(seed: nearest.seed, size: nearest.size, age: Date.now.addingTimeInterval(Self.timeOffset).timeIntervalSince(nearest.timestamp))
        )
        modelContext.insert(trace)
        modelContext.delete(nearest)
        // the water knows a life has left it — the trace holds the
        // shape of the absence, and the witness is the knowing
        // itself, kept a moment, and forgotten, the way the water
        // forgets everything
        witnesses.append(Witness(seed: nearest.seed, kind: .going, at: .now))
    }

    private func spawnRipple(_ unitPoint: CGPoint, kind: Ripple.Kind) {
        let ripple = Ripple(id: nextRippleID, unitPoint: unitPoint, start: .now, kind: kind)
        nextRippleID += 1
        ripples.append(ripple)
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            ripples.removeAll { $0.id == ripple.id }
        }
    }

    // MARK: - Text

    private var hint: some View {
        Text("press anywhere —\nlet a barnacle settle")
            .multilineTextAlignment(.center)
            .font(.system(.title3, design: .serif).italic())
            .foregroundStyle(.white.opacity(0.45))
            .padding(.horizontal, 40)
    }

    private var caption: some View {
        // the water keeps time, and the water has a day, and the
        // water speaks: the caption keeps the water's hour and the
        // water's voice as well
        TimelineView(.periodic(from: .now, by: 5)) { timeline in
            // the caption keeps the water's time: the piece's own
            // clock, shifted when it is shifted
            let vnow = timeline.date.addingTimeInterval(Self.timeOffset)
            VStack(spacing: 4) {
                Text(captionText)
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(.white.opacity(0.40))
                if let ageLine = ageLine(for: vnow) {
                    Text(ageLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let waterLine = waterLine(for: vnow) {
                    Text(waterLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let stormLine = stormLine(for: vnow) {
                    Text(stormLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let moonLine = moonLine(for: vnow) {
                    Text(moonLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let deepLine = deepLine(for: vnow) {
                    Text(deepLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let hushLine = hushLine(for: vnow) {
                    Text(hushLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let skitterLine = skitterLine(for: vnow) {
                    Text(skitterLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                // the knowing of the comings and the goings runs on
                // world time, like the hand's other answers: the
                // witnesses keep the world's time, not the shifted
                // clock, so the caption reads them on the world's
                // now, the way the voice does
                if let comingLine = comingLine(for: timeline.date) {
                    Text(comingLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let goingLine = goingLine(for: timeline.date) {
                    Text(goingLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let quietLine = quietLine(for: vnow) {
                    Text(quietLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                Text("hold a barnacle to let it go — the water will remember")
                    .font(.system(.caption2, design: .serif).italic())
                    .foregroundStyle(.white.opacity(0.20))
            }
            .padding(.bottom, 26)
        }
    }

    private var captionText: String {
        switch barnacles.count {
        case 1:
            return "one barnacle has made itself at home"
        default:
            return "\(barnacles.count) barnacles have made themselves at home"
        }
    }

    /// The colony keeps its own time: who has been longest here.
    private func ageLine(for now: Date) -> String? {
        guard let oldest = barnacles.map(\.timestamp).min() else { return nil }
        let age = now.timeIntervalSince(oldest)
        switch age {
        case ..<60:
            return "the eldest among you arrived moments ago"
        case ..<3600:
            let minutes = max(1, Int(age / 60))
            return minutes == 1
                ? "the eldest arrived a minute ago"
                : "the eldest arrived \(minutes) minutes ago"
        case ..<86_400:
            let hours = Int(age / 3600)
            return hours == 1
                ? "the eldest has kept this water for an hour"
                : "the eldest has kept this water for \(hours) hours"
        case ..<172_800:
            return "the eldest has kept this water for a day"
        default:
            let days = Int(age / 86_400)
            return "the eldest has kept this water for \(days) days"
        }
    }

    /// The water's own hour: whether it is in its day, its night, or
    /// the turning between the two. The turning is the water's own
    /// state, not a silence: it is the low light, the moment the
    /// sky's light comes down warm — and the caption says so, the
    /// way it says the day and the night.
    private func waterLine(for now: Date) -> String? {
        let light = Self.daylight(now.timeIntervalSinceReferenceDate)
        if light < 0.25 {
            return "the water is in its night"
        }
        if light > 0.75 {
            return "the water is in its day"
        }
        return "the water is in its turning"
    }

    /// The water's voice, as the caption keeps it: the water speaks
    /// as the tide turns, and the flood and the ebb speak, and the
    /// caption does not need to say that. Only at the slack — and
    /// not in the storm, and not where a moving hand has been
    /// swishing, and not where a body of the deep hushes the water —
    /// is the water quiet, and only then does the caption say so.
    private func quietLine(for now: Date) -> String? {
        let t = now.timeIntervalSinceReferenceDate
        let murmur = Self.murmurGain(
            strengthNow: Self.tide(t).strength,
            strengthThen: Self.tide(t - 2).strength
        )
        guard murmur < 0.03 else { return nil }
        guard Self.storm(t) < 0.1 else { return nil }
        // the swish is the hand's answer, and the hand is the
        // world's: it keeps the world's time, not the water's
        guard Self.handSwish(
            speed: handSpeed,
            age: max(0, Date.now.timeIntervalSince(handSpeedAt))
        ) < 0.03 else { return nil }
        // the hush is a different quiet: "the water is quiet" is the
        // slack's stillness, the water's own — where a body of the
        // deep is in the water the water hushes, and the caption
        // says that, not the other
        guard Self.hushGain(deep: Self.deep(t), twin: Self.deepTwin(t), t: t) < 0.05 else { return nil }
        return "the water is quiet"
    }

    /// The hush, as the caption keeps it: where a body of the deep
    /// is in the water the water's own speech goes thin around it —
    /// the water hushes, the way a river hushes around a stone — and
    /// the caption says so, the way it says the deep. The hush is
    /// the water's own quiet, made for the body, kept apart from the
    /// slack's quiet, the way the two are kept apart in the water.
    private func hushLine(for now: Date) -> String? {
        let t = now.timeIntervalSinceReferenceDate
        guard Self.hushGain(deep: Self.deep(t), twin: Self.deepTwin(t), t: t) > 0.05 else { return nil }
        return "the water hushes"
    }

    /// The quick ones' skitter, as the caption keeps it. The quick
    /// ones skitter always — the piece's own small motion, never
    /// still — but the caption counts the rare, the way it counts
    /// the deep: the skitter's loud corner, where the flood carries
    /// the quick ones and the night keeps them bright and the storm
    /// is over the water, the quick ones' storm hour, the way the
    /// colony has its storm word and the sky has its storm word and
    /// the quick ones have their skitter, and never in the calm,
    /// where the skitter is under everything, the way the quick
    /// ones are under everything, and the caption keeps its
    /// silence about the always, the way the caption keeps its
    /// silence about the water itself.
    private func skitterLine(for now: Date) -> String? {
        let t = now.timeIntervalSinceReferenceDate
        let skitter = Self.skitterGain(
            current: Self.tide(t).strength,
            light: Self.drawnLight(t),
            storm: Self.storm(t)
        )
        guard skitter >= 0.012 else { return nil }
        return "the quick ones skitter"
    }

    /// The water's knowing of a coming, as the caption keeps it: a
    /// new life settles, and the caption says so — for a moment,
    /// while the water knows it, the way a witness is a witness.
    /// The count line counts the colony, the way it counts; this
    /// names the moment of the coming itself, which the count does
    /// not name. And a moment later the water forgets the coming,
    /// the way it forgets everything, and the caption keeps its
    /// silence, the way the caption keeps its silence about the
    /// water itself. The witnesses keep the world's time (the hand's
    /// other answers do too), so this reads the world's now — on the
    /// shifted clock the knowing would read as old before it has
    /// happened.
    private func comingLine(for now: Date) -> String? {
        guard witnesses.contains(where: { $0.kind == .coming && now.timeIntervalSince($0.at) < 8 }) else { return nil }
        return "a new life has come to the water"
    }

    /// The water's knowing of a going, as the caption keeps it: a
    /// life is pried off, and the caption says so — for a moment,
    /// while the water knows it. The trace holds the shape of the
    /// absence, the way the water remembers the gone one a while
    /// and then forgets it; the caption keeps the knowing, not the
    /// trace, and keeps it a moment, the way the knowing is a
    /// moment: a loss lingers a moment longer than a coming, and
    /// the caption lingers with it, and then the water is the
    /// water again.
    private func goingLine(for now: Date) -> String? {
        guard witnesses.contains(where: { $0.kind == .going && now.timeIntervalSince($0.at) < 12 }) else { return nil }
        return "a life has left the water"
    }

    // MARK: - The Current

    /// The water is one body. A tide runs through it — slowly turning,
    /// swelling and easing — and everything free in it moves with it:
    /// the motes are carried, the light leans, the plumes of the
    /// anchored creatures reach into it. Nothing in the water moves
    /// alone. And the turning of this tide is what the water says
    /// when it speaks.
    static func tide(_ t: Double) -> (angle: Double, strength: Double) {
        // the tide turns on a long breath, and swells and eases;
        // in the storm the water chafes — the current surges, and
        // chatters fast and less sure of its way
        let s = Self.storm(t)
        let angle = 0.62 + 0.9 * sin(t * 2 * .pi / 420 + 1.3) + 0.45 * sin(t * 2 * .pi / 97 + 0.4)
            + 0.35 * s * sin(t * 2 * .pi / 2.3 + 1.1)
        let strength = (0.30 + 0.70 * (0.5 + 0.5 * sin(t * 2 * .pi / 260 + 2.2))) * (1 + 0.9 * s)
        return (angle, strength)
    }

    /// The surface drift the tide makes, in points per second.
    private func tideFlow(_ t: Double) -> (dx: Double, dy: Double) {
        let tide = Self.tide(t)
        let speed = 2.0 + 5.0 * tide.strength
        return (cos(tide.angle) * speed, sin(tide.angle) * speed)
    }

    /// The flow the water actually has at a point: the tide, bent
    /// around the hand where it is — a soft body in a moving stream.
    /// Far from the hand this is just the tide. At the hand's edge the
    /// flow stalls; at its sides it doubles — the way water goes
    /// around a rock.
    private func localFlow(_ p: CGPoint, finger: CGPoint?, presence: Double, t: Double) -> (dx: Double, dy: Double) {
        let flow = tideFlow(t)
        guard let f = finger, presence > 0.001 else { return (flow.dx, flow.dy) }
        let x = Double(p.x) - Double(f.x)
        let y = Double(p.y) - Double(f.y)
        let r2 = x * x + y * y
        let a = 110.0 * (0.5 + 0.5 * presence)
        let rs2 = max(r2, a * a * 0.25)
        let rs4 = rs2 * rs2
        let g = 1 - a * a * (x * x - y * y) / rs4
        let c = 2 * a * a * x * y / rs4
        let fx = Double(flow.dx), fy = Double(flow.dy)
        return (fx * g - fy * c, fy * g - fx * c)
    }

    /// How far the water at a point has been carried out of the way of
    /// the hand: the flow's deflection, carried along, plus a soft
    /// outward parting that holds even in still water.
    private func handParting(_ p: CGPoint, finger: CGPoint?, presence: Double, t: Double) -> (dx: Double, dy: Double) {
        guard let f = finger, presence > 0.001 else { return (0, 0) }
        let flow = tideFlow(t)
        let u = localFlow(p, finger: f, presence: presence, t: t)
        let x = Double(p.x) - Double(f.x)
        let y = Double(p.y) - Double(f.y)
        let r2 = x * x + y * y
        let r = r2.squareRoot()
        let part = 16.0 * presence * exp(-r2 / (2 * 120 * 120))
        let px = r > 1 ? x / r * part : 0
        let py = r > 1 ? y / r * part : 0
        return ((u.dx - flow.dx) * 6.0 * presence + px, (u.dy - flow.dy) * 6.0 * presence + py)
    }

    /// The parting the water makes around a deep body's back: a
    /// soft outward bending, strongest over the body, gone a
    /// body-length away — the way the water parts around the hand,
    /// only fainter: the deep bodies are deep, and the water turns
    /// around them only a little. The deep one's parting is the
    /// stronger of the two: it is the larger body, and the water
    /// turns around the larger body more.
    private func bodyParting(_ p: CGPoint, center: CGPoint, strength: Double, sx: Double, sy: Double) -> (dx: Double, dy: Double) {
        let nx = (Double(p.x) - Double(center.x)) / sx
        let ny = (Double(p.y) - Double(center.y)) / sy
        let r2 = nx * nx + ny * ny
        let r = max(r2.squareRoot(), 0.001)
        let part = strength * exp(-r2 / 2)
        return (nx / r * part, ny / r * part)
    }

    @inline(__always)
    private static func blendAngle(_ a: Double, _ b: Double, _ w: Double) -> Double {
        let d = atan2(sin(b - a), cos(b - a))
        return a + d * w
    }

    // MARK: - The Passing

    /// The quick ones: small lives that ride the current and never
    /// settle. They are not part of the record — the water keeps what
    /// stays, and lets go what passes — so they are kept nowhere. Each
    /// one's whole life is a function of the water's own clock, the
    /// way the tide and the motes are: it was running before the piece
    /// was opened, and it will be running after it is closed.
    ///
    /// They answer the hand the opposite way the colony does: the
    /// anchored turn toward it, tasting; the quick ones scatter from
    /// it. And when the hand is gone they drift back, and the water
    /// does not remember the hand. And now the piece hears them, the
    /// way the piece hears everything: the quick ones' own small
    /// voice — the skitter, high and brief, the quick ones' feet on
    /// the water's surface, five small voices the way the quick ones
    /// are five — kept in "The Voice" (skitterGain, and the hand's
    /// answer to the quick ones, skitterStartle), the way the piece
    /// keeps the water's.

    /// Five, no more: this water is not a school.
    private static let drifterCount = 5

    /// How far behind its own clock a quick one rides the current: it
    /// turns late, the way a small body turns late in moving water.
    private static let drifterRideLag: Double = 90

    private func drawPassing(_ context: inout GraphicsContext, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double, storm: Double, moon: Double, moonBeamX: Double) {
        for i in 0..<Self.drifterCount {
            drawDrifter(&context, index: i, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash, storm: storm, moon: moon, moonBeamX: moonBeamX)
        }
    }

    private func drawDrifter(_ context: inout GraphicsContext, index: Int, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double, storm: Double, moon: Double, moonBeamX: Double) {
        // 0x50415353 is "PASS" in hex: the ones who pass through
        let seed = 0x50415353

        // its depth: the near ones are larger and brighter, the far
        // ones are small and dim — and it is the water between the
        // depths that gives the piece its thickness
        let depth = 0.45 + 0.55 * Self.fuzz(seed, 10 + index)
        let scale = 0.55 + 0.75 * depth

        // the current at its lagged clock: the quick ones ride it and
        // turn late. A half-second back, the same lag.
        let carry = tideFlow(t - Self.drifterRideLag / 2)
        let step: Double = 0.6
        let now = Self.drifterRawPosition(index: index, size: size, t: t, carry: carry, finger: fingerPoint, presence: presence)
        let late = Self.drifterRawPosition(index: index, size: size, t: t - step, carry: tideFlow(t - step - Self.drifterRideLag / 2), finger: fingerPoint, presence: presence)
        let vx = (now.x - late.x) / step
        let vy = (now.y - late.y) / step
        let position = Self.drifterWrapped(CGPoint(x: now.x, y: now.y), in: size)


        // the heading: the filaments stream behind the motion, the way
        // the plumes stream behind the barnacles — and when its motion
        // stills, it points into the current, the way the colony does
        let speed = hypot(vx, vy)
        let motionAngle = atan2(vy, vx)
        let heading = Self.blendAngle(Self.tide(t).angle, motionAngle, Self.smoothstep(0.15, 0.9, speed))

        // the taste: when the motion stills it pauses, and the
        // filaments open
        let taste = 1 - min(1, speed / 3)

        // the body: a small warm thing, turned to its heading
        let bodyLength = (2.6 + 1.2 * Self.fuzz(seed, 140 + index)) * scale
        let bodyWidth = bodyLength * 0.45
        var bodyContext = context
        bodyContext.translateBy(x: position.x, y: position.y)
        bodyContext.rotate(by: .radians(heading))

        // the faint glow: what makes it read as life, and not dust —
        // and what, in the water's night, makes it read as life at
        // all. The quick ones shine of their own when the light is
        // gone, and a moving hand stirs that shine — and they ride
        // the storm, the way quick things ride everything, and in
        // it they shine
        var glow = (0.08 + 0.07 * taste) * (0.35 + 0.65 * depth) * (1 + 0.7 * (1 - light)) * (1 + 0.5 * storm)
        if handFlash > 0.001, let fp = fingerPoint {
            let d = hypot(Double(fp.x) - position.x, Double(fp.y) - position.y)
            glow += 0.10 * handFlash * (1 - Self.smoothstep(60, 200, d))
        }
        // the moon's light lays on the passing too — the quick ones
        // do not care which light sees them
        if moon > 0.02 {
            glow += 0.10 * moon * Self.moonBeamFall(
                x: Double(position.x),
                beamX: moonBeamX,
                sigma: Self.moonBeamSigma(width: size.width)
            )
        }
        bodyContext.fill(
            Path(ellipseIn: CGRect(x: -bodyLength * 2.4, y: -bodyLength * 2.4, width: bodyLength * 4.8, height: bodyLength * 4.8)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.80, green: 0.92, blue: 0.90).opacity(glow),
                    .clear,
                ]),
                center: .zero,
                startRadius: 0,
                endRadius: bodyLength * 2.4
            )
        )
        bodyContext.fill(
            Path(ellipseIn: CGRect(x: -bodyLength / 2, y: -bodyWidth / 2, width: bodyLength, height: bodyWidth)),
            with: .color(Color(red: 0.92, green: 0.97, blue: 0.95).opacity((0.26 + 0.30 * depth) * (0.45 + 0.55 * light)))
        )

        // the filaments: streaming behind, opening as it pauses —
        // and streaming faster still in the storm's surge
        let filamentCount = 3 + Int(Self.fuzz(seed, 141 + index) * 3)
        for i in 0..<filamentCount {
            let fan = (Double(i) - Double(filamentCount - 1) / 2) * (0.20 + 0.30 * taste)
            let sway = 0.12 * sin(t * 1.3 + 2 * .pi * Self.fuzz(seed, 142 + i) + Double(i) * 1.7)
            let a = .pi + fan + sway
            let length = (5 + 7 * Self.fuzz(seed, 150 + i)) * scale * (0.8 + 0.4 * taste) * (1 + 0.25 * storm)
            let curve: Double = (Self.fuzz(seed, 160 + i) > 0.5 ? 1 : -1) * 0.18
            let start = CGPoint(x: -bodyLength * 0.45, y: 0)
            let end = CGPoint(x: start.x + cos(a) * length, y: start.y + sin(a) * length)
            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let ctrl = CGPoint(x: midX - sin(a) * length * curve, y: midY + cos(a) * length * curve)
            var filament = Path()
            filament.move(to: start)
            filament.addQuadCurve(to: end, control: ctrl)
            bodyContext.stroke(
                filament,
                with: .color(Color(red: 0.85, green: 0.93, blue: 0.92)
                    .opacity((0.09 + 0.10 * depth + 0.06 * taste) * (0.5 + 0.5 * light) + 0.04 * (1 - light))),
                lineWidth: 0.8 + 0.4 * scale
            )
        }
    }

    /// One of the quick ones, at the water's clock: its own two slow
    /// sines, the carry of the tide, and the scatter of the hand.
    /// Nothing else, and nothing stored — the water keeps what stays,
    /// and lets go what passes.
    private static func drifterRawPosition(
        index: Int,
        size: CGSize,
        t: Double,
        carry: (dx: Double, dy: Double),
        finger: CGPoint?,
        presence: Double
    ) -> (x: Double, y: Double) {
        let seed = 0x50415353

        // its own wandering: two slow sines per axis, incommensurate,
        // so no two of its paths are the same, and none of them repeats
        let x0 = (0.10 + 0.80 * Self.fuzz(seed, 100 + index)) * Double(size.width)
        let y0 = (0.08 + 0.80 * Self.fuzz(seed, 110 + index)) * Double(size.height)
        let wx = (45 + 70 * Self.fuzz(seed, 120 + index)) * sin(t * 2 * .pi / (61 + 53 * Self.fuzz(seed, 121 + index)) + 2 * .pi * Self.fuzz(seed, 122 + index))
            + (25 + 35 * Self.fuzz(seed, 123 + index)) * sin(t * 2 * .pi / (37 + 29 * Self.fuzz(seed, 124 + index)) + 2 * .pi * Self.fuzz(seed, 125 + index))
        let wy = (40 + 60 * Self.fuzz(seed, 126 + index)) * sin(t * 2 * .pi / (67 + 49 * Self.fuzz(seed, 127 + index)) + 2 * .pi * Self.fuzz(seed, 128 + index))
            + (22 + 30 * Self.fuzz(seed, 129 + index)) * sin(t * 2 * .pi / (41 + 31 * Self.fuzz(seed, 130 + index)) + 2 * .pi * Self.fuzz(seed, 131 + index))

        // the ride: it carries the current with it, and turns late
        let rideFactor = 0.30 + 0.45 * Self.fuzz(seed, 132 + index)
        var x = x0 + wx + carry.dx * Self.drifterRideLag * rideFactor
        var y = y0 + wy + carry.dy * Self.drifterRideLag * rideFactor

        // the scatter: the hand parts the quick ones, and the water
        // does not remember the hand
        let s = scatterOffset(from: CGPoint(x: x, y: y), finger: finger, presence: presence)
        x += s.dx
        y += s.dy
        return (x, y)
    }

    /// The water wraps: what leaves one side comes in the other, so
    /// the passing never runs out, and the water never has to
    /// remember any of it.
    private static func drifterWrapped(_ raw: CGPoint, in size: CGSize) -> CGPoint {
        let spanX = Double(size.width) + 60
        let spanY = Double(size.height) + 60
        var x = Double(raw.x).truncatingRemainder(dividingBy: spanX)
        if x < 0 { x += spanX }
        var y = Double(raw.y).truncatingRemainder(dividingBy: spanY)
        if y < 0 { y += spanY }
        return CGPoint(x: x - 30, y: y - 30)
    }

    /// The scatter the hand makes on the quick ones: a soft push away,
    /// strongest close in, gone by 180 points. The water does not hold
    /// them, so when the hand is gone they drift back, and the water
    /// does not remember the hand.
    static func scatterOffset(from p: CGPoint, finger: CGPoint?, presence: Double) -> (dx: Double, dy: Double) {
        guard let f = finger, presence > 0.001 else { return (0, 0) }
        let x = Double(p.x) - Double(f.x)
        let y = Double(p.y) - Double(f.y)
        let d = hypot(x, y)
        guard d > 1 else { return (0, 0) }
        let falloff = 1 - Self.smoothstep(50, 180, d)
        let push = 150 * presence * falloff * falloff
        return (x / d * push, y / d * push)
    }

    // MARK: - The Day

    /// The water's own day: the light from the surface slowly dims
    /// and brightens again — a long night and a long day, on the
    /// water's clock, not on ours. The water's day is twenty-four
    /// minutes of ours: the tide turns in seven, the murk in four,
    /// and nothing in the water waits for the sun. In the night the
    /// colony is lit by its own faint light, and the hand is the
    /// only lamp there is.
    static func daylight(_ t: Double) -> Double {
        let day = 0.5 + 0.5 * sin(t * 2 * .pi / 1440 + 0.8)
        let murk = 0.06 * sin(t * 2 * .pi / 233 + 1.7)
        // the night is never pitch black: there is always some
        // light left in the water
        return min(1, max(0.02, day + murk))
    }

    /// The sky's light from above is not one light: it has a color,
    /// and the color turns with the water's day. At the low turning
    /// — the water's meeting of day and night, the low light — the
    /// light that comes down is warm, the way the low light is
    /// warm; at the high of the day the light that comes down is
    /// white, the way the high light is white; and in the deep
    /// night the sky has little light left to be warm. This is the
    /// warmth of the sky's light — a pure function of the water's
    /// clock, the way everything in the piece is — and it is the
    /// sky's, the way the deep's light is the deep's and the
    /// colony's glow is the colony's: the sky's light is the one
    /// that comes down, and it comes down warm at the turning and
    /// white at the high. And when the sky's cloud comes the light
    /// that comes down is less, the way the cloud takes the light,
    /// and the warmth goes down with it, the way the warmth goes
    /// down with the light. A pure function of t — the sky does not
    /// remember the turning, the way the sky forgets everything.
    static func skyWarmth(_ t: Double) -> Double {
        let day = daylight(t)
        // the warmth is a low-light thing: it peaks at the turning,
        // where the light is low, and is gone at the high, where the
        // light is white, and is nearly gone in the deep night,
        // where the sky has little light left at all
        return exp(-pow((day - 0.30) / 0.22, 2) / 2)
    }

    /// The color of the sky's light from above: warm gold at the low
    /// turning of the water's day, white at its high, and a faint
    /// warm in the deep night where the sky has little light left.
    /// At the high the color is white — the way the water renders at
    /// full light — so a full day is the full day the piece has
    /// always drawn, and the turning is the turning the piece has
    /// not once given its color. The color is the sky's, the way
    /// the deep's light is the deep's: the water's own small lights
    /// keep their own, and the sky's light is the one that comes
    /// down, and it comes down in a color.
    /// The color of the sky's light from above, in 0...1: warm gold
    /// at the low turning of the water's day, white at its high. This
    /// is the color the piece lays down for everything the sky's
    /// light touches — the surface light, the light shafts, the
    /// motes — and the piece's own small lights keep their own
    /// colors, the way the deep's light keeps its, the way the
    /// colony's glow keeps its.
    static func skyLightRGB(_ t: Double) -> (red: Double, green: Double, blue: Double) {
        let w = skyWarmth(t)
        // the sky's light goes from the gold of the low sun to the
        // white of the high sun: warm gold at the turning, white at
        // the high
        return (
            1.0,
            0.66 + 0.34 * (1 - w),
            0.52 + 0.48 * (1 - w)
        )
    }

    /// The color of the sky's light from above, as the piece draws
    /// it: the warm gold and the white, laid over the water where the
    /// light from above reaches.
    static func skyLightColor(_ t: Double) -> Color {
        let c = skyLightRGB(t)
        return Color(red: c.red, green: c.green, blue: c.blue)
    }

    /// The color of the water itself: the water drinks the color of
    /// the light that comes down. The sky's light is not only a
    /// brightness but a color — warm gold at the low turning, white
    /// at the high, the way the sky's light is — and the water takes
    /// the color it is given, the way water takes whatever the light
    /// in it is: white light leaves the water's own blue exactly as
    /// it is, the way the high leaves it, and the warm light of the
    /// turning gilds it, the way the low light gilds the sea —
    /// copper where the light lies, and teal where it does not. The
    /// piece's own small lights keep their own colors, the way the
    /// deep's light keeps its and the colony's glow keeps its; what
    /// drinks the sky's color is the water itself, and the water only
    /// drinks — it never adds its own — and when the turning turns to
    /// the day the water is the water again, and does not remember
    /// the gold, the way it forgets everything.
    static func waterColor(
        _ t: Double,
        light: Double
    ) -> (top: (red: Double, green: Double, blue: Double), bottom: (red: Double, green: Double, blue: Double)) {
        let sky = skyLightRGB(t)
        // the depth: darker in the water's night, the way the sea
        // is darker at night — and not black
        let depthLight = 0.35 + 0.65 * light
        let deepLight = 0.30 + 0.70 * light
        return (
            top: (
                red: 0.055 * depthLight * sky.red,
                green: 0.20 * depthLight * sky.green,
                blue: 0.245 * depthLight * sky.blue
            ),
            bottom: (
                red: 0.012 * deepLight * sky.red,
                green: 0.055 * deepLight * sky.green,
                blue: 0.11 * deepLight * sky.blue
            )
        )
    }

    /// The stirring the hand makes of the colony's self-light: in
    /// the water's night a moving hand is light, and the light
    /// lingers a moment after the hand has stopped or lifted. In
    /// full daylight the colony is lit by the surface and the
    /// stirring is not seen.
    static func handFlashEnvelope(speed: Double, age: Double, light: Double) -> Double {
        return min(1.2, speed / 400) * exp(-max(0, age) * 0.9) * (1 - light)
    }

    // MARK: - The Storm

    /// Rare weather over the water. The tide is the water's
    /// breathing; the storm is what the sky remembers of it. It
    /// comes only in the storm season, which turns on a calendar
    /// slower than the water's day, and only when two
    /// incommensurate currents turn to face the same way at once —
    /// so the storms are few, and none of them is the same, and the
    /// water is mostly calm. While it is here, the current surges,
    /// the rain falls, the light from above dims under the cloud,
    /// the colony tucks in, and the quick ones ride it the way
    /// quick things ride everything. And when the storm passes, the
    /// water is the water again, and does not remember it.
    static func storm(_ t: Double) -> Double {
        // the alignment: two incommensurate currents must turn to
        // face the same way at once
        let a = sin(t * 2 * .pi / 1439 + 0.7)
        let b = sin(t * 2 * .pi / 641 + 2.9)
        let alignment = a * b * 0.5 + 0.5
        // the season: the sky is willing only part of the time,
        // and what it wills, it wills slowly
        let season = 0.5 + 0.5 * sin(t * 2 * .pi / 3727 + 1.1)
        return smoothstep(0.78, 0.93, alignment) * pow(season, 3)
    }

    /// The light the piece actually draws: the water's day,
    /// darkened under the storm's cloud — and just the day, where
    /// the water is calm.
    static func drawnLight(_ t: Double) -> Double {
        let s = storm(t)
        return daylight(t) * (1 - 0.35 * s)
    }

    /// The weather the caption keeps: the storm comes rarely, and
    /// when it is here, or is already stirring, the caption says so.
    private func stormLine(for now: Date) -> String? {
        let s = Self.storm(now.timeIntervalSinceReferenceDate)
        if s > 0.5 {
            return "a storm is over the water"
        }
        if s > 0.15 {
            return "the storm is stirring"
        }
        return nil
    }

    // MARK: - The Moon

    /// The sky's own slow word. The storm is what the sky remembers
    /// of the water; the moon is what the sky says to it. It comes
    /// rarely — the way the storm comes, only rarer: two
    /// incommensurate currents must turn to face the same way at
    /// once, and the sky must be clear for it, and the clearing
    /// turns on a calendar slower than the storm's season — and it
    /// keeps to the night, the way the moon keeps to the night: in
    /// the day the sky is too bright, and the crossing passes
    /// unseen. While it is over the water, a broad beam of the
    /// sky's cold light drifts across it — the one light in the
    /// piece that moves across the water instead of over it — the
    /// colony is lit by the sky for a while, the motes catch the
    /// beam, the moving water glints under it, the way the sea
    /// glints under the moon. And when the crossing passes, the
    /// water is the water again, and does not remember it.
    static func moon(_ t: Double) -> Double {
        // the alignment: two incommensurate currents must turn to
        // face the same way at once, the way the storm's do
        let a = sin(t * 2 * .pi / 1723 + 0.9)
        let b = sin(t * 2 * .pi / 791 + 2.2)
        let alignment = a * b * 0.5 + 0.5
        // the clearing: the sky is clear for the moon only part of
        // the time, and what it is, it is slowly — slower still
        // than the storm's season
        let clearness = 0.5 + 0.5 * sin(t * 2 * .pi / 4871 + 0.5)
        return smoothstep(0.80, 0.97, alignment) * pow(clearness, 2)
    }

    /// The moon as the water sees it: the crossing, in the night.
    /// In the day the sky is too bright, and the water does not
    /// see the moon at all.
    static func moonDrawn(_ t: Double) -> Double {
        return moon(t) * (1 - daylight(t))
    }

    /// Where the moon's beam is: the crossing is a drifting — the
    /// beam moves across the water, slowly, the way the moon's
    /// light moves across the sea. The sky is patient.
    static func moonBeamX(_ t: Double, width: Double) -> Double {
        return width * (0.5 + 0.78 * sin(t * 2 * .pi / 887 + 1.7))
    }

    /// The beam's soft width: the moon's light is a broad one, the
    /// way the moon's light on the sea is broad.
    static func moonBeamSigma(width: Double) -> Double {
        return 0.16 * width
    }

    /// How much of the moon's light lies on a point of the water:
    /// most where the beam is, and a little way from it, none far
    /// from it.
    static func moonBeamFall(x: Double, beamX: Double, sigma: Double) -> Double {
        let d = (x - beamX) / sigma
        return exp(-d * d / 2)
    }

    /// The sky's own slow word, as the caption keeps it: the moon
    /// crosses rarely, and keeps to the night, and while it is over
    /// the water the caption says so, the way the caption keeps the
    /// storm.
    private func moonLine(for now: Date) -> String? {
        let m = Self.moonDrawn(now.timeIntervalSinceReferenceDate)
        if m > 0.5 {
            return "the moon crosses the water"
        }
        if m > 0.15 {
            return "the moon is over the water"
        }
        return nil
    }

    // MARK: - The Deep

    /// The deep one: a body in the water's depths — large, slow,
    /// and rarely there. It is the piece's lowest life: below the
    /// rock the colony is on, below the water the quick ones ride,
    /// in the dark where the light from the surface has given up.
    /// It comes the way the storm and the moon come, only rarer
    /// still — two incommensurate currents must turn to face the
    /// same way at once, and the deep season, which turns on a
    /// calendar slower than the sky's, must be willing. While it is
    /// here it drifts across the depths, entering from one side of
    /// the water and leaving by the other — the water's current
    /// goes around its back the way it goes around the hand, and
    /// the colony slows its breath under it, the way sleepers slow
    /// under a passing shadow. And when it passes, the water is the
    /// water again, and does not remember it — and the deep one
    /// does not remember the water either.
    static func deep(_ t: Double) -> Double {
        // the alignment: two incommensurate currents must turn to
        // face the same way at once — the storm's kind of coming,
        // held to a narrower gate, the way the deep is narrow
        let a = sin(t * 2 * .pi / 2531 + 0.3)
        let b = sin(t * 2 * .pi / 1117 + 2.6)
        let alignment = a * b * 0.5 + 0.5
        // the deep season: the deep keeps its own calendar, and it
        // turns slower than the sky's seasons, the way the deep
        // turns
        let season = 0.5 + 0.5 * sin(t * 2 * .pi / 5999 + 4.4)
        return smoothstep(0.86, 0.97, alignment) * pow(season, 3)
    }

    /// Where the deep one is crossing: its passing is a drifting —
    /// it enters from one side of the water and leaves by the
    /// other, slowly, the way something of its size moves. The
    /// water is patient; the deep is patient still.
    static func deepX(_ t: Double, width: Double) -> Double {
        return width * (0.5 + 0.92 * sin(t * 2 * .pi / 1433 + 2.2))
    }

    /// Where the deep one keeps: low in the water, always — and it
    /// breathes there, slowly, the way something that deep
    /// breathes.
    static func deepY(_ t: Double, height: Double) -> Double {
        return height * (0.80 + 0.045 * sin(t * 2 * .pi / 517 + 0.9))
    }

    /// The deep one's size: a body long enough that its passing is
    /// a crossing of the water, not a blink of it.
    static func deepBodyLength(width: Double) -> Double {
        return 0.55 * width
    }

    /// The deep one's voice, as a gain: one low tone, the way a
    /// single body makes a single sound. The water's voices are
    /// the water's motion — the murmur, the rain, the swish — and
    /// the granular voices of the populations — the colony's
    /// closing, the sky's glint. But the deep one is a body of its
    /// own, and its voice is its own: one low tone under the
    /// water, quiet the way the deep is quiet.
    static func deepGain(_ deep: Double) -> Double {
        return 0.05 * deep
    }

    /// How strongly the water goes around the deep one's back: the
    /// parting the current makes around the body — and the storm's
    /// surge makes the water go around it more, the way a flood
    /// bends more around a stone: the water is chafing, and where a
    /// body is in the water the water turns around it more. Where
    /// there is no storm this is the parting as it always was.
    static func deepPartingStrength(deep: Double, storm: Double) -> Double {
        return 9.0 * deep * (1 + 0.5 * storm)
    }

    /// The deep one's own small light: the piece's first light that
    /// is not the sky's. The light from above is the sky's, and it
    /// gives out in the deep, the way light gives out in the deep —
    /// but the deep one is a body of its own, and a body in the
    /// dark has a light of its own: a small cold one, made by the
    /// body, in the water's night, breathing at the body's breath —
    /// the same slow breath that makes the body's tone, the way a
    /// large body breathes — and gone when the passing is gone, and
    /// not remembered, the way everything is. And the light is not
    /// the sky's, so the sky's own dark word makes it brighter, not
    /// fainter: under the storm's cloud the light from above goes
    /// out more, and the deep's light comes up, the way the
    /// water's own small lights come up under the cloud — the
    /// piece's first light that is not the sky's, brightest of all
    /// where the sky is darkest. And that same breath
    /// reaches a long way: it reaches up to the surface, where the
    /// water answers with a faint cold swell — the answer, made the
    /// way an answer is made: the water carries it, and the body
    /// breathes it.
    static func deepLight(deep: Double, light: Double, t: Double) -> Double {
        // the light shows where the light from above is gone: it is
        // a night light, and a light under the storm's cloud, the
        // way the water's own small lights are
        let dark = 1 - light
        // the body breathes, the way the body breathes — the same
        // 37 s gain-breath that makes the body's tone in WaterVoice:
        // one body, one breath, one voice, one light
        let breath = 0.75 + 0.25 * sin(t * 2 * .pi / 37 + 1.2)
        return 0.10 * deep * dark * breath
    }

    /// The surface's answer to the deep one's breath: the body
    /// breathes, the way a large body breathes — the same slow 37 s
    /// breath that makes the body's tone and the body's light — and
    /// a breath that deep reaches a long way: it reaches up through
    /// the water to the surface, and where it arrives the water
    /// answers with a faint cold swell. The answer is the body's
    /// light reaching the surface: the same light, spread thin by
    /// the distance it has traveled, the way an echo is thinner than
    /// the voice that made it. It is made of the body's presence and
    /// the water's night, it travels at the water's pace, and it is
    /// gone when the passing is gone — and the water does not
    /// remember it, the way it forgets everything. One body, one
    /// breath, one voice, one light, one answer.
    static func deepAnswer(deep: Double, light: Double, t: Double) -> Double {
        // the answer is the light's reaching the surface: the same
        // breath, spread thin by the way it has traveled
        return Self.deepLight(deep: deep, light: light, t: t) * 0.6
    }

    /// The deep one, as the caption keeps it: it passes rarely, and
    /// while it is under the water the caption says so, the way the
    /// caption keeps the storm and the moon. And when the deep one
    /// and its twin are under the water at once — the piece's
    /// rarest moment — the caption says so in two words.
    private func deepLine(for now: Date) -> String? {
        let t = now.timeIntervalSinceReferenceDate
        let d = Self.deep(t)
        let tw = Self.deepTwin(t)
        if d > 0.5 && tw > 0.5 {
            return "two are in the deep"
        }
        if d > 0.5 || tw > 0.5 {
            return "the deep one is under the water"
        }
        if d > 0.15 || tw > 0.15 {
            return "something deep is passing"
        }
        return nil
    }

    // MARK: - The Twin

    /// The deep one's twin: the piece's rarest moment. The deep one
    /// is rarely there — two incommensurate currents and a season,
    /// the way the deep one comes. The twin comes the same way, on
    /// its own currents and its own season, calendars the deep one
    /// does not keep: two bodies, each with its own calendar, and
    /// the calendars do not agree, the way the deep does not agree
    /// with the sky. So the twin is rarely there, the deep one is
    /// rarely there, and the two are rarely there together — the
    /// piece's rarest moment, rarer still than the moon's crossing
    /// finding the deep one's back. While the twin is here it
    /// keeps a little higher in the water than the deep one, the
    /// way its kind keeps, and it is the smaller of the two, the
    /// way its kind is. And when it passes, the water is the water
    /// again, and does not remember it, the way it forgets
    /// everything.
    static func deepTwin(_ t: Double) -> Double {
        // the alignment: the twin's own two incommensurate currents
        // must turn to face the same way at once — the deep one's
        // kind of coming, on the twin's own calendar
        let a = sin(t * 2 * .pi / 2297 + 1.9)
        let b = sin(t * 2 * .pi / 1381 + 0.2)
        let alignment = a * b * 0.5 + 0.5
        // the twin's season: slower than the deep season still, the
        // way its kind turns
        let season = 0.5 + 0.5 * sin(t * 2 * .pi / 6761 + 2.8)
        return smoothstep(0.86, 0.97, alignment) * pow(season, 3)
    }

    /// Where the twin is crossing: its own drifting, on its own
    /// pace — the twin does not keep the deep one's pace, the way
    /// no two bodies of the deep keep one another's pace.
    static func deepTwinX(_ t: Double, width: Double) -> Double {
        return width * (0.5 + 0.92 * sin(t * 2 * .pi / 1679 + 4.1))
    }

    /// Where the twin keeps: a little higher in the water than the
    /// deep one, always — the two pass at different depths, the
    /// way two bodies of the deep pass, sometimes near abreast,
    /// sometimes far, and never in the same water.
    static func deepTwinY(_ t: Double, height: Double) -> Double {
        return height * (0.70 + 0.04 * sin(t * 2 * .pi / 431 + 2.3))
    }

    /// The twin's size: the smaller of the two — a body, but a
    /// lesser body, the way its kind is.
    static func deepTwinBodyLength(width: Double) -> Double {
        return 0.42 * width
    }

    /// The twin's voice, as a gain: one low tone, the way a single
    /// body makes a single sound — the twin's tone sits a little
    /// above the deep one's, the way a lesser body's voice sits a
    /// little above a larger body's, and where the two bodies are
    /// together the two tones beat against each other, three swells
    /// a second, the way two large bodies breathing at once would
    /// sound — the piece's rarest sound.
    static func deepTwinGain(_ twin: Double) -> Double {
        return 0.05 * twin
    }

    /// How strongly the water goes around the twin's back: the
    /// smaller body turns the water less, the way its kind turns —
    /// and the storm's surge bends the water around it more, the
    /// way the flood bends more around the stone, the way it bends
    /// more around the larger body's.
    static func deepTwinPartingStrength(twin: Double, storm: Double) -> Double {
        return 7.0 * twin * (1 + 0.5 * storm)
    }

    /// The twin's own small light: the twin is a body of its own,
    /// and a body in the dark has a light of its own — the twin's
    /// is the smaller of the two, a fainter, less blue one, made by
    /// the smaller body, in the water's night, breathing at the
    /// twin's own breath — a breath the deep one does not keep,
    /// the way the two bodies keep their own. One body, one voice,
    /// one light, for each of them. And that breath reaches the
    /// surface too, where the water answers it at the twin's own
    /// pace — the fainter of the two answers, keeping a little
    /// higher in the water, the way the twin keeps.
    static func deepTwinLight(twin: Double, light: Double, t: Double) -> Double {
        // the light shows where the light from above is gone, the
        // way the deep one's does
        let dark = 1 - light
        // the twin breathes at its own breath: 41 s, not the deep
        // one's 37 — the two bodies breathe at their own breaths,
        // the way two bodies do
        let breath = 0.75 + 0.25 * sin(t * 2 * .pi / 41 + 3.9)
        return 0.08 * twin * dark * breath
    }

    /// The twin's answer: the surface answers the twin's breath the
    /// same way it answers the deep one's — but a fainter, less
    /// blue swell, keeping a little higher in the water, the way
    /// the twin keeps a little higher, and breathing at the twin's
    /// own breath, the 41 s, not the deep one's 37: the two
    /// answers keep their own breaths, the way the two bodies do.
    /// And where the two are together — the piece's rarest moment —
    /// the surface carries two swells at once, each at its own
    /// breath: the rarest moment seen from above, the way the
    /// rarest sound is heard from below.
    static func deepTwinAnswer(twin: Double, light: Double, t: Double) -> Double {
        return Self.deepTwinLight(twin: twin, light: light, t: t) * 0.6
    }

    // MARK: - The Hush

    /// The water hushes where the body is. Everything else the body
    /// makes in the piece is a giving: the water goes around its
    /// back, the body carries a light, the surface answers its
    /// breath, the voice carries its tone. The hush is the one
    /// taking-away the body makes: where a body of the deep is in
    /// the water, the water's own speech — the murmur, the tide's
    /// turning — goes thin around it, the way a river's voice goes
    /// thin around a stone in its bed. The hush is the body's
    /// presence, not the body's envelope alone: it tracks the body's
    /// crossing, and when the body drifts fully off the water the
    /// hush goes with it, and the water speaks again, the way a
    /// river speaks again past the stone. The smaller body hushes
    /// the water less, the way the smaller body turns the water
    /// less — seven ninths of the way the larger one does, the way
    /// its kind turns. And the hush is on the water's own voice
    /// only: the rain keeps falling, the way rain keeps falling on a
    /// stone, and the body's own tone keeps its own breath through
    /// the hush, the way the body does not read the sky's word — one
    /// speaks, one hushes, and the hush is the water's, made for the
    /// body, gone when the body is gone, and not remembered, the
    /// way everything is. A pure function of the water's clock —
    /// the water does not remember the hush; verify with the shifted
    /// clock.
    static func hushGain(deep: Double, twin: Double, t: Double) -> Double {
        // the hush is the water's, so it is measured on the water's
        // own width, the way the water measures anything: the
        // body's crossing on the water's own scale
        func hush(_ x: Double, presence: Double, sigma: Double) -> Double {
            guard presence > 0 else { return 0 }
            // the hush is where the body is: the water's own
            // parting, a falloff on the body's crossing, the way the
            // water's own parting of the body is
            let d = (x - 0.5) / sigma
            return exp(-0.5 * d * d) * presence
        }
        // the larger body hushes the water more, the way the larger
        // body turns the water more — the water's own parting of
        // the larger body is the wider, and the hush is wide with
        // it
        let hushDeep = 0.40 * hush(Self.deepX(t, width: 1), presence: deep, sigma: 0.30)
        // the smaller body hushes the water less, the way its kind
        // turns: seven ninths of the larger body's hush, the way
        // seven ninths of its turning
        let hushTwin = 0.31 * hush(Self.deepTwinX(t, width: 1), presence: twin, sigma: 0.24)
        return max(hushDeep, hushTwin)
    }

    /// The murmur the water actually speaks: the tide's turning,
    /// thinned where a body of the deep is in the water — the water
    /// hushes where the body speaks. The hush only takes, and never
    /// gives: the spoken murmur never exceeds the turning's own
    /// voice, the way a hush is a taking-away, not a giving. Where
    /// no body is in the water this is the murmur as it always was.
    static func spokenMurmur(
        strengthNow: Double,
        strengthThen: Double,
        deep: Double,
        twin: Double,
        t: Double
    ) -> Double {
        return Self.murmurGain(strengthNow: strengthNow, strengthThen: strengthThen)
            * (1 - Self.hushGain(deep: deep, twin: twin, t: t))
    }

    // MARK: - The Opening

    /// The colony's word in its calm: the opening. The colony has
    /// a word in its weather — the tuck, the closing, when the
    /// storm tucks it in — and its home is the calm: the water is
    /// calm most of the water's days, and the colony was silent
    /// at home. The opening is the colony's word at home: one soft
    /// chime, sparse, at the colony's own pace — not the storm's,
    /// not the tide's, its own — the way no two shells open
    /// together. It is full in the deep calm, and gone at the
    /// storm's full, the way the colony's two words turn with the
    /// weather, the way a sleeper's breath turns. And the colony's
    /// quiet word keeps below its storm word: the opening at most
    /// 0.015, the closing at most 0.06, the way the sky's word
    /// keeps below the body's.
    static func openingGain(storm: Double) -> Double {
        return 0.015 * (1 - storm)
    }

    /// The new life's first adult breath, as the piece witnesses
    /// it: a barnacle completes its becoming — the sixty seconds
    /// of layering, the way a barnacle layers — and the piece
    /// sees it while it is happening: a bloom of the colony's own
    /// light, one slow ring that goes out once, and the colony's
    /// one opening voice opens for it, a soft chime, the loudest
    /// the opening is. The witness window is short — the piece
    /// sees the becoming while it is happening, and a moment
    /// after, and not a moment longer: after that the creature is
    /// what it is, the size the water remembers it by, and the
    /// piece keeps its size, not its becoming.
    static func isBecoming(_ age: Double) -> Bool {
        return age >= 60 && age < 75
    }

    /// The bloom's own light: one slow ring of the colony's own
    /// light, going out once — quick to come, slow to go, gone
    /// within a few seconds, and not remembered, the way the
    /// water's small lights are, and the way the water forgets
    /// everything.
    static func bloomFade(_ age: Double) -> Double {
        return 1 - smoothstep(0.5, 6, age)
    }

    /// The bloom's chime, as a gain: the colony's one opening
    /// voice, opening for a new life — the loudest the opening
    /// is — quick to come, slow to go, gone within a few seconds,
    /// and not remembered, the way everything is.
    static func bloomChime(_ age: Double) -> Double {
        return 0.03 * exp(-max(0, age) * 1.1)
    }

    // MARK: - The Coming And The Going

    /// The water's knowing of a coming: a new life settles, and the
    /// water knows a life has come to it. The ripple is the
    /// coming's face — the small slow ring where the life arrives —
    /// and this is the knowing itself: one small grain in the
    /// water's voice, quick to come, and gone in a few seconds,
    /// and not remembered, the way the water forgets everything.
    /// The piece has always witnessed the becoming — the sixty
    /// seconds of layering, the bloom, the chime — and did not
    /// know the moment of the coming itself, the way a colony
    /// keeps the creature and not the arrival. The knowing is the
    /// water's, not the hand's: it runs on the world's time, the
    /// way the hand's other answers do, and it is the same in the
    /// day and in the night, the way the water's knowing is the
    /// water's. The coming's grain keeps below the colony's quiet
    /// word, the way the small keeps below the large: 0.008
    /// against the opening's 0.015, and the piece's account of its
    /// voices is kept.
    static func comingGain(_ age: Double) -> Double {
        return 0.008 * exp(-max(0, age) * 0.5)
    }

    /// The water's knowing of a going: a life is pried off, and the
    /// water knows a life has left it. The trace holds the shape
    /// of the absence — kept a while, then dissolved, then pruned,
    /// the way the water forgets — and this is the knowing itself:
    /// one small grain, a little deeper than the coming's, a
    /// little quieter, and a little longer: a loss is quieter than
    /// a coming, and a loss lingers a moment longer, the way a loss
    /// lingers. 0.005 against the coming's 0.008, and the two
    /// together — a coming and a going at the same moment, the
    /// piece keeping both — never run past the colony's quiet word
    /// of 0.015, the way the small keeps below the large, the way
    /// the piece keeps its own account of its own voices.
    static func goingGain(_ age: Double) -> Double {
        return 0.005 * exp(-max(0, age) * 0.35)
    }

    // MARK: - The Wake

    /// How long the wake holds before the water forgets it. It is a
    /// moment — quick to come, slow to go — and no longer.
    static let wakeLife: Double = 1.6

    /// The light a moving hand makes in the water itself: the way the
    /// sea sparkles where a wave breaks. It is the water's own small
    /// light, stirred along the hand's path — not the light from
    /// above, and not the colony's glow — and it shows where the
    /// light from above is gone. A still hand makes no wake at all: a
    /// still hand is a lamp, and a moving hand is a maker of light.
    static func wakeStrength(speed: Double, light: Double, storm: Double) -> Double {
        // the stirring: a still hand makes none, a fast hand makes much
        let stirred = min(1, speed / 450)
        // the water's small light shows where the light from above is
        // gone: faint in the full day, strong in the night
        let dark = 1 - light
        // the storm's cloud is a going-out of the light, and the wake
        // shows under it, the way everything the water makes shows
        return stirred * (0.05 + 0.22 * dark) * (1 + 0.5 * storm)
    }

    /// The wake lingers a moment after the hand, and then the water
    /// forgets it — the way it forgets the hand, and the storm, and
    /// everything.
    static func wakeFade(age: Double) -> Double {
        return 1 - smoothstep(0.12, Self.wakeLife, age)
    }

    // MARK: - The Voice

    /// The water's voice is not added to the piece: it is the
    /// piece's own motion, heard. The same tide that carries the
    /// motes is what murmurs — and the water speaks as the tide
    /// *turns*, so the slack water is quiet, and the flood and the
    /// ebb speak. The same storm that darkens the water is what
    /// falls as rain. And a moving hand is what swishes, the way
    /// the sea swishes where a wave breaks: the same hand that makes
    /// the wake makes the swish, and a still hand makes neither,
    /// the way a still hand is only a lamp. And the colony, when
    /// the storm comes and it tucks in, closes its shells, and the
    /// closing is a granular voice, made of the colony itself:
    /// sparse and far at the storm's stirring, a bed of closings at
    /// the storm's full — and where there is no storm the colony is
    /// quiet, the way the slack water is quiet. The colony's voice
    /// is the storm's, not the colony's: the colony speaks only
    /// when the water is angry. But the colony has a word in its
    /// calm, the way it has a word in its weather: the opening,
    /// one soft chime, sparse, at the colony's own pace — the
    /// colony's word at home, full in the deep calm and gone at the
    /// storm's full, the way the colony's two words turn with the
    /// weather — and the new life's first adult breath, witnessed:
    /// a bloom of the colony's own light, one slow ring, and the
    /// chime, the loudest the opening is, kept a moment and
    /// forgotten the way everything is. And where the moon's light lies on
    /// the moving water, the water glints — small and high and
    /// sparse, the way a glint is: the sky's voice on the water,
    /// heard, and gone, and forgotten, the way the sky forgets
    /// everything. And when the water comes to its turning and the
    /// sky's light comes down warm, the voice warms with it — a low
    /// warm wash, the sky's voice in its warm hour, the way the rain
    /// is the sky's voice in its dark hour, and the glint is the
    /// sky's voice in its cold hour: the moving water gilds, the
    /// still water does not — and when the turning turns to the day
    /// the wash is gone, and the water does not remember the
    /// warmth, the way it forgets everything. And the sky's dark
    /// word has a low end — the roll under the rain: the storm's
    /// voice in the deep, very low and very slow, rolling within
    /// the storm the way a storm rolls within itself; and where
    /// the sky's dark word is over the water and a body of the
    /// deep is under it, the sky's word and the body's word sound
    /// in the same deep — the rarest weather heard at its bottom —
    /// and when the storm passes the roll goes with it, and the
    /// water does not remember it, the way it forgets everything.
    /// And the water knows the comings and the goings — a life
    /// settling, the water knowing a life has come to it, a small
    /// grain, and a life pried off, the water knowing a life has
    /// left it, a smaller grain, a little deeper, a little
    /// longer: a loss is quieter than a coming, and a loss lingers
    /// a moment longer. The piece has always witnessed the
    /// becoming — the bloom, the chime — and did not know the
    /// coming itself, the way it did not know the going, and
    /// knows them now, a moment each, and forgets them, the way
    /// it forgets everything: the water keeps the body and the
    /// trace, and not the knowing. The coming's grain keeps below
    /// the colony's quiet word, the going's keeps below the
    /// coming's, and the two together never run past the opening's
    /// full, the way the small keeps below the large, the way the
    /// piece keeps its own account of its own voices: the closing
    /// is eight small voices, the glint is six grains, the deep
    /// one is one voice, the opening is one, the quick ones are
    /// five, and the water's knowing of the comings and the
    /// goings is one each — one grain for the coming, one grain
    /// for the going, the way the small keeps below the large.

    /// How much of the water's low voice is up at a moment: the
    /// voice is the *turning* of the current — the change of the
    /// current's strength, not its strength. At the slack, where the
    /// strength is neither swelling nor easing, the water is quiet.
    /// The turning is measured over a two-second window, the way the
    /// water measures anything: slowly.
    static func murmurGain(strengthNow: Double, strengthThen: Double) -> Double {
        let turn = abs(strengthNow - strengthThen) / 2
        // the voice is a low one: quiet at the slack, up with the
        // flood and the ebb
        return 0.14 * smoothstep(0, 0.004, turn)
    }

    /// The rain the storm brings down, as a voice: it falls only
    /// when the storm is over the water, and a little less in the
    /// night, where the dark keeps the water's own small things to
    /// itself.
    static func rainGain(storm: Double, light: Double) -> Double {
        return 0.16 * storm * (0.6 + 0.4 * light)
    }

    /// The swish of a hand parting the water: the water's answer to
    /// the hand, heard, the way the wake is the water's answer,
    /// seen. It lingers a moment after the hand has stopped or
    /// lifted, and then the water is quiet again. A still hand
    /// makes no swish at all: a still hand is only a lamp, and a
    /// lamp is only light.
    static func handSwish(speed: Double, age: Double) -> Double {
        let stirred = min(1, speed / 450)
        return 0.22 * stirred * exp(-max(0, age) * 0.9)
    }

    /// The colony's closing, as a voice: when the storm comes the
    /// colony tucks in, and the closing of its shells is what the
    /// colony says — a granular voice, made of the colony itself.
    /// It is the storm's voice, not the colony's: the closing comes
    /// and thickens with the storm, and where there is no storm the
    /// colony is quiet, the way the slack water is quiet. When the
    /// storm passes, the closing is gone the way the storm is gone,
    /// and the water does not remember it.
    static func tuckGain(storm: Double) -> Double {
        return 0.06 * storm
    }

    /// The sky's own voice on the water: where the moon's light
    /// lies, the moving water glints — small and high and sparse,
    /// the way a glint is. The glint is the sky's light on the
    /// water's *motion*: the still water glints less, the moving
    /// water glints more — the moon does not make the sparkle, it
    /// makes it visible. Where the moon is not, the sky is silent,
    /// the way the sky is silent most of the time, and when the
    /// crossing passes, the glint is gone the way the crossing is
    /// gone, and the water does not remember it.
    static func glintGain(moon: Double, current: Double) -> Double {
        // the glint is light on motion: the tide's strength, which
        // the water measures the way it measures anything
        let motion = min(1, max(0, (current - 0.3) / 0.7))
        return 0.03 * moon * (0.30 + 0.70 * motion)
    }

    /// The sky's warm word, as a voice. The sky has a voice in its
    /// dark hour — the rain, where the storm is — and a voice in its
    /// cold hour — the glint, where the moon's light lies on the
    /// moving water — and its warm hour, the turning, the low light
    /// where the sky's light comes down warm gold, has one now: a
    /// low warm wash, present only while the light is warm, gone at
    /// the high where the light is white, and gone in the deep night
    /// where the sky has given out. It is the sky's voice on the
    /// water's *motion*, the way the glint is: the moving water
    /// gilds, the still water does not — the sky does not make the
    /// warmth, it makes the warmth audible in the motion, the way
    /// the moon makes the sparkle. The sky's dark word is the rain,
    /// the sky's cold word is the glint, and the sky's warm word is
    /// this — and when the turning turns to the day the wash is
    /// gone, and the water does not remember the warmth, the way it
    /// forgets everything.
    static func gildGain(warmth: Double, current: Double) -> Double {
        // the gild is warmth on motion: the tide's strength, which
        // the water measures the way it measures anything — the
        // moving water gilds, the still water does not
        let motion = min(1, max(0, (current - 0.3) / 0.7))
        return 0.04 * warmth * (0.30 + 0.70 * motion)
    }

    /// The sky's dark word has a low end. The rain — the sky's
    /// dark word — falls on the surface, hissed into the high, the
    /// way falling is; and the sky's other words are words of the
    /// surface still: the glint, high grains of the moon's light,
    /// the gild, a warm low band of the turning. The deep, the
    /// water's bottom, has the body's voice — the deep one's low
    /// tone, the twin's a little above — and the sky's word never
    /// reaches it. But a storm is a body of weather, and a body
    /// has a bottom, the way the sea has a bottom: under the rain
    /// there is the roll — very low, very slow, the storm's voice
    /// in the deep. It is the sky's, not the deep's: the sky does
    /// not read the body, the way the body does not read the
    /// sky's word — and where the storm is over the water and a
    /// body of the deep is under it, the sky's word and the
    /// body's word sound in the same deep, the rarest weather
    /// heard at its bottom: the meeting is not made, it comes of
    /// two voices at once, the way it comes of two bodies at
    /// once. The low end never drowns the surface's own voice —
    /// the roll stays far below the rain, the way a bottom is
    /// below the surface — and it keeps below the body's own
    /// voice, the way the sky's word keeps below the body's: the
    /// tone is heard above the roll, the way the body's voice is
    /// the body's. A little less in the night, the way the rain
    /// is a little less in the night. And when the storm passes
    /// the roll goes with it, and the water is the water again,
    /// and does not remember the roll, the way it forgets
    /// everything.
    static func rollGain(storm: Double, light: Double) -> Double {
        return 0.035 * storm * (0.6 + 0.4 * light)
    }

    /// The quick ones' skitter. The piece's account of its own
    /// voices had kept the quick ones out: the water speaks — the
    /// murmur, the rain, the swish, the hush — and the sky speaks
    /// — the rain, the roll, the glint, the gild — and the colony
    /// speaks — the closing, the opening — and the deep speaks —
    /// the one low tone, the twin's a little above — but the
    /// quick ones, the five small lives that ride the current and
    /// never settle, had never once been heard, the way the
    /// passing had never been heard, the way the passing is the
    /// passing. Now they are heard: a skitter, high and brief and
    /// small, the quick ones' feet on the water's surface. The
    /// current is what carries them — the flood and the ebb carry
    /// them more than the slack, the way the moving water carries
    /// the quick ones and the still water does not — and a little
    /// more in the night, the way the quick ones' light is a
    /// little more in the night, the way the quick ones shine of
    /// their own where the light is gone, and more in the storm,
    /// the way the quick ones ride the storm: they ride
    /// everything, the way the quick ones ride everything. And
    /// the skitter never fully stops, the way the quick ones
    /// never stop: at the slack it thins to its floor, the way
    /// the still water glints less than the moving water — less,
    /// not none — and where a body of the deep hushes the water
    /// the skitter keeps its own pace through it, the way the
    /// quick ones skim over what the water keeps thin, the way
    /// the quick ones do not read the hush, the way the quick
    /// ones keep their own. And the skitter keeps below the
    /// colony's quiet word — the quick ones are small, the way
    /// the quick ones are small — and keeps below the closing's
    /// full, the way the small keeps below the large, the way
    /// the piece keeps its own account of its own voices: the
    /// closing is eight small voices, the glint is six grains,
    /// the deep one is one voice, the opening is one, and the
    /// quick ones are five, the way the quick ones are five.
    static func skitterGain(current: Double, light: Double, storm: Double) -> Double {
        // the quick ones ride the current: the tide's strength,
        // which the water measures the way it measures anything —
        // the moving water carries the quick ones, the still
        // water does not; at the slack the skitter keeps its
        // floor, the way the quick ones never stop
        let motion = min(1, max(0, (current - 0.3) / 0.7))
        // a little more in the night, the way the quick ones'
        // light is a little more in the night — and more in the
        // storm, the way the quick ones ride the storm
        return 0.0085 * (0.3 + 0.7 * motion) * (1.3 - 0.3 * light) * (1 + 0.3 * storm)
    }

    /// The hand's answer to the quick ones, heard. A moving hand
    /// parts the quick ones, the way it parts the water — and
    /// the quick ones, parted, skitter away, the way startled
    /// things skitter: the skitter thickens for a moment, the
    /// way a scatter thickens, and settles back to the current's
    /// pace, the way the quick ones drift back, and the water
    /// does not remember the hand, the way it forgets
    /// everything. A still hand parts them quietly: a still hand
    /// is only a lamp, and a lamp is only light, and the quick
    /// ones keep their pace under the lamp, the way the quick
    /// ones keep their pace. The startle keeps below the quick
    /// ones' own voice — the hand's answer keeps below the
    /// quick ones' skitter, the way the hand's answers keep
    /// below the water's — and it runs on the world's time, the
    /// way the hand's other answers do: it is the hand the water
    /// knows, not the clock the water keeps.
    static func skitterStartle(speed: Double, age: Double) -> Double {
        // the startle is the hand's, not the quick ones': a
        // still hand startles none, a fast hand startles most
        let stirred = min(1, speed / 450)
        // quick to come, slow to go, gone within a few seconds —
        // and not remembered, the way the water forgets the hand
        return 0.004 * stirred * exp(-max(0, age) * 0.7)
    }

    // MARK: - Virtual Time

    /// The piece's own clock can be shifted, for testing and for
    /// verification: with a nonzero offset the piece renders, and
    /// keeps its records, as if its clock ran this many seconds
    /// ahead of (or behind) the world's. The water does not know
    /// the difference — for the water there is only its own clock.
    /// Zero, the piece is in the world's time, the way it is in
    /// the water.
    static var timeOffset: TimeInterval = 0

    /// The shift the launch argument carries, if it carries one:
    /// `-fb.virtualTimeOffset <seconds>`. A dangling or numberless
    /// argument carries no shift, and the piece keeps the world's
    /// time.
    static func virtualTimeOffset(from arguments: [String]) -> TimeInterval {
        guard let i = arguments.firstIndex(of: "-fb.virtualTimeOffset") else { return 0 }
        guard i + 1 < arguments.count, let value = Double(arguments[i + 1]) else { return 0 }
        return value
    }

    /// The water's voice can be kept, for testing and for a room
    /// that wants quiet: `-fb.noVoice`. The water does not speak,
    /// and is no less the water for it — the piece's motion is the
    /// piece's motion, whether it is heard or not.
    static var voiceEnabled: Bool = true

    /// Whether the launch arguments ask for the water's silence:
    /// `-fb.noVoice` keeps the piece's voice, the way a held breath
    /// is still a breath.
    static func voiceEnabled(from arguments: [String]) -> Bool {
        return !arguments.contains("-fb.noVoice")
    }

    // MARK: - Drawing

    /// Deterministic unit random from (seed, channel): the fuzz behind
    /// every barnacle's shape, colour, and rhythm.
    @inline(__always)
    private static func fuzz(_ seed: Int, _ channel: Int) -> Double {
        var z = UInt64(bitPattern: Int64(seed)) &+ UInt64(bitPattern: Int64(channel)) &* 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return Double(z & 0xFFFFFF) / Double(0x1000000)
    }

    private func shellColor(seed: Int) -> Color {
        Color(
            hue: 0.082 + 0.05 * Self.fuzz(seed, 1),
            saturation: 0.14 + 0.12 * Self.fuzz(seed, 2),
            brightness: 0.80 + 0.10 * Self.fuzz(seed, 3)
        )
    }

    private func plateColor(seed: Int) -> Color {
        Color(
            hue: 0.088 + 0.035 * Self.fuzz(seed, 41),
            saturation: 0.30 + 0.14 * Self.fuzz(seed, 42),
            brightness: 0.42 + 0.12 * Self.fuzz(seed, 43)
        )
    }

    /// How present the hand is right now: eases in over the first moment
    /// of a touch, eases out over the half-second after it lifts.
    private func fingerPresence(now: Date) -> Double {
        if fingerDown {
            let t = now.timeIntervalSince(fingerDownSince ?? now)
            return Self.smoothstep(0, 0.14, t)
        } else if let up = fingerUpSince {
            let t = now.timeIntervalSince(up)
            return 1 - Self.smoothstep(0, 0.5, t)
        } else {
            return 0
        }
    }

    @inline(__always)
    private static func smoothstep(_ a: Double, _ b: Double, _ x: Double) -> Double {
        let t = max(0, min(1, (x - a) / (b - a)))
        return t * t * (3 - 2 * t)
    }

    /// A barnacle is not finished when it settles. It arrives small and
    /// accretes slowly — layer over layer, the way real ones do — to its
    /// adult size across the first minute of its life. After that it is
    /// what it is: the size the water remembers it by.
    private func grownRadius(seed: Int, size: Double, age: Double) -> Double {
        let adult = size * (1.15 + 0.45 * Self.fuzz(seed, 9))
        let p = min(1, age / 60)
        let eased = 1 - pow(1 - p, 2)
        return size + (adult - size) * eased
    }

    /// A dim warm light where the hand is — as if it refracts the light
    /// from above — so the colony's turning toward it reads. In the
    /// water's night the hand is the only lamp there is, and it
    /// reads as one.
    private func drawHandGlow(_ context: inout GraphicsContext, fingerPoint: CGPoint?, presence: Double, light: Double, storm: Double) {
        guard let fp = fingerPoint, presence > 0.001 else { return }
        let radius: CGFloat = 160
        // in the night the hand is the only lamp there is, and in
        // the storm the lamp is needed most
        let glow = 0.15 + 0.09 * (1 - light) + 0.05 * storm
        context.fill(
            Path(ellipseIn: CGRect(x: fp.x - radius, y: fp.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 1.0, green: 0.93, blue: 0.80).opacity(glow * presence),
                    .clear,
                ]),
                center: fp,
                startRadius: 0,
                endRadius: radius
            )
        )
    }

    /// The wake: the light a moving hand makes in the water itself,
    /// drawn from the hand's recent path — the water's own small
    /// light, stirred, and gone, and forgotten, the way the water
    /// forgets.
    private func drawWake(_ context: inout GraphicsContext, now: Date, light: Double, storm: Double) {
        for sample in handTrail {
            let age = now.timeIntervalSince(sample.time)
            let fade = Self.wakeFade(age: age)
            guard fade > 0.004 else { continue }
            let strength = Self.wakeStrength(speed: sample.speed, light: light, storm: storm)
            guard strength > 0.004 else { continue }
            let radius = 24.0
            context.fill(
                Path(ellipseIn: CGRect(
                    x: sample.point.x - radius,
                    y: sample.point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 0.62, green: 0.96, blue: 0.95).opacity(strength * fade),
                        .clear,
                    ]),
                    center: sample.point,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }
    }

    /// The bloom, drawn: one slow ring of the colony's own light,
    /// going out once, the way a breath goes out — wider as it
    /// goes, fainter as it goes, shown where the light from above
    /// is gone the way the colony's own small lights are, and a
    /// little in the day, the way a breath is seen in the day.
    /// When it goes, the water does not remember it, the way it
    /// forgets everything.
    private func drawBloom(_ context: inout GraphicsContext, _ bloom: Bloom, size: CGSize, now: Date, light: Double) {
        guard let b = barnacles.first(where: { $0.seed == bloom.seed }) else { return }
        let age = now.timeIntervalSince(bloom.at)
        let fade = Self.bloomFade(age)
        guard fade > 0.004 else { return }
        let center = CGPoint(x: b.x * size.width, y: b.y * size.height)
        let radius = grownRadius(seed: b.seed, size: b.size, age: now.timeIntervalSince(b.timestamp))
        // the ring goes out once, the way a breath goes out:
        // slow, and wider as it goes
        let p = min(1, age / 6)
        let ringRadius = radius * (2.2 + 2.6 * p)
        // shown where the light from above is gone, the way the
        // colony's own small lights are — and a little in the day,
        // the way a breath is seen in the day
        let vis = 0.16 * fade * (0.30 + 0.70 * (1 - light))
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - ringRadius,
                y: center.y - ringRadius,
                width: ringRadius * 2,
                height: ringRadius * 2
            )),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color(red: 0.55, green: 0.95, blue: 0.88).opacity(vis), location: 0.75),
                    .init(color: .clear, location: 1),
                ]),
                center: center,
                startRadius: 0,
                endRadius: ringRadius
            )
        )
    }

    private func drawWater(_ context: inout GraphicsContext, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, storm: Double, moon: Double, moonBeamX: Double, deep: Double, deepCenter: CGPoint, deepTwin: Double, deepTwinCenter: CGPoint) {
        let rect = CGRect(origin: .zero, size: size)

        // the color of the sky's light from above: the water's day
        // has a color, not only a brightness — warm gold at the low
        // turning, white at the high, and a faint warm in the deep
        // night where the sky has little light left. The water's own
        // small lights keep their own colors; this is the one that
        // comes down, and it comes down in a color
        let skyColor = Self.skyLightColor(t)

        // the water's own color: the water drinks the color of the
        // light it is given — gilded at the turning, the way the sea
        // is gilded at dusk, and its own blue at the high, the way
        // the sea is its own blue under a white sky. In the night
        // the sky has little light left to give a color, and the
        // water is nearly dark, and what color is left in it is the
        // sky's. The water only drinks; it never adds its own
        let water = Self.waterColor(t, light: light)
        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: water.top.red, green: water.top.green, blue: water.top.blue),
                    Color(red: water.bottom.red, green: water.bottom.green, blue: water.bottom.blue),
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        // soft light from the surface: gone with the day, and in a
        // color — the sky's light comes down warm at the turning and
        // white at the high, the way the low light is warm and the
        // high light is white
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(colors: [skyColor.opacity(0.10 * (0.15 + 0.85 * light)), .clear]),
                center: CGPoint(x: size.width * 0.5, y: -size.height * 0.25),
                startRadius: 0,
                endRadius: size.height * 0.95
            )
        )

        // two slow shafts of light, leaning with the tide — and
        // trembling in the storm, the way light trembles under
        // a moving cloud
        let tideNow = Self.tide(t)
        for i in 0..<2 {
            let drift = sin(t * 0.05 + Double(i) * 1.9) * 8
                + cos(tideNow.angle) * (2.0 + 5.0 * tideNow.strength) * 6
                + sin(t * 2.6 + Double(i) * 2.2) * 3.0 * storm
            let x = size.width * (0.28 + 0.42 * Double(i)) + drift
            var shaft = context
            shaft.translateBy(x: x, y: -size.height * 0.15)
            shaft.rotate(by: .degrees(16 + tideNow.angle * 12))
            let shaftRect = CGRect(x: -40, y: 0, width: 80, height: size.height * 1.5)
            shaft.fill(
                Path(shaftRect),
                with: .linearGradient(
                    Gradient(colors: [skyColor.opacity(0.05 * (0.12 + 0.88 * light)), .clear]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: shaftRect.height)
                )
            )
        }

        // the answer: while a body of the deep is under the water
        // in the water's night, the surface answers its breath — a
        // faint cold swell, traveling at the water's pace,
        // swelling and easing at the body's breath. The deep one's
        // answer keeps the lower part of the surface; the twin's —
        // a little fainter, a little less blue — keeps a little
        // higher, the way the twin keeps a little higher in the
        // water. And in the full day the light from above is
        // enough, and neither answer is seen
        if deep > 0.01 {
            drawAnswer(
                &context,
                size: size,
                t: t,
                surfaceY: 0.075 * Double(size.height),
                answer: Self.deepAnswer(deep: deep, light: light, t: t),
                maxAnswer: 0.06,
                color: Color(red: 0.50, green: 0.80, blue: 0.95),
                wavelengthFrac: 0.35,
                period: 420
            )
        }
        if deepTwin > 0.01 {
            drawAnswer(
                &context,
                size: size,
                t: t,
                surfaceY: 0.045 * Double(size.height),
                answer: Self.deepTwinAnswer(twin: deepTwin, light: light, t: t),
                maxAnswer: 0.048,
                color: Color(red: 0.62, green: 0.78, blue: 0.92),
                wavelengthFrac: 0.30,
                period: 470
            )
        }

        // the deep one: a large slow body in the water's depths —
        // under everything the water carries: the motes are near
        // the surface, the colony is on the rock, and the deep one
        // is below all of it. The moon's beam, when it comes,
        // falls on its back. And, rarely still, its twin — the
        // smaller body, a little higher in the water, keeping its
        // own pace and its own light and its own breath
        if deep > 0.01 {
            drawDeepBody(
                &context,
                size: size,
                t: t,
                center: deepCenter,
                movingRight: cos(t * 2 * .pi / 1433 + 2.2) >= 0,
                bend: 12.0 * sin(t * 2 * .pi / 613 + 1.4),
                length: Self.deepBodyLength(width: size.width),
                presence: deep,
                light: light,
                glow: Self.deepLight(deep: deep, light: light, t: t),
                glowColor: Color(red: 0.50, green: 0.80, blue: 0.95),
                moon: moon,
                moonBeamX: moonBeamX
            )
        }
        if deepTwin > 0.01 {
            drawDeepBody(
                &context,
                size: size,
                t: t,
                center: deepTwinCenter,
                movingRight: cos(t * 2 * .pi / 1679 + 4.1) >= 0,
                bend: 9.0 * sin(t * 2 * .pi / 521 + 3.3),
                length: Self.deepTwinBodyLength(width: size.width),
                presence: deepTwin,
                light: light,
                glow: Self.deepTwinLight(twin: deepTwin, light: light, t: t),
                glowColor: Color(red: 0.62, green: 0.78, blue: 0.92),
                moon: moon,
                moonBeamX: moonBeamX
            )
        }

        // the moon's beam: the sky's cold light, drifting across the
        // water — a broad one, the way the moon's light on the sea
        // is broad. While it is here, the water is lit by the sky;
        // when it passes, the water does not remember it
        if moon > 0.02 {
            let sigma = Self.moonBeamSigma(width: size.width)
            let beamColor = Color(red: 0.78, green: 0.86, blue: 1.0)
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: beamColor.opacity(0.08 * moon * 0.88), location: 0.25),
                        .init(color: beamColor.opacity(0.08 * moon), location: 0.5),
                        .init(color: beamColor.opacity(0.08 * moon * 0.33), location: 0.75),
                        .init(color: beamColor.opacity(0.08 * moon * 0.14), location: 1),
                    ]),
                    startPoint: CGPoint(x: moonBeamX - 2 * sigma, y: 0),
                    endPoint: CGPoint(x: moonBeamX + 2 * sigma, y: 0)
                )
            )
        }

        // drifting motes: carried by the tide, bent around the hand
        for i in 0..<16 {
            let x0 = Self.fuzz(0x5EED, i) * size.width
            let speed = 5 + 9 * Self.fuzz(0x5EED, 100 + i)
            let cycle = size.height + 40
            let progress = (t * speed + Double(i) * 977.13).truncatingRemainder(dividingBy: cycle)
            var y = size.height + 20 - progress
            var x = x0 + sin(t * 0.3 + Double(i) * 0.9) * 14
            // the tide carries: the longer a mote has been in the water,
            // the farther the current has taken it
            let upFor = progress / speed
            let carry = tideFlow(t - upFor / 2)
            let carryFactor = 0.8 + 0.4 * Self.fuzz(0x5EED, 150 + i)
            // the water slows over a deep body's back, the way a
            // river slows over a submerged stone: the mote's being
            // carried is less, the deeper the water under it — and
            // where the two bodies are together, the water between
            // them slows more still
            var carryDamp = 1.0
            if deep > 0.02 || deepTwin > 0.02 {
                let wx = x + carry.dx * upFor * carryFactor
                let wy = y + carry.dy * upFor * carryFactor * 0.35
                if deep > 0.02 {
                    let dxn = (wx - Double(deepCenter.x)) / (0.30 * Double(size.width))
                    let dyn = (wy - Double(deepCenter.y)) / (0.10 * Double(size.height))
                    let prox = exp(-(dxn * dxn + dyn * dyn) / 2)
                    carryDamp *= 1 - 0.4 * deep * prox
                }
                if deepTwin > 0.02 {
                    let dxn = (wx - Double(deepTwinCenter.x)) / (0.24 * Double(size.width))
                    let dyn = (wy - Double(deepTwinCenter.y)) / (0.08 * Double(size.height))
                    let prox = exp(-(dxn * dxn + dyn * dyn) / 2)
                    carryDamp *= 1 - 0.4 * deepTwin * prox
                }
            }
            x += carry.dx * upFor * carryFactor * carryDamp
            y += carry.dy * upFor * carryFactor * 0.35 * carryDamp
            let span = Double(size.width) + 40
            var xx = x.truncatingRemainder(dividingBy: span)
            if xx < 0 { xx += span }
            if xx < 20 { xx -= span }
            if let fp = fingerPoint, presence > 0.001 {
                // the water parts around the hand
                let parting = handParting(CGPoint(x: xx, y: y), finger: fp, presence: presence, t: t)
                xx += parting.dx
                y += parting.dy
            }
            if deep > 0.02 {
                // the mote is bent out of the way of a deep body,
                // the way it is bent out of the way of the hand —
                // fainter: it is deep, and the water only turns
                // around it a little; the larger body turns the
                // water more, the smaller body less — and the
                // storm's surge bends the water around the back
                // more still, the way a flood bends more around a
                // stone
                let parting = bodyParting(
                    CGPoint(x: xx, y: y),
                    center: deepCenter,
                    strength: Self.deepPartingStrength(deep: deep, storm: storm),
                    sx: 0.30 * Double(size.width),
                    sy: 0.10 * Double(size.height)
                )
                xx += parting.dx
                y += parting.dy
            }
            if deepTwin > 0.02 {
                // the twin's parting: the smaller body turns the
                // water less — and the storm's surge bends the
                // water around its back more still, the way the
                // flood bends more around the smaller stone
                let parting = bodyParting(
                    CGPoint(x: xx, y: y),
                    center: deepTwinCenter,
                    strength: Self.deepTwinPartingStrength(twin: deepTwin, storm: storm),
                    sx: 0.24 * Double(size.width),
                    sy: 0.08 * Double(size.height)
                )
                xx += parting.dx
                y += parting.dy
            }
            let radius = 0.7 + 1.5 * Self.fuzz(0x5EED, 200 + i)
            // the motes are lit by the surface: at night only a few
            // faint ones show — and they take the color of the
            // sky's light, warm at the turning, white at the high
            let alpha = (0.04 + 0.18 * Self.fuzz(0x5EED, 300 + i)) * (0.25 + 0.75 * light)
            context.fill(
                Path(ellipseIn: CGRect(x: xx - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                with: .color(skyColor.opacity(alpha))
            )
        }

        // rain: what the storm brings down through the water — thin
        // bright lines, falling fast, slanted by the wind the
        // surging current makes. Where there is no storm there is no
        // rain, and the water does not remember the rain either
        if storm > 0.02 {
            let rainSeed = 0x5241494E // "RAIN" in hex: the falling ones
            let wind = tideFlow(t)
            for i in 0..<44 {
                let speed = 110 + 160 * Self.fuzz(rainSeed, 100 + i)
                let cycle = size.height + 100
                let progress = (t * speed + Double(i) * 7919.7).truncatingRemainder(dividingBy: cycle)
                let y = -30 + progress
                let fall = progress / speed
                // the wind the current makes carries the fall
                let x0 = Self.fuzz(rainSeed, i) * (size.width + 80) - 40
                let x = x0 + wind.dx * fall * (0.5 + 0.5 * Self.fuzz(rainSeed, 200 + i))
                let span = size.width + 80
                var xx = (x + 40).truncatingRemainder(dividingBy: span) - 40
                let len = 9 + 15 * Self.fuzz(rainSeed, 300 + i)
                let slope = 2 * wind.dx / speed
                // rain is seen where there is light to see it by:
                // bright in the storm-darkened day, faint in the
                // storm-darkened night, where the colony's own light
                // is all there is
                let alpha = (0.10 + 0.16 * Self.fuzz(rainSeed, 400 + i)) * storm * (0.35 + 0.65 * light)
                var streak = Path()
                streak.move(to: CGPoint(x: xx, y: y))
                streak.addLine(to: CGPoint(x: xx + slope * len, y: y + len))
                context.stroke(streak, with: .color(.white.opacity(alpha)), lineWidth: 1)
            }
        }
    }

    /// A body of the deep, drawn: the water's own soft dark, laid
    /// along its spine — a body long enough that its passing is a
    /// crossing of the water. In the day it is a shadow moving
    /// through the light; in the night it is a dark against the
    /// colony's own small light — and in the water's night each
    /// body of the deep carries a light of its own: a small cold
    /// one, from within, the water around the body lit and the body
    /// itself still dark, the way a body is where its own light is.
    /// The deep one's is the colder of the two, the twin's the
    /// fainter; where the moon's beam lies on a back, the sky's
    /// light stops on the passing shadow. When it passes, the water
    /// does not remember it.
    private func drawDeepBody(
        _ context: inout GraphicsContext,
        size: CGSize,
        t: Double,
        center: CGPoint,
        movingRight: Bool,
        bend: Double,
        length: Double,
        presence: Double,
        light: Double,
        glow: Double,
        glowColor: Color,
        moon: Double,
        moonBeamX: Double
    ) {
        // the body is made of the water's own soft dark — the piece
        // has light made of the piece's light, and dark made of the
        // piece's dark
        let bodyColor = Color(red: 0.004, green: 0.02, blue: 0.045)
        // the shadow shows where there is light to be a shadow in:
        // plain in the day, a dark against the colony's own light
        // in the night
        let alpha = presence * (0.05 + 0.16 * light)
        // the body's own small light: made by the body, in the
        // night, breathing at the body's breath; in the full day
        // the light from above is enough, and the deep's light is
        // not seen
        // a soft dark body: ten along the spine, thinning toward
        // the head and the tail the way a body thins — and the
        // spine bends slowly, the way something of its size bends
        let count = 10
        for i in 0..<count {
            // along the body, 0 = the tail, 1 = the head; the head
            // leads the way the crossing goes — and the body thins
            // to nothing at both ends, the way a body does
            let u = Double(i) / Double(count - 1)
            let s = movingRight ? (u - 0.5) * 2 : (0.5 - u) * 2
            let taper = pow(sin(.pi * u), 0.7)
            let halfW = length * 0.13 * taper
            guard halfW > 1 else { continue }
            let halfH = halfW * 0.62
            let x = center.x + s * length * 0.5
            let y = center.y + bend * s
            // the body's own light, laid in the water around the
            // body before the body's dark: the light is from
            // within, so the water around the body is lit, and the
            // body itself stays dark, the way a body is where its
            // own light is
            if glow > 0.004 {
                context.fill(
                    Path(ellipseIn: CGRect(x: x - halfW * 3.0, y: y - halfH * 3.0, width: halfW * 6.0, height: halfH * 6.0)),
                    with: .radialGradient(
                        Gradient(colors: [
                            glowColor.opacity(glow * taper),
                            .clear,
                        ]),
                        center: CGPoint(x: x, y: y),
                        startRadius: 0,
                        endRadius: halfW * 3.0
                    )
                )
            }
            context.fill(
                Path(ellipseIn: CGRect(x: x - halfW, y: y - halfH, width: halfW * 2, height: halfH * 2)),
                with: .radialGradient(
                    Gradient(colors: [
                        bodyColor.opacity(alpha),
                        bodyColor.opacity(alpha * 0.35),
                        .clear,
                    ]),
                    center: CGPoint(x: x, y: y),
                    startRadius: 0,
                    endRadius: max(halfW, halfH)
                )
            )
        }
        // the water's light skims the back: a faint sheen along the
        // body's upper edge, the way light skims the back of
        // something that swims
        let sheenY = center.y - length * 0.05
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - length * 0.38, y: sheenY - 2.5, width: length * 0.76, height: 5)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.75, green: 0.85, blue: 0.95).opacity(0.05 * presence * (0.2 + 0.8 * light)),
                    .clear,
                ]),
                center: CGPoint(x: center.x, y: sheenY),
                startRadius: 0,
                endRadius: length * 0.38
            )
        )
        // the moon's light finds a deep body's back: where the beam
        // crosses the body, the sky's light stops on the passing
        // shadow — a cold edge on its back, at the place of the
        // beam, and when the moon passes, it does not remember
        // finding it
        if moon > 0.02 {
            let fall = Self.moonBeamFall(
                x: Double(center.x),
                beamX: moonBeamX,
                sigma: Self.moonBeamSigma(width: size.width)
            )
            if fall > 0.05 {
                // the light stops where the beam is, clamped to the
                // body: the back under the beam, and only there
                let litX = min(max(moonBeamX, center.x - length * 0.42), center.x + length * 0.42)
                context.fill(
                    Path(ellipseIn: CGRect(x: litX - length * 0.26, y: sheenY - 4, width: length * 0.52, height: 8)),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 0.78, green: 0.86, blue: 1.0).opacity(0.16 * moon * fall),
                            .clear,
                        ]),
                        center: CGPoint(x: litX, y: sheenY),
                        startRadius: 0,
                        endRadius: length * 0.26
                    )
                )
            }
        }
    }

    /// The answer, drawn: a faint cold swell at the water's
    /// surface, while a body of the deep is under the water in the
    /// water's night — the band of light where the body's breath
    /// arrives, and the small slow ripples it makes, the way a
    /// swell moves. The ripples travel at the water's pace, and
    /// they swell and ease at the body's breath: the water carries
    /// the answer, and the body breathes it. In the full day the
    /// light from above is enough, and the answer is not seen, the
    /// way the deep's light is not seen in the sun.
    private func drawAnswer(
        _ context: inout GraphicsContext,
        size: CGSize,
        t: Double,
        surfaceY: Double,
        answer: Double,
        maxAnswer: Double,
        color: Color,
        wavelengthFrac: Double,
        period: Double
    ) {
        guard answer > 0.004 else { return }
        let w = Double(size.width)
        // the answer swells and eases at the body's breath; it
        // travels at the water's pace — the water carries it, and
        // the body breathes it
        let strength = min(1, answer / maxAnswer)
        let amp = 5.5 * strength
        // the band: the breath's arrival at the surface — a faint
        // cold light laid across the whole of it, the way the
        // breath is of the whole water, not of a place in it
        context.fill(
            Path(CGRect(x: 0, y: surfaceY - 13, width: size.width, height: 26)),
            with: .linearGradient(
                Gradient(colors: [
                    .clear,
                    color.opacity(0.8 * answer),
                    .clear,
                ]),
                startPoint: CGPoint(x: 0, y: surfaceY - 13),
                endPoint: CGPoint(x: 0, y: surfaceY + 13)
            )
        )
        // the ripples: three of them, each at its own phase, the
        // way no two crests of a swell are in phase — and each
        // traveling at the water's pace, slowly, the way a swell
        // travels
        for i in 0..<3 {
            let offset = (Double(i) - 1) * 3.5
            let phase0 = Double(i) * 1.13
            var ripple = Path()
            var first = true
            var x = -8.0
            while x <= w + 8 {
                let y = surfaceY + offset + amp * sin(2 * .pi * (x / (w * wavelengthFrac) - t / period) + phase0)
                let p = CGPoint(x: x, y: y)
                if first {
                    ripple.move(to: p)
                    first = false
                } else {
                    ripple.addLine(to: p)
                }
                x += 6
            }
            let alpha = (i == 1 ? 0.85 : 0.45) * 1.6 * answer
            context.stroke(ripple, with: .color(color.opacity(alpha)), lineWidth: 1.2)
        }
    }

    private func drawBarnacle(_ context: inout GraphicsContext, _ barnacle: Barnacle, size: CGSize, now: Date, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double, storm: Double, moon: Double, moonBeamX: Double, deep: Double, deepCenter: CGPoint, deepTwin: Double, deepTwinCenter: CGPoint) {
        let seed = barnacle.seed

        // settling: born at its timestamp, eases in with a small overshoot
        let age = now.timeIntervalSince(barnacle.timestamp)
        let settleProgress = min(1, age / 0.9)
        let settleScale = settleProgress >= 1 ? 1 : easeOutBack(settleProgress)

        // accretion: it settled small, and has been growing ever since
        let grown = grownRadius(seed: seed, size: barnacle.size, age: age)

        // settling into the rock: with age the breathing slows, and the
        // creature answers the current less eagerly — the old have seen
        // the tide, and turn to it only when it comes close
        let ageSettle = Self.smoothstep(120, 1800, age)

        // breathing and drifting — the anchored body leans into the
        // current, the way a holdfast leans into the sea
        let tideNow = Self.tide(t)
        let breathePhase = 2 * .pi * Self.fuzz(seed, 50)
        let driftPhase = 2 * .pi * Self.fuzz(seed, 51)
        let lean = 4.5 * tideNow.strength * (0.7 + 0.6 * Self.fuzz(seed, 56))
        var swayX = sin(t * 0.35 + driftPhase) * 3 + cos(tideNow.angle) * lean
        var swayY = cos(t * 0.27 + driftPhase * 1.31) * 3 + sin(tideNow.angle) * lean
        // the surge: in the storm the anchored bodies shudder with
        // the water, each at its own rate
        let shudder = 2.4 * storm
        if shudder > 0.01 {
            swayX += sin(t * (1.7 + 0.9 * Self.fuzz(seed, 58)) + driftPhase) * shudder
            swayY += cos(t * (1.9 + 0.7 * Self.fuzz(seed, 59)) + driftPhase * 1.31) * shudder * 0.6
        }

        // does the colony feel the current the hand has made? (0...1, eased by distance)
        var attention = 0.0
        var angleToFinger = 0.0
        // the stirring of the colony's self-light, where the hand's
        // movement has reached this creature
        var flashLocal = 0.0
        if let fp = fingerPoint, presence > 0.001 {
            let dx = Double(fp.x) - Double(barnacle.x) * Double(size.width)
            let dy = Double(fp.y) - Double(barnacle.y) * Double(size.height)
            let d = hypot(dx, dy)
            if d > 0.001 {
                attention = presence * (1 - Self.smoothstep(44, 180, d))
                angleToFinger = atan2(dy, dx)
                flashLocal = handFlash * (1 - Self.smoothstep(44, 200, d))
            }
        }

        // the deep one, where it is passing under the water: the
        // colony slows its breath under the passing shadow, the
        // way sleepers slow under a shadow — not the storm's tuck:
        // the deep one is not weather, and the colony does not
        // tuck to it. The twin passes the same way, a little
        // higher in the water, and the colony slows under it the
        // same way — and where the two are together, the colony
        // slows under whichever of them is under it. Where the
        // deep is not, this is nothing, the way all of the
        // water's answers are nothing
        let deepLocal = max(
            deep * exp(
                -pow((Double(barnacle.x) * Double(size.width) - Double(deepCenter.x)) / (0.40 * Double(size.width)), 2)
            ),
            deepTwin * exp(
                -pow((Double(barnacle.x) * Double(size.width) - Double(deepTwinCenter.x)) / (0.30 * Double(size.width)), 2)
            )
        )

        // a barnacle that feels the current breathes a little deeper —
        // but a barnacle that has settled into the rock breathes
        // slower, and in the water's night the whole colony breathes
        // shallow, the way sleepers breathe, and in the storm the
        // whole colony holds its breath, and under the deep one the
        // whole colony slows its breath, the way sleepers slow under
        // a passing shadow
        let rest = 1 - light
        let breath = 1
            + (0.02 + 0.03 * attention) * (1 - 0.5 * ageSettle) * (1 - 0.4 * rest) * (1 - 0.5 * storm) * (1 - 0.35 * deepLocal)
            * sin(t * (0.7 * (1 - 0.35 * ageSettle)) + breathePhase)

        let center = CGPoint(
            x: barnacle.x * size.width + swayX,
            y: barnacle.y * size.height + swayY
        )
        let radius = grown * settleScale * breath
        guard radius > 0.5 else { return }

        // the moon: while the crossing is over this water, the
        // creature is lit by the sky's cold light — the sky's
        // light over its own — the way a creature on the shore is
        // lit by the moon over the sea
        let moonLocal = moon * Self.moonBeamFall(
            x: Double(center.x),
            beamX: moonBeamX,
            sigma: Self.moonBeamSigma(width: size.width)
        )

        // the deep one's own light, where the deep one is passing
        // under the water in the water's night: the colony above it
        // is lit from below by the deep's small light — the light
        // from within the deep, not from the sky, the way sleepers
        // are lit by a lamp under them — and when the passing ends,
        // the light goes with it, and the colony goes back to its
        // own. The twin keeps a little higher in the water, and its
        // small light — the fainter, less blue of the two — comes
        // up to the colony a little further, the way a lamp held
        // higher reaches further
        let deepGlowLocal = Self.deepLight(deep: deep, light: light, t: t) * exp(
            -(pow((Double(center.x) - Double(deepCenter.x)) / (0.30 * Double(size.width)), 2)
                + pow((Double(center.y) - Double(deepCenter.y)) / (0.15 * Double(size.height)), 2)) / 2
        )
        + Self.deepTwinLight(twin: deepTwin, light: light, t: t) * exp(
            -(pow((Double(center.x) - Double(deepTwinCenter.x)) / (0.30 * Double(size.width)), 2)
                + pow((Double(center.y) - Double(deepTwinCenter.y)) / (0.20 * Double(size.height)), 2)) / 2
        )

        let shell = shellColor(seed: seed)
        let plate = plateColor(seed: seed)
        // with age the colour drains toward the rock it is becoming
        let agedShell = ageSettle > 0.001
            ? shell.mix(with: Color(red: 0.30, green: 0.27, blue: 0.23), by: 0.30 * ageSettle)
            : shell

        // fuzzy halo, swelling softly as the barnacle wakes — and hugging
        // closer to the body as it settles into the rock
        let haloR = radius * (1.9 + 0.6 * attention) * (1 - 0.15 * ageSettle)
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - haloR,
                y: center.y - haloR,
                width: haloR * 2,
                height: haloR * 2
            )),
            with: .radialGradient(
                Gradient(colors: [agedShell.opacity(0.28 + 0.10 * attention), .clear]),
                center: center,
                startRadius: radius * 0.2,
                endRadius: haloR
            )
        )

        // the deep's own light, under the colony's own: where the
        // deep one is passing below in the night, the sleepers are
        // lit from below by the deep's small light — laid down
        // first, the way the light that is lowest lies down first
        if deepGlowLocal > 0.004 {
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - haloR,
                    y: center.y - haloR,
                    width: haloR * 2,
                    height: haloR * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 0.50, green: 0.80, blue: 0.95).opacity(deepGlowLocal),
                        .clear,
                    ]),
                    center: center,
                    startRadius: radius * 0.1,
                    endRadius: haloR
                )
            )
        }

        // the self-light: in the water's night the colony is lit by
        // its own faint glow, and a moving hand stirs that glow
        // brighter, and the glow lingers a moment after the hand is
        // gone
        let selfLight = 0.045 * rest + 0.12 * flashLocal
        if selfLight > 0.004 {
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - haloR,
                    y: center.y - haloR,
                    width: haloR * 2,
                    height: haloR * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 0.55, green: 0.95, blue: 0.88).opacity(selfLight),
                        .clear,
                    ]),
                    center: center,
                    startRadius: radius * 0.1,
                    endRadius: haloR
                )
            )
        }

        // the moon's light: while the crossing is over this water
        // the creature is lit by the sky, over its own light — and
        // when the crossing passes, the sky does not remember the
        // creature, the way the water does not remember the sky
        if moonLocal > 0.02 {
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - haloR,
                    y: center.y - haloR,
                    width: haloR * 2,
                    height: haloR * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 0.78, green: 0.86, blue: 1.0).opacity(0.10 * moonLocal),
                        .clear,
                    ]),
                    center: center,
                    startRadius: radius * 0.1,
                    endRadius: haloR
                )
            )
        }

        // body: a centre lobe and a ring of lobes, wobbling gently
        var body = Path()
        body.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        let lobeCount = 5 + Int(Self.fuzz(seed, 4) * 4)
        for i in 0..<lobeCount {
            let angle = 2 * .pi * Self.fuzz(seed, 10 + i) + 0.18 * sin(t * 0.5 + breathePhase + Double(i))
            let distance = radius * (0.45 + 0.45 * Self.fuzz(seed, 20 + i))
            let lobeRadius = radius * (0.30 + 0.35 * Self.fuzz(seed, 30 + i))
                * (1 + 0.05 * sin(t * 0.9 + breathePhase + Double(i) * 1.13))
            let lobeCenter = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            body.addEllipse(in: CGRect(
                x: lobeCenter.x - lobeRadius,
                y: lobeCenter.y - lobeRadius,
                width: lobeRadius * 2,
                height: lobeRadius * 2
            ))
        }
        context.fill(body, with: .color(agedShell))
        if attention > 0.01 {
            context.fill(body, with: .color(.white.opacity(0.05 * attention)))
        }

        // shell plates
        let plateCount = 4 + Int(Self.fuzz(seed, 60) * 3)
        for i in 0..<plateCount {
            let angle = 2 * .pi * Self.fuzz(seed, 70 + i) + 0.35 * sin(t * 0.21 + Double(i) * 1.7)
            let distance = radius * (0.28 + 0.30 * Self.fuzz(seed, 80 + i))
            let plateCenter = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            let long = radius * (0.20 + 0.14 * Self.fuzz(seed, 90 + i))
            let short = long * 0.62
            var plateContext = context
            plateContext.translateBy(x: plateCenter.x, y: plateCenter.y)
            plateContext.rotate(by: .radians(angle + .pi / 2))
            plateContext.fill(
                Path(ellipseIn: CGRect(x: -long / 2, y: -short / 2, width: long, height: short)),
                with: .color(plate.opacity(0.30))
            )
        }

        // the orifice at the centre — it dilates toward the current;
        // the old, whose patience has run deep, open less
        let orif = radius * (0.10 + 0.22 * attention * (1 - 0.4 * ageSettle))
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - orif,
                y: center.y - orif,
                width: orif * 2,
                height: orif * 2
            )),
            with: .color(plate.opacity(0.5 + 0.25 * attention))
        )
        if attention > 0.01 {
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - orif * 2,
                    y: center.y - orif * 2,
                    width: orif * 4,
                    height: orif * 4
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 0.72, green: 0.92, blue: 0.90).opacity(0.30 * attention),
                        .clear,
                    ]),
                    center: center,
                    startRadius: 0,
                    endRadius: orif * 2
                )
            )
        }

        // cirri: the feathery feeding plumes, always reaching into the
        // current — the colony feeding on the open water — and turning
        // toward a hand, which makes a richer local current. The young
        // taste everything; the old reach shorter, and fainter.
        let cirriThreshold = 0.04 + 0.10 * ageSettle
        let plumeBase = tideNow.angle + (Self.fuzz(seed, 55) * 0.5 - 0.25)
        // the plumes fold in under the storm, the way a colony
        // tucks in to weather
        var plumeReach = radius * (0.55 + 0.55 * tideNow.strength)
            * (0.7 + 0.5 * Self.fuzz(seed, 44)) * (1 - 0.35 * ageSettle) * (0.8 + 0.2 * light)
            * (1 - 0.45 * storm)
            // the moonlit colony reaches: lit by the sky for a
            // while, the plumes reach into the passing light, the
            // way the colony reaches into anything that feeds it
            * (1 + 0.35 * moonLocal)
            // and the colony under the deep one folds its plumes a
            // little, the way they fold under anything that moves
            // the water — not the tuck: the deep one is not weather
            * (1 - 0.25 * deepLocal)
        var plumeAngle = plumeBase
        var plumeVis = 0.14 + 0.10 * tideNow.strength
        if attention > cirriThreshold {
            let beyond = (attention - cirriThreshold) / max(0.25, 1 - cirriThreshold)
            plumeAngle = Self.blendAngle(plumeBase, angleToFinger, min(1.0, 1.5 * attention))
            plumeReach = max(plumeReach, radius * (0.55 + 0.65 * beyond))
            plumeVis = max(plumeVis, 0.32 * beyond + 0.10)
        }
        // in the water's night the plumes are seen by the colony's
        // own light, not by the light from above — shorter, and
        // fainter, the way sleepers reach
        plumeVis = plumeVis * (0.55 + 0.45 * light) + 0.05 * (1 - light)
        let cirriCount = 6
        for i in 0..<cirriCount {
            let spread = (Double(i) - Double(cirriCount - 1) / 2) * 0.55
            let sway = 0.28 * sin(t * 1.1 + breathePhase + Double(i) * 1.31)
            let a = plumeAngle + spread + sway
            let start = CGPoint(
                x: center.x + cos(a) * radius * 0.12,
                y: center.y + sin(a) * radius * 0.12
            )
            let end = CGPoint(
                x: center.x + cos(a) * plumeReach,
                y: center.y + sin(a) * plumeReach
            )
            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let ctrl = CGPoint(
                x: midX - sin(a) * radius * 0.18,
                y: midY + cos(a) * radius * 0.18
            )
            var filament = Path()
            filament.move(to: start)
            filament.addQuadCurve(to: end, control: ctrl)
            context.stroke(
                filament,
                with: .color(Color(red: 0.85, green: 0.93, blue: 0.92).opacity(plumeVis)),
                lineWidth: 1.2
            )
        }

        // a sliver of surface light on the upper-left
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 0.75,
                y: center.y - radius * 0.85,
                width: radius * 0.55,
                height: radius * 0.4
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.22), .clear]),
                center: CGPoint(x: center.x - radius * 0.47, y: center.y - radius * 0.65),
                startRadius: 0,
                endRadius: radius * 0.45
            )
        )
    }

    /// The trace of a barnacle that let go: a mineral rim where its
    /// shell had been, and the pale surface exposed beneath. It holds
    /// for a while, then the water slowly forgets it. Unlike the living,
    /// a trace does not drift — it stays where the creature was.
    private func drawGhost(_ context: inout GraphicsContext, _ ghost: Ghost, size: CGSize, now: Date, light: Double, storm: Double, fingerPoint: CGPoint?, presence: Double, moon: Double, moonBeamX: Double) {
        let age = now.timeIntervalSince(ghost.departedAt)
        guard age < 150 else { return }
        // the trace keeps, then dissolves — and in the water's night
        // the trace goes dark too, lit only where the hand's light
        // reaches it, the way a rock is lit by a lamp laid against
        // it. The storm scours the water, and in it the water
        // forgets faster
        let fade = 1 - Self.smoothstep(40, 150 * (1 - 0.5 * storm), age)
        guard fade > 0.001 else { return }

        let center = CGPoint(x: ghost.x * size.width, y: ghost.y * size.height)
        let r = ghost.size
        var vis = fade * (0.30 + 0.70 * light)
        if let fp = fingerPoint, presence > 0.001 {
            let d = hypot(Double(fp.x) - center.x, Double(fp.y) - center.y)
            vis += presence * (1 - light) * (1 - Self.smoothstep(40, 170, d)) * 0.35
        }
        // the moon lays its light on the trace, the way the hand's
        // lamp does — the sky sees the water's keeping, and when the
        // moon passes, it does not remember seeing it
        if moon > 0.02 {
            vis += 0.30 * moon * Self.moonBeamFall(
                x: Double(center.x),
                beamX: moonBeamX,
                sigma: Self.moonBeamSigma(width: size.width)
            )
        }

        // the exposed surface: pale where the body had been
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.84, green: 0.82, blue: 0.74).opacity(0.11 * vis),
                    .clear,
                ]),
                center: center,
                startRadius: 0,
                endRadius: r
            )
        )

        // the rim: the edge of where it had been
        var ring = Path()
        ring.addEllipse(in: CGRect(
            x: center.x - r * 1.12,
            y: center.y - r * 1.12,
            width: r * 2.24,
            height: r * 2.24
        ))
        context.stroke(
            ring,
            with: .color(Color(red: 0.88, green: 0.85, blue: 0.76).opacity(0.16 * vis)),
            lineWidth: 1.5
        )
    }

    private func drawRipple(_ context: inout GraphicsContext, _ ripple: Ripple, size: CGSize, now: Date) {
        let lifetime: Double = ripple.kind == .settle ? 1.1 : 0.8
        let progress = now.timeIntervalSince(ripple.start) / lifetime
        guard progress < 1 else { return }

        let center = CGPoint(x: ripple.unitPoint.x * size.width, y: ripple.unitPoint.y * size.height)
        let ease = 1 - pow(1 - progress, 3)
        let radius: CGFloat = ripple.kind == .settle ? 12 + 84 * ease : 8 + 40 * ease
        let opacity = (ripple.kind == .settle ? 0.30 : 0.22) * (1 - progress)

        var ring = Path()
        ring.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        context.stroke(ring, with: .color(.white.opacity(opacity)), lineWidth: 2 * (1 - progress) + 0.5)
    }

    private func drawVignette(_ context: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear, location: 0.55),
                    .init(color: Color.black.opacity(0.32), location: 1.0),
                ]),
                center: CGPoint(x: size.width / 2, y: size.height * 0.45),
                startRadius: 0,
                endRadius: hypot(size.width, size.height) * 0.62
            )
        )
    }

    private func easeOutBack(_ p: Double) -> Double {
        let c1 = 1.70158
        let c2 = c1 * 1.525
        return 1 + c2 * pow(p - 1, 3) + c1 * pow(p - 1, 2)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Barnacle.self, Ghost.self], inMemory: true)
}
