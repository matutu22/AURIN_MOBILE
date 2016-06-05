//
//  MapSettingTableViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/15.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import GoogleMaps


class MapSettingTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate {

    // Receive data from former view.
    var propertyList = [String: String]()
    var dataset:Dataset!
    var geom_name = "the_geom"

    
    // Passing data to next view.
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    var titleProperty: String = ""
    var classifierProperty: String = ""
    var palette: String = "Red"
    var colorClass: Int = 6
    var opacity: Float = 0.7
    
    
    // Picker Options
    let states = ["Capital Territory", "New South Wales", "Northern Territory", "Queensland", "South Australia", "Tasmania", "Victoria", "Western Australia"]
    var suburbs = ["ACT-All", "Canberra"]
    let vic = ["VIC-All", "Ballarat", "Bendigo", "Geelong", "Hume", "Latrobe - Gippsland", "Melbourne - Inner", "Melbourne - Inner East", "Melbourne - Inner South", "Melbourne - North East", "Melbourne - North West", "Melbourne - Outer East", "Melbourne - South East", "Melbourne - West", "Mornington Peninsula", "North West", "Shepparton", "Warrnambool and South West"]
    let act = ["ACT-All", "Canberra"]
    let nsw = ["NSW-All", "Capital Region", "Central Coast", "Central West", "Coffs Harbour", "Far West and Orana", "Hunter Valley exc Newcastle", "Illawarra", "Mid North Coast", "Murray", "Newcastle and Lake Macquarie", "New England and North West", "Riverina", "Southern Highlands and Shoalhaven", "Sydney - Baulkham Hills and Hawkesbury", "Sydney - Blacktown", "Sydney - City and Inner South", "Sydney - Eastern Suburbs", "Sydney - Inner South West", "Sydney - Inner West", "Sydney - Northern Beaches", "Sydney - North Sydney and Hornsby", "Sydney - Outer South West", "Sydney - Outer West and Blue Mountains", "Sydney - Parramatta", "Sydney - Ryde", "Sydney - South West", "Sydney - Sutherland"]
    let nt = ["NT-All", "Darwin", "Northern Territory - Outback"]
    let qld = ["QLD-All", "Brisbane - East", "Brisbane Inner City", "Brisbane - North", "Brisbane - South", "Brisbane - West", "Cairns", "Darling Downs - Maranoa", "Fitzroy", "Gold Coast", "Ipswich", "Logan - Beaudesert", "Mackay", "Moreton Bay - North", "Moreton Bay - South", "Queensland - Outback", "Sunshine Coast", "Toowoomba", "Townsville", "Wide Bay"]
    let sa = ["SA-All", "Adelaide - Central and Hills", "Adelaide - North", "Adelaide - South", "Adelaide - West", "Barossa - Yorke - Mid North", "South Australia - Outback", "South Australia - South East"]
    let tas = ["TAS-All", "Hobart", "Launceston and North East", "South East", "West and North West"]
    let wa = ["WA-All", "Bunbury", "Mandurah", "Perth - Inner", "Perth - North East", "Perth - North West", "Perth - South East", "Perth - South West", "Western Australia - Outback", "Western Australia - Wheat Belt"]
    
    // Properties Pickers Option
    var titleProperties = [String]()
    var classifierProperties = [String]()
    
    // Hidden flags
    var areaPickerHidden = true
    var bboxMapHidden = true
    var titlePickerHidden = true
    var classifierPickerHidden = true
    var platteSegmentHidden = true
    var colorSliderHidden = true
    var opacitySliderHidden = true
    
    
    
    // Used for MapView
    // 这些变量用于在地图上选定区域
    // tapCount用于对点击次数进行统计
    var tapCount = 0
    // 以下四个变量用于分别统计两次点击的坐标
    var lowerLatitude:Double = 0.0
    var lowerLongitude:Double = 0.0
    var upperLatitude:Double = 0.0
    var upperLongitude:Double = 0.0
    // 定义两个marker，分别用来标记两次点击的点
    var marker1 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker2 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker3 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker4 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    // areaSelection用于根据两个marker的位置来画图
    var areaSelection = GMSPolygon()

    
    
    
    @IBOutlet var areaTitle: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var areaPicker: UIPickerView!
    
    @IBOutlet var bboxTitle: UILabel!
    @IBOutlet var bboxLabel: UILabel!
    @IBOutlet var bboxMap: GMSMapView!
    
    @IBOutlet var titleTitle: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titlePicker: UIPickerView!
    
    @IBOutlet var classifierTitle: UILabel!
    @IBOutlet var classifierLabel: UILabel!
    @IBOutlet var classifierPicker: UIPickerView!
    
    @IBOutlet var paletteTitle: UILabel!
    @IBOutlet var paletteLabel: UILabel!
    @IBOutlet var paletteSegment: UISegmentedControl!
    
    @IBOutlet var colorClassTitle: UILabel!
    @IBOutlet var colorClassLabel: UILabel!
    @IBOutlet var colorClassSlider: UISlider!
    
    @IBOutlet var opacityTitle: UILabel!
    @IBOutlet var opacityLabel: UILabel!
    @IBOutlet var opacitySlider: UISlider!
    
    
    @IBOutlet var simplifierSwitch: UISwitch!
    @IBOutlet var simplifierServer: UITextField!
    @IBOutlet var simplifierLevel: UISlider!
    @IBOutlet var simLevelLabel: UILabel!
    var simLevel: Float = 0.1
    var useSimplifier = false
    var serverAddress = "localhost:3000"
    
    @IBAction func simplifierOnOff(sender: UISwitch) {
        if sender.on {
            useSimplifier = true
            tableView.reloadData()
            print("On")
        } else {
            useSimplifier = false
            tableView.reloadData()
            print("Off")
        }
    }
    
    @IBAction func simplifierSlider(sender: AnyObject) {
        let slider = sender as! UISlider
        let i = Int(slider.value)
        slider.value = Float(i)
        simLevelLabel.text = "\(i)%"
        simLevel = slider.value / 100.0
    }
    
    @IBAction func inputAddress(sender: AnyObject) {
        let textField = sender as! UITextField
        serverAddress = textField.text!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Map Setting"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        // 装载Properties选项
        for (key, value) in propertyList {
            switch value {
            case "string":
                titleProperties.append(key)
            case "double", "int", "float", "decimal":
                classifierProperties.append(key)
            default:
                break
            }
        }
        
        if titleProperties.count > 0 {
            titleProperty = titleProperties[0]
        }
        if classifierProperties.count > 0 {
            classifierProperty = classifierProperties[0]
        }
        
        
        self.bboxMap.myLocationEnabled = true;
        self.bboxMap.mapType = kGMSTypeNormal;
        self.bboxMap.settings.compassButton = false;
        self.bboxMap.settings.myLocationButton = true;
        self.bboxMap.settings.zoomGestures = true
        self.bboxMap.settings.tiltGestures = false
        self.bboxMap.settings.rotateGestures = false
        self.bboxMap.settings.scrollGestures = true
        
        self.bboxMap.delegate = self;
        let camera = GMSCameraPosition.cameraWithLatitude(dataset.center.latitude, longitude: dataset.center.longitude, zoom: dataset.zoom)
        bboxMap.animateToCameraPosition(camera)
        
        // 为小屏幕iPhone优化
        if UIScreen.mainScreen().bounds.width <= 350.0 {
            areaLabel.font = areaLabel.font.fontWithSize(13.0)
            areaTitle.font = areaTitle.font.fontWithSize(13.0)
            bboxLabel.font = bboxLabel.font.fontWithSize(13.0)
            bboxTitle.font = bboxLabel.font.fontWithSize(13.0)
            titleLabel.font = titleLabel.font.fontWithSize(13.0)
            titleTitle.font = titleTitle.font.fontWithSize(13.0)
            classifierLabel.font = classifierLabel.font.fontWithSize(13.0)
            classifierTitle.font = classifierTitle.font.fontWithSize(13.0)
            paletteLabel.font = paletteLabel.font.fontWithSize(13.0)
            paletteTitle.font = paletteTitle.font.fontWithSize(13.0)
            opacityLabel.font = opacityLabel.font.fontWithSize(13.0)
            opacityTitle.font = opacityTitle.font.fontWithSize(13.0)
            colorClassLabel.font = colorClassLabel.font.fontWithSize(13.0)
            colorClassTitle.font = colorClassTitle.font.fontWithSize(13.0)
        }

        
        // 根据是否存储了Filter中已经过滤的Area或者BBOX，来更改默认设置
        
        if DataSet.filterBBOX.lowerLON != 0 {
            chooseBBOX = DataSet.filterBBOX
            areaLabel.text = "Chosen by filter"
            bboxLabel.text = chooseBBOX.printBBOX()
            DataSet.filterBBOX = BBOX(lowerLON: 0, lowerLAT: 0, upperLON: 0, upperLAT: 0)
        }
        
        
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        /***********/
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    
    /************************************* TABLE VIEW **************************************/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                areaPickerHidden = !areaPickerHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            if indexPath.row == 2 {
                bboxMapHidden = !bboxMapHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        case 1:
            if indexPath.row == 0 {
                titlePickerHidden = !titlePickerHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            if indexPath.row == 2 {
                classifierPickerHidden = !classifierPickerHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        case 2:
            if indexPath.row == 0 {
                platteSegmentHidden = !platteSegmentHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            if indexPath.row == 2 {
                colorSliderHidden = !colorSliderHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            if indexPath.row == 4 {
                opacitySliderHidden = !opacitySliderHidden
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if areaPickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        } else if bboxMapHidden && indexPath.section == 0 && indexPath.row == 3 {
            return 0
        } else if titlePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else if classifierPickerHidden && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        } else if platteSegmentHidden && indexPath.section == 2 && indexPath.row == 1 {
            return 0
        } else if colorSliderHidden && indexPath.section == 2 && indexPath.row == 3 {
            return 0
        } else if opacitySliderHidden && indexPath.section == 2 && indexPath.row == 5 {
            return 0
        } else if !useSimplifier && indexPath.section == 3 && indexPath.row == 1 {
            return 0
        } else if !useSimplifier && indexPath.section == 3 && indexPath.row == 2 {
            return 0
        }
        
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    
    /************************************* 3 PICKERS ***************************************/
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                return states.count
            } else {
                return suburbs.count
            }
        case 1:
            return titleProperties.count
        case 2:
            return classifierProperties.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                return states[row]
            } else {
                return suburbs[row]
            }
        case 1:
            return titleProperties[row]
        default:
            return classifierProperties[row]
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                let pickerLabel = UILabel()
                pickerLabel.textColor = UIColor.blackColor()
                pickerLabel.text = states[row]
                // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
                pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
                pickerLabel.textAlignment = NSTextAlignment.Center
                return pickerLabel
                
            } else {
                let pickerLabel = UILabel()
                pickerLabel.textColor = UIColor.blackColor()
                pickerLabel.text = suburbs[row]
                // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
                pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 12) // In this use your custom font
                pickerLabel.textAlignment = NSTextAlignment.Center
                return pickerLabel
            }
        case 1:
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = titleProperties[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
            return pickerLabel
        default:
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = classifierProperties[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
            return pickerLabel
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                switch states[row] {
                case "Capital Territory":
                    suburbs = act
                    areaLabel.text = "ACT-All"
                    chooseBBOX = bboxSet.BBoxes["ACT-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "New South Wales":
                    suburbs = nsw
                    areaLabel.text = "NSW-All"
                    chooseBBOX = bboxSet.BBoxes["NSW-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Northern Territory":
                    suburbs = nt
                    areaLabel.text = "NT-All"
                    chooseBBOX = bboxSet.BBoxes["NT-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Queensland":
                    suburbs = qld
                    areaLabel.text = "QLD-All"
                    chooseBBOX = bboxSet.BBoxes["QLD-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "South Australia":
                    suburbs = sa
                    areaLabel.text = "SA-All"
                    chooseBBOX = bboxSet.BBoxes["SA-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Tasmania":
                    suburbs = tas
                    areaLabel.text = "TAS-All"
                    chooseBBOX = bboxSet.BBoxes["TAS-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Victoria":
                    suburbs = vic
                    areaLabel.text = "VIC-All"
                    chooseBBOX = bboxSet.BBoxes["VIC-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Western Australia":
                    suburbs = wa
                    areaLabel.text = "WA-All"
                    chooseBBOX = bboxSet.BBoxes["WA-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                default:
                    break
                }
            } else {
                areaLabel.text = suburbs[row]
                chooseBBOX = bboxSet.BBoxes[suburbs[row]]!
                bboxLabel.text = chooseBBOX.printBBOX()
            }
            
            
            // 在地图上画出Bounding Box
            let rect = GMSMutablePath()
            rect.addCoordinate(CLLocationCoordinate2D(latitude: chooseBBOX.lowerLAT, longitude: chooseBBOX.lowerLON))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: chooseBBOX.upperLAT, longitude: chooseBBOX.lowerLON))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: chooseBBOX.upperLAT, longitude: chooseBBOX.upperLON))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: chooseBBOX.lowerLAT, longitude: chooseBBOX.upperLON))
            
            bboxMap.clear()
            let bounding = GMSPolygon(path: rect)
            bounding.tappable = true
            bounding.strokeColor = UIColor.blackColor()
            bounding.strokeWidth = 1.5
            bounding.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            
            bounding.map = bboxMap
            
            let zoomLevel = Float(round((log2(210 / abs(chooseBBOX.upperLON - chooseBBOX.lowerLON)) + 1) * 100) / 100) - 1.5
            let centerLatitude = (chooseBBOX.lowerLAT + chooseBBOX.upperLAT) / 2
            let centerLongitude = (chooseBBOX.lowerLON + chooseBBOX.upperLON) / 2
            
            let camera = GMSCameraPosition.cameraWithLatitude(centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
            bboxMap.animateToCameraPosition(camera)
            
        case 1:
            titleLabel.text = titleProperties[pickerView.selectedRowInComponent(0)]
            titleProperty = titleProperties[pickerView.selectedRowInComponent(0)]
        case 2:
            classifierLabel.text = classifierProperties[pickerView.selectedRowInComponent(0)]
            classifierProperty = classifierProperties[pickerView.selectedRowInComponent(0)]
        default:
            break
        }
        
    }
    

    
    
    
    /************************************* COLOR PALETTE ***********************************/
    
    @IBAction func paletteSelected(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            paletteLabel.text = "Red"
            palette = "Red"
        case 1:
            paletteLabel.text = "Orange"
            palette = "Orange"
        case 2:
            paletteLabel.text = "Green"
            palette = "Green"
        case 3:
            paletteLabel.text = "Blue"
            palette = "Blue"
        case 4:
            paletteLabel.text = "Purple"
            palette = "Purple"
        case 5:
            paletteLabel.text = "Gray"
            palette = "Gray"
        default:
            break
        }
    }
    
    
    /************************************* COLOR CLASS *************************************/
    
    @IBAction func colorClassChanged(sender: AnyObject) {
        let slider = sender as! UISlider
        let i = Int(slider.value)
        slider.value = Float(i)
        colorClassLabel.text = "\(i)"
        colorClass = i
    }
    
    
    /************************************* COLOR OPACITY ***********************************/
    
    @IBAction func colorOpacityChanged(sender: AnyObject) {
        let slider = sender as! UISlider
        let i = Int(slider.value)
        slider.value = Float(i)
        opacityLabel.text = "\(i)%"
        opacity = slider.value / 100.0
    }
    
    
    
    /************************************* MAP VIEW ****************************************/

    
    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        // print(coordinate)
        
        // 定义一个icon，用于作为自定义的Marker显示。第二句话用于将marker显示的点定义在中心位置
        var markerIcon = UIImage(named: "dot")
        markerIcon = markerIcon!.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, markerIcon!.size.height/2, 0))
        // 点击计数器
        self.tapCount += 1
        
        // 单数次点击的情况
        if (self.tapCount % 2 == 1) {
            // 点数次的点击，先清理遗留的坐标和Bounding Box
            marker1.map = nil
            marker2.map = nil
            marker3.map = nil
            marker4.map = nil
            areaSelection.map = nil
            
            self.lowerLatitude = coordinate.latitude
            self.lowerLongitude = coordinate.longitude
            // 覆盖掉之前的 marker1
            marker1 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker1.icon = markerIcon!
            marker1.appearAnimation = kGMSMarkerAnimationPop
            marker1.snippet = ("\(marker1.position.latitude)\n\(marker1.position.longitude)")
            marker1.map = self.bboxMap
        } else {
            // 双数次的点击，记录点击的坐标，更新全局变量
            self.upperLatitude = coordinate.latitude
            self.upperLongitude = coordinate.longitude
            // 覆盖掉之前的 marker2
            marker2 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker2.icon = markerIcon!
            marker2.appearAnimation = kGMSMarkerAnimationPop
            //marker2.snippet = ("\(marker2.position.latitude)\n\(marker2.position.longitude)")
            marker2.map = self.bboxMap
            
            // 在与marker1和marker2相对的地方，放置marker3和marker4
            marker3 = GMSMarker(position: CLLocationCoordinate2DMake(self.upperLatitude, self.lowerLongitude))
            marker4 = GMSMarker(position: CLLocationCoordinate2DMake(self.lowerLatitude, self.upperLongitude))
            marker3.icon = markerIcon!
            marker4.icon = markerIcon!
            marker3.appearAnimation = kGMSMarkerAnimationPop
            marker4.appearAnimation = kGMSMarkerAnimationPop
            //marker3.snippet = ("\(marker3.position.latitude)\n\(marker3.position.longitude)")
            //marker4.snippet = ("\(marker4.position.latitude)\n\(marker4.position.longitude)")
            marker3.map = self.bboxMap
            marker4.map = self.bboxMap
            
            
            
            // 两次点击确定一个Bounding Box
            let rect = GMSMutablePath()
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.lowerLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.lowerLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.upperLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.upperLongitude))
            // 将Bounding Box画在地图上
            areaSelection = GMSPolygon(path: rect)
            //areaSelection = GMSPolygon(path: rect)
            areaSelection.strokeColor = UIColor.blackColor()
            areaSelection.strokeWidth = 1.5
            areaSelection.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            areaSelection.tappable = true
            
            areaSelection.map = self.bboxMap
            
            let swLatitude = min(lowerLatitude, upperLatitude)
            let swLongitude = min(lowerLongitude, upperLongitude)
            let neLatitude = max(lowerLatitude, upperLatitude)
            let neLongitude = max(lowerLongitude, upperLongitude)
            
            
            let longitudeDistance = neLongitude - swLongitude
            let latitudeDistance = neLatitude - swLatitude
            // 如果所选范围过大，给出提示
            if longitudeDistance > 0.3 || latitudeDistance > 0.3 {
                
                let alertMessage = UIAlertController(title: "Large Area", message: "You have selected a large area, a mass of data may cause app crash.", preferredStyle: .Alert)
                                
                let retryHandler = { (action:UIAlertAction!) -> Void in
                    self.areaSelection.map = nil
                    self.marker1.map = nil
                    self.marker2.map = nil
                    self.marker3.map = nil
                    self.marker4.map = nil
                }
                let ignoreHandler = { (action:UIAlertAction!) -> Void in
                    self.chooseBBOX = BBOX(lowerLON: swLongitude, lowerLAT: swLatitude, upperLON: neLongitude, upperLAT: neLatitude)
                    self.bboxLabel.text = self.chooseBBOX.printBBOX()
                }
                
                // 向Alert弹框里面增加一个选项
                alertMessage.addAction(UIAlertAction(title: "IGNORE", style: .Destructive, handler: ignoreHandler))
                alertMessage.addAction(UIAlertAction(title: "RETRY", style: .Default, handler: retryHandler))

                
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
                
            } else {
                self.chooseBBOX = BBOX(lowerLON: swLongitude, lowerLAT: swLatitude, upperLON: neLongitude, upperLAT: neLatitude)
                self.bboxLabel.text = self.chooseBBOX.printBBOX()
            }

        }
        
    } // FUNCTION: mapView - didLongPressAtCoordinate
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        overlay.map = nil
        self.marker1.map = nil
        self.marker2.map = nil
        self.marker3.map = nil
        self.marker4.map = nil
        
    }

    

    
    
    
     // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "drawingMap" {
            let destinationController = segue.destinationViewController as! MapDrawingViewController
            destinationController.dataset = dataset
            destinationController.chooseBBOX = chooseBBOX
            destinationController.titleProperty = titleProperty
            destinationController.classifierProperty = classifierProperty
            destinationController.palette = palette
            destinationController.opacity = opacity
            destinationController.colorClass = colorClass
            destinationController.geom_name = geom_name
            
            
            destinationController.simLevel = simLevel
            destinationController.serverAddress = serverAddress
            destinationController.useSimplifier = useSimplifier
            // 在下页隐藏Tab Bar
            // destinationController.hidesBottomBarWhenPushed = true
        }
    }

    
    @IBAction func close(segue:UIStoryboardSegue) {
    
    }
    
}
