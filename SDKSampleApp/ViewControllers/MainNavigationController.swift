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
        urlParams?.bu != nil
        &&
        urlParams?.cu != nil
        &&
        urlParams?.env != nil
        &&
        urlParams?.sessionToken == nil
        //rdk add simple check if URL and so on
    }
    
    var isContentDataAvailable: Bool {
        urlParams?.source != nil
    }
    
    var isSourceAssetURL: Bool {
        guard
            let assetID = urlParams?.source
        else {
            return false
        }
        return isValidURL(assetID)
    }
    
    private func isValidURL(
        _ urlString: String
    ) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}

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
            guard
                let environment = StorageProvider.storedEnvironment
            else {
                return
            }
    
        if let qrCodeData, qrCodeData.isContentDataAvailable {
                showPlayerController(
                    qrCodeData: qrCodeData,
                    environment: environment
                )
            }
    }
    
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
        
        print("RDK SOURCE ASSET IS URL? ->\(qrCodeData.isSourceAssetURL)")
        
        guard
            let source = qrCodeData.urlParams?.source
        else {
            return
        }
        
        let playerVC = PlayerViewController()
        
        playerVC.environment = environment
        playerVC.sessionToken = StorageProvider.storedSessionToken //  rdk this should be optional - if not provided then crash
        
        
        if qrCodeData.isSourceAssetURL,
        let sourceURL = URL(string: source) {
            playerVC.shouldPlayWithUrl = true
            playerVC.urlPlayable = URLPlayable(url: sourceURL)
        } else {
            playerVC.shouldPlayWithUrl = false
            playerVC.playable = AssetPlayable(assetId: source)
        }
        
        viewControllers.append(playerVC)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


