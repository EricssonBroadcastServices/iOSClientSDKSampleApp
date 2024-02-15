//
//  URLViewController.swift
//  SDKSampleApp
//
//  Created by Robert Pelka on 14/02/2024.
//

import Foundation
import iOSClientExposurePlayback
import iOSClientPlayer
import UIKit

class URLViewController: UIViewController {
    
    lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter URL"
        
        textField.text = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8"
        // textField.text = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        let verticalStackView = UIStackView(arrangedSubviews: [urlTextField, playButton])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 20
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.alignment = .center
        view.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func playButtonTapped() {
        guard let urlString = urlTextField.text,
              let url = URL(string: urlString)
        else {
            return
        }
        self.handlePlay(url: url)
    }
    
    func handlePlay(url: URL) {
        
        let destinationViewController = PlayerViewController()

        destinationViewController.urlPlayableUrl = url
        destinationViewController.shouldPlayWithUrl = true
        
        destinationViewController.environment = StorageProvider.storedEnvironment
        destinationViewController.sessionToken = StorageProvider.storedSessionToken
 
        self.navigationController?.pushViewController(destinationViewController, animated: false)
    }
}
