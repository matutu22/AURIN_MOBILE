//
//  MapDrawingViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/15.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    Fetch detailed geospatial data from AURIN and draw it on map.
 ********************************************************************************************/


import UIKit
import Alamofire
import GoogleMaps


class MapDrawingViewController: UIViewController, GMSMapViewDelegate {

    // The parameters of intermediate server
    var simLevel: Float = 0.1
    var useSimplifier = false
    var serverAddress = "localhost:3000"
    
    
    // Receive Data from Map Setting View
    var dataset:Dataset!
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    var titleProperty: String = ""
    var classifierProperty: String = ""
    var palette: String = "Red"
    var colorClass: Int = 6
    var opacity: Float = 0.7
    var geom_name = "the_geom"

    
    // Used in Drawing Map
    var alpha: CGFloat = 0.7
    var shapeType = "Overlay"

    @IBOutlet var backButton: UIButton!
    @IBOutlet var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title of navigation bar
        navigationItem.title = "\(dataset.title)"
        
        var queryURL = "https://geoserver.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(dataset.name)&MaxFeatures=1000&outputFormat=json&CQL_FILTER=BBOX(\(geom_name),\(chooseBBOX.lowerLAT),\(chooseBBOX.lowerLON),\(chooseBBOX.upperLAT),\(chooseBBOX.upperLON))"
        
        // If the use choose to use the intermediate server, change the URL.
        if useSimplifier {
            queryURL = "http://\(serverAddress)/query?dataset=\(dataset.name)&geo_name=\(geom_name)&llat=\(chooseBBOX.lowerLAT)&llon=\(chooseBBOX.lowerLON)&ulat=\(chooseBBOX.upperLAT)&ulon=\(chooseBBOX.upperLON)&simpify=\(simLevel)"
        }
        
        
        print(queryURL)
        
        let zoomLevel = Float(round((log2(210 / abs(chooseBBOX.upperLON - chooseBBOX.lowerLON)) + 1) * 100) / 100)
        let centerLatitude = (chooseBBOX.lowerLAT + chooseBBOX.upperLAT) / 2
        let centerLongitude = (chooseBBOX.lowerLON + chooseBBOX.upperLON) / 2
        
        mapView.bringSubview(toFront: backButton)
        alpha = CGFloat(opacity)
        
        self.mapView.isMyLocationEnabled = true;
        self.mapView.mapType = .normal;
        self.mapView.settings.compassButton = true;
        self.mapView.settings.myLocationButton = true;
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.rotateGestures = false
        self.mapView.delegate = self;
        let camera = GMSCameraPosition.camera(withLatitude: centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
        self.mapView.animate(to: camera)
        
        // Do any additional setup after loading the view.
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0).async(execute: {
            Alamofire.request(queryURL).response { (_request, _response, data, _error) in
                let json = JSON(data: data!)
                
                if json["features"].count == 0 {
                    let alertMessage = UIAlertController(title: "No Data", message: "There is no data in the selected area, please try to choose another area.", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                }
                
                let shapeType = json["features"][0]["geometry"]["type"]
                switch shapeType {
                // ====================================================================================
                case "Point":
                    let featuresNum = json["features"].count
                    for featureID in Range(0..<featuresNum) {
                        
                        let latitude = json["features"][featureID]["geometry"]["coordinates"][1].doubleValue
                        let longitude = json["features"][featureID]["geometry"]["coordinates"][0].doubleValue
                        let marker = ExtendedMarker(position: CLLocationCoordinate2DMake(latitude, longitude))
                        marker.title = json["features"][featureID]["id"].stringValue
                        for property in json["features"][featureID]["properties"] {
                            marker.properties.updateValue(String(property.1), forKey: property.0)
                        }
                        marker.key = json["features"][featureID]["properties"][self.titleProperty].stringValue
                        marker.value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
                        
                        
                        let markerColor = ColorSet.colorDictionary[self.palette]
                        marker.icon = GMSMarker.markerImageWithColor(markerColor?.colorWithAlphaComponent(self.alpha))
                        marker.properties.removeValueForKey("bbox")
                        //marker.appearAnimation = kGMSMarkerAnimationPop
                        marker.map = self.mapView
                    }
                // ====================================================================================
                case "LineString": break
                // ====================================================================================
                //case "Polygon": break
                // ====================================================================================
                case "MultiPoint": break
                // ====================================================================================
                case "MultiLineString":
                    self.shapeType = "Polyline"
                    let featuresNum = json["features"].count
                    var polylinePath = GMSMutablePath()
                    
                    for featureID in Range(0..<featuresNum) {
                        let polylineCount = json["features"][featureID]["geometry"]["coordinates"].count
                        for polylineNum in Range(0..<polylineCount) {
                            let count = json["features"][featureID]["geometry"]["coordinates"][polylineNum].count
                            for coordinateNum in Range(0..<count) {
                                let point = json["features"][featureID]["geometry"]["coordinates"][polylineNum][coordinateNum]
                                polylinePath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                            }
                            
                            let polyline = ExtendedPolyline(path: polylinePath)
                            polyline.title = json["features"][featureID]["id"].stringValue
                            for property in json["features"][featureID]["properties"] {
                                polyline.properties.updateValue(String(property.1), forKey: property.0)
                            }
                            polyline.properties.removeValueForKey("bbox")
                            polyline.key = json["features"][featureID]["properties"][self.titleProperty].stringValue
                            polyline.value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
                            
                            polyline.strokeWidth = 2.0
                            let strokeColor = ColorSet.colorDictionary[self.palette]
                            polyline.strokeColor = strokeColor!.colorWithAlphaComponent(self.alpha)
                            polyline.geodesic = true
                            polyline.tappable = true
                            polyline.map = self.mapView
                            polylinePath = GMSMutablePath()
                        }
                    }
                    
                    
                    break
                // ====================================================================================
                case "MultiPolygon", "Polygon":
                    self.shapeType = "Polygon"
                    let featuresNum = json["features"].count
                    var polygonPath = GMSMutablePath()
                    var polygons = [ExtendedPolygon]()
                    var maxValue = 0.0
                    var minValue = 9999999.0
                    var step = 0.0
                    
                    for featureID in Range(0..<featuresNum) {
                        if json["features"][featureID]["geometry"]["type"] == "Polygon" {
                            let count = json["features"][featureID]["geometry"]["coordinates"][0].count
                            for i in Range(0..<count) {
                                let point = json["features"][featureID]["geometry"]["coordinates"][0][i]
                                polygonPath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                            }
                            
                            let polygon = ExtendedPolygon(path: polygonPath)
                            polygon.title = json["features"][featureID]["id"].stringValue
                            for property in json["features"][featureID]["properties"] {
                                polygon.properties.updateValue(String(property.1), forKey: property.0)
                            }
                            polygon.properties.removeValueForKey("bbox")
                            polygon.key = json["features"][featureID]["properties"][self.titleProperty].stringValue
                            polygon.value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
                            if polygon.value > maxValue {
                                maxValue = polygon.value
                            }
                            if polygon.value < minValue {
                                minValue = polygon.value
                            }
                            polygon.strokeColor = UIColor.blackColor()
                            polygon.strokeWidth = 1
                            polygon.tappable = true
                            polygons.append(polygon)
                            
                            polygonPath = GMSMutablePath()
                        } else {
                        
                            let ploygonCount = json["features"][featureID]["geometry"]["coordinates"].count
                            for polygonNum in Range(0..<ploygonCount) {
                                let count = json["features"][featureID]["geometry"]["coordinates"][polygonNum][0].count
                                for i in Range(0..<count) {
                                    let point = json["features"][featureID]["geometry"]["coordinates"][polygonNum][0][i]
                                    polygonPath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                                } // traverse all coordinates in a polygon
                                
                                let polygon = ExtendedPolygon(path: polygonPath)
                                polygon.title = json["features"][featureID]["id"].stringValue
                                for property in json["features"][featureID]["properties"] {
                                    polygon.properties.updateValue(String(property.1), forKey: property.0)
                                }
                                polygon.properties.removeValueForKey("bbox")
                                polygon.key = json["features"][featureID]["properties"][self.titleProperty].stringValue
                                polygon.value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
                                if polygon.value > maxValue {
                                    maxValue = polygon.value
                                }
                                if polygon.value < minValue {
                                    minValue = polygon.value
                                }
                                polygon.strokeColor = UIColor.blackColor()
                                polygon.strokeWidth = 1
                                polygon.tappable = true
                                polygons.append(polygon)
                                
                                // Reset
                                polygonPath = GMSMutablePath()
                                
                            } // traverse each polygon in a feature
                        }
                    } // traverse features
                    
                    maxValue *= 1.01
                    minValue *= 0.99
                    step = (maxValue - minValue) / Double(self.colorClass)
                    //print("Dataset(\(featuresNum)) - max: \(maxValue), min: \(minValue)")
                    //print("Step = \(step)")
                    
                    for polygon in polygons {
                        //let colorRank = Int((shape.value - self.minValue) / self.step)
                        let rankIndex = Int((polygon.value - minValue) / step)
                        let transformedIndex = Int(Double(rankIndex) * 10.0 / Double(self.colorClass))
                        
                        
                        switch self.palette {
                        case "Red":
                            polygon.fillColor = ColorSet.redSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        case "Orange":
                            polygon.fillColor = ColorSet.OrangeSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        case "Green":
                            polygon.fillColor = ColorSet.GreenSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        case "Blue":
                            polygon.fillColor = ColorSet.BlueSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        case "Purple":
                            polygon.fillColor = ColorSet.PurpleSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        case "Gray":
                            polygon.fillColor = ColorSet.GraySet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        default:
                            polygon.fillColor = ColorSet.redSet[transformedIndex].colorWithAlphaComponent(self.alpha)
                        }
                        polygon.map = self.mapView
                    }
                    
                // ====================================================================================
                default: break
                }
                
            } // Alamofire request ends.
            
        }) // Multithread ends.
        
    } // View Did Load

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let extendedMarker = marker as! ExtendedMarker
        let alertMessage = UIAlertController(title: extendedMarker.key, message: "\(classifierProperty): \(extendedMarker.value)", preferredStyle: .alert)
        
        let detailActionHandler = { (action:UIAlertAction!) -> Void in
            let detailMessage = UIAlertController(title: extendedMarker.title, message: "Message", preferredStyle: .actionSheet)
            detailMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            // Show alert
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            let messageText = NSMutableAttributedString(
                string: extendedMarker.getProperties(),
                attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                    NSForegroundColorAttributeName : UIColor.darkGray
                ])
            detailMessage.setValue(messageText, forKey: "attributedMessage")
            self.present(detailMessage, animated: true, completion: nil)
        }
        
        alertMessage.addAction(UIAlertAction(title: "MORE", style: .default, handler: detailActionHandler))
        alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .destructive, handler: nil))
        self.present(alertMessage, animated: true, completion: nil)
        return true
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        switch shapeType {
        case "Polygon":
            let extendedPolygon = overlay as! ExtendedPolygon
            let alertMessage = UIAlertController(title: extendedPolygon.key, message: "\(classifierProperty): \(extendedPolygon.value)", preferredStyle: .alert)
            
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                let detailMessage = UIAlertController(title: extendedPolygon.title, message: "Message", preferredStyle: .actionSheet)
                detailMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.center
                let messageText = NSMutableAttributedString(
                    string: extendedPolygon.getProperties(),
                    attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                        NSForegroundColorAttributeName : UIColor.darkGray
                    ])
                detailMessage.setValue(messageText, forKey: "attributedMessage")
                self.present(detailMessage, animated: true, completion: nil)
            }
            alertMessage.addAction(UIAlertAction(title: "MORE", style: .default, handler: detailActionHandler))
            alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .destructive, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
            
        case "Polyline":
            let extendedPolyline = overlay as! ExtendedPolyline
            let alertMessage = UIAlertController(title: extendedPolyline.key, message: "\(classifierProperty): \(extendedPolyline.value)", preferredStyle: .alert)
            
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                let detailMessage = UIAlertController(title: extendedPolyline.title, message: "Message", preferredStyle: .actionSheet)
                detailMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.center
                let messageText = NSMutableAttributedString(
                    string: extendedPolyline.getProperties(),
                    attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                        NSForegroundColorAttributeName : UIColor.darkGray
                    ])
                detailMessage.setValue(messageText, forKey: "attributedMessage")
                self.present(detailMessage, animated: true, completion: nil)
            }
            alertMessage.addAction(UIAlertAction(title: "MORE", style: .default, handler: detailActionHandler))
            alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .destructive, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
            
        default:
            break
        }
        
        
    }

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
