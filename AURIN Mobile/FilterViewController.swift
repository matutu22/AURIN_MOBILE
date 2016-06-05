//
//  FilterViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/5/1.
//  Copyright © 2016年 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    This file define a filter page. User can select an area to filter dataset.
 ********************************************************************************************/


import UIKit
import GoogleMaps

class FilterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate {

    @IBOutlet var areaPicker: UIPickerView!
    @IBOutlet var areaMap: GMSMapView!
    
    var filertBBOX = BBOX(lowerLON: 116.16, lowerLAT: -44.23, upperLON: 157.11, upperLAT: -7.19)
    
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
    
    // Used for MapView
    var tapCount = 0
    var lowerLatitude:Double = 0.0
    var lowerLongitude:Double = 0.0
    var upperLatitude:Double = 0.0
    var upperLongitude:Double = 0.0
    var marker1 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker2 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker3 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var marker4 = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
    var areaSelection = GMSPolygon()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.areaMap.myLocationEnabled = true;
        self.areaMap.mapType = kGMSTypeNormal;
        self.areaMap.settings.compassButton = false;
        self.areaMap.settings.myLocationButton = false;
        self.areaMap.settings.zoomGestures = true
        self.areaMap.settings.tiltGestures = false
        self.areaMap.settings.rotateGestures = false
        self.areaMap.settings.scrollGestures = true
        
        self.areaMap.delegate = self;
        let camera = GMSCameraPosition.cameraWithLatitude(-28.00, longitude: 133.135, zoom: 3)
        areaMap.animateToCameraPosition(camera)
        
        
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if component == 0 {
            return states.count
        } else {
            return suburbs.count
        }

    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
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
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == 0 {
            switch states[row] {
            case "Capital Territory":
                suburbs = act
                filertBBOX = bboxSet.BBoxes["ACT-All"]!
                pickerView.reloadAllComponents()
            case "New South Wales":
                suburbs = nsw
                filertBBOX = bboxSet.BBoxes["NSW-All"]!
                pickerView.reloadAllComponents()
            case "Northern Territory":
                suburbs = nt
                filertBBOX = bboxSet.BBoxes["NT-All"]!
                pickerView.reloadAllComponents()
            case "Queensland":
                suburbs = qld
                filertBBOX = bboxSet.BBoxes["QLD-All"]!
                pickerView.reloadAllComponents()
            case "South Australia":
                suburbs = sa
                filertBBOX = bboxSet.BBoxes["SA-All"]!
                pickerView.reloadAllComponents()
            case "Tasmania":
                suburbs = tas
                filertBBOX = bboxSet.BBoxes["TAS-All"]!
                pickerView.reloadAllComponents()
            case "Victoria":
                suburbs = vic
                filertBBOX = bboxSet.BBoxes["VIC-All"]!
                pickerView.reloadAllComponents()
            case "Western Australia":
                suburbs = wa
                filertBBOX = bboxSet.BBoxes["WA-All"]!
                pickerView.reloadAllComponents()
            default:
                break
            }
        } else {
            filertBBOX = bboxSet.BBoxes[suburbs[row]]!
        }
        
        // draw bounding box on the map
        let rect = GMSMutablePath()
        rect.addCoordinate(CLLocationCoordinate2D(latitude: filertBBOX.lowerLAT, longitude: filertBBOX.lowerLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: filertBBOX.upperLAT, longitude: filertBBOX.lowerLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: filertBBOX.upperLAT, longitude: filertBBOX.upperLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: filertBBOX.lowerLAT, longitude: filertBBOX.upperLON))
        
        areaMap.clear()
        let bounding = GMSPolygon(path: rect)
        bounding.tappable = true
        bounding.strokeColor = UIColor.blackColor()
        bounding.strokeWidth = 1.5
        bounding.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
        
        bounding.map = areaMap
        
        let zoomLevel = Float(round((log2(210 / abs(filertBBOX.upperLON - filertBBOX.lowerLON)) + 1) * 100) / 100) - 1.5
        let centerLatitude = (filertBBOX.lowerLAT + filertBBOX.upperLAT) / 2
        let centerLongitude = (filertBBOX.lowerLON + filertBBOX.upperLON) / 2
        
        
        
        let camera = GMSCameraPosition.cameraWithLatitude(centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
        areaMap.animateToCameraPosition(camera)
        
        
    }
    
    
    
    /************************************* MAP VIEW ****************************************/
    
    
    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        // print(coordinate)
        
        var markerIcon = UIImage(named: "dot")
        markerIcon = markerIcon!.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, markerIcon!.size.height/2, 0))
        // Count the taps
        self.tapCount += 1
        
        // When tap number is odd.
        if (self.tapCount % 2 == 1) {
            // clean the bounding box and dots.
            marker1.map = nil
            marker2.map = nil
            marker3.map = nil
            marker4.map = nil
            areaSelection.map = nil
            
            self.lowerLatitude = coordinate.latitude
            self.lowerLongitude = coordinate.longitude
            marker1 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker1.icon = markerIcon!
            marker1.appearAnimation = kGMSMarkerAnimationPop
            marker1.snippet = ("\(marker1.position.latitude)\n\(marker1.position.longitude)")
            marker1.map = self.areaMap
        } else {
            self.upperLatitude = coordinate.latitude
            self.upperLongitude = coordinate.longitude
            marker2 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker2.icon = markerIcon!
            marker2.appearAnimation = kGMSMarkerAnimationPop
            marker2.map = self.areaMap
            
            marker3 = GMSMarker(position: CLLocationCoordinate2DMake(self.upperLatitude, self.lowerLongitude))
            marker4 = GMSMarker(position: CLLocationCoordinate2DMake(self.lowerLatitude, self.upperLongitude))
            marker3.icon = markerIcon!
            marker4.icon = markerIcon!
            marker3.appearAnimation = kGMSMarkerAnimationPop
            marker4.appearAnimation = kGMSMarkerAnimationPop
            marker3.map = self.areaMap
            marker4.map = self.areaMap
            
            
            
            let rect = GMSMutablePath()
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.lowerLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.lowerLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.upperLongitude))
            rect.addCoordinate(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.upperLongitude))
            areaSelection = GMSPolygon(path: rect)
            areaSelection.strokeColor = UIColor.blackColor()
            areaSelection.strokeWidth = 1.5
            areaSelection.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            areaSelection.tappable = true
            
            areaSelection.map = self.areaMap
            
            let swLatitude = min(lowerLatitude, upperLatitude)
            let swLongitude = min(lowerLongitude, upperLongitude)
            let neLatitude = max(lowerLatitude, upperLatitude)
            let neLongitude = max(lowerLongitude, upperLongitude)

            
            self.filertBBOX = BBOX(lowerLON: swLongitude, lowerLAT: swLatitude, upperLON: neLongitude, upperLAT: neLatitude)
            
        }
        
        
        
    }
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        overlay.map = nil
        self.marker1.map = nil
        self.marker2.map = nil
        self.marker3.map = nil
        self.marker4.map = nil
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
