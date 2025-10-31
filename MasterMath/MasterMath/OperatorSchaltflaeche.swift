//
//  OperatorSchaltflaeche.swift
//  MasterMath
//
//  Operator Schaltfläche (Operator Button)
//

import UIKit

class OperatorSchaltflaeche: UIButton {
    
    var operatorTyp: OperatorTyp? {
        didSet {
            aktualiesiereAnsicht()
        }
    }
    
    var istAusgewaehlt: Bool = false {
        didSet {
            aktualiesiereAuswahlStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        einrichteAnsicht()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        einrichteAnsicht()
    }
    
    private func einrichteAnsicht() {
        backgroundColor = .systemIndigo
        layer.cornerRadius = 35  // 增大圆角以适应更大的按钮 (70/2 = 35)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        
        // 设置图片内容模式
        imageView?.contentMode = .scaleAspectFit
        
        addTarget(self, action: #selector(schaltflaecheGedrueckt), for: .touchUpInside)
    }
    
    private func aktualiesiereAnsicht() {
        guard let op = operatorTyp else { return }
        
        // 使用素材图片而不是文字符号
        let bildName = op.rawValue  // "Operator_add", "Operator_subtract", 等
        if let bild = UIImage(named: bildName) {
            setImage(bild, for: .normal)
            // 适当减小边距，让图片更大，更清晰
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            // 如果图片加载失败，回退到文本（增大字体）
            setTitle(op.symbol, for: .normal)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        }
    }
    
    private func aktualiesiereAuswahlStatus() {
        if istAusgewaehlt {
            backgroundColor = .systemYellow
            layer.borderWidth = 3
            layer.borderColor = UIColor.systemOrange.cgColor
            // 为选中状态添加轻微的缩放
            transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } else {
            backgroundColor = .systemIndigo
            layer.borderWidth = 0
            transform = .identity
        }
    }
    
    @objc private func schaltflaecheGedrueckt() {
        // 简单的点击反馈动画（按下-弹起）
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}

