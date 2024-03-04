import Foundation
import UIKit
import iOSClientExposure
import AVFoundation
import GoogleCast

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!
    var isScanning = true

    override func viewDidLoad() {
        super.viewDidLoad()

        session = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print(error.localizedDescription)
            return
        }

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        // Define a smaller center square window as region of interest (ROI)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let rectOfInterest = CGRect(x: (screenWidth - 200) / 2, y: (screenHeight - 200) / 2, width: 200, height: 200)
        output.rectOfInterest = CGRect(x: rectOfInterest.origin.y / screenHeight, y: rectOfInterest.origin.x / screenWidth, width: rectOfInterest.size.height / screenHeight, height: rectOfInterest.size.width / screenWidth)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Add semi-transparent overlay view to dim the area outside the red square
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayView)

        // Add the transparent square view as an overlay to indicate the smaller square window
        let squareView = UIView(frame: rectOfInterest)
        squareView.layer.borderWidth = 2
        squareView.layer.borderColor = UIColor.red.cgColor
        squareView.backgroundColor = UIColor.clear
        view.addSubview(squareView)

        // Cut out the region corresponding to the red square from the overlay view
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(rect: squareView.frame).reversing())
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer

        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isScanning {
            isScanning = false
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == .qr {
                    if let qrCodeData = metadataObject.stringValue {
//                        print("QR Code Data: \(qrCodeData)")
                        
                        let parameters = extractURLParameters(from: qrCodeData)
                        print(parameters)
                        // Handle the QR code data as needed
                        // Stop scanning more QR codes
                        session.stopRunning()
                        // Vibrate the device
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if session?.isRunning == false {
            session.startRunning()
            isScanning = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if session?.isRunning == true {
            session.stopRunning()
        }
    }
    
    func extractURLParameters(from qrCodeData: String) -> QRCodeURLParameters {
        var parameters = QRCodeURLParameters()
        
        // Remove the leading prefix if present
        let cleanedData = qrCodeData.replacingOccurrences(of: "https://ericssonbroadcastservices.github.io/javascript-player/?", with: "")
        
        // Split the string by "&" to get individual parameters
        let parameterPairs = cleanedData.components(separatedBy: "&")
        
        // Iterate over parameter pairs and extract key-value pairs
        for pair in parameterPairs {
            let components = pair.components(separatedBy: "=")
            if components.count == 2 {
                if let key = components[0].removingPercentEncoding, let value = components[1].removingPercentEncoding {
                    if let parameter = QRCodeParameter(rawValue: key) {
                        switch parameter {
                        case .env: parameters.env = value
                        case .cu: parameters.cu = value
                        case .bu: parameters.bu = value
                        case .source: parameters.source = value
                        case .sessionToken: parameters.sessionToken = value
                        }
                    }
                }
            }
        }
        navigateBack(qrParams: parameters)
        return parameters
    }
    
    func navigateBack(qrParams: QRCodeURLParameters) {
        
        if let sessionToken = SessionToken(value: qrParams.sessionToken) {
            StorageProvider.store(sessionToken: sessionToken)
        }
        
        let baseUrl = qrParams.env
        let customer = qrParams.cu
        let businessUnit = qrParams.bu
        let source = qrParams.source
        
        let environment = Environment(
            baseUrl: baseUrl ?? "",
            customer: customer ?? "", // rdk here only if all are set up
            businessUnit: businessUnit ?? ""
        )
        
        StorageProvider.store(environment: environment)
        
        
        let navigationController = MainNavigationController()
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
          as GCKUICastContainerViewController
        castContainerVC.miniMediaControlsItemEnabled = true
        UIApplication.shared.keyWindow?.rootViewController = castContainerVC
    }

}

enum QRCodeParameter: String {
    case env
    case cu
    case bu
    case source
    case sessionToken
}

struct QRCodeURLParameters {
    var env: String?
    var cu: String?
    var bu: String?
    var source: String?
    var sessionToken: String?
    
    init(env: String? = nil, cu: String? = nil, bu: String? = nil, source: String? = nil, sessionToken: String? = nil) {
        self.env = env
        self.cu = cu
        self.bu = bu
        self.source = source
        self.sessionToken = sessionToken
    }
}
