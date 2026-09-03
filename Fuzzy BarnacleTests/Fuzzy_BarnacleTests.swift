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

    // The voice: the water's voice is the water's own motion, heard.
    // The same tide that carries the motes is what murmurs — and it
    // murmurs as the tide *turns*, so the slack water is quiet. The
    // storm is what falls as rain, and a moving hand is what
    // swishes, the way the sea swishes where a wave breaks. A still
    // hand makes no swish at all: a still hand is only a lamp.

    @Test func theWaterSpeaksAsTheTideTurns() {
        // over two days of the water's clock there is a slack — a
        // moment where the current is neither swelling nor easing,
        // and the water is quiet — and there is a full turn, where
        // the flood or the ebb is at its fastest and the water is
        // speaking
        var quietest = 1.0
        var loudest = 0.0
        for i in 0..<345_600 {
            let t = Double(i) * 0.5
            let m = ContentView.murmurGain(
                strengthNow: ContentView.tide(t).strength,
                strengthThen: ContentView.tide(t - 2).strength
            )
            quietest = min(quietest, m)
            loudest = max(loudest, m)
        }
        #expect(quietest < 0.02, "at the slack the water is quiet")
        #expect(loudest > 0.10, "with the flood and the ebb the water speaks")
    }

    @Test func theRainIsTheStormsVoice() {
        #expect(ContentView.rainGain(storm: 0, light: 1) == 0, "where there is no storm there is no rain")
        #expect(
            ContentView.rainGain(storm: 0.5, light: 1) > ContentView.rainGain(storm: 0.2, light: 1),
            "the rain falls with the storm"
        )
        #expect(
            ContentView.rainGain(storm: 1, light: 1) > ContentView.rainGain(storm: 1, light: 0.02),
            "the rain keeps a little more of itself in the day"
        )
    }

    @Test func theMovingHandMakesASwish() {
        #expect(ContentView.handSwish(speed: 0, age: 0) == 0, "a still hand makes no swish — a still hand is only a lamp")
        let fast = ContentView.handSwish(speed: 450, age: 0)
        #expect(fast > 0.2, "a fast hand parts the water, and the water swishes")
        let later = ContentView.handSwish(speed: 450, age: 3)
        #expect(later < fast * 0.1, "the swish lingers a moment, then the water is quiet again")
    }

    // The colony's closing: the tuck. When the storm comes the
    // colony tucks in, and the closing of its shells is a granular
    // voice — the colony's own voice, made of the colony itself.
    // Where there is no storm the colony is quiet, the way the slack
    // water is quiet. The colony's voice is the storm's, not the
    // colony's.

    @Test func theColonyIsQuietWhereThereIsNoStorm() {
        #expect(ContentView.tuckGain(storm: 0) == 0, "where there is no storm the colony is quiet")
        #expect(
            ContentView.tuckGain(storm: 1) > ContentView.tuckGain(storm: 0.3)
                && ContentView.tuckGain(storm: 0.3) > ContentView.tuckGain(storm: 0.1),
            "the closing comes and thickens with the storm"
        )
    }

    @Test func theColonySpeaksMostlyInTheCalms() {
        // forty-eight hours of the water's clock: the water is
        // mostly calm, and the colony is quiet with it — the
        // colony's voice is the storm's, not its own
        var quietSeconds = 0
        for i in 0..<172_800 {
            if ContentView.tuckGain(storm: ContentView.storm(Double(i))) < 0.01 {
                quietSeconds += 1
            }
        }
        #expect(quietSeconds > 150_000, "the colony is quiet most of the time, the way the water is calm most of the time")
    }

    @Test func aFullTuckDoesCome() {
        // within two days the storm runs to its full strength, and
        // with it the colony's closing runs to its full
        var hi = 0.0
        for i in stride(from: 0, to: 172_800, by: 2) {
            hi = max(hi, ContentView.tuckGain(storm: ContentView.storm(Double(i))))
        }
        #expect(hi > 0.05, "a full tuck does come, with a full storm")
    }

    // The moon: the sky's own slow word. It crosses rarely — the
    // way the storm comes, only rarer — and keeps to the night: in
    // the day the sky is too bright, and the crossing passes
    // unseen. While it is over the water, its beam of light drifts
    // across it, and the moving water glints under it; where the
    // moon is not, the sky is silent.

    @Test func theMoonKeepsToTheNight() {
        // forty-eight hours of the water's clock: wherever the moon
        // is seen, it is seen in the night, and the night only
        // takes the moon's light, never gives it
        for i in stride(from: 0, to: 172_800, by: 2) {
            let t = Double(i)
            let drawn = ContentView.moonDrawn(t)
            #expect(drawn <= ContentView.moon(t) + 0.000_001, "the night only takes the moon's light, never gives")
            if drawn > 0.8 {
                #expect(ContentView.daylight(t) < 0.2, "a crossing seen at its full is a night crossing")
            }
        }
    }

    @Test func aCrossingDoesCome() {
        // within two days the alignment and the clear sky and the
        // night do meet, and a crossing runs near to its full —
        // and the crossings are rare: the moon is a guest, not a
        // weather
        var hi = 0.0
        var windows = 0
        var inWindow = false
        for i in 0..<172_800 {
            let m = ContentView.moonDrawn(Double(i))
            if m > hi { hi = m }
            if m > 0.3 {
                if !inWindow {
                    windows += 1
                    inWindow = true
                }
            } else {
                inWindow = false
            }
        }
        #expect(hi > 0.8, "a crossing near to its full does come")
        #expect(windows >= 5 && windows <= 40, "the crossings come, and the crossings are rare")
    }

    @Test func theMoonsLightDriftsAcrossTheWater() {
        // while the moon is over the water, its beam moves: the
        // crossing is a drifting, not a standing — the one light
        // in the piece that moves across the water instead of over
        // it
        var lo = Double.greatestFiniteMagnitude
        var hi = -Double.greatestFiniteMagnitude
        var seen = 0
        for i in 0..<172_800 {
            if ContentView.moonDrawn(Double(i)) > 0.5 {
                let x = ContentView.moonBeamX(Double(i), width: 430)
                lo = min(lo, x)
                hi = max(hi, x)
                seen += 1
            }
        }
        #expect(seen > 0, "the moon is seen sometimes")
        #expect(hi - lo > 200, "the moon's light drifts across the water while it is here")
    }

    @Test func theSkyIsSilentWhereTheMoonIsNot() {
        #expect(ContentView.glintGain(moon: 0, current: 1) == 0, "where the moon is not, the sky is silent")
        #expect(
            ContentView.glintGain(moon: 1, current: 1) > ContentView.glintGain(moon: 1, current: 0.3),
            "the moving water glints more than the still water"
        )
        #expect(
            ContentView.glintGain(moon: 1, current: 1) < ContentView.rainGain(storm: 1, light: 1),
            "the guest's voice is quieter than the weather's"
        )
    }

    // The deep one: a body in the water's depths. It comes the way
    // the storm and the moon come, only rarer still — two
    // incommensurate currents must align, and the deep season,
    // which turns slower than the sky's, must be willing. While it
    // is here it drifts across the depths, entering from one side
    // of the water and leaving by the other; and it has a voice of
    // its own — one low tone, the way a single body makes a single
    // sound — the piece's first voice that is not the water's.

    @Test func theDeepOneIsRare() {
        // forty-eight hours of the water's clock: the water is
        // mostly calm, and the deep ones are rarer still than the
        // moon's crossings — the deep one is the piece's least
        // frequent guest
        var calmSeconds = 0
        var deepWindows = 0
        var inWindow = false
        var moonWindows = 0
        var inMoon = false
        for i in 0..<172_800 {
            let t = Double(i)
            let d = ContentView.deep(t)
            let m = ContentView.moonDrawn(t)
            if d < 0.05 { calmSeconds += 1 }
            if d > 0.3 {
                if !inWindow {
                    deepWindows += 1
                    inWindow = true
                }
            } else {
                inWindow = false
            }
            if m > 0.3 {
                if !inMoon {
                    moonWindows += 1
                    inMoon = true
                }
            } else {
                inMoon = false
            }
        }
        #expect(calmSeconds > 150_000, "the water is mostly calm, and mostly without a deep one")
        #expect(deepWindows >= 4 && deepWindows < moonWindows, "the deep one comes, and it comes rarer than the moon")
    }

    @Test func aDeepPassingDoesCome() {
        // within two days the alignment and the deep season do
        // meet, and the passing runs to its full
        var hi = 0.0
        for i in stride(from: 0, to: 172_800, by: 2) {
            hi = max(hi, ContentView.deep(Double(i)))
        }
        #expect(hi > 0.85, "a full passing does come")
    }

    @Test func theDeepOneDriftsAcrossTheWater() {
        // while the deep one is under the water, its crossing
        // moves: it enters from one side of the water and leaves
        // by the other — and it keeps to the deep, the way the
        // deep keeps
        var lo = Double.greatestFiniteMagnitude
        var hi = -Double.greatestFiniteMagnitude
        var seen = 0
        for i in 0..<172_800 {
            if ContentView.deep(Double(i)) > 0.3 {
                let x = ContentView.deepX(Double(i), width: 430)
                lo = min(lo, x)
                hi = max(hi, x)
                seen += 1
            }
        }
        #expect(seen > 0, "the deep one is under the water sometimes")
        #expect(lo < 0 && hi > 430, "it enters from one side of the water and leaves by the other")
        for i in stride(from: 0, to: 172_800, by: 30) {
            let y = ContentView.deepY(Double(i), height: 928)
            #expect(y > 0.7 * 928 && y < 0.9 * 928, "the deep one keeps to the deep")
        }
    }

    @Test func theDeepOneHasOneVoice() {
        // the deep one's voice is the deep one's, not the
        // water's: where there is no passing there is no tone,
        // and the tone is a low one — quieter than the
        // weather's voice — and the piece is mostly without it
        #expect(ContentView.deepGain(0) == 0, "where there is no deep one there is no tone")
        #expect(
            ContentView.deepGain(1) < ContentView.rainGain(storm: 1, light: 1),
            "the deep one's voice is a low one, quieter than the weather's"
        )
        var quietSeconds = 0
        for i in 0..<172_800 {
            if ContentView.deepGain(ContentView.deep(Double(i))) < 0.01 {
                quietSeconds += 1
            }
        }
        #expect(quietSeconds > 150_000, "the deep one's tone is a rare one")
    }

    // The deep one's own small light: the piece's first light
    // that is not the sky's — made by the body, in the night,
    // breathing at the body's breath, gone where the passing is
    // gone. One body, one voice, one light.

    @Test func theDeepOneHasItsOwnLight() {
        #expect(ContentView.deepLight(deep: 0, light: 0, t: 0) == 0, "where there is no deep one there is no light of the deep")
        #expect(ContentView.deepLight(deep: 1, light: 1, t: 0) == 0, "in the full day the deep's own light is not seen — the sky's light is enough")
        let night = ContentView.deepLight(deep: 1, light: 0, t: 0)
        #expect(night > 0.05 && night <= 0.10, "in the deep night the body carries its own small light")
        // the deep's light is the deep's, not the sky's: fainter
        // than the moon's beam at its full, the way the deep is
        // fainter than the sky
        #expect(night < 0.08 * 1.5, "the deep's light is a small one, not the sky's")
    }

    @Test func theDeepLightBreathesWithTheBody() {
        // the light breathes at the body's breath — the same 37 s
        // gain-breath that makes the body's tone, the way a large
        // body breaths: it comes back with the breath, and it
        // swells and eases within it
        let a = ContentView.deepLight(deep: 1, light: 0, t: 1000)
        let b = ContentView.deepLight(deep: 1, light: 0, t: 1000 + 37)
        #expect(abs(a - b) < 0.000_001, "the light returns with the body's breath")
        var lo = Double.greatestFiniteMagnitude
        var hi = -Double.greatestFiniteMagnitude
        for i in 0..<74 {
            let v = ContentView.deepLight(deep: 1, light: 0, t: Double(i) * 0.5)
            lo = min(lo, v)
            hi = max(hi, v)
        }
        #expect(hi > lo * 1.2, "the light swells and eases at the body's breath")
    }

    @Test func theDeepLightIsARareOne() {
        // over two days of the water's clock the deep's light is
        // up for a small part of the time only: it is the
        // passing's, and the passing is rare, and the light keeps
        // to the night, the way the deep keeps
        var litSeconds = 0
        for i in 0..<172_800 {
            if ContentView.deepLight(
                deep: ContentView.deep(Double(i)),
                light: ContentView.drawnLight(Double(i)),
                t: Double(i)
            ) > 0.02 {
                litSeconds += 1
            }
        }
        #expect(litSeconds > 0, "the deep's light does come up")
        #expect(litSeconds < 3_000, "the deep's light is a rare one")
    }

    // The deep one's twin: the piece's rarest moment. The twin
    // comes the way the deep one comes — on its own currents and
    // its own season, calendars the deep one does not keep — so it
    // is rarely there, and the deep one is rarely there, and the
    // two are rarely there together, the way the deep does not
    // agree with the sky. The twin keeps a little higher in the
    // water, and is the smaller of the two, and it has a voice of
    // its own, a little above the deep one's, and a light of its
    // own, the fainter, less blue of the two — one body, one
    // voice, one light, for each of them.

    @Test func theDeepOneHasATwin() {
        // forty-eight hours of the water's clock: the twin comes
        // the way the deep one comes — rarely, on its own
        // calendar — and it does not come more often than the deep
        // one does, the way its kind keeps
        var calmSeconds = 0
        var twinWindows = 0
        var inWindow = false
        var deepWindows = 0
        var inDeep = false
        for i in 0..<172_800 {
            let tw = ContentView.deepTwin(Double(i))
            if tw < 0.05 { calmSeconds += 1 }
            if tw > 0.3 {
                if !inWindow {
                    twinWindows += 1
                    inWindow = true
                }
            } else {
                inWindow = false
            }
            let d = ContentView.deep(Double(i))
            if d > 0.3 {
                if !inDeep {
                    deepWindows += 1
                    inDeep = true
                }
            } else {
                inDeep = false
            }
        }
        #expect(calmSeconds > 150_000, "the water is mostly without its twin")
        #expect(twinWindows >= 4, "the twin comes, the way the deep one comes")
        #expect(twinWindows < deepWindows + 2, "the twin does not come more often than the deep one")
    }

    @Test func theTwoBodiesBarelyMeet() {
        // the piece's rarest moment: the deep one is rarely there,
        // and the twin is rarely there, and the two are rarely
        // there together — over thirty days of the water's clock
        // the two are together for a small part of the time only,
        // the way the deep does not agree with the sky
        var bothSeconds = 0
        for i in stride(from: 0, to: 2_592_000, by: 1) {
            if ContentView.deep(Double(i)) > 0.3 && ContentView.deepTwin(Double(i)) > 0.3 {
                bothSeconds += 1
            }
        }
        #expect(bothSeconds > 0, "the two are together sometimes — the rarest of times")
        #expect(bothSeconds < 2_500, "the two are together rarely: under one part in a thousand of the water's days")
    }

    @Test func aTwinPassingDoesCome() {
        // within two days the twin's alignment and its season do
        // meet, and the passing runs to its full
        var hi = 0.0
        for i in stride(from: 0, to: 172_800, by: 2) {
            hi = max(hi, ContentView.deepTwin(Double(i)))
        }
        #expect(hi > 0.85, "a full twin passing does come")
    }

    @Test func theTwinKeepsToTheDeep() {
        // the twin keeps to the deep the way the deep one keeps —
        // and a little higher in the water, the way its kind
        // keeps — and its crossing is a drifting: it enters from
        // one side of the water and leaves by the other
        var lo = Double.greatestFiniteMagnitude
        var hi = -Double.greatestFiniteMagnitude
        for i in stride(from: 0, to: 172_800, by: 5) {
            let x = ContentView.deepTwinX(Double(i), width: 430)
            lo = min(lo, x)
            hi = max(hi, x)
        }
        #expect(lo < 0 && hi > 430, "the twin enters from one side of the water and leaves by the other")
        for i in stride(from: 0, to: 172_800, by: 30) {
            let y = ContentView.deepTwinY(Double(i), height: 928)
            #expect(y > 0.6 * 928 && y < 0.8 * 928, "the twin keeps to the deep")
        }
    }

    @Test func theTwinHasOneVoice() {
        // the twin's voice is the twin's, not the water's: where
        // there is no twin there is no tone of the twin, and the
        // tone is a low one — quieter than the weather's voice —
        // and the piece is mostly without it
        #expect(ContentView.deepTwinGain(0) == 0, "where there is no twin there is no tone of the twin")
        #expect(
            ContentView.deepTwinGain(1) < ContentView.rainGain(storm: 1, light: 1),
            "the twin's voice is a low one, quieter than the weather's"
        )
        var quietSeconds = 0
        for i in 0..<172_800 {
            if ContentView.deepTwinGain(ContentView.deepTwin(Double(i))) < 0.01 {
                quietSeconds += 1
            }
        }
        #expect(quietSeconds > 150_000, "the twin's tone is a rare one")
    }

    @Test func theTwinHasItsOwnLight() {
        // the twin's light is the twin's: where there is no twin
        // there is no light of the twin, and in the full day the
        // twin's light is not seen, the way the deep one's is not.
        // And the twin's light is the smaller of the two — the
        // smaller body makes the smaller light — and it breathes
        // at the twin's own breath, not the deep one's
        #expect(ContentView.deepTwinLight(twin: 0, light: 0, t: 0) == 0, "where there is no twin there is no light of the twin")
        #expect(ContentView.deepTwinLight(twin: 1, light: 1, t: 0) == 0, "in the full day the twin's own light is not seen")
        let night = ContentView.deepTwinLight(twin: 1, light: 0, t: 0)
        #expect(night > 0 && night < ContentView.deepLight(deep: 1, light: 0, t: 0), "the twin's light is the smaller of the two — the smaller body makes the smaller light")
        let a = ContentView.deepTwinLight(twin: 1, light: 0, t: 1000)
        let b = ContentView.deepTwinLight(twin: 1, light: 0, t: 1000 + 41)
        #expect(abs(a - b) < 0.000_001, "the twin's light returns with the twin's own breath")
    }

    @Test func thePieceCanRunWithoutAVoice() {
        // the water's voice can be kept: by default the water
        // speaks, and `-fb.noVoice` keeps it — the piece's motion
        // is the piece's motion, whether it is heard or not
        #expect(ContentView.voiceEnabled(from: ["Fuzzy Barnacle"]) == true, "by default the water speaks")
        #expect(ContentView.voiceEnabled(from: ["Fuzzy Barnacle", "-fb.noVoice"]) == false, "`-fb.noVoice` keeps the piece's voice")
        #expect(ContentView.voiceEnabled(from: ["Fuzzy Barnacle", "-fb.virtualTimeOffset", "10", "-fb.noVoice"]) == false, "the silence holds alongside the shifted clock")
    }

    // The answer: while a body of the deep is under the water in
    // the water's night, its breath reaches the surface, and the
    // water answers with a faint cold swell — the body's light
    // reaching the surface, spread thin by the way it has traveled.

    @Test func theSurfaceAnswersTheDeepBreath() {
        // where there is no body there is no answer, and in the
        // full day the answer is not seen, the way the deep's light
        // is not seen in the sun — and the answer is thinner than
        // the light: the breath has traveled a long way, and an
        // answer is thinner than the voice that made it
        #expect(ContentView.deepAnswer(deep: 0, light: 0, t: 0) == 0, "where there is no deep one there is no answer")
        #expect(ContentView.deepAnswer(deep: 1, light: 1, t: 0) == 0, "in the full day the answer is not seen — the light from above is enough")
        let night = ContentView.deepAnswer(deep: 1, light: 0, t: 0)
        #expect(night > 0, "in the deep night the surface answers the body's breath")
        #expect(night < ContentView.deepLight(deep: 1, light: 0, t: 0), "the answer is thinner than the light — the breath has traveled a long way")
    }

    @Test func theAnswerKeepsTheBodysBreath() {
        // the answer swells and eases at the body's own breath —
        // the same 37 s breath that makes the body's light and the
        // body's tone: it returns with the breath, and it swells
        // and eases within it, the way a breath does
        let a = ContentView.deepAnswer(deep: 1, light: 0, t: 500)
        let b = ContentView.deepAnswer(deep: 1, light: 0, t: 500 + 37)
        #expect(abs(a - b) < 0.000_001, "the answer returns with the body's 37 s breath")
        var lo = Double.greatestFiniteMagnitude
        var hi = -Double.greatestFiniteMagnitude
        for i in 0..<74 {
            let v = ContentView.deepAnswer(deep: 1, light: 0, t: Double(i) * 0.5)
            lo = min(lo, v)
            hi = max(hi, v)
        }
        #expect(hi > lo * 1.2, "the answer swells and eases, the way a breath does")
    }

    @Test func theTwinAnswersAtItsOwnBreath() {
        // the twin's answer keeps the twin's own breath, not the
        // deep one's: the two answers keep their own breaths, the
        // way the two bodies do — and the smaller body's answer is
        // the smaller one
        #expect(ContentView.deepTwinAnswer(twin: 0, light: 0, t: 0) == 0, "where there is no twin there is no answer")
        #expect(ContentView.deepTwinAnswer(twin: 1, light: 1, t: 0) == 0, "in the full day the twin's answer is not seen")
        let a = ContentView.deepTwinAnswer(twin: 1, light: 0, t: 500)
        let b = ContentView.deepTwinAnswer(twin: 1, light: 0, t: 500 + 41)
        #expect(abs(a - b) < 0.000_001, "the twin's answer returns with the twin's own 41 s breath")
        var dMax = 0.0
        for i in 0..<74 {
            dMax = max(dMax, abs(ContentView.deepAnswer(deep: 1, light: 0, t: Double(i)) - ContentView.deepAnswer(deep: 1, light: 0, t: Double(i) + 41)))
        }
        #expect(dMax > 0.005, "the deep one's answer does not keep the twin's breath")
        var tMax = 0.0
        for i in 0..<82 {
            tMax = max(tMax, abs(ContentView.deepTwinAnswer(twin: 1, light: 0, t: Double(i)) - ContentView.deepTwinAnswer(twin: 1, light: 0, t: Double(i) + 37)))
        }
        #expect(tMax > 0.005, "the twin's answer does not keep the deep one's breath")
        var deepMax = 0.0
        var twinMax = 0.0
        for i in 0..<82 {
            deepMax = max(deepMax, ContentView.deepAnswer(deep: 1, light: 0, t: Double(i)))
            twinMax = max(twinMax, ContentView.deepTwinAnswer(twin: 1, light: 0, t: Double(i)))
        }
        #expect(twinMax < deepMax, "the smaller body's answer is the smaller one")
    }

    // The storm finds the deep one: the sky's dark word and the
    // deep's cold body, at the same time, in the same water. The
    // storm is what the sky remembers of the water; the deep one is
    // a body of its own. The two calendars are the sky's and the
    // deep's, and they agree rarely — but they do agree, and where
    // they agree the flood bends more around the stone, and the
    // deep's light — the piece's first light that is not the
    // sky's — is brightest of all under the sky's dark word,
    // because it is not the sky's light.

    @Test func thePartingSurgesWithTheStorm() {
        // the water goes around the deep one's back the way a river
        // goes around a stone — and a flood bends more: the
        // storm's surge makes the water go around the body more,
        // the way a storm's water goes around everything. Where
        // there is no storm the parting is the parting as it always
        // was
        #expect(ContentView.deepPartingStrength(deep: 1, storm: 0) == 9.0, "where there is no storm the parting is the parting")
        #expect(ContentView.deepPartingStrength(deep: 1, storm: 1) == 9.0 * 1.5, "at the storm's full the water goes around the body more")
        #expect(
            ContentView.deepPartingStrength(deep: 0.5, storm: 0.5) > ContentView.deepPartingStrength(deep: 0.5, storm: 0),
            "the surge bends the water around the body more"
        )
        // the twin is the smaller body: the water turns around the
        // smaller body less, the way its kind turns — and the
        // storm's surge bends the water around it more, the way it
        // bends the water around the larger body's
        #expect(
            ContentView.deepTwinPartingStrength(twin: 1, storm: 0) < ContentView.deepPartingStrength(deep: 1, storm: 0),
            "the water turns around the smaller body less"
        )
        #expect(ContentView.deepTwinPartingStrength(twin: 1, storm: 1) == 7.0 * 1.5, "the storm's surge bends the water around the twin more still")
    }

    @Test func theStormFindsTheDeepOne() {
        // the sky's dark word and the deep's body: the two
        // calendars do not agree, the way the sky does not agree
        // with the deep — but they do agree, rarely: over a year of
        // the water's clock the storm is over the deep one for a
        // small part of the time only, and the storm is over both
        // bodies at once for a rarer still — a matter of seconds in
        // a year
        var pairSeconds = 0
        var tripleSeconds = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            let s = ContentView.storm(t)
            guard s > 0.5 else { continue }
            let d = ContentView.deep(t)
            guard d > 0.5 else { continue }
            pairSeconds += 1
            if ContentView.deepTwin(t) > 0.5 {
                tripleSeconds += 1
            }
        }
        #expect(pairSeconds > 10_000, "the storm does find the deep one — rarely, but it comes")
        #expect(pairSeconds < 3_200_000, "the finding is a rare one: under a tenth of the water's year")
        #expect(tripleSeconds > 0, "the sky's dark word does come over both of them — the rarest of times")
        #expect(tripleSeconds < 100, "the dark word over both bodies is a matter of seconds in a year")
    }

    @Test func theStormsCloudBrightensTheDeepsLight() {
        // the sky's dark word darkens the light from above — and
        // the deep's light is not the sky's light: at every moment
        // of storm in the water's night where a body of the deep is
        // under the water, the deep's light is brighter under the
        // sky's dark word than it would be were the word not there
        // — the
        // piece's first light that is not the sky's, brightest of
        // all where the sky is darkest
        var stormNightSeconds = 0
        var brighterSeconds = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            let s = ContentView.storm(t)
            guard s > 0.5 else { continue }
            let d = ContentView.deep(t)
            guard d > 0.3, ContentView.daylight(t) < 0.25 else { continue }
            stormNightSeconds += 1
            let underWord = ContentView.deepLight(deep: d, light: ContentView.drawnLight(t), t: t)
            let wordLess = ContentView.deepLight(deep: d, light: ContentView.daylight(t), t: t)
            if underWord > wordLess {
                brighterSeconds += 1
            }
        }
        #expect(stormNightSeconds > 0, "a storm in the water's night, where a body of the deep is under the water, does come")
        #expect(
            brighterSeconds == stormNightSeconds,
            "at each of them the deep's light is brighter under the sky's dark word — it is not the sky's light"
        )
    }

    // The sky's light has a color: the water's day has always had a
    // brightness; this gives it a color too. The sky's light comes
    // down warm gold at the low turning of the water's day, the way
    // the low light is warm, and white at its high, the way the high
    // light is white — and the color is the sky's, the way the
    // deep's light is the deep's: the water's own small lights keep
    // their own, and the sky's light is the one that comes down, in
    // a color.

    @Test func theSkysLightTurnsWarm() {
        // over a water-day there is a high (the light at its full,
        // where the sky is white) and a turning (the low light, where
        // the sky's warmth peaks): the warmth peaks at the turning
        // and is gone at the high, the way the low light is warm and
        // the high light is white
        var highT = 0.0
        var highDay = -1.0
        var turnT = 0.0
        var turnNear = Double.greatestFiniteMagnitude
        for i in 0..<5760 { // a full water-day, quarter-second steps
            let t = Double(i) * 0.25
            let day = ContentView.daylight(t)
            if day > highDay { highDay = day; highT = t }
            if abs(day - 0.30) < turnNear { turnNear = abs(day - 0.30); turnT = t }
        }
        #expect(highDay > 0.95, "the day reaches its high")
        #expect(turnNear < 0.05, "the day turns through the low light")
        let highWarmth = ContentView.skyWarmth(highT)
        let turnWarmth = ContentView.skyWarmth(turnT)
        #expect(turnWarmth > 0.7, "the sky's warmth peaks at the turning")
        #expect(highWarmth < 0.05, "the sky's warmth is gone at the high")
        #expect(turnWarmth > highWarmth, "the turning is the warm moment, the high is not")
        // and the warmth is a warmth, the way a brightness is a
        // brightness: it is a value the sky keeps, not a color made
        // up
        for i in 0..<2160 {
            #expect(ContentView.skyWarmth(Double(i) * 0.25) >= 0, "the sky's warmth is a warmth (low bound)")
            #expect(ContentView.skyWarmth(Double(i) * 0.25) <= 1, "the sky's warmth is a warmth (high bound)")
        }
    }

    @Test func theSkysLightIsWhiteAtTheHigh() {
        // the color of the sky's light: at the high of the day it is
        // white — the way the water renders at full light — and at
        // the turning it is warm, red out ahead of blue, the way the
        // low light is warm
        var highT = 0.0
        var highDay = -1.0
        for i in 0..<5760 {
            let t = Double(i) * 0.25
            let day = ContentView.daylight(t)
            if day > highDay { highDay = day; highT = t }
        }
        let high = ContentView.skyLightRGB(highT)
        #expect(high.red > 0.98 && high.green > 0.98 && high.blue > 0.98,
            "at the high of the day the sky's light is white")
        // the turning: red out ahead of blue, the way the warm light
        // is
        var turnT = 0.0
        var turnNear = Double.greatestFiniteMagnitude
        for i in 0..<5760 {
            let t = Double(i) * 0.25
            if abs(ContentView.daylight(t) - 0.30) < turnNear {
                turnNear = abs(ContentView.daylight(t) - 0.30)
                turnT = t
            }
        }
        let warm = ContentView.skyLightRGB(turnT)
        #expect(warm.red > warm.blue, "at the turning the sky's light is warm — red ahead of blue")
    }

    @Test func theWaterDrinksTheSkysColor() {
        // the water's own color drinks the color of the light it is
        // given: at the high the sky's light is white, and the
        // water's own blue is exactly as it is — the full day is the
        // full day the piece has always drawn — and at the turning
        // the sky's light is warm, and the water is gilded, the way
        // the sea is gilded at dusk. And the water only drinks: it
        // never adds a color of its own, so its channels never
        // exceed the color of the water with no sky's color in it
        var highT = 0.0
        var highDay = -1.0
        var turnT = 0.0
        var turnNear = Double.greatestFiniteMagnitude
        for i in 0..<5760 { // a full water-day, quarter-second steps
            let t = Double(i) * 0.25
            let day = ContentView.daylight(t)
            if day > highDay { highDay = day; highT = t }
            if abs(day - 0.30) < turnNear { turnNear = abs(day - 0.30); turnT = t }
        }
        #expect(highDay > 0.95, "the day reaches its high")
        #expect(turnNear < 0.05, "the day turns through the low light")
        // the high: white light leaves the water's own blue as it
        // is — within the white's edge, the way the high leaves it
        let high = ContentView.waterColor(highT, light: 1.0)
        #expect(high.top.blue >= 0.95 * 0.245, "at the high the water's blue is its own (top)")
        #expect(high.top.green >= 0.95 * 0.20, "at the high the water's blue is its own (green)")
        #expect(high.bottom.blue >= 0.95 * 0.11, "at the high the water's blue is its own (deep)")
        // the turning: the warm light gilds the water — the blue is
        // taken toward the gold, the way the low light takes the
        // sea toward the gold
        let turn = ContentView.waterColor(turnT, light: 0.30)
        let turnDepthLight = 0.35 + 0.65 * 0.30
        #expect(turn.top.blue < 0.60 * 0.245 * turnDepthLight, "at the turning the water's blue is gilded — taken toward the gold")
        #expect(turn.top.blue < turn.top.green, "at the turning the water is copper, not blue — the green out ahead of the blue")
        // the water only drinks: at every hour the water's channels
        // are no more than the water's own with no sky's color in
        // it — the water never adds a color of its own
        for i in 0..<5760 {
            let t = Double(i) * 0.25
            let light = ContentView.daylight(t)
            let c = ContentView.waterColor(t, light: light)
            let depthLight = 0.35 + 0.65 * light
            let deepLight = 0.30 + 0.70 * light
            #expect(c.top.blue <= 0.245 * depthLight + 1e-9, "the water only drinks — top blue")
            #expect(c.top.green <= 0.20 * depthLight + 1e-9, "the water only drinks — top green")
            #expect(c.bottom.blue <= 0.11 * deepLight + 1e-9, "the water only drinks — deep blue")
        }
    }

    @Test func theCloudTakesTheLightNotTheColor() {
        // the storm's cloud takes the light, not the color: in the
        // low light the cloud darkens the water, the way the cloud
        // takes the light — but the water keeps the sky's warm
        // color under it, the way the dusk under a cloud is still
        // dusk: where the sky's dark word is over the water in the
        // low light, the water is gilded, not blue
        var found = 0
        var leastGilded = 1.0
        for i in 0..<6_307_200 { // a water-year, five-second steps
            let t = Double(i) * 5
            guard ContentView.storm(t) > 0.5, ContentView.daylight(t) < 0.30 else { continue }
            found += 1
            let light = ContentView.drawnLight(t)
            let c = ContentView.waterColor(t, light: light)
            let ownBlue = 0.245 * (0.35 + 0.65 * light)
            leastGilded = min(leastGilded, c.top.blue / ownBlue)
        }
        #expect(found > 0, "the sky's dark word comes in the low light sometimes")
        #expect(leastGilded < 0.7, "under the cloud in the low light the water keeps its gild")
    }

    @Test func theSkysWarmWordHasAVoice() {
        // the gild: the sky's voice in its warm hour — the sky's
        // dark word is the rain, the sky's cold word is the glint,
        // and the sky's warm word is this. It is the sky's voice on
        // the water's motion, the way the glint is: gone where the
        // sky is not warm, up at the turning, and the moving water
        // gilds more than the still water, the way the moving water
        // glints more
        #expect(ContentView.gildGain(warmth: 0, current: 1.0) == 0, "where the sky is not warm the gild is not")
        #expect(ContentView.gildGain(warmth: 1.0, current: 1.0) > 0.03, "at the turning the gild is up")
        #expect(ContentView.gildGain(warmth: 1.0, current: 1.0) <= 0.04, "the gild is a quiet voice, the way the glint is")
        #expect(
            ContentView.gildGain(warmth: 1.0, current: 1.0) > ContentView.gildGain(warmth: 1.0, current: 0.3),
            "the moving water gilds more than the still water"
        )
        // over the water's day the gild comes at the turning and is
        // gone at the high, the way the sky's warmth does: the
        // sky's warm word is a word of the water's clock, the way
        // everything in the piece is
        var maxGild = 0.0
        var highT = 0.0
        var highDay = -1.0
        for i in 0..<5760 {
            let t = Double(i) * 0.25
            let gild = ContentView.gildGain(
                warmth: ContentView.skyWarmth(t),
                current: ContentView.tide(t).strength
            )
            maxGild = max(maxGild, gild)
            let day = ContentView.daylight(t)
            if day > highDay { highDay = day; highT = t }
        }
        #expect(maxGild > 0.02, "the gild does come")
        let highGild = ContentView.gildGain(
            warmth: ContentView.skyWarmth(highT),
            current: ContentView.tide(highT).strength
        )
        #expect(highGild < 0.005, "the gild is gone at the high, the way the warmth is gone at the high")
    }

    // The hush: the one taking-away the body makes. Everything else
    // the body makes in the piece is a giving — the water goes
    // around it, the body carries a light, the surface answers its
    // breath, the voice carries its tone. The hush is the body's
    // presence thinning the water's own speech: where a body of the
    // deep is in the water the murmur goes thin around it, the way
    // a river's voice goes thin around a stone, and when the body
    // drifts off the water the hush goes with it, and the water
    // speaks again, the way a river speaks again past the stone.

    @Test func theWaterHushesWhereTheBodySpeaks() {
        // the hush is the body's presence, on the water's own
        // speech: where there is no body there is no hush, and
        // where a body is at the middle of the water the hush is at
        // its full — and it is a hush, not a silence: it thins the
        // water's voice, it does not take it
        var maxDeep = 0.0
        var maxTwin = 0.0
        var offSeconds = 0
        for i in stride(from: 0, to: 4872, by: 1) {
            let t = Double(i)
            // no body, no hush — the hush is the body's, the way
            // everything in the piece is
            #expect(ContentView.hushGain(deep: 0, twin: 0, t: t) == 0, "where there is no body there is no hush")
            let hD = ContentView.hushGain(deep: 1, twin: 0, t: t)
            let hT = ContentView.hushGain(deep: 0, twin: 1, t: t)
            maxDeep = max(maxDeep, hD)
            maxTwin = max(maxTwin, hT)
            #expect(hD >= 0 && hD <= 0.40, "the hush is a thinning, not a taking-away: it stays in its own band")
            if abs(ContentView.deepX(t, width: 1) - 0.5) > 0.75 {
                offSeconds += 1
            }
        }
        #expect(maxDeep > 0.39, "at the middle of the water the larger body's hush is at its full")
        #expect(abs(maxDeep - 0.40) < 0.005, "the larger body's hush is the water's own hush: four tenths of the water's voice, no more")
        #expect(offSeconds > 100, "the larger body does drift off the water, the way its passing is a crossing")
    }

    @Test func theSmallerBodyHushesLess() {
        // the smaller body hushes the water less, the way the
        // smaller body turns the water less — seven ninths of the
        // way the larger one does, the way its kind turns: at the
        // middle of the water the larger body's hush is the deeper
        // of the two, the way its turning of the water is the
        // deeper of the two
        #expect(
            abs(0.31 / 0.40 - 7.0 / 9.0) < 0.01,
            "the smaller body hushes seven ninths of the way the larger one does, the way it turns the water"
        )
        var maxDeep = 0.0
        var maxTwin = 0.0
        for i in stride(from: 0, to: 8000, by: 1) {
            let t = Double(i)
            maxDeep = max(maxDeep, ContentView.hushGain(deep: 1, twin: 0, t: t))
            maxTwin = max(maxTwin, ContentView.hushGain(deep: 0, twin: 1, t: t))
        }
        #expect(abs(maxTwin - 0.31) < 0.005, "at the middle of the water the smaller body's hush is its own, and a lesser one")
        #expect(maxDeep > maxTwin, "at the middle of the water the larger body's hush is the deeper of the two, the way its turning is")
    }

    @Test func theHushGoesWithTheBody() {
        // the hush is the body's presence, not the body's envelope
        // alone: it tracks the body's crossing. Where the body is
        // at the middle of the water the hush is at its full; where
        // the body has drifted off the water — still present, its
        // answer still at the surface, the way presence is not
        // position — the hush has gone with it, and the water
        // speaks again
        // on the water's own scale: the larger body's crossing, and
        // the hush of it, at full presence
        var fullSeconds = 0
        var goneSeconds = 0
        for i in stride(from: 0, to: 2900, by: 1) {
            let t = Double(i)
            let off = abs(ContentView.deepX(t, width: 1) - 0.5)
            if off < 0.15 {
                #expect(ContentView.hushGain(deep: 1, twin: 0, t: t) > 0.30, "at the middle of the water the hush is at its full")
                fullSeconds += 1
            }
            if off > 0.75 {
                #expect(ContentView.hushGain(deep: 1, twin: 0, t: t) < 0.02, "off the water the hush goes with the body, and the water speaks again")
                goneSeconds += 1
            }
        }
        #expect(fullSeconds > 100, "the larger body does come to the middle of the water, and the hush is there")
        #expect(goneSeconds > 100, "the larger body does drift off the water, and the hush goes with it")
        // in the water's own calendar: a body present, and off the
        // water, does come — and at each of them the hush is the
        // small one, the way the body is the small one there
        var offPresentSeconds = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            let d = ContentView.deep(t)
            guard d > 0.5, abs(ContentView.deepX(t, width: 1) - 0.5) > 0.75 else { continue }
            #expect(ContentView.hushGain(deep: d, twin: 0, t: t) < 0.02, "the body present and off the water: the hush has gone with it")
            offPresentSeconds += 1
        }
        #expect(offPresentSeconds > 0, "a body present and off the water does come, the way the body's passing is a crossing of the water")
    }

    @Test func theWaterSpeaksAgainWhenThePassingEnds() {
        // the hush is the passing's, and the passing ends: over a
        // year of the water's clock the water hushes for a small
        // part of the time only — the bodies are rare, and the
        // hush is rarer still, being where the body is, and the
        // water speaks most of the time, the way the water does
        var hushSeconds = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            if ContentView.hushGain(deep: ContentView.deep(t), twin: ContentView.deepTwin(t), t: t) > 0.05 {
                hushSeconds += 1
            }
        }
        #expect(hushSeconds > 50_000, "the water does hush: where the bodies are in the water the water's own speech goes thin")
        #expect(hushSeconds < 1_000_000, "the hush is a small part of the water's year: under an hour of hush to the water's day, the way the passing is a small part of the water's time")
    }

    @Test func theHushOnlyTakesFromTheMurmur() {
        // the hush is a taking-away, not a giving: the spoken
        // murmur — the tide's turning, thinned where the body is —
        // never exceeds the turning's own voice, the way a hush
        // never adds to the water's speech. At the middle of the
        // water the water hushes, and off the water the water
        // speaks again, the way a river speaks again past the stone
        let now = 1.0
        let then = 0.3
        let own = ContentView.murmurGain(strengthNow: now, strengthThen: then)
        #expect(own > 0.1, "the tide's turning does speak, the way the flood and the ebb speak")
        var centerT = 0.0
        var edgeT = 0.0
        var centerOff = 10.0
        var edgeOff = 0.0
        for i in stride(from: 0, to: 2900, by: 1) {
            let t = Double(i)
            let spoken = ContentView.spokenMurmur(strengthNow: now, strengthThen: then, deep: 1, twin: 0, t: t)
            #expect(spoken <= own + 1e-9, "the hush only takes: the spoken murmur never exceeds the turning's own voice")
            let off = abs(ContentView.deepX(t, width: 1) - 0.5)
            if off < centerOff { centerOff = off; centerT = t }
            if off > edgeOff { edgeOff = off; edgeT = t }
        }
        let hushed = ContentView.spokenMurmur(strengthNow: now, strengthThen: then, deep: 1, twin: 0, t: centerT)
        #expect(hushed < 0.65 * own, "at the middle of the water the water hushes: the turning's own voice, thinned around the body")
        let again = ContentView.spokenMurmur(strengthNow: now, strengthThen: then, deep: 1, twin: 0, t: edgeT)
        #expect(again > 0.9 * own, "off the water the hush goes with the body, and the water speaks again")
    }

    // The sky's dark word has a low end: the roll under the rain.
    // The rain — the sky's dark word — falls on the surface, and
    // the sky's other words are words of the surface still: the
    // glint, high grains of the moon's light, the gild, a warm low
    // band of the turning. The deep, the water's bottom, has the
    // body's voice — the deep one's low tone, the twin's a little
    // above — and the sky's word never reaches it. The roll is the
    // sky's dark word's low end: the storm's voice in the deep,
    // and where the storm is over the water and a body of the deep
    // is under it, the sky's word and the body's word sound in the
    // same deep — the rarest weather heard at its bottom.

    @Test func theSkysDarkWordHasALowEnd() {
        // the roll is the storm's, not the water's: where there is
        // no storm there is no low end, the way there is no rain
        // where there is no storm
        #expect(ContentView.rollGain(storm: 0, light: 1) == 0, "without the storm the sky's dark word has no low end")
        #expect(ContentView.rollGain(storm: 0, light: 0) == 0)
        // the low end never drowns the surface's own voice: the
        // roll stays below the rain, the way a bottom stays below
        // the surface
        for s in stride(from: 0.0, through: 1.0, by: 0.05) {
            for l in stride(from: 0.0, through: 1.0, by: 0.1) {
                #expect(
                    ContentView.rollGain(storm: s, light: l) <= ContentView.rainGain(storm: s, light: l),
                    "the low end never exceeds the surface's own voice"
                )
            }
        }
        // a little less in the night, the way the rain is a little
        // less in the night
        #expect(ContentView.rollGain(storm: 1, light: 0) < ContentView.rollGain(storm: 1, light: 1))
        // the low end keeps below the body's own voice: the sky's
        // word stays under the body's word, so the tone is heard
        // above the roll, the way the body's voice is the body's
        #expect(
            ContentView.rollGain(storm: 1, light: 1) < ContentView.deepGain(1),
            "the sky's low end keeps below the body's voice"
        )
    }

    @Test func theRarestWeatherIsHeardAtItsBottom() {
        // the sky's dark word and the deep's bodies: over a year
        // of the water's clock the storm is over the deep one for
        // a small part of the time only, and over both bodies at
        // once for a rarer still — a matter of seconds in a year
        // — and at every one of those seconds the low end is with
        // the sky's dark word: the rarest weather is heard at its
        // bottom, the way the rarest moment is seen from above
        var meetingSeconds = 0
        var tripleSeconds = 0
        var lowEndMissing = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            let s = ContentView.storm(t)
            guard s > 0.5 else { continue }
            let d = ContentView.deep(t)
            guard d > 0.5 else { continue }
            meetingSeconds += 1
            if ContentView.deepTwin(t) > 0.5 {
                tripleSeconds += 1
            }
            if ContentView.rollGain(storm: s, light: ContentView.drawnLight(t)) <= 0 {
                lowEndMissing += 1
            }
        }
        #expect(meetingSeconds > 10_000, "the storm does find the deep one — rarely, but it comes")
        #expect(meetingSeconds < 3_200_000, "the finding is a rare one: under a tenth of the water's year")
        #expect(
            lowEndMissing == 0,
            "where the sky's dark word is over the deep, its low end is with it — the rarest weather is heard at its bottom"
        )
        #expect(tripleSeconds > 0, "the sky's dark word does come over both of them — the rarest of times")
        #expect(tripleSeconds < 100, "the dark word over both bodies is a matter of seconds in a year")
    }

    @Test func theSkyDoesNotReadTheHush() {
        // the hush is the body's taking-away, on the water's own
        // voice only: the murmur thins where the body is, the way
        // the water's own words thin — but the sky's word is not
        // the water's word, and the sky's dark word's low end
        // keeps its own pace through the hush, the way the rain
        // keeps falling: over a year of the water's clock the
        // body's hush and the sky's dark word do meet — the body
        // in the water, the storm over it — and at every one of
        // those seconds the roll is still there, the sky's word
        // the sky's
        var hushStormSeconds = 0
        var rollStillThere = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            guard ContentView.storm(t) > 0.5 else { continue }
            let d = ContentView.deep(t)
            let tw = ContentView.deepTwin(t)
            guard ContentView.hushGain(deep: d, twin: tw, t: t) > 0.05 else { continue }
            hushStormSeconds += 1
            if ContentView.rollGain(storm: ContentView.storm(t), light: ContentView.drawnLight(t)) > 0 {
                rollStillThere += 1
            }
        }
        #expect(hushStormSeconds > 5_000, "the body's hush and the sky's dark word do meet: the body in the water, the storm over it")
        #expect(
            rollStillThere == hushStormSeconds,
            "the sky's dark word's low end keeps its own pace through the hush, the way the rain keeps falling"
        )
    }

    // The opening: the colony's word in its calm. The tuck is the
    // colony's word in its weather — the closing, when the storm
    // tucks it in. The opening is the colony's word at home: one
    // soft chime, sparse, at the colony's own pace — full in the
    // deep calm, gone at the storm's full, the way the two words
    // turn with the weather. And the new life's first adult
    // breath, witnessed: a bloom of the colony's own light, one
    // slow ring, and the chime, the loudest the opening is.

    @Test func theColonyOpensInTheCalm() {
        #expect(ContentView.openingGain(storm: 0) == 0.015, "in the deep calm the colony's opening is full")
        #expect(ContentView.openingGain(storm: 1) == 0, "at the storm's full the opening is gone")
        // the opening thins with the storm, the way the colony's
        // word thins with the storm
        var prev = 1.0
        for i in 0...20 {
            let v = ContentView.openingGain(storm: Double(i) / 20)
            #expect(v <= prev + 0.000_001, "the opening thins with the storm")
            prev = v
        }
        // forty-eight hours of the water's clock: the water is
        // mostly calm, and the colony is open at home, the way the
        // water is calm most of the time
        var openSeconds = 0
        for i in 0..<172_800 {
            if ContentView.openingGain(storm: ContentView.storm(Double(i))) >= 0.014 {
                openSeconds += 1
            }
        }
        #expect(openSeconds > 150_000, "the colony opens at home most of the time, the way the water is calm most of the time")
    }

    @Test func theTwoWordsTurnWithTheWeather() {
        // the colony's two words: the closing, the storm's — the
        // opening, the calm's. They turn with the weather, the way
        // a sleeper's breath turns: where the closing is full the
        // opening is gone, and the two together never run past the
        // colony's storm word
        #expect(
            ContentView.openingGain(storm: 0) > 0 && ContentView.tuckGain(storm: 0) == 0,
            "where the opening is full the closing is none"
        )
        #expect(
            ContentView.tuckGain(storm: 1) > 0 && ContentView.openingGain(storm: 1) == 0,
            "where the closing is full the opening is gone"
        )
        for i in 0...20 {
            let s = Double(i) / 20
            #expect(
                ContentView.tuckGain(storm: s) + ContentView.openingGain(storm: s) <= 0.06 + 0.000_001,
                "the two words together never run past the colony's storm word"
            )
        }
    }

    @Test func aNewLifesFirstBreathIsSeen() {
        // the piece sees the becoming while it is happening: the
        // window is the moment after the accretion completes, and
        // a moment after — and not a moment longer
        #expect(ContentView.isBecoming(60), "the becoming is witnessed as it completes")
        #expect(ContentView.isBecoming(74.9), "and a moment after")
        #expect(!ContentView.isBecoming(59), "a life still accreting is not becoming yet")
        #expect(!ContentView.isBecoming(75), "after the moment, the creature is what it is")
        #expect(
            !ContentView.isBecoming(3600),
            "a life settled an hour ago is an adult: the piece keeps its size, not its becoming"
        )
        // the bloom's light: quick to come, slow to go, and gone
        #expect(ContentView.bloomFade(0.5) == 1, "the bloom is full at once")
        #expect(ContentView.bloomFade(6) == 0, "the bloom is gone within six seconds")
        let mid = ContentView.bloomFade(3)
        #expect(mid > 0 && mid < 1, "the bloom fades slowly, the way the water's small lights fade")
    }

    @Test func theOpeningKeepsBelowTheClosing() {
        // the colony's quiet word keeps below its storm word, the
        // way the sky's word keeps below the body's: the opening
        // at most 0.015, the closing at most 0.06 — and even the
        // new life's chime, the loudest the opening is, keeps
        // below the closing's full
        #expect(
            ContentView.openingGain(storm: 0) < ContentView.tuckGain(storm: 1),
            "the colony's quiet word is far below its storm word"
        )
        #expect(
            ContentView.bloomChime(0) < ContentView.tuckGain(storm: 1),
            "the loudest opening keeps below the closing's full"
        )
        #expect(ContentView.bloomChime(4) < 0.001, "the chime is gone within a few seconds, and not remembered")
    }

    // The quick ones' skitter: the quick ones' feet on the
    // water's surface. The closing is eight small voices, the
    // glint is six grains, the deep one is one, the opening is
    // one — and the quick ones are five. The skitter turns with
    // the current, is a little more in the night, the way the
    // quick ones' light is a little more in the night, and more
    // in the storm, the way the quick ones ride the storm; and a
    // moving hand parts the quick ones, and the quick ones,
    // parted, skitter away, and settle back, and the water does
    // not remember the hand, the way it forgets everything.

    @Test func theQuickOnesAreHeardInTheCurrent() {
        // the quick ones ride the current: the moving water
        // carries the quick ones, the still water does not — but
        // the quick ones never stop, so the skitter never stops
        // either: at the slack it thins to its floor, the way the
        // still water glints less than the moving water — less,
        // not none
        let floor = ContentView.skitterGain(current: 0.3, light: 1, storm: 0)
        #expect(floor > 0.002 && floor < 0.003, "at the slack the skitter keeps its floor: the quick ones never stop")
        for l in stride(from: 0.0, through: 1.0, by: 0.1) {
            for s in stride(from: 0.0, through: 1.0, by: 0.1) {
                #expect(
                    ContentView.skitterGain(current: 1.0, light: l, storm: s) > ContentView.skitterGain(current: 0.3, light: l, storm: s),
                    "the flood carries the quick ones more than the slack"
                )
            }
        }
        // a little more in the night, the way the quick ones'
        // light is a little more in the night
        #expect(
            ContentView.skitterGain(current: 1, light: 0, storm: 0) > ContentView.skitterGain(current: 1, light: 1, storm: 0),
            "a little more in the night, the way the quick ones' light is a little more in the night"
        )
        // the skitter is the piece's smallest voice: it keeps
        // small, the way the quick ones are the piece's smallest
        // motion
        for c in stride(from: 0.3, through: 1.0, by: 0.05) {
            for l in stride(from: 0.0, through: 1.0, by: 0.1) {
                for s in stride(from: 0.0, through: 1.0, by: 0.1) {
                    let v = ContentView.skitterGain(current: c, light: l, storm: s)
                    #expect(v >= 0.0025 && v <= 0.0145, "the skitter is a small voice, the way the quick ones are small")
                }
            }
        }
    }

    @Test func theQuickOnesKeepBelowTheQuietWords() {
        // the quick ones are small, the way the quick ones are
        // small: in the calm the skitter keeps below the colony's
        // quiet word, and at its corner it keeps below the
        // closing's full — the small keeps below the large, the
        // way the sky's word keeps below the body's
        for l in stride(from: 0.0, through: 1.0, by: 0.1) {
            #expect(
                ContentView.skitterGain(current: 1, light: l, storm: 0) <= ContentView.openingGain(storm: 0) + 0.000_001,
                "in the calm the skitter keeps below the colony's quiet word"
            )
        }
        #expect(
            ContentView.skitterGain(current: 1, light: 0, storm: 1) < ContentView.tuckGain(storm: 1),
            "at its corner the skitter keeps below the closing's full"
        )
        // the startle — the hand's answer to the quick ones —
        // keeps below the quick ones' own voice, the way the
        // hand's answers keep below the water's: and skitter and
        // startle together keep below the closing's full, the way
        // the piece keeps its own account of its own voices
        #expect(
            ContentView.skitterStartle(speed: 450, age: 0) < ContentView.skitterGain(current: 1, light: 0, storm: 0),
            "the startle keeps below the quick ones' own voice"
        )
        #expect(
            ContentView.skitterGain(current: 1, light: 0, storm: 1) + ContentView.skitterStartle(speed: 450, age: 0) < ContentView.tuckGain(storm: 1),
            "the skitter and the startle together keep below the closing's full"
        )
    }

    @Test func theMovingHandStartlesTheQuickOnes() {
        // the startle is the hand's, not the quick ones': a still
        // hand startles none, a moving hand startles — quick to
        // come, slow to go, gone within a few seconds — and then
        // the quick ones settle back to the current's pace, and
        // the water does not remember the hand, the way it
        // forgets everything
        #expect(ContentView.skitterStartle(speed: 0, age: 0) == 0, "a still hand startles none: a still hand is only a lamp")
        #expect(
            ContentView.skitterStartle(speed: 225, age: 0) < ContentView.skitterStartle(speed: 450, age: 0),
            "a fast hand startles most"
        )
        var prev = ContentView.skitterStartle(speed: 450, age: 0)
        for i in 1...8 {
            let v = ContentView.skitterStartle(speed: 450, age: Double(i))
            #expect(v < prev + 0.000_001, "the startle settles back to the current's pace, the way the quick ones drift back")
            prev = v
        }
        #expect(ContentView.skitterStartle(speed: 450, age: 8) < 0.0001, "gone within a few seconds, and not remembered")
    }

    @Test func theQuickOnesSkitterInTheRain() {
        // the quick ones ride the storm, the way the quick ones
        // ride everything: the skitter thickens in the rain — and
        // at every second of the rarest weather the skitter is
        // present: the rarest weather is heard at its bottom, the
        // way it is heard at its surface, where the quick ones'
        // feet are
        for l in stride(from: 0.0, through: 1.0, by: 0.1) {
            #expect(
                ContentView.skitterGain(current: 1, light: l, storm: 1) > ContentView.skitterGain(current: 1, light: l, storm: 0),
                "the quick ones ride the storm, the way the quick ones ride everything"
            )
        }
        // a year of the water's clock: the rarest weather — the
        // sky's dark word over both bodies — and at every one of
        // its seconds the skitter is present; and the skitter's
        // loud corner, the corner the caption counts, is a small
        // part of the year, the way the rare is a small part of
        // the always
        var tripleSeconds = 0
        var skitterMissing = 0
        var loudSeconds = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            let s = ContentView.storm(t)
            guard s > 0.5 else { continue }
            let sk = ContentView.skitterGain(current: ContentView.tide(t).strength, light: ContentView.drawnLight(t), storm: s)
            if sk >= 0.012 { loudSeconds += 1 }
            guard ContentView.deep(t) > 0.5, ContentView.deepTwin(t) > 0.5 else { continue }
            tripleSeconds += 1
            if sk < 0.0025 {
                skitterMissing += 1
            }
        }
        #expect(tripleSeconds > 0 && tripleSeconds < 100, "the rarest weather is a matter of seconds in a year")
        #expect(
            skitterMissing == 0,
            "at every second of the rarest weather the quick ones' skitter is present, the way the rarest weather is heard at its surface"
        )
        #expect(loudSeconds > 5_000, "the skitter's loud corner comes: the night, the flood, and the storm's stirring")
        #expect(loudSeconds < 1_000_000, "the loud corner is a small part of the water's year, the way the rare is a small part of the always")
    }

    @Test func theQuickOnesDoNotReadTheHush() {
        // the hush is the body's taking-away, on the water's own
        // voice only: the murmur thins where the body is, the way
        // the water's own words thin — but the quick ones'
        // skitter is not the water's voice: the quick ones skim
        // over what the water keeps thin, the way the quick ones
        // keep their own. Over a year of the water's clock the
        // body's hush is there, and at every one of its seconds
        // the quick ones' skitter is at its floor — the hush
        // takes from the water's own voice, and never from the
        // quick ones'
        var hushSeconds = 0
        var skitterKeepsItsFloor = 0
        for i in stride(from: 0, to: 31_536_000, by: 1) {
            let t = Double(i)
            guard ContentView.hushGain(deep: ContentView.deep(t), twin: ContentView.deepTwin(t), t: t) > 0.05 else { continue }
            hushSeconds += 1
            let sk = ContentView.skitterGain(
                current: ContentView.tide(t).strength,
                light: ContentView.drawnLight(t),
                storm: ContentView.storm(t)
            )
            if sk >= 0.0025 {
                skitterKeepsItsFloor += 1
            }
        }
        #expect(hushSeconds > 50_000, "the water does hush: a small part of the water's year, on the bodies' own rarity")
        #expect(
            skitterKeepsItsFloor == hushSeconds,
            "the quick ones' skitter keeps its own pace through the hush, the way the quick ones do not read the hush"
        )
    }

}
