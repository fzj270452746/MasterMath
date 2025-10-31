

import UIKit

class RanglisteViewController: UIViewController {
    
    private let titelLabel = UILabel()
    private let einfachPunktzahlLabel = UILabel()
    private let schwierigPunktzahlLabel = UILabel()
    private let zeitPunktzahlLabel = UILabel()
    private let schliessenSchaltflaeche = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        einrichteAnsicht()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ladePunktzahlen()
    }
    
    private func einrichteAnsicht() {
        view.backgroundColor = .systemBackground
        
        // Titel
        titelLabel.text = "🏆 Leaderboard"
        titelLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titelLabel.textAlignment = .center
        titelLabel.textColor = .systemPurple
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titelLabel)
        
        // Einfach Modus
        einfachPunktzahlLabel.font = UIFont.systemFont(ofSize: 20)
        einfachPunktzahlLabel.textColor = .black
        einfachPunktzahlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Schwierig Modus
        schwierigPunktzahlLabel.font = UIFont.systemFont(ofSize: 20)
        schwierigPunktzahlLabel.textColor = .black
        schwierigPunktzahlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Zeit Modus
        zeitPunktzahlLabel.font = UIFont.systemFont(ofSize: 20)
        zeitPunktzahlLabel.textColor = .black
        zeitPunktzahlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stapelAnsicht = UIStackView(arrangedSubviews: [
            erstellePunktzahlKarte(emoji: "🎯", titel: "Simple Mode", label: einfachPunktzahlLabel),
            erstellePunktzahlKarte(emoji: "🔥", titel: "Hard Mode", label: schwierigPunktzahlLabel),
            erstellePunktzahlKarte(emoji: "⏱️", titel: "Time Mode", label: zeitPunktzahlLabel)
        ])
        stapelAnsicht.axis = .vertical
        stapelAnsicht.spacing = 20
        stapelAnsicht.distribution = .fillEqually
        stapelAnsicht.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stapelAnsicht)
        
        // Schließen Button
        schliessenSchaltflaeche.setTitle("Close", for: .normal)
        schliessenSchaltflaeche.backgroundColor = .systemBlue
        schliessenSchaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        schliessenSchaltflaeche.setTitleColor(.white, for: .normal)
        schliessenSchaltflaeche.layer.cornerRadius = 12
        schliessenSchaltflaeche.addTarget(self, action: #selector(schliessen), for: .touchUpInside)
        schliessenSchaltflaeche.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(schliessenSchaltflaeche)
        
        NSLayoutConstraint.activate([
            titelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stapelAnsicht.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 40),
            stapelAnsicht.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stapelAnsicht.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stapelAnsicht.heightAnchor.constraint(equalToConstant: 300),
            
            schliessenSchaltflaeche.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            schliessenSchaltflaeche.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            schliessenSchaltflaeche.widthAnchor.constraint(equalToConstant: 200),
            schliessenSchaltflaeche.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func erstellePunktzahlKarte(emoji: String, titel: String, label: UILabel) -> UIView {
        let karteAnsicht = UIView()
        karteAnsicht.backgroundColor = .white
        karteAnsicht.layer.cornerRadius = 15
        karteAnsicht.layer.shadowColor = UIColor.black.cgColor
        karteAnsicht.layer.shadowOffset = CGSize(width: 0, height: 4)
        karteAnsicht.layer.shadowRadius = 8
        karteAnsicht.layer.shadowOpacity = 0.1
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 40)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        karteAnsicht.addSubview(emojiLabel)
        
        let titelLabel = UILabel()
        titelLabel.text = titel
        titelLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titelLabel.textColor = .black
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        karteAnsicht.addSubview(titelLabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        karteAnsicht.addSubview(label)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: karteAnsicht.leadingAnchor, constant: 20),
            emojiLabel.centerYAnchor.constraint(equalTo: karteAnsicht.centerYAnchor),
            
            titelLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 15),
            titelLabel.centerYAnchor.constraint(equalTo: karteAnsicht.centerYAnchor, constant: -10),
            
            label.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 15),
            label.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 5)
        ])
        
        return karteAnsicht
    }
    
    private func ladePunktzahlen() {
        let einfachPunktzahl = PunktzahlManager.shared.holePunktzahl(fuerModus: .einfach)
        let schwierigPunktzahl = PunktzahlManager.shared.holePunktzahl(fuerModus: .schwierig)
        let zeitPunktzahl = PunktzahlManager.shared.holePunktzahl(fuerModus: .zeit)
        
        einfachPunktzahlLabel.text = "Best Score: \(einfachPunktzahl)"
        schwierigPunktzahlLabel.text = "Best Score: \(schwierigPunktzahl)"
        zeitPunktzahlLabel.text = "Best Score: \(zeitPunktzahl)"
    }
    
    @objc private func schliessen() {
        dismiss(animated: true)
    }
}

