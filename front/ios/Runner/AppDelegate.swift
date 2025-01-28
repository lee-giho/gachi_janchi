import UIKit
import Flutter
import NaverThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    // 네이버 앱으로 인증
    NaverThirdPartyLoginConnection.getSharedInstance()?.isNaverAppOauthEnable = true
    // SafariViewContoller에서 인증
    NaverThirdPartyLoginConnection.getSharedInstance()?.isInAppOauthEnable = true
    
    // NaverThirdPartyLoginConnection 인스턴스 가져오기
    if let thirdConn = NaverThirdPartyLoginConnection.getSharedInstance() {
        thirdConn.serviceUrlScheme = kServiceAppUrlScheme
        thirdConn.consumerKey = kConsumerKey
        thirdConn.consumerSecret = kConsumerSecret
        thirdConn.appName = kServiceAppName
    } else {
        print("Error: NaverThirdPartyLoginConnection instance is nil")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    var applicationResult = false
    if !applicationResult {
       applicationResult = NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options) ?? false
    }
    // if you use other application url process, please add code here.
    
    if !applicationResult {
       applicationResult = super.application(app, open: url, options: options)
    }
    return applicationResult
  }

  // 앱이 백그라운드로 전환될 때 호출
  // override func applicationDidEnterBackground(_ application: UIApplication) {
  //   super.applicationDidEnterBackground(application)

  //   // 네이버 로그아웃 처리
  //   if let thirdConn = NaverThirdPartyLoginConnection.getSharedInstance() {
  //       thirdConn.requestDeleteToken() // 네이버 로그아웃 요청
  //   } else {
  //       print("NaverThirdPartyLoginConnection instance is nil")
  //   }
  // }
}
