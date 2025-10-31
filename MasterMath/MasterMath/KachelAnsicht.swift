//
//  KachelAnsicht.swift
//  MasterMath
//
//  Mahjong-Kachel Ansicht (Mahjong Tile View)
//

import UIKit

class KachelAnsicht: UIView {
    
    private let bildAnsicht = UIImageView()
    private let auswahlUeberlagung = UIView()
    private let wertLabel = UILabel()
    
    var kachel: MahjongKachel? {
        didSet {
            aktualiesiereAnsicht()
        }
    }
    
    var istAusgewaehlt: Bool = false {
        didSet {
            auswahlUeberlagung.isHidden = !istAusgewaehlt
            if istAusgewaehlt {
                animiereAuswahl()
            }
        }
    }
    
    var kachelAngetippt: ((KachelAnsicht) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        einrichteAnsicht()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        einrichteAnsicht()
    }
    
    private func einrichteAnsicht() {
        // Hintergrund - 透明背景，无容器
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        
        // Bild
        bildAnsicht.contentMode = .scaleAspectFit
        bildAnsicht.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bildAnsicht)
        
        // Wert Label
        wertLabel.textAlignment = .center
        wertLabel.font = UIFont.boldSystemFont(ofSize: 32)
        wertLabel.textColor = .black
        wertLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wertLabel)
        
        // Auswahl-Overlay - 只有边框，无背景和圆角
        auswahlUeberlagung.backgroundColor = .clear
        auswahlUeberlagung.layer.borderWidth = 4
        auswahlUeberlagung.layer.borderColor = UIColor.systemYellow.cgColor
        auswahlUeberlagung.isHidden = true
        auswahlUeberlagung.translatesAutoresizingMaskIntoConstraints = false
        addSubview(auswahlUeberlagung)
        
        // Constraints
        NSLayoutConstraint.activate([
            bildAnsicht.topAnchor.constraint(equalTo: topAnchor),
            bildAnsicht.leadingAnchor.constraint(equalTo: leadingAnchor),
            bildAnsicht.trailingAnchor.constraint(equalTo: trailingAnchor),
            bildAnsicht.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            wertLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            wertLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            auswahlUeberlagung.topAnchor.constraint(equalTo: topAnchor),
            auswahlUeberlagung.leadingAnchor.constraint(equalTo: leadingAnchor),
            auswahlUeberlagung.trailingAnchor.constraint(equalTo: trailingAnchor),
            auswahlUeberlagung.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(kachelWurdeAngetippt))
        addGestureRecognizer(tapGesture)
    }
    
    private func aktualiesiereAnsicht() {
        guard let kachel = kachel else { return }
        
        // Versuche Bild zu laden, ansonsten zeige Wert
        if let bild = UIImage(named: kachel.bildName) {
            bildAnsicht.image = bild
            wertLabel.isHidden = true
        } else {
            // Fallback: Zeige Wert mit farbigem Hintergrund
            bildAnsicht.image = nil
            wertLabel.text = "\(kachel.wert)"
            wertLabel.isHidden = false
            
            // Setze Hintergrundfarbe basierend auf Farbe
            switch kachel.farbe {
            case .freun:
                backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                wertLabel.textColor = .systemRed
            case .joirars:
                backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                wertLabel.textColor = .systemBlue
            case .sortie:
                backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                wertLabel.textColor = .systemGreen
            }
        }
    }
    
    @objc private func kachelWurdeAngetippt() {
        kachelAngetippt?(self)
    }
    
    private func animiereAuswahl() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}
