//
//  WaypointImageViewController.swift
//  Trax
//
//  Created by chenjs on 15/3/28.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {

    var waypoint: GPX.Waypoint? {
        didSet {
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            
            updateEmbedMap()
        }
    }
    
    private func updateEmbedMap() {
        if let mapView = smvc?.mapView {
            mapView.mapType = .Hybrid
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(waypoint)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var smvc: SimpleMapViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed Segue" {
            smvc = segue.destinationViewController as? SimpleMapViewController
        }
    }
}
