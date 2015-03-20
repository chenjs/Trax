//
//  AppDelegate.swift
//  Trax
//
//  Created by chenjs on 15/3/20.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import UIKit

struct GPXURL {
    static let Notification = "GPXURL Notification"
    static let URLKey = "GPXURL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.Notification, object: self, userInfo: [GPXURL.URLKey: url])
        center.postNotification(notification)
        
        return true
    }

}

