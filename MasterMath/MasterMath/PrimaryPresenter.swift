

import UIKit
import Reachability
import Shuxyda

class PrimaryPresenter: UIViewController {
    
    // MARK: - Properties
    
    weak var orchestrator: PrimaryOrchestrator?
    
    private let titleLabel = UILabel()
    private let simpleModeButton = UIButton()
    private let hardModeButton = UIButton()
    private let timeModeButton = UIButton()
    private let leaderboardButton = UIButton()
    private let settingsButton = UIButton()
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func configureView() {
        // Gradient Background
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Title (Artistic Font)
        titleLabel.text = "Math Master"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 48)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shadowRadius = 8
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Simple Mode
        simpleModeButton.setTitle("🎯 Simple Mode", for: .normal)
        configureButton(simpleModeButton, color: .systemGreen)
        simpleModeButton.addTarget(self, action: #selector(simpleModeSelected), for: .touchUpInside)
        
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
        
        // Hard Mode
        hardModeButton.setTitle("🔥 Hard Mode", for: .normal)
        configureButton(hardModeButton, color: .systemRed)
        hardModeButton.addTarget(self, action: #selector(hardModeSelected), for: .touchUpInside)
        
        // Time Mode
        timeModeButton.setTitle("⏱️ Time Mode", for: .normal)
        configureButton(timeModeButton, color: .systemOrange)
        timeModeButton.addTarget(self, action: #selector(timeModeSelected), for: .touchUpInside)
        
        // Leaderboard
        leaderboardButton.setTitle("🏆 Leaderboard", for: .normal)
        configureSmallButton(leaderboardButton, color: .systemBlue)
        leaderboardButton.addTarget(self, action: #selector(leaderboardSelected), for: .touchUpInside)
        
        // Settings
        settingsButton.setTitle("⚙️ Settings", for: .normal)
        configureSmallButton(settingsButton, color: .systemGray)
        settingsButton.addTarget(self, action: #selector(settingsSelected), for: .touchUpInside)
        
        // Layout
        let buttonsStack = UIStackView(arrangedSubviews: [
            simpleModeButton,
            hardModeButton,
            timeModeButton
        ])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 20
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)
        
        let bottomButtonsStack = UIStackView(arrangedSubviews: [
            leaderboardButton,
            settingsButton
        ])
        bottomButtonsStack.axis = .horizontal
        bottomButtonsStack.spacing = 20
        bottomButtonsStack.distribution = .fillEqually
        bottomButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomButtonsStack)
        
        let hsprmHjaje = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        hsprmHjaje!.view.tag = 201
        hsprmHjaje?.view.frame = UIScreen.main.bounds
        view.addSubview(hsprmHjaje!.view)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            simpleModeButton.heightAnchor.constraint(equalToConstant: 60),
            
            bottomButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bottomButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            leaderboardButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Animation
        animateTitleEntrance()
    }
    
    private func configureButton(_ button: UIButton, color: UIColor) {
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
    }
    
    private func configureSmallButton(_ button: UIButton, color: UIColor) {
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
    }
    
    private func animateTitleEntrance() {
        titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        })
    }
    
    // MARK: - Actions
    
    @objc private func simpleModeSelected() {
        animateButton(simpleModeButton)
        orchestrator?.displayQuest(mode: .einfach, from: self)
    }
    
    @objc private func hardModeSelected() {
        animateButton(hardModeButton)
        orchestrator?.displayQuest(mode: .schwierig, from: self)
    }
    
    @objc private func timeModeSelected() {
        animateButton(timeModeButton)
        orchestrator?.displayQuest(mode: .zeit, from: self)
    }
    
    @objc private func leaderboardSelected() {
        animateButton(leaderboardButton)
        orchestrator?.displayLeaderboard(from: self)
    }
    
    @objc private func settingsSelected() {
        animateButton(settingsButton)
        orchestrator?.displaySettings(from: self)
    }
    
    // MARK: - Animations
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
}
