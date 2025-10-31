//
//  CustomDialogView.swift
//  MasterMath
//

import UIKit

class CustomDialogView: UIView {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonsStackView = UIStackView()
    
    var buttonAction: ((Int) -> Void)?
    
    init(title: String, message: String, buttonTitles: [String]) {
        super.init(frame: .zero)
        setupView(title: title, message: message, buttonTitles: buttonTitles)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String, message: String, buttonTitles: [String]) {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Container - 现代化的卡片设计
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.98)
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 24
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title - 更大的字体和更优雅的颜色
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Message - 更好的可读性
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageLabel)
        
        // Buttons - 现代化的按钮设计
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 12
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonsStackView)
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            
            // 根据按钮位置设置不同的颜色
            if buttonTitles.count == 1 {
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
                button.setTitleColor(.white, for: .normal)
            } else {
                if index == 0 {
                    button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
                    button.setTitleColor(UIColor.systemGray, for: .normal)
                } else {
                    button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
                    button.setTitleColor(.white, for: .normal)
                }
            }
            
            button.layer.cornerRadius = 14
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.shadowOpacity = 0.2
            button.tag = index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            buttonsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        // Tap on background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        buttonAction?(sender.tag)
        remove()
    }
    
    @objc private func backgroundTapped() {
        // Optional: Close dialog
    }
    
    func display(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.containerView.transform = .identity
        })
    }
    
    func remove() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
