//
//  EnvironmentViewController.swift
//  RefApp
//
//  Created by Udaya Sri Senarathne on 2018-11-21.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import iOSClientExposure

class EnvironmentViewController: UIViewController {
    
    let topHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    let bottomHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "redbee")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let environmentUrlTextField: RBMTextField = {
        let textfield = RBMTextField(placeHolderText: "Exposure base URL")
        textfield.text = StorageProvider.storedEnvironment?.baseUrl ?? ""
        textfield.backgroundColor = ColorState.active.textFieldBackground
        return textfield
    }()
    
    let customerNameTextField: RBMTextField = {
        let textfield = RBMTextField(placeHolderText: NSLocalizedString("Customer Name", comment: ""))
        textfield.text = StorageProvider.storedEnvironment?.customer ?? ""
        textfield.backgroundColor = ColorState.active.textFieldBackground
        return textfield
    }()
    
    let businessUnitTextField: RBMTextField = {
        let textfield = RBMTextField(placeHolderText: NSLocalizedString("Business Unit", comment: ""))
        textfield.backgroundColor = ColorState.active.textFieldBackground
        textfield.text = StorageProvider.storedEnvironment?.businessUnit ?? ""
        return textfield
    }()
    
    let nextButton: RBMButton = {
        let button = RBMButton(titleText: NSLocalizedString("Next", comment: ""))
        button.addTarget(self, action: #selector(navigateToLogin), for: .touchUpInside)
        return button
    }()
    
    let qrCodeButton: RBMButton = {
        let button = RBMButton(titleText: NSLocalizedString("Scan QR Code", comment: ""))
        button.addTarget(self, action: #selector(scanQRCode), for: .touchUpInside)
        return button
    }()
    
    // MARK: Life Cycle
    override func loadView() {
        super.loadView()
        
        addSubViews()
        setupAnchorsForViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.bindToKeyboard()
        
        self.navigationItem.title = NSLocalizedString("Environment", comment: "")
        view.backgroundColor = ColorState.active.background
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        view.unbindToKeyboard()
    }
}

// MARK: - Layout
extension EnvironmentViewController {
    
    fileprivate func addSubViews() {
        
        view.addSubview(topHolderView)
        view.addSubview(bottomHolderView)
        view.addSubview(logoImageView)
        view.addSubview(environmentUrlTextField)
        view.addSubview(customerNameTextField)
        view.addSubview(businessUnitTextField)
        view.addSubview(nextButton)
        view.addSubview(qrCodeButton)
    }
    
    fileprivate func setupAnchorsForViews() {
        
        if #available(iOS 11, *) {
            
            topHolderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: bottomHolderView.topAnchor, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
            
            bottomHolderView.anchor(top: topHolderView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
            
            environmentUrlTextField.anchor(top: bottomHolderView.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 20, left: 16, bottom: 0, right: -16))
            
            customerNameTextField.anchor(top: environmentUrlTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            businessUnitTextField.anchor(top: customerNameTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            nextButton.anchor(top: businessUnitTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            qrCodeButton.anchor(top: nextButton.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
        } else {
            
            topHolderView.anchor(top: view.topAnchor, bottom: bottomHolderView.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
            
            bottomHolderView.anchor(top: topHolderView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor)
            
            environmentUrlTextField.anchor(top: bottomHolderView.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: 16, bottom: 0, right: -16))
            
            customerNameTextField.anchor(top: environmentUrlTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            businessUnitTextField.anchor(top: customerNameTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            nextButton.anchor(top: businessUnitTextField.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
            
            qrCodeButton.anchor(top: nextButton.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top:20, left: 16, bottom:0, right: -16))
        }
        
        topHolderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3).isActive = true
        
        logoImageView.anchor(top: nil, bottom: topHolderView.bottomAnchor, leading: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        bottomHolderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2/3).isActive = true
    }
}


// MARK: - Navigation
extension EnvironmentViewController {
    
    /// Navigate to Login Page after validation
    @objc fileprivate func navigateToLogin() {
        
        view.endEditing(true)
        
        guard let environmentUrl = environmentUrlTextField.text,
            let customerName = customerNameTextField.text,
            let businessUnit = businessUnitTextField.text,
            environmentUrl != "", customerName != "", businessUnit != "" else {
                
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                
                self.popupAlert(title:NSLocalizedString("Sorry", comment: "") , message: NSLocalizedString("Please fill all fields", comment: ""), actions: [okAction], preferedStyle: .alert)
                return
        }
        
        let environment = Environment(baseUrl: environmentUrl, customer: customerName, businessUnit: businessUnit)
        
        let loginViewController = LoginViewController()
        loginViewController.environment = environment
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
    /// Navigate to QR Code Scanner View
    @objc fileprivate func scanQRCode() {
        let qrScannerViewController = QRScannerViewController(
            viewModel: QRScannerViewModel()
        )
        self.navigationController?.pushViewController(qrScannerViewController, animated: true)
    }
}
