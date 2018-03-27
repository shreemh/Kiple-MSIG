//
//  AppDelegate.swift
//  AtilzeConsumer
//
//  Created by Sreejith on 17/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import SWRevealViewController
import Instabug
import Fabric
import Crashlytics
import Moscapsule
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setGlobalChanges()
        
        if let mqttInfo = UserDefaults.standard.object(forKey: "VW.Consumer.MQTTInfo") as? [String : Any] {
            // MQTT
            let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
            let port: Int = mqttInfo["port"] as? Int ?? 0
            let portInt32 : Int32 = Int32(port)
            let host : String = mqttInfo["host"] as? String ?? ""
            let userName : String = mqttInfo["username"] as? String ?? ""
            let password : String = mqttInfo["password"] as? String ?? ""
            Model.shared.mqttConfig = MQTTConfig(clientId: clientID, host: host, port: portInt32, keepAlive: 100)
            Model.shared.mqttConfig?.mqttAuthOpts = MQTTAuthOpts(username: userName, password: password)
        }
        
        // MQTT
        /// Check if already logged-in
        if(Utility.getToken().characters.count > 0) {
            let dashBoardVC = mainSB.instantiateViewController(withIdentifier: "SWRevealVC")
            window?.rootViewController = dashBoardVC
            window?.makeKeyAndVisible()
            
            if Utility.getLoginMode() == "OBD" {
                
//                // AUTO REFRESH
//                DispatchQueue.main.asyncAfter(deadline: .now() + 120.0, execute: {
//                    Utility.refreshDashBoard()
//                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 240.0, execute: {
//                    Utility.refreshTrips()
//                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 360.0, execute: {
//                    Utility.refreshNotifications()
//                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 480.0, execute: {
//                    Utility.refreshAlerts()
//                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 600.0, execute: {
//                    Utility.refreshSettings()
//                })
                Model.shared.isAutoTrackingMode = false
            } else if Utility.getLoginMode() == "OBDless" {
                if Utility.getLoginType().lowercased() == "auto" {
                    Model.shared.isAutoTrackingMode = true
                } else {
                     Model.shared.isAutoTrackingMode = false
                }
            }
        }
        // FIREBASE
    
//        Analytics.logEvent(AnalyticsEventViewItem, parameters: ["Home_navigation" as String : "Home" as String])
//
        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        application.registerForRemoteNotifications()
//
//      //  Messaging.messaging().delegate = self
//

        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        // For iOS 10 data message (sent via FCM
        Messaging.messaging().delegate = self as MessagingDelegate
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        
        // TIMEZONE
        let storedData = Utility.readFromFile(fileName: FileNames.selectedTimeZone.rawValue)
        if let status = storedData["status"] as? String, status == "OK", let dict = storedData["data"] as? [String : Any], let timeZone = dict["timezone"] as? String {
            Model.shared.timeZone = timeZone
        } else {
            Model.shared.timeZone = "Asia/Kuala_Lumpur"
        }
        //  INSTABUG
        Instabug.start(withToken: "6f08b3976a1a890ffca925163f761b47", invocationEvent: .floatingButton)
        Instabug.setPromptOptionsEnabledWithBug(true, feedback: true, chat: false)
         //  FABRIC
        Fabric.with([Crashlytics.self])
        
        // NETWORK CONNECTION
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .unknown:
                print("Unknown")
            case .notReachable:
                print("Not reachable")
            case .reachableViaWWAN:
                print("Reachable reachableViaWWAN")
                DispatchQueue.main.async {
                    if Model.shared.mqttConfig != nil {
                        MQTTObject.sharedInstance.flushPendingData()
                    }
                }
            case .reachableViaWiFi:
                print("Reachable reachableViaWiFi")
                DispatchQueue.main.async {
                    if Model.shared.mqttConfig != nil {
                        MQTTObject.sharedInstance.flushPendingData()
                    }
                }
            }
            if (previousNetworkReachabilityStatus != .unknown && status != previousNetworkReachabilityStatus) {
                NotificationCenter.default.post(name: NetworkReachabilityChanged, object: nil)
            }
            previousNetworkReachabilityStatus = status
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
        return true
    }
    func test() {
        Model.shared.notiCount = Model.shared.notiCount + 1
        notificationSetUp(msg: "Test KIplecar-- shree", identifierName: String(Model.shared.notiCount))
    }
    
    func notificationSetUp(msg : String, identifierName : String) {
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = msg
        content.sound = UNNotificationSound.default()
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: identifierName, content: content, trigger: trigger)
        
        // Schedule the notification.
        Model.shared.center.add(request) { (error) in
            print("error")
        }
        
    }
    
    func updateDeviceToken() {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let deviceToken  = UserDefaults.standard.object(forKey: "VW.Consumer.deviceToken")
            let params: [String : Any] = ["device_token" : deviceToken ?? "", "device_type" : "iOS"]
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.registerDeviceToken + "?"
            networkManager.postMethod(url, params: params, success: { (response) in
                if let resultDict = response as? [String : Any], resultDict["error"] == nil {
                    print("SUCCESS")
                } else {
                    print("FAILED")
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            print("internetConnectMsg -- Update device token")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Model.shared.isinBackgroundState = true
     //   UserLocation.sharedInstance.locationManager?.requestAlwaysAuthorization()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
      Model.shared.isinBackgroundState = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // GET STORED TIME AND CHECK LOGGED-IN OR NOT
        guard let storedTime = UserDefaults.standard.object(forKey: "VW.Consumer.refreshTime") as? Date, Utility.getToken().characters.count > 1 else {
            return
        }
        let time1 = storedTime.addingTimeInterval(refreshTokenTime)
        let time3 = storedTime.addingTimeInterval(refreshTokenExpiryTime)
        let now = Date()
        if now > time3 {
            print("REFRESH TOKEN EXPIRED ---- REDIRECT TO LOGIN")
            clearLocaldata()
        } else if now > time1 {
            print("REFRESH TOKEN")
            Utility.refreshTokenMethod()
        } else {
            print("NOTHING 😝")
        }
    }
    
    func clearLocaldata() {
        // STOP TIMER AS WE NO LONGER NEED TO REFRESH THE ACCESS TOKEN AND OTHER APIS
        timerForRefreshToken.invalidate()
        timerForTripsRefresh.invalidate()
        timerForSetingsRefresh.invalidate()
        timerForDashBoardRefresh.invalidate()
        timerForNotificationsRefresh.invalidate()
        Model.destroy()
        
        // DELETE ALL FILES FROM DOC DIR
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let documentsPath = documentsUrl.path
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("All files in doc: \(fileNames)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".dat")) {
                    let filePathName = "\(documentsPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("Files in doc after deleting: \(files)")
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        let deviceToken = UserDefaults.standard.object(forKey: "VW.Consumer.deviceToken") as? String
        
        // REMOVE UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        
        UserDefaults.standard.set(deviceToken, forKey: "VW.Consumer.deviceToken")
        
        // REDIRECT TO FIRST VC
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let navController = secondSB.instantiateViewController(withIdentifier: "KipleNC")
        appDelegate?.window?.rootViewController = navController
        appDelegate?.window?.makeKeyAndVisible()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Model.shared.isOngoingTrip = false
    }

//    // MARK: - PUSH NOTIFICATIONS
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
////        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
////        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
//
//        print("deviceToken == \(deviceToken)")
//
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print(token)
//
//      //  print("TOKEN ===== \(InstanceID.instanceID().token() ?? "shreeee")")
//        // GET TOKEN
//        let FCMToken: String = Messaging.messaging().fcmToken ?? ""
//        //UserDefaults.standard.set(FCMToken, forKey: "VW.Consumer.deviceToken")
//        print("FCM token: \(FCMToken)")
//        if !FCMToken.isEmpty {
//            UserDefaults.standard.set(FCMToken, forKey: "VW.Consumer.deviceToken")
//            updateDeviceToken()
//        }
//    }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        UserDefaults.standard.set(fcmToken, forKey: "VW.Consumer.deviceToken")
//        if !fcmToken.isEmpty {
//            UserDefaults.standard.set(fcmToken, forKey: "VW.Consumer.deviceToken")
//            updateDeviceToken()
//        }
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
//
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print(error)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
//        print("Handle push from foreground")
//        // custom code to handle push while app is in the foreground
//        print("\(notification.request.content.userInfo)")
//        print("aps: \(notification.request.content.userInfo[AnyHashable("aps")] ?? "")")
//
//        let aps = notification.request.content.userInfo["aps"] as? [String : Any]
//        print("aps == \(aps ?? ["":""])")
//        let alerts = aps?["alert"] as? [String : Any]
//        let title: String = alerts?["title"] as? String ?? ""
//        let message: String = alerts?["body"] as? String ?? ""
//        self.alertView(title: title, alertText: message)
////        completionHandler([.alert, .badge, .sound])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("Handle push from background or closed")
////        print("\(response.notification.request.content.userInfo)")
////        print("aps: \(response.notification.request.content.userInfo[AnyHashable("aps")])")
////        print("type: \(response.notification.request.content.userInfo[AnyHashable("type")])")
//    }
//
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        if !fcmToken.isEmpty {
//            UserDefaults.standard.set(fcmToken, forKey: "VW.Consumer.deviceToken")
//            updateDeviceToken()
//        }
//    }
    
    func alertView(title : String, alertText : String) {
        
        let alertController = UIAlertController (title: title, message: alertText, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            // self.viewNotification()
            print("OK")
        }
        
        alertController.addAction(okAction)
        
        guard  let rootVC = self.window?.rootViewController else {
            return
        }
        
        var currentVC = self.findTopViewController(viewController: rootVC)
        
        if(currentVC is UIAlertController) {
            
            /* DISMISS PRESENTED ALERT VIEW AND SHOW RECENT ALERT VIEW ON CURRENT VC */
            currentVC.dismiss(animated: true, completion: {
                
                currentVC = self.findTopViewController(viewController: rootVC)
                
                currentVC.present(alertController, animated: true, completion: nil)
                
            })
            
        } else {
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    func findTopViewController(viewController : Any) -> UIViewController {
        
        if viewController is SWRevealViewController {
            guard let revealVC = viewController as? SWRevealViewController else {
                return viewController as! UIViewController
            }
            return self.findTopViewController(viewController: revealVC.frontViewController)
        }
        if viewController is UITabBarController {
            let baseTabBarVC = viewController as? UITabBarController
            return self.findTopViewController(viewController: baseTabBarVC!.selectedViewController!)
            
        } else if(viewController is UINavigationController) {
            let navigationVC = viewController as? UINavigationController
            return self.findTopViewController(viewController: navigationVC!.visibleViewController!)
        } else {
            return (viewController as? UIViewController)!
        }
    }
    
    
    func getTabBarVC(viewController : Any) -> UIViewController {
        if viewController is SWRevealViewController {
            guard let revealVC = viewController as? SWRevealViewController else {
                return viewController as! UIViewController
            }
            return self.findTopViewController(viewController: revealVC.frontViewController)
        }
        if viewController is UITabBarController {
            let baseTabBarVC = viewController as? UITabBarController
            return self.findTopViewController(viewController: baseTabBarVC!.selectedViewController!)
            
        } else if(viewController is UINavigationController) {
            let navigationVC = viewController as? UINavigationController
            return self.findTopViewController(viewController: navigationVC!.visibleViewController!)
        } else {
            return (viewController as? UIViewController)!
        }
        
    }
    
}

extension AppDelegate {
    /* Global changes */

    func setGlobalChanges() {
    
        UITabBar.appearance().tintColor = BLUE
        UITabBar.appearance().backgroundColor = .white
        
//        UINavigationBar.appearance().barTintColor = UIColor.init(hexString: "00A3EA")
//        UINavigationBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.init(hexString: "00A3EA")
        let font = UIFont(name: "Montserrat-Bold", size: 16)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.init(hexString: "00A3EA"), NSFontAttributeName: font ?? UIFont()]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
       // UINavigationBar.appearance().shadowImage = UIImage()
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        
       // SET BACK BUTTON IMAGE
//        let backImg: UIImage = UIImage(named: "back")!
//        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, for: .normal, barMetrics: .default)
        
// swift 4
//  UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.foregroundColor.rawValue : UIColor.white, NSAttributedString.font.rawValue: UIFont(name: "Montserrat-Bold", size: 16.0)!]
//   
        
    }
}

// MARK: - Push notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerPushNotification(_ application: UIApplication) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        // For iOS 10 data message (sent via FCM)
        Messaging.messaging().delegate = self
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //When the notifications of this code worked well, there was not yet.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // Print message ID.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
 
        completionHandler(.newData)
    }
    
    // showing push notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // NAVIGATE TO REVIEW SCREEN
        if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
            print("userInfo == \(userInfo)")
        }
        guard  let rootVC = self.window?.rootViewController else {
            return
        }
        
        if rootVC is SWRevealViewController {
            guard let revealVC = rootVC as? SWRevealViewController, let tabBarVC = revealVC.frontViewController as? UITabBarController else {
                return
            }
            tabBarVC.selectedIndex = 2
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound, .badge])
    }
    
}

// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        if !fcmToken.isEmpty {
            UserDefaults.standard.set(fcmToken, forKey: "VW.Consumer.deviceToken")
            updateDeviceToken()
        }
    }
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
}

