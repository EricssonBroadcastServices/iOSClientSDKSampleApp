import Foundation
import UIKit
import iOSClientExposure
import AVFoundation
import GoogleCast
import iOSClientExposurePlayback

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var viewModel: QRScannerViewModel
    var session: AVCaptureSession = AVCaptureSession()
    var isScanning = true
    
    public init(
        viewModel: QRScannerViewModel,
        isScanning: Bool = true
    ) {
        self.viewModel = viewModel
        self.isScanning = isScanning
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        
        let rectOfInterest = createRectOfInterest()
        
//        let output = AVCaptureMetadataOutput()
        let output = createAVCaptureMetadataOutput(rectOfInterest: rectOfInterest)
        session.addOutput(output)
        output.metadataObjectTypes = [.qr]


        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        setupLayout(rectOfInterest: rectOfInterest)

        session.startRunning()
    }
    
    private func createRectOfInterest() -> CGRect {
           let screenWidth = UIScreen.main.bounds.width
           let screenHeight = UIScreen.main.bounds.height
           
           return CGRect(
               x: (screenWidth - 200) / 2,
               y: (screenHeight - 200) / 2,
               width: 200,
               height: 200
           )
       }
       
       private func createAVCaptureMetadataOutput(
           rectOfInterest: CGRect
       ) -> AVCaptureMetadataOutput {
           let screenWidth = UIScreen.main.bounds.width
           let screenHeight = UIScreen.main.bounds.height
         
           let output = AVCaptureMetadataOutput()
           
           output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

           output.rectOfInterest = CGRect(
               x: rectOfInterest.origin.y / screenHeight,
               y: rectOfInterest.origin.x / screenWidth,
               width: rectOfInterest.size.height / screenHeight,
               height: rectOfInterest.size.width / screenWidth
           )
           return output
       }
       
       private func setupLayout(
           rectOfInterest: CGRect
       ) {
           let overlayView = UIView(frame: view.bounds)
           overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
           view.addSubview(overlayView)

           let squareView = UIView(frame: rectOfInterest)
           squareView.layer.borderWidth = 2
           squareView.backgroundColor = UIColor.clear
           view.addSubview(squareView)

           let maskLayer = CAShapeLayer()
           let path = UIBezierPath(rect: overlayView.bounds)
           path.append(UIBezierPath(rect: squareView.frame).reversing())
           maskLayer.path = path.cgPath
           overlayView.layer.mask = maskLayer
       }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if isScanning {
            isScanning = false
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == .qr {
                    if let qrCodeData = metadataObject.stringValue {
                        let parameters = extractURLParameters(from: qrCodeData)
                        session.stopRunning()
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if session.isRunning == false {
            session.startRunning()
            isScanning = true
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if session.isRunning == true {
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
        navigationController.qrCodeData = .init(urlParams: qrParams)
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
          as GCKUICastContainerViewController
        castContainerVC.miniMediaControlsItemEnabled = true
        UIApplication.shared.keyWindow?.rootViewController = castContainerVC
        
        
    }

}
