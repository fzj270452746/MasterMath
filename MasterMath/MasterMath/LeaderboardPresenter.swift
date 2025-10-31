//
//  LeaderboardPresenter.swift
//  MasterMath
//

import UIKit

class LeaderboardPresenter: UIViewController {
    
    private let titleLabel = UILabel()
    private let simpleScoreLabel = UILabel()
    private let hardScoreLabel = UILabel()
    private let timeScoreLabel = UILabel()
    private let closeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadScores()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel.text = "🏆 Leaderboard"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .systemPurple
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Simple Mode
        simpleScoreLabel.font = UIFont.systemFont(ofSize: 20)
        simpleScoreLabel.textColor = .black
        simpleScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Hard Mode
        hardScoreLabel.font = UIFont.systemFont(ofSize: 20)
        hardScoreLabel.textColor = .black
        hardScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Time Mode
        timeScoreLabel.font = UIFont.systemFont(ofSize: 20)
        timeScoreLabel.textColor = .black
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
        
        // Close Button
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 12
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
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
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 40)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(emojiLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(label)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -10),
            
            label.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 15),
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        ])
        
        return cardView
    }
    
    private func loadScores() {
        let simpleScore = ScoreHandler.shared.retrieveScore(forMode: .einfach)
        let hardScore = ScoreHandler.shared.retrieveScore(forMode: .schwierig)
        let timeScore = ScoreHandler.shared.retrieveScore(forMode: .zeit)
        
        simpleScoreLabel.text = "Best Score: \(simpleScore)"
        hardScoreLabel.text = "Best Score: \(hardScore)"
        timeScoreLabel.text = "Best Score: \(timeScore)"
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
