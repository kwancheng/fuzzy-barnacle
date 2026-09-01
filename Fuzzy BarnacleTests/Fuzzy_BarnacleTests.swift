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

}
