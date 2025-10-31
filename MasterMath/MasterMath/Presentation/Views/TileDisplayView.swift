//
//  TileDisplayView.swift
//  MasterMath
//
//  Presentation Layer - Tile Display View
//

import UIKit

final class TileDisplayView: UIView {
    
    private let imageView = UIImageView()
    private let selectionBorder = UIView()
    private let valueLabel = UILabel()
    
    private(set) var tile: TileEntity?
    var onTap: (() -> Void)?
    
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
        layer.shadowOpacity = 0.15
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.layer.shadowColor = UIColor.black.cgColor
        valueLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        valueLabel.layer.shadowRadius = 2
        valueLabel.layer.shadowOpacity = 0.3
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        selectionBorder.backgroundColor = .clear
        selectionBorder.layer.borderWidth = 4
        selectionBorder.layer.borderColor = UIColor.systemYellow.cgColor
        selectionBorder.layer.cornerRadius = 12
        selectionBorder.isHidden = true
        selectionBorder.layer.shadowColor = UIColor.systemYellow.cgColor
        selectionBorder.layer.shadowOffset = CGSize(width: 0, height: 0)
        selectionBorder.layer.shadowRadius = 8
        selectionBorder.layer.shadowOpacity = 0.6
        selectionBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionBorder)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            selectionBorder.topAnchor.constraint(equalTo: topAnchor),
            selectionBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectionBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectionBorder.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tileTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func configure(with tile: TileEntity) {
        self.tile = tile
        updateDisplay()
    }
    
    func updateSelection(_ isSelected: Bool) {
        selectionBorder.isHidden = !isSelected
        if isSelected {
            animateSelection()
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
    }
    
    private func updateDisplay() {
        guard let tile = tile else { return }
        
        layer.cornerRadius = 12
        
        if let image = UIImage(named: tile.imageName) {
            imageView.image = image
            valueLabel.isHidden = true
            backgroundColor = .clear
        } else {
            imageView.image = nil
            valueLabel.text = "\(tile.numericValue)"
            valueLabel.isHidden = false
            
            // 现代化的渐变背景
            let gradient = CAGradientLayer()
            switch tile.colorTheme {
            case .red:
                gradient.colors = [
                    UIColor.systemRed.withAlphaComponent(0.9).cgColor,
                    UIColor.systemRed.withAlphaComponent(0.7).cgColor
                ]
                valueLabel.textColor = .white
            case .blue:
                gradient.colors = [
                    UIColor.systemBlue.withAlphaComponent(0.9).cgColor,
                    UIColor.systemBlue.withAlphaComponent(0.7).cgColor
                ]
                valueLabel.textColor = .white
            case .green:
                gradient.colors = [
                    UIColor.systemGreen.withAlphaComponent(0.9).cgColor,
                    UIColor.systemGreen.withAlphaComponent(0.7).cgColor
                ]
                valueLabel.textColor = .white
            }
            gradient.locations = [0.0, 1.0]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.cornerRadius = 12
            gradient.frame = bounds
            layer.insertSublayer(gradient, at: 0)
        }
        
        updateSelection(tile.isChosen)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新渐变层的frame
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
    
    @objc private func tileTapped() {
        onTap?()
    }
    
    private func animateSelection() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
}

