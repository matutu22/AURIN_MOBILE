//
//  MapDrawingViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/15.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

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

        navigationItem.title = "\(dataset.title)"
        
//        let multiPolygonURL = "https://geoserver.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=grattan:Grattan_Job_Access2011&MaxFeatures=1000&outputFormat=json&CQL_FILTER=BBOX(the_geom,-37.843287468235644,144.88364340276473,-37.7613640945703,145.05084158388618)"
        
        
//        let queryURL = "http://localhost:3000/query?name=dataset&llat=1&llon=2&ulat=3&ulon=4"
        
//        let queryURL = "http://192.168.2.19:3000/query?dataset=\(dataset.name)&geo_name=\(geom_name)&llat=\(chooseBBOX.lowerLAT)&llon=\(chooseBBOX.lowerLON)&ulat=\(chooseBBOX.upperLAT)&ulon=\(chooseBBOX.upperLON)"
        
        var queryURL = "https://geoserver.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(dataset.name)&MaxFeatures=1000&outputFormat=json&CQL_FILTER=BBOX(\(geom_name),\(chooseBBOX.lowerLAT),\(chooseBBOX.lowerLON),\(chooseBBOX.upperLAT),\(chooseBBOX.upperLON))"
        
        // If the use choose to use the intermediate server, change the URL.
        if useSimplifier {
            queryURL = "http://\(serverAddress)/query?dataset=\(dataset.name)&geo_name=\(geom_name)&llat=\(chooseBBOX.lowerLAT)&llon=\(chooseBBOX.lowerLON)&ulat=\(chooseBBOX.upperLAT)&ulon=\(chooseBBOX.upperLON)&simpify=\(simLevel)"
        }
        
        
        print(queryURL)
        
        let zoomLevel = Float(round((log2(210 / abs(chooseBBOX.upperLON - chooseBBOX.lowerLON)) + 1) * 100) / 100)
        let centerLatitude = (chooseBBOX.lowerLAT + chooseBBOX.upperLAT) / 2
        let centerLongitude = (chooseBBOX.lowerLON + chooseBBOX.upperLON) / 2
        
        mapView.bringSubviewToFront(backButton)
        alpha = CGFloat(opacity)
        
        self.mapView.myLocationEnabled = true;
        self.mapView.mapType = kGMSTypeNormal;
        self.mapView.settings.compassButton = true;
        self.mapView.settings.myLocationButton = true;
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.rotateGestures = false
        self.mapView.delegate = self;
        let camera = GMSCameraPosition.cameraWithLatitude(centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
        self.mapView.animateToCameraPosition(camera)
        
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            Alamofire.request(.GET, queryURL).response { (_request, _response, data, _error) in
                // 获取JSON信息
                let json = JSON(data: data!)
                
                if json["features"].count == 0 {
                    let alertMessage = UIAlertController(title: "No Data", message: "There is no data in the selected area, please try to choose another area.", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                }
                
                // 分析第一个元素即可知数据集的数据类型
                let shapeType = json["features"][0]["geometry"]["type"]
                print(shapeType)
                switch shapeType {
                // ====================================================================================
                case "Point":
                    let featuresNum = json["features"].count
                    for featureID in Range(0..<featuresNum) {
                        
                        let latitude = json["features"][featureID]["geometry"]["coordinates"][1].doubleValue
                        let longitude = json["features"][featureID]["geometry"]["coordinates"][0].doubleValue
                        //print("\(latitude), \(longitude)")
                        let marker = ExtendedMarker(position: CLLocationCoordinate2DMake(latitude, longitude))
                        //print(json["features"][featureID]["properties"])
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
                    // 得到数据集的数目
                    let featuresNum = json["features"].count
                    // 存储Polyline的Path和所有Polyline
                    var polylinePath = GMSMutablePath()
                    //                var polylines = [ExtendedPolyline]()
                    //                var maxValue = 0.0
                    //                var minValue = 9999999.0
                    //                var step = 0.0
                    
                    // 对于每个数据集，要拿出数据集的properties，找到坐标，并画在地图上
                    for featureID in Range(0..<featuresNum) {
                        let polylineCount = json["features"][featureID]["geometry"]["coordinates"].count
                        for polylineNum in Range(0..<polylineCount) {
                            let count = json["features"][featureID]["geometry"]["coordinates"][polylineNum].count
                            for coordinateNum in Range(0..<count) {
                                let point = json["features"][featureID]["geometry"]["coordinates"][polylineNum][coordinateNum]
                                polylinePath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                            } // 坐标遍历完毕
                            
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
                    // Do something
                    self.shapeType = "Polygon"
                    let featuresNum = json["features"].count
                    // 为了存储Polygon的Path和所有Polygon
                    var polygonPath = GMSMutablePath()
                    var polygons = [ExtendedPolygon]()
                    var maxValue = 0.0
                    var minValue = 9999999.0
                    var step = 0.0
                    
                    // 每个featureID都是一个Polygon
                    for featureID in Range(0..<featuresNum) {
                        if json["features"][featureID]["geometry"]["type"] == "Polygon" {
                            let count = json["features"][featureID]["geometry"]["coordinates"][0].count
                            for i in Range(0..<count) {
                                let point = json["features"][featureID]["geometry"]["coordinates"][0][i]
                                // 向Polygon坐标集中加入当前坐标
                                polygonPath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                            } // 遍历Polygon的每个坐标
                            
                            // 坐标集遍历完毕，通过坐标集生成Polygon
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
                            
                            // 一个Polygon画完，要重置Path坐标集，以便重新写入
                            polygonPath = GMSMutablePath()
                        } else {
                        
                            // 计算Polygon由多少个点坐标构成
                            let ploygonCount = json["features"][featureID]["geometry"]["coordinates"].count
                            for polygonNum in Range(0..<ploygonCount) {
                                let count = json["features"][featureID]["geometry"]["coordinates"][polygonNum][0].count
                                // 对于每个点坐标
                                for i in Range(0..<count) {
                                    let point = json["features"][featureID]["geometry"]["coordinates"][polygonNum][0][i]
                                    // 向Polygon坐标集中加入当前坐标
                                    polygonPath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                                } // 遍历Polygon的每个坐标
                                
                                // 坐标集遍历完毕，通过坐标集生成Polygon
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
                                
                                // 一个Polygon画完，要重置Path坐标集，以便重新写入
                                polygonPath = GMSMutablePath()
                                
                            } // 遍历Feature里面包含的各个Polygons
                        }
                    } // 遍历Features
                    
                    // 取出了数据集中的最大值和最小值
                    //print("Dataset(\(featuresNum)) - max: \(maxValue), min: \(minValue)")
                    // 略微调整最大值和最小值的边界
                    maxValue *= 1.01
                    minValue *= 0.99
                    step = (maxValue - minValue) / Double(self.colorClass)
                    //print("Dataset(\(featuresNum)) - max: \(maxValue), min: \(minValue)")
                    //print("Step = \(step)")
                    
                    // 遍历图形集，开始向地图上画图
                    for polygon in polygons {
                        //let colorRank = Int((shape.value - self.minValue) / self.step)
                        // 转换成10种颜色集的下标，10.0 is the size of color set.
                        let rankIndex = Int((polygon.value - minValue) / step)
                        let transformedIndex = Int(Double(rankIndex) * 10.0 / Double(self.colorClass))
                        
                        // To see the conversion of color set index.
                        //print("\(rankIndex) -> \(transformedIndex)")
                        
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
                let circleCenter = CLLocationCoordinate2D(latitude: -37.84, longitude: 144.88)
                let circ = GMSCircle(position: circleCenter, radius: 1000)
                circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
//                circ.strokeColor = UIColor.redColor()
                circ.strokeWidth = 1
                circ.map = self.mapView;
            }
            
        })
        
    } // View Did Load

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        let extendedMarker = marker as! ExtendedMarker
        let alertMessage = UIAlertController(title: extendedMarker.key, message: "\(classifierProperty): \(extendedMarker.value)", preferredStyle: .Alert)
        
        let detailActionHandler = { (action:UIAlertAction!) -> Void in
            // 定义一个Alert信息，Style为弹出式Alert
            let detailMessage = UIAlertController(title: extendedMarker.title, message: "Message", preferredStyle: .ActionSheet)
            // 向Alert弹框里面增加一个选项
            detailMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            // 显示弹框
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Center
            let messageText = NSMutableAttributedString(
                string: extendedMarker.getProperties(),
                attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    //NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
                    NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                    NSForegroundColorAttributeName : UIColor.darkGrayColor()
                ])
            detailMessage.setValue(messageText, forKey: "attributedMessage")
            //            detailMessage.setValue(NSAttributedString(string: extendedMarker.getProperties(), attributes: [NSFontAttributeName: UIFont.systemFontOfSize(9), NSForegroundColorAttributeName: UIColor.darkGrayColor()]), forKey: "attributedMessage")
            self.presentViewController(detailMessage, animated: true, completion: nil)
        }
        
        
        
        
        // 向Alert弹框里面增加一个选项
        alertMessage.addAction(UIAlertAction(title: "MORE", style: .Default, handler: detailActionHandler))
        alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .Destructive, handler: nil))
        self.presentViewController(alertMessage, animated: true, completion: nil)
        return true
    }
    
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        // Overlay可能有两种情况，PolyLine和Polygon要分开处理
        switch shapeType {
        case "Polygon":
            let extendedPolygon = overlay as! ExtendedPolygon
            let alertMessage = UIAlertController(title: extendedPolygon.key, message: "\(classifierProperty): \(extendedPolygon.value)", preferredStyle: .Alert)
            
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                // 定义一个Alert信息，Style为弹出式Alert
                let detailMessage = UIAlertController(title: extendedPolygon.title, message: "Message", preferredStyle: .ActionSheet)
                // 向Alert弹框里面增加一个选项
                detailMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                // 显示弹框
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.Center
                let messageText = NSMutableAttributedString(
                    string: extendedPolygon.getProperties(),
                    attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        //NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
                        NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                        NSForegroundColorAttributeName : UIColor.darkGrayColor()
                    ])
                detailMessage.setValue(messageText, forKey: "attributedMessage")
                self.presentViewController(detailMessage, animated: true, completion: nil)
            }
            
            // 向Alert弹框里面增加一个选项
            alertMessage.addAction(UIAlertAction(title: "MORE", style: .Default, handler: detailActionHandler))
            alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .Destructive, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
        case "Polyline":
            let extendedPolyline = overlay as! ExtendedPolyline
            let alertMessage = UIAlertController(title: extendedPolyline.key, message: "\(classifierProperty): \(extendedPolyline.value)", preferredStyle: .Alert)
            
            let detailActionHandler = { (action:UIAlertAction!) -> Void in
                // 定义一个Alert信息，Style为弹出式Alert
                let detailMessage = UIAlertController(title: extendedPolyline.title, message: "Message", preferredStyle: .ActionSheet)
                // 向Alert弹框里面增加一个选项
                detailMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                // 显示弹框
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.Center
                let messageText = NSMutableAttributedString(
                    string: extendedPolyline.getProperties(),
                    attributes: [
                        NSParagraphStyleAttributeName: paragraphStyle,
                        //NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
                        NSFontAttributeName: UIFont(name: "Menlo-Regular",size: 11.0)!,
                        NSForegroundColorAttributeName : UIColor.darkGrayColor()
                    ])
                detailMessage.setValue(messageText, forKey: "attributedMessage")
                self.presentViewController(detailMessage, animated: true, completion: nil)
            }
            // 向Alert弹框里面增加一个选项
            alertMessage.addAction(UIAlertAction(title: "MORE", style: .Default, handler: detailActionHandler))
            alertMessage.addAction(UIAlertAction(title: "CLOSE", style: .Destructive, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
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
