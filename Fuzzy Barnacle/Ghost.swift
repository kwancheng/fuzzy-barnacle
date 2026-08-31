import Foundation
import SwiftData

/// The trace a barnacle leaves when it lets go.
///
/// The water does not forget at once: where the creature had been,
/// a faint mineral rim and a paler centre keep the shape of its
/// absence for a few minutes, then the water slowly forgets it.
///
/// `size` is the radius the barnacle had *at the moment it left* —
/// it had already grown — so the trace matches the creature that was.
@Model
final class Ghost {
    var departedAt: Date
    var x: Double
    var y: Double
    var seed: Int
    var size: Double

    init(departedAt: Date = .now, x: Double, y: Double, seed: Int, size: Double) {
        self.departedAt = departedAt
        self.x = x
        self.y = y
        self.seed = seed
        self.size = size
    }
}
