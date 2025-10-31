//
//  SpielViewController.swift
//  MasterMath
//
//  Spiel-View-Controller (Game View Controller) - MVVM Pattern
//

import UIKit

final class SpielViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SpielCoordinator?
    private let viewModel: SpielViewModel
    
    // UI Elemente
    private let schliessenSchaltflaeche = UIButton()
    private let zielLabel = UILabel()
    private let punktzahlLabel = UILabel()
    private let levelLabel = UILabel()
    private let zeitLabel = UILabel()
    private let kachelnContainerAnsicht = UIView()
    private let operatorenContainerAnsicht = UIView()
    private let auswahlLabel = UILabel()
    private let zuruecksetzenSchaltflaeche = UIButton()
    private let ueberpruefenSchaltflaeche = UIButton()
    private let auffrischenSchaltflaeche = UIButton()
    private let schaltflaechenStapel = UIStackView()
    private var kachelAnsichten: [KachelAnsicht] = []
    private var operatorSchaltflaechen: [OperatorSchaltflaeche] = []
    private var gradientSchicht: CAGradientLayer?
    private var hatLayoutBeendet = false
    
    // MARK: - Initialization
    
    init(viewModel: SpielViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        einrichteAnsicht()
        bindeViewModel()
        viewModel.starteNeuesSpiel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientSchicht?.frame = view.bounds
        
        if !hatLayoutBeendet {
            hatLayoutBeendet = true
            erstelleKachelAnsichten()
            erstelleOperatorSchaltflaechen()
        }
    }
    
    // MARK: - Setup
    
    private func einrichteAnsicht() {
        view.backgroundColor = UIColor.systemBackground
        
        // Gradient Hintergrund
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemTeal.withAlphaComponent(0.3).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientSchicht = gradient
        
        einrichteKopfzeile()
        einrichteZielLabel()
        einrichteKachelnContainer()
        einrichteOperatorenContainer()
        einrichteAuswahlBereich()
        einrichteSchaltflaechen()
        einrichteConstraints()
    }
    
    private func einrichteKopfzeile() {
        // Schließen Button
        schliessenSchaltflaeche.setTitle("✕", for: .normal)
        schliessenSchaltflaeche.setTitleColor(.black, for: .normal)
        schliessenSchaltflaeche.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        schliessenSchaltflaeche.addTarget(self, action: #selector(schliessenGewaehlt), for: .touchUpInside)
        schliessenSchaltflaeche.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(schliessenSchaltflaeche)
        
        // Punktzahl Label
        punktzahlLabel.text = "Score: 0"
        punktzahlLabel.font = UIFont.boldSystemFont(ofSize: 20)
        punktzahlLabel.textColor = .black
        punktzahlLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(punktzahlLabel)
        
        // Level Label
        levelLabel.text = "Level 1"
        levelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        levelLabel.textColor = .black
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        // Zeit Label (nur für Zeit-Modus)
        if viewModel.hatZeitLimit {
            zeitLabel.text = "⏱ \(viewModel.zeitVerbleibend)"
            zeitLabel.font = UIFont.boldSystemFont(ofSize: 20)
            zeitLabel.textColor = .systemRed
            zeitLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(zeitLabel)
        }
        }
        
    private func einrichteZielLabel() {
        zielLabel.text = "Target: 0"
        zielLabel.font = UIFont.boldSystemFont(ofSize: 36)
        zielLabel.textColor = .systemIndigo
        zielLabel.textAlignment = .center
        zielLabel.layer.shadowColor = UIColor.black.cgColor
        zielLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        zielLabel.layer.shadowRadius = 4
        zielLabel.layer.shadowOpacity = 0.2
        zielLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zielLabel)
    }
        
    private func einrichteKachelnContainer() {
        kachelnContainerAnsicht.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(kachelnContainerAnsicht)
    }
        
    private func einrichteOperatorenContainer() {
        operatorenContainerAnsicht.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(operatorenContainerAnsicht)
    }
        
    private func einrichteAuswahlBereich() {
        auswahlLabel.text = "Select tiles and operators"
        auswahlLabel.font = UIFont.systemFont(ofSize: 18)
        auswahlLabel.textColor = .darkGray
        auswahlLabel.textAlignment = .center
        auswahlLabel.numberOfLines = 0
        auswahlLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(auswahlLabel)
    }
        
    private func einrichteSchaltflaechen() {
        // Zurücksetzen Button
        zuruecksetzenSchaltflaeche.setTitle("🔄 Reset", for: .normal)
        einrichteSchaltflaeche(zuruecksetzenSchaltflaeche, farbe: .systemGray)
        zuruecksetzenSchaltflaeche.addTarget(self, action: #selector(zuruecksetzenGewaehlt), for: .touchUpInside)
        
        // Überprüfen Button
        ueberpruefenSchaltflaeche.setTitle("✓ Submit", for: .normal)
        einrichteSchaltflaeche(ueberpruefenSchaltflaeche, farbe: .systemGreen)
        ueberpruefenSchaltflaeche.addTarget(self, action: #selector(ueberpruefenGewaehlt), for: .touchUpInside)
        
        // Auffrischen Button
        auffrischenSchaltflaeche.setTitle("⟳ New", for: .normal)
        einrichteSchaltflaeche(auffrischenSchaltflaeche, farbe: .systemBlue)
        auffrischenSchaltflaeche.addTarget(self, action: #selector(auffrischenGewaehlt), for: .touchUpInside)
        
        // StackView配置
        schaltflaechenStapel.axis = .horizontal
        schaltflaechenStapel.spacing = 15
        schaltflaechenStapel.distribution = .fillEqually
        schaltflaechenStapel.translatesAutoresizingMaskIntoConstraints = false
        
        schaltflaechenStapel.addArrangedSubview(zuruecksetzenSchaltflaeche)
        schaltflaechenStapel.addArrangedSubview(ueberpruefenSchaltflaeche)
        schaltflaechenStapel.addArrangedSubview(auffrischenSchaltflaeche)
        
        view.addSubview(schaltflaechenStapel)
    }
    
    private func einrichteSchaltflaeche(_ schaltflaeche: UIButton, farbe: UIColor) {
        schaltflaeche.backgroundColor = farbe
        schaltflaeche.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        schaltflaeche.setTitleColor(.white, for: .normal)
        schaltflaeche.layer.cornerRadius = 12
        schaltflaeche.layer.shadowColor = UIColor.black.cgColor
        schaltflaeche.layer.shadowOffset = CGSize(width: 0, height: 2)
        schaltflaeche.layer.shadowRadius = 4
        schaltflaeche.layer.shadowOpacity = 0.2
        schaltflaeche.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func einrichteConstraints() {
        var constraints: [NSLayoutConstraint] = [
            schliessenSchaltflaeche.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            schliessenSchaltflaeche.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            punktzahlLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            punktzahlLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            
            zielLabel.topAnchor.constraint(equalTo: punktzahlLabel.bottomAnchor, constant: 20),
            zielLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            kachelnContainerAnsicht.topAnchor.constraint(equalTo: zielLabel.bottomAnchor, constant: 30),
            kachelnContainerAnsicht.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kachelnContainerAnsicht.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            kachelnContainerAnsicht.heightAnchor.constraint(equalToConstant: 170),
            
            operatorenContainerAnsicht.topAnchor.constraint(equalTo: kachelnContainerAnsicht.bottomAnchor, constant: 20),
            operatorenContainerAnsicht.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            operatorenContainerAnsicht.heightAnchor.constraint(equalToConstant: 80),
            operatorenContainerAnsicht.widthAnchor.constraint(equalToConstant: 330),
            
            auswahlLabel.topAnchor.constraint(equalTo: operatorenContainerAnsicht.bottomAnchor, constant: 20),
            auswahlLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            auswahlLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            schaltflaechenStapel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            schaltflaechenStapel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            schaltflaechenStapel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            schaltflaechenStapel.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        if viewModel.hatZeitLimit {
            constraints.append(contentsOf: [
                zeitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                zeitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - ViewModel Binding
    
    private func bindeViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - UI Updates
    
    private func aktualisiereBildschirm() {
        zielLabel.text = "Target: \(viewModel.zielWert)"
        punktzahlLabel.text = "Score: \(viewModel.aktuellerPunktzahl)"
        levelLabel.text = "Level \(viewModel.aktuellerLevel)"
        auswahlLabel.text = viewModel.auswahlText
        ueberpruefenSchaltflaeche.isEnabled = viewModel.kannEinreichen
        ueberpruefenSchaltflaeche.alpha = viewModel.kannEinreichen ? 1.0 : 0.5
    }
    
    private func erstelleKachelAnsichten() {
        // Entferne alte Ansichten
        kachelAnsichten.forEach { $0.removeFromSuperview() }
        kachelAnsichten.removeAll()
        
        let kacheln = viewModel.kacheln
        
        // 根据牌的数量决定布局
        // 简单模式(5张): 1行5列
        // 困难模式(10张): 2行5列
        let spalten = 5
        let zeilen = (kacheln.count + spalten - 1) / spalten
        let kachelGroesse: CGFloat = 70
        let abstand: CGFloat = 10
        
        let gesamtBreite = CGFloat(spalten) * kachelGroesse + CGFloat(spalten - 1) * abstand
        let gesamtHoehe = CGFloat(zeilen) * kachelGroesse + CGFloat(zeilen - 1) * abstand
        let startX = (kachelnContainerAnsicht.bounds.width - gesamtBreite) / 2
        let startY = (kachelnContainerAnsicht.bounds.height - gesamtHoehe) / 2
        
        for (index, kachel) in kacheln.enumerated() {
            let zeile = index / spalten
            let spalte = index % spalten
            
            let x = startX + CGFloat(spalte) * (kachelGroesse + abstand)
            let y = startY + CGFloat(zeile) * (kachelGroesse + abstand)
            
            let kachelAnsicht = KachelAnsicht(frame: CGRect(x: x, y: y, width: kachelGroesse, height: kachelGroesse))
            kachelAnsicht.kachel = kachel
            kachelAnsicht.kachelAngetippt = { [weak self] _ in
                self?.kachelWurdeGewaehlt(kachel)
            }
            
            kachelnContainerAnsicht.addSubview(kachelAnsicht)
            kachelAnsichten.append(kachelAnsicht)
        }
    }
    
    private func erstelleOperatorSchaltflaechen() {
        // Entferne alte Schaltflächen
        operatorSchaltflaechen.forEach { $0.removeFromSuperview() }
        operatorSchaltflaechen.removeAll()
        
        let operatoren: [OperatorTyp] = [.addieren, .subtrahieren, .multiplizieren, .dividieren]
        let schaltflaecheBreite: CGFloat = 70
        let abstand: CGFloat = 10
        let gesamtBreite = CGFloat(operatoren.count) * schaltflaecheBreite + CGFloat(operatoren.count - 1) * abstand
        // 使用容器的宽度而不是整个视图的宽度
        let containerBreite: CGFloat = 330 // 与约束中设置的宽度一致
        let startX = (containerBreite - gesamtBreite) / 2
        
        for (index, operator_) in operatoren.enumerated() {
            let x = startX + CGFloat(index) * (schaltflaecheBreite + abstand)
            let schaltflaeche = OperatorSchaltflaeche(frame: CGRect(x: x, y: 5, width: schaltflaecheBreite, height: 70))
            schaltflaeche.operatorTyp = operator_
            schaltflaeche.addTarget(self, action: #selector(operatorSchaltflaecheGedrueckt(_:)), for: .touchUpInside)
            
            operatorenContainerAnsicht.addSubview(schaltflaeche)
            operatorSchaltflaechen.append(schaltflaeche)
        }
    }
    
    // MARK: - Actions
    
    @objc private func schliessenGewaehlt() {
        coordinator?.spielBeenden()
    }
    
    private func kachelWurdeGewaehlt(_ kachel: MahjongKachel) {
        let aktion = viewModel.kachelWurdeAusgewaehlt(kachel)
        
        switch aktion {
        case .operatorErforderlich:
            zeigeHinweis(nachricht: "Please select an operator first!")
        case .erfolgreichSelektiert, .erfolgreichDeselektiert:
            aktualisiereBildschirm()
            aktualisiereKachelAnsichten()
        }
    }
    
    @objc private func operatorSchaltflaecheGedrueckt(_ sender: OperatorSchaltflaeche) {
        guard let operator_ = sender.operatorTyp else { return }
        viewModel.operatorWurdeAusgewaehlt(operator_)
    }
    
    @objc private func zuruecksetzenGewaehlt() {
        viewModel.zuruecksetzenAuswahl()
        aktualisiereKachelAnsichten()
    }
    
    @objc private func ueberpruefenGewaehlt() {
        viewModel.antwortEinreichen()
    }
    
    @objc private func auffrischenGewaehlt() {
        viewModel.auffrischenSpiel()
        erstelleKachelAnsichten()
    }
    
    // MARK: - Helper Methods
    
    private func aktualisiereKachelAnsichten() {
        for (index, ansicht) in kachelAnsichten.enumerated() {
            if index < viewModel.kacheln.count {
                ansicht.istAusgewaehlt = viewModel.kacheln[index].istAusgewaehlt
            }
        }
    }
    
    private func zeigeHinweis(nachricht: String) {
        DialogCoordinator.zeigeFehlerDialog(
            in: view,
            titel: "Notice",
            nachricht: nachricht
        )
    }
}

// MARK: - SpielViewModelDelegate

extension SpielViewController: SpielViewModelDelegate {
    
    func spielViewModelDidUpdate(_ viewModel: SpielViewModel) {
        aktualisiereBildschirm()
        
        // 只更新已存在的视图
        if !kachelAnsichten.isEmpty {
            aktualisiereKachelAnsichten()
        }
    }
    
    func spielViewModel(_ viewModel: SpielViewModel, didFinishMitErgebnis ergebnis: ValidierungsErgebnis) {
        switch ergebnis {
        case .korrekt(let punkte):
            // 积分已经在 ViewModel 中计算过了（punkte * level），不需要再次乘以 level
            // 注意：此时 viewModel.aktuellerLevel 已经 +1 了，所以这里只显示基础分
            let gesamtPunkte = punkte * (viewModel.aktuellerLevel - 1)
            zeigePartikelEffekt()
            
            DialogCoordinator.zeigeErfolgDialog(in: view, punkte: gesamtPunkte) { [weak self] in
                self?.viewModel.auffrischenSpiel()
                self?.erstelleKachelAnsichten()
            }
            
        case .zuWenigeKacheln(let mindestens):
            zeigeHinweis(nachricht: "Please select at least \(mindestens) tiles!")
            
        case .falscheOperatorAnzahl(let erwartet, let erhalten):
            zeigeHinweis(nachricht: "Expected \(erwartet) operators but got \(erhalten)!")
            
        case .falschesErgebnis(let erwartet, let erhalten):
            let erhaltString = String(format: "%.0f", erhalten)
            zeigeHinweis(nachricht: "Incorrect! Got \(erhaltString), expected \(erwartet)")
        }
    }
    
    func spielViewModel(_ viewModel: SpielViewModel, didUpdateZeit sekunden: Int) {
        zeitLabel.text = "⏱ \(sekunden)"
        
        if sekunden <= 10 {
            zeitLabel.textColor = .systemRed
            UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat]) {
                self.zeitLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }
    
    func spielViewModelDidEndSpiel(_ viewModel: SpielViewModel, mitPunktzahl punktzahl: Int, level: Int) {
        DialogCoordinator.zeigeZeitAbgelaufenDialog(
            in: view,
            punktzahl: punktzahl,
            level: level,
            neustart: { [weak self] in
                self?.viewModel.neustart()
                self?.erstelleKachelAnsichten()
            },
            beenden: { [weak self] in
                self?.coordinator?.spielBeenden()
            }
        )
    }
}
