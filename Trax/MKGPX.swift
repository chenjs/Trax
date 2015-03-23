//
//  MKGPX.swift
//  Trax
//
//  Created by chenjs on 15/3/21.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import MapKit

extension GPX.Waypoint: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String! {
        return name
    }
    
    var subtitle: String! {
        return info
    }
    
    var thumbnailURL: NSURL? { return getImageURLOfType("thumbnail") }
    var imageURL: NSURL? { return getImageURLOfType("large") }
    
    private func getImageURLOfType(type: String) -> NSURL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}
