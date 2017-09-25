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
    @IBOutlet weak var resetFilter: UIButton!
    @IBOutlet weak var applyFilter: UIButton!
    
    @IBAction func applyFilter(_ sender: AnyObject){
        performSegue(withIdentifier: "applyFilter", sender: self)
    }
    
    @IBAction func resetFilter(_ sender: AnyObject){
        performSegue(withIdentifier: "resetFilter", sender: self)
    }
    
    var filterBBOX = BBOX(lowerLON: 116.16, lowerLAT: -44.23, upperLON: 157.11, upperLAT: -7.19)
    
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
        
        self.areaMap.isMyLocationEnabled = true;
        self.areaMap.mapType = .normal;
        self.areaMap.settings.compassButton = false;
        self.areaMap.settings.myLocationButton = false;
        self.areaMap.settings.zoomGestures = true
        self.areaMap.settings.tiltGestures = false
        self.areaMap.settings.rotateGestures = false
        self.areaMap.settings.scrollGestures = true
        
        self.areaMap.delegate = self;
        let camera = GMSCameraPosition.camera(withLatitude: -28.00, longitude: 133.135, zoom: 3)
        areaMap.animate(to: camera)
        
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if component == 0 {
            return Region.states.count
        } else {
            return Region.suburbs.count
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        if component == 0 {
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = Region.states[row]
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
            
        } else {
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = Region.suburbs[row]
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 12) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == 0 {
            switch Region.states[row] {
            case "Capital Territory":
                Region.suburbs = Region.act
                filterBBOX = bboxSet.BBoxes["ACT-All"]!
                pickerView.reloadAllComponents()
            case "New South Wales":
                Region.suburbs = Region.nsw
                filterBBOX = bboxSet.BBoxes["NSW-All"]!
                pickerView.reloadAllComponents()
            case "Northern Territory":
                Region.suburbs = Region.nt
                filterBBOX = bboxSet.BBoxes["NT-All"]!
                pickerView.reloadAllComponents()
            case "Queensland":
                Region.suburbs = Region.qld
                filterBBOX = bboxSet.BBoxes["QLD-All"]!
                pickerView.reloadAllComponents()
            case "South Australia":
                Region.suburbs = Region.sa
                filterBBOX = bboxSet.BBoxes["SA-All"]!
                pickerView.reloadAllComponents()
            case "Tasmania":
                Region.suburbs = Region.tas
                filterBBOX = bboxSet.BBoxes["TAS-All"]!
                pickerView.reloadAllComponents()
            case "Victoria":
                Region.suburbs = Region.vic
                filterBBOX = bboxSet.BBoxes["VIC-All"]!
                pickerView.reloadAllComponents()
            case "Western Australia":
                Region.suburbs = Region.wa
                filterBBOX = bboxSet.BBoxes["WA-All"]!
                pickerView.reloadAllComponents()
            default:
                break
            }
        } else {
            filterBBOX = bboxSet.BBoxes[Region.suburbs[row]]!
        }
        
        // draw bounding box on the map
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: filterBBOX.lowerLAT, longitude: filterBBOX.lowerLON))
        rect.add(CLLocationCoordinate2D(latitude: filterBBOX.upperLAT, longitude: filterBBOX.lowerLON))
        rect.add(CLLocationCoordinate2D(latitude: filterBBOX.upperLAT, longitude: filterBBOX.upperLON))
        rect.add(CLLocationCoordinate2D(latitude: filterBBOX.lowerLAT, longitude: filterBBOX.upperLON))
        
        areaMap.clear()
        let bounding = GMSPolygon(path: rect)
        bounding.isTappable = true
        bounding.strokeColor = UIColor.black
        bounding.strokeWidth = 1.5
        bounding.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
        
        bounding.map = areaMap
        
        let zoomLevel = Float(round((log2(210 / abs(filterBBOX.upperLON - filterBBOX.lowerLON)) + 1) * 100) / 100) - 1.5
        let centerLatitude = (filterBBOX.lowerLAT + filterBBOX.upperLAT) / 2
        let centerLongitude = (filterBBOX.lowerLON + filterBBOX.upperLON) / 2
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
        areaMap.animate(to: camera)
        
        
    }
    
    
    
    /************************************* MAP VIEW ****************************************/
    
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // print(coordinate)
        
        var markerIcon = UIImage(named: "dot")
        markerIcon = markerIcon!.withAlignmentRectInsets(UIEdgeInsetsMake(0, 0, markerIcon!.size.height/2, 0))
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
            marker1.appearAnimation = .pop
            marker1.snippet = ("\(marker1.position.latitude)\n\(marker1.position.longitude)")
            marker1.map = self.areaMap
        } else {
            self.upperLatitude = coordinate.latitude
            self.upperLongitude = coordinate.longitude
            marker2 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker2.icon = markerIcon!
            marker2.appearAnimation = .pop
            marker2.map = self.areaMap
            
            marker3 = GMSMarker(position: CLLocationCoordinate2DMake(self.upperLatitude, self.lowerLongitude))
            marker4 = GMSMarker(position: CLLocationCoordinate2DMake(self.lowerLatitude, self.upperLongitude))
            marker3.icon = markerIcon!
            marker4.icon = markerIcon!
            marker3.appearAnimation = .pop
            marker4.appearAnimation = .pop
            marker3.map = self.areaMap
            marker4.map = self.areaMap
            
            
            
            let rect = GMSMutablePath()
            rect.add(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.lowerLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.lowerLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.upperLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.upperLongitude))
            areaSelection = GMSPolygon(path: rect)
            areaSelection.strokeColor = UIColor.black
            areaSelection.strokeWidth = 1.5
            areaSelection.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            areaSelection.isTappable = true
            
            areaSelection.map = self.areaMap
            
            let swLatitude = min(lowerLatitude, upperLatitude)
            let swLongitude = min(lowerLongitude, upperLongitude)
            let neLatitude = max(lowerLatitude, upperLatitude)
            let neLongitude = max(lowerLongitude, upperLongitude)

            
            self.filterBBOX = BBOX(lowerLON: swLongitude, lowerLAT: swLatitude, upperLON: neLongitude, upperLAT: neLatitude)
            
        }
        
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
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
