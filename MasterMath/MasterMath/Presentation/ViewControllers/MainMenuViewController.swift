
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
        // 清新的渐变背景：从淡蓝到淡紫
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,  // 淡蓝白
            UIColor(red: 0.92, green: 0.94, blue: 0.98, alpha: 1.0).cgColor,  // 淡紫灰
            UIColor(red: 0.98, green: 0.96, blue: 1.0, alpha: 1.0).cgColor   // 淡粉紫
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel.text = "Math Master"
        titleLabel.font = UIFont.systemFont(ofSize: 52, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)  // 深蓝灰
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 12
        titleLabel.layer.shadowOpacity = 0.8
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
        
        // 使用半透明背景色替代渐变，更简单且性能更好
        button.backgroundColor = color.withAlphaComponent(0.85)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.4
        
        // 添加边框高光
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
    private func configureActionButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        
        // 半透明背景与边框设计
        button.backgroundColor = color.withAlphaComponent(0.15)
        button.layer.borderWidth = 2
        button.layer.borderColor = color.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(color, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
    }
    
    private func animateTitleAppearance() {
        titleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        })
        
        // 添加微妙的呼吸动画
        UIView.animate(withDuration: 2.0, delay: 1.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.titleLabel.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }) { _ in
            self.titleLabel.transform = .identity
        }
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
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            button.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                button.transform = .identity
                button.alpha = 1.0
            })
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

