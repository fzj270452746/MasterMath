//
//  OperandButton.swift
//  MasterMath
//
//  Operand Button
//

import UIKit

class OperandButton: UIButton {
    
    var operandType: ArithmeticOperand? {
        didSet {
            updateView()
        }
    }
    
    var isOperandSelected: Bool = false {
        didSet {
            updateSelectionStatus()
        }
    }
    
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
        
        // Set image content mode
        imageView?.contentMode = .scaleAspectFit
        
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    private func updateView() {
        guard let op = operandType else { return }
        
        // Use asset image instead of text symbol
        let imageName = op.rawValue
        if let image = UIImage(named: imageName) {
            setImage(image, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            // Fallback to text if image loading fails
            setTitle(op.symbol, for: .normal)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        }
    }
    
    private func updateSelectionStatus() {
        if isOperandSelected {
            backgroundColor = .systemYellow
            layer.borderWidth = 3
            layer.borderColor = UIColor.systemOrange.cgColor
            transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } else {
            backgroundColor = .systemIndigo
            layer.borderWidth = 0
            transform = .identity
        }
    }
    
    @objc private func buttonPressed() {
        // Simple click feedback animation (press-release)
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
