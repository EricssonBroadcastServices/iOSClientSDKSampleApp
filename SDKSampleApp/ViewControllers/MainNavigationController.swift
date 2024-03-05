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
        print("rdk showPlayerController")
        guard
            let source = qrCodeData.urlParams?.source
//            let sessionToken = qrCodeData.urlParams?.sessionToken
        else {
            return
        }
        
//        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        
//        Authenticate(environment: environment)
//            .validate(sessionToken: SessionToken(value: sessionToken))
//            .request()
//            .validate()
//            .response { [weak self] in
//                
//                if let error = $0.error {
//                    print("RDK wrong session token")
//                } else {
//                    print("RDK OK session token")
//                }
//                
//                if let error = $0.error {
//                    
//                    let message = "\(error.code) " + error.message + "\n" + (error.info ?? "")
//                    self?.popupAlert(title: error.domain , message: message, actions: [okAction], preferedStyle: .alert)
//                } else {
//                    if let credentials = $0.value {
//                        
//                        StorageProvider.store(environment: environment)
//                        //                        StorageProvider.store(sessionToken: credentials.sessionToken)
//                        
//                                    guard
//                                        let source = qrCodeData.urlParams?.source,
//                                        qrCodeData.urlParams?.sessionToken != nil
//                                    else {
//                                        return
//                                    }
//                        
//                                    let playerVC = PlayerViewController()
//                        
//                                    playerVC.environment = environment
//                                    playerVC.sessionToken = StorageProvider.storedSessionToken
//                        
//                                    if qrCodeData.isSourceAssetURL,
//                                    let sourceURL = URL(string: source) {
//                                        playerVC.shouldPlayWithUrl = true
//                                        playerVC.urlPlayable = URLPlayable(url: sourceURL)
//                                        self?.viewControllers.append(playerVC)
//                                    } else if playerVC.sessionToken != nil {
//                                        playerVC.shouldPlayWithUrl = false
//                                        playerVC.playable = AssetPlayable(assetId: source)
//                                        self?.viewControllers.append(playerVC)
//                                    }
//                    }
//                }
//                
//                
//            }
        
//        Task {
            guard
                let source = qrCodeData.urlParams?.source
//                qrCodeData.urlParams?.sessionToken != nil
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
                print("rdk append VIDEO")
            }
//        }
       
        
    }
}
