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
            print("rdk showRootController")
//            showRootController()
            let rootVC = RootViewController()
            viewControllers = [rootVC]
        } else {
            print("rdk showEnvironmentController")
//            showEnvironmentController()
            let environmentViewController = EnvironmentViewController()
            viewControllers = [environmentViewController]
        }
        tryPlayingAssetIfPossible()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        tryPlayingAssetIfPossible()
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        tryPlayingAssetIfPossible()
//    }
    
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
        if let qrCodeData, qrCodeData.isContentAssetAvailable {
            showPlayerController(
                qrCodeData: qrCodeData,
                environment: StorageProvider.storedEnvironment
            )
        }
    }
    
    private func showPlayerController(
        qrCodeData: QRCodeData,
        environment: Environment?
    ) {
        print("rdk showPlayerController")
        
//        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        

        
            guard
                let source = qrCodeData.urlParams?.source
            else {
                return
            }
            
            let playerVC = PlayerViewController()
            
        if qrCodeData.isSourceAssetURL,
           let sourceURL = URL(string: source) {
            /// assetURL
            playerVC.shouldPlayWithUrl = true
            playerVC.urlPlayable = URLPlayable(url: sourceURL)
            viewControllers.append(playerVC)
        } else if let sessionToken = qrCodeData.urlParams?.sessionToken,
                    let environment = StorageProvider.storedEnvironment {
            /// assetID
            playerVC.sessionToken = SessionToken(value: sessionToken)
        
            
            playerVC.sessionToken = StorageProvider.storedSessionToken
            playerVC.environment = environment // rdk is it obligatory?
            playerVC.shouldPlayWithUrl = false
            playerVC.playable = AssetPlayable(assetId: source)
            viewControllers.append(playerVC)
            print("rdk append VIDEO")
        }
       
        
    }
}
