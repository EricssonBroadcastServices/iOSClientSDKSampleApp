import GoogleCast

func reloadAppNavigation() {
    let navigationController = MainNavigationController()
    let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
    as GCKUICastContainerViewController
    castContainerVC.miniMediaControlsItemEnabled = true
    if let mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        mainWindow.rootViewController = castContainerVC
    }
    
    print("rdk call")
}
