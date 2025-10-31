//
//  SpielViewModel.swift
//  MasterMath
//
//  Spiel ViewModel - MVVM Pattern
//

import Foundation

// MARK: - Protokolle

protocol SpielViewModelDelegate: AnyObject {
    func spielViewModelDidUpdate(_ viewModel: SpielViewModel)
    func spielViewModel(_ viewModel: SpielViewModel, didFinishMitErgebnis ergebnis: ValidierungsErgebnis)
    func spielViewModel(_ viewModel: SpielViewModel, didUpdateZeit sekunden: Int)
    func spielViewModelDidEndSpiel(_ viewModel: SpielViewModel, mitPunktzahl punktzahl: Int, level: Int)
}

// MARK: - Spiel ViewModel

final class SpielViewModel {
    
    // MARK: Properties
    
    weak var delegate: SpielViewModelDelegate?
    
    private let spielLogikManager: SpielLogikManager
    private let punktzahlManager: PunktzahlManager
    private let modus: SpielModus
    
    private(set) var spielZustand: SpielZustand?
    private(set) var ausgewaehlteKacheln: [MahjongKachel] = []
    private(set) var ausgewaehlteOperatoren: [OperatorTyp] = []
    private(set) var aktuellerPunktzahl: Int = 0
    private(set) var aktuellerLevel: Int = 1
    private(set) var zeitVerbleibend: Int
    
    private var timer: Timer?
    private var letzteAuswahl: AuswahlTyp = .keine
    
    // MARK: Computed Properties
    
    var zielWert: Int {
        return spielZustand?.zielWert ?? 0
    }
    
    var kacheln: [MahjongKachel] {
        return spielZustand?.kacheln ?? []
    }
    
    var auswahlText: String {
        guard !ausgewaehlteKacheln.isEmpty else {
            return "Select tiles and operators"
        }
        
        var text = ""
        for i in 0..<ausgewaehlteKacheln.count {
            text += "\(ausgewaehlteKacheln[i].numerischerWert)"
            if i < ausgewaehlteOperatoren.count {
                text += " \(ausgewaehlteOperatoren[i].symbol) "
            }
        }
        return text
    }
    
    var kannEinreichen: Bool {
        return ausgewaehlteKacheln.count >= 3 && 
               ausgewaehlteOperatoren.count == ausgewaehlteKacheln.count - 1
    }
    
    var hatZeitLimit: Bool {
        return modus.konfiguration.hatZeitLimit
    }
    
    // MARK: Nested Types
    
    private enum AuswahlTyp {
        case keine
        case kachel
        case operatorTyp
    }
    
    // MARK: Initialization
    
    init(
        modus: SpielModus,
        spielLogikManager: SpielLogikManager = .shared,
        punktzahlManager: PunktzahlManager = .shared
    ) {
        self.modus = modus
        self.spielLogikManager = spielLogikManager
        self.punktzahlManager = punktzahlManager
        self.zeitVerbleibend = modus.konfiguration.zeitLimitInSekunden
    }
    
    deinit {
        stoppeTimer()
    }
    
    // MARK: Public Methods - Spielablauf
    
    func starteNeuesSpiel() {
        spielZustand = spielLogikManager.generiereSpiel(modus: modus)
        zuruecksetzenAuswahl()
        delegate?.spielViewModelDidUpdate(self)
        
        if hatZeitLimit && timer == nil {
            starteTimer()
        }
    }
    
    func auffrischenSpiel() {
        kacheln.forEach { $0.zuruecksetzen() }
        zuruecksetzenAuswahl()
        starteNeuesSpiel()
    }
    
    func neustart() {
        aktuellerPunktzahl = 0
        aktuellerLevel = 1
        zeitVerbleibend = modus.konfiguration.zeitLimitInSekunden
        zuruecksetzenAuswahl()
        starteNeuesSpiel()
    }
    
    func spielBeenden() {
        stoppeTimer()
        punktzahlManager.speicherePunktzahl(aktuellerPunktzahl, fuerModus: modus)
        delegate?.spielViewModelDidEndSpiel(self, mitPunktzahl: aktuellerPunktzahl, level: aktuellerLevel)
    }
    
    // MARK: Public Methods - Auswahl
    
    func kachelWurdeAusgewaehlt(_ kachel: MahjongKachel) -> AuswahlAktion {
        // Prüfe auf konsekutive Kachel-Auswahl
        if letzteAuswahl == .kachel && !kachel.istAusgewaehlt {
            return .operatorErforderlich
        }
        
        if kachel.istAusgewaehlt {
            // Deselektieren
            kachel.istAusgewaehlt = false
            ausgewaehlteKacheln.removeAll { $0.eindeutigeID == kachel.eindeutigeID }
            
            if ausgewaehlteKacheln.isEmpty {
                letzteAuswahl = .keine
            }
            return .erfolgreichDeselektiert
        } else {
            // Selektieren
            kachel.istAusgewaehlt = true
            ausgewaehlteKacheln.append(kachel)
            letzteAuswahl = .kachel
            delegate?.spielViewModelDidUpdate(self)
            return .erfolgreichSelektiert
        }
    }
    
    func operatorWurdeAusgewaehlt(_ operator_: OperatorTyp) {
        ausgewaehlteOperatoren.append(operator_)
        letzteAuswahl = .operatorTyp
        delegate?.spielViewModelDidUpdate(self)
    }
    
    func zuruecksetzenAuswahl() {
        ausgewaehlteKacheln.forEach { $0.istAusgewaehlt = false }
        ausgewaehlteKacheln.removeAll()
        ausgewaehlteOperatoren.removeAll()
        letzteAuswahl = .keine
        delegate?.spielViewModelDidUpdate(self)
    }
    
    // MARK: Public Methods - Validierung
    
    func antwortEinreichen() {
        let ergebnis = spielLogikManager.validiereAntwort(
            ausgewaehlteKacheln: ausgewaehlteKacheln,
            ausgewaehlteOperatoren: ausgewaehlteOperatoren,
            zielWert: zielWert
        )
        
        if case .korrekt(let punkte) = ergebnis {
            aktuellerPunktzahl += punkte * aktuellerLevel
            aktuellerLevel += 1
        }
        
        delegate?.spielViewModel(self, didFinishMitErgebnis: ergebnis)
    }
    
    // MARK: Private Methods - Timer
    
    private func starteTimer() {
        zeitVerbleibend = modus.konfiguration.zeitLimitInSekunden
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    private func stoppeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick() {
        zeitVerbleibend -= 1
        delegate?.spielViewModel(self, didUpdateZeit: zeitVerbleibend)
        
        if zeitVerbleibend <= 0 {
            spielBeenden()
        }
    }
}

// MARK: - Auswahl Aktion

enum AuswahlAktion {
    case erfolgreichSelektiert
    case erfolgreichDeselektiert
    case operatorErforderlich
}


