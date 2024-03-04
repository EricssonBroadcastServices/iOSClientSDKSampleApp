import Foundation
import UIKit

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
