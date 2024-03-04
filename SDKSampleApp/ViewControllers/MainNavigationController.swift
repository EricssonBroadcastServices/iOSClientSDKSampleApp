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

struct QRCodeData {
    let urlParams: QRCodeURLParameters?
    
    var isAnonymousLoginPossible: Bool {
        urlParams?.bu != nil && urlParams?.cu != nil && urlParams?.env != nil
        //rdk add simple check if URL and so on
    }
    
    var isContentDataAvailable: Bool {
        urlParams?.source != nil
    }
}

/// Handles the main navigation in the app
class MainNavigationController: UINavigationController {
    
    var qrCodeData: QRCodeData? //= "b74e3719-3ef0-481a-8014-40fa7cea2402_82162E"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RDK viewDidLoad")
        
        if StorageProvider.storedSessionToken != nil {
            showRootController()
        } else {
            showEnvironmentController()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("RDK viewWillAppear")
        
            guard
                let environment = StorageProvider.storedEnvironment
            else {
                print("RDK guard return")
                return
            }
    
        if let qrCodeData, qrCodeData.isContentDataAvailable {
                print("RDK showPlayerController")
                showPlayerController(
                    qrCodeData: qrCodeData,
                    environment: environment
                )
            }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        guard
//            let environment = StorageProvider.storedEnvironment
//        else {
//            return
//        }
//        
//        if let assetID {
//            showPlayerController(
//                assetID: assetID,
//                environment: environment
//            )
//        }
//    }
    
    /// Show Root (main) view if user not logged in
    private func showRootController() {
        let vc = RootViewController()
        viewControllers = [vc]
    }
    
    /// Show Enviornment view if user not logged in
    private func showEnvironmentController() {
        let vc = EnvironmentViewController()
        vc.tryAutoLogIn = qrCodeData?.isAnonymousLoginPossible ?? false
        viewControllers = [vc]
    }
    
    private func showPlayerController(
        qrCodeData: QRCodeData,
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
        playerVC.playable = AssetPlayable(assetId: qrCodeData.urlParams?.source ?? "")
        
        
        viewControllers.append(playerVC)
//        pushViewController(playerVC, animated: false)
        
        print("RDK player VC should be there")
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


