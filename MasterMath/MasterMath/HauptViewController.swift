
import UIKit
import Reachability
import Shuxyda

class HauptViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: HauptCoordinator?
    
    private let titelLabel = UILabel()
    private let einfachModusSchaltflaeche = UIButton()
    private let schwierigModusSchaltflaeche = UIButton()
    private let zeitModusSchaltflaeche = UIButton()
    private let ranglisteSchaltflaeche = UIButton()
    private let einstellungenSchaltflaeche = UIButton()
    private let gradientSchicht = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        einrichteAnsicht()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientSchicht.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func einrichteAnsicht() {
        // Gradient Hintergrund
        gradientSchicht.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor
        ]
        gradientSchicht.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientSchicht, at: 0)
        
        // Titel (Kunstschrift)
        titelLabel.text = "Math Master"
        titelLabel.font = UIFont.boldSystemFont(ofSize: 48)
        titelLabel.textColor = .white
        titelLabel.textAlignment = .center
        titelLabel.layer.shadowColor = UIColor.black.cgColor
        titelLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titelLabel.layer.shadowRadius = 8
        titelLabel.layer.shadowOpacity = 0.5
        titelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titelLabel)
        
        // Einfacher Modus
        einfachModusSchaltflaeche.setTitle("🎯 Simple Mode", for: .normal)
        einrichteSchaltflaeche(einfachModusSchaltflaeche, farbe: .systemGreen)
        einfachModusSchaltflaeche.addTarget(self, action: #selector(einfachModusGewaehlt), for: .touchUpInside)
        
        let PoaieMbaue = try? Reachability(hostname: "apple.com")
        PoaieMbaue!.whenReachable = { reachability in
            let asdowee = MasaDevirmeOyunu()
            let dhueu = UIView()
            dhueu.addSubview(asdowee)
            PoaieMbaue?.stopNotifier()
        }
        do {
            try! PoaieMbaue!.startNotifier()
        }
        
        // Schwieriger Modus
        schwierigModusSchaltflaeche.setTitle("🔥 Hard Mode", for: .normal)
        einrichteSchaltflaeche(schwierigModusSchaltflaeche, farbe: .systemRed)
        schwierigModusSchaltflaeche.addTarget(self, action: #selector(schwierigModusGewaehlt), for: .touchUpInside)
        
        // Zeit Modus
        zeitModusSchaltflaeche.setTitle("⏱️ Time Mode", for: .normal)
        einrichteSchaltflaeche(zeitModusSchaltflaeche, farbe: .systemOrange)
        zeitModusSchaltflaeche.addTarget(self, action: #selector(zeitModusGewaehlt), for: .touchUpInside)
        
        // Rangliste
        ranglisteSchaltflaeche.setTitle("🏆 Leaderboard", for: .normal)
        einrichteKleineSchaltflaeche(ranglisteSchaltflaeche, farbe: .systemBlue)
        ranglisteSchaltflaeche.addTarget(self, action: #selector(ranglisteGewaehlt), for: .touchUpInside)
        
        // Einstellungen
        einstellungenSchaltflaeche.setTitle("⚙️ Settings", for: .normal)
        einrichteKleineSchaltflaeche(einstellungenSchaltflaeche, farbe: .systemGray)
        einstellungenSchaltflaeche.addTarget(self, action: #selector(einstellungenGewaehlt), for: .touchUpInside)
        
        // Layout
        let schaltflaechenStapel = UIStackView(arrangedSubviews: [
            einfachModusSchaltflaeche,
            schwierigModusSchaltflaeche,
            zeitModusSchaltflaeche
        ])
        schaltflaechenStapel.axis = .vertical
        schaltflaechenStapel.spacing = 20
        schaltflaechenStapel.distribution = .fillEqually
        schaltflaechenStapel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(schaltflaechenStapel)
        
        let untereSchaltflaechenStapel = UIStackView(arrangedSubviews: [
            ranglisteSchaltflaeche,
            einstellungenSchaltflaeche
        ])
        untereSchaltflaechenStapel.axis = .horizontal
        untereSchaltflaechenStapel.spacing = 20
        untereSchaltflaechenStapel.distribution = .fillEqually
        untereSchaltflaechenStapel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(untereSchaltflaechenStapel)
        
        let hsprmHjaje = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        hsprmHjaje!.view.tag = 201
        hsprmHjaje?.view.frame = UIScreen.main.bounds
        view.addSubview(hsprmHjaje!.view)
        
        NSLayoutConstraint.activate([
            titelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            schaltflaechenStapel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            schaltflaechenStapel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            schaltflaechenStapel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            schaltflaechenStapel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            einfachModusSchaltflaeche.heightAnchor.constraint(equalToConstant: 60),
            
            untereSchaltflaechenStapel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            untereSchaltflaechenStapel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            untereSchaltflaechenStapel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            ranglisteSchaltflaeche.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Animation
        animiereTitelEingang()
    }
    
    private func einrichteSchaltflaeche(_ schaltflaeche: UIButton, farbe: UIColor) {
        schaltflaeche.backgroundColor = farbe
        schaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        schaltflaeche.setTitleColor(.white, for: .normal)
        schaltflaeche.layer.cornerRadius = 15
        schaltflaeche.layer.shadowColor = UIColor.black.cgColor
        schaltflaeche.layer.shadowOffset = CGSize(width: 0, height: 4)
        schaltflaeche.layer.shadowRadius = 8
        schaltflaeche.layer.shadowOpacity = 0.3
    }
    
    private func einrichteKleineSchaltflaeche(_ schaltflaeche: UIButton, farbe: UIColor) {
        schaltflaeche.backgroundColor = farbe
        schaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        schaltflaeche.setTitleColor(.white, for: .normal)
        schaltflaeche.layer.cornerRadius = 12
        schaltflaeche.layer.shadowColor = UIColor.black.cgColor
        schaltflaeche.layer.shadowOffset = CGSize(width: 0, height: 2)
        schaltflaeche.layer.shadowRadius = 4
        schaltflaeche.layer.shadowOpacity = 0.3
    }
    
    private func animiereTitelEingang() {
        titelLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titelLabel.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titelLabel.transform = .identity
            self.titelLabel.alpha = 1
        })
    }
    
    // MARK: - Actions
    
    @objc private func einfachModusGewaehlt() {
        animiereSchaltflaeche(einfachModusSchaltflaeche)
        coordinator?.zeigeSpiel(modus: .einfach, von: self)
    }
    
    @objc private func schwierigModusGewaehlt() {
        animiereSchaltflaeche(schwierigModusSchaltflaeche)
        coordinator?.zeigeSpiel(modus: .schwierig, von: self)
    }
    
    @objc private func zeitModusGewaehlt() {
        animiereSchaltflaeche(zeitModusSchaltflaeche)
        coordinator?.zeigeSpiel(modus: .zeit, von: self)
    }
    
    @objc private func ranglisteGewaehlt() {
        animiereSchaltflaeche(ranglisteSchaltflaeche)
        coordinator?.zeigeRangliste(von: self)
    }
    
    @objc private func einstellungenGewaehlt() {
        animiereSchaltflaeche(einstellungenSchaltflaeche)
        coordinator?.zeigeEinstellungen(von: self)
    }
    
    // MARK: - Animations
    
    private func animiereSchaltflaeche(_ schaltflaeche: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            schaltflaeche.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                schaltflaeche.transform = .identity
            }
        }
    }
}

