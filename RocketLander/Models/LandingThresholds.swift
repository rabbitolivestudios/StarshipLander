import CoreGraphics

// MARK: - Speed Band Classification

enum SpeedBand: Int, Comparable {
    case safe = 0
    case hard = 1
    case fail = 2

    static func < (lhs: SpeedBand, rhs: SpeedBand) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Landing Result

struct LandingResult {
    let success: Bool
    let speedBand: SpeedBand
    let rotationFailed: Bool
}

// MARK: - Platform Speed Bands

struct PlatformBands {
    let safeVertical: CGFloat
    let hardVertical: CGFloat    // FAIL threshold is > hardVertical
    let safeHorizontal: CGFloat
    let hardHorizontal: CGFloat  // FAIL threshold is > hardHorizontal
}

// MARK: - Landing Thresholds (Single Source of Truth)

enum LandingThresholds {

    // Tilt bands — all platforms (safe/hard/fail like speed bands)
    static let safeTilt: CGFloat = 0.05     // ~2.9° — full rotation score
    static let hardTilt: CGFloat = 0.10     // ~5.7° — partial credit, landing succeeds
    // > hardTilt = crash (FAIL)

    // Legacy accessor (used by HUD, crash messages, scoring)
    static let maxRotation: CGFloat = hardTilt

    // Approach speed — scoring/messaging only, NOT a crash gate
    static let approachSpeedScoringThreshold: CGFloat = 80.0

    // Per-platform speed bands (tightened in v2.0.3)
    // A & B: ~15% tighter for more challenge
    // C: ~5% tighter (already the hardest)
    static let platformA = PlatformBands(
        safeVertical: 70, hardVertical: 100,
        safeHorizontal: 50, hardHorizontal: 80
    )

    static let platformB = PlatformBands(
        safeVertical: 50, hardVertical: 75,
        safeHorizontal: 40, hardHorizontal: 60
    )

    static let platformC = PlatformBands(
        safeVertical: 33, hardVertical: 52,
        safeHorizontal: 28, hardHorizontal: 48
    )

    static func bands(for platform: LandingPlatform) -> PlatformBands {
        switch platform {
        case .a: return platformA
        case .b: return platformB
        case .c: return platformC
        }
    }

    // MARK: - Band Classification

    static func verticalBand(_ speed: CGFloat, platform: LandingPlatform) -> SpeedBand {
        let b = bands(for: platform)
        if speed <= b.safeVertical { return .safe }
        if speed <= b.hardVertical { return .hard }
        return .fail
    }

    static func horizontalBand(_ speed: CGFloat, platform: LandingPlatform) -> SpeedBand {
        let b = bands(for: platform)
        if speed <= b.safeHorizontal { return .safe }
        if speed <= b.hardHorizontal { return .hard }
        return .fail
    }

    // MARK: - Tilt Band Classification

    static func tiltBand(_ rotation: CGFloat) -> SpeedBand {
        if rotation <= safeTilt { return .safe }
        if rotation <= hardTilt { return .hard }
        return .fail
    }

    // MARK: - Pure Landing Evaluation

    static func evaluate(
        verticalSpeed: CGFloat,
        horizontalSpeed: CGFloat,
        rotation: CGFloat,
        platform: LandingPlatform
    ) -> LandingResult {
        let tBand = tiltBand(rotation)
        let rotationFailed = tBand == .fail

        let vBand = verticalBand(verticalSpeed, platform: platform)
        let hBand = horizontalBand(horizontalSpeed, platform: platform)

        // Worst band wins (higher = worse)
        let overallBand = max(vBand, max(hBand, tBand))

        if rotationFailed || overallBand == .fail {
            return LandingResult(
                success: false,
                speedBand: overallBand,
                rotationFailed: rotationFailed
            )
        }

        return LandingResult(
            success: true,
            speedBand: overallBand,
            rotationFailed: false
        )
    }
}
