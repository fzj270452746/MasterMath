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
        layer.shadowOpacity = 0.2
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.boldSystemFont(ofSize: 32)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        selectionBorder.backgroundColor = .clear
        selectionBorder.layer.borderWidth = 4
        selectionBorder.layer.borderColor = UIColor.systemYellow.cgColor
        selectionBorder.isHidden = true
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
        }
    }
    
    private func updateDisplay() {
        guard let tile = tile else { return }
        
        if let image = UIImage(named: tile.imageName) {
            imageView.image = image
            valueLabel.isHidden = true
        } else {
            imageView.image = nil
            valueLabel.text = "\(tile.numericValue)"
            valueLabel.isHidden = false
            
            switch tile.colorTheme {
            case .red:
                backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                valueLabel.textColor = .systemRed
            case .blue:
                backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                valueLabel.textColor = .systemBlue
            case .green:
                backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                valueLabel.textColor = .systemGreen
            }
        }
        
        updateSelection(tile.isChosen)
    }
    
    @objc private func tileTapped() {
        onTap?()
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

