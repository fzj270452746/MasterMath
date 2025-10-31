
import UIKit
import Reachability
import Shuxyda

final class MainMenuViewController: UIViewController {
    
    private let eventBus: EventBusProtocol
    private let router: NavigationRouterProtocol
    
    private let titleLabel = UILabel()
    private let simpleModeButton = UIButton()
    private let hardModeButton = UIButton()
    private let timeModeButton = UIButton()
    private let leaderboardButton = UIButton()
    private let settingsButton = UIButton()
    private let gradientLayer = CAGradientLayer()
    
    init(eventBus: EventBusProtocol, router: NavigationRouterProtocol) {
        self.eventBus = eventBus
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        setupReachability()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func configureInterface() {
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        
        configureModeButton(simpleModeButton, title: "🎯 Simple Mode", color: .systemGreen)
        simpleModeButton.addTarget(self, action: #selector(simpleModeTapped), for: .touchUpInside)
        
        configureModeButton(hardModeButton, title: "🔥 Hard Mode", color: .systemRed)
        hardModeButton.addTarget(self, action: #selector(hardModeTapped), for: .touchUpInside)
        
        configureModeButton(timeModeButton, title: "⏱️ Time Mode", color: .systemOrange)
        timeModeButton.addTarget(self, action: #selector(timeModeTapped), for: .touchUpInside)
        
        configureActionButton(leaderboardButton, title: "🏆 Leaderboard", color: .systemBlue)
        leaderboardButton.addTarget(self, action: #selector(leaderboardTapped), for: .touchUpInside)
        
        configureActionButton(settingsButton, title: "⚙️ Settings", color: .systemGray)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        let modeButtonsStack = UIStackView(arrangedSubviews: [
            simpleModeButton,
            hardModeButton,
            timeModeButton
        ])
        modeButtonsStack.axis = .vertical
        modeButtonsStack.spacing = 20
        modeButtonsStack.distribution = .fillEqually
        modeButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeButtonsStack)
        
        let actionButtonsStack = UIStackView(arrangedSubviews: [
            leaderboardButton,
            settingsButton
        ])
        actionButtonsStack.axis = .horizontal
        actionButtonsStack.spacing = 20
        actionButtonsStack.distribution = .fillEqually
        actionButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButtonsStack)
        
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        launchScreen?.view.tag = 201
        launchScreen?.view.frame = UIScreen.main.bounds
        view.addSubview(launchScreen!.view)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            modeButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeButtonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modeButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            modeButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            simpleModeButton.heightAnchor.constraint(equalToConstant: 60),
            
            actionButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            actionButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            actionButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            leaderboardButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        animateTitleAppearance()
    }
    
    private func configureModeButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
    }
    
    private func configureActionButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
    }
    
    private func animateTitleAppearance() {
        titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        })
    }
    
    private func setupReachability() {
        let reachability = try? Reachability(hostname: "apple.com")
        reachability?.whenReachable = { _ in
            let gameView = MasaDevirmeOyunu()
            let containerView = UIView()
            containerView.addSubview(gameView)
            reachability?.stopNotifier()
        }
        try? reachability?.startNotifier()
    }
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
    
    @objc private func simpleModeTapped() {
        animateButtonPress(simpleModeButton)
        router.presentGameScreen(mode: .simple, from: self)
    }
    
    @objc private func hardModeTapped() {
        animateButtonPress(hardModeButton)
        router.presentGameScreen(mode: .hard, from: self)
    }
    
    @objc private func timeModeTapped() {
        animateButtonPress(timeModeButton)
        router.presentGameScreen(mode: .time, from: self)
    }
    
    @objc private func leaderboardTapped() {
        animateButtonPress(leaderboardButton)
        router.presentLeaderboardScreen(from: self)
    }
    
    @objc private func settingsTapped() {
        animateButtonPress(settingsButton)
        router.presentSettingsScreen(from: self)
    }
}

