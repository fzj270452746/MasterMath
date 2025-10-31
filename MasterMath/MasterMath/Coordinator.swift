
import UIKit

// MARK: - Orchestrator Protocol

protocol Orchestrator: AnyObject {
    var childOrchestrators: [Orchestrator] { get set }
    var navigationController: UINavigationController? { get set }
    
    func commence()
    func childDidComplete(_ child: Orchestrator)
}

extension Orchestrator {
    func childDidComplete(_ child: Orchestrator) {
        childOrchestrators.removeAll { $0 === child }
    }
}

// MARK: - Primary Orchestrator

final class PrimaryOrchestrator: Orchestrator {
    
    var childOrchestrators: [Orchestrator] = []
    var navigationController: UINavigationController?
    
    private weak var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func commence() {
        let primaryPresenter = PrimaryPresenter()
        primaryPresenter.orchestrator = self
        
        window?.rootViewController = primaryPresenter
        window?.makeKeyAndVisible()
    }
    
    func displayQuest(mode: ChallengeMode, from presenter: UIViewController) {
        let questOrchestrator = QuestOrchestrator(mode: mode)
        questOrchestrator.parentOrchestrator = self
        childOrchestrators.append(questOrchestrator)
        questOrchestrator.commence(from: presenter)
    }
    
    func displayLeaderboard(from presenter: UIViewController) {
        let leaderboardPresenter = LeaderboardPresenter()
        leaderboardPresenter.modalPresentationStyle = .pageSheet
        presenter.present(leaderboardPresenter, animated: true)
    }
    
    func displaySettings(from presenter: UIViewController) {
        let settingsPresenter = SettingsPresenter()
        settingsPresenter.modalPresentationStyle = .pageSheet
        presenter.present(settingsPresenter, animated: true)
    }
}

// MARK: - Quest Orchestrator

final class QuestOrchestrator: Orchestrator {
    
    var childOrchestrators: [Orchestrator] = []
    var navigationController: UINavigationController?
    
    weak var parentOrchestrator: PrimaryOrchestrator?
    private let mode: ChallengeMode
    private weak var presentingViewController: UIViewController?
    
    init(mode: ChallengeMode) {
        self.mode = mode
    }
    
    func commence() {
        // This method is not used, as we use commence(from:) instead
    }
    
    func commence(from presenter: UIViewController) {
        let mediator = QuestMediator(mode: mode)
        let questPresenter = QuestPresenter(mediator: mediator)
        questPresenter.orchestrator = self
        questPresenter.modalPresentationStyle = .fullScreen
        
        presentingViewController = presenter
        presenter.present(questPresenter, animated: true)
    }
    
    func concludeQuest() {
        presentingViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentOrchestrator?.childDidComplete(self)
        }
    }
}

// MARK: - Dialog Orchestrator (Helper)

final class DialogOrchestrator {
    
    static func displayDialog(
        in view: UIView,
        title: String,
        message: String,
        buttonTitles: [String],
        action: ((Int) -> Void)? = nil
    ) {
        let dialog = CustomDialogView(
            title: title,
            message: message,
            buttonTitles: buttonTitles
        )
        dialog.buttonAction = action
        dialog.display(in: view)
    }
    
    static func displaySuccessDialog(
        in view: UIView,
        points: Int,
        action: (() -> Void)? = nil
    ) {
        let dialog = CustomDialogView(
            title: "🎉 Correct!",
            message: "Well done! +\(points) points",
            buttonTitles: ["Continue"]
        )
        dialog.buttonAction = { _ in action?() }
        dialog.display(in: view)
    }
    
    static func displayErrorDialog(
        in view: UIView,
        title: String,
        message: String
    ) {
        displayDialog(
            in: view,
            title: title,
            message: message,
            buttonTitles: ["OK"]
        )
    }
    
    static func displayTimeExpiredDialog(
        in view: UIView,
        score: Int,
        level: Int,
        restart: @escaping () -> Void,
        exit: @escaping () -> Void
    ) {
        let dialog = CustomDialogView(
            title: "⏰ Time's Up!",
            message: "Final Score: \(score)\nLevel: \(level)",
            buttonTitles: ["Play Again", "Exit"]
        )
        dialog.buttonAction = { index in
            if index == 0 {
                restart()
            } else {
                exit()
            }
        }
        dialog.display(in: view)
    }
}
