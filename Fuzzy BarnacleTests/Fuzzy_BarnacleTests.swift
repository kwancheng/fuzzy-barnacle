import Testing
import SwiftUI
@testable import Fuzzy_Barnacle

struct Fuzzy_BarnacleTests {

    // The quick ones scatter from the hand: a push away, falling off
    // with distance, and gone where the hand is not — the water parts
    // around the hand, and does not remember it.

    @Test func theScatterPushesAwayFromTheHand() {
        let hand = CGPoint(x: 200, y: 400)
        let offset = ContentView.scatterOffset(from: CGPoint(x: 260, y: 400), finger: hand, presence: 1)
        #expect(offset.dx > 0, "a drifter to the right of the hand is pushed away from it")
        #expect(offset.dy == 0)
    }

    @Test func theScatterFallsOffWithDistance() {
        let hand = CGPoint(x: 200, y: 400)
        func push(_ p: CGPoint, _ presence: Double) -> Double {
            let o = ContentView.scatterOffset(from: p, finger: hand, presence: presence)
            return hypot(o.dx, o.dy)
        }
        let close = push(CGPoint(x: 240, y: 400), 1)   // 40 in: inside the parting
        let mid = push(CGPoint(x: 290, y: 400), 1)     // 90 in
        let far = push(CGPoint(x: 400, y: 400), 1)     // 200 in: beyond the parting
        #expect(close > mid)
        #expect(far == 0)
    }

    @Test func theWaterDoesNotRememberTheHand() {
        let hand = CGPoint(x: 200, y: 400)
        let offset = ContentView.scatterOffset(from: CGPoint(x: 240, y: 400), finger: hand, presence: 0)
        #expect(offset.dx == 0 && offset.dy == 0, "with the hand gone, the scatter is gone with it")
    }

    // The water's own day: the light from the surface dims and
    // brightens again on the water's clock — never pitch black, and
    // always turning. In the night a moving hand stirs the colony's
    // self-light, and the stirring fades.

    @Test func theWaterHasADayAndANight() {
        var lo = 1.0
        var hi = 0.0
        for i in 0..<5760 {
            let v = ContentView.daylight(Double(i) * 0.25)
            lo = min(lo, v)
            hi = max(hi, v)
        }
        #expect(lo >= 0.02, "the water's night is never pitch black")
        #expect(hi <= 1.0)
        #expect(hi - lo > 0.8, "the water's light actually turns")
    }

    @Test func theStirringLingersThenFades() {
        let stirred = ContentView.handFlashEnvelope(speed: 400, age: 0, light: 0)
        #expect(stirred > 0.9, "a fast hand in the dark water is light")
        let after = ContentView.handFlashEnvelope(speed: 400, age: 3, light: 0)
        #expect(after < stirred * 0.15, "the stirred light fades within three seconds")
        #expect(ContentView.handFlashEnvelope(speed: 400, age: 0, light: 1) == 0, "in full daylight the stirring is not seen")
    }

    // The storm: rare weather over the water. It comes only when
    // two incommensurate currents align and the sky is willing, so
    // the water is mostly calm. While it is here, the light from
    // above is darkened under the cloud — and where the water is
    // calm, nothing is changed at all.

    @Test func theStormComesAndGoes() {
        // forty-eight hours of the water's clock, second by second
        var calmSeconds = 0
        var windows = 0
        var inWindow = false
        for i in 0..<172800 {
            let s = ContentView.storm(Double(i))
            if s < 0.05 { calmSeconds += 1 }
            if s > 0.5 {
                if !inWindow {
                    windows += 1
                    inWindow = true
                }
            } else {
                inWindow = false
            }
        }
        #expect(calmSeconds > 150_000, "the water is mostly calm")
        #expect(windows >= 10 && windows <= 60, "the storms are rare, and pass")
    }

    @Test func aFullStormDoesCome() {
        // within two days the alignment and the season do meet,
        // and the storm runs to its full strength
        var hi = 0.0
        for i in stride(from: 0, to: 172800, by: 2) {
            hi = max(hi, ContentView.storm(Double(i)))
        }
        #expect(hi > 0.9, "a full storm does come")
    }

    @Test func theStormDarkensTheWater() {
        // where the water is calm, the piece draws the plain day;
        // where the storm runs to its full strength, the light is
        // darkened under the cloud
        #expect(ContentView.drawnLight(0) == ContentView.daylight(0), "a calm water is unchanged by the storm")
        var hi = 0.0
        var hiAt = 0.0
        for i in stride(from: 0, to: 172800, by: 2) {
            let s = ContentView.storm(Double(i))
            if s > hi {
                hi = s
                hiAt = Double(i)
            }
        }
        #expect(hi > 0.95, "within two days a storm runs to its full strength")
        #expect(
            ContentView.drawnLight(hiAt) <= ContentView.daylight(hiAt) * (1 - 0.35 * 0.95),
            "at a storm's full strength the light is darkened under the cloud"
        )
    }

    // The virtual clock: the piece can be launched with a shifted
    // clock, so its time-dependent weather can be seen on demand
    // without waiting for the real water's day.

    @Test func theVirtualClockIsReadFromTheLaunchArguments() {
        #expect(ContentView.virtualTimeOffset(from: ["Fuzzy Barnacle"]) == 0, "no argument, no shift")
        #expect(ContentView.virtualTimeOffset(from: ["Fuzzy Barnacle", "-fb.virtualTimeOffset", "42"]) == 42, "a positive shift is read")
        #expect(ContentView.virtualTimeOffset(from: ["Fuzzy Barnacle", "-fb.virtualTimeOffset", "-90000"]) == -90_000, "a negative shift is read")
        #expect(ContentView.virtualTimeOffset(from: ["Fuzzy Barnacle", "-fb.virtualTimeOffset"]) == 0, "a dangling flag shifts nothing")
        #expect(ContentView.virtualTimeOffset(from: ["Fuzzy Barnacle", "-fb.virtualTimeOffset", "not-a-number"]) == 0, "a numberless shift is nothing")
    }

    @Test func theShiftedClockFindsTheStormOnDemand() {
        // a shift of the clock moves the water through its weather:
        // from any moment there is a nearby moment under a full
        // storm, and there is a nearby moment that is calm — so the
        // weather can be tested in virtual time, not waited for
        var hi = 0.0
        var hiAt = 0.0
        for i in stride(from: 0, to: 172800, by: 2) {
            let s = ContentView.storm(Double(i))
            if s > hi {
                hi = s
                hiAt = Double(i)
            }
        }
        #expect(hi > 0.95, "within two days a storm runs to its full strength")
        // the shift that lands a given moment on that peak
        let now = 1_000_000.0
        let offset = hiAt - now
        #expect(ContentView.storm(now + offset) > 0.95, "the shifted clock reaches the storm")
        #expect(
            ContentView.drawnLight(now + offset) <= ContentView.daylight(now + offset) * (1 - 0.35 * 0.95),
            "under the shifted sky the light is darkened"
        )
        // and a calm moment is just as close: the shift that lands
        // on it leaves the water unchanged
        var calmAt = 0.0
        for i in stride(from: 0, to: 172800, by: 2) where ContentView.storm(Double(i)) < 0.02 {
            calmAt = Double(i)
            break
        }
        #expect(ContentView.storm(now + calmAt - now) < 0.02, "the shifted clock also reaches the calm")
        #expect(ContentView.drawnLight(now + calmAt - now) == ContentView.daylight(now + calmAt - now), "and there the water is unchanged")
    }

    // The wake: a moving hand stirs the water's own small light
    // along its path, the way the sea sparkles where a wave breaks.
    // A still hand makes none — a still hand is a lamp. It shows
    // where the light from above is gone, and the water forgets it.

    @Test func theMovingHandMakesAWake() {
        let nightFast = ContentView.wakeStrength(speed: 450, light: 0, storm: 0)
        let dayFast = ContentView.wakeStrength(speed: 450, light: 1, storm: 0)
        let still = ContentView.wakeStrength(speed: 0, light: 0, storm: 0)
        #expect(nightFast > dayFast, "the wake shows where the light from above is gone")
        #expect(dayFast > 0, "in the day the wake is faint, not gone")
        #expect(still == 0, "a still hand makes no wake — a still hand is a lamp")
    }

    @Test func theWakeShowsUnderTheCloud() {
        // the storm's cloud is a going-out of the light, and the
        // water's small light shows under it, the way it shows in
        // the night
        let calmNight = ContentView.wakeStrength(speed: 450, light: 0, storm: 0)
        let stormNight = ContentView.wakeStrength(speed: 450, light: 0, storm: 1)
        #expect(stormNight > calmNight, "the wake is brighter under the storm's cloud")
    }

    @Test func theWakeLingersThenTheWaterForgets() {
        let fresh = ContentView.wakeFade(age: 0)
        #expect(fresh == 1, "a just-made wake is at its full")
        let later = ContentView.wakeFade(age: 3)
        #expect(later == 0, "the water forgets the wake within three seconds")
        let mid = ContentView.wakeFade(age: 0.8)
        #expect(mid > 0 && mid < 1, "the wake lingers a moment, then fades")
    }

}
