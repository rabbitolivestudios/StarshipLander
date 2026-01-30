import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    private var lastThrustHaptic: TimeInterval = 0
    private let thrustInterval: TimeInterval = 0.1 // 100ms between thrust pulses

    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    // MARK: - Thrust Haptic (continuous light pulse)
    func thrustPulse() {
        let now = CACurrentMediaTime()
        guard now - lastThrustHaptic >= thrustInterval else { return }
        lastThrustHaptic = now
        lightImpact.impactOccurred()
    }

    // MARK: - Rotation Haptic (medium impact on start)
    func rotationStart() {
        mediumImpact.impactOccurred()
    }

    // MARK: - Landing Success Haptic
    func landingSuccess() {
        notification.notificationOccurred(.success)
    }

    // MARK: - Crash Haptic (heavy double-tap)
    func crash() {
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.heavyImpact.impactOccurred()
        }
    }
}
