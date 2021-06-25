//
//  AppDelegate.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import AWSS3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.initializeS3()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func initializeS3() {
//        let poolId = "ap-northeast-2:a6efc9f8-3dc8-48cc-801d-8334bb6752c8"
//        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.APNortheast2, identityPoolId: poolId)
//        let configuration = AWSServiceConfiguration(region: AWSRegionType.APNortheast2, credentialsProvider: credentialProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSS3Region,
           identityPoolId: AWSS3PoolId)
        let configuration = AWSServiceConfiguration(region: AWSS3Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

}
