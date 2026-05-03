import Foundation

// MARK: - Challenge Constraint
// Each constraint defines one success condition for a daily challenge.

enum ChallengeConstraint: Equatable {
    case landOnPlatform(LandingPlatform)
    case maxTilt(degrees: Double)
    case maxVerticalSpeed(CGFloat)
    case maxHorizontalSpeed(CGFloat)
    case minFuel(percent: Double)
    case maxTime(seconds: Int)

    /// Icon for display in briefing/results
    var icon: String {
        switch self {
        case .landOnPlatform: return "scope"
        case .maxTilt: return "rotate.right"
        case .maxVerticalSpeed: return "arrow.down"
        case .maxHorizontalSpeed: return "arrow.left.arrow.right"
        case .minFuel: return "fuelpump.fill"
        case .maxTime: return "timer"
        }
    }

    /// Human-readable label for briefing screen
    var label: String {
        switch self {
        case .landOnPlatform(let p):
            return "Land on Platform \(p.rawValue)"
        case .maxTilt(let deg):
            return "Tilt < \(String(format: "%.0f", deg))\u{00B0}"
        case .maxVerticalSpeed(let v):
            return "V.Speed < \(String(format: "%.0f", v))"
        case .maxHorizontalSpeed(let h):
            return "H.Speed < \(String(format: "%.0f", h))"
        case .minFuel(let pct):
            return "Fuel > \(String(format: "%.0f", pct))%"
        case .maxTime(let sec):
            return "Time < \(sec)s"
        }
    }

    /// Evaluate whether this constraint was met
    func isMet(platform: LandingPlatform, tiltRadians: CGFloat, verticalSpeed: CGFloat, horizontalSpeed: CGFloat, fuel: Double, elapsedTime: TimeInterval) -> Bool {
        switch self {
        case .landOnPlatform(let target):
            return platform == target
        case .maxTilt(let degrees):
            let actualDegrees = abs(Double(tiltRadians)) * 180.0 / .pi
            return actualDegrees < degrees
        case .maxVerticalSpeed(let maxV):
            return verticalSpeed < maxV
        case .maxHorizontalSpeed(let maxH):
            return horizontalSpeed < maxH
        case .minFuel(let minPct):
            return fuel > minPct
        case .maxTime(let seconds):
            return elapsedTime < Double(seconds)
        }
    }

    /// Format the actual value for results display
    func actualValue(platform: LandingPlatform, tiltRadians: CGFloat, verticalSpeed: CGFloat, horizontalSpeed: CGFloat, fuel: Double, elapsedTime: TimeInterval) -> String {
        switch self {
        case .landOnPlatform:
            return "Platform \(platform.rawValue)"
        case .maxTilt:
            let deg = abs(Double(tiltRadians)) * 180.0 / .pi
            return String(format: "%.1f\u{00B0}", deg)
        case .maxVerticalSpeed:
            return String(format: "%.0f", verticalSpeed)
        case .maxHorizontalSpeed:
            return String(format: "%.0f", horizontalSpeed)
        case .minFuel:
            return String(format: "%.0f%%", fuel)
        case .maxTime:
            return String(format: "%.1fs", elapsedTime)
        }
    }
}

// MARK: - Challenge Spec

struct ChallengeSpec {
    let levelId: Int
    let constraints: [ChallengeConstraint]
    let title: String
    let briefing: String

    var level: LevelDefinition {
        LevelDefinition.levels.first { $0.id == levelId } ?? LevelDefinition.levels[0]
    }

    /// Auto-computed difficulty (1-5 stars) based on objective factors:
    /// - Planet difficulty (gravity, hazards)
    /// - Number of constraints
    /// - Constraint tightness
    /// - Platform requirement
    /// - Time pressure
    var difficulty: Int {
        var score: Double = 0.0

        // 1. Planet difficulty (0.0 - 4.0 points)
        // Moon=1, Mars=2, Titan=3, Europa=4, Earth=5, Venus=6, Mercury=7, Ganymede=8, Io=9, Jupiter=10
        let planetScores: [Int: Double] = [
            1: 0.0,   // Moon — trivial gravity, no hazards
            2: 0.5,   // Mars — light wind
            3: 0.8,   // Titan — dense atmosphere (actually helps dampen)
            4: 1.2,   // Europa — cryogeysers
            5: 1.5,   // Earth — moving platform
            6: 2.0,   // Venus — heavy turbulence
            7: 2.3,   // Mercury — strong gravity + shimmer
            8: 2.7,   // Ganymede — craters + heavy gravity
            9: 3.2,   // Io — volcanic eruptions + heavy gravity
            10: 4.0,  // Jupiter — extreme gravity + extreme wind
        ]
        score += planetScores[levelId] ?? 0.0

        // 2. Number of constraints (0.0 - 2.0 points)
        // 1 constraint = 0, 2 = 0.8, 3 = 1.6
        score += Double(constraints.count - 1) * 0.8

        // 3. Constraint tightness (sum of individual tightness scores)
        for constraint in constraints {
            switch constraint {
            case .landOnPlatform(let p):
                // Platform A (Training) = 0.2, B (Precision) = 0.5, C (Elite) = 1.0
                switch p {
                case .a: score += 0.2
                case .b: score += 0.5
                case .c: score += 1.0
                }
            case .maxTilt(let deg):
                // 3° = easy (0.3), 2.5° = moderate (0.5), 2° = hard (0.8), 1.5° = very hard (1.2)
                if deg >= 3.0 { score += 0.3 }
                else if deg >= 2.5 { score += 0.5 }
                else if deg >= 2.0 { score += 0.8 }
                else { score += 1.2 }
            case .maxVerticalSpeed(let v):
                // 50 = easy (0.2), 45 = mild (0.3), 40 = moderate (0.5), 35 = hard (0.8), 30 = very hard (1.1)
                if v >= 50 { score += 0.2 }
                else if v >= 45 { score += 0.3 }
                else if v >= 40 { score += 0.5 }
                else if v >= 35 { score += 0.8 }
                else { score += 1.1 }
            case .maxHorizontalSpeed(let h):
                // 25 = easy (0.3), 22 = moderate (0.5), 20 = hard (0.7), 18 = very hard (1.0)
                if h >= 25 { score += 0.3 }
                else if h >= 22 { score += 0.5 }
                else if h >= 20 { score += 0.7 }
                else { score += 1.0 }
            case .minFuel(let pct):
                // 20% = easy (0.2), 25% = mild (0.3), 30% = moderate (0.5), 35% = hard (0.7), 40%+ = very hard (0.9)
                if pct <= 20 { score += 0.2 }
                else if pct <= 25 { score += 0.3 }
                else if pct <= 30 { score += 0.5 }
                else if pct <= 35 { score += 0.7 }
                else if pct <= 40 { score += 0.9 }
                else { score += 1.1 }
            case .maxTime(let sec):
                // Base: 25s = 0.3, 22s = 0.5, 20s = 0.7, 18s = 1.0, 16s = 1.3
                // Reduced on easy planets where time is less pressured (low gravity = easier to maneuver quickly)
                var timeScore: Double
                if sec >= 25 { timeScore = 0.3 }
                else if sec >= 22 { timeScore = 0.5 }
                else if sec >= 20 { timeScore = 0.7 }
                else if sec >= 18 { timeScore = 1.0 }
                else { timeScore = 1.3 }
                // Easy planets (Moon/Mars/Titan): time is less pressured, reduce score
                if levelId <= 2 { timeScore *= 0.5 }
                else if levelId <= 3 { timeScore *= 0.7 }
                score += timeScore
            }
        }

        // Map cumulative score to 1-5 stars
        // Thresholds tuned for balanced distribution across 75 templates:
        // 0.0 - 1.0 = 1 star (very easy — Moon/Mars single easy constraint)
        // 1.0 - 2.2 = 2 stars (easy)
        // 2.2 - 3.8 = 3 stars (moderate)
        // 3.8 - 5.5 = 4 stars (hard)
        // 5.5+       = 5 stars (expert)
        if score < 1.0 { return 1 }
        if score < 2.2 { return 2 }
        if score < 3.8 { return 3 }
        if score < 5.5 { return 4 }
        return 5
    }
}

// MARK: - Daily Challenge
// Deterministic daily challenge that cycles through 75 templates.
// All players worldwide get the same challenge each day (~2.5-month cycle).

struct DailyChallenge {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    /// Day-of-year seed (1-366). Deterministic for any given date.
    static var dayOfYear: Int {
        calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }

    /// Today's challenge spec, deterministically selected from the template pool.
    static var today: ChallengeSpec {
        let index = dayOfYear % templates.count
        return templates[index]
    }

    /// Level ID for today's challenge.
    static var levelId: Int { today.levelId }

    /// Level definition for today's challenge.
    static var level: LevelDefinition { today.level }

    /// Human-readable challenge title.
    static var displayTitle: String {
        "\(today.title) — \(today.level.name)"
    }

    /// The time limit for today's challenge in seconds (first maxTime constraint, or nil).
    static var timeLimitSeconds: Int? {
        for constraint in today.constraints {
            if case .maxTime(let seconds) = constraint { return seconds }
        }
        return nil
    }

    /// The target platform for today's challenge (first landOnPlatform constraint, or nil).
    static var targetPlatform: LandingPlatform? {
        for constraint in today.constraints {
            if case .landOnPlatform(let p) = constraint { return p }
        }
        return nil
    }

    // MARK: - Evaluation

    /// Evaluate all constraints for today's challenge. Returns true if ALL pass.
    static func evaluate(platform: LandingPlatform, tiltRadians: CGFloat, verticalSpeed: CGFloat, horizontalSpeed: CGFloat, fuel: Double, elapsedTime: TimeInterval) -> Bool {
        let spec = today
        return spec.constraints.allSatisfy { constraint in
            constraint.isMet(platform: platform, tiltRadians: tiltRadians, verticalSpeed: verticalSpeed, horizontalSpeed: horizontalSpeed, fuel: fuel, elapsedTime: elapsedTime)
        }
    }

    /// Evaluate each constraint individually. Returns array of (constraint, passed, actual) tuples.
    static func evaluateDetailed(platform: LandingPlatform, tiltRadians: CGFloat, verticalSpeed: CGFloat, horizontalSpeed: CGFloat, fuel: Double, elapsedTime: TimeInterval) -> [(constraint: ChallengeConstraint, passed: Bool, actual: String)] {
        let spec = today
        return spec.constraints.map { constraint in
            let passed = constraint.isMet(platform: platform, tiltRadians: tiltRadians, verticalSpeed: verticalSpeed, horizontalSpeed: horizontalSpeed, fuel: fuel, elapsedTime: elapsedTime)
            let actual = constraint.actualValue(platform: platform, tiltRadians: tiltRadians, verticalSpeed: verticalSpeed, horizontalSpeed: horizontalSpeed, fuel: fuel, elapsedTime: elapsedTime)
            return (constraint, passed, actual)
        }
    }

    // MARK: - UserDefaults Persistence

    private static var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        return "daily_\(formatter.string(from: Date()))"
    }

    /// Best score for today's challenge, or nil if not yet attempted.
    static var localBestScore: Int? {
        let score = UserDefaults.standard.integer(forKey: todayKey)
        return score > 0 ? score : nil
    }

    /// Player name associated with today's best score, or nil.
    static var localBestName: String? {
        UserDefaults.standard.string(forKey: "\(todayKey)_name")
    }

    /// Whether today's challenge has been completed (all constraints met).
    static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: "\(todayKey)_completed")
    }

    /// Record a score for today's challenge. Saves if better than current best.
    static func recordScore(_ score: Int, success: Bool, playerName: String? = nil) {
        let current = UserDefaults.standard.integer(forKey: todayKey)
        if score > current {
            UserDefaults.standard.set(score, forKey: todayKey)
            if let name = playerName, !name.isEmpty {
                UserDefaults.standard.set(name, forKey: "\(todayKey)_name")
            }
        } else if score == current, let name = playerName, !name.isEmpty {
            UserDefaults.standard.set(name, forKey: "\(todayKey)_name")
        }
        if success {
            UserDefaults.standard.set(true, forKey: "\(todayKey)_completed")
        }
    }

    // MARK: - Challenge Templates (75 rotating daily challenges)
    // Deterministic cycle: dayOfYear % 75 — repeats every ~2.5 months.
    // Difficulty is auto-computed by ChallengeSpec.difficulty based on planet, constraints, and tightness.
    // Levels: 1=Moon, 2=Mars, 3=Titan, 4=Europa, 5=Earth, 6=Venus, 7=Mercury, 8=Ganymede, 9=Io, 10=Jupiter

    static let templates: [ChallengeSpec] = [

        // --- Easy planets, simple constraints ---

        ChallengeSpec(levelId: 1, constraints: [.landOnPlatform(.b)],
            title: "Target Practice", briefing: "Land on the Precision Target on the Moon."),
        ChallengeSpec(levelId: 1, constraints: [.maxVerticalSpeed(50)],
            title: "Easy Does It", briefing: "Land gently on the Moon — keep it smooth."),
        ChallengeSpec(levelId: 1, constraints: [.maxTilt(degrees: 3)],
            title: "Stay Level", briefing: "Keep your tilt under 3 degrees on the Moon."),
        ChallengeSpec(levelId: 2, constraints: [.maxHorizontalSpeed(25)],
            title: "Steady Approach", briefing: "Land on Mars with minimal sideways drift."),
        ChallengeSpec(levelId: 1, constraints: [.minFuel(percent: 40)],
            title: "Fuel Saver", briefing: "Land on the Moon with at least 40% fuel remaining."),

        // --- Easy-moderate planets, tighter constraints ---

        ChallengeSpec(levelId: 2, constraints: [.maxVerticalSpeed(45)],
            title: "Feather Touch", briefing: "Land gently on Mars — keep your descent speed low."),
        ChallengeSpec(levelId: 3, constraints: [.maxTilt(degrees: 2.5)],
            title: "Steady Hands", briefing: "Land level on Titan — keep your tilt under 2.5 degrees."),
        ChallengeSpec(levelId: 1, constraints: [.minFuel(percent: 50)],
            title: "Fuel Miser", briefing: "Land on the Moon with over half your fuel remaining."),
        ChallengeSpec(levelId: 1, constraints: [.maxTime(seconds: 15), .landOnPlatform(.a)],
            title: "Speed Run", briefing: "Race to the Training Zone on the Moon in under 15 seconds."),
        ChallengeSpec(levelId: 2, constraints: [.maxHorizontalSpeed(18)],
            title: "Zero Drift", briefing: "Land on Mars with minimal horizontal drift."),
        ChallengeSpec(levelId: 2, constraints: [.maxTime(seconds: 20)],
            title: "Quick Drop", briefing: "Touch down on Mars in under 20 seconds — any platform."),
        ChallengeSpec(levelId: 3, constraints: [.landOnPlatform(.b)],
            title: "Titan Target", briefing: "Hit the Precision Target on Titan through the thick atmosphere."),
        ChallengeSpec(levelId: 1, constraints: [.landOnPlatform(.c)],
            title: "Moon Elite", briefing: "Aim for the Elite Landing pad on the Moon."),
        ChallengeSpec(levelId: 2, constraints: [.maxVerticalSpeed(40), .maxTilt(degrees: 3)],
            title: "Smooth Operator", briefing: "Land on Mars both gently and level."),
        ChallengeSpec(levelId: 3, constraints: [.minFuel(percent: 45)],
            title: "Dense Efficiency", briefing: "Save fuel while fighting Titan's dense atmosphere."),

        // --- Mid planets, multi-constraint ---

        ChallengeSpec(levelId: 4, constraints: [.landOnPlatform(.c)],
            title: "Precision Descent", briefing: "Navigate Europa's cryogeysers to the Elite Landing pad."),
        ChallengeSpec(levelId: 5, constraints: [.maxVerticalSpeed(35), .maxHorizontalSpeed(25)],
            title: "Whisper Landing", briefing: "Touch down on Earth's moving barge with minimal speed."),
        ChallengeSpec(levelId: 6, constraints: [.minFuel(percent: 40)],
            title: "Fuel Master", briefing: "Fight Venus turbulence and still conserve your fuel."),
        ChallengeSpec(levelId: 7, constraints: [.landOnPlatform(.b)],
            title: "Razor's Edge", briefing: "Hit Mercury's Precision Target through the heat shimmer."),
        ChallengeSpec(levelId: 4, constraints: [.maxTime(seconds: 22), .landOnPlatform(.b)],
            title: "Lightning Strike", briefing: "Dodge cryogeysers and hit Europa Platform B in under 22 seconds."),
        ChallengeSpec(levelId: 3, constraints: [.maxVerticalSpeed(40), .minFuel(percent: 35)],
            title: "Hover Expert", briefing: "Land softly on Titan while keeping fuel above 35%."),
        ChallengeSpec(levelId: 5, constraints: [.maxTime(seconds: 18)],
            title: "Speed Demon", briefing: "Catch Earth's moving barge in under 18 seconds."),
        ChallengeSpec(levelId: 4, constraints: [.maxTilt(degrees: 2)],
            title: "Ice Level", briefing: "Stay perfectly level amid Europa's cryogeyser blasts."),
        ChallengeSpec(levelId: 5, constraints: [.landOnPlatform(.b), .maxVerticalSpeed(40)],
            title: "Barge Hunter", briefing: "Track the moving barge and land softly on Platform B."),
        ChallengeSpec(levelId: 6, constraints: [.maxTilt(degrees: 2.5), .maxVerticalSpeed(45)],
            title: "Venus Calm", briefing: "Stay level and descend gently through Venus updrafts."),
        ChallengeSpec(levelId: 7, constraints: [.maxVerticalSpeed(40), .maxHorizontalSpeed(22)],
            title: "Mercury Crawl", briefing: "Land on Mercury with low speed in every direction."),
        ChallengeSpec(levelId: 2, constraints: [.landOnPlatform(.c), .maxTilt(degrees: 2.5)],
            title: "Mars Bullseye", briefing: "Hit the Elite pad on Mars — stay level in the dust."),
        ChallengeSpec(levelId: 4, constraints: [.minFuel(percent: 35), .landOnPlatform(.b)],
            title: "Europa Thrift", briefing: "Land on Platform B on Europa with fuel to spare."),
        ChallengeSpec(levelId: 3, constraints: [.maxTime(seconds: 22)],
            title: "Titan Express", briefing: "Touch down on Titan in under 22 seconds."),
        ChallengeSpec(levelId: 5, constraints: [.minFuel(percent: 40)],
            title: "Efficient Barge", briefing: "Land on Earth's barge with 40% fuel remaining."),
        ChallengeSpec(levelId: 6, constraints: [.landOnPlatform(.b)],
            title: "Venus Target", briefing: "Hit the Precision Target through Venus turbulence."),
        ChallengeSpec(levelId: 7, constraints: [.minFuel(percent: 35)],
            title: "Mercury Reserve", briefing: "Fight Mercury's gravity and conserve 35% fuel."),
        ChallengeSpec(levelId: 1, constraints: [.maxTime(seconds: 18), .landOnPlatform(.c)],
            title: "Moon Sprint", briefing: "Hit the Elite pad on the Moon in under 18 seconds."),
        ChallengeSpec(levelId: 4, constraints: [.maxVerticalSpeed(38), .maxTilt(degrees: 2.5)],
            title: "Geyser Dodge", briefing: "Navigate Europa's ice geysers — land soft and level."),
        ChallengeSpec(levelId: 2, constraints: [.maxTime(seconds: 18), .landOnPlatform(.b)],
            title: "Mars Rush", briefing: "Hit the Precision Target on Mars in under 18 seconds."),
        ChallengeSpec(levelId: 3, constraints: [.landOnPlatform(.c), .minFuel(percent: 30)],
            title: "Titan Elite", briefing: "Land on Titan's Elite pad with 30% fuel to spare."),
        ChallengeSpec(levelId: 5, constraints: [.maxTilt(degrees: 2), .maxHorizontalSpeed(20)],
            title: "Barge Surgeon", briefing: "Land on Earth's barge perfectly level with zero drift."),
        ChallengeSpec(levelId: 7, constraints: [.maxTime(seconds: 20)],
            title: "Mercury Dash", briefing: "Touch down on Mercury in under 20 seconds."),
        ChallengeSpec(levelId: 6, constraints: [.maxVerticalSpeed(42)],
            title: "Venus Feather", briefing: "Land softly on Venus despite the updrafts."),
        ChallengeSpec(levelId: 2, constraints: [.minFuel(percent: 45), .maxVerticalSpeed(42)],
            title: "Mars Balance", briefing: "Balance fuel conservation with a gentle Mars landing."),

        // --- Hard planets, tight constraints ---

        ChallengeSpec(levelId: 8, constraints: [.landOnPlatform(.c), .maxTilt(degrees: 3)],
            title: "Elite Touch", briefing: "Navigate Ganymede's craters to the Elite pad — stay level."),
        ChallengeSpec(levelId: 10, constraints: [.maxVerticalSpeed(50)],
            title: "Gentle Giant", briefing: "Survive Jupiter's extreme wind and land gently."),
        ChallengeSpec(levelId: 9, constraints: [.minFuel(percent: 30)],
            title: "Conservation", briefing: "Dodge Io's volcanic eruptions and save 30% fuel."),
        ChallengeSpec(levelId: 6, constraints: [.maxTilt(degrees: 2), .maxHorizontalSpeed(20)],
            title: "Total Control", briefing: "Master Venus updrafts — stay level and stop drifting."),
        ChallengeSpec(levelId: 8, constraints: [.maxVerticalSpeed(38), .minFuel(percent: 30)],
            title: "Crater Glide", briefing: "Land softly on Ganymede with fuel in reserve."),
        ChallengeSpec(levelId: 9, constraints: [.landOnPlatform(.b), .maxTilt(degrees: 2.5)],
            title: "Io Precision", briefing: "Hit Io's Precision Target — stay level near the volcanoes."),
        ChallengeSpec(levelId: 10, constraints: [.landOnPlatform(.b)],
            title: "Jupiter Target", briefing: "Hit the Precision Target in Jupiter's extreme winds."),
        ChallengeSpec(levelId: 7, constraints: [.landOnPlatform(.c), .maxVerticalSpeed(40)],
            title: "Mercury Elite", briefing: "Land on Mercury's Elite pad — soft touch required."),
        ChallengeSpec(levelId: 8, constraints: [.maxTime(seconds: 20)],
            title: "Crater Sprint", briefing: "Touch down on Ganymede in under 20 seconds."),
        ChallengeSpec(levelId: 9, constraints: [.maxVerticalSpeed(45), .maxHorizontalSpeed(25)],
            title: "Io Whisper", briefing: "Land on Io with minimal speed in every direction."),
        ChallengeSpec(levelId: 6, constraints: [.landOnPlatform(.c), .minFuel(percent: 30)],
            title: "Venus Elite", briefing: "Fight the updrafts to reach Venus Elite pad with fuel."),
        ChallengeSpec(levelId: 10, constraints: [.maxHorizontalSpeed(25)],
            title: "Wind Walker", briefing: "Land on Jupiter with minimal drift despite the gusts."),
        ChallengeSpec(levelId: 8, constraints: [.landOnPlatform(.b), .minFuel(percent: 35)],
            title: "Ganymede Thrift", briefing: "Hit Platform B on Ganymede with 35% fuel remaining."),
        ChallengeSpec(levelId: 9, constraints: [.maxTime(seconds: 20), .landOnPlatform(.a)],
            title: "Io Blitz", briefing: "Race past the eruptions and land on Io in under 20 seconds."),
        ChallengeSpec(levelId: 7, constraints: [.maxTilt(degrees: 1.5), .maxVerticalSpeed(38)],
            title: "Mercury Surgeon", briefing: "Ultra-precise landing on Mercury — near-zero tilt."),
        ChallengeSpec(levelId: 5, constraints: [.landOnPlatform(.c), .maxTime(seconds: 18)],
            title: "Barge Blitz", briefing: "Hit the Elite pad on Earth's moving barge in 18 seconds."),
        ChallengeSpec(levelId: 4, constraints: [.landOnPlatform(.c), .maxVerticalSpeed(35), .minFuel(percent: 25)],
            title: "Europa Triple", briefing: "Elite pad, soft landing, fuel reserve — on Europa."),
        ChallengeSpec(levelId: 6, constraints: [.maxTime(seconds: 18), .maxVerticalSpeed(42)],
            title: "Venus Sprint", briefing: "Land on Venus fast AND soft — fight the updrafts."),
        ChallengeSpec(levelId: 9, constraints: [.landOnPlatform(.c)],
            title: "Volcanic Elite", briefing: "Navigate Io's volcanic eruptions to the Elite pad."),
        ChallengeSpec(levelId: 10, constraints: [.maxTilt(degrees: 3), .minFuel(percent: 20)],
            title: "Jupiter Steady", briefing: "Stay level in Jupiter's extreme wind and save fuel."),

        // --- Expert: hardest planets, multiple tight constraints ---

        ChallengeSpec(levelId: 8, constraints: [.landOnPlatform(.c), .maxVerticalSpeed(35), .maxTilt(degrees: 2)],
            title: "Absolute Precision", briefing: "Elite pad on Ganymede, feather-soft and level."),
        ChallengeSpec(levelId: 10, constraints: [.landOnPlatform(.c), .minFuel(percent: 25)],
            title: "Impossible Landing", briefing: "Elite pad on Jupiter with fuel to spare. Legends only."),
        ChallengeSpec(levelId: 9, constraints: [.landOnPlatform(.c), .maxTilt(degrees: 2), .minFuel(percent: 25)],
            title: "Io Masterclass", briefing: "Elite pad on Io — level, efficient, through volcanic hell."),
        ChallengeSpec(levelId: 10, constraints: [.maxVerticalSpeed(40), .maxHorizontalSpeed(20), .maxTilt(degrees: 2.5)],
            title: "Jupiter Surgeon", briefing: "Total control on Jupiter — soft, still, and level."),
        ChallengeSpec(levelId: 8, constraints: [.landOnPlatform(.c), .maxTime(seconds: 18)],
            title: "Crater Blitz", briefing: "Hit Ganymede's Elite pad in under 18 seconds."),
        ChallengeSpec(levelId: 9, constraints: [.landOnPlatform(.b), .maxVerticalSpeed(38), .maxTime(seconds: 20)],
            title: "Io Rush", briefing: "Platform B on Io — soft and fast through the eruptions."),
        ChallengeSpec(levelId: 10, constraints: [.landOnPlatform(.b), .maxVerticalSpeed(42), .minFuel(percent: 20)],
            title: "Storm Rider", briefing: "Jupiter Platform B — soft landing with fuel to spare."),
        ChallengeSpec(levelId: 7, constraints: [.landOnPlatform(.c), .maxTilt(degrees: 1.5), .maxVerticalSpeed(35)],
            title: "Mercury Perfection", briefing: "Elite pad on Mercury — near-zero tilt, feather touch."),
        ChallengeSpec(levelId: 6, constraints: [.landOnPlatform(.c), .maxTilt(degrees: 2), .minFuel(percent: 30)],
            title: "Venus Mastery", briefing: "Elite pad on Venus — level and efficient through chaos."),
        ChallengeSpec(levelId: 5, constraints: [.landOnPlatform(.c), .maxVerticalSpeed(30), .maxHorizontalSpeed(18)],
            title: "Barge Perfect", briefing: "Elite pad on Earth's barge — absolute minimal speed."),
        ChallengeSpec(levelId: 9, constraints: [.minFuel(percent: 35), .maxVerticalSpeed(40), .maxTilt(degrees: 2)],
            title: "Io Zen", briefing: "Total control on Io — soft, level, with fuel to spare."),
        ChallengeSpec(levelId: 10, constraints: [.maxTime(seconds: 18)],
            title: "Jupiter Express", briefing: "Land on Jupiter in under 18 seconds. Good luck."),
        ChallengeSpec(levelId: 8, constraints: [.landOnPlatform(.c), .minFuel(percent: 30), .maxTilt(degrees: 2)],
            title: "Ganymede Triple", briefing: "Elite pad, fuel saved, perfectly level — on Ganymede."),
        ChallengeSpec(levelId: 6, constraints: [.maxTime(seconds: 16), .landOnPlatform(.b)],
            title: "Venus Lightning", briefing: "Hit Platform B on Venus in 16 seconds through updrafts."),
        ChallengeSpec(levelId: 10, constraints: [.landOnPlatform(.c), .maxVerticalSpeed(40), .maxTilt(degrees: 2)],
            title: "The Final Test", briefing: "Elite pad on Jupiter — soft, level, legendary. The ultimate challenge."),
    ]
}
