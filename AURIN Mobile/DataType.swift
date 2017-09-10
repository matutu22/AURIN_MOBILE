//
//  DataType.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/9.
//  Updated by Chenhan on Aug 2017
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    This file defines some data types used in this project:
        BBOX: Store the bounding box
        Dataset: Store the dataset from AUIRN
        LocalDataset: Store the dataset in local database
        ExtendedMarker: Used to represend Point data type
        ExtendedPolyline: Used to represend MultiLineString data type
        ExtendedPolygon: Used to represend MultiPolygon data type
 ********************************************************************************************/


import CoreData
import Foundation
import GoogleMaps

// Bounding box
class BBOX {
    var lowerLON: Double = 0.0
    var lowerLAT: Double = 0.0
    var upperLON: Double = 0.0
    var upperLAT: Double = 0.0
    
    init() {}
    
    init(lowerLON: Double, lowerLAT: Double, upperLON: Double, upperLAT: Double) {
        self.lowerLON = lowerLON
        self.lowerLAT = lowerLAT
        self.upperLON = upperLON
        self.upperLAT = upperLAT
    }
    
    // Algorithms to judge if two bounding boxes are intersectant
    func isIntersect(_ bbox: BBOX) -> Bool {
        // (x11, y11) is top-left corner, (x12, y12) is bottom-right corner.
        var x11 = self.lowerLON
        var y11 = self.upperLAT
        var x12 = self.upperLON
        var y12 = self.lowerLAT
        // (x21, y21) is top-left corner, (x22, y22) is bottom-right corner.
        var x21 = bbox.lowerLON
        var y21 = bbox.upperLAT
        var x22 = bbox.upperLON
        var y22 = bbox.lowerLAT
        // Decide if they are intersectant
        if x12 < x11 { swap(&x11, &x12) }
        if y11 < y12 { swap(&y11, &y12) }
        if x22 < x21 { swap(&x22, &x21) }
        if y21 < y22 { swap(&y21, &y22) }
        if max(x11,x21) > min(x12,x22) || max(y12,y22) > min(y11,y21) {
            return false
        } else {
            return true
        }
    }
    
    func printBBOX() -> String {
        return "[\(NSString(format:"%.2f",self.lowerLON)), \(NSString(format:"%.2f",self.lowerLAT)), \(NSString(format:"%.2f",self.upperLON)), \(NSString(format:"%.2f",self.upperLAT))]"
    }
    
    func printFormattedBBOX() -> String {
        return "Lower LON: \(NSString(format:"%.4f",self.lowerLON)) \nLower LAT: \(NSString(format:"%.4f",self.lowerLAT)) \nUpper LON: \(NSString(format:"%.4f",self.upperLON)) \nUpper LAT: \(NSString(format:"%.4f",self.upperLAT))"
    }
}


// Online dataset
class Dataset {
    var name: String = "dataset name"
    var title: String = "dataset title"
    var abstract: String = "abstract"
    var organisation: String = "org"
    var website: String = "www.aurin.org.au"
    var keywords: [String] = [" "]
    //var bbox: (lowerLON: Double, lowerLAT: Double, upperLON: Double, upperLAT: Double)
    var bbox =  BBOX()
    var zoom:Float = 0.00
    var center: (longitude: Double, latitude: Double)
    var isSaved = false
    
    init() {
        self.name = ""
        self.title = ""
        self.organisation = ""
        self.abstract = ""
        self.website = ""
        self.keywords = []
        self.bbox =  BBOX(lowerLON: 0.0, lowerLAT: 0.0, upperLON: 0.0, upperLAT: 0.0)
        self.zoom = 0.00
        self.center = (0.000000, 0.000000)
    }
    
    func showKeyword() -> String {
        var keywordString = ""
        var count = 0
        for keyword in self.keywords {
            count += 1
            if keyword != "features" {
                keywordString += "\(keyword)"
                if count < self.keywords.count {
                    keywordString += ", "
                }
            }
        }
        return keywordString
    }
    
    func toLoalDataset() -> LocalDataset {
        let localDataset = LocalDataset()

        localDataset.name = self.name
        localDataset.title = self.title
        localDataset.abstract = self.abstract
        localDataset.organisation = self.organisation
        localDataset.website = self.website
        localDataset.keywords = self.showKeyword()
        localDataset.lowerLON = self.bbox.lowerLON
        localDataset.lowerLAT = self.bbox.lowerLAT
        localDataset.upperLON = self.bbox.upperLON
        localDataset.upperLAT = self.bbox.upperLAT
        localDataset.zoom = self.zoom
        localDataset.centerLON = self.center.longitude
        localDataset.centerLAT = self.center.latitude
        
        return localDataset
    }
}


// Local dataset
class LocalDataset:NSManagedObject {
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var abstract: String
    @NSManaged var organisation: String
    @NSManaged var website: String
    @NSManaged var keywords: String
    @NSManaged var lowerLON: Double
    @NSManaged var lowerLAT: Double
    @NSManaged var upperLON: Double
    @NSManaged var upperLAT: Double
    @NSManaged var zoom: Float
    @NSManaged var centerLON: Double
    @NSManaged var centerLAT: Double

    func toDataset() -> Dataset {
        let dataset = Dataset()
        
        dataset.name = self.name
        dataset.title = self.title
        dataset.abstract = self.abstract
        dataset.organisation = self.organisation
        dataset.website = self.website
        dataset.keywords = [self.keywords]
        dataset.bbox = BBOX(lowerLON: self.lowerLON, lowerLAT: self.lowerLAT, upperLON: self.upperLON, upperLAT: self.upperLAT)
        dataset.zoom = self.zoom
        dataset.center = (longitude: self.centerLON, latitude: self.centerLAT)
        
        return dataset
    }
    
}


// Extend the Marker type in Google Maps SDK
class ExtendedMarker: GMSMarker, GMUClusterItem {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.main.bounds.width <= 350.0 {
            width = 35
        }
        
        
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sorted{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in 0...(spaceNum > 0 ? spaceNum : 0) {
                propertiesString += "-"
            }
            propertiesString += " \(value)"
            if count < properties.count {
                propertiesString += "\n"
            }
        }
        return propertiesString
    }
}


// Extend the Polyline type in Google Maps SDK
class ExtendedPolyline: GMSPolyline {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.main.bounds.width <= 350.0 {
            width = 35
        }
        
        
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sorted{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in 0...(spaceNum > 0 ? spaceNum : 0) {
                propertiesString += "-"
            }
            propertiesString += " \(value)"
            if count < properties.count {
                propertiesString += "\n"
            }
        }
        return propertiesString
    }
}


// Extend the Polygon type in Google Maps SDK
class ExtendedPolygon: GMSPolygon {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.main.bounds.width <= 350.0 {
            width = 35
        }
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sorted{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in 0...(spaceNum > 0 ? spaceNum : 0) {
                propertiesString += "-"
            }
            propertiesString += " \(value)"
            if count < properties.count {
                propertiesString += "\n"
            }
        }
        return propertiesString
    }
}
