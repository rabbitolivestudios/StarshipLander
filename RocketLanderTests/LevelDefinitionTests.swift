import XCTest
@testable import RocketLander

final class LevelDefinitionTests: XCTestCase {

    func testLevelCount() {
        XCTAssertEqual(LevelDefinition.levels.count, 10)
    }

    func testLevelIdsSequential() {
        let ids = LevelDefinition.levels.map { $0.id }
        XCTAssertEqual(ids, Array(1...10))
    }

    func testGravityIncreasing() {
        let gravities = LevelDefinition.levels.map { abs($0.gravity) }
        for i in 1..<gravities.count {
            XCTAssertGreaterThan(gravities[i], gravities[i - 1],
                "Level \(i + 1) gravity should exceed level \(i)")
        }
    }

    func testThrustIncreasing() {
        let thrusts = LevelDefinition.levels.map { $0.thrustPower }
        for i in 1..<thrusts.count {
            XCTAssertGreaterThan(thrusts[i], thrusts[i - 1],
                "Level \(i + 1) thrust should exceed level \(i)")
        }
    }

    func testThrustGravityRatio() {
        for level in LevelDefinition.levels {
            let ratio = level.thrustPower / abs(level.gravity)
            XCTAssertGreaterThan(ratio, 3.0,
                "\(level.name) thrust/gravity ratio \(ratio) should be > 3.0 (landable)")
        }
    }

    func testLevelLookup() {
        let earth = LevelDefinition.level(for: 5)
        XCTAssertNotNil(earth)
        XCTAssertEqual(earth?.name, "Earth")
    }

    func testInvalidLookup() {
        XCTAssertNil(LevelDefinition.level(for: 0))
        XCTAssertNil(LevelDefinition.level(for: 11))
    }

    func testEachLevelHasMechanic() {
        let expectedMechanics: [Int: SpecialMechanic] = [
            1: .none,
            2: .lightWind,
            3: .denseAtmosphere,
            4: .cryogeysers,
            5: .movingPlatform,
            6: .heavyTurbulence,
            7: .heatShimmer,
            8: .deepCraters,
            9: .volcanicEruptions,
            10: .extremeWind,
        ]

        for (levelId, expectedMechanic) in expectedMechanics {
            let level = LevelDefinition.level(for: levelId)
            XCTAssertEqual(level?.specialMechanic, expectedMechanic,
                "Level \(levelId) should have mechanic \(expectedMechanic)")
        }
    }
}
