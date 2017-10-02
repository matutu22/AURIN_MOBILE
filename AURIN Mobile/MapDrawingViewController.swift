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
import SwiftyJSON
//import SVProgressHUD
import MBProgressHUD

class MapDrawingViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    
    private var clusterManager: GMUClusterManager!

    // Receive Data from Map Setting View
    var dataset:Dataset!
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    var titleProperty: String = ""
    var classifierProperty: String = ""
    var palette: String = "Red"
    var colorClass: Int = 6
    var opacity: Float = 0.7
    var geom_name = "ogr_geometry"
    var queryURL : String = ""
    var suburbQuery : String = ""

    var progressHUD : MBProgressHUD = MBProgressHUD()
    
    // Used in Drawing Map
    var alpha: CGFloat = 0.7
    var shapeType = "Overlay"

    @IBOutlet var backButton: UIButton!
    @IBOutlet var mapView: GMSMapView!

    // Mark: viewdidload
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title of navigation bar

        let label = UILabel(frame: CGRect(x:0, y:0, width:400, height:50))
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = "\(dataset.title)"
        label.font = UIFont(name: "Avenir-Light", size: 16.0)
        label.adjustsFontSizeToFitWidth = true
        
        self.navigationItem.titleView = label
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        queryURL = "http://openapi.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(dataset.name)&MaxFeatures=1000&outputFormat=json&CQL_FILTER=BBOX(\(geom_name),\(chooseBBOX.lowerLAT),\(chooseBBOX.lowerLON),\(chooseBBOX.upperLAT),\(chooseBBOX.upperLON))"
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
        
        progressHUD = MBProgressHUD.showAdded(to: self.mapView, animated: true)
        progressHUD.mode = MBProgressHUDMode.indeterminate
        progressHUD.label.text = "Loading..."
        
        self.queryDataSet(queryURL)
        
    } // View Did Load
    
    
    fileprivate func queryDataSet(_ queryURL : String) {
        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(queryURL).validate().responseJSON() { response in

                guard response.result.isSuccess else{
                    Reuse.shared.showAlert(view: self, title: "Oops!", message: "There is something wrong connecting with the server.")
                    self.progressHUD.hide(animated: true)
                    return
                }
                
                let json = try! JSON(data: response.data!)
                
                if json["features"].count == 0 {
                    Reuse.shared.showAlert(view: self, title: "No data",
                                           message: "There is no data in the selected area, please try to choose another area.")
                }
                
                let shapeType = json["features"][0]["geometry"]["type"]
                print("shapetype", shapeType)
                
                //Different dataset properties
                switch shapeType {
                case "Point":
                    self.pointDataset(json)
                case "LineString": break
                case "MultiPoint": break
                case "MultiLineString":
                    self.multiLineStringDataSet(json)
                case "Polygon":
                    self.polygonDataSet(json)
                case "MultiPolygon":
                    self.multiPolygonDataSet(json)
                default:
                    Reuse.shared.showAlert(view: self, title: "Error", message: "Something wrong")
                    break
                }
                
                // Process Bar Setting
                self.progressHUD.hide(animated: true)
                let doneProgress = MBProgressHUD.showAdded(to: self.mapView, animated: true)
                doneProgress.mode = MBProgressHUDMode.customView
                doneProgress.customView = UIImageView.init(image: #imageLiteral(resourceName: "Checkmark"))
                doneProgress.label.text = "Done"
                doneProgress.isSquare = true
                doneProgress.hide(animated: true, afterDelay: 2)

            } // Alamofire request ends.
        }

    }
    
    fileprivate func pointDataset(_ json : JSON) {
        let featuresNum = json["features"].count
        for featureID in 0..<featuresNum {
            let thisPoint = json["features"][featureID]
            
            let latitude = thisPoint["geometry"]["coordinates"][1].doubleValue
            let longitude = thisPoint["geometry"]["coordinates"][0].doubleValue
            let marker = ExtendedMarker(position: CLLocationCoordinate2DMake(latitude, longitude))
            marker.title = thisPoint["id"].stringValue

            marker.key = thisPoint["properties"][self.titleProperty].stringValue
            marker.value = thisPoint["properties"][self.classifierProperty].doubleValue
            
            let markerColor = ColorSet.colorDictionary[self.palette]
            marker.icon = GMSMarker.markerImage(with: markerColor?.withAlphaComponent(self.alpha))
            self.clusterManager.add(marker)

        }
        self.clusterManager.cluster()
        
        self.clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    fileprivate func multiLineStringDataSet(_ json : JSON) {
        self.shapeType = "Polyline"
        let featuresNum = json["features"].count
        var polylinePath = GMSMutablePath()
        
        for featureID in 0..<featuresNum {
            let thisPolyline = json["features"][featureID]
            let polylineCount = thisPolyline["geometry"]["coordinates"].count

            for polylineNum in 0..<polylineCount {
                let coordinates = thisPolyline["geometry"]["coordinates"][polylineNum]

                let count = coordinates.count
                for coordinateNum in 0..<count {
                    let point = coordinates[coordinateNum]
                    polylinePath.add(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                }
                
                let polyline = ExtendedPolyline(path: polylinePath)
                polyline.title = thisPolyline["id"].stringValue
                for property in thisPolyline["properties"] {
                    polyline.properties.updateValue(String(describing: property.1), forKey: property.0)
                }
                polyline.properties.removeValue(forKey: "bbox")
                polyline.key = thisPolyline["properties"][self.titleProperty].stringValue
                polyline.value = thisPolyline["properties"][self.classifierProperty].doubleValue
                
                polyline.strokeWidth = 2.0
                let strokeColor = ColorSet.colorDictionary[self.palette]
                polyline.strokeColor = strokeColor!.withAlphaComponent(self.alpha)
                polyline.geodesic = true
                polyline.isTappable = true
                polyline.map = self.mapView
                polylinePath = GMSMutablePath()
            }
        }
        
    }
    
    fileprivate func polygonDataSet(_ json: JSON){
        self.shapeType = "Polygon"
        let featuresNum = json["features"].count
        
        if featuresNum > 100 {
            self.areaTooLargeAlert()
            return
        }
        
        var polygonPath = GMSMutablePath()
        var polygons = [ExtendedPolygon]()
        var maxValue = 0.0
        var minValue = 9999999.0
        var step = 0.0
        
        for featureID in 0..<featuresNum {
            let polygonCoordinatesList = json["features"][featureID]["geometry"]["coordinates"][0]
            let coordinatecount = polygonCoordinatesList.count
            
            for coordianteNum in 0..<coordinatecount {
                let polygonCoordinate = polygonCoordinatesList[coordianteNum]
                polygonPath.add(CLLocationCoordinate2D(latitude: (polygonCoordinate[1].doubleValue), longitude: (polygonCoordinate[0].doubleValue)))
            }
            
            let polygon = ExtendedPolygon(path: polygonPath)
            polygon.title = json["features"][featureID]["id"].stringValue

            polygon.key = json["features"][featureID]["properties"][self.titleProperty].stringValue
            polygon.value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
            
            if polygon.value > maxValue { maxValue = polygon.value }
            if polygon.value < minValue { minValue = polygon.value }
            
            polygon.strokeColor = UIColor.black
            polygon.strokeWidth = 1
            polygon.isTappable = true
            polygons.append(polygon)
            
            polygonPath = GMSMutablePath()
        }
        maxValue *= 1.01
        minValue *= 0.99
        step = (maxValue - minValue) / Double(self.colorClass)

        drawPolygons(polygons, minValue: minValue, step: step)

    }
    
    fileprivate func multiPolygonDataSet(_ json: JSON){
        self.shapeType = "Polygon"
        let featuresNum = json["features"].count
        var polygonPath = GMSMutablePath()
        var polygons = [ExtendedPolygon]()
        var maxValue = 0.0
        var minValue = Double.infinity
        var step = 0.0
        
        if featuresNum > 100 {
            self.areaTooLargeAlert()
            return
        }
        
        for featureID in 0..<featuresNum {
            let thisPloygon = json["features"][featureID]
            let polygonCoordinatesList = thisPloygon["geometry"]["coordinates"][0][0]
            let coordinatecount = polygonCoordinatesList.count
            
            for coordianteNum in 0..<coordinatecount {
                let polygonCoordinate = polygonCoordinatesList[coordianteNum]
                polygonPath.add(CLLocationCoordinate2D(latitude: (polygonCoordinate[1].doubleValue),
                                                       longitude: (polygonCoordinate[0].doubleValue)))
            } // traverse each polygon in a feature
            
            let polygon = ExtendedPolygon(path: polygonPath)
            
            polygon.key = thisPloygon["properties"][self.titleProperty].stringValue
            polygon.value = thisPloygon["properties"][self.classifierProperty].doubleValue
            
            if polygon.value > maxValue { maxValue = polygon.value }
            if polygon.value < minValue { minValue = polygon.value }
            
            polygon.title = thisPloygon["id"].stringValue
            
            polygon.strokeColor = UIColor.black
            polygon.strokeWidth = 1
            polygon.isTappable = true
            polygons.append(polygon)
            
            polygonPath = GMSMutablePath()
            
        } // traverse features
        maxValue *= 1.01
        minValue *= 0.99
        step = (maxValue - minValue) / Double(self.colorClass)
        
        drawPolygons(polygons, minValue: minValue, step: step)
    }
    
    fileprivate func drawPolygons(_ polygons : [ExtendedPolygon], minValue : Double, step : Double){
        for polygon in polygons {
            let rankIndex = abs (floor((polygon.value - minValue) / step))
            
            let transformedIndex = Int(round(Double(rankIndex) * 10.0 / Double(self.colorClass)))
            
            switch self.palette {
            case "Red":
                polygon.fillColor = ColorSet.redSet[transformedIndex].withAlphaComponent(self.alpha)
            case "Orange":
                polygon.fillColor = ColorSet.OrangeSet[transformedIndex].withAlphaComponent(self.alpha)
            case "Green":
                polygon.fillColor = ColorSet.GreenSet[transformedIndex].withAlphaComponent(self.alpha)
            case "Blue":
                polygon.fillColor = ColorSet.BlueSet[transformedIndex].withAlphaComponent(self.alpha)
            case "Purple":
                polygon.fillColor = ColorSet.PurpleSet[transformedIndex].withAlphaComponent(self.alpha)
            case "Gray":
                polygon.fillColor = ColorSet.GraySet[transformedIndex].withAlphaComponent(self.alpha)
            default:
                polygon.fillColor = ColorSet.redSet[transformedIndex].withAlphaComponent(self.alpha)
            }
            polygon.map = self.mapView
        }
    }
    

    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if (marker.userData as? GMUCluster) != nil{
            NSLog("Tapped on a cluster")
        }else{
            NSLog("Tapped on Marker")
            let extendedMarker = marker.userData as! ExtendedMarker
            let alertMessage = UIAlertController(title: extendedMarker.key, message: "\(classifierProperty): \(extendedMarker.value)", preferredStyle: .alert)
            
            if extendedMarker.key == ""{
                self.titleNullAlert()
                return true
            }
            let newName = extendedMarker.key.replacingOccurrences(of: " ", with: "%20")
            self.suburbQuery = "http://openapi.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(self.dataset.name)&outputFormat=json&CQL_FILTER=(\(self.titleProperty)='\(newName)')"
            
            Alamofire.request(self.suburbQuery).response { response in
                let json = try! JSON(data: response.data!)
                for property in json["features"][0]["properties"] {
                    if property.0 != "bbox"{
                        extendedMarker.properties.updateValue(String(describing: property.1), forKey: property.0)
                    }
                }
            }
            
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                let detailMessage = UIAlertController(title: extendedMarker.title, message: "Message", preferredStyle: .actionSheet)
                detailMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.center
                let messageText = NSMutableAttributedString(
                    string: (extendedMarker.getProperties()),
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

        }
        return true
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        switch shapeType {
        case "Polygon":
            NSLog("Tapped on polygon")
            let extendedPolygon = overlay as! ExtendedPolygon
            let alertMessage = UIAlertController(title: extendedPolygon.key, message: "\(classifierProperty): \(extendedPolygon.value)", preferredStyle: .alert)
            
            if extendedPolygon.key == ""{
                self.titleNullAlert()
                return
            }
            let newName = extendedPolygon.key.replacingOccurrences(of: " ", with: "%20")
            self.suburbQuery = "http://openapi.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(self.dataset.name)&outputFormat=json&CQL_FILTER=(\(self.titleProperty)='\(newName)')"
            
            Alamofire.request(self.suburbQuery).response { response in
                let json = try! JSON(data: response.data!)
                for property in json["features"][0]["properties"] {
                    if property.0 != "bbox"{
                        extendedPolygon.properties.updateValue(String(describing: property.1), forKey: property.0)
                    }
                }
            }
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                print("Detailactionhandler")
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

    override func viewWillDisappear(_ animated: Bool) {
        if let barFont1 = UIFont(name: "Avenir-Light", size: 24.0) {
            self.navigationController?.navigationBar.titleTextAttributes =
                [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:barFont1]
        }
    }
    
    func areaTooLargeAlert(){
        Reuse.shared.showAlert(view: self, title: "Area too large",
                               message: "The area you choose has too much data, please choose a smaller area.")
    }
    
    func titleNullAlert(){
        Reuse.shared.showAlert(view: self, title: "No data of current title",
                               message: "There is no data under chosen title attribute, please go back select another title.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
