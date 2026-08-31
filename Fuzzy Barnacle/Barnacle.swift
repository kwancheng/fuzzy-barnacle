import Foundation
import SwiftData

/// A single barnacle, settled onto the surface at a moment in time.
///
/// `x` and `y` are normalized to the surface (0...1) so the colony
/// survives rotation and different device sizes; `seed` drives the
/// creature's procedural shape and colour; `size` is its base radius
/// in points.
@Model
final class Barnacle {
    var timestamp: Date
    var x: Double
    var y: Double
    var seed: Int
    var size: Double

    init(timestamp: Date = .now, x: Double, y: Double, seed: Int, size: Double) {
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.seed = seed
        self.size = size
    }
}

extension Barnacle {
    var unitPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
