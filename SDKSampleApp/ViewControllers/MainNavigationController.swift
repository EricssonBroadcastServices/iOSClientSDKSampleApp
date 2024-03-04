//
//  MainNavigationController.swift
//  RefApp
//
//  Created by Udaya Sri Senarathne on 2018-11-21.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import iOSClientExposure
import iOSClientExposurePlayback

/// Handles the main navigation in the app
class MainNavigationController: UINavigationController {
    
    private var assetID: String? = "b74e3719-3ef0-481a-8014-40fa7cea2402_82162E"
    
//    init(
//        rootViewController: UIViewController,
//        assetID: String? = nil
//    ) {
//        super.init(rootViewController: rootViewController)
//        // Additional custom initialization code if needed
//    }
    
//    public init(
//        assetID: String? = nil
//    ) {
//        super.init(rootViewController: <#T##UIViewController#>)
//        self.assetID = assetID
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StorageProvider.storedSessionToken != nil {
            showRootController()
        } else {
            showEnvironmentController()
        }
        
        guard 
            let environment = StorageProvider.storedEnvironment
        else {
            return
        }
        
        if let assetID {
            showPlayerController(
                assetID: assetID,
                environment: environment
            )
        }
    }
    
    /// Show Root (main) view if user not logged in
    private func showRootController() {
        viewControllers = [RootViewController()]
    }
    
    /// Show Enviornment view if user not logged in
    private func showEnvironmentController() {
        viewControllers = [EnvironmentViewController()]
    }
    
    private func showPlayerController(
        assetID: String,
        environment: Environment
    ) {
        let playerVC = PlayerViewController()
        
        playerVC.environment = environment
        playerVC.sessionToken = StorageProvider.storedSessionToken //  rdk this should be optional - if not provided then crash
        
        let properties = PlaybackProperties(
            autoplay: true,
            playFrom: .bookmark
        )
        
        playerVC.playbackProperties = properties
        playerVC.playable = AssetPlayable(assetId: assetID)
        
        viewControllers.append(playerVC)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


