import SpriteKit

// MARK: - Special Mechanics
enum SpecialMechanic: String, Codable {
    case none
    case lightWind           // Mars: light dust wind
    case denseAtmosphere     // Titan: higher damping
    case iceSurface          // Europa: low friction platform
    case movingPlatform      // Earth: moving barge
    case heavyTurbulence     // Venus: variable wind
    case heatShimmer         // Mercury: visual effect
    case deepCraters         // Ganymede: deep terrain
    case volcanicEruptions   // Io: volcanic particles
    case extremeWind         // Jupiter: extreme wind gusts

    var displayName: String {
        switch self {
        case .none: return "None"
        case .lightWind: return "Light Wind"
        case .denseAtmosphere: return "Dense Atmosphere"
        case .iceSurface: return "Ice Surface"
        case .movingPlatform: return "Moving Platform"
        case .heavyTurbulence: return "Vertical Updrafts"
        case .heatShimmer: return "Heat Shimmer"
        case .deepCraters: return "Deep Craters"
        case .volcanicEruptions: return "Volcanic Eruptions"
        case .extremeWind: return "Extreme Wind"
        }
    }
}

// MARK: - Celestial Body
struct CelestialBody {
    let name: String
    let radius: CGFloat
    let color: SKColor
    let hasRings: Bool
    let craterCount: Int

    static let moon = CelestialBody(name: "Moon", radius: 40, color: SKColor(red: 0.85, green: 0.85, blue: 0.8, alpha: 1.0), hasRings: false, craterCount: 5)
    static let mars = CelestialBody(name: "Mars", radius: 45, color: SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0), hasRings: false, craterCount: 3)
    static let titan = CelestialBody(name: "Saturn", radius: 50, color: SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0), hasRings: true, craterCount: 0)
    static let europa = CelestialBody(name: "Jupiter", radius: 55, color: SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)
    static let earth = CelestialBody(name: "Earth", radius: 50, color: SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0), hasRings: false, craterCount: 0)
    static let venus = CelestialBody(name: "Venus", radius: 48, color: SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0), hasRings: false, craterCount: 0)
    static let mercury = CelestialBody(name: "Mercury", radius: 35, color: SKColor(red: 0.6, green: 0.6, blue: 0.55, alpha: 1.0), hasRings: false, craterCount: 8)
    static let ganymede = CelestialBody(name: "Jupiter", radius: 55, color: SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)
    static let io = CelestialBody(name: "Jupiter", radius: 55, color: SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)
    static let jupiter = CelestialBody(name: "Jupiter", radius: 60, color: SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)
}

// MARK: - Level Definition
struct LevelDefinition {
    let id: Int
    let name: String
    let gravity: CGFloat
    let thrustPower: CGFloat      // Per-level thrust (velocity delta per frame)
    let skyColorTop: SKColor
    let skyColorBottom: SKColor
    let terrainColor: SKColor
    let terrainStrokeColor: SKColor
    let celestialBody: CelestialBody
    let specialMechanic: SpecialMechanic
    let description: String

    // MARK: - All 10 Levels
    static let levels: [LevelDefinition] = [
        // Level 1: Moon — floaty, gentle (ratio 5.0x)
        LevelDefinition(
            id: 1, name: "Moon",
            gravity: -1.6, thrustPower: 8.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0),
            terrainColor: SKColor(red: 0.6, green: 0.6, blue: 0.55, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.7, green: 0.7, blue: 0.65, alpha: 1.0),
            celestialBody: .earth,
            specialMechanic: .none,
            description: "Low gravity training. No hazards."
        ),
        // Level 2: Mars — light wind adds challenge (ratio 4.75x)
        LevelDefinition(
            id: 2, name: "Mars",
            gravity: -2.0, thrustPower: 9.5,
            skyColorTop: SKColor(red: 0.15, green: 0.05, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0),
            terrainColor: SKColor(red: 0.6, green: 0.25, blue: 0.15, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.7, green: 0.35, blue: 0.2, alpha: 1.0),
            celestialBody: .mars,
            specialMechanic: .lightWind,
            description: "Light dust winds push your craft."
        ),
        // Level 3: Titan — dense atmo damping helps (ratio 4.5x)
        LevelDefinition(
            id: 3, name: "Titan",
            gravity: -2.2, thrustPower: 10.0,
            skyColorTop: SKColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.4, green: 0.35, blue: 0.2, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.5, green: 0.45, blue: 0.3, alpha: 1.0),
            celestialBody: .titan,
            specialMechanic: .denseAtmosphere,
            description: "Dense atmosphere increases drag."
        ),
        // Level 4: Europa — ice makes landing tricky (ratio 4.4x)
        LevelDefinition(
            id: 4, name: "Europa",
            gravity: -2.5, thrustPower: 11.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.1, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0),
            terrainColor: SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0),
            celestialBody: .europa,
            specialMechanic: .iceSurface,
            description: "Ice surface — low friction landing."
        ),
        // Level 5: Earth — familiar feel like classic (ratio 4.3x)
        LevelDefinition(
            id: 5, name: "Earth",
            gravity: -2.8, thrustPower: 12.0,
            skyColorTop: SKColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
            terrainColor: SKColor(red: 0.2, green: 0.35, blue: 0.5, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.25, green: 0.4, blue: 0.55, alpha: 1.0),
            celestialBody: .moon,
            specialMechanic: .movingPlatform,
            description: "Barge landing — platform moves!"
        ),
        // Level 6: Venus — heavier, turbulence adds chaos (ratio 4.1x)
        LevelDefinition(
            id: 6, name: "Venus",
            gravity: -3.2, thrustPower: 13.0,
            skyColorTop: SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.5, green: 0.4, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.6, green: 0.5, blue: 0.35, alpha: 1.0),
            celestialBody: .venus,
            specialMechanic: .heavyTurbulence,
            description: "Vertical updrafts disrupt your descent."
        ),
        // Level 7: Mercury — strong gravity, heat shimmer (ratio 4.0x)
        LevelDefinition(
            id: 7, name: "Mercury",
            gravity: -3.5, thrustPower: 14.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.08, blue: 0.05, alpha: 1.0),
            terrainColor: SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 1.0),
            celestialBody: .mercury,
            specialMechanic: .heatShimmer,
            description: "Heat shimmer disrupts thrust control."
        ),
        // Level 8: Ganymede — craters demand precision (ratio 3.9x)
        LevelDefinition(
            id: 8, name: "Ganymede",
            gravity: -3.8, thrustPower: 15.0,
            skyColorTop: SKColor(red: 0.0, green: 0.02, blue: 0.08, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0),
            celestialBody: .ganymede,
            specialMechanic: .deepCraters,
            description: "Deep craters make terrain deadly."
        ),
        // Level 9: Io — volcanic hazards, heavy gravity (ratio 3.9x)
        LevelDefinition(
            id: 9, name: "Io",
            gravity: -4.2, thrustPower: 16.5,
            skyColorTop: SKColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.3, green: 0.2, blue: 0.05, alpha: 1.0),
            terrainColor: SKColor(red: 0.7, green: 0.6, blue: 0.2, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0),
            celestialBody: .io,
            specialMechanic: .volcanicEruptions,
            description: "Volcanic debris is deadly — time it."
        ),
        // Level 10: Jupiter — extreme gravity + wind (ratio 3.8x)
        LevelDefinition(
            id: 10, name: "Jupiter",
            gravity: -4.8, thrustPower: 18.5,
            skyColorTop: SKColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.5, green: 0.4, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0),
            celestialBody: .jupiter,
            specialMechanic: .extremeWind,
            description: "Sudden gusts between calm windows."
        ),
    ]

    static func level(for id: Int) -> LevelDefinition? {
        return levels.first { $0.id == id }
    }
}
