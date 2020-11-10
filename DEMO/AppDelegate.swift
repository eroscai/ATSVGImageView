//
//  AppDelegate.swift
//  DEMO
//
//  Created by CaiSanze on 2020/11/10.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        return true
    }

}

