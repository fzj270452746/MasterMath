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
        backgroundColor = .systemIndigo
        layer.cornerRadius = 35
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        
        imageView?.contentMode = .scaleAspectFit
        
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func configure(with op: OperatorEntity) {
        self.operatorEntity = op
        
        let imageName = op.rawValue
        if let image = UIImage(named: imageName) {
            setImage(image, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            setTitle(op.symbol, for: .normal)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        }
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}

