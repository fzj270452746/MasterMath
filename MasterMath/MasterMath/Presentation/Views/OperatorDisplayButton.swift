//
//  OperatorDisplayButton.swift
//  MasterMath
//
//  Presentation Layer - Operator Display Button
//

import UIKit

final class OperatorDisplayButton: UIButton {
    
    private(set) var operatorEntity: OperatorEntity?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.9)
        layer.cornerRadius = 35
        layer.shadowColor = UIColor.systemIndigo.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        imageView?.contentMode = .scaleAspectFit
        
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func configure(with op: OperatorEntity) {
        self.operatorEntity = op
        
        // 根据运算符设置不同的颜色
        var buttonColor: UIColor
        switch op {
        case .addition:
            buttonColor = UIColor.systemGreen
        case .subtraction:
            buttonColor = UIColor.systemOrange
        case .multiplication:
            buttonColor = UIColor.systemPurple
        case .division:
            buttonColor = UIColor.systemBlue
        }
        
        backgroundColor = buttonColor.withAlphaComponent(0.9)
        layer.shadowColor = buttonColor.cgColor
        
        let imageName = op.rawValue
        if let image = UIImage(named: imageName) {
            setImage(image, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            setTitle(op.symbol, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            setTitleColor(.white, for: .normal)
        }
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.transform = .identity
                self.alpha = 1.0
            })
        }
    }
}

