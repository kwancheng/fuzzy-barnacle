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

}
