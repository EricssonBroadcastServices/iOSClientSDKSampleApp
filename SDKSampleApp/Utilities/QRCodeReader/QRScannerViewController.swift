import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!
    var isScanning = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("QR Reader", comment: "")

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

        // Add transparent square view as an overlay to indicate the smaller square window
        let overlayView = UIView(frame: rectOfInterest)
        overlayView.layer.borderWidth = 2
        overlayView.layer.borderColor = UIColor.red.cgColor
        overlayView.backgroundColor = UIColor.clear
        view.addSubview(overlayView)

        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isScanning {
            isScanning = false
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == .qr {
                    if let qrCodeData = metadataObject.stringValue {
                        print("QR Code Data: \(qrCodeData)")
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

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
}
