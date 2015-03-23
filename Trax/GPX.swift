//
//  GPX.swift
//  Trax
//
//  Created by chenjs on 15/3/21.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//


import Foundation

class GPX: NSObject, Printable, NSXMLParserDelegate
{
    var waypoints = [Waypoint]()
    var tracks = [Track]()
    var routes = [Track]()
    
    override var description: String {
        var descriptions = [String]()
        if waypoints.count > 0 { descriptions.append("waypoints = \(waypoints)") }
        if tracks.count > 0 { descriptions.append("tracks = \(tracks)") }
        if routes.count > 0 { descriptions.append("routes = \(routes)") }
        return "\n".join(descriptions)
    }
    
    private let url: NSURL
    private let completionHandler: GPXCompletionHandler
    
    private init(url: NSURL, completionHandler: GPXCompletionHandler) {
        self.url = url
        self.completionHandler = completionHandler
    }
    
    typealias GPXCompletionHandler = (GPX?) -> Void
    
    class func parse(url: NSURL, completionHandler: GPXCompletionHandler) {
        GPX(url: url, completionHandler: completionHandler).parse()
    }
    
    private func complete(#success: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.completionHandler(success ? self : nil)
        }
    }
    
    private func fail() { complete(success: false) }
    private func succeed() { complete(success: true) }
    
    private func parse() {
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            if let data = NSData(contentsOfURL: self.url) {
                let parser = NSXMLParser(data: data)
                parser.delegate = self
                parser.shouldProcessNamespaces = false
                parser.shouldReportNamespacePrefixes = false
                parser.shouldResolveExternalEntities = false
                parser.parse()
            } else {
                self.fail()
            }
        }
    }

    func parserDidEndDocument(parser: NSXMLParser!) { succeed() }
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) { fail() }
    func parser(parser: NSXMLParser!, validationErrorOccurred validationError: NSError!) { fail() }
    
    var input = ""
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        input += string
    }
    
    var waypoint : Waypoint?
    var track: Track?
    var link: Link?
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
    
    //func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedname qName: String!, attributes attributeDict: [NSObject: AnyObject]!) {
        switch elementName {
        case "trkseg":
            if track == nil { fallthrough }
        case "trk":
            tracks.append(Track())
            track = tracks.last
        case "rte":
            routes.append(Track())
            track = routes.last
        case "rtept", "trkpt", "wpt":
            let latitude = (attributeDict["lat"] as NSString).doubleValue
            let longitute = (attributeDict["lon"] as NSString).doubleValue
            waypoint = Waypoint(latitude: latitude, longitude: longitute)
        case "link":
            link = Link(href: attributeDict["href"] as String)
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        switch elementName {
        case "wpt":
            if waypoint != nil { waypoints.append(waypoint!); waypoint = nil }
        case "trkpt", "rtept":
            if waypoint != nil { track?.fixes.append(waypoint!); waypoint = nil }
        case "trk", "trkseg", "rte":
            track = nil
        case "link":
            if link != nil {
                if waypoint != nil {
                    waypoint!.links.append(link!)
                } else {
                    track!.links.append(link!)
                }
            }
            link = nil
        default:
            if link != nil {
                link!.linkattributes[elementName] = input.trimmed
            } else if waypoint != nil {
                waypoint!.attributes[elementName] = input.trimmed
            } else if track != nil {
                track!.attributes[elementName] = input.trimmed
            }
            input = ""
        }
    }
    
    class Track: Entry, Printable {
        var fixes = [Waypoint]()
        
        override var description: String {
            let waypointDescription = "fixes=[\n" + "\n".join(fixes.map { $0.description }) + "\n]"
            return "".join([super.description, waypointDescription])
        }
        
        private struct Constants {
            static let MinimumWaypointSeparation = 1.0
            static let MaximumInterwaypointVelocity = 250_000.0/3600.0
            static let CreateNewSegmentTimeThreshold = 120.0
        }
        
        /*
        var segments: [TrackSegment] {
            var segments = [TrackSegment]()
            
            var lastWaypoint: GPX.Waypoint?
            var lastStoppedWaypoint: GPX.Waypoint?
            var waypoints = Array<GPX.Waypoint>()
            
            for waypoint in fixes {
                if let waypointDate = waypoint.date {
                    let distanceFromLastWaypoint = waypoint.distanceFromWaypoint(lastWaypoint)
                    let timeSinceLastWaypoint = waypointDate - lastWaypoint.date
                    let velocityFromLastWaypoint = distanceFromLastWaypoint / timeSinceLastWaypoint
                    if distanceFromLastWaypoint > Constants.MinimumWaypointSeparation && velocityFromLastWaypoint > Constants.MaximumInterwaypointVelocity)
                        break
                }
            }
            
            for waypoint in fixes.reverse() {
                if let waypointDate = waypoint.date {
                    dateOfLastCoordinate = waypointDate
                    break
                }
            }
            
        }
        */
    }

    class Waypoint: Entry, Printable
    {
        var latitude: Double
        var longitude: Double
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
            super.init()
        }
        
        var info: String? {
            get {
                return attributes["desc"]
            }
            set {
                attributes["desc"] = newValue
            }
        }
        lazy var date: NSDate? = {
            if let dateStr = self.attributes["time"] {
                return NSDateFormatter().dateFromString(dateStr)
            } else {
                return nil
            }
        }()
        
        override var description: String {
            return ".".join(["lat=\(latitude)", "lon=\(longitude)", super.description])
        }
        
        func distanceFromWaypoint(waypoint: Waypoint?) -> Double {
            if let waypoint = waypoint {
                let radiansPerDegree = M_PI / 180.0
                let deltaLongitude = (longitude - waypoint.longitude) * radiansPerDegree
                let deltaLatitude = (latitude - waypoint.latitude) * radiansPerDegree
                let myLatitude = latitude * radiansPerDegree
                let otherLatitude = latitude * radiansPerDegree
                let x = pow((sin(deltaLatitude / 2)), 2.0) + cos(myLatitude) * cos(otherLatitude) * pow(sin(deltaLongitude / 2), 2.0)
                return 6371.0 * 1000.0 * 2 * atan2(sqrt(x), sqrt(1 - x))
            } else {
                return 6371.0 * M_PI
            }
        }
    }
    
    class Entry: NSObject, Printable
    {
        var links = [Link]()
        var attributes = [String: String]()
        
        var name: String? {
            get {
                return attributes["name"]
            }
            set {
                attributes["name"] = newValue
            }
        }
        
        override var description:String {
            var descriptions = [String]()
            if attributes.count > 0 { descriptions.append("attributes=\(attributes)") }
            if links.count > 0 { descriptions.append("links=\(links)") }
            return ".".join(descriptions)
        }
    }
    
    class Link: Printable
    {
        var href: String
        var linkattributes = [String: String]()
        
        init(href: String) {
            self.href = href
        }
        
        var url: NSURL? { return NSURL(string: href) }
        var text: String? { return linkattributes["text"] }
        var type: String? { return linkattributes["type"] }
        
        var description: String {
            var descriptions = [String]()
            descriptions.append("href=\(href)")
            if linkattributes.count > 0 { descriptions.append("linkattributes=\(linkattributes)") }
            return "[" + " ".join(descriptions) + "]"
        }
        
    }
}

extension String {
    var trimmed: String {
        let trimmedString = NSString(string: self).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return trimmedString
    }
}
