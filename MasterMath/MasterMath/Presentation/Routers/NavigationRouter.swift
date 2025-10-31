//
//  NavigationRouter.swift
//  MasterMath
//
//  Presentation Layer - Navigation Router
//

import UIKit

protocol NavigationRouterProtocol: AnyObject {
    func presentGameScreen(mode: GameModeEntity, from: UIViewController)
    func presentLeaderboardScreen(from: UIViewController)
    func presentSettingsScreen(from: UIViewController)
    func dismiss(from: UIViewController)
}

final class NavigationRouter: NavigationRouterProtocol {
    
    private let eventBus: EventBusProtocol
    private let commandHandler: CommandHandlerProtocol
    
    init(
        eventBus: EventBusProtocol,
        commandHandler: CommandHandlerProtocol
    ) {
        self.eventBus = eventBus
        self.commandHandler = commandHandler
    }
    
    func presentGameScreen(mode: GameModeEntity, from: UIViewController) {
        let gameViewController = GamePlayViewController(
            mode: mode,
            eventBus: eventBus,
            commandHandler: commandHandler,
            router: self
        )
        gameViewController.modalPresentationStyle = .fullScreen
        from.present(gameViewController, animated: true)
    }
    
    func presentLeaderboardScreen(from: UIViewController) {
        let leaderboardViewController = LeaderboardViewController(
            eventBus: eventBus,
            router: self
        )
        leaderboardViewController.modalPresentationStyle = .pageSheet
        from.present(leaderboardViewController, animated: true)
    }
    
    func presentSettingsScreen(from: UIViewController) {
        let settingsViewController = SettingsViewController(
            eventBus: eventBus,
            router: self
        )
        settingsViewController.modalPresentationStyle = .pageSheet
        from.present(settingsViewController, animated: true)
    }
    
    func dismiss(from: UIViewController) {
        from.dismiss(animated: true)
    }
}

