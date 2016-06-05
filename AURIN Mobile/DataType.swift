//
//  DataType.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/9.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import CoreData
import Foundation
import GoogleMaps

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
    
    // 判断两个BBOX是否有重合部分，有则返回true，没有则返回false
    func isIntersect(bbox: BBOX) -> Bool {
        //x11和y11为坐标的左上角 x12和y12为坐标的右下角
        var x11 = self.lowerLON
        var y11 = self.upperLAT
        var x12 = self.upperLON
        var y12 = self.lowerLAT
        
        //x21和y21为坐标的左上角 x22和y22为坐标的右下角
        var x21 = bbox.lowerLON
        var y21 = bbox.upperLAT
        var x22 = bbox.upperLON
        var y22 = bbox.lowerLAT
        
        if x12 < x11 {
            swap(&x11, &x12)
        }
        if y11 < y12 {
            swap(&y11, &y12)
        }
        if x22 < x21 {
            swap(&x22, &x21)
        }
        if y21 < y22 {
            swap(&y21, &y22)
        }
        if max(x11,x21) > min(x12,x22) || max(y12,y22) > min(y11,y21) {
            return false
        } else {
            return true
        }
        
//        // 相交
//        let minLat = max(self.lowerLAT, bbox.lowerLAT)
//        let minLon = max(self.lowerLON, bbox.lowerLON)
//        let maxLat = min(self.upperLAT, bbox.upperLAT)
//        let maxLon = min(self.upperLON, bbox.upperLON)
//        if (minLat > maxLat) || (minLon > maxLon) {
//            return true
//        }
//
//        // 包含
//        if (self.lowerLAT < bbox.lowerLAT) && (self.lowerLON < bbox.lowerLON) && (self.upperLAT > bbox.upperLAT) && (self.upperLON > bbox.upperLON) {
//            return true
//        }
//        
//        // 被包含
//        if (self.lowerLAT > bbox.lowerLAT) && (self.lowerLON > bbox.lowerLON) && (self.upperLAT < bbox.upperLAT) && (self.upperLON < bbox.upperLON) {
//            return true
//        }
//        
//        return false
    }
    
    
    func printBBOX() -> String {
        return "[\(NSString(format:"%.2f",self.lowerLON)), \(NSString(format:"%.2f",self.lowerLAT)), \(NSString(format:"%.2f",self.upperLON)), \(NSString(format:"%.2f",self.upperLAT))]"
    }
    
    func printFormattedBBOX() -> String {
        return "Lower LON: \(NSString(format:"%.4f",self.lowerLON)) \nLower LAT: \(NSString(format:"%.4f",self.lowerLAT)) \nUpper LON: \(NSString(format:"%.4f",self.upperLON)) \nUpper LAT: \(NSString(format:"%.4f",self.upperLAT))"
    }
}


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


class ExtendedMarker: GMSMarker {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
//    func getProperties() -> String {
//        var propertiesString = ""
//        var count = 0
//        for (key, value) in self.properties {
//            count += 1
//            propertiesString += "\(key): \(value)"
//            if count < properties.count {
//                propertiesString += "\n"
//            }
//        }
//        return propertiesString
//    }
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.mainScreen().bounds.width <= 350.0 {
            width = 35
        }
        
        
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sort{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in Range(0...(spaceNum > 0 ? spaceNum : 0)) {
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


class ExtendedPolyline: GMSPolyline {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.mainScreen().bounds.width <= 350.0 {
            width = 35
        }
        
        
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sort{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in Range(0...(spaceNum > 0 ? spaceNum : 0)) {
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


class ExtendedPolygon: GMSPolygon {
    var key: String = ""
    var value: Double = 0.0
    var properties = [String:String]()
    
    func getProperties() -> String {
        var width = 45
        if UIScreen.mainScreen().bounds.width <= 350.0 {
            width = 35
        }
        var count = 0
        var propertiesString = ""
        let newprop = self.properties.sort{$0.0 < $1.0}
        for (key, value) in newprop {
            count += 1
            propertiesString += "\(key) "
            let spaceNum = width-key.characters.count-value.characters.count
            for _ in Range(0...(spaceNum > 0 ? spaceNum : 0)) {
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