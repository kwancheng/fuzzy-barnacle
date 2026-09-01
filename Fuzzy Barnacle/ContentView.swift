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
/// the hand's light reaches them.
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
        .task {
            // the water forgets: traces are kept for a while, then gone
            while !Task.isCancelled {
                pruneGhosts()
                try? await Task.sleep(for: .seconds(20))
            }
        }
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
                Canvas { context, size in
                    let t = now.timeIntervalSinceReferenceDate
                    let presence = fingerPresence(now: now)
                    let light = Self.daylight(t)
                    let handFlash = presence > 0.001 && handSpeed > 1
                        ? Self.handFlashEnvelope(speed: handSpeed, age: now.timeIntervalSince(handSpeedAt), light: light)
                        : 0
                    drawWater(&context, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light)
                    drawHandGlow(&context, fingerPoint: fingerPoint, presence: presence, light: light)
                    drawPassing(&context, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash)
                    for ghost in ghosts {
                        drawGhost(&context, ghost, size: size, now: now, light: light, fingerPoint: fingerPoint, presence: presence)
                    }
                    for barnacle in barnacles {
                        drawBarnacle(&context, barnacle, size: size, now: now, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash)
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
            size: grownRadius(seed: nearest.seed, size: nearest.size, age: Date.now.timeIntervalSince(nearest.timestamp))
        )
        modelContext.insert(trace)
        modelContext.delete(nearest)
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
        // the water keeps time, and the water has a day: the
        // caption keeps the water's hour as well
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let now = timeline.date
            VStack(spacing: 4) {
                Text(captionText)
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(.white.opacity(0.40))
                if let ageLine = ageLine(for: now) {
                    Text(ageLine)
                        .font(.system(.caption2, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.25))
                }
                if let waterLine = waterLine(for: now) {
                    Text(waterLine)
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

    /// The water's own hour: whether it is in its day or its night.
    /// In the turning between the two, the light is neither, and
    /// the caption says nothing.
    private func waterLine(for now: Date) -> String? {
        let light = Self.daylight(now.timeIntervalSinceReferenceDate)
        if light < 0.25 {
            return "the water is in its night"
        }
        if light > 0.75 {
            return "the water is in its day"
        }
        return nil
    }

    // MARK: - The Current

    /// The water is one body. A tide runs through it — slowly turning,
    /// swelling and easing — and everything free in it moves with it:
    /// the motes are carried, the light leans, the plumes of the
    /// anchored creatures reach into it. Nothing in the water moves
    /// alone.
    private func tide(_ t: Double) -> (angle: Double, strength: Double) {
        // the tide turns on a long breath, and swells and eases
        let angle = 0.62 + 0.9 * sin(t * 2 * .pi / 420 + 1.3) + 0.45 * sin(t * 2 * .pi / 97 + 0.4)
        let strength = 0.30 + 0.70 * (0.5 + 0.5 * sin(t * 2 * .pi / 260 + 2.2))
        return (angle, strength)
    }

    /// The surface drift the tide makes, in points per second.
    private func tideFlow(_ t: Double) -> (dx: Double, dy: Double) {
        let tide = tide(t)
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
    /// does not remember the hand.

    /// Five, no more: this water is not a school.
    private static let drifterCount = 5

    /// How far behind its own clock a quick one rides the current: it
    /// turns late, the way a small body turns late in moving water.
    private static let drifterRideLag: Double = 90

    private func drawPassing(_ context: inout GraphicsContext, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double) {
        for i in 0..<Self.drifterCount {
            drawDrifter(&context, index: i, size: size, t: t, fingerPoint: fingerPoint, presence: presence, light: light, handFlash: handFlash)
        }
    }

    private func drawDrifter(_ context: inout GraphicsContext, index: Int, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double) {
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
        let heading = Self.blendAngle(tide(t).angle, motionAngle, Self.smoothstep(0.15, 0.9, speed))

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
        // gone, and a moving hand stirs that shine.
        var glow = (0.08 + 0.07 * taste) * (0.35 + 0.65 * depth) * (1 + 0.7 * (1 - light))
        if handFlash > 0.001, let fp = fingerPoint {
            let d = hypot(Double(fp.x) - position.x, Double(fp.y) - position.y)
            glow += 0.10 * handFlash * (1 - Self.smoothstep(60, 200, d))
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

        // the filaments: streaming behind, opening as it pauses
        let filamentCount = 3 + Int(Self.fuzz(seed, 141 + index) * 3)
        for i in 0..<filamentCount {
            let fan = (Double(i) - Double(filamentCount - 1) / 2) * (0.20 + 0.30 * taste)
            let sway = 0.12 * sin(t * 1.3 + 2 * .pi * Self.fuzz(seed, 142 + i) + Double(i) * 1.7)
            let a = .pi + fan + sway
            let length = (5 + 7 * Self.fuzz(seed, 150 + i)) * scale * (0.8 + 0.4 * taste)
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

    /// The stirring the hand makes of the colony's self-light: in
    /// the water's night a moving hand is light, and the light
    /// lingers a moment after the hand has stopped or lifted. In
    /// full daylight the colony is lit by the surface and the
    /// stirring is not seen.
    static func handFlashEnvelope(speed: Double, age: Double, light: Double) -> Double {
        return min(1.2, speed / 400) * exp(-max(0, age) * 0.9) * (1 - light)
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
    private func drawHandGlow(_ context: inout GraphicsContext, fingerPoint: CGPoint?, presence: Double, light: Double) {
        guard let fp = fingerPoint, presence > 0.001 else { return }
        let radius: CGFloat = 160
        let glow = 0.15 + 0.09 * (1 - light)
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

    private func drawWater(_ context: inout GraphicsContext, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double) {
        let rect = CGRect(origin: .zero, size: size)

        // the depth: darker in the water's night, the way the sea
        // is darker at night — and not black
        let depthLight = 0.35 + 0.65 * light
        let deepLight = 0.30 + 0.70 * light
        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.055 * depthLight, green: 0.20 * depthLight, blue: 0.245 * depthLight),
                    Color(red: 0.012 * deepLight, green: 0.055 * deepLight, blue: 0.11 * deepLight),
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        // soft light from the surface: gone with the day
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.10 * (0.15 + 0.85 * light)), .clear]),
                center: CGPoint(x: size.width * 0.5, y: -size.height * 0.25),
                startRadius: 0,
                endRadius: size.height * 0.95
            )
        )

        // two slow shafts of light, leaning with the tide
        let tideNow = tide(t)
        for i in 0..<2 {
            let drift = sin(t * 0.05 + Double(i) * 1.9) * 8
                + cos(tideNow.angle) * (2.0 + 5.0 * tideNow.strength) * 6
            let x = size.width * (0.28 + 0.42 * Double(i)) + drift
            var shaft = context
            shaft.translateBy(x: x, y: -size.height * 0.15)
            shaft.rotate(by: .degrees(16 + tideNow.angle * 12))
            let shaftRect = CGRect(x: -40, y: 0, width: 80, height: size.height * 1.5)
            shaft.fill(
                Path(shaftRect),
                with: .linearGradient(
                    Gradient(colors: [Color.white.opacity(0.05 * (0.12 + 0.88 * light)), .clear]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: shaftRect.height)
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
            x += carry.dx * upFor * carryFactor
            y += carry.dy * upFor * carryFactor * 0.35
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
            let radius = 0.7 + 1.5 * Self.fuzz(0x5EED, 200 + i)
            // the motes are lit by the surface: at night only a few
            // faint ones show
            let alpha = (0.04 + 0.18 * Self.fuzz(0x5EED, 300 + i)) * (0.25 + 0.75 * light)
            context.fill(
                Path(ellipseIn: CGRect(x: xx - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                with: .color(.white.opacity(alpha))
            )
        }
    }

    private func drawBarnacle(_ context: inout GraphicsContext, _ barnacle: Barnacle, size: CGSize, now: Date, t: Double, fingerPoint: CGPoint?, presence: Double, light: Double, handFlash: Double) {
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
        let tideNow = tide(t)
        let breathePhase = 2 * .pi * Self.fuzz(seed, 50)
        let driftPhase = 2 * .pi * Self.fuzz(seed, 51)
        let lean = 4.5 * tideNow.strength * (0.7 + 0.6 * Self.fuzz(seed, 56))
        let swayX = sin(t * 0.35 + driftPhase) * 3 + cos(tideNow.angle) * lean
        let swayY = cos(t * 0.27 + driftPhase * 1.31) * 3 + sin(tideNow.angle) * lean

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

        // a barnacle that feels the current breathes a little deeper —
        // but a barnacle that has settled into the rock breathes
        // slower, and in the water's night the whole colony breathes
        // shallow, the way sleepers breathe
        let rest = 1 - light
        let breath = 1
            + (0.02 + 0.03 * attention) * (1 - 0.5 * ageSettle) * (1 - 0.4 * rest)
            * sin(t * (0.7 * (1 - 0.35 * ageSettle)) + breathePhase)

        let center = CGPoint(
            x: barnacle.x * size.width + swayX,
            y: barnacle.y * size.height + swayY
        )
        let radius = grown * settleScale * breath
        guard radius > 0.5 else { return }

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
        var plumeReach = radius * (0.55 + 0.55 * tideNow.strength)
            * (0.7 + 0.5 * Self.fuzz(seed, 44)) * (1 - 0.35 * ageSettle) * (0.8 + 0.2 * light)
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
    private func drawGhost(_ context: inout GraphicsContext, _ ghost: Ghost, size: CGSize, now: Date, light: Double, fingerPoint: CGPoint?, presence: Double) {
        let age = now.timeIntervalSince(ghost.departedAt)
        guard age < 150 else { return }
        // the trace keeps, then dissolves — and in the water's night
        // the trace goes dark too, lit only where the hand's light
        // reaches it, the way a rock is lit by a lamp laid against
        // it
        let fade = 1 - Self.smoothstep(40, 150, age)
        guard fade > 0.001 else { return }

        let center = CGPoint(x: ghost.x * size.width, y: ghost.y * size.height)
        let r = ghost.size
        var vis = fade * (0.30 + 0.70 * light)
        if let fp = fingerPoint, presence > 0.001 {
            let d = hypot(Double(fp.x) - center.x, Double(fp.y) - center.y)
            vis += presence * (1 - light) * (1 - Self.smoothstep(40, 170, d)) * 0.35
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
