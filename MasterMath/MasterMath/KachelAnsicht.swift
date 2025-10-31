//
//  TokenView.swift
//  MasterMath
//
//  Numeric Token View
//

import UIKit

class TokenView: UIView {
    
    private let imageView = UIImageView()
    private let selectionOverlay = UIView()
    private let valueLabel = UILabel()
    
    var token: NumericToken? {
        didSet {
            updateView()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            selectionOverlay.isHidden = !isSelected
            if isSelected {
                animateSelection()
            }
        }
    }
    
    var tokenTapped: ((TokenView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        
        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        // Value Label
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.boldSystemFont(ofSize: 32)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        // Selection Overlay - only border, no background and corner radius
        selectionOverlay.backgroundColor = .clear
        selectionOverlay.layer.borderWidth = 4
        selectionOverlay.layer.borderColor = UIColor.systemYellow.cgColor
        selectionOverlay.isHidden = true
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionOverlay)
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            selectionOverlay.topAnchor.constraint(equalTo: topAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tokenWasTapped))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateView() {
        guard let token = token else { return }
        
        // Try to load image, otherwise show value
        if let image = UIImage(named: token.imageAssetName) {
            imageView.image = image
            valueLabel.isHidden = true
        } else {
            // Fallback: Show value with colored background
            imageView.image = nil
            valueLabel.text = "\(token.value)"
            valueLabel.isHidden = false
            
            // Set background color based on color scheme
            switch token.colorScheme {
            case .freun:
                backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                valueLabel.textColor = .systemRed
            case .joirars:
                backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                valueLabel.textColor = .systemBlue
            case .sortie:
                backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                valueLabel.textColor = .systemGreen
            }
        }
    }
    
    @objc private func tokenWasTapped() {
        tokenTapped?(self)
    }
    
    private func animateSelection() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}
