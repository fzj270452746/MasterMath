
import UIKit

class ParticleEffectView: UIView {
    
    private let emitterLayer = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmitter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEmitter()
    }
    
    private func setupEmitter() {
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitterLayer.emitterShape = .circle
        emitterLayer.emitterSize = CGSize(width: 50, height: 50)
        layer.addSublayer(emitterLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    func showSuccessEffect() {
        let particle = createParticleCell(color: .systemYellow)
        emitterLayer.emitterCells = [particle]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.stopEffect()
        }
    }
    
    func showFirework(at position: CGPoint) {
        emitterLayer.emitterPosition = position
        
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple]
        let particles = colors.map { createParticleCell(color: $0) }
        
        emitterLayer.emitterCells = particles
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.stopEffect()
        }
    }
    
    private func createParticleCell(color: UIColor) -> CAEmitterCell {
        let particle = CAEmitterCell()
        
        particle.contents = createParticleImage(color: color).cgImage
        particle.birthRate = 10
        particle.lifetime = 2.0
        particle.lifetimeRange = 0.5
        particle.velocity = 100
        particle.velocityRange = 50
        particle.emissionRange = .pi * 2
        particle.spin = 2
        particle.spinRange = 3
        particle.scaleRange = 0.5
        particle.scaleSpeed = -0.5
        particle.alphaSpeed = -0.5
        
        return particle
    }
    
    private func createParticleImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func stopEffect() {
        emitterLayer.birthRate = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}

// Extension for UIViewController
extension UIViewController {
    func showParticleEffect(at position: CGPoint? = nil) {
        let effectView = ParticleEffectView(frame: view.bounds)
        effectView.backgroundColor = .clear
        view.addSubview(effectView)
        
        if let position = position {
            effectView.showFirework(at: position)
        } else {
            effectView.showSuccessEffect()
        }
    }
}
