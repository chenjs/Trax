//
//  ImageViewController.swift
//  Cassini
//
//  Created by chenjs on 15/3/4.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            
            updateZoom()
    
            spinner?.stopAnimating()
        }
    }
    
    func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if imageData != nil {
                        self.image = UIImage(data: imageData!)
                    } else {
                        self.image = nil
                    }
                }
            }
        }
    }
    
    private var isFullScreen:Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
            if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
                UIApplication.sharedApplication().setStatusBarHidden(isFullScreen, withAnimation: UIStatusBarAnimation.Slide)
            }
        }
    }
    
    private var lastScrollViewFrame = CGRectZero
    
    func updateZoom() {
        if imageView.image == nil || scrollView == nil {
            return
        }
        
        if scrollView.frame == lastScrollViewFrame {
            return
        }
        
        //println("updateZoom: scrollView.frame = \(scrollView.frame)")
        
        // 0 reset scrollView & imageView
        scrollView.zoomScale = 1.0
        imageView.frame = CGRect(origin: CGPointZero, size:imageView.image!.size)
        scrollView.contentSize = imageView.image!.size
        
        // 1
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.0
        lastScrollViewFrame = scrollViewFrame
        
        // 2
        scrollView.zoomScale = minScale;
        
        // 3
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
        
        //println("imageView.frame = \(imageView.frame)")
    }

    func imageViewTapped(gesture: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        //scrollView.backgroundColor = UIColor.lightGrayColor()
        scrollView.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("imageViewTapped:"))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //updateZoom()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoom()
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        if newCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        } else {
            UIApplication.sharedApplication().setStatusBarHidden(isFullScreen, withAnimation: UIStatusBarAnimation.None)
        }
        
        updateZoom()
    }
    
}
