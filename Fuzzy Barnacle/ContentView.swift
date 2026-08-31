//
//  ContentView.swift
//  Fuzzy Barnacle
//
//  Created by kc on 8/31/26.
//

import SwiftUI
import SwiftData

/// Open water. Press anywhere and a barnacle settles there; hold and
/// one lets go. The colony is the record — every press is a moment
/// that decided to stay. And the water keeps time: the creatures grow,
/// they slow with age, and where one has let go, a trace remains
/// a while before the water forgets it.
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
                    drawWater(&context, size: size, t: t, fingerPoint: fingerPoint, presence: presence)
                    drawHandGlow(&context, fingerPoint: fingerPoint, presence: presence)
                    for ghost in ghosts {
                        drawGhost(&context, ghost, size: size, now: now)
                    }
                    for barnacle in barnacles {
                        drawBarnacle(&context, barnacle, size: size, now: now, t: t, fingerPoint: fingerPoint, presence: presence)
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
                if pressStart == nil {
                    pressStart = .now
                }
                if !fingerDown {
                    fingerDown = true
                    fingerDownSince = .now
                    fingerUpSince = nil
                }
                fingerPoint = value.location
            }
            .onEnded { value in
                defer { pressStart = nil }
                let start = pressStart ?? .now
                let held = Date.now.timeIntervalSince(start)
                let travel = hypot(value.translation.width, value.translation.height)
                fingerDown = false
                fingerUpSince = .now
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
        VStack(spacing: 4) {
            Text(captionText)
                .font(.system(.footnote, design: .serif).italic())
                .foregroundStyle(.white.opacity(0.40))
            if let ageLine {
                Text(ageLine)
                    .font(.system(.caption2, design: .serif).italic())
                    .foregroundStyle(.white.opacity(0.25))
            }
            Text("hold a barnacle to let it go — the water will remember")
                .font(.system(.caption2, design: .serif).italic())
                .foregroundStyle(.white.opacity(0.20))
        }
        .padding(.bottom, 26)
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
    private var ageLine: String? {
        guard let oldest = barnacles.map(\.timestamp).min() else { return nil }
        let age = Date.now.timeIntervalSince(oldest)
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

    // MARK: - Drawing

    /// Deterministic unit random from (seed, channel): the fuzz behind
    /// every barnacle's shape, colour, and rhythm.
    @inline(__always)
    private func fuzz(_ seed: Int, _ channel: Int) -> Double {
        var z = UInt64(bitPattern: Int64(seed)) &+ UInt64(bitPattern: Int64(channel)) &* 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return Double(z & 0xFFFFFF) / Double(0x1000000)
    }

    private func shellColor(seed: Int) -> Color {
        Color(
            hue: 0.082 + 0.05 * fuzz(seed, 1),
            saturation: 0.14 + 0.12 * fuzz(seed, 2),
            brightness: 0.80 + 0.10 * fuzz(seed, 3)
        )
    }

    private func plateColor(seed: Int) -> Color {
        Color(
            hue: 0.088 + 0.035 * fuzz(seed, 41),
            saturation: 0.30 + 0.14 * fuzz(seed, 42),
            brightness: 0.42 + 0.12 * fuzz(seed, 43)
        )
    }

    /// How present the hand is right now: eases in over the first moment
    /// of a touch, eases out over the half-second after it lifts.
    private func fingerPresence(now: Date) -> Double {
        if fingerDown {
            let t = now.timeIntervalSince(fingerDownSince ?? now)
            return smoothstep(0, 0.14, t)
        } else if let up = fingerUpSince {
            let t = now.timeIntervalSince(up)
            return 1 - smoothstep(0, 0.5, t)
        } else {
            return 0
        }
    }

    @inline(__always)
    private func smoothstep(_ a: Double, _ b: Double, _ x: Double) -> Double {
        let t = max(0, min(1, (x - a) / (b - a)))
        return t * t * (3 - 2 * t)
    }

    /// A barnacle is not finished when it settles. It arrives small and
    /// accretes slowly — layer over layer, the way real ones do — to its
    /// adult size across the first minute of its life. After that it is
    /// what it is: the size the water remembers it by.
    private func grownRadius(seed: Int, size: Double, age: Double) -> Double {
        let adult = size * (1.15 + 0.45 * fuzz(seed, 9))
        let p = min(1, age / 60)
        let eased = 1 - pow(1 - p, 2)
        return size + (adult - size) * eased
    }

    /// A dim warm light where the hand is — as if it refracts the light
    /// from above — so the colony's turning toward it reads.
    private func drawHandGlow(_ context: inout GraphicsContext, fingerPoint: CGPoint?, presence: Double) {
        guard let fp = fingerPoint, presence > 0.001 else { return }
        let radius: CGFloat = 160
        context.fill(
            Path(ellipseIn: CGRect(x: fp.x - radius, y: fp.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 1.0, green: 0.93, blue: 0.80).opacity(0.15 * presence),
                    .clear,
                ]),
                center: fp,
                startRadius: 0,
                endRadius: radius
            )
        )
    }

    private func drawWater(_ context: inout GraphicsContext, size: CGSize, t: Double, fingerPoint: CGPoint?, presence: Double) {
        let rect = CGRect(origin: .zero, size: size)

        // the depth
        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.055, green: 0.20, blue: 0.245),
                    Color(red: 0.012, green: 0.055, blue: 0.11),
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        // soft light from the surface
        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.10), .clear]),
                center: CGPoint(x: size.width * 0.5, y: -size.height * 0.25),
                startRadius: 0,
                endRadius: size.height * 0.95
            )
        )

        // two slow-drifting shafts of light
        for i in 0..<2 {
            let drift = sin(t * 0.05 + Double(i) * 1.9) * 26
            let x = size.width * (0.28 + 0.42 * Double(i)) + drift
            var shaft = context
            shaft.translateBy(x: x, y: -size.height * 0.15)
            shaft.rotate(by: .degrees(16))
            let shaftRect = CGRect(x: -40, y: 0, width: 80, height: size.height * 1.5)
            shaft.fill(
                Path(shaftRect),
                with: .linearGradient(
                    Gradient(colors: [Color.white.opacity(0.05), .clear]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: shaftRect.height)
                )
            )
        }

        // drifting motes, leaning a little into the hand's current
        for i in 0..<16 {
            let x0 = fuzz(0x5EED, i) * size.width
            let speed = 5 + 9 * fuzz(0x5EED, 100 + i)
            let cycle = size.height + 40
            let progress = (t * speed + Double(i) * 977.13).truncatingRemainder(dividingBy: cycle)
            var y = size.height + 20 - progress
            var x = x0 + sin(t * 0.3 + Double(i) * 0.9) * 14
            let radius = 0.7 + 1.5 * fuzz(0x5EED, 200 + i)
            let alpha = 0.04 + 0.18 * fuzz(0x5EED, 300 + i)
            if let fp = fingerPoint, presence > 0.001 {
                let dx = Double(fp.x) - x
                let dy = Double(fp.y) - y
                let d = hypot(dx, dy)
                if d > 1 {
                    let pull = presence * (1 - smoothstep(0, 170, d)) * 7
                    x += dx / d * pull
                    y += dy / d * pull
                }
            }
            context.fill(
                Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                with: .color(.white.opacity(alpha))
            )
        }
    }

    private func drawBarnacle(_ context: inout GraphicsContext, _ barnacle: Barnacle, size: CGSize, now: Date, t: Double, fingerPoint: CGPoint?, presence: Double) {
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
        let ageSettle = smoothstep(120, 1800, age)

        // breathing and drifting
        let breathePhase = 2 * .pi * fuzz(seed, 50)
        let driftPhase = 2 * .pi * fuzz(seed, 51)
        let swayX = sin(t * 0.35 + driftPhase) * 3
        let swayY = cos(t * 0.27 + driftPhase * 1.31) * 3

        // does the colony feel the current the hand has made? (0...1, eased by distance)
        var attention = 0.0
        var angleToFinger = 0.0
        if let fp = fingerPoint, presence > 0.001 {
            let dx = Double(fp.x) - Double(barnacle.x) * Double(size.width)
            let dy = Double(fp.y) - Double(barnacle.y) * Double(size.height)
            let d = hypot(dx, dy)
            if d > 0.001 {
                attention = presence * (1 - smoothstep(44, 180, d))
                angleToFinger = atan2(dy, dx)
            }
        }

        // a barnacle that feels the current breathes a little deeper —
        // but a barnacle that has settled into the rock breathes slower
        let breath = 1
            + (0.02 + 0.03 * attention) * (1 - 0.5 * ageSettle)
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

        // body: a centre lobe and a ring of lobes, wobbling gently
        var body = Path()
        body.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        let lobeCount = 5 + Int(fuzz(seed, 4) * 4)
        for i in 0..<lobeCount {
            let angle = 2 * .pi * fuzz(seed, 10 + i) + 0.18 * sin(t * 0.5 + breathePhase + Double(i))
            let distance = radius * (0.45 + 0.45 * fuzz(seed, 20 + i))
            let lobeRadius = radius * (0.30 + 0.35 * fuzz(seed, 30 + i))
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
        let plateCount = 4 + Int(fuzz(seed, 60) * 3)
        for i in 0..<plateCount {
            let angle = 2 * .pi * fuzz(seed, 70 + i) + 0.35 * sin(t * 0.21 + Double(i) * 1.7)
            let distance = radius * (0.28 + 0.30 * fuzz(seed, 80 + i))
            let plateCenter = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            let long = radius * (0.20 + 0.14 * fuzz(seed, 90 + i))
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

        // cirri: the feathery feeding plumes, reaching into the current
        // the hand has made — the barnacle tasting its visitor.
        // The young taste everything; the old answer only a hand that
        // comes close, and then reach shorter, and fainter.
        let cirriThreshold = 0.04 + 0.10 * ageSettle
        if attention > cirriThreshold {
            let beyond = (attention - cirriThreshold) / max(0.25, 1 - cirriThreshold)
            let cirriCount = 6
            let reach = radius * (0.55 + 0.65 * beyond)
            for i in 0..<cirriCount {
                let spread = (Double(i) - Double(cirriCount - 1) / 2) * 0.55
                let sway = 0.28 * sin(t * 1.1 + breathePhase + Double(i) * 1.31)
                let a = angleToFinger + spread + sway
                let start = CGPoint(
                    x: center.x + cos(a) * radius * 0.12,
                    y: center.y + sin(a) * radius * 0.12
                )
                let end = CGPoint(
                    x: center.x + cos(a) * reach,
                    y: center.y + sin(a) * reach
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
                    with: .color(Color(red: 0.85, green: 0.93, blue: 0.92).opacity(0.30 * beyond)),
                    lineWidth: 1.2
                )
            }
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
    private func drawGhost(_ context: inout GraphicsContext, _ ghost: Ghost, size: CGSize, now: Date) {
        let age = now.timeIntervalSince(ghost.departedAt)
        guard age < 150 else { return }
        // the trace keeps, then dissolves
        let fade = 1 - smoothstep(40, 150, age)
        guard fade > 0.001 else { return }

        let center = CGPoint(x: ghost.x * size.width, y: ghost.y * size.height)
        let r = ghost.size

        // the exposed surface: pale where the body had been
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.84, green: 0.82, blue: 0.74).opacity(0.11 * fade),
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
            with: .color(Color(red: 0.88, green: 0.85, blue: 0.76).opacity(0.16 * fade)),
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
