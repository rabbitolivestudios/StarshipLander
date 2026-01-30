import SpriteKit

// MARK: - Sound Methods
extension GameScene {

    func startThrustSound() {
        guard !isThrustSoundPlaying else { return }

        if let url = Bundle.main.url(forResource: "thrust", withExtension: "wav") {
            thrustSound = SKAudioNode(url: url)
            if let sound = thrustSound {
                sound.autoplayLooped = true
                addChild(sound)
                sound.run(SKAction.sequence([
                    SKAction.changeVolume(to: 0.5, duration: 0),
                    SKAction.play()
                ]))
                isThrustSoundPlaying = true
            }
        }
    }

    func stopThrustSound() {
        if let sound = thrustSound {
            sound.run(SKAction.stop())
            sound.removeFromParent()
        }
        thrustSound = nil
        isThrustSoundPlaying = false
    }

    func playRotateSound() {
        run(SKAction.playSoundFileNamed("rotate.wav", waitForCompletion: false))
    }

    func playSuccessSound() {
        run(SKAction.playSoundFileNamed("land_success.wav", waitForCompletion: false))
    }

    func playExplosionSound() {
        run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
    }
}
