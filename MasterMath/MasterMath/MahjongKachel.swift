//
//  MahjongKachel.swift
//  MasterMath
//
//  Mahjong-Kachel Datenmodell (Mahjong Tile Data Model)
//

import UIKit

// MARK: - Protokolle (Protocols)

/// Protokoll für Werte die berechenbar sind
protocol Berechenbar {
    var numerischerWert: Int { get }
}

/// Protokoll für auswählbare Elemente
protocol Auswaehlbar: AnyObject {
    var istAusgewaehlt: Bool { get set }
    var eindeutigeID: UUID { get }
}

/// Protokoll für visuelle Darstellung
protocol VisuellDarstellbar {
    var bildName: String { get }
    var darstellungsFarbe: UIColor { get }
}

// MARK: - Enumerations

/// Mahjong-Farbe Typ (Mahjong Color Type)
enum MahjongFarbe: String, CaseIterable, Codable {
    case freun = "Freun"
    case joirars = "Joirars"
    case sortie = "Sortie"
    
    var zugehoerigeFarbe: UIColor {
        switch self {
        case .freun: return .systemRed
        case .joirars: return .systemBlue
        case .sortie: return .systemGreen
        }
    }
    
    static func zufaellig() -> MahjongFarbe {
        return allCases.randomElement() ?? .freun
    }
}

/// Operator Typ
enum OperatorTyp: String, CaseIterable, Codable {
    case addieren = "Operator_add"
    case subtrahieren = "Operator_subtract"
    case multiplizieren = "Operator_multiply"
    case dividieren = "Operator_divide"
    
    var symbol: String {
        switch self {
        case .addieren: return "+"
        case .subtrahieren: return "-"
        case .multiplizieren: return "×"
        case .dividieren: return "÷"
        }
    }
    
    var prioritaet: Int {
        switch self {
        case .addieren, .subtrahieren: return 1
        case .multiplizieren, .dividieren: return 2
        }
    }
}

// MARK: - Berechnung Extension

extension OperatorTyp {
    func fuehreOperationAus(links: Double, rechts: Double) -> BerechnungsErgebnis {
        let resultat: Double
        var fehler: BerechnungsFehler?
        
        switch self {
        case .addieren:
            resultat = links + rechts
        case .subtrahieren:
            resultat = links - rechts
        case .multiplizieren:
            resultat = links * rechts
        case .dividieren:
            if rechts == 0 {
                fehler = .divisionDurchNull
                resultat = 0
            } else {
                resultat = links / rechts
            }
        }
        
        return BerechnungsErgebnis(wert: resultat, fehler: fehler)
    }
}

// MARK: - Berechnung Models

struct BerechnungsErgebnis {
    let wert: Double
    let fehler: BerechnungsFehler?
    
    var istGueltig: Bool { fehler == nil }
}

enum BerechnungsFehler: Error {
    case divisionDurchNull
    case ungueltigerWert
}

// MARK: - Mahjong-Kachel Modell

class MahjongKachel: Auswaehlbar, Berechenbar, VisuellDarstellbar {
    
    // MARK: Properties
    
    let farbe: MahjongFarbe
    private(set) var wert: Int
    let eindeutigeID: UUID
    var istAusgewaehlt: Bool
    
    // MARK: Computed Properties
    
    var bildName: String {
        "\(farbe.rawValue)_\(wert)"
    }
    
    var darstellungsFarbe: UIColor {
        farbe.zugehoerigeFarbe
    }
    
    var numerischerWert: Int {
        wert
    }
    
    // MARK: Initialization
    
    init(farbe: MahjongFarbe, wert: Int, eindeutigeID: UUID = UUID()) {
        self.farbe = farbe
        self.wert = min(max(wert, 1), 9) // Begrenze auf 1-9
        self.eindeutigeID = eindeutigeID
        self.istAusgewaehlt = false
    }
    
    // MARK: Factory Methods
    
    static func erstelleZufaelligeKachel() -> MahjongKachel {
        let farbe = MahjongFarbe.zufaellig()
        let wert = Int.random(in: 1...9)
        return MahjongKachel(farbe: farbe, wert: wert)
    }
    
    static func erstelleKachelSammlung(anzahl: Int) -> [MahjongKachel] {
        return (0..<anzahl).map { _ in erstelleZufaelligeKachel() }
    }
    
    // MARK: Methods
    
    func zuruecksetzen() {
        istAusgewaehlt = false
    }
    
    func kopiere() -> MahjongKachel {
        return MahjongKachel(farbe: farbe, wert: wert, eindeutigeID: UUID())
    }
}

// MARK: - Equatable

extension MahjongKachel: Equatable {
    static func == (lhs: MahjongKachel, rhs: MahjongKachel) -> Bool {
        return lhs.eindeutigeID == rhs.eindeutigeID
    }
}

// MARK: - Spiel-Modus (Game Mode)

enum SpielModus: String, CaseIterable {
    case einfach = "Simple Mode"
    case schwierig = "Hard Mode"
    case zeit = "Time Mode"
    
    var konfiguration: SpielKonfiguration {
        switch self {
        case .einfach:
            return SpielKonfiguration(
                kachelAnzahl: 5,
                minimalKachelVerwendung: 3,
                maximalKachelVerwendung: 5,
                zielWertBereich: 10...100,
                hatZeitLimit: false,
                zeitLimitInSekunden: 0
            )
        case .schwierig:
            return SpielKonfiguration(
                kachelAnzahl: 10,
                minimalKachelVerwendung: 3,
                maximalKachelVerwendung: 6,
                zielWertBereich: 10...100,
                hatZeitLimit: false,
                zeitLimitInSekunden: 0
            )
        case .zeit:
            return SpielKonfiguration(
                kachelAnzahl: 5,
                minimalKachelVerwendung: 3,
                maximalKachelVerwendung: 5,
                zielWertBereich: 10...100,
                hatZeitLimit: true,
                zeitLimitInSekunden: 60
            )
        }
    }
}

// MARK: - Spiel Konfiguration

struct SpielKonfiguration {
    let kachelAnzahl: Int
    let minimalKachelVerwendung: Int
    let maximalKachelVerwendung: Int
    let zielWertBereich: ClosedRange<Int>
    let hatZeitLimit: Bool
    let zeitLimitInSekunden: Int
    
    func generiereZielWert() -> Int {
        return Int.random(in: zielWertBereich)
    }
}

// MARK: - Validierungs Ergebnis

enum ValidierungsErgebnis {
    case korrekt(punkte: Int)
    case zuWenigeKacheln(mindestens: Int)
    case falscheOperatorAnzahl(erwartet: Int, erhalten: Int)
    case falschesErgebnis(erwartet: Int, erhalten: Double)
    
    var istErfolgreich: Bool {
        if case .korrekt = self { return true }
        return false
    }
    
    var fehlerbeschreibung: String? {
        switch self {
        case .korrekt:
            return nil
        case .zuWenigeKacheln(let mindestens):
            return "Bitte wähle mindestens \(mindestens) Kacheln aus."
        case .falscheOperatorAnzahl(let erwartet, let erhalten):
            return "Benötigt \(erwartet) Operatoren, aber \(erhalten) wurden ausgewählt."
        case .falschesErgebnis(let erwartet, let erhalten):
            return "Erwartet: \(erwartet), Erhalten: \(Int(erhalten))"
        }
    }
}
