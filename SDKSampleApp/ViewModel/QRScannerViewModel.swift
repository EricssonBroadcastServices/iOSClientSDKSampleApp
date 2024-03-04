import AVFoundation
import GoogleCast
import iOSClientExposure

class QRScannerViewModel: NSObject {
    
    private var session: AVCaptureSession = AVCaptureSession()
    private var isScanning = true
    
    public override init() {
        super.init()
    }
    
    func tryToStartSession() {
        if session.isRunning == false {
            let queue = DispatchQueue.global(qos: .background)
            queue.async { [weak self] in
                self?.session.startRunning()
            }
            isScanning = true
        }
    }
    
    func tryToStopSession() {
        if session.isRunning == true {
            session.stopRunning()
        }
    }
    
    func createSession(
        rectOfInterest: CGRect
    ) -> AVCaptureSession? {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return nil }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        let output = createAVCaptureMetadataOutput(rectOfInterest: rectOfInterest)
        session.addOutput(output)
        output.metadataObjectTypes = [.qr]
        
        return session
    }
    
    func createAVCaptureMetadataOutput(
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
    
}

// MARK: - AVFoundation QR
extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    internal func metadataOutput(
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
                        navigateWithQRParams(qrParams: parameters)
                        session.stopRunning()
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                }
            }
        }
    }
}

// MARK: - private functions
extension QRScannerViewModel {
    
    private func extractURLParameters(from qrCodeData: String) -> QRCodeURLParameters {
        var parameters = QRCodeURLParameters()
        let parameterPairs = qrCodeData.components(separatedBy: "&")
        
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
        return parameters
    }
    
    private func navigateWithQRParams(qrParams: QRCodeURLParameters) {
        
        if let sessionToken = SessionToken(value: qrParams.sessionToken) {
            StorageProvider.store(sessionToken: sessionToken)
        }
        
        let baseUrl = qrParams.env
        let customer = qrParams.cu
        let businessUnit = qrParams.bu
        let source = qrParams.source
        
        let environment = Environment(
            baseUrl: baseUrl ?? "",
            customer: customer ?? "",
            businessUnit: businessUnit ?? ""
        )
        StorageProvider.store(environment: environment)
        
        let navigationController = MainNavigationController()
        navigationController.qrCodeData = .init(urlParams: qrParams)
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
        as GCKUICastContainerViewController
        castContainerVC.miniMediaControlsItemEnabled = true
        if let mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            mainWindow.rootViewController = castContainerVC
        }
        
    }
}
