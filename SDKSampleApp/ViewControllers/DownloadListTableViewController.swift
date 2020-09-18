//
//  DownloadListTableViewController.swift
//  RefApp
//
//  Created by Udaya Sri Senarathne on 2020-05-25.
//  Copyright © 2020 emp. All rights reserved.
//

import UIKit
import ExposureDownload
import ExposurePlayback

class DownloadListTableViewController: UITableViewController, EnigmaDownloadManager {
    
    var downloadedAssets: [OfflineMediaAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        
        self.refreshTableView()
        
    }
    
    func refreshTableView() {
        downloadedAssets = enigmaDownloadManager.getDownloadedAssets()
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloadedAssets?.count == 0 {
            tableView.showEmptyMessage(message: NSLocalizedString("No downloaded content", comment: ""))
        } else {
            tableView.hideEmptyMessage()
        }
        return downloadedAssets?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showOptions(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        if let asset = downloadedAssets?[indexPath.row] {
            cell.textLabel?.text = asset.assetId
            
            let expired = self.enigmaDownloadManager.isExpired(assetId: asset.assetId)
            if expired {
                print("Download has expired")
            }
        }
         
        return cell
    }
    
    func showOptions(_ row:Int ) {
        let message = "Choose option"
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let deletelAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if let asset = self.downloadedAssets?[row] {
                
                // Developers can use ExposureDownloadTask removeDownloadedAsset option to delete an already downloaded asset
                self.enigmaDownloadManager.removeDownloadedAsset(assetId: asset.assetId)
                self.refreshTableView()
            }
        })
        
        let refreshAction = UIAlertAction(title: "Refresh Liscence", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            guard let session = StorageProvider.storedSessionToken, let environment = StorageProvider.storedEnvironment else {
                print("No Session token or enviornment providec ")
                return
            }
            
            if let asset = self.downloadedAssets?[row] {
                
                // Developers can use the same download task to refresh the licence if it has expired.
                let task = self.enigmaDownloadManager.download(assetId: asset.assetId, using: session, in: environment)
                task.refreshLicence()
                task.onError {_, url, error in
                    print("📱 RefreshLicence Task failed with an error: \(error)",url ?? "")
                }
                .onCompleted { _, url in
                    print("📱 RefreshLicence Task completed: \(url)")
                }
            }
        })
        
        let playOffline = UIAlertAction(title: "Play Offline", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if let asset = self.downloadedAssets?[row] {
                
                // Developers can check if an asset is already downloaded by passing an assetId.
                // If the asset is already downloaded, API will return OfflineMediaAsset which has assetId, entitlement, urlAsset etc.
                let downloadedAsset = self.enigmaDownloadManager.getDownloadedAsset(assetId: asset.assetId)
                let urlAsset = downloadedAsset?.urlAsset
                
                if let entitlement = downloadedAsset?.entitlement, let urlAsset = urlAsset {
                    

                    let destinationViewController = PlayerViewController()
                    destinationViewController.environment = StorageProvider.storedEnvironment
                    destinationViewController.sessionToken = StorageProvider.storedSessionToken
                    
                    /// Optional playback properties
                    let properties = PlaybackProperties(autoplay: true,
                                                        playFrom: .bookmark,
                                                        language: .custom(text: "fr", audio: "en"),
                                                        maxBitrate: 300000)
                    
                    destinationViewController.playbackProperties = properties
                    destinationViewController.offlineMediaPlayable = OfflineMediaPlayable(assetId: asset.assetId, entitlement: entitlement, url: urlAsset.url)
                    
                    self.navigationController?.pushViewController(destinationViewController, animated: false)
                    
                }
            }
            
            
        })
        
        self.popupAlert(title: nil, message: message, actions: [playOffline, refreshAction, deletelAction, cancelAction], preferedStyle: .actionSheet)
    }
}
