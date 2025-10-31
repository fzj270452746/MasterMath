
import UIKit

// MARK: - Coordinator Protokoll

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController? { get set }
    
    func start()
    func childDidFinish(_ child: Coordinator)
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}

// MARK: - Haupt Coordinator

final class HauptCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    private weak var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let hauptViewController = HauptViewController()
        hauptViewController.coordinator = self
        
        window?.rootViewController = hauptViewController
        window?.makeKeyAndVisible()
    }
    
    func zeigeSpiel(modus: SpielModus, von viewController: UIViewController) {
        let spielCoordinator = SpielCoordinator(modus: modus)
        spielCoordinator.parentCoordinator = self
        childCoordinators.append(spielCoordinator)
        spielCoordinator.start(von: viewController)
    }
    
    func zeigeRangliste(von viewController: UIViewController) {
        let ranglisteViewController = RanglisteViewController()
        ranglisteViewController.modalPresentationStyle = .pageSheet
        viewController.present(ranglisteViewController, animated: true)
    }
    
    func zeigeEinstellungen(von viewController: UIViewController) {
        let einstellungenViewController = EinstellungenViewController()
        einstellungenViewController.modalPresentationStyle = .pageSheet
        viewController.present(einstellungenViewController, animated: true)
    }
}

// MARK: - Spiel Coordinator

final class SpielCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    weak var parentCoordinator: HauptCoordinator?
    private let modus: SpielModus
    private weak var presentingViewController: UIViewController?
    
    init(modus: SpielModus) {
        self.modus = modus
    }
    
    func start() {
        // Diese Methode wird nicht verwendet, da wir start(von:) nutzen
    }
    
    func start(von viewController: UIViewController) {
        let viewModel = SpielViewModel(modus: modus)
        let spielViewController = SpielViewController(viewModel: viewModel)
        spielViewController.coordinator = self
        spielViewController.modalPresentationStyle = .fullScreen
        
        presentingViewController = viewController
        viewController.present(spielViewController, animated: true)
    }
    
    func spielBeenden() {
        presentingViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.childDidFinish(self)
        }
    }
}

// MARK: - Dialog Coordinator (Helper)

final class DialogCoordinator {
    
    static func zeigeDialog(
        in view: UIView,
        titel: String,
        nachricht: String,
        schaltflaechenTitel: [String],
        aktion: ((Int) -> Void)? = nil
    ) {
        let dialog = BenutzerdefinierteDialogansicht(
            titel: titel,
            nachricht: nachricht,
            schaltflaechenTitel: schaltflaechenTitel
        )
        dialog.schaltflaechenAktion = aktion
        dialog.anzeigen(in: view)
    }
    
    static func zeigeErfolgDialog(
        in view: UIView,
        punkte: Int,
        aktion: (() -> Void)? = nil
    ) {
        let dialog = BenutzerdefinierteDialogansicht(
            titel: "🎉 Correct!",
            nachricht: "Well done! +\(punkte) points",
            schaltflaechenTitel: ["Continue"]
        )
        dialog.schaltflaechenAktion = { _ in aktion?() }
        dialog.anzeigen(in: view)
    }
    
    static func zeigeFehlerDialog(
        in view: UIView,
        titel: String,
        nachricht: String
    ) {
        zeigeDialog(
            in: view,
            titel: titel,
            nachricht: nachricht,
            schaltflaechenTitel: ["OK"]
        )
    }
    
    static func zeigeZeitAbgelaufenDialog(
        in view: UIView,
        punktzahl: Int,
        level: Int,
        neustart: @escaping () -> Void,
        beenden: @escaping () -> Void
    ) {
        let dialog = BenutzerdefinierteDialogansicht(
            titel: "⏰ Time's Up!",
            nachricht: "Final Score: \(punktzahl)\nLevel: \(level)",
            schaltflaechenTitel: ["Play Again", "Exit"]
        )
        dialog.schaltflaechenAktion = { index in
            if index == 0 {
                neustart()
            } else {
                beenden()
            }
        }
        dialog.anzeigen(in: view)
    }
}


