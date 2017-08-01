//
//  ChartDrawingTableViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/17.
//  Copyright © 2016年 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    Requset data from AURIN and generate a bar chart.
 ********************************************************************************************/


import UIKit
import Charts
import Alamofire
import GoogleMaps


class ChartDrawingTableViewController: UITableViewController, ChartViewDelegate, GMSMapViewDelegate {

    
    // Receive from former view.
    var dataset:Dataset!
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    var titleProperty: String = ""
    var classifierProperty: String = ""
    var palette: String = "Default"
    //var colorClass: Int = 6
    var opacity: Float = 0.7
    var geom_name = "the_geom"

    var alpha: CGFloat = 0.7
    
    // Hidden Cell Flag.
    var mapViewHidden = true
    var detailViewHidden = true

    // Store the x-axis and y-axis data.
    var xAxis: [String] = []
    var yAxis: [Double] = []
    
    // Bind the UIKit components.
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(dataset.title)"
        
        alpha = CGFloat(opacity)
        
        keyLabel.text = titleProperty
        valueLabel.text = classifierProperty
        
        barChartView.delegate = self
        
        self.mapView.mapType = .normal;
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.scrollGestures = true
        self.mapView.delegate = self;
        // Set the map location to fit the dataset.
        let zoomLevel = Float(round((log2(210 / abs(dataset.bbox.upperLON - dataset.bbox.lowerLON)) + 1) * 100) / 100)
        let centerLatitude = (dataset.bbox.lowerLAT + dataset.bbox.upperLAT) / 2
        let centerLongitude = (dataset.bbox.lowerLON + dataset.bbox.upperLON) / 2
        
        let camera = GMSCameraPosition.camera(withLatitude: centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
        self.mapView.animate(camera)
        
        // Generate the query which only request for key & value properties.
        let queryURL = "https://geoserver.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(dataset.name)&MaxFeatures=1000&outputFormat=json&CQL_FILTER=BBOX(\(geom_name),\(chooseBBOX.lowerLAT),\(chooseBBOX.lowerLON),\(chooseBBOX.upperLAT),\(chooseBBOX.upperLON))&PropertyName=\(titleProperty),\(classifierProperty)"
        
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0).async(execute: {
            Alamofire.request(queryURL).response { response in
                let json = JSON(data: response.data!)
                
                if json["features"].count == 0 {
                    let alertMessage = UIAlertController(title: "No Data", message: "There is no data in the selected area, please try to choose another area.", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                }
                
                
                // ====================================================================================
                let featuresNum = json["features"].count
                for featureID in Range(0..<featuresNum) {
                    let key = json["features"][featureID]["properties"][self.titleProperty].stringValue
                    let value = json["features"][featureID]["properties"][self.classifierProperty].doubleValue
                    self.xAxis.append(key)
                    self.yAxis.append(value)
                    self.tableView.reloadData()
                }
                
                self.setChart(self.xAxis, values: self.yAxis)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !mapViewHidden && detailViewHidden && indexPath.section == 0 {
            // Map opend，Text closed.
            switch indexPath.row {
            case 0: // Bar Chart.
                return 275
            case 2: // Text Field.
                return 0
            case 3: // Map View.
                return 200
            default: // Cell Label.
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else if mapViewHidden && !detailViewHidden && indexPath.section == 0 {
            // Map closed，Text opend.
            switch indexPath.row {
            case 0: // Bar Chart.
                return 355
            case 2: // Text Field.
                return 120
            case 3: // Map View.
                return 0
            default: // Cell Label.
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else if mapViewHidden && detailViewHidden && indexPath.section == 0 {
            // Map closed，Text closed
            switch indexPath.row {
            case 0: // Bar Chart.
                return 350
            case 2: // Text Field.
                return 0
            case 3: // Map View.
                return 0
            default: // Cell Label.
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else if !mapViewHidden && !detailViewHidden && indexPath.section == 0 {
            // Map opend，Text opend.
            switch indexPath.row {
            case 0: // Bar Chart.
                return 255
            case 2: // Text Field.
                return 70
            case 3: // Map View.
                return 150
            default: // Cell Label.
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
            
        } else {
            // Other cells in section 0 and 1.
            return super.tableView(tableView, heightForRowAt: indexPath)
        }

    }
    
    @IBAction func mapSwitch(_ sender: UISwitch) {
        if sender.isOn {
            mapViewHidden = false
            tableView.reloadData()
        } else {
            mapViewHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func detailSwitch(_ sender: UISwitch) {
        if sender.isOn {
            detailViewHidden = false
            tableView.reloadData()
        } else {
            detailViewHidden = true
            tableView.reloadData()
        }
    }


    func setChart(_ dataPoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "\(classifierProperty)")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChartView.data = chartData
        
        switch self.palette {
        case "Red":
            //chartDataSet.colors = ChartColorTemplates.liberty()
            chartDataSet.colors = ColorSet.barChartRed
        case "Orange":
            //chartDataSet.colors = ChartColorTemplates.colorful()
            chartDataSet.colors = ColorSet.barChartOrange
        case "Green":
            //chartDataSet.colors = ChartColorTemplates.joyful()
            chartDataSet.colors = ColorSet.barChartGreen
        case "Blue":
            //chartDataSet.colors = ChartColorTemplates.material()
            chartDataSet.colors = ColorSet.barChartBlue
        case "Purple":
            //chartDataSet.colors = ChartColorTemplates.pastel()
            chartDataSet.colors = ColorSet.barChartPurple
        case "Gray":
            //chartDataSet.colors = ChartColorTemplates.vordiplom()
            chartDataSet.colors = ColorSet.barChartGray
        default:
            chartDataSet.colors = ChartColorTemplates.liberty()
        }
        
        //chartDataSet.colors = ColorSet.BlueSet
        
        barChartView.noDataText = "Loading data, please wait..."
        barChartView.noDataTextDescription = "The Internet is busy now"
        barChartView.descriptionText = ""
        
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.backgroundColor = UIColor.whiteColor()
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Set the limit line.
        var average = 0.0
        for value in values {
            average += value
        }
        average /= Double(values.count)
        
        let limitLine = ChartLimitLine(limit: average, label: "AVG")
        limitLine.lineColor = UIColor.redColor()
        barChartView.drawValueAboveBarEnabled = false
        barChartView.rightAxis.addLimitLine(limitLine)
        
    }
    
    
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        mapView.clear()
        keyLabel.text = "\(xAxis[entry.xIndex])"
        valueLabel.text = "\(entry.value)"
        
        
        if !mapViewHidden || !detailViewHidden {
            // The URL request shoud not include 'space', so change it to '%20'.
            let newName = xAxis[entry.xIndex].stringByReplacingOccurrencesOfString(" ", withString: "%20")
            let nameSearchURL = "https://geoserver.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName=\(dataset.name)&outputFormat=json&CQL_FILTER=(\(titleProperty)='\(newName)')"
            print(nameSearchURL)
            
            Alamofire.request(.GET, nameSearchURL).response { (_request, _response, data, _error) in
                let json = JSON(data: data!)
                let shapeType = json["features"][0]["geometry"]["type"]
                switch shapeType {
                // ====================================================================================
                case "Point":
                    let latitude = json["features"][0]["geometry"]["coordinates"][1].doubleValue
                    let longitude = json["features"][0]["geometry"]["coordinates"][0].doubleValue
                    let marker = ExtendedMarker(position: CLLocationCoordinate2DMake(latitude, longitude))
                    marker.title = json["features"][0]["id"].stringValue
                    for property in json["features"][0]["properties"] {
                        marker.properties.updateValue(String(property.1), forKey: property.0)
                    }
                    marker.properties.removeValueForKey("bbox")
                    
                    self.textView.editable = false
                    self.textView.text = marker.getProperties()
                    marker.map = self.mapView
                // ====================================================================================
                case "MultiLineString":
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
                            polyline.strokeColor = strokeColor!.colorWithAlphaComponent(0.7)
                            polyline.geodesic = true
                            polyline.tappable = true
                            polyline.map = self.mapView
                            polylinePath = GMSMutablePath()
                            self.textView.editable = false
                            self.textView.text = polyline.getProperties()
                        }
                    }
                // ====================================================================================
                case "MultiPolygon":
                    var polygonPath = GMSMutablePath()
                    let count = json["features"][0]["geometry"]["coordinates"][0][0].count
                    for i in Range(0..<count) {
                        let point = json["features"][0]["geometry"]["coordinates"][0][0][i]
                        polygonPath.addCoordinate(CLLocationCoordinate2D(latitude: (point[1].double!),  longitude: (point[0].double!)))
                    }
                    
                    let polygon = ExtendedPolygon(path: polygonPath)
                    polygon.title = json["features"][0]["id"].stringValue
                    for property in json["features"][0]["properties"] {
                        polygon.properties.updateValue(String(property.1), forKey: property.0)
                    }
                    
                    
                    polygon.properties.removeValueForKey("bbox")
                    polygon.key = json["features"][0]["properties"][self.titleProperty].stringValue
                    polygon.value = json["features"][0]["properties"][self.classifierProperty].doubleValue
                    polygon.strokeColor = UIColor.blackColor()
                    polygon.strokeWidth = 1
                    polygon.tappable = true
                    
                    switch self.palette {
                    case "Red":
                        polygon.fillColor = ColorSet.colorDictionary["Red"]!.colorWithAlphaComponent(self.alpha)
                    case "Orange":
                        polygon.fillColor = ColorSet.colorDictionary["Orange"]!.colorWithAlphaComponent(self.alpha)
                    case "Green":
                        polygon.fillColor = ColorSet.colorDictionary["Green"]!.colorWithAlphaComponent(self.alpha)
                    case "Blue":
                        polygon.fillColor = ColorSet.colorDictionary["Blue"]!.colorWithAlphaComponent(self.alpha)
                    case "Purple":
                        polygon.fillColor = ColorSet.colorDictionary["Purple"]!.colorWithAlphaComponent(self.alpha)
                    case "Gray":
                        polygon.fillColor = ColorSet.colorDictionary["Gray"]!.colorWithAlphaComponent(self.alpha)
                    default:
                        polygon.fillColor = ColorSet.theme["AURIN-Ming"]?.colorWithAlphaComponent(self.alpha)
                    }
                    
                    polygon.map = self.mapView
                    
                    let lowerLat = json["features"][0]["properties"]["bbox"][1].doubleValue
                    let lowerLon = json["features"][0]["properties"]["bbox"][0].doubleValue
                    let upperLat = json["features"][0]["properties"]["bbox"][3].doubleValue
                    let upperLon = json["features"][0]["properties"]["bbox"][2].doubleValue
                    
                    let zoomLevel = Float(round((log2(210 / abs(upperLon - lowerLon)) + 1) * 100) / 100) - 1.5
                    let centerLatitude = (lowerLat + upperLat) / 2
                    let centerLongitude = (lowerLon + upperLon) / 2
                    
                    
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
                    self.mapView.animateToCameraPosition(camera)
                    
                    
                    polygonPath = GMSMutablePath()
                    
                    self.textView.editable = false
                    self.textView.text = polygon.getProperties()
                    self.textView.textColor = ColorSet.theme["AURIN-Ming"]
                    self.textView.font = UIFont(name: "Menlo", size: 10)
                    self.textView.textAlignment = .Center
                    
                    
                // ====================================================================================
                default:
                    break
                } // Switch ends.
                
            } // Alamofire request ends.
            
        } // Hidden Flag checking ends.
        
    } // FUNCTION: chartValueSelected ends.

}
