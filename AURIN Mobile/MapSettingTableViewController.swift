//
//  MapSettingTableViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/15.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    Control the map setting view.
 ********************************************************************************************/


import UIKit
import GoogleMaps


class MapSettingTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate {

    // Receive data from former view.
    var propertyList = [String: String]()
    var dataset:Dataset!
    var geom_name = "ogr_geometry"

    
    // Passing data to next view.
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    var titleProperty: String = ""
    var classifierProperty: String = ""
    var palette: String = "Red"
    var colorClass: Int = 6
    var opacity: Float = 0.7
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("MapsettingTable View controller", geom_name)

        navigationItem.title = "Map Setting"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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
        
        
        self.bboxMap.isMyLocationEnabled = true;
        self.bboxMap.mapType = .normal;
        self.bboxMap.settings.compassButton = false;
        self.bboxMap.settings.myLocationButton = true;
        self.bboxMap.settings.zoomGestures = true
        self.bboxMap.settings.tiltGestures = false
        self.bboxMap.settings.rotateGestures = false
        self.bboxMap.settings.scrollGestures = true
        
        self.bboxMap.delegate = self;
        let camera = GMSCameraPosition.camera(withLatitude: dataset.center.latitude, longitude: dataset.center.longitude, zoom: dataset.zoom)
        bboxMap.animate(to: camera)
        
        if UIScreen.main.bounds.width <= 350.0 {
            areaLabel.font = areaLabel.font.withSize(13.0)
            areaTitle.font = areaTitle.font.withSize(13.0)
            bboxLabel.font = bboxLabel.font.withSize(13.0)
            bboxTitle.font = bboxLabel.font.withSize(13.0)
            titleLabel.font = titleLabel.font.withSize(13.0)
            titleTitle.font = titleTitle.font.withSize(13.0)
            classifierLabel.font = classifierLabel.font.withSize(13.0)
            classifierTitle.font = classifierTitle.font.withSize(13.0)
            paletteLabel.font = paletteLabel.font.withSize(13.0)
            paletteTitle.font = paletteTitle.font.withSize(13.0)
            opacityLabel.font = opacityLabel.font.withSize(13.0)
            opacityTitle.font = opacityTitle.font.withSize(13.0)
            colorClassLabel.font = colorClassLabel.font.withSize(13.0)
            colorClassTitle.font = colorClassTitle.font.withSize(13.0)
        }

        
        if DataSet.filterBBOX.lowerLON != 0 {
            chooseBBOX = DataSet.filterBBOX
            areaLabel.text = "Chosen by filter"
            bboxLabel.text = chooseBBOX.printBBOX()
            DataSet.filterBBOX = BBOX(lowerLON: 0, lowerLAT: 0, upperLON: 0, upperLAT: 0)
        }

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    
    /************************************* TABLE VIEW **************************************/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        }
        
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    
    /************************************* 3 PICKERS ***************************************/
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                return Region.states.count
            } else {
                return Region.suburbs.count
            }
        case 1:
            return titleProperties.count
        case 2:
            return classifierProperties.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                return Region.states[row]
            } else {
                return Region.suburbs[row]
            }
        case 1:
            return titleProperties[row]
        default:
            return classifierProperties[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        switch pickerView.tag {
        case 0:
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
        case 1:
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = titleProperties[row]
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
        default:
            let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.black
            pickerLabel.text = classifierProperties[row]
            pickerLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.center
            return pickerLabel
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            if component == 0 {
                switch Region.states[row] {
                case "Capital Territory":
                    Region.suburbs = Region.act
                    areaLabel.text = "ACT-All"
                    chooseBBOX = bboxSet.BBoxes["ACT-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "New South Wales":
                    Region.suburbs = Region.nsw
                    areaLabel.text = "NSW-All"
                    chooseBBOX = bboxSet.BBoxes["NSW-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Northern Territory":
                    Region.suburbs = Region.nt
                    areaLabel.text = "NT-All"
                    chooseBBOX = bboxSet.BBoxes["NT-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Queensland":
                    Region.suburbs = Region.qld
                    areaLabel.text = "QLD-All"
                    chooseBBOX = bboxSet.BBoxes["QLD-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "South Australia":
                    Region.suburbs = Region.sa
                    areaLabel.text = "SA-All"
                    chooseBBOX = bboxSet.BBoxes["SA-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Tasmania":
                    Region.suburbs = Region.tas
                    areaLabel.text = "TAS-All"
                    chooseBBOX = bboxSet.BBoxes["TAS-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Victoria":
                    Region.suburbs = Region.vic
                    areaLabel.text = "VIC-All"
                    chooseBBOX = bboxSet.BBoxes["VIC-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                case "Western Australia":
                    Region.suburbs = Region.wa
                    areaLabel.text = "WA-All"
                    chooseBBOX = bboxSet.BBoxes["WA-All"]!
                    bboxLabel.text = chooseBBOX.printBBOX()
                    pickerView.reloadAllComponents()
                default:
                    break
                }
            } else {
                areaLabel.text = Region.suburbs[row]
                chooseBBOX = bboxSet.BBoxes[Region.suburbs[row]]!
                bboxLabel.text = chooseBBOX.printBBOX()
            }
            
            let rect = GMSMutablePath()
            rect.add(CLLocationCoordinate2D(latitude: chooseBBOX.lowerLAT, longitude: chooseBBOX.lowerLON))
            rect.add(CLLocationCoordinate2D(latitude: chooseBBOX.upperLAT, longitude: chooseBBOX.lowerLON))
            rect.add(CLLocationCoordinate2D(latitude: chooseBBOX.upperLAT, longitude: chooseBBOX.upperLON))
            rect.add(CLLocationCoordinate2D(latitude: chooseBBOX.lowerLAT, longitude: chooseBBOX.upperLON))
            
            bboxMap.clear()
            let bounding = GMSPolygon(path: rect)
            bounding.isTappable = true
            bounding.strokeColor = UIColor.black
            bounding.strokeWidth = 1.5
            bounding.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            
            bounding.map = bboxMap
            
            let zoomLevel = Float(round((log2(210 / abs(chooseBBOX.upperLON - chooseBBOX.lowerLON)) + 1) * 100) / 100) - 1.5
            let centerLatitude = (chooseBBOX.lowerLAT + chooseBBOX.upperLAT) / 2
            let centerLongitude = (chooseBBOX.lowerLON + chooseBBOX.upperLON) / 2
            
            let camera = GMSCameraPosition.camera(withLatitude: centerLatitude, longitude: centerLongitude, zoom: zoomLevel)
            bboxMap.animate(to: camera)
            
        case 1:
            titleLabel.text = titleProperties[pickerView.selectedRow(inComponent: 0)]
            titleProperty = titleProperties[pickerView.selectedRow(inComponent: 0)]
        case 2:
            classifierLabel.text = classifierProperties[pickerView.selectedRow(inComponent: 0)]
            classifierProperty = classifierProperties[pickerView.selectedRow(inComponent: 0)]
        default:
            break
        }
        
    }
    

    
    
    
    /************************************* COLOR PALETTE ***********************************/
    
    @IBAction func paletteSelected(_ sender: UISegmentedControl) {
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
    
    @IBAction func colorClassChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        let i = Int(slider.value)
        slider.value = Float(i)
        colorClassLabel.text = "\(i)"
        colorClass = i
    }
    
    
    /************************************* COLOR OPACITY ***********************************/
    
    @IBAction func colorOpacityChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        let i = Int(slider.value)
        slider.value = Float(i)
        opacityLabel.text = "\(i)%"
        opacity = slider.value / 100.0
    }
    
    
    
    /************************************* MAP VIEW ****************************************/

    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {

        var markerIcon = UIImage(named: "dot")
        markerIcon = markerIcon!.withAlignmentRectInsets(UIEdgeInsetsMake(0, 0, markerIcon!.size.height/2, 0))

        self.tapCount += 1
        

        if (self.tapCount % 2 == 1) {

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
            marker1.appearAnimation = .pop
            marker1.snippet = ("\(marker1.position.latitude)\n\(marker1.position.longitude)")
            marker1.map = self.bboxMap
        } else {

            self.upperLatitude = coordinate.latitude
            self.upperLongitude = coordinate.longitude
            marker2 = GMSMarker(position: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
            marker2.icon = markerIcon!
            marker2.appearAnimation = .pop
            //marker2.snippet = ("\(marker2.position.latitude)\n\(marker2.position.longitude)")
            marker2.map = self.bboxMap
            
            marker3 = GMSMarker(position: CLLocationCoordinate2DMake(self.upperLatitude, self.lowerLongitude))
            marker4 = GMSMarker(position: CLLocationCoordinate2DMake(self.lowerLatitude, self.upperLongitude))
            marker3.icon = markerIcon!
            marker4.icon = markerIcon!
            marker3.appearAnimation = .pop
            marker4.appearAnimation = .pop
            //marker3.snippet = ("\(marker3.position.latitude)\n\(marker3.position.longitude)")
            //marker4.snippet = ("\(marker4.position.latitude)\n\(marker4.position.longitude)")
            marker3.map = self.bboxMap
            marker4.map = self.bboxMap
            
            
            

            let rect = GMSMutablePath()
            rect.add(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.lowerLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.lowerLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.upperLatitude, longitude: self.upperLongitude))
            rect.add(CLLocationCoordinate2D(latitude: self.lowerLatitude, longitude: self.upperLongitude))

            areaSelection = GMSPolygon(path: rect)
            //areaSelection = GMSPolygon(path: rect)
            areaSelection.strokeColor = UIColor.black
            areaSelection.strokeWidth = 1.5
            areaSelection.fillColor = UIColor(red:0, green:0, blue:0, alpha:0.2)
            areaSelection.isTappable = true
            
            areaSelection.map = self.bboxMap
            
            let swLatitude = min(lowerLatitude, upperLatitude)
            let swLongitude = min(lowerLongitude, upperLongitude)
            let neLatitude = max(lowerLatitude, upperLatitude)
            let neLongitude = max(lowerLongitude, upperLongitude)
            
            
            let longitudeDistance = neLongitude - swLongitude
            let latitudeDistance = neLatitude - swLatitude

            if longitudeDistance > 0.3 || latitudeDistance > 0.3 {
                
                let alertMessage = UIAlertController(title: "Large Area", message: "You have selected a large area, a mass of data may cause app crash.", preferredStyle: .alert)
                                
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
                alertMessage.addAction(UIAlertAction(title: "IGNORE", style: .destructive, handler: ignoreHandler))
                alertMessage.addAction(UIAlertAction(title: "RETRY", style: .default, handler: retryHandler))

                
                self.present(alertMessage, animated: true, completion: nil)
                
                
            } else {
                self.chooseBBOX = BBOX(lowerLON: swLongitude, lowerLAT: swLatitude, upperLON: neLongitude, upperLAT: neLatitude)
                self.bboxLabel.text = self.chooseBBOX.printBBOX()
            }

        }
        
    } // FUNCTION: mapView - didLongPressAtCoordinate
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        overlay.map = nil
        self.marker1.map = nil
        self.marker2.map = nil
        self.marker3.map = nil
        self.marker4.map = nil
        
    }


    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "drawingMap" {
            let destinationController = segue.destination as! MapDrawingViewController
            destinationController.dataset = dataset
            destinationController.chooseBBOX = chooseBBOX
            destinationController.titleProperty = titleProperty
            destinationController.classifierProperty = classifierProperty
            destinationController.palette = palette
            destinationController.opacity = opacity
            destinationController.colorClass = colorClass
            destinationController.geom_name = geom_name
            
        }
    }

    
    @IBAction func close(_ segue:UIStoryboardSegue) {
    
    }
    
}
