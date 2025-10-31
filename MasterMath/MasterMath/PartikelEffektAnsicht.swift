//
//  PartikelEffektAnsicht.swift
//  MasterMath
//
//  Partikel-Effekt Ansicht (Particle Effect View)
//

import UIKit

class PartikelEffektAnsicht: UIView {
    
    private let emitterSchicht = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        einrichteEmitter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        einrichteEmitter()
    }
    
    private func einrichteEmitter() {
        emitterSchicht.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitterSchicht.emitterShape = .circle
        emitterSchicht.emitterSize = CGSize(width: 50, height: 50)
        layer.addSublayer(emitterSchicht)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterSchicht.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    func zeigeErfolgEffekt() {
        let partikel = erstellePartikelZelle(farbe: .systemYellow)
        emitterSchicht.emitterCells = [partikel]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.stoppeEffekt()
        }
    }
    
    func zeigeFeuerwerk(an position: CGPoint) {
        emitterSchicht.emitterPosition = position
        
        let farben: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple]
        let partikel = farben.map { erstellePartikelZelle(farbe: $0) }
        
        emitterSchicht.emitterCells = partikel
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.stoppeEffekt()
        }
    }
    
    private func erstellePartikelZelle(farbe: UIColor) -> CAEmitterCell {
        let partikel = CAEmitterCell()
        
        partikel.contents = erstellePartikelBild(farbe: farbe).cgImage
        partikel.birthRate = 10
        partikel.lifetime = 2.0
        partikel.lifetimeRange = 0.5
        partikel.velocity = 100
        partikel.velocityRange = 50
        partikel.emissionRange = .pi * 2
        partikel.spin = 2
        partikel.spinRange = 3
        partikel.scaleRange = 0.5
        partikel.scaleSpeed = -0.5
        partikel.alphaSpeed = -0.5
        
        return partikel
    }
    
    private func erstellePartikelBild(farbe: UIColor) -> UIImage {
        let groesse = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: groesse)
        
        return renderer.image { context in
            farbe.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: groesse))
        }
    }
    
    private func stoppeEffekt() {
        emitterSchicht.birthRate = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}

// Erweiterung für UIViewController
extension UIViewController {
    func zeigePartikelEffekt(an position: CGPoint? = nil) {
        let effektAnsicht = PartikelEffektAnsicht(frame: view.bounds)
        effektAnsicht.backgroundColor = .clear
        view.addSubview(effektAnsicht)
        
        if let position = position {
            effektAnsicht.zeigeFeuerwerk(an: position)
        } else {
            effektAnsicht.zeigeErfolgEffekt()
        }
    }
}


