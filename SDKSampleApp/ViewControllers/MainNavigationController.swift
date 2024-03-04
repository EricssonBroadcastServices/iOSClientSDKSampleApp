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

    var qrCodeData: QRCodeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if StorageProvider.storedSessionToken != nil {
            showRootController()
        } else {
            showEnvironmentController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tryPlayingAssetIfPossible()
    }
    
    /// Show Root (main) view if user not logged in
    private func showRootController() {
        let vc = RootViewController()
        viewControllers = [vc]
    }
    
    /// Show Enviornment view if user not logged in
    private func showEnvironmentController() {
        let vc = EnvironmentViewController()
//        vc.tryAutoLogIn = qrCodeData?.isAnonymousLoginPossible ?? false // rdk
        viewControllers = [vc]
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - QR Code related funcs

extension MainNavigationController {
    
    func tryPlayingAssetIfPossible() {
        guard
            let environment = StorageProvider.storedEnvironment
        else {
            return
        }

    if let qrCodeData, qrCodeData.isContentAssetAvailable {
            showPlayerController(
                qrCodeData: qrCodeData,
                environment: environment
            )
        }
    }
    
    private func showPlayerController(
        qrCodeData: QRCodeData,
        environment: Environment
    ) {
        guard
            let source = qrCodeData.urlParams?.source,
            qrCodeData.urlParams?.sessionToken != nil
        else {
            return
        }
        
        let playerVC = PlayerViewController()
        
        playerVC.environment = environment
        playerVC.sessionToken = StorageProvider.storedSessionToken
        
        if qrCodeData.isSourceAssetURL,
        let sourceURL = URL(string: source) {
            playerVC.shouldPlayWithUrl = true
            playerVC.urlPlayable = URLPlayable(url: sourceURL)
            viewControllers.append(playerVC)
        } else if playerVC.sessionToken != nil {
            playerVC.shouldPlayWithUrl = false
            playerVC.playable = AssetPlayable(assetId: source)
            viewControllers.append(playerVC)
        }
        
    }
}
