

import UIKit

class BenutzerdefinierteDialogansicht: UIView {
    
    private let containerAnsicht = UIView()
    private let titelLabel = UILabel()
    private let nachrichtLabel = UILabel()
    private let schaltflaechenStapelAnsicht = UIStackView()
    
    var schaltflaechenAktion: ((Int) -> Void)?
    
    init(titel: String, nachricht: String, schaltflaechenTitel: [String]) {
        super.init(frame: .zero)
        einrichteAnsicht(titel: titel, nachricht: nachricht, schaltflaechenTitel: schaltflaechenTitel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func einrichteAnsicht(titel: String, nachricht: String, schaltflaechenTitel: [String]) {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Container
        containerAnsicht.backgroundColor = .white
        containerAnsicht.layer.cornerRadius = 20
        containerAnsicht.layer.shadowColor = UIColor.black.cgColor
        containerAnsicht.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerAnsicht.layer.shadowRadius = 20
        containerAnsicht.layer.shadowOpacity = 0.3
        containerAnsicht.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerAnsicht)
        
        // Titel
        titelLabel.text = titel
        titelLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titelLabel.textAlignment = .center
        titelLabel.textColor = .black
        titelLabel.numberOfLines = 0
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        containerAnsicht.addSubview(titelLabel)
        
        // Nachricht
        nachrichtLabel.text = nachricht
        nachrichtLabel.font = UIFont.systemFont(ofSize: 18)
        nachrichtLabel.textAlignment = .center
        nachrichtLabel.textColor = .darkGray
        nachrichtLabel.numberOfLines = 0
        nachrichtLabel.translatesAutoresizingMaskIntoConstraints = false
        containerAnsicht.addSubview(nachrichtLabel)
        
        // Schaltflächen
        schaltflaechenStapelAnsicht.axis = .horizontal
        schaltflaechenStapelAnsicht.distribution = .fillEqually
        schaltflaechenStapelAnsicht.spacing = 10
        schaltflaechenStapelAnsicht.translatesAutoresizingMaskIntoConstraints = false
        containerAnsicht.addSubview(schaltflaechenStapelAnsicht)
        
        for (index, titel) in schaltflaechenTitel.enumerated() {
            let schaltflaeche = UIButton(type: .system)
            schaltflaeche.setTitle(titel, for: .normal)
            schaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            schaltflaeche.backgroundColor = index == 0 ? .systemGray : .systemBlue
            schaltflaeche.setTitleColor(.white, for: .normal)
            schaltflaeche.layer.cornerRadius = 10
            schaltflaeche.tag = index
            schaltflaeche.addTarget(self, action: #selector(schaltflaecheGedrueckt(_:)), for: .touchUpInside)
            schaltflaechenStapelAnsicht.addArrangedSubview(schaltflaeche)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            containerAnsicht.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerAnsicht.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerAnsicht.widthAnchor.constraint(equalToConstant: 300),
            
            titelLabel.topAnchor.constraint(equalTo: containerAnsicht.topAnchor, constant: 30),
            titelLabel.leadingAnchor.constraint(equalTo: containerAnsicht.leadingAnchor, constant: 20),
            titelLabel.trailingAnchor.constraint(equalTo: containerAnsicht.trailingAnchor, constant: -20),
            
            nachrichtLabel.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 20),
            nachrichtLabel.leadingAnchor.constraint(equalTo: containerAnsicht.leadingAnchor, constant: 20),
            nachrichtLabel.trailingAnchor.constraint(equalTo: containerAnsicht.trailingAnchor, constant: -20),
            
            schaltflaechenStapelAnsicht.topAnchor.constraint(equalTo: nachrichtLabel.bottomAnchor, constant: 30),
            schaltflaechenStapelAnsicht.leadingAnchor.constraint(equalTo: containerAnsicht.leadingAnchor, constant: 20),
            schaltflaechenStapelAnsicht.trailingAnchor.constraint(equalTo: containerAnsicht.trailingAnchor, constant: -20),
            schaltflaechenStapelAnsicht.bottomAnchor.constraint(equalTo: containerAnsicht.bottomAnchor, constant: -20),
            schaltflaechenStapelAnsicht.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Tap auf Hintergrund
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hintergrundAngetippt))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func schaltflaecheGedrueckt(_ sender: UIButton) {
        schaltflaechenAktion?(sender.tag)
        entfernen()
    }
    
    @objc private func hintergrundAngetippt() {
        // Optional: Dialog schließen
    }
    
    func anzeigen(in ansicht: UIView) {
        frame = ansicht.bounds
        ansicht.addSubview(self)
        
        alpha = 0
        containerAnsicht.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.containerAnsicht.transform = .identity
        })
    }
    
    func entfernen() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerAnsicht.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}


