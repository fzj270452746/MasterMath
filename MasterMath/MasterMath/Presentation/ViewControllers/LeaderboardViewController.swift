//
//  LeaderboardViewController.swift
//  MasterMath
//
//  Presentation Layer - Leaderboard View Controller
//

import UIKit

final class LeaderboardViewController: UIViewController {
    
    private let eventBus: EventBusProtocol
    private let router: NavigationRouterProtocol
    private let scoreRepository: ScoreRepositoryProtocol
    
    private let titleLabel = UILabel()
    private let simpleScoreLabel = UILabel()
    private let hardScoreLabel = UILabel()
    private let timeScoreLabel = UILabel()
    private let closeButton = UIButton()
    
    init(eventBus: EventBusProtocol, router: NavigationRouterProtocol) {
        self.eventBus = eventBus
        self.router = router
        self.scoreRepository = ScoreRepository()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadScores()
    }
    
    private func configureInterface() {
        // 清新的渐变背景
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.96, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
        titleLabel.text = "🏆 Leaderboard"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 8
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        simpleScoreLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        simpleScoreLabel.textColor = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
        simpleScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hardScoreLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        hardScoreLabel.textColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
        hardScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeScoreLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        timeScoreLabel.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1.0)
        timeScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            createScoreCard(emoji: "🎯", title: "Simple Mode", label: simpleScoreLabel),
            createScoreCard(emoji: "🔥", title: "Hard Mode", label: hardScoreLabel),
            createScoreCard(emoji: "⏱️", title: "Time Mode", label: timeScoreLabel)
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 16
        closeButton.layer.shadowColor = UIColor.systemBlue.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        closeButton.layer.shadowRadius = 8
        closeButton.layer.shadowOpacity = 0.4
        closeButton.layer.borderWidth = 1.5
        closeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 300),
            
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 200),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createScoreCard(emoji: String, title: String, label: UILabel) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.borderWidth = 1.5
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 48)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(emojiLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(label)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -12),
            
            label.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        ])
        
        return cardView
    }
    
    private func loadScores() {
        let simpleScore = scoreRepository.fetchBestScore(for: "simple")
        let hardScore = scoreRepository.fetchBestScore(for: "hard")
        let timeScore = scoreRepository.fetchBestScore(for: "time")
        
        simpleScoreLabel.text = "Best Score: \(simpleScore)"
        hardScoreLabel.text = "Best Score: \(hardScore)"
        timeScoreLabel.text = "Best Score: \(timeScore)"
    }
    
    @objc private func closeTapped() {
        router.dismiss(from: self)
    }
}

