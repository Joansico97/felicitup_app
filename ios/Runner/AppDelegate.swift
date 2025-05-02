import Flutter
import UIKit
import flutter_local_notifications
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. Configura Firebase (PRIMER PASO)
    FirebaseApp.configure()
    
    // 2. Configuración de notificaciones locales
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in 
      GeneratedPluginRegistrant.register(with: registry)
    }
      
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    // 3. Registro de plugins estándar
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
