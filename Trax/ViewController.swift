//
//  ViewController.swift
//  Trax
//
//  Created by chenjs on 15/3/20.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue) { notification  in
            if let url = notification?.userInfo?[GPXURL.URLKey] as? NSURL {
                self.textView.text = "Received: \(url)"
            }
        }
    }

}


