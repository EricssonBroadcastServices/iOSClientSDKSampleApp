import GoogleCast

func reloadAppNavigation(
    qrParams: QRCodeURLParameters? = nil
) {
    let navigationController = MainNavigationController()
    navigationController.qrCodeData = .init(urlParams: qrParams)
    let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
    as GCKUICastContainerViewController
    castContainerVC.miniMediaControlsItemEnabled = true
    if let mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        mainWindow.rootViewController = castContainerVC
    }
}
