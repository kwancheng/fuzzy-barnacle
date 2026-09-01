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

}
