//
//  SpielLogikManager.swift
//  MasterMath
//
//  Spiellogik Manager (Game Logic Manager)
//

import Foundation

// MARK: - Protokolle

/// Protokoll für Spiel-Generierung
protocol SpielGenerierer {
    func generiereSpiel(modus: SpielModus) -> SpielZustand
}

/// Protokoll für Antwort-Validierung
protocol AntwortValidierer {
    func validiereAntwort(
        kacheln: [MahjongKachel],
        operatoren: [OperatorTyp],
        zielWert: Int
    ) -> ValidierungsErgebnis
}

/// Protokoll für Lösbarkeits-Prüfung
protocol LoesbarkeitsChecker {
    func istLoesbar(zielWert: Int, kacheln: [MahjongKachel], konfiguration: SpielKonfiguration) -> Bool
}

/// Protokoll für Berechnungen
protocol Rechner {
    func berechne(kacheln: [MahjongKachel], operatoren: [OperatorTyp]) -> BerechnungsErgebnis
}

// MARK: - Spiel Zustand

struct SpielZustand {
    let zielWert: Int
    let kacheln: [MahjongKachel]
    let modus: SpielModus
    let erstellungsZeit: Date
    
    init(zielWert: Int, kacheln: [MahjongKachel], modus: SpielModus) {
        self.zielWert = zielWert
        self.kacheln = kacheln
        self.modus = modus
        self.erstellungsZeit = Date()
    }
}

// MARK: - Rechner Implementierung

final class StandardRechner: Rechner {
    
    func berechne(kacheln: [MahjongKachel], operatoren: [OperatorTyp]) -> BerechnungsErgebnis {
        guard !kacheln.isEmpty else {
            return BerechnungsErgebnis(wert: 0, fehler: .ungueltigerWert)
        }
        
        guard kacheln.count == operatoren.count + 1 else {
            return BerechnungsErgebnis(wert: 0, fehler: .ungueltigerWert)
        }
        
        // Berechne von links nach rechts
        var ergebnis = Double(kacheln[0].numerischerWert)
        
        for (index, operator_) in operatoren.enumerated() {
            let naechsterWert = Double(kacheln[index + 1].numerischerWert)
            let zwischenErgebnis = operator_.fuehreOperationAus(links: ergebnis, rechts: naechsterWert)
            
            if let fehler = zwischenErgebnis.fehler {
                return BerechnungsErgebnis(wert: 0, fehler: fehler)
            }
            
            ergebnis = zwischenErgebnis.wert
        }
        
        return BerechnungsErgebnis(wert: ergebnis, fehler: nil)
    }
}

// MARK: - Antwort Validierer Implementierung

final class StandardAntwortValidierer: AntwortValidierer {
    
    private let rechner: Rechner
    private let minimalAnzahlKacheln: Int
    
    init(rechner: Rechner, minimalAnzahlKacheln: Int = 3) {
        self.rechner = rechner
        self.minimalAnzahlKacheln = minimalAnzahlKacheln
    }
    
    func validiereAntwort(
        kacheln: [MahjongKachel],
        operatoren: [OperatorTyp],
        zielWert: Int
    ) -> ValidierungsErgebnis {
        
        // Prüfe Mindestanzahl
        guard kacheln.count >= minimalAnzahlKacheln else {
            return .zuWenigeKacheln(mindestens: minimalAnzahlKacheln)
        }
        
        // Prüfe Operator-Anzahl
        let erwarteteOperatorAnzahl = kacheln.count - 1
        guard operatoren.count == erwarteteOperatorAnzahl else {
            return .falscheOperatorAnzahl(
                erwartet: erwarteteOperatorAnzahl,
                erhalten: operatoren.count
            )
        }
        
        // Berechne Ergebnis
        let berechnungsErgebnis = rechner.berechne(kacheln: kacheln, operatoren: operatoren)
        
        guard berechnungsErgebnis.istGueltig else {
            return .falschesErgebnis(erwartet: zielWert, erhalten: 0)
        }
        
        // Prüfe ob korrekt (mit Toleranz für Gleitkomma-Fehler)
        let istKorrekt = abs(berechnungsErgebnis.wert - Double(zielWert)) < 0.001
        
        if istKorrekt {
            let punkte = berechneGrundbasis(kachelAnzahl: kacheln.count)
            return .korrekt(punkte: punkte)
        } else {
            return .falschesErgebnis(erwartet: zielWert, erhalten: berechnungsErgebnis.wert)
        }
    }
    
    private func berechneGrundbasis(kachelAnzahl: Int) -> Int {
        return 10 // Basis-Punkte, werden später mit Level multipliziert
    }
}

// MARK: - Lösbarkeits Checker Implementierung

final class StandardLoesbarkeitsChecker: LoesbarkeitsChecker {
    
    private let rechner: Rechner
    
    init(rechner: Rechner) {
        self.rechner = rechner
    }
    
    func istLoesbar(zielWert: Int, kacheln: [MahjongKachel], konfiguration: SpielKonfiguration) -> Bool {
        
        let minAnzahl = konfiguration.minimalKachelVerwendung
        let maxAnzahl = min(konfiguration.maximalKachelVerwendung, kacheln.count)
        
        for anzahl in minAnzahl...maxAnzahl {
            let kombinationen = generiereKombinationen(aus: kacheln, anzahl: anzahl)
            
            for kombination in kombinationen {
                if kannZielErreichen(ziel: zielWert, kacheln: kombination) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func kannZielErreichen(ziel: Int, kacheln: [MahjongKachel]) -> Bool {
        guard !kacheln.isEmpty else { return false }
        guard kacheln.count > 0 else { return false }
        
        if kacheln.count == 1 {
            return kacheln[0].numerischerWert == ziel
        }
        
        let permutationen = generierePermutationen(kacheln: kacheln)
        
        for permutation in permutationen {
            let anzahlOperatoren = permutation.count - 1
            let operatorKombinationen = generiereOperatorKombinationen(anzahl: anzahlOperatoren)
            
            for operatoren in operatorKombinationen {
                let ergebnis = rechner.berechne(kacheln: permutation, operatoren: operatoren)
                
                if ergebnis.istGueltig && abs(ergebnis.wert - Double(ziel)) < 0.001 {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func generiereKombinationen(aus kacheln: [MahjongKachel], anzahl: Int) -> [[MahjongKachel]] {
        if anzahl == 0 { return [[]] }
        if kacheln.isEmpty { return [] }
        
        let erste = kacheln[0]
        let rest = Array(kacheln.dropFirst())
        
        let mitErster = generiereKombinationen(aus: rest, anzahl: anzahl - 1).map { [erste] + $0 }
        let ohneErste = generiereKombinationen(aus: rest, anzahl: anzahl)
        
        return mitErster + ohneErste
    }
    
    private func generierePermutationen(kacheln: [MahjongKachel]) -> [[MahjongKachel]] {
        if kacheln.count <= 1 { return [kacheln] }
        
        var result: [[MahjongKachel]] = []
        
        for i in 0..<kacheln.count {
            let current = kacheln[i]
            var remaining = kacheln
            remaining.remove(at: i)
            
            let permutationenVonRest = generierePermutationen(kacheln: remaining)
            for permutation in permutationenVonRest {
                result.append([current] + permutation)
            }
        }
        
        return result
    }
    
    private func generiereOperatorKombinationen(anzahl: Int) -> [[OperatorTyp]] {
        if anzahl == 0 { return [[]] }
        if anzahl == 1 {
            return OperatorTyp.allCases.map { [$0] }
        }
        
        let kleinereKombinationen = generiereOperatorKombinationen(anzahl: anzahl - 1)
        var result: [[OperatorTyp]] = []
        
        for kombination in kleinereKombinationen {
            for operator_ in OperatorTyp.allCases {
                result.append(kombination + [operator_])
            }
        }
        
        return result
    }
}

// MARK: - Spiel Generierer Implementierung

final class StandardSpielGenerierer: SpielGenerierer {
    
    private let loesbarkeitsChecker: LoesbarkeitsChecker
    private let maxVersuche: Int
    
    init(loesbarkeitsChecker: LoesbarkeitsChecker, maxVersuche: Int = 100) {
        self.loesbarkeitsChecker = loesbarkeitsChecker
        self.maxVersuche = maxVersuche
    }
    
    func generiereSpiel(modus: SpielModus) -> SpielZustand {
        let konfiguration = modus.konfiguration
        var versuche = 0
        
        while versuche < maxVersuche {
            let zielWert = konfiguration.generiereZielWert()
            let kacheln = MahjongKachel.erstelleKachelSammlung(anzahl: konfiguration.kachelAnzahl)
            
            if loesbarkeitsChecker.istLoesbar(zielWert: zielWert, kacheln: kacheln, konfiguration: konfiguration) {
                return SpielZustand(zielWert: zielWert, kacheln: kacheln, modus: modus)
            }
            
            versuche += 1
        }
        
        // Fallback: garantiert lösbares Spiel
        return erstelleGarantiertLoesbaresSpiel(modus: modus, konfiguration: konfiguration)
    }
    
    private func erstelleGarantiertLoesbaresSpiel(modus: SpielModus, konfiguration: SpielKonfiguration) -> SpielZustand {
        let useMultiplication = Bool.random()
        
        let a: Int
        let b: Int
        let zielWert: Int
        
        if useMultiplication {
            a = Int.random(in: 3...9)
            b = Int.random(in: 3...9)
            zielWert = a * b
        } else {
            a = Int.random(in: 5...20)
            b = Int.random(in: 5...20)
            zielWert = a + b
        }
        
        var kacheln: [MahjongKachel] = [
            MahjongKachel(farbe: .freun, wert: a),
            MahjongKachel(farbe: .joirars, wert: b)
        ]
        
        while kacheln.count < konfiguration.kachelAnzahl {
            kacheln.append(MahjongKachel.erstelleZufaelligeKachel())
        }
        
        kacheln.shuffle()
        
        return SpielZustand(zielWert: zielWert, kacheln: kacheln, modus: modus)
    }
}

// MARK: - Haupt Spiel-Logik Manager (Facade)

final class SpielLogikManager {
    
    // MARK: Properties
    
    private let spielGenerierer: SpielGenerierer
    private let antwortValidierer: AntwortValidierer
    
    // MARK: Shared Instance
    
    static let shared: SpielLogikManager = {
        let rechner = StandardRechner()
        let loesbarkeitsChecker = StandardLoesbarkeitsChecker(rechner: rechner)
        let spielGenerierer = StandardSpielGenerierer(loesbarkeitsChecker: loesbarkeitsChecker)
        let antwortValidierer = StandardAntwortValidierer(rechner: rechner)
        
        return SpielLogikManager(
            spielGenerierer: spielGenerierer,
            antwortValidierer: antwortValidierer
        )
    }()
    
    // MARK: Initialization
    
    init(spielGenerierer: SpielGenerierer, antwortValidierer: AntwortValidierer) {
        self.spielGenerierer = spielGenerierer
        self.antwortValidierer = antwortValidierer
    }
    
    // MARK: Public Methods
    
    func generiereSpiel(modus: SpielModus) -> SpielZustand {
        return spielGenerierer.generiereSpiel(modus: modus)
    }
    
    func validiereAntwort(
        ausgewaehlteKacheln: [MahjongKachel],
        ausgewaehlteOperatoren: [OperatorTyp],
        zielWert: Int
    ) -> ValidierungsErgebnis {
        return antwortValidierer.validiereAntwort(
            kacheln: ausgewaehlteKacheln,
            operatoren: ausgewaehlteOperatoren,
            zielWert: zielWert
        )
    }
    
    // MARK: Legacy Compatibility
    
    @available(*, deprecated, message: "Use generiereSpiel(modus:) instead")
    static func generiereSpiel(modus: SpielModus) -> (zielWert: Int, kacheln: [MahjongKachel]) {
        let zustand = shared.generiereSpiel(modus: modus)
        return (zustand.zielWert, zustand.kacheln)
    }
    
    @available(*, deprecated, message: "Use shared.validiereAntwort instead")
    static func validiereAntwort(
        ausgewaehlteKacheln: [MahjongKachel],
        ausgewaehlteOperatoren: [OperatorTyp],
        zielWert: Int
    ) -> ValidierungsErgebnis {
        return shared.validiereAntwort(
            ausgewaehlteKacheln: ausgewaehlteKacheln,
            ausgewaehlteOperatoren: ausgewaehlteOperatoren,
            zielWert: zielWert
        )
    }
}

// MARK: - Punktzahl Manager (Score Manager)

protocol PunktzahlSpeicher {
    func holePunktzahl(fuerModus modus: SpielModus) -> Int
    func speicherePunktzahl(_ punktzahl: Int, fuerModus modus: SpielModus)
}

final class PunktzahlManager: PunktzahlSpeicher {
    
    // MARK: Shared Instance
    
    static let shared = PunktzahlManager()
    
    // MARK: Properties
    
    private let schluesselEinfach = "punktzahl_einfach"
    private let schluesselSchwierig = "punktzahl_schwierig"
    private let schluesselZeit = "punktzahl_zeit"
    private let speicher: UserDefaults
    
    // MARK: Initialization
    
    init(speicher: UserDefaults = .standard) {
        self.speicher = speicher
    }
    
    // MARK: Public Methods
    
    func holePunktzahl(fuerModus modus: SpielModus) -> Int {
        let schluessel = schluesselFuerModus(modus)
        return speicher.integer(forKey: schluessel)
    }
    
    func speicherePunktzahl(_ punktzahl: Int, fuerModus modus: SpielModus) {
        let schluessel = schluesselFuerModus(modus)
        let aktuellePunktzahl = holePunktzahl(fuerModus: modus)
        if punktzahl > aktuellePunktzahl {
            speicher.set(punktzahl, forKey: schluessel)
        }
    }
    
    func aktualisierePunktzahl(_ punktzahl: Int, fuerModus modus: SpielModus) {
        let schluessel = schluesselFuerModus(modus)
        speicher.set(punktzahl, forKey: schluessel)
    }
    
    func zuruecksetzenAllePunktzahlen() {
        SpielModus.allCases.forEach { modus in
            aktualisierePunktzahl(0, fuerModus: modus)
        }
    }
    
    // MARK: Private Methods
    
    private func schluesselFuerModus(_ modus: SpielModus) -> String {
        switch modus {
        case .einfach: return schluesselEinfach
        case .schwierig: return schluesselSchwierig
        case .zeit: return schluesselZeit
        }
    }
}
